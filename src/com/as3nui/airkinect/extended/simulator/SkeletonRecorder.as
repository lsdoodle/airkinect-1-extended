/**
 *
 * User: rgerbasi
 * Date: 12/6/11
 * Time: 2:19 PM
 */
package com.as3nui.airkinect.extended.simulator {
	import com.as3nui.nativeExtensions.kinect.AIRKinect;
	import com.as3nui.nativeExtensions.kinect.data.AIRKinectSkeleton;
	import com.as3nui.nativeExtensions.kinect.data.AIRKinectSkeletonJoint;
	import com.as3nui.nativeExtensions.kinect.data.AIRKinectSkeletonFrame;
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
		public static const STOPPED:String 		= "stopped";
		
		/**
		 * Recording State of Recorder
		 */
		public static const RECORDING:String 	= "recording";

		/**
		 * Paused state of recorder
		 */
		public static const PAUSED:String 		= "paused";

		/**
		 * Current recorder state
		 */
		private var _state:String = STOPPED;

		/**
		 * A vector of TimeCodedSkeletonFrames that have been recorded
		 */
		private var _currentRecording:Vector.<TimeCodedSkeletonFrame>;

		/**
		 * Time inwhich recording started
		 */
		private var _recordingStartTimer:int;
		/**
		 * Duration of the recording
		 */
		private var _recordedDuration:int;
		
		/**
		 * Whether recording should ignore empty skeleton frames.
		 */
		private var _ignoreEmptyFrames:Boolean;

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
			if(recording) return;
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
			if(!recording) return;
			_state = PAUSED;
			AIRKinect.removeEventListener(SkeletonFrameEvent.UPDATE, onSkeletonFrame);
		}

		/**
		 * Stops the recording
		 */
		public function stop():void {
			if(!recording) return;
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
		private function onSkeletonFrame(event:SkeletonFrameEvent):void {
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
			if(_state != STOPPED) return null;
			var xml:XML = <AIRKinectRecording/>;
			xml.@duration 			= _recordedDuration;
			xml.@recordStartTime 	= _recordingStartTimer;

			var joint:AIRKinectSkeletonJoint;
			var frameXML:XML;
			var positionXML:XML;
			var jointXML:XML;

			var skeletonFrame:AIRKinectSkeletonFrame;
			for each(var timeCodedSkeletonFrame:TimeCodedSkeletonFrame in _currentRecording) {
				skeletonFrame = timeCodedSkeletonFrame.skeletonFrame;
				frameXML = <SkeletonFrame/>;
				frameXML.@recordedTime = timeCodedSkeletonFrame.time;
				for each(var skeletonPosition:AIRKinectSkeleton in skeletonFrame.skeletonsPositions) {
					positionXML = <SkeletonPosition/>;
					positionXML.@trackingID = skeletonPosition.trackingID;
					positionXML.@timestamp = skeletonPosition.timestamp;
					positionXML.@frame = skeletonPosition.frameNumber;
					positionXML.@trackingState = skeletonPosition.trackingState;

					for (var jointIndex:uint = 0; jointIndex < skeletonPosition.joints.length; jointIndex++) {
						joint = skeletonPosition.getJointRaw(jointIndex);
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

import com.as3nui.nativeExtensions.kinect.data.AIRKinectSkeletonFrame;

/**
 * Timecoded Skeleton Frame is used to associate a Skeleton Frame with the time of a recording.
 */
class TimeCodedSkeletonFrame {
	private var _time:uint;
	private var _skeletonFrame:AIRKinectSkeletonFrame;

	public function TimeCodedSkeletonFrame(time:uint, skeletonFrame:AIRKinectSkeletonFrame):void {
		_time = time;
		_skeletonFrame = skeletonFrame;
	}

	public function get time():uint {
		return _time;
	}

	public function get skeletonFrame():AIRKinectSkeletonFrame {
		return _skeletonFrame;
	}
}