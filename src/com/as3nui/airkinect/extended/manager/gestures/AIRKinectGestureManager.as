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

package com.as3nui.airkinect.extended.manager.gestures {
	import com.as3nui.airkinect.extended.manager.skeleton.ExtendedSkeleton;

	import flash.display.Sprite;
	import flash.events.Event;

	/**
	 * Gesture Managers handles updating gestures through the different states,
	 * Gestures are added and removed to this Singleton to be updated on EnterFrame.
	 * For exmaple
	 * <p>
	 * <code>
	 * 		var leftSwipeGesture:SwipeGesture = new SwipeGesture(skeleton, AIRKinectSkeleton.HAND_LEFT, null, true, false, false);
	 *		AIRKinectGestureManager.addGesture(leftSwipeGesture);
	 * </code>
	 * </p>
	 *
	 *
	*/
	public class AIRKinectGestureManager {
		private static var _instance:AIRKinectGestureManager;

		private static function get instance():AIRKinectGestureManager {
			if (_instance) return _instance;
			_instance = new AIRKinectGestureManager();
			return _instance;
		}

		/**
		 * Cleanup Manager removes eneter frame and cleans up lookups
		 */
		public static function dispose():void {
			instance.dispose();
			_instance = null;
		}

		/**
		 * Add a gesture to the manager
		 * @param gesture		Gesture to add
		 */
		public static function addGesture(gesture:IKinectGesture):void {
			instance.addGesture(gesture);
		}

		/**
		 * Removes a gesture from the manager
		 * @param gesture		Gesture to remove
		 * @return				Index of gesture removed
		 */
		public static function removeGesture(gesture:IKinectGesture):int {
			return instance.removeGesture(gesture);
		}

		/**
		 * Removes all gestures from the manager for a specific skeleton
		 * @param skeleton		Skeleton to remove gestures of
		 * @return				Number of gestures removed from the skeleton
		 */
		public static function removeAllGestures(skeleton:ExtendedSkeleton):uint {
			return instance.removeAllGestures(skeleton);
		}


		protected var _pulseSprite:Sprite;
		protected var _gestures:Array;

		/**
		 * Gesture Manager is a singleton and should not be created as a instance
		 */
		public function AIRKinectGestureManager() {
			_pulseSprite = new Sprite();
			this._gestures = new Array();
		}

		/**
		 * Disposes all memory and cleans up enterframe
		 */
		public function dispose():void {
			this._gestures = null;
			_pulseSprite.removeEventListener(Event.ENTER_FRAME, onPulse);
		}

		/**
		 * Starts the enterframe management
		 */
		private function initPulse():void {
			_pulseSprite.addEventListener(Event.ENTER_FRAME, onPulse);
		}

		/**
		 * Removes enter frame management
		 */
		private function removePulse():void {
			_pulseSprite.removeEventListener(Event.ENTER_FRAME, onPulse);
		}

		/**
		 * Enter Frame pulse
		 * @param event		eneter frame event
		 */
		private function onPulse(event:Event):void {
			updateGestures();
		}

		/**
		 * Adds a gesture to the manager to be tracked and process through different States.
		 * @param gesture		Gesture to add
		 */
		public function addGesture(gesture:IKinectGesture):void {
			if (!_pulseSprite.hasEventListener(Event.ENTER_FRAME)) initPulse();
			this._gestures.push(gesture);
			this._gestures.sortOn("priority", Array.NUMERIC);
		}

		/**
		 * Removes a gesture from the manager. Gesture will no longer be processed
		 * @param gesture Gesture to remove
		 * @return	index of removed gesture
		 */
		public function removeGesture(gesture:IKinectGesture):int {
			var index:int = this._gestures.indexOf(gesture);
			if (index >= 0) {
				gesture.dispose();
				this._gestures.splice(index, 1);
			}

			if (_gestures.length == 0) removePulse();
			return index;
		}

		/**
		 * Removes all gestures that are on a skeleton from the manager.
		 * Useful when a skeleton is removed
		 * @param skeleton		Skeleton to remove gesture from
		 * @return				Number of gestures removed
		 */
		public function removeAllGestures(skeleton:ExtendedSkeleton):uint {
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

		/**
		 * updates the gestures through the different gesture states
		 */
		private function updateGestures():void {
			var skeletonsWithGestures:Vector.<ExtendedSkeleton> = new Vector.<ExtendedSkeleton>();
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