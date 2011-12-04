/**
 *
 * User: Ross
 * Date: 11/26/11
 * Time: 2:22 PM
 */
package com.as3nui.airkinect.extended.ui.components {
	import com.as3nui.airkinect.extended.ui.components.interfaces.ISlideHandle;
	import com.as3nui.airkinect.extended.ui.events.CursorEvent;
	import com.as3nui.airkinect.extended.ui.events.UIEvent;

	import flash.display.DisplayObject;

	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.geom.Point;

	public class SlideHandle extends Handle implements ISlideHandle {
		public static const UP:String = "up";
		public static const DOWN:String = "down";
		public static const LEFT:String = "left";
		public static const RIGHT:String = "right";

		protected var _track:DisplayObject;
		protected var _orientation:String;

		protected var _slideStartPosition:Point;
		protected var _currentCursorPosition:Point = new Point();

		protected var _trackEndPadding:int = 5;

		protected var _trackCaptureArea:Shape;
		protected var _trackCapturePadding:Number = .25;


		public function SlideHandle(icon:DisplayObject, track:DisplayObject, selectedIcon:DisplayObject = null, disabledIcon:DisplayObject = null, orientation:String = LEFT, capturePadding:Number = .45, minPull:Number = .1, maxPull:Number = 1) {
			super(icon, selectedIcon, disabledIcon, capturePadding, minPull, maxPull);
			_track = track;
			_orientation = orientation;

			_trackCaptureArea = new Shape();
		}

		override protected function onAddedToStage():void {
			super.onAddedToStage();
			createTrackCaptureArea();
		}

		override protected function onRemovedFromStage():void {
			super.onRemovedFromStage();
			_trackCaptureArea.graphics.clear();
		}

		override public function showCaptureArea():void {
			super.showCaptureArea();
			createTrackCaptureArea();
		}
		
		override public function hideCaptureArea():void {
			super.hideCaptureArea();
			createTrackCaptureArea()
		}

		private function createTrackCaptureArea():void {
			_trackCaptureArea.graphics.clear();
			_trackCaptureArea.graphics.beginFill(0xff0000, _showCaptureArea ? .5 : 0);

			var widthPadding:Number = (_trackCapturePadding * _track.width);
			var width:uint = _track.width + widthPadding;

			var heightPadding:Number = (_trackCapturePadding * _track.height);
			var height:uint = _track.height + heightPadding;

			switch (_orientation) {
				case RIGHT:
					_trackCaptureArea.graphics.drawRect(0, -heightPadding / 2, width, height);
					break;
				case LEFT:
					_trackCaptureArea.graphics.drawRect(_icon.width, -heightPadding / 2, -width, height);
					break;
				case UP:
					_trackCaptureArea.graphics.drawRect(-widthPadding / 2, _icon.height, width, -height);
					break;
				case DOWN:
					_trackCaptureArea.graphics.drawRect(-widthPadding / 2, 0, width, height);
					break;
			}
		}

		override protected function onHandleCapture():void {
			super.onHandleCapture();
			this.addEventListener(CursorEvent.MOVE, onCursorMove);
			showTrack();
		}

		override protected function onHandleRelease():void {
			var globalPosition:Point = this.localToGlobal(_centerPoint);
			this.dispatchEvent(new UIEvent(UIEvent.MOVE, _cursor, 0,0, globalPosition.x,  globalPosition.y,0));

			super.onHandleRelease();
			releaseIcon();
			hideTrack();
		}

		private function releaseIcon():void {
			_icon.x = 0;
			_icon.y = 0;
		}

		protected function onCursorMove(event:CursorEvent):void {
			if(!_cursor) return;

			if (!_slideStartPosition) _slideStartPosition = new Point(event.localX, event.localY);
			_currentCursorPosition.x = event.localX;
			_currentCursorPosition.y = event.localY;
			var progress:Number = 0;
			var trackEnd:Number;

			if (_orientation == RIGHT) {
				_icon.x = _currentCursorPosition.x - _slideStartPosition.x;
				if (_icon.x < 0) _icon.x = 0;
				trackEnd = _track.width - _icon.width - _trackEndPadding;
				progress = Math.abs(_icon.x / trackEnd);
				if (_icon.x >= trackEnd) onSelected()
			} else if (_orientation == LEFT) {
				_icon.x = _currentCursorPosition.x - _slideStartPosition.x;
				if (_icon.x > 0) _icon.x = 0;
				trackEnd = -_track.width + _track.x + _trackEndPadding;
				progress = Math.abs(_icon.x / trackEnd);
				if (_icon.x <= trackEnd) onSelected()
			} else if (_orientation == UP) {
				_icon.y = _currentCursorPosition.y - _slideStartPosition.y;
				if (_icon.y > 0) _icon.y = 0;

				trackEnd = -_track.height + _track.y + _trackEndPadding;
				progress = Math.abs(_icon.y / trackEnd);
				if (_icon.y <= trackEnd) onSelected()
			} else if (_orientation == DOWN) {
				_icon.y = _currentCursorPosition.y - _slideStartPosition.y;
				if (_icon.y < 0) _icon.y = 0;
				trackEnd = _track.height - _icon.height - _trackEndPadding;
				progress = Math.abs(_icon.y / trackEnd);
				if (_icon.y >= trackEnd) onSelected()
			}

			if(!_cursor) return;
			this.dispatchEvent(new UIEvent(UIEvent.MOVE, event.cursor, event.localX, event.localY, event.stageX, event.stageY, progress));
		}

		protected function onSelected():void {
			release(_cursor);
			var globalPosition:Point = this.localToGlobal(_currentCursorPosition);
			this.dispatchEvent(new UIEvent(UIEvent.SELECTED, _cursor, _currentCursorPosition.x, _currentCursorPosition.y, globalPosition.x, globalPosition.y));
		}

		protected function showTrack():void {
			this.addChildAt(_track, 0);
			if(_orientation == LEFT) _track.x = _icon.width;
			if(_orientation == UP) _track.y = _icon.height;


			this.addChildAt(_trackCaptureArea, 0);
			_track.visible = true;
			onTrackShown();
		}

		protected function onTrackShown():void {

		}

		protected function hideTrack():void {
			if (this.contains(_trackCaptureArea)) this.removeChild(_trackCaptureArea);
			if (this.contains(_track)) this.removeChild(_track);
			_track.visible = false;
			onTrackHidden();
		}

		protected function onTrackHidden():void {

		}

		public function get orientation():String {
			return _orientation;
		}
	}
}

