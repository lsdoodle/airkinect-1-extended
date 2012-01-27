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
	import com.as3nui.airkinect.extended.manager.skeleton.DeltaResult;
	import com.as3nui.airkinect.extended.manager.regions.Region;
	import com.as3nui.airkinect.extended.manager.skeleton.ExtendedSkeleton;

	import flash.geom.Vector3D;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;

	/**
	 * Swipe gesture is defined as a joint moving over a set velocity in some direction
	 * and then falling below another velocity. Swipes can be in any direction in space (left, right, forward back, up, down)
	 */
	public class SwipeGesture extends AbstractKinectGesture {
		/**
		 * Minimum delay (milliseoncds) allowed between Swipe Dispatches
		 */
		public static var DISPATCH_DELAY:uint = 1000;
		public static var LAST_DISPATCHED_LOOKUP:Dictionary = new Dictionary();

		/**
		 * Constant for Left Swipe Direction
		 */
		public static const DIRECTION_LEFT:String 		= DeltaResult.LEFT;
		/**
		 * Constant for Right Swipe Direction
		 */
		public static const DIRECTION_RIGHT:String 		= DeltaResult.RIGHT;
		/**
		 * Constant for Down Swipe Direction
		 */
		public static const DIRECTION_DOWN:String		= DeltaResult.DOWN;
		/**
		 * Constant for UpSwipe Direction
		 */
		public static const DIRECTION_UP:String 		= DeltaResult.UP;
		/**
		 * Constant for Back Swipe Direction
		 */
		public static const DIRECTION_BACK:String 		= DeltaResult.BACK;
		/**
		 * Constant for Forward Swipe Direction
		 */
		public static const DIRECTION_FORWARD:String 	= DeltaResult.FORWARD;

		/**
		 * Constant for X-Axis
		 */
		public static const AXIS_X:String				= "x";
		/**
		 * Constant for Y-Axis
		 */
		public static const AXIS_Y:String				= "y";
		/**
		 * Constant for Z-Axis
		 */
		public static const AXIS_Z:String				= "z";

		/**
		 * Joint being tracked for Swipe
		 */
		protected var _jointID:uint;

		/**
		 * Swipe Direction
		 */
		protected var _currentSwipeDirection:String;
		/**
		 * Delta Result
		 */
		protected var _currentDeltaResult:DeltaResult;
		/**
		 * Lookup for different Process Tests over each direction
		 */
		protected var _processSwipeTests:Dictionary;
		/**
		 * Lookup for different Start tests over each direction
		 */
		protected var _startSwipeTests:Array;
		/**
		 * Position at the start of the gesture
		 */
		protected var _gestureStartPosition:Vector3D;

		/**
		 * Steps in history to use to detect swipe
		 */
		protected var _historySteps:int = 7;

		/**
		 * Swipe Gestures supports 6 directions (3-Axis)
		 * @param skeleton		Skeleton to use for skeleton tracking
		 * @param jointID		JointID to track for Swipes
		 * @param regions		Optional Regions to force start of gesture in
		 * @param useX			Boolean for detecting Swipes on the X-Axis (Left/Right)
		 * @param useY			Boolean for detecting Swipes on the Y-Axis (Up/Down)
		 * @param useZ			Boolean for detecting Swipes on the Z-Axis (Forward/Back)
		 */
		public function SwipeGesture(skeleton:ExtendedSkeleton, jointID:uint, regions:Vector.<Region> = null, useX:Boolean = true, useY:Boolean = true, useZ:Boolean = true) {
			super(skeleton, regions);
			_jointID = jointID;

			_processSwipeTests = new Dictionary();
			_processSwipeTests[DeltaResult.LEFT] = {axis:AXIS_X, threshold:-.14};
			_processSwipeTests[DeltaResult.RIGHT] = {axis:AXIS_X, threshold:.14};

			_processSwipeTests[DeltaResult.UP] = {axis:AXIS_Y, threshold:-.14};
			_processSwipeTests[DeltaResult.DOWN] = {axis:AXIS_Y, threshold:.14};

			_processSwipeTests[DeltaResult.FORWARD] = {axis:AXIS_Z, threshold:-.2};
			_processSwipeTests[DeltaResult.BACK] = {axis:AXIS_Z, threshold:.2};

			_startSwipeTests = [];
			if (useX) _startSwipeTests.push({axis:AXIS_X, threshold:.2, positiveResult:DIRECTION_RIGHT, negativeResult:DIRECTION_LEFT});
			if (useY) _startSwipeTests.push({axis:AXIS_Y, threshold:.2, positiveResult:DIRECTION_DOWN, negativeResult:DIRECTION_UP});
			if (useZ) _startSwipeTests.push({axis:AXIS_Z, threshold:.35, positiveResult:DIRECTION_BACK, negativeResult:DIRECTION_FORWARD});
		}

		/**
		 * Dispose memory used by the Swipe Gesture
		 */
		override public function dispose():void {
			LAST_DISPATCHED_LOOKUP[_skeleton.trackingID] = null;
			delete LAST_DISPATCHED_LOOKUP[_skeleton.trackingID];
			super.dispose();
		}

		/**
		 * Tests for the Start of a Gesture. Checks to see if threshold is broken on each axis.
		 * @param axis				Axis to check
		 * @param threshold			Threhold to check against
		 * @param negativeResult	Result if delta is negative
		 * @param positiveResult	Result if Delta is positive
		 * @return
		 */
		protected function testForStartOfGesture(axis:String, threshold:Number, negativeResult:String, positiveResult:String):Boolean {
			if (_currentDeltaResult.delta[axis] <= -threshold) {
				_currentSwipeDirection = negativeResult;
				return true;
			} else if (_currentDeltaResult.delta[axis] >= threshold) {
				_currentSwipeDirection = positiveResult;
				return true;
			}
			return false;
		}

		/**
		 * Processes a Gesture after it has been started
		 * @param axis			Axis to check
		 * @param threshold		Threshold to check against
		 */
		protected function processGesture(axis:String, threshold:Number):void {
			//If the gesture is complete or Canceld Reset
			if (_currentState == GestureState.GESTURE_COMPLETE || _currentState == GestureState.GESTURE_CANCELED) {
				resetGesture();
				return;
			}

			//Negative Checking
			if (threshold <= 0) {
				//If the gesture is started and we are still above the cut off threshold. Process the gesture
				if (_currentState == GestureState.GESTURE_STARTED && _currentDeltaResult.delta[axis] <= threshold) {
					progressGesture();
				//If the Gesture is started and the threshold has below the threshold. Cancel
				} else if (_currentState == GestureState.GESTURE_STARTED && _currentDeltaResult.delta[axis] > threshold) {
					cancelGesture();
				//If the gesture is progressing and the delta is under the threshold. Successful Gesture
				} else if (_currentState == GestureState.GESTURE_PROGRESS && _currentDeltaResult.delta[axis] > threshold) {
					completeGesture();
				}
			//Positive Checking
			} else {
				//If the gesture is started and we are still above the cut off threshold. Process the gesture
				if (_currentState == GestureState.GESTURE_STARTED && _currentDeltaResult.delta[axis] >= threshold) {
					progressGesture();
				//If the gesture is started and below the cut off threshold. Cancel
				} else if (_currentState == GestureState.GESTURE_STARTED && _currentDeltaResult.delta[axis] < threshold) {
					cancelGesture();
				//If the gesture is progressing and the delta is under the threshold. Successful Gesture
				} else if (_currentState == GestureState.GESTURE_PROGRESS && _currentDeltaResult.delta[axis] < threshold) {
					completeGesture();
				}
			}
		}

		/**
		 * Updated by pulse of the Gesture Manager, this should not be called manually
		 */
		override public function update():void {
			super.update();

			//Calculates the delta change on the joint
			_currentDeltaResult = _skeleton.calculateDelta(_jointID, _historySteps);

			//If a direction is already determined
			if (_currentSwipeDirection) {
				//Process the gesture with the threshold information.
				if (_processSwipeTests[_currentSwipeDirection]) {
					processGesture(_processSwipeTests[_currentSwipeDirection].axis, _processSwipeTests[_currentSwipeDirection].threshold);
				}
			//Direction has nor been determined
			} else {
				//For each possible Start Test
				for each(var test:Object in _startSwipeTests) {
					//Test for the begining of a gesture on the axis
					if (testForStartOfGesture(test.axis, test.threshold, test.negativeResult, test.positiveResult)) {
						beginGesture();
						break;
					}
				}
			}
		}

		/**
		 * Called when agesture begins in any direction
		 */
		override protected function beginGesture():void {
			//Determins if this gesture has begun out of the region
			updateJointStartedOutOfRegion(_jointID, _historySteps);
//			trace(_currentSwipeDirection + " : Started");
//			trace("Out of Region :: " + _jointStartedOutOfRegion);
			super.beginGesture();
		}

		/**
		 * Process the gesture through all its states
		 */
		override protected function progressGesture():void {
//			trace(_currentSwipeDirection + " : Progress");
			super.progressGesture();
		}

		/**
		 * Gesture has been canceled
		 */
		override protected function cancelGesture():void {
//			trace(_currentSwipeDirection + " : Canceled");
			super.cancelGesture();
		}

		/**
		 * Gesture is complete
		 */
		override protected function completeGesture():void {
			//IF the gesture began outside of the Region, cancel it
			if (_jointStartedOutOfRegion) {
//				trace("Gesture complete, but started out of region");
				cancelGesture();
				return;
			}

			//If the gesture is attempting to happen to quickly aft5er a previous gesture, cancel it
			if(LAST_DISPATCHED_LOOKUP[_skeleton.trackingID] == null) LAST_DISPATCHED_LOOKUP[_skeleton.trackingID] = 0;
			if(LAST_DISPATCHED_LOOKUP[_skeleton.trackingID]  + DISPATCH_DELAY > getTimer()){
//				trace("Swipe Attempted too soon after last Swipe, canceled, wait " + ((LAST_DISPATCHED_LOOKUP[_skeleton.trackingID]  + DISPATCH_DELAY) - getTimer()) +"ms");
				cancelGesture();
				return;
			}

			//Gesture was successful. Record the time and dispatch the event
			LAST_DISPATCHED_LOOKUP[_skeleton.trackingID]  = getTimer();
//			trace("Swipe Complete");
			super.completeGesture();
		}

		/**
		 * Resets the Gesture
		 */
		override protected function resetGesture():void {
//			trace(_currentSwipeDirection + " : Reset");
			_currentSwipeDirection = null;
			_currentDeltaResult = null;
			_gestureStartPosition = null;
			super.resetGesture();
		}

		/**
		 * Access for the current Swipe axis of the gesture (X,Y,Z)
		 */
		public function get currentSwipeAxis():String {
			if(_currentSwipeDirection && _processSwipeTests[_currentSwipeDirection]) return _processSwipeTests[_currentSwipeDirection].axis;
			else return null;
		}

		/**
		 * Access to the current Swipe Direction (LEFT, RIGHT, UP, DOWN, FORWARD, BACK)
		 */
		public function get currentSwipeDirection():String {
			return _currentSwipeDirection;
		}

		/**
		 * Access to the current Delta results for this gesture
		 */
		public function get currentDeltaResult():DeltaResult {
			return _currentDeltaResult;
		}
	}
}