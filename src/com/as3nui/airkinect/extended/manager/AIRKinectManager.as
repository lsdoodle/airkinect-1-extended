/**
 *
 * User: rgerbasi
 * Date: 10/1/11
 * Time: 3:50 PM
 */
package com.as3nui.airkinect.extended.manager {
	import com.as3nui.airkinect.extended.manager.skeleton.Skeleton;
	import com.as3nui.nativeExtensions.kinect.AIRKinect;
	import com.as3nui.nativeExtensions.kinect.data.AIRKinectCameraConstants;
	import com.as3nui.nativeExtensions.kinect.data.SkeletonFrame;
	import com.as3nui.nativeExtensions.kinect.data.SkeletonPosition;
	import com.as3nui.nativeExtensions.kinect.events.CameraFrameEvent;
	import com.as3nui.nativeExtensions.kinect.events.DeviceStatusEvent;
	import com.as3nui.nativeExtensions.kinect.events.SkeletonFrameEvent;

	import flash.display.BitmapData;
	import flash.events.EventDispatcher;
	import flash.geom.PerspectiveProjection;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;

	import org.osflash.signals.Signal;

	public class AIRKinectManager {
		private static var _instance:AIRKinectManager;
		private static const DEFAULT_FLAGS:uint = 11;

		private static function get instance():AIRKinectManager {
			if (_instance) return _instance;
			_instance = new AIRKinectManager();
			return _instance;
		}

		public static function initialize(flags:uint = DEFAULT_FLAGS):Boolean {
			return instance.initialize(flags);
		}

		public static function shutdown():void {
			instance.shutdown();
		}

		public static function get onSkeletonUpdate():Signal {
			return instance.onSkeletonUpdate;
		}

		public static function get onSkeletonAdded():Signal {
			return instance.onSkeletonAdded;
		}

		public static function get onSkeletonRemoved():Signal {
			return instance.onSkeletonRemoved;
		}

		public static function getNextSkeleton():Skeleton {
			return instance.getNextSkeleton();
		}

		public static function get onRGBFrameUpdate():Signal {
			return instance.onRGBFrameUpdate;
		}

		public static function get onDepthFrameUpdate():Signal {
			return instance.onDepthFrameUpdate;
		}

		public static function get onKinectReconnected():Signal {
			return instance.onKinectReconnected;
		}

		public static function get onKinectDisconnected():Signal {
			return instance.onKinectDisconnected;
		}

		public static function setKinectAngle(angle:int):void {
			instance.setKinectAngle(angle);
		}

		public static function getKinectAngle():int {
			return instance.getKinectAngle();
		}

		public static function numSkeletons():uint {
			return instance.numSkeletons();
		}

		public static function matchPerspectiveProjection(perspectiveProjection:PerspectiveProjection):void {
			perspectiveProjection.focalLength = AIRKinectCameraConstants.NUI_CAMERA_DEPTH_NOMINAL_FOCAL_LENGTH_IN_PIXELS * 10;
		}

		public static function addSkeletonDispatcher(dispatcher:EventDispatcher):void {
			instance.addSkeletonDispatcher(dispatcher);
		}

		public static function removeSkeletonDispatcher(dispatcher:EventDispatcher):void {
			instance.removeSkeletonDispatcher(dispatcher);
		}

		//----------------------------------
		// Start Instance
		//----------------------------------
		protected var _skeletonLookup:Dictionary;

		protected var _onSkeletonUpdate:Signal;
		protected var _onSkeletonAdded:Signal;
		protected var _onSkeletonRemoved:Signal;

		protected var _onRGBFrameUpdate:Signal;
		protected var _onDepthFrameUpdate:Signal;
		protected var _onKinectDisconnected:Signal;
		protected var _onKinectReconnected:Signal;

		protected var _currentFlags:uint;
		protected var _isInitialized:Boolean;
		protected var _skeletonDispatchers:Vector.<EventDispatcher>;

		public function AIRKinectManager() {

		}

		public function initialize(flags:uint = DEFAULT_FLAGS):Boolean {
			var success:Boolean = true;

			if (!_isInitialized) {
				_currentFlags = flags;
				success = AIRKinect.initialize(flags);

				_skeletonLookup = new Dictionary();
				_onSkeletonAdded = new Signal(Skeleton);
				_onSkeletonUpdate = new Signal(Skeleton);
				_onSkeletonRemoved = new Signal(Skeleton);
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
		 * Dispose Memory used by Kinect Manager and Kinect Extension
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
			_skeletonLookup = null;

			_currentFlags = 0;
			_isInitialized = false;

			if (_skeletonDispatchers) {
				for each(var eventDispatcher:EventDispatcher in _skeletonDispatchers) {
					eventDispatcher.removeEventListener(SkeletonFrameEvent.UPDATE, onSkeletonFrame);
				}
				_skeletonDispatchers = null;
			}
		}

		protected function cleanupSkeletons():void {
			var skeletonIndex:String;
			var dispatcher:Object;
			for (dispatcher in _skeletonLookup) {
				for (skeletonIndex in _skeletonLookup[dispatcher]) {
					if (_skeletonLookup[dispatcher][skeletonIndex] is Skeleton) {
						(_skeletonLookup[dispatcher][skeletonIndex] as Skeleton).dispose();
					}
				}
			}
		}

		//----------------------------------
		// Skeleton Frame
		//----------------------------------
		protected function onSkeletonFrame(e:SkeletonFrameEvent):void {
			if (!_isInitialized) return;

			var skeletonFrame:SkeletonFrame = e.skeletonFrame;
			var skeletonPosition:SkeletonPosition;
			var skeleton:Skeleton;
			var trackedSkeletonIDs:Vector.<uint> = new Vector.<uint>();

			if (!_skeletonLookup[e.target]) _skeletonLookup[e.target] = new Dictionary();

			if (skeletonFrame.numSkeletons > 0) {
				for (var j:uint = 0; j < skeletonFrame.numSkeletons; j++) {
					skeletonPosition = skeletonFrame.getSkeletonPosition(j);
					trackedSkeletonIDs.push(skeletonPosition.trackingID);

					if (_skeletonLookup[e.target][skeletonPosition.trackingID] == null) {
						skeleton = _skeletonLookup[e.target][skeletonPosition.trackingID] = new Skeleton(skeletonPosition);
						_onSkeletonAdded.dispatch(skeleton);
					} else {
						skeleton = _skeletonLookup[e.target][skeletonPosition.trackingID] as Skeleton;
						skeleton.update(skeletonPosition);
						_onSkeletonUpdate.dispatch(skeleton);
					}
				}
			}

			var skeletonRemoveIndex:String;
			for (skeletonRemoveIndex in _skeletonLookup[e.target]) {
				if (skeletonFrame.numSkeletons == 0 || trackedSkeletonIDs.indexOf(skeletonRemoveIndex) == -1) {
					skeleton = _skeletonLookup[e.target][skeletonRemoveIndex] as Skeleton;
					_skeletonLookup[e.target][skeletonRemoveIndex] = null;
					delete _skeletonLookup[e.target][skeletonRemoveIndex];
					_onSkeletonRemoved.dispatch(skeleton);
					skeleton.dispose();
				}
			}
		}

		public function getNextSkeleton():Skeleton {
			var skeletonIndex:String;
			var dispatcher:Object;
			for (dispatcher in _skeletonLookup) {
				for (skeletonIndex in _skeletonLookup[dispatcher]) {
					if (_skeletonLookup[dispatcher][skeletonIndex] is Skeleton) {
						return _skeletonLookup[dispatcher][skeletonIndex] as Skeleton;
					}
				}
			}
			return null;
		}

		public function numSkeletons():uint {
			var count:uint = 0;
			var skeletonIndex:String;
			var dispatcher:Object;
			for (dispatcher in _skeletonLookup) {
				for (skeletonIndex in _skeletonLookup[dispatcher]) {
					if (_skeletonLookup[dispatcher][skeletonIndex] is Skeleton) {
						count++;
					}
				}
			}
			return count;

		}

		//----------------------------------
		// RGB Frame
		//----------------------------------
		private function onRGBFrame(event:CameraFrameEvent):void {
			_onRGBFrameUpdate.dispatch(event.frame.clone());
			event.frame.dispose();
		}

		//----------------------------------
		// Depth Frame
		//----------------------------------
		private function onDepthFrame(event:CameraFrameEvent):void {
			_onDepthFrameUpdate.dispatch(event.frame.clone(), event.data);
			event.frame.dispose();
		}

		//----------------------------------
		// Kinect Disconnect/Reconnect
		//----------------------------------
		private function onKinectDisconnection(event:DeviceStatusEvent):void {
			trace("Kinect Manager :: Disconnection");
			var skeletonIndex:String;
			var dispatcher:EventDispatcher = event.target as EventDispatcher;
			for (skeletonIndex in _skeletonLookup[dispatcher]) {
				if (_skeletonLookup[dispatcher][skeletonIndex] is Skeleton) {
					_onSkeletonRemoved.dispatch((_skeletonLookup[dispatcher][skeletonIndex] as Skeleton));
					(_skeletonLookup[dispatcher][skeletonIndex] as Skeleton).dispose();
				}
			}
			_onKinectDisconnected.dispatch();

			_skeletonLookup[dispatcher] = new Dictionary();
			cleanupSkeletons();
		}

		private function onKinectReconnection(event:DeviceStatusEvent):void {
			trace("Kinect Manager :: Reconnection");
			_onKinectReconnected.dispatch(AIRKinect.initialize(_currentFlags));
		}

		//----------------------------------
		// Kinect Angle
		//----------------------------------
		public function setKinectAngle(angle:int):void {
			AIRKinect.setKinectAngle(angle);
		}

		public function getKinectAngle():int {
			return AIRKinect.getKinectAngle();
		}

		//----------------------------------
		// Adding other Skeleton Dispatcher (used for XML playback)
		//----------------------------------
		public function addSkeletonDispatcher(dispatcher:EventDispatcher):void {
			if (!_skeletonDispatchers) _skeletonDispatchers = new <EventDispatcher>[];

			dispatcher.addEventListener(SkeletonFrameEvent.UPDATE, onSkeletonFrame);
			_skeletonDispatchers.push(dispatcher)
		}

		public function removeSkeletonDispatcher(dispatcher:EventDispatcher):void {
			dispatcher.removeEventListener(SkeletonFrameEvent.UPDATE, onSkeletonFrame);

			if (_skeletonDispatchers) {
				var index:int = _skeletonDispatchers.indexOf(dispatcher);
				if (index >= 0) _skeletonDispatchers.splice(index, 1);
				var skeletonIndex:String;
				for (skeletonIndex in _skeletonLookup[dispatcher]) {
					if (_skeletonLookup[dispatcher][skeletonIndex] is Skeleton) {
						_onSkeletonRemoved.dispatch((_skeletonLookup[dispatcher][skeletonIndex] as Skeleton));
						(_skeletonLookup[dispatcher][skeletonIndex] as Skeleton).dispose();
					}
				}
			}
		}

		//----------------------------------
		// Kinect Manager Signals
		//----------------------------------

		public function get onSkeletonAdded():Signal {
			return _onSkeletonAdded;
		}

		public function get onSkeletonRemoved():Signal {
			return _onSkeletonRemoved;
		}

		public function get onSkeletonUpdate():Signal {
			return _onSkeletonUpdate;
		}

		public function get onRGBFrameUpdate():Signal {
			return _onRGBFrameUpdate;
		}

		public function get onDepthFrameUpdate():Signal {
			return _onDepthFrameUpdate;
		}

		public function get onKinectDisconnected():Signal {
			return _onKinectDisconnected;
		}

		public function get onKinectReconnected():Signal {
			return _onKinectReconnected;
		}
	}
}