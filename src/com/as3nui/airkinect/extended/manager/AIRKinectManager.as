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

package com.as3nui.airkinect.extended.manager {
	import com.as3nui.airkinect.extended.manager.skeleton.ExtendedSkeleton;
	import com.as3nui.nativeExtensions.kinect.AIRKinect;
	import com.as3nui.nativeExtensions.kinect.settings.AIRKinectCameraConstants;
	import com.as3nui.nativeExtensions.kinect.data.AIRKinectSkeletonFrame;
	import com.as3nui.nativeExtensions.kinect.data.AIRKinectSkeleton;
	import com.as3nui.nativeExtensions.kinect.events.CameraFrameEvent;
	import com.as3nui.nativeExtensions.kinect.events.DeviceStatusEvent;
	import com.as3nui.nativeExtensions.kinect.events.SkeletonFrameEvent;

	import flash.display.BitmapData;
	import flash.events.EventDispatcher;
	import flash.geom.PerspectiveProjection;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;

	import org.osflash.signals.Signal;

	/**
	 * AIRKinectManager is a singleton Class used to manage Skeletons, RGB Frames and Depth Frames.
	 * Manger should be initialized prior to use
	 * <p>
	 * <code>
	 *  	var flags:uint = AIRKinect.NUI_INITIALIZE_FLAG_USES_SKELETON | AIRKinect.NUI_INITIALIZE_FLAG_USES_COLOR
	 *		AIRKinectManager.initialize(flags);
	 * </code>
	 * </p>
	 *
	 * Once Manager is initialized one can attach to any of the avaliable Signals to track events such as
	 * onSkeletonAdded, onSkeletonRemoved, onRGBFrameUpdate, etc
	 */
	public class AIRKinectManager {

		/**
		 * Singleton Reference
		 */
		private static var _instance:AIRKinectManager;

		/**
		 * Default Flags for initialization
		 */
		private static const DEFAULT_FLAGS:uint = 11;

		/**
		 * Creates the Singleton Instance for this class
		 */
		private static function get instance():AIRKinectManager {
			if (_instance) return _instance;
			_instance = new AIRKinectManager();
			return _instance;
		}

		/**
		 * Initializes the Kinect
		 * @param flags		Flags to init the kinect with
		 * @return			Boolean of success
		 * @see				AIRKinectManager.initialize
		 */
		public static function initialize(flags:uint = DEFAULT_FLAGS):Boolean {
			return instance.initialize(flags);
		}

		/**
		 * Shutsdown the Kinect
		 */
		public static function shutdown():void {
			instance.shutdown();
		}

		/**
		 * Getter for SkeletonUpdate signal
		 */
		public static function get onSkeletonUpdate():Signal {
			return instance.onSkeletonUpdate;
		}

		/**
		 * Getter for SkeletonAdded Signal
		 */
		public static function get onSkeletonAdded():Signal {
			return instance.onSkeletonAdded;
		}

		/**
		 * Getter for SkeletonRemoved Signal
		 */
		public static function get onSkeletonRemoved():Signal {
			return instance.onSkeletonRemoved;
		}

		/**
		 * @return		Next Available Skeleton in the collection
		 */
		public static function getNextSkeleton():ExtendedSkeleton {
			return instance.getNextSkeleton();
		}

		/**
		 * Getter for RGBFrameUpdate Signal
		 */
		public static function get onRGBFrameUpdate():Signal {
			return instance.onRGBFrameUpdate;
		}

		/**
		 * Getter for DepthFrameUpdate Signal
		 */
		public static function get onDepthFrameUpdate():Signal {
			return instance.onDepthFrameUpdate;
		}

		/**
		 * Getter for KinectReconnected Signal
		 */
		public static function get onKinectReconnected():Signal {
			return instance.onKinectReconnected;
		}

		/**
		 * Getter for Kinect Disconnected Signal
		 */
		public static function get onKinectDisconnected():Signal {
			return instance.onKinectDisconnected;
		}

		/**
		 * Setter for Kinect Angle
		 * @param angle		Angle in which to set the Kinect
		 */
		public static function setKinectAngle(angle:int):void {
			instance.setKinectAngle(angle);
		}

		/**
		 * Getter for Kinect Angle
		 * @return		Angle that the kinect is at
		 */
		public static function getKinectAngle():int {
			return instance.getKinectAngle();
		}

		/**
		 * Total number of skeletons currently tracked
		 * @return
		 */
		public static function numSkeletons():uint {
			return instance.numSkeletons();
		}

		public static function currentSkeletons():Vector.<ExtendedSkeleton> {
			return instance.currentSkeletons()
		}

		/**
		 * Matches the Focal Length to Depth Camera
		 * @param perspectiveProjection
		 */
		public static function matchPerspectiveProjection(perspectiveProjection:PerspectiveProjection):void {
			perspectiveProjection.focalLength = AIRKinectCameraConstants.NUI_CAMERA_DEPTH_NOMINAL_FOCAL_LENGTH_IN_PIXELS * 10;
		}

		/**
		 * Adds any dispatcher as a Skeleton Dipatcher. This is mainly used for
		 * simulated skeleton data.
		 * @param dispatcher			Dispatcher to be added. should dispatch SkeletonFrameEvent's
		 */
		public static function addSkeletonDispatcher(dispatcher:EventDispatcher):void {
			instance.addSkeletonDispatcher(dispatcher);
		}

		/**
		 * Remove a Skeleton Dispatcher that has been added with addSkeletonDispatcher
		 * @param dispatcher			Dispatcher to remove
		 */
		public static function removeSkeletonDispatcher(dispatcher:EventDispatcher):void {
			instance.removeSkeletonDispatcher(dispatcher);
		}

		//----------------------------------
		// Start Instance
		//----------------------------------

		/**
		 * Nested Dictionaries in the form [dispatcher][skeletonTrackingID]
		 */
		protected var _dispatcherLookup:Dictionary;

		/**
		 * Skeleton Update Signal
		 */
		protected var _onSkeletonUpdate:Signal;
		/**
		 * Skeleton Added Signal
		 */
		protected var _onSkeletonAdded:Signal;
		/**
		 * Skeleton Removed Signal
		 */
		protected var _onSkeletonRemoved:Signal;

		/**
		 * RGBFrame Updated Signal
		 */
		protected var _onRGBFrameUpdate:Signal;
		/**
		 * DepthFrame Updated Signal
		 */
		protected var _onDepthFrameUpdate:Signal;
		/**
		 * Kinect Disconnected Signal
		 */
		protected var _onKinectDisconnected:Signal;
		/**
		 * Kinect Reconnected Signal
		 */
		protected var _onKinectReconnected:Signal;

		/**
		 * Current Flags used to initialize the kinect
		 */
		protected var _currentFlags:uint;

		/**
		 * Boolean exposing whether the Manager has been successfully initialized or not
		 */
		protected var _isInitialized:Boolean;

		/**
		 * Collection of SkeletonDispatchers managed through addSkeletonDispatcher and removeSkeletonDispatcher.
		 * Used for SkeletonFrame Simulations mainly.
		 */
		protected var _skeletonDispatchers:Vector.<EventDispatcher>;

		public function AIRKinectManager() {

		}

		/**
		 * Attempts to initialize the Kinect with the defined flags.
		 * @param flags		Flags to start the Kinect with
		 * @return			Boolean of success for the Kinect starting. Will return false on Error such as
		 *					 missing kinect.
		 */
		public function initialize(flags:uint = DEFAULT_FLAGS):Boolean {
			var success:Boolean = true;

			if (!_isInitialized) {
				_currentFlags = flags;
				success = AIRKinect.initialize(flags);

				_dispatcherLookup = new Dictionary();
				_onSkeletonAdded = new Signal(ExtendedSkeleton);
				_onSkeletonUpdate = new Signal(ExtendedSkeleton);
				_onSkeletonRemoved = new Signal(ExtendedSkeleton);
				_onRGBFrameUpdate = new Signal(BitmapData);
				_onDepthFrameUpdate = new Signal(BitmapData, ByteArray);
				_onKinectDisconnected = new Signal();
				_onKinectReconnected = new Signal(Boolean);
				AIRKinect.addEventListener(SkeletonFrameEvent.UPDATE, onSkeletonFrame);
				AIRKinect.addEventListener(CameraFrameEvent.RGB, onRGBFrame);
				AIRKinect.addEventListener(CameraFrameEvent.DEPTH, onDepthFrame);

				AIRKinect.addEventListener(DeviceStatusEvent.RECONNECTED, onKinectReconnection);
				AIRKinect.addEventListener(DeviceStatusEvent.DISCONNECTED, onKinectDisconnection);
				_isInitialized = true;
			}

			return success;
		}

		/**
		 * Shuts down the Kinect and cleans up Memory used by Kinect Manager and Kinect Extension
		 */
		public function shutdown():void {
			if (_onSkeletonAdded) _onSkeletonAdded.removeAll();
			if (_onSkeletonUpdate) _onSkeletonUpdate.removeAll();
			if (_onSkeletonRemoved) _onSkeletonRemoved.removeAll();
			if (_onRGBFrameUpdate) _onRGBFrameUpdate.removeAll();
			if (_onDepthFrameUpdate) _onDepthFrameUpdate.removeAll();
			if (_onKinectDisconnected) _onKinectDisconnected.removeAll();
			if (_onKinectReconnected) _onKinectReconnected.removeAll();
			cleanupSkeletons();

			AIRKinect.removeEventListener(SkeletonFrameEvent.UPDATE, onSkeletonFrame);
			AIRKinect.removeEventListener(CameraFrameEvent.RGB, onRGBFrame);
			AIRKinect.removeEventListener(CameraFrameEvent.DEPTH, onDepthFrame);
			_dispatcherLookup = null;

			_currentFlags = 0;
			_isInitialized = false;

			if (_skeletonDispatchers) {
				for each(var eventDispatcher:EventDispatcher in _skeletonDispatchers) {
					eventDispatcher.removeEventListener(SkeletonFrameEvent.UPDATE, onSkeletonFrame);
				}
				_skeletonDispatchers = null;
			}

			AIRKinect.shutdown()
		}

		/**
		 * Cleans up Dispatcher and Skeleton Lookup
		 */
		protected function cleanupSkeletons():void {
			var skeletonIndex:String;
			var dispatcher:Object;
			for (dispatcher in _dispatcherLookup) {
				for (skeletonIndex in _dispatcherLookup[dispatcher]) {
					if (_dispatcherLookup[dispatcher][skeletonIndex] is ExtendedSkeleton) {
						(_dispatcherLookup[dispatcher][skeletonIndex] as ExtendedSkeleton).dispose();
					}
				}
			}
		}

		/**
		 * Event Handler for Skeleton Frames. Function is called whenever a new Skeleton Frame
		 * is Dispatched from AIRKinect or any added Skeleton Dispatcher
		 * @param e			SkeletonFrameEvent
		 */
		protected function onSkeletonFrame(e:SkeletonFrameEvent):void {
			if (!_isInitialized) return;

			var skeletonFrame:AIRKinectSkeletonFrame = e.skeletonFrame;
			var skeleton:AIRKinectSkeleton;
			var extendedSkeleton:ExtendedSkeleton;
			var trackedSkeletonIDs:Vector.<uint> = new Vector.<uint>();

			if (!_dispatcherLookup[e.target]) _dispatcherLookup[e.target] = new Dictionary();

			if (skeletonFrame.numSkeletons > 0) {
				for (var j:uint = 0; j < skeletonFrame.numSkeletons; j++) {
					skeleton = skeletonFrame.getSkeleton(j);
					trackedSkeletonIDs.push(skeleton.trackingID);

					if (_dispatcherLookup[e.target][skeleton.trackingID] == null) {
						extendedSkeleton = _dispatcherLookup[e.target][skeleton.trackingID] = new ExtendedSkeleton(skeleton);
						_onSkeletonAdded.dispatch(extendedSkeleton);
					} else {
						extendedSkeleton = _dispatcherLookup[e.target][skeleton.trackingID] as ExtendedSkeleton;
						extendedSkeleton.update(skeleton);
						_onSkeletonUpdate.dispatch(extendedSkeleton);
					}
				}
			}

			var skeletonRemoveIndex:String;
			for (skeletonRemoveIndex in _dispatcherLookup[e.target]) {
				if (skeletonFrame.numSkeletons == 0 || trackedSkeletonIDs.indexOf(skeletonRemoveIndex) == -1) {
					extendedSkeleton = _dispatcherLookup[e.target][skeletonRemoveIndex] as ExtendedSkeleton;
					_dispatcherLookup[e.target][skeletonRemoveIndex] = null;
					delete _dispatcherLookup[e.target][skeletonRemoveIndex];
					_onSkeletonRemoved.dispatch(extendedSkeleton);
					extendedSkeleton.dispose();
				}
			}
		}

		/**
		 * Returns the next available skeleton in the current Dispatcher Lookup.
		 * @return			The next skeleton available from a dispatcher
		 */
		public function getNextSkeleton():ExtendedSkeleton {
			var skeletonIndex:String;
			var dispatcher:Object;
			for (dispatcher in _dispatcherLookup) {
				for (skeletonIndex in _dispatcherLookup[dispatcher]) {
					if (_dispatcherLookup[dispatcher][skeletonIndex] is ExtendedSkeleton) {
						return _dispatcherLookup[dispatcher][skeletonIndex] as ExtendedSkeleton;
					}
				}
			}
			return null;
		}

		/**
		 * Returns the total skeletons in all dispatchers currently avaliable
		 * @return	Total Skeletons in lookups
		 */
		public function numSkeletons():uint {
			var count:uint = 0;
			var skeletonIndex:String;
			var dispatcher:Object;
			for (dispatcher in _dispatcherLookup) {
				for (skeletonIndex in _dispatcherLookup[dispatcher]) {
					if (_dispatcherLookup[dispatcher][skeletonIndex] is ExtendedSkeleton) {
						count++;
					}
				}
			}
			return count;
		}

		public function currentSkeletons():Vector.<ExtendedSkeleton> {
			var skeletons:Vector.<ExtendedSkeleton> = new <ExtendedSkeleton>[];
			var skeletonIndex:String;
			var dispatcher:Object;
			for (dispatcher in _dispatcherLookup) {
				for (skeletonIndex in _dispatcherLookup[dispatcher]) {
					if (_dispatcherLookup[dispatcher][skeletonIndex] is ExtendedSkeleton) {
						skeletons.push(_dispatcherLookup[dispatcher][skeletonIndex] as ExtendedSkeleton)
					}
				}
			}
			return skeletons;
		}

		/**
		 * Event Handler for RGB Frame updates. Dispatches onRGBFrameUpdate Signal
		 * @param event		CameraframeEvent
		 */
		private function onRGBFrame(event:CameraFrameEvent):void {
			_onRGBFrameUpdate.dispatch(event.frame.clone());
			event.frame.dispose();
		}

		/**
		 * Event Handler for Depth Frame updates. Dispatches onDepthFrameUpdate Signal
		 * @param event		CameraframeEvent
		 */
		private function onDepthFrame(event:CameraFrameEvent):void {
			_onDepthFrameUpdate.dispatch(event.frame.clone(), event.data);
			event.frame.dispose();
		}

		/**
		 * Event Handler for Kinect Disconnection. Cleans up all Skeleton Dispatchers
		 * and Dispatches a onKinectDisconnected Signal
		 * @param event		DeviceStatusEvent
		 */
		private function onKinectDisconnection(event:DeviceStatusEvent):void {
			trace("Kinect Manager :: Disconnection");
			if(_isInitialized)
			{
				var skeletonIndex:String;
				var dispatcher:EventDispatcher = event.target as EventDispatcher;
				for (skeletonIndex in _dispatcherLookup[dispatcher]) {
					if (_dispatcherLookup[dispatcher][skeletonIndex] is ExtendedSkeleton) {
						_onSkeletonRemoved.dispatch((_dispatcherLookup[dispatcher][skeletonIndex] as ExtendedSkeleton));
						(_dispatcherLookup[dispatcher][skeletonIndex] as ExtendedSkeleton).dispose();
					}
				}
				_onKinectDisconnected.dispatch();
	
				_dispatcherLookup[dispatcher] = new Dictionary();
				cleanupSkeletons();
			}
		}

		/**
		 * Event Handler for Kinect Reconnection. Attempts to Re-Initalize the Kinect
		 * with the flags it previously used. onKinectReconnected Signal will be dispatched
		 * with a Boolean of the successful initialization.
		 * @param event
		 */
		private function onKinectReconnection(event:DeviceStatusEvent):void {
			trace("Kinect Manager :: Reconnection");
			_onKinectReconnected.dispatch(AIRKinect.initialize(_currentFlags));
		}

		/**
		 * Sets the Kinect Angle.
		 * @see AIRKinect.setKinectAngle
		 * @param angle		Angle to move the Kinect to
		 */
		public function setKinectAngle(angle:int):void {
			AIRKinect.setKinectAngle(angle);
		}

		/**
		 * Returns the current Kinect angle
		 * @see AIRKinect.getKinectAngle
		 * @return		Angle of the Kinect
		 */
		public function getKinectAngle():int {
			return AIRKinect.getKinectAngle();
		}

		/**
		 * Dynamically adds Skeleton Frame Dispatchers. Allows the Manager to respond to any
		 * SkeletonFrameEvent dispatcher.
		 * @param dispatcher		Dispatcher that, should, dispatch a SkeletonFrameEvent
		 */
		public function addSkeletonDispatcher(dispatcher:EventDispatcher):void {
			if (!_skeletonDispatchers) _skeletonDispatchers = new <EventDispatcher>[];

			dispatcher.addEventListener(SkeletonFrameEvent.UPDATE, onSkeletonFrame);
			_skeletonDispatchers.push(dispatcher)
		}

		/**
		 * Removes a Skeleton Dispatcher that was previously added by addSkeletonDispatcher
		 * @param dispatcher		Dispatcher to remove
		 */
		public function removeSkeletonDispatcher(dispatcher:EventDispatcher):void {
			dispatcher.removeEventListener(SkeletonFrameEvent.UPDATE, onSkeletonFrame);

			if (_skeletonDispatchers) {
				var index:int = _skeletonDispatchers.indexOf(dispatcher);
				if (index >= 0) _skeletonDispatchers.splice(index, 1);
				var skeletonIndex:String;
				if(!_dispatcherLookup) return;
				for (skeletonIndex in _dispatcherLookup[dispatcher]) {
					if (_dispatcherLookup[dispatcher][skeletonIndex] is ExtendedSkeleton) {
						_onSkeletonRemoved.dispatch((_dispatcherLookup[dispatcher][skeletonIndex] as ExtendedSkeleton));
						(_dispatcherLookup[dispatcher][skeletonIndex] as ExtendedSkeleton).dispose();
					}
				}
			}
		}

		/**
		 * Signal that is Dispatched when a Skeleton is Added.
		 * Will be dispatched with one parameter of type Skeleton.
		 */
		public function get onSkeletonAdded():Signal {
			return _onSkeletonAdded;
		}

		/**
		 * Signal that is Dispatched when a Skeleton is Removed.
		 * Will be dispatched with one parameter of type Skeleton.
		 */
		public function get onSkeletonRemoved():Signal {
			return _onSkeletonRemoved;
		}

		/**
		 * Signal that is Dispatched when a Skeleton is Updated
		 * Will be dispatched with one parameter of type Skeleton
		 */
		public function get onSkeletonUpdate():Signal {
			return _onSkeletonUpdate;
		}

		/**
		 * Signal that is dispatched when a new RGB Frame is ready.
		 * Will be dispatched with one parametetr of type BitmapData
		 */
		public function get onRGBFrameUpdate():Signal {
			return _onRGBFrameUpdate;
		}

		/**
		 * Signal that is dispatched when a new Depth Frame is ready
		 * Will be dispatched with two parameters of type BitmapData, ByteArray
		 * Bitmap data is current Depth Bitmap Data.
		 * ByteArray is only used in AIRkinectFlags.NUI_INITIALIZE_FLAG_USES_DEPTH mode.
		 * Data is a Byte Array in the format x,y,z where each is a Unsigned Short
		 * the array will contain ((_frame.width * _frame.height) * (2 *3)) bytes. (2 bytes per UShort and 3 USHORTs per pixel.)
		 */
		public function get onDepthFrameUpdate():Signal {
			return _onDepthFrameUpdate;
		}

		/**
		 * Signal that is dispatched when the Kinect is Disconnected.
		 * No Parameters
		 */
		public function get onKinectDisconnected():Signal {
			return _onKinectDisconnected;
		}

		/**
		 * Signal that is dispatched when the Kinect is Reconnected
		 * Will be dispatched with one parameter of type Boolean.
		 * Boolean is a successful initialization of the connect.
		 */
		public function get onKinectReconnected():Signal {
			return _onKinectReconnected;
		}
	}
}