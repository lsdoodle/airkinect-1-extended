/**
 *
 * User: rgerbasi
 * Date: 10/3/11
 * Time: 5:22 PM
 */
package com.as3nui.airkinect.extended.manager.gestures {
	import com.as3nui.airkinect.extended.manager.regions.Region;
	import com.as3nui.airkinect.extended.manager.skeleton.Skeleton;

	import flash.geom.Vector3D;

	import org.osflash.signals.Signal;

	/**
	 * Base class for Gestures to build off of. Provides all signals needed to dispatched
	 * Region support and function structure for creating gestures
	 * Most core gesture functionality is provided here and should be overridden in new gestures
	 */
	public class AbstractKinectGesture implements IKinectGesture {

		//Gesture Signals
		protected var _onGestureBegin:Signal;
		protected var _onGestureProgress:Signal;
		protected var _onGestureComplete:Signal;
		protected var _onGestureCanceled:Signal;
		protected var _onGestureReset:Signal;

		//Skeleton the gesture is attrached to
		protected var _skeleton:Skeleton;

		//Regions the gesture is bound to start inside of
		protected var _regions:Vector.<Region>;

		//Current State of the gesture
		protected var _currentState:String;

		//Boolean telling if the Gesture has started outside of any region in _regions
		protected var _elementStartedOutOfRegion:Boolean;

		//priority used to detemrine which gestures have priority over others.
		protected var _priority:uint;

		/**
		 * Base constructor for all gestures
		 * @param skeleton		Skeleton to track
		 * @param regions		regions to test for containment at start of gesture
		 * @param priority		priority determines if a getsure cancles other gestures. Exmaple. a gesture of priority 2 will occur and cancel any gestures of priority 1.
		 * 						gestures of the same priority will all get dispatched. Default is 0
		 */
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

		/**
		 * Cleans up all signals and resets the state of the gesture
		 */
		virtual public function dispose():void {
			_onGestureBegin.removeAll();
			_onGestureProgress.removeAll();
			_onGestureComplete.removeAll();
			_onGestureCanceled.removeAll();
			_onGestureReset.removeAll();

			_currentState = GestureState.GESTURE_IDLE;
		}

		/**
		 * Updated by the Gesture Manager, should not be called manually
		 */
		virtual public function update():void {
		}

		/**
		 * Called when a gesture begins. Dispatches the onGestureBegin signal
		 */
		protected function beginGesture():void {
			_currentState = GestureState.GESTURE_STARTED;
			_onGestureBegin.dispatch(this);
		}

		/**
		 * Called when the gesture is being processed.
		 * Dispatches the onGestureProgess Signal
		 */
		protected function progressGesture():void {
			_currentState = GestureState.GESTURE_PROGRESS;
			_onGestureProgress.dispatch(this);
		}

		/**
		 * Called when a gesture is Canceled.
		 * Dispatches onGestureCancled Signal
		 */
		protected function cancelGesture():void {
			_currentState = GestureState.GESTURE_CANCELED;
			_onGestureCanceled.dispatch(this);
		}

		/**
		 * Called when a gesture is completed successfully
		 * Dispatches a onGestureComplete Signal
		 */
		protected function completeGesture():void {
			_currentState = GestureState.GESTURE_COMPLETE;
			_onGestureComplete.dispatch(this);
		}

		/**
		 * Called when a gesture is reset to IDLE state.
		 * Dispatches a onGestureReset Signal
		 */
		protected function resetGesture():void {
			_currentState = GestureState.GESTURE_IDLE;
			_onGestureReset.dispatch(this);
		}

		/**
		 * Updates local variable _elementStartedOutOfRegion if the current element is outside of any region specified.
		 * @param elementID		Element to check
		 * @param steps			Steps in history to check
		 */
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

		/**
		 * Updates local variable _elementStartedOutOfRegion if any of the elements provided are outside of any region specified.
		 * @param elements
		 * @param steps
		 */
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

		/**
		 * Returns the current skeleon being used for this gesture
		 */
		public function get skeleton():Skeleton {
			return _skeleton;
		}

		/**
		 * Returns a vector of regions used for start detection on this gesture
		 */
		public function get regions():Vector.<Region> {
			return _regions;
		}

		/**
		 * Returns The Gesture Begin Signal, dispatched when a Gesture Begins
		 */
		public function get onGestureBegin():Signal {
			return _onGestureBegin;
		}

		/**
		 * Returns the Gesture Progress Signal, dispatched as the gesture progresses
		 */
		public function get onGestureProgress():Signal {
			return _onGestureProgress;
		}

		/**
		 * Returns the Gesture Complete Signal. Dispatched upon a successful gesture
		 */
		public function get onGestureComplete():Signal {
			return _onGestureComplete;
		}

		/**
		 * Returns the Gesture Canceled Signal. Dispatched whern a gesture is canceled.
		 */
		public function get onGestureCanceled():Signal {
			return _onGestureCanceled;
		}

		/**
		 * Returns the priority of this gesture
		 */
		public function get priority():uint {
			return _priority;
		}

		/**
		 * Returns the current state of this gesture
		 */
		public function get currentState():String {
			return _currentState;
		}
	}
}