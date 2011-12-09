/**
 *
 * User: Ross
 * Date: 12/8/11
 * Time: 1:10 PM
 */
package com.as3nui.airkinect.extended.simulator.helpers {
	import com.as3nui.airkinect.extended.manager.AIRKinectManager;
	import com.as3nui.airkinect.extended.simulator.SkeletonPlayer;
	import com.as3nui.airkinect.extended.simulator.SkeletonRecorder;
	import com.as3nui.nativeExtensions.kinect.data.SkeletonFrame;
	import com.as3nui.nativeExtensions.kinect.events.SkeletonFrameEvent;

	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.ui.Keyboard;
	import flash.utils.ByteArray;

	import org.osflash.signals.Signal;

	public class SkeletonSimulatorHelper {
		private static var TOTAL_RECORDINGS:uint = 0;

		private static var _skeletonPlayer:SkeletonPlayer;
		private static var _skeletonRecorder:SkeletonRecorder;
		private static var _stage:Stage;

		private static var _enabled:Boolean;

		public static var autoPlayOnLoad:Boolean = true;
		public static var autoPlayOnRecordFinished:Boolean = true;
		public static var saveFileOnRecordFinished:Boolean = true;
		public static var autoLoop:Boolean = false;
		public static var requireShift:Boolean = false;
		public static var loadButton:uint = Keyboard.L;
		public static var playButton:uint = Keyboard.P;
		public static var pauseButton:uint = Keyboard.P;
		public static var stopButton:uint = Keyboard.S;
		public static var recordButton:uint = Keyboard.R;

		private static var _onSkeletonFrame:Signal;
		private static var _onRecordingStopped:Signal;
		private static var _onRecordingSaveSuccess:Signal;
		private static var _onRecordingSaveCancel:Signal;

		private static var _loop:Boolean;
		private static var _currentXML:XML;
		private static var _addedToManager:Boolean;
		private static var _autoAddToManager:Boolean;

		public static function init(stage:Stage, autoAddToManager:Boolean = true):void {
			_stage = stage;
			_skeletonPlayer = new SkeletonPlayer();
			_skeletonRecorder = new SkeletonRecorder();

			_onSkeletonFrame = new Signal(SkeletonFrame);
			_onRecordingStopped = new Signal(XML);
			_onRecordingSaveSuccess = new Signal(XML);
			_onRecordingSaveCancel = new Signal(XML);

			_autoAddToManager = autoAddToManager;
			enable();
		}

		public static function addToManager():void {
			if (_addedToManager) return;
			AIRKinectManager.addSkeletonDispatcher(_skeletonPlayer);
			_addedToManager = true;
		}

		public static function removeFromManager():void {
			AIRKinectManager.removeSkeletonDispatcher(_skeletonPlayer);
			_addedToManager = false;
		}


		public static function uninit():void {
			disable();
			if (_skeletonPlayer && (_skeletonPlayer.playing || _skeletonPlayer.paused)) {
				_skeletonPlayer.stop();
				_skeletonPlayer.clear();
			}

			if (_skeletonRecorder && _skeletonRecorder.recording) {
				_skeletonRecorder.stop();
				_skeletonRecorder.clear();
			}

			if (_onSkeletonFrame) _onSkeletonFrame.removeAll();
			if (_onRecordingStopped) _onRecordingStopped.removeAll();
			if (_onRecordingSaveSuccess) _onRecordingSaveSuccess.removeAll();
			if (_onRecordingSaveCancel) _onRecordingSaveCancel.removeAll();
		}

		public static function enable():void {
			if (_enabled) return;
			if (_autoAddToManager) addToManager();
			_skeletonPlayer.addEventListener(SkeletonFrameEvent.UPDATE, onSimulatedSkeletonFrame);
			_stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			_enabled = true;
		}

		public static function disable():void {
			if (!_enabled) return;
			removeFromManager();
			_skeletonPlayer.removeEventListener(SkeletonFrameEvent.UPDATE, onSimulatedSkeletonFrame);
			_stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			_enabled = false;
		}

		private static function onKeyUp(event:KeyboardEvent):void {
			if (!_enabled) return;
			if (requireShift && !event.shiftKey) return;


			if (event.keyCode == loadButton) {
				_loop = event.ctrlKey || autoLoop;
				load();
			} else if (event.keyCode == playButton || event.keyCode == pauseButton) {
				trace("playing :: " + _skeletonPlayer.playing);
				if (_skeletonPlayer.paused) {
					_skeletonPlayer.resume();
				} else if (!_skeletonPlayer.playing) {
					_loop = event.ctrlKey || autoLoop;
					play();
				} else if (_skeletonPlayer.playing) {
					pause();
				}
			} else if (event.keyCode == stopButton) {
				stop();
			} else if (event.keyCode == recordButton) {
				record();
			}
		}

		//----------------------------------
		// Recording
		//----------------------------------
		public static function record():void {
			if (!_enabled) return;
			if (!_skeletonRecorder || !_skeletonPlayer) return;
			_skeletonRecorder.record();
		}

		private static function onRecordStopped():void {
			_onRecordingStopped.dispatch(_skeletonRecorder.currentRecordingXML);

			if (autoPlayOnRecordFinished) {
				if (_skeletonPlayer.playing) _skeletonPlayer.stop();
				_currentXML = _skeletonRecorder.currentRecordingXML;
				play();
			}

			if (saveFileOnRecordFinished) {
				var ba:ByteArray = new ByteArray();
				ba.writeUTFBytes(_skeletonRecorder.currentRecordingXML);

				var fr:FileReference = new FileReference();
				fr.addEventListener(Event.SELECT, onSaveSuccess);
				fr.addEventListener(Event.CANCEL, onSaveCancel);
				fr.save(ba, "SkeletonRecording_" + TOTAL_RECORDINGS + ".xml");
			}
		}

		private static function onSaveSuccess(event:Event):void {
			TOTAL_RECORDINGS++;
			_onRecordingSaveSuccess.dispatch();
		}


		private static function onSaveCancel(event:Event):void {
			_onRecordingSaveCancel.dispatch();
		}

		//----------------------------------
		// Playback
		//----------------------------------

		public static function load():void {
			if (!_enabled) return;
			var txtFilter:FileFilter = new FileFilter("XML", "*.xml");
			var file:File = new File();
			file.addEventListener(Event.SELECT, onFileSelected);
			file.browseForOpen("Please select a file...", [txtFilter]);
		}

		public static function play():void {
			if (!_enabled) return;
			if (!_currentXML || !_skeletonPlayer) return;
			if (_skeletonPlayer.playing) _skeletonPlayer.stop();
			_skeletonPlayer.play(_currentXML, _loop);
		}

		public static function pause():void {
			if (!_enabled) return;
			if (!_currentXML || !_skeletonPlayer) return;
			if (_skeletonPlayer.playing) _skeletonPlayer.pause();
		}

		public static function stop():void {
			if (!_enabled) return;
			if (_skeletonRecorder && _skeletonRecorder.recording) {
				_skeletonRecorder.stop();
				onRecordStopped();
			} else if (_skeletonPlayer && _currentXML) {
				if (_skeletonPlayer.playing) _skeletonPlayer.stop();
			}
		}

		public static function clear():void {
			if (!_enabled) return;
			if (_skeletonRecorder && _skeletonRecorder.recording) {
				_skeletonRecorder.stop();
				_skeletonRecorder.record();
			}

			if (_skeletonPlayer && _skeletonPlayer.playing) _skeletonPlayer.stop();

			_currentXML = null;
		}

		private static function onFileSelected(event:Event):void {
			var fileStream:FileStream = new FileStream();
			try {
				fileStream.open(event.target as File, FileMode.READ);
				_currentXML = XML(fileStream.readUTFBytes(fileStream.bytesAvailable));
				fileStream.close();
				if (autoPlayOnLoad) play();
			} catch (e:Error) {
				trace("Error loading Config : " + e.message);
			}
		}

		private static function onSimulatedSkeletonFrame(event:SkeletonFrameEvent):void {
			if (_onSkeletonFrame) _onSkeletonFrame.dispatch(event.skeletonFrame);
		}

		public static function get playing():Boolean {
			if (!_skeletonPlayer) return false;
			return _skeletonPlayer.playing
		}

		public static function get paused():Boolean {
			if (!_skeletonPlayer) return false;
			return _skeletonPlayer.paused;
		}

		public static function get stopped():Boolean {
			if (!_skeletonPlayer) return false;
			return _skeletonPlayer.stopped
		}

		public static function get recording():Boolean {
			if (!_skeletonRecorder) return false;
			return _skeletonRecorder.recording
		}

		public static function get onSkeletonFrame():Signal {
			return _onSkeletonFrame;
		}

		public static function get onRecordingStopped():Signal {
			return _onRecordingStopped;
		}

		public static function get onRecordingSaveSuccess():Signal {
			return _onRecordingSaveSuccess;
		}

		public static function get onRecordingSaveCancel():Signal {
			return _onRecordingSaveCancel;
		}
	}
}