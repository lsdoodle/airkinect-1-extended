/**
 *
 * User: rgerbasi
 * Date: 12/6/11
 * Time: 4:39 PM
 */
package com.as3nui.airkinect.extended.simulator {
	import com.as3nui.nativeExtensions.kinect.data.AIRKinectSkeleton;
	import com.as3nui.nativeExtensions.kinect.data.AIRKinectSkeletonJoint;
	import com.as3nui.nativeExtensions.kinect.data.AIRKinectSkeletonFrame;
	import com.as3nui.nativeExtensions.kinect.events.SkeletonFrameEvent;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.getTimer;

	/**
	 * Skeleton Player is used to play back a XML recording of Skeleton Frame Data
	 * For example to use with a manual event hander use the following. 
	 * <p>
	 * <code>
	 *  	_skeletonPlayer = new SkeletonPlayer();
	 *	 	_skeletonPlayer.addEventListener(SkeletonFrameEvent.UPDATE, onSimulatedSkeletonFrame);
	 * </code>
	 * </p>
	 * 
	 * To use with the AIRKinect Manager use the following
	 * <p>
	 * <code>
	 *  	_skeletonPlayer = new SkeletonPlayer();
	 *	 	AIRKinectManager.addSkeletonDispatcher(_skeletonPlayer);
	 * </code>
	 * </p>
	 */
	public class SkeletonPlayer extends EventDispatcher {
		public static const STOPPED:String = "stopped";
		public static const PAUSED:String = "paused";
		public static const PLAYING:String = "playing";

		/**
		 * Pulse Sprite used to update the player through the XML
		 */
		private var _pulseSprite:Sprite;
		/**
		 * Determines whether playback loops upon completion
		 */
		private var _loop:Boolean;
		/**
		 * Current XML for playback
		 */
		private var _currentXML:XML;
		/**
		 * Current Skeleton Frame
		 */
		private var _currentFrame:int;
		/**
		 * End Frame of current playback
		 */
		private var _endFrame:int;

		/**
		 * Delay between each frame this is calulcated dynamically
		 */
		private var _delay:uint;
		/**
		 * Last Dispatched Event Time
		 */
		private var _lastDispatchedTime:int;
		/**
		 * Determines wether to skip initial delay in Skeleton XML
		 */
		private var _skipInitialDelay:Boolean;
		
		private var _state:String = STOPPED;

		public function SkeletonPlayer() {
			_pulseSprite = new Sprite();
		}

		/**
		 * Plays an XML recording of Skeleton Frames from SkeletonRecorder 
		 * @param xml				XML to play back
		 * @param loop				Whether to look upon playback completion
		 * @param skipInitialDelay	Forces playback to skip the delay between starting recording and the first skeleon frame.
		 */
		public function play(xml:XML, loop:Boolean = false, skipInitialDelay:Boolean = true):void {
			_loop = loop;
			_currentXML = xml;
			_currentFrame = 0;
			_endFrame = _currentXML..SkeletonFrame.length();
			_lastDispatchedTime = getTimer();
			_skipInitialDelay = skipInitialDelay;
			_delay = _skipInitialDelay ? 0 : parseInt(_currentXML..SkeletonFrame[0].@recordedTime) - parseInt(_currentXML.@recordStartTime);
			_pulseSprite.addEventListener(Event.ENTER_FRAME, onUpdate);

			_state = PLAYING;
		}

		/**
		 * Resumes playback
		 */
		public function resume():void {
			if(!paused) return;
			_pulseSprite.addEventListener(Event.ENTER_FRAME, onUpdate);
			_state = PLAYING;
		}

		/**
		 * Pauses the playback of XML
		 */
		public function pause():void {
			if(!playing) return;
			_pulseSprite.removeEventListener(Event.ENTER_FRAME, onUpdate);
			_state = PAUSED;
		}

		/**
		 * Stops the playback and resets the playback
		 */
		public function stop():void {
			_currentFrame = 0;
			_pulseSprite.removeEventListener(Event.ENTER_FRAME, onUpdate);
			_state = STOPPED;

			var skeletonFrame:AIRKinectSkeletonFrame = new AIRKinectSkeletonFrame(new Vector.<AIRKinectSkeleton>());
			this.dispatchEvent(new SkeletonFrameEvent(skeletonFrame));
		}

		/**
		 * Clears out the current playback and empties the XML
		 */
		public function clear():void {
			if(this.playing) stop();
			_currentXML = null;
		}

		/**
		 * Udpate is called from the pul;se Sprite on Enter Frame
		 * @param event
		 */
		private function onUpdate(event:Event):void {
			//No XML? no use being here...
			if (!_currentXML) return;

			//Checks the current time against the last dispatched time and delay to dispatched a frame.
			if (getTimer() > _lastDispatchedTime + _delay) {
				_lastDispatchedTime = getTimer();

				var skeletonPositions:Vector.<AIRKinectSkeleton> = new <AIRKinectSkeleton>[];
				var currentFrame:XML = _currentXML..SkeletonFrame[_currentFrame];
				var joints:Vector.<AIRKinectSkeletonJoint>;
				var jointXML:XML;
				for each(var skeletonPositionXML:XML in currentFrame..SkeletonPosition) {
					joints = new Vector.<AIRKinectSkeletonJoint>(skeletonPositionXML..joint.length());
					for (var jointIndex:uint = 0; jointIndex < joints.length; jointIndex++) {
						jointXML = skeletonPositionXML..joint[jointIndex];
						joints[parseInt(jointXML.@id)] = new AIRKinectSkeletonJoint(parseFloat(jointXML.@x), parseFloat(jointXML.@y), parseFloat(jointXML.@z));
					}

					var skeletonPosition:AIRKinectSkeleton = new AIRKinectSkeleton(
							parseInt(skeletonPositionXML.@frame),
							parseInt(skeletonPositionXML.@timestamp),
							parseInt(skeletonPositionXML.@trackingID),
							parseInt(skeletonPositionXML.@trackingState),
							joints);

					skeletonPositions.push(skeletonPosition);
				}

				var skeletonFrame:AIRKinectSkeletonFrame = new AIRKinectSkeletonFrame(skeletonPositions);
				this.dispatchEvent(new SkeletonFrameEvent(skeletonFrame));

				_currentFrame++;
				if (_currentFrame >= _endFrame) {
					if (_loop) {
						_delay = _skipInitialDelay ? 0 : parseInt(_currentXML..SkeletonFrame[0].@recordedTime) - parseInt(_currentXML.@recordStartTime);
						_currentFrame = 0;
					} else {
						stop();
					}
				}else{
					_delay =  parseInt(_currentXML..SkeletonFrame[_currentFrame].@recordedTime) - parseInt(currentFrame.@recordedTime);
				}
			}
		}

		/**
		 * Returns a true if the player is currently playing
		 */
		public function get playing():Boolean {
			return _state == PLAYING;
		}

		/**
		 * Returns a true if the player is currently paused
		 */
		public function get paused():Boolean {
			return _state == PAUSED;
		}

		/**
		 * Returns a true if the player is stopped
		 */
		public function get stopped():Boolean {
			return _state == STOPPED;
		}
	}
}