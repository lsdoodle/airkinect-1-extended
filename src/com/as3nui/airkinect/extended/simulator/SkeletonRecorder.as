/**
 *
 * User: rgerbasi
 * Date: 12/6/11
 * Time: 2:19 PM
 */
package com.as3nui.airkinect.extended.simulator {
	import com.as3nui.nativeExtensions.kinect.AIRKinect;
	import com.as3nui.nativeExtensions.kinect.data.SkeletonFrame;
	import com.as3nui.nativeExtensions.kinect.data.SkeletonPosition;
	import com.as3nui.nativeExtensions.kinect.events.SkeletonFrameEvent;

	import flash.events.EventDispatcher;
	import flash.geom.Vector3D;
	import flash.utils.getTimer;

	public class SkeletonRecorder extends EventDispatcher {
		public static const STOPPED:String 		= "stopped";
		public static const RECORDING:String 	= "recording";
		public static const PAUSED:String 		= "paused";

		private var _state:String = STOPPED;

		private var _currentRecording:Vector.<TimeCodedSkeletonFrame>;

		private var _recordingStartTimer:int;
		private var _recordedDuration:int;
		private var _ignoreEmptyFrames:Boolean;

		public function SkeletonRecorder() {
			_currentRecording = new <TimeCodedSkeletonFrame>[];
			_ignoreEmptyFrames = true;
		}

		public function record():void {
			//If stopped start a new recording
			if (_state == STOPPED) clear();
			_recordingStartTimer = getTimer();
			_state = RECORDING;
			AIRKinect.addEventListener(SkeletonFrameEvent.UPDATE, onSkeletonFrame);
		}

		public function pause():void {
			_state = PAUSED;
			AIRKinect.removeEventListener(SkeletonFrameEvent.UPDATE, onSkeletonFrame);
		}

		public function stop():void {
			_state = STOPPED;
			_recordedDuration = getTimer() - _recordingStartTimer;
			AIRKinect.removeEventListener(SkeletonFrameEvent.UPDATE, onSkeletonFrame);
		}

		public function clear():void {
			_currentRecording = new <TimeCodedSkeletonFrame>[];
		}

		private function onSkeletonFrame(event:SkeletonFrameEvent):void {
			if (!_ignoreEmptyFrames || event.skeletonFrame.numSkeletons > 0) {
				_currentRecording.push(new TimeCodedSkeletonFrame(getTimer(), event.skeletonFrame));
			}
		}

		public function get currentRecording():Vector.<TimeCodedSkeletonFrame> {
			return _currentRecording;
		}

		public function get currentRecordingXML():XML {
			if(_state != STOPPED) return null;
			var xml:XML = <AIRKinectRecording/>;
			xml.@duration 			= _recordedDuration;
			xml.@recordStartTime 	= _recordingStartTimer;

			var element:Vector3D;
			var frameXML:XML;
			var positionXML:XML;
			var elementXML:XML;

			var skeletonFrame:SkeletonFrame;
			for each(var timeCodedSkeletonFrame:TimeCodedSkeletonFrame in _currentRecording) {
				skeletonFrame = timeCodedSkeletonFrame.skeletonFrame;
				frameXML = <SkeletonFrame/>;
				frameXML.@recordedTime = timeCodedSkeletonFrame.time;
				for each(var skeletonPosition:SkeletonPosition in skeletonFrame.skeletonsPositions) {
					positionXML = <SkeletonPosition/>;
					positionXML.@trackingID = skeletonPosition.trackingID;
					positionXML.@timestamp = skeletonPosition.timestamp;
					positionXML.@frame = skeletonPosition.frameNumber;
					positionXML.@trackingState = skeletonPosition.trackingState;

					for (var elementIndex:uint = 0; elementIndex < skeletonPosition.elements.length; elementIndex++) {
						element = skeletonPosition.getElementRaw(elementIndex);
						elementXML = <element/>;
						elementXML.@id = elementIndex;
						elementXML.@x = element.x.toString();
						elementXML.@y = element.y.toString();
						elementXML.@z = element.z.toString();
						positionXML.appendChild(elementXML);
					}
					frameXML.appendChild(positionXML);
				}
				xml.appendChild(frameXML)
			}
			return xml;
		}

		public function get recording():Boolean {
			return _state == RECORDING;
		}

		public function get stopped():Boolean {
			return _state == STOPPED;
		}

		public function get paused():Boolean {
			return _state == PAUSED;
		}

		public function get ignoreEmptyFrames():Boolean {
			return _ignoreEmptyFrames;
		}

		public function set ignoreEmptyFrames(value:Boolean):void {
			_ignoreEmptyFrames = value;
		}
	}
}

import com.as3nui.nativeExtensions.kinect.data.SkeletonFrame;

class TimeCodedSkeletonFrame {
	private var _time:uint;
	private var _skeletonFrame:SkeletonFrame;

	public function TimeCodedSkeletonFrame(time:uint, skeletonFrame:SkeletonFrame):void {
		_time = time;
		_skeletonFrame = skeletonFrame;
	}

	public function get time():uint {
		return _time;
	}

	public function get skeletonFrame():SkeletonFrame {
		return _skeletonFrame;
	}
}