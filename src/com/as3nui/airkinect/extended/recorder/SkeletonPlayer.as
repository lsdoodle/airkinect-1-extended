/**
 *
 * User: rgerbasi
 * Date: 12/6/11
 * Time: 4:39 PM
 */
package com.as3nui.airkinect.extended.recorder {
	import com.as3nui.nativeExtensions.kinect.data.SkeletonFrame;
	import com.as3nui.nativeExtensions.kinect.data.SkeletonPosition;
	import com.as3nui.nativeExtensions.kinect.events.SkeletonFrameEvent;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Vector3D;
	import flash.utils.getTimer;

	public class SkeletonPlayer extends EventDispatcher {
		public static const STOPPED:String = "stopped";
		public static const PAUSED:String = "paused";
		public static const PLAYING:String = "playing";


		private var _pulseSprite:Sprite;
		private var _loop:Boolean;
		private var _currentXML:XML;
		private var _currentFrame:int;
		private var _endFrame:int;

		private var _delay:uint;
		private var _lastDispatchedTime:int;
		private var _skipInitialDelay:Boolean;
		
		private var _state:String = STOPPED;

		public function SkeletonPlayer() {
			_pulseSprite = new Sprite();
		}

		public function play(xml:XML, loop:Boolean = false, skipInitialDelay:Boolean = true):void {
			_loop = loop;
			_currentXML = xml;
			_currentFrame = 0;
			_endFrame = _currentXML..SkeletonFrame.length();
			_lastDispatchedTime = getTimer();
			_skipInitialDelay = skipInitialDelay;
			_delay = _skipInitialDelay ? 0 : parseInt(_currentXML..SkeletonFrame[0].@recordedTime) - parseInt(_currentXML.@recordStartTime);
			_pulseSprite.addEventListener(Event.ENTER_FRAME, onUpdate);

			_state = PLAYING;
		}

		public function resume():void {
			_pulseSprite.addEventListener(Event.ENTER_FRAME, onUpdate);
			_state = PLAYING;
		}

		public function pause():void {
			_pulseSprite.removeEventListener(Event.ENTER_FRAME, onUpdate);
			_state = PAUSED;
		}

		public function stop():void {
			_currentFrame = 0;
			_pulseSprite.removeEventListener(Event.ENTER_FRAME, onUpdate);
			_state = STOPPED;

			var skeletonFrame:SkeletonFrame = new SkeletonFrame(new Vector.<SkeletonPosition>());
			this.dispatchEvent(new SkeletonFrameEvent(skeletonFrame));
		}

		private function onUpdate(event:Event):void {
			if (!_currentXML) return;
			if (getTimer() > _lastDispatchedTime + _delay) {
				_lastDispatchedTime = getTimer();

				var skeletonPositions:Vector.<SkeletonPosition> = new <SkeletonPosition>[];
				var currentFrame:XML = _currentXML..SkeletonFrame[_currentFrame];
				var elements:Vector.<Vector3D>;
				var elementXML:XML;
				for each(var skeletonPositionXML:XML in currentFrame..SkeletonPosition) {
					elements = new Vector.<Vector3D>(skeletonPositionXML..element.length());
					for (var elementIndex:uint = 0; elementIndex < elements.length; elementIndex++) {
						elementXML = skeletonPositionXML..element[elementIndex];
						elements[parseInt(elementXML.@id)] = new Vector3D(parseFloat(elementXML.@x), parseFloat(elementXML.@y), parseFloat(elementXML.@z));
					}

					var skeletonPosition:SkeletonPosition = new SkeletonPosition(
							parseInt(skeletonPositionXML.@frame),
							parseInt(skeletonPositionXML.@timestamp),
							parseInt(skeletonPositionXML.@trackingID),
							parseInt(skeletonPositionXML.@trackingState),
							elements);

					skeletonPositions.push(skeletonPosition);
				}

				var skeletonFrame:SkeletonFrame = new SkeletonFrame(skeletonPositions);
				this.dispatchEvent(new SkeletonFrameEvent(skeletonFrame));

				_currentFrame++;
				if (_currentFrame >= _endFrame) {
					if (_loop) {
						_delay = _skipInitialDelay ? 0 : parseInt(_currentXML..SkeletonFrame[0].@recordedTime) - parseInt(_currentXML.@recordStartTime);
						_currentFrame = 0;
					} else {
						stop();
					}
				}else{
					_delay =  parseInt(_currentXML..SkeletonFrame[_currentFrame].@recordedTime) - parseInt(currentFrame.@recordedTime);
				}
			}
		}


		public function get playing():Boolean {
			return _state == PLAYING;
		}

		public function get paused():Boolean {
			return _state == PAUSED;
		}

		public function get stopped():Boolean {
			return _state == STOPPED;
		}

	}
}