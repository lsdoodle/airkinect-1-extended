/**
 *
 * User: rgerbasi
 * Date: 10/3/11
 * Time: 5:21 PM
 */
package com.as3nui.airkinect.extended.manager.gestures {
	import com.as3nui.airkinect.extended.manager.regions.Region;
	import com.as3nui.airkinect.extended.manager.skeleton.DeltaResult;
	import com.as3nui.airkinect.extended.manager.skeleton.Skeleton;

	import flash.geom.Vector3D;

	import flash.utils.Dictionary;
	import flash.utils.getTimer;

	public class ScaleGesture extends AbstractKinectGesture {
		public static const SCALE_OUT:String	= "out";
		public static const SCALE_IN:String		= "in";

		public static var DISPATCH_DELAY:uint = 1000;
		public static var LAST_DISPATCHED_LOOKUP:Dictionary = new Dictionary();


		protected var _currentScaleType:String;
		protected var _leftElementID:uint;
		protected var _rightElementID:uint;

		protected var _historySteps:int = 7;
		protected var _elements:Vector.<uint>;

		//Result from the time the gesture began
		private var _startLeftDeltaResult:DeltaResult;
		private var _startRightDeltaResult:DeltaResult;
		private var _startDistance:Vector3D;

		//Current Results from the Gesture
		private var _currentLeftDeltaResult:DeltaResult;
		private var _currentRightDeltaResult:DeltaResult;
		private var _currentDistance:Vector3D;

		public function ScaleGesture(skeleton:Skeleton, leftElementID:uint,  rightElementID:uint,  regions:Vector.<Region> = null) {
			super(skeleton, regions);
			_leftElementID = leftElementID;
			_rightElementID = rightElementID;
			_elements = new <uint>[_leftElementID, _rightElementID];
		}

		override public function dispose():void {
			LAST_DISPATCHED_LOOKUP[_skeleton.trackingID] = null;
			delete LAST_DISPATCHED_LOOKUP[_skeleton.trackingID];
			super.dispose();
		}
		
		override public function update():void {
			super.update();
			if (_currentState == GestureState.GESTURE_COMPLETE || _currentState == GestureState.GESTURE_CANCELED) {
				resetGesture();
				return;
			}

			_currentLeftDeltaResult = _skeleton.calculateDelta(_leftElementID, _historySteps);
			_currentRightDeltaResult= _skeleton.calculateDelta(_rightElementID, _historySteps);
			_currentDistance = _currentRightDeltaResult.delta.subtract(_currentLeftDeltaResult.delta);

			if(_currentState == GestureState.GESTURE_IDLE) {
				if(_currentLeftDeltaResult.delta.x <= -.15 && _currentRightDeltaResult.delta.x >= .15) {
					_currentScaleType = SCALE_OUT;
					beginGesture();
				}else if(_currentLeftDeltaResult.delta.x >= .15 && _currentRightDeltaResult.delta.x <= -.15) {
					_currentScaleType = SCALE_IN;
					beginGesture();
				}
			} else if(_currentScaleType && _currentState == GestureState.GESTURE_STARTED || _currentState == GestureState.GESTURE_PROGRESS){
				if(_currentScaleType == SCALE_OUT && (_currentLeftDeltaResult.delta.x <= -.1 && _currentRightDeltaResult.delta.x >= .1)) {
					progressGesture();
				}else if(_currentScaleType == SCALE_IN && (_currentLeftDeltaResult.delta.x >= .1 && _currentRightDeltaResult.delta.x <= -.1)) {
					progressGesture();
				}else{
					completeGesture();
				}
			}
		}

		override protected function beginGesture():void {
			updateElementsStartedOutOfRegion(_elements, _historySteps);

			_startLeftDeltaResult = _currentLeftDeltaResult;
			_startRightDeltaResult = _currentRightDeltaResult;
			_startDistance = _currentDistance;
//			trace("Started");
			//trace("Out of Region :: " + _elementStartedOutOfRegion);
			super.beginGesture();
		}

		override protected function progressGesture():void {
//			trace("Progress");
			super.progressGesture();
		}

		override protected function cancelGesture():void {
//			trace("Canceled");
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
//				trace("Swipe Attempted too soon after last Scale, canceled, wait " + ((LAST_DISPATCHED_LOOKUP[_skeleton.trackingID]  + DISPATCH_DELAY) - getTimer()) +"ms");
				cancelGesture();
				return;
			}

			LAST_DISPATCHED_LOOKUP[_skeleton.trackingID]  = getTimer();
			super.completeGesture();
		}

		override protected function resetGesture():void {
//			trace("Reset");
			super.resetGesture();
		}

		public function get currentScaleType():String {
			return _currentScaleType;
		}

		public function get startLeftDeltaResult():DeltaResult {
			return _startLeftDeltaResult;
		}

		public function get startRightDeltaResult():DeltaResult {
			return _startRightDeltaResult;
		}

		public function get currentLeftDeltaResult():DeltaResult {
			return _currentLeftDeltaResult;
		}

		public function get currentRightDeltaResult():DeltaResult {
			return _currentRightDeltaResult;
		}
	}
}