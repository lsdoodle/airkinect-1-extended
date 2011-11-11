/**
 *
 * User: rgerbasi
 * Date: 10/3/11
 * Time: 5:22 PM
 */
package com.as3nui.airkinect.manager.gestures {
	import com.as3nui.airkinect.manager.regions.Region;
	import com.as3nui.airkinect.manager.skeleton.Skeleton;

	import flash.geom.Vector3D;

	import org.osflash.signals.Signal;

	public class AbstractKinectGesture implements IKinectGesture {
		protected var _onGestureBegin:Signal;
		protected var _onGestureProgress:Signal;
		protected var _onGestureComplete:Signal;
		protected var _onGestureCanceled:Signal;
		protected var _onGestureReset:Signal;

		protected var _skeleton:Skeleton;
		protected var _regions:Vector.<Region>;

		protected var _currentState:String;

		protected var _elementStartedOutOfRegion:Boolean;

		protected var _priority:uint;

		public function AbstractKinectGesture(skeleton:Skeleton, regions:Vector.<Region> = null, priority:uint = 0) {
			_onGestureBegin = new Signal();
			_onGestureProgress = new Signal();
			_onGestureComplete = new Signal();
			_onGestureCanceled = new Signal();
			_onGestureReset = new Signal();

			_currentState = GestureState.GESTURE_IDLE;

			_skeleton = skeleton;
			_regions = regions;
			_priority = priority;
		}

		virtual public function dispose():void {
			_onGestureBegin.removeAll();
			_onGestureProgress.removeAll();
			_onGestureComplete.removeAll();
			_onGestureCanceled.removeAll();
			_onGestureReset.removeAll();

			_currentState = GestureState.GESTURE_IDLE;
		}

		virtual public function update():void {
		}

		protected function beginGesture():void {
			_currentState = GestureState.GESTURE_STARTED;
			_onGestureBegin.dispatch(this);
		}

		protected function progressGesture():void {
			_currentState = GestureState.GESTURE_PROGRESS;
			_onGestureProgress.dispatch(this);
		}

		protected function cancelGesture():void {
			_currentState = GestureState.GESTURE_CANCELED;
			_onGestureCanceled.dispatch(this);
		}

		protected function completeGesture():void {
			_currentState = GestureState.GESTURE_COMPLETE;
			_onGestureComplete.dispatch(this);
		}

		protected function resetGesture():void {
			_currentState = GestureState.GESTURE_IDLE;
			_onGestureReset.dispatch(this);
		}

		protected function updateElementStartedOutOfRegion(elementID:uint, steps:uint):void {
			_elementStartedOutOfRegion = false;
			var elementPosition:Vector3D;

			elementPosition = _skeleton.getPositionInHistory(elementID, steps);

			for each(var region:Region in _regions) {
				if (!region.contains3D(elementPosition)) {
					_elementStartedOutOfRegion = true;
					return;
				}
			}
		}

		protected function updateElementsStartedOutOfRegion(elements:Vector.<uint>, steps:uint):void {
			_elementStartedOutOfRegion = false;
			var elementPosition:Vector3D;
			for each(var elementID:uint in elements) {
				elementPosition = _skeleton.getPositionInHistory(elementID, steps);

				for each(var region:Region in _regions) {
					if (!region.contains3D(elementPosition)) {
						_elementStartedOutOfRegion = true;
						return;
					}
				}
			}
		}

		public function get skeleton():Skeleton {
			return _skeleton;
		}

		public function get regions():Vector.<Region> {
			return _regions;
		}

		public function get onGestureBegin():Signal {
			return _onGestureBegin;
		}

		public function get onGestureProgress():Signal {
			return _onGestureProgress;
		}

		public function get onGestureComplete():Signal {
			return _onGestureComplete;
		}

		public function get onGestureCanceled():Signal {
			return _onGestureCanceled;
		}

		public function get priority():uint {
			return _priority;
		}

		public function get currentState():String {
			return _currentState;
		}
	}
}