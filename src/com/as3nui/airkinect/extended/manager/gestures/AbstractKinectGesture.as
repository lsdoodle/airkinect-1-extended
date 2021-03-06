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
	import com.as3nui.airkinect.extended.manager.regions.Region;
	import com.as3nui.airkinect.extended.manager.skeleton.ExtendedSkeleton;
	import com.as3nui.nativeExtensions.kinect.data.AIRKinectSkeletonJoint;

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
		protected var _skeleton:ExtendedSkeleton;

		//Regions the gesture is bound to start inside of
		protected var _regions:Vector.<Region>;

		//Current State of the gesture
		protected var _currentState:String;

		//Boolean telling if the Gesture has started outside of any region in _regions
		protected var _jointStartedOutOfRegion:Boolean;

		//priority used to detemrine which gestures have priority over others.
		protected var _priority:uint;

		/**
		 * Base constructor for all gestures
		 * @param skeleton		Skeleton to track
		 * @param regions		regions to test for containment at start of gesture
		 * @param priority		priority determines if a getsure cancles other gestures. Exmaple. a gesture of priority 2 will occur and cancel any gestures of priority 1.
		 * 						gestures of the same priority will all get dispatched. Default is 0
		 */
		public function AbstractKinectGesture(skeleton:ExtendedSkeleton, regions:Vector.<Region> = null, priority:uint = 0) {
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
		 * Updates local variable _jointStartedOutOfRegion if the current joint is outside of any region specified.
		 * @param jointID		Joint to check
		 * @param steps			Steps in history to check
		 */
		protected function updateJointStartedOutOfRegion(jointID:uint, steps:uint):void {
			_jointStartedOutOfRegion = false;
			var jointPosition:AIRKinectSkeletonJoint;

			jointPosition = _skeleton.getPositionInHistory(jointID, steps);

			for each(var region:Region in _regions) {
				if (!region.contains3D(jointPosition)) {
					_jointStartedOutOfRegion = true;
					return;
				}
			}
		}

		/**
		 * Updates local variable _jointStartedOutOfRegion if any of the joints provided are outside of any region specified.
		 * @param jointIDs
		 * @param steps
		 */
		protected function updateJointsStartedOutOfRegion(jointIDs:Vector.<uint>, steps:uint):void {
			_jointStartedOutOfRegion = false;
			var jointPosition:AIRKinectSkeletonJoint;
			for each(var jointID:uint in jointIDs) {
				jointPosition = _skeleton.getPositionInHistory(jointID, steps);

				for each(var region:Region in _regions) {
					if (!region.contains3D(jointPosition)) {
						_jointStartedOutOfRegion = true;
						return;
					}
				}
			}
		}

		/**
		 * Returns the current skeleon being used for this gesture
		 */
		public function get skeleton():ExtendedSkeleton {
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