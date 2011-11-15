/**
 *
 * User: rgerbasi
 * Date: 10/4/11
 * Time: 6:52 PM
 */
package com.as3nui.airkinect.extended.manager.gestures {
	import com.as3nui.airkinect.extended.manager.skeleton.Skeleton;

	import flash.display.Sprite;
	import flash.events.Event;

	public class AIRKinectGestureManager {
		private static var _instance:AIRKinectGestureManager;

		private static function get instance():AIRKinectGestureManager {
			if (_instance) return _instance;
			_instance = new AIRKinectGestureManager();
			return _instance;
		}

		public static function dispose():void {
			instance.dispose();
		}

		public static function addGesture(gesture:IKinectGesture):void {
			instance.addGesture(gesture);
		}

		public static function removeGesture(gesture:IKinectGesture):int {
			return instance.removeGesture(gesture);
		}

		public static function removeAllGestures(skeleton:Skeleton):uint {
			return instance.removeAllGestures(skeleton);
		}


		protected var _pulseSprite:Sprite;
		protected var _gestures:Array;
		
		public function AIRKinectGestureManager() {
			_pulseSprite = new Sprite();
			this._gestures = new Array();
		}

		public function dispose():void {
			this._gestures = null;
			_pulseSprite.removeEventListener(Event.ENTER_FRAME, onPulse);
		}

		//----------------------------------
		// Pulse Functions
		//----------------------------------
		private function initPulse():void {
			_pulseSprite.addEventListener(Event.ENTER_FRAME, onPulse);
		}

		private function removePulse():void {
			_pulseSprite.removeEventListener(Event.ENTER_FRAME, onPulse);
		}

		private function onPulse(event:Event):void {
			updateGestures();
		}

		//----------------------------------
		// Kinect Gesture Management
		//----------------------------------
		public function addGesture(gesture:IKinectGesture):void {
			if (!_pulseSprite.hasEventListener(Event.ENTER_FRAME)) initPulse();
			this._gestures.push(gesture);
			this._gestures.sortOn("priority", Array.NUMERIC);
		}

		public function removeGesture(gesture:IKinectGesture):int {
			var index:int = this._gestures.indexOf(gesture);
			if (index >= 0) {
				gesture.dispose();
				this._gestures.splice(index, 1);
			}

			if (_gestures.length == 0) removePulse();
			return index;
		}

		public function removeAllGestures(skeleton:Skeleton):uint {
			var remainingGestures:Array = [];
			var count:uint = 0;
			for each(var gesture:IKinectGesture in this._gestures) {
				if (gesture.skeleton != skeleton) {
					remainingGestures.push(gesture);
				} else {
					gesture.dispose();
					count++;
				}
			}

			this._gestures = remainingGestures;
			return count;
		}

		private function updateGestures():void {
			var skeletonsWithGestures:Vector.<Skeleton> = new Vector.<Skeleton>();
			var executedGesturePriority:uint = 0;

			for each(var gesture:IKinectGesture in this._gestures) {
				if (skeletonsWithGestures.indexOf(gesture.skeleton) && gesture.priority < executedGesturePriority) break;

				//Skeleton was deleted
				if(gesture.skeleton.currentSkeleton == null){
					removeAllGestures(gesture.skeleton)
				}else{
					gesture.update();
					if (gesture.currentState == GestureState.GESTURE_STARTED || gesture.currentState == GestureState.GESTURE_PROGRESS || (gesture.currentState == GestureState.GESTURE_COMPLETE)) {
						skeletonsWithGestures.push(gesture.skeleton);
						executedGesturePriority = gesture.priority;
					}
				}
			}
		}
	}
}