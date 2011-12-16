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

	/**
	 * Skeleton Simulator Helper is a simple utility class to add Record and Playback of Skeleton Frames to any project with
	 * minimal code.
	 * To use with manual Skeleton Frame management use the following
	 * <p>
	 * <code>
	 *			SkeletonSimulatorHelper.init(stage);
	 *			SkeletonSimulatorHelper.onSkeletonFrame.add(onSimulatedSkeletonFrame);
	 * </code>
	 * </p>
	 *
	 * To use with AIRKinectManager simply cuse
	 * <p>
	 * <code>
	 *			SkeletonSimulatorHelper.init(stage);
	 * </code>
	 * </p>
	 *
	 * Once initialized all functions are accessible through keyboard, R for record, L for Load, P for play/pause, S for Stop.
	 */
	public class SkeletonSimulatorHelper {
		private static var TOTAL_RECORDINGS:uint = 0;

		private static var _skeletonPlayer:SkeletonPlayer;
		private static var _skeletonRecorder:SkeletonRecorder;
		private static var _stage:Stage;

		private static var _enabled:Boolean;

		/**
		 * Determines if Playback should start automatically upon loading XML. If false one must
		 * play the recording after loading it manually
		 */
		public static var autoPlayOnLoad:Boolean = true;

		/**
		 * Determines if playback should automatically start after recording is complete. IF false
		 * one must load the saved XML file and play it back manually
		 */
		public static var autoPlayOnRecordFinished:Boolean = true;

		/**
		 * Determines if file saving dialog should automatically be presented when a recording is complete. If false
		 * one must manage XML data from the onRecordingStopped Signal
		 */
		public static var saveFileOnRecordFinished:Boolean = true;

		/**
		 * Determines is playback should automatically loop
		 */
		public static var autoLoop:Boolean = false;

		/**
		 * Determines if the SHIFT key is required to be held down in addiction to key presses
		 */
		public static var requireShift:Boolean = false;

		/**
		 * Key used to Load XML
		 */
		public static var loadButton:uint = Keyboard.L;
		/**
		 * Key used to Play XML
		 */
		public static var playButton:uint = Keyboard.P;
		/**
		 * Key used to Pause Playback or Recording
		 */
		public static var pauseButton:uint = Keyboard.P;

		/**
		 * Key used to stop playback or recording
		 */
		public static var stopButton:uint = Keyboard.S;

		/**
		 * Key used to start recording
		 */
		public static var recordButton:uint = Keyboard.R;

		//Signals
		private static var _onSkeletonFrame:Signal;
		private static var _onRecordingStopped:Signal;
		private static var _onRecordingSaveSuccess:Signal;
		private static var _onRecordingSaveCancel:Signal;

		private static var _loop:Boolean;
		private static var _currentXML:XML;
		private static var _currentRecordedXML:XML;
		private static var _addedToManager:Boolean;
		private static var _autoAddToManager:Boolean;

		/**
		 * Initializes the Simulation Helper
		 * To use with manual Skeleton Frame management use the following
		 * <p>
		 * <code>
		 *			SkeletonSimulatorHelper.init(stage);
		 *			SkeletonSimulatorHelper.onSkeletonFrame.add(onSimulatedSkeletonFrame);
		 * </code>
		 * </p>
		 *
		 * To use with AIRKinectManager simply cuse
		 * <p>
		 * <code>
		 *			SkeletonSimulatorHelper.init(stage);
		 * </code>
		 * </p>
		 *
		 * @param stage					stage reference for helper to use
		 * @param autoAddToManager		Boolean to automatically add Player to AIRKinect manager. Allowing manager to receive skeleton frames
		 */
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

		/**
		 * Manually adds the skeleton player to the AIRKinectManager
		 */
		public static function addToManager():void {
			if (_addedToManager) return;
			AIRKinectManager.addSkeletonDispatcher(_skeletonPlayer);
			_addedToManager = true;
		}

		/**
		 * Manually removes the skeleton player from the AIRKinectManager
		 */
		public static function removeFromManager():void {
			AIRKinectManager.removeSkeletonDispatcher(_skeletonPlayer);
			_addedToManager = false;
		}

		/**
		 * Un-Initializes the Helper. stopping recorder and player and removing all Signals and Listeners.
		 */
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

			_currentXML = null;
			_currentRecordedXML = null;
		}

		/**
		 * Enables the Simulation helper. This is done automatically in the constructor and only needs to be run manually
		 * if it has been disabled.
		 */
		public static function enable():void {
			if (_enabled) return;
			if (_autoAddToManager) addToManager();
			_skeletonPlayer.addEventListener(SkeletonFrameEvent.UPDATE, onSimulatedSkeletonFrame);
			_stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			_enabled = true;
		}

		/**
		 * Disables the Simulation Helper. IT will not longer responds to key presses, and skeleton updates.
		 */
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

		/**
		 * Starts the recording, this should be done though the Keyboard automatically.
		 */
		public static function record():void {
			if (!_enabled) return;
			if (!_skeletonRecorder || !_skeletonPlayer) return;
			_skeletonRecorder.record();
		}

		/**
		 * On Record stopped. Dispatches  onRecordingStopped with XML as its only parameter.
		 * If autoPlayOnRecordFinished playback is started
		 * If saveFileOnRecordFinished file dialog is shown to save XML
		 */
		private static function onRecordStopped():void {
			_currentRecordedXML = _skeletonRecorder.currentRecordingXML;
			_onRecordingStopped.dispatch(_skeletonRecorder.currentRecordingXML);

			if (saveFileOnRecordFinished) {
				var ba:ByteArray = new ByteArray();
				ba.writeUTFBytes(_skeletonRecorder.currentRecordingXML);

				var fr:FileReference = new FileReference();
				fr.addEventListener(Event.SELECT, onSaveSuccess);
				fr.addEventListener(Event.CANCEL, onSaveCancel);
				fr.save(ba, "SkeletonRecording_" + TOTAL_RECORDINGS + ".xml");
			} else {
				if (autoPlayOnRecordFinished) {
					if (_skeletonPlayer.playing) _skeletonPlayer.stop();
					_currentXML = _currentRecordedXML;
					play();
				}
			}
		}

		private static function onSaveSuccess(event:Event):void {
			TOTAL_RECORDINGS++;
			_onRecordingSaveSuccess.dispatch();

			if (autoPlayOnRecordFinished) {
				if (_skeletonPlayer.playing) _skeletonPlayer.stop();
				_currentXML = _currentRecordedXML;
				play();
			}
		}


		private static function onSaveCancel(event:Event):void {
			_onRecordingSaveCancel.dispatch();
			if (autoPlayOnRecordFinished) {
				if (_skeletonPlayer.playing) _skeletonPlayer.stop();
				_currentXML = _currentRecordedXML;
				play();
			}
		}

		/**
		 * Prompts the user to load an XML file for SkeletonFrame playback
		 */
		public static function load():void {
			if (!_enabled) return;
			var txtFilter:FileFilter = new FileFilter("XML", "*.xml");
			var file:File = new File();
			file.addEventListener(Event.SELECT, onFileSelected);
			file.browseForOpen("Please select a file...", [txtFilter]);
		}

		/**
		 * Starts playback of the current XML in memory
		 */
		public static function play():void {
			if (!_enabled) return;
			if (!_currentXML || !_skeletonPlayer) return;
			if (_skeletonPlayer.playing) _skeletonPlayer.stop();
			_skeletonPlayer.play(_currentXML, _loop);
		}

		/**
		 * If currently playing,playback is paused.
		 * If currently recording, recording is paused
		 */
		public static function pause():void {
			if (!_enabled) return;
			if (!_currentXML || !_skeletonPlayer) return;
			if (_skeletonPlayer.playing) _skeletonPlayer.pause();
		}

		/**
		 * If currently playing, playback is stopped.
		 * If currently Recording, recording is stopped
		 */
		public static function stop():void {
			if (!_enabled) return;
			if (_skeletonRecorder && _skeletonRecorder.recording) {
				_skeletonRecorder.stop();
				onRecordStopped();
			} else if (_skeletonPlayer && _currentXML) {
				if (_skeletonPlayer.playing) _skeletonPlayer.stop();
			}
		}

		/**
		 * Stops playback and Recording and clears out all XML from memory.
		 */
		public static function clear():void {
			if (!_enabled) return;
			if (_skeletonRecorder && _skeletonRecorder.recording) {
				_skeletonRecorder.stop();
				_skeletonRecorder.record();
			}

			if (_skeletonPlayer && _skeletonPlayer.playing) _skeletonPlayer.stop();

			_currentXML = null;
			_currentRecordedXML = null;
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

		/**
		 * Boolean true is player is current Playing
		 */
		public static function get playing():Boolean {
			if (!_skeletonPlayer) return false;
			return _skeletonPlayer.playing
		}

		/**
		 * Boolean true if player is currently paused
		 */
		public static function get paused():Boolean {
			if (!_skeletonPlayer) return false;
			return _skeletonPlayer.paused;
		}

		/**
		 * Boolean true if player is currently stopped
		 */
		public static function get stopped():Boolean {
			if (!_skeletonPlayer) return false;
			return _skeletonPlayer.stopped
		}

		/**
		 * Boolean true if currently recording
		 */
		public static function get recording():Boolean {
			if (!_skeletonRecorder) return false;
			return _skeletonRecorder.recording
		}

		/**
		 * Signal will be dispatched whenever a skeleton from is played back from XML
		 */
		public static function get onSkeletonFrame():Signal {
			return _onSkeletonFrame;
		}

		/**
		 * Signal is dispatched when recording stops
		 */
		public static function get onRecordingStopped():Signal {
			return _onRecordingStopped;
		}

		/**
		 * Signal is Dispatched when Recording Save is successful
		 */
		public static function get onRecordingSaveSuccess():Signal {
			return _onRecordingSaveSuccess;
		}

		/**
		 * Signal is Dispatched when Recording Save is canceled.
		 */
		public static function get onRecordingSaveCancel():Signal {
			return _onRecordingSaveCancel;
		}
	}
}