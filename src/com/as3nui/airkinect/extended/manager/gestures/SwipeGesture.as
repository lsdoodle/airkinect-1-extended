/**
 *
 * User: rgerbasi
 * Date: 10/3/11
 * Time: 5:21 PM
 */
package com.as3nui.airkinect.extended.manager.gestures {
	import com.as3nui.airkinect.extended.manager.skeleton.DeltaResult;
	import com.as3nui.airkinect.extended.manager.regions.Region;
	import com.as3nui.airkinect.extended.manager.skeleton.Skeleton;

	import flash.geom.Vector3D;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;

	public class SwipeGesture extends AbstractKinectGesture {
		public static var DISPATCH_DELAY:uint = 1000;
		public static var LAST_DISPATCHED_LOOKUP:Dictionary = new Dictionary();

		public static const DIRECTION_LEFT:String 		= DeltaResult.LEFT;
		public static const DIRECTION_RIGHT:String 		= DeltaResult.RIGHT;
		public static const DIRECTION_DOWN:String		= DeltaResult.DOWN;
		public static const DIRECTION_UP:String 		= DeltaResult.UP;
		public static const DIRECTION_BACK:String 		= DeltaResult.BACK;
		public static const DIRECTION_FORWARD:String 	= DeltaResult.FORWARD;

		public static const AXIS_X:String				= "x";
		public static const AXIS_Y:String				= "y";
		public static const AXIS_Z:String				= "z";

		protected var _elementID:uint;

		protected var _currentSwipeDirection:String;
		protected var _currentDeltaResult:DeltaResult;

		protected var _processSwipeTests:Dictionary;
		protected var _startSwipeTests:Array;
		protected var _gestureStartPosition:Vector3D;

		protected var _historySteps:int = 7;

		public function SwipeGesture(skeleton:Skeleton, elementID:uint, regions:Vector.<Region> = null, useX:Boolean = true, useY:Boolean = true, useZ:Boolean = true) {
			super(skeleton, regions);
			_elementID = elementID;

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

		override public function dispose():void {
			LAST_DISPATCHED_LOOKUP[_skeleton.trackingID] = null;
			delete LAST_DISPATCHED_LOOKUP[_skeleton.trackingID];
			super.dispose();
		}

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


		protected function processGesture(axis:String, threshold:Number):void {
			if (_currentState == GestureState.GESTURE_COMPLETE || _currentState == GestureState.GESTURE_CANCELED) {
				resetGesture();
				return;
			}

			if (threshold <= 0) {
				if (_currentState == GestureState.GESTURE_STARTED && _currentDeltaResult.delta[axis] <= threshold) {
					progressGesture();
				} else if (_currentState == GestureState.GESTURE_STARTED && _currentDeltaResult.delta[axis] > threshold) {
					cancelGesture();
				} else if (_currentState == GestureState.GESTURE_PROGRESS && _currentDeltaResult.delta[axis] > threshold) {
					completeGesture();
				}
			} else {
				if (_currentState == GestureState.GESTURE_STARTED && _currentDeltaResult.delta[axis] >= threshold) {
					progressGesture();
				} else if (_currentState == GestureState.GESTURE_STARTED && _currentDeltaResult.delta[axis] < threshold) {
					cancelGesture();
				} else if (_currentState == GestureState.GESTURE_PROGRESS && _currentDeltaResult.delta[axis] < threshold) {
					completeGesture();
				}
			}
		}

		override public function update():void {
			super.update();

			_currentDeltaResult = _skeleton.calculateDelta(_elementID, _historySteps);
			if (_currentSwipeDirection) {
				if (_processSwipeTests[_currentSwipeDirection]) {
					processGesture(_processSwipeTests[_currentSwipeDirection].axis, _processSwipeTests[_currentSwipeDirection].threshold);
				}
			} else {
				for each(var test:Object in _startSwipeTests) {
					if (testForStartOfGesture(test.axis, test.threshold, test.negativeResult, test.positiveResult)) {
						beginGesture();
						break;
					}
				}
			}
		}

		override protected function beginGesture():void {
			updateElementStartedOutOfRegion(_elementID, _historySteps);
//			trace(_currentSwipeDirection + " : Started");
//			trace("Out of Region :: " + _elementStartedOutOfRegion);
			super.beginGesture();
		}

		override protected function progressGesture():void {
//			trace(_currentSwipeDirection + " : Progress");
			super.progressGesture();
		}

		override protected function cancelGesture():void {
//			trace(_currentSwipeDirection + " : Canceled");
			super.cancelGesture();
		}

		override protected function completeGesture():void {
			if (_elementStartedOutOfRegion) {
//				trace("Gesture complete, but started out of region");
				cancelGesture();
				return;
			}

			if(LAST_DISPATCHED_LOOKUP[_skeleton.trackingID] == null) LAST_DISPATCHED_LOOKUP[_skeleton.trackingID] = 0;
			if(LAST_DISPATCHED_LOOKUP[_skeleton.trackingID]  + DISPATCH_DELAY > getTimer()){
//				trace("Swipe Attempted too soon after last Swipe, canceled, wait " + ((LAST_DISPATCHED_LOOKUP[_skeleton.trackingID]  + DISPATCH_DELAY) - getTimer()) +"ms");
				cancelGesture();
				return;
			}

			LAST_DISPATCHED_LOOKUP[_skeleton.trackingID]  = getTimer();
//			trace("Swipe Complete");
			super.completeGesture();
		}

		override protected function resetGesture():void {
//			trace(_currentSwipeDirection + " : Reset");
			_currentSwipeDirection = null;
			_currentDeltaResult = null;
			_gestureStartPosition = null;
			super.resetGesture();
		}

		public function get currentSwipeAxis():String {
			if(_currentSwipeDirection && _processSwipeTests[_currentSwipeDirection]) return _processSwipeTests[_currentSwipeDirection].axis;
			else return null;
		}

		public function get currentSwipeDirection():String {
			return _currentSwipeDirection;
		}

		public function get currentDeltaResult():DeltaResult {
			return _currentDeltaResult;
		}
	}
}