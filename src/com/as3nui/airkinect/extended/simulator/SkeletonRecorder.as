/*
 * Copyright 2012 AS3NUI
 *
 *    Licensed under the Apache License, Version 2.0 (the "License");
 *    you may not use this file except in compliance with the License.
 *    You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *    Unless required by applicable law or agreed to in writing, software
 *    distributed under the License is distributed on an "AS IS" BASIS,
 *    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *    See the License for the specific language governing permissions and
 *    limitations under the License.
 */

package com.as3nui.airkinect.extended.simulator {
	import com.as3nui.airkinect.extended.simulator.data.TimeCodedSkeletonFrame;
	import com.as3nui.nativeExtensions.kinect.AIRKinect;
	import com.as3nui.nativeExtensions.kinect.data.AIRKinectSkeleton;
	import com.as3nui.nativeExtensions.kinect.data.AIRKinectSkeletonFrame;
	import com.as3nui.nativeExtensions.kinect.data.AIRKinectSkeletonJoint;
	import com.as3nui.nativeExtensions.kinect.events.SkeletonFrameEvent;

	import flash.events.EventDispatcher;
	import flash.utils.getTimer;

	/**
	 * Skeleton Recorder is used to capture Skeleton Frames from the Kinect and record them.
	 * Upon completion data can be retrieved as XML
	 */
	public class SkeletonRecorder extends EventDispatcher {
		/**
		 * Stopped state of recording
		 */
		public static const STOPPED:String = "stopped";

		/**
		 * Recording State of Recorder
		 */
		public static const RECORDING:String = "recording";

		/**
		 * Paused state of recorder
		 */
		public static const PAUSED:String = "paused";

		/**
		 * Current recorder state
		 */
		protected var _state:String = STOPPED;

		/**
		 * A vector of TimeCodedSkeletonFrames that have been recorded
		 */
		protected var _currentRecording:Vector.<TimeCodedSkeletonFrame>;

		/**
		 * Time inwhich recording started
		 */
		protected var _recordingStartTimer:int;
		/**
		 * Duration of the recording
		 */
		protected var _recordedDuration:int;

		/**
		 * Whether recording should ignore empty skeleton frames.
		 */
		protected var _ignoreEmptyFrames:Boolean;

		/**
		 * Skeleton Recorder constructor
		 */
		public function SkeletonRecorder() {
			_currentRecording = new <TimeCodedSkeletonFrame>[];
			_ignoreEmptyFrames = true;
		}

		/**
		 * Starts recording Skeleton Frames from the Kinect
		 */
		public function record():void {
			if (recording) return;
			//If stopped start a new recording
			if (_state == STOPPED) clear();
			_recordingStartTimer = getTimer();
			_state = RECORDING;
			AIRKinect.addEventListener(SkeletonFrameEvent.UPDATE, onSkeletonFrame);
		}

		/**
		 * Pauses the recorder
		 */
		public function pause():void {
			if (!recording) return;
			_state = PAUSED;
			AIRKinect.removeEventListener(SkeletonFrameEvent.UPDATE, onSkeletonFrame);
		}

		/**
		 * Stops the recording
		 */
		public function stop():void {
			if (!recording) return;
			_state = STOPPED;
			_recordedDuration = getTimer() - _recordingStartTimer;
			AIRKinect.removeEventListener(SkeletonFrameEvent.UPDATE, onSkeletonFrame);
		}

		/**
		 * Clears out the current recording data
		 */
		public function clear():void {
			_currentRecording = new <TimeCodedSkeletonFrame>[];
		}

		/**
		 * Event handler for Skeleton from from Kinect. Adds frame to recorded buffer
		 * @param event		SkeletonFrameEvent
		 */
		protected function onSkeletonFrame(event:SkeletonFrameEvent):void {
			if (!_ignoreEmptyFrames || event.skeletonFrame.numSkeletons > 0) {
				_currentRecording.push(new TimeCodedSkeletonFrame(getTimer(), event.skeletonFrame));
			}
		}

		/**
		 * Returns the current Recording as a vector
		 */
		public function get currentRecording():Vector.<TimeCodedSkeletonFrame> {
			return _currentRecording;
		}

		/**
		 * Returns the current Recording in XML format
		 */
		public function get currentRecordingXML():XML {
			if (_state != STOPPED) return null;
			var xml:XML = <AIRKinectRecording/>;
			xml.@duration = _recordedDuration;
			xml.@recordStartTime = _recordingStartTimer;

			var joint:AIRKinectSkeletonJoint;
			var frameXML:XML;
			var positionXML:XML;
			var jointXML:XML;

			var skeletonFrame:AIRKinectSkeletonFrame;
			for each(var timeCodedSkeletonFrame:TimeCodedSkeletonFrame in _currentRecording) {
				skeletonFrame = timeCodedSkeletonFrame.skeletonFrame;
				frameXML = <SkeletonFrame/>;
				frameXML.@recordedTime = timeCodedSkeletonFrame.time;
				for each(var skeleton:AIRKinectSkeleton in skeletonFrame.skeletons) {
					positionXML = <Skeleton/>;
					positionXML.@trackingID = skeleton.trackingID;
					positionXML.@timestamp = skeleton.timestamp;
					positionXML.@frame = skeleton.frameNumber;
					positionXML.@trackingState = skeleton.trackingState;

					for (var jointIndex:uint = 0; jointIndex < skeleton.joints.length; jointIndex++) {
						joint = skeleton.getJointRaw(jointIndex);
						jointXML = <joint/>;
						jointXML.@id = jointIndex;
						jointXML.@x = joint.x.toString();
						jointXML.@y = joint.y.toString();
						jointXML.@z = joint.z.toString();
						positionXML.appendChild(jointXML);
					}
					frameXML.appendChild(positionXML);
				}
				xml.appendChild(frameXML)
			}
			return xml;
		}

		/**
		 * Boolean true if the recorder is recording
		 */
		public function get recording():Boolean {
			return _state == RECORDING;
		}

		/**
		 * Boolean true if the recorder is currently stopped
		 */
		public function get stopped():Boolean {
			return _state == STOPPED;
		}

		/**
		 * Boolean true if the recorder is currently paused
		 */
		public function get paused():Boolean {
			return _state == PAUSED;
		}

		/**
		 * Boolean to set if Empty frames should be ignored.
		 * If this is true any frames with 0 skeletons will not be recorded.
		 * If false all frames will be recorded regardless of number of skeletons
		 */
		public function get ignoreEmptyFrames():Boolean {
			return _ignoreEmptyFrames;
		}

		/**
		 * Boolean to set if Empty frames should be ignored.
		 * If this is true any frames with 0 skeletons will not be recorded.
		 * If false all frames will be recorded regardless of number of skeletons
		 */
		public function set ignoreEmptyFrames(value:Boolean):void {
			_ignoreEmptyFrames = value;
		}
	}
}