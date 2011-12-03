/**
 *
 * User: Ross
 * Date: 11/19/11
 * Time: 4:49 PM
 */
package com.as3nui.airkinect.extended.ui.components {
	import com.as3nui.airkinect.extended.ui.components.interfaces.IHandle;
	import com.as3nui.airkinect.extended.ui.components.interfaces.core.ICaptureHost;
	import com.as3nui.airkinect.extended.ui.events.CursorEvent;
	import com.as3nui.airkinect.extended.ui.events.UIEvent;
	import com.as3nui.airkinect.extended.ui.objects.Cursor;

	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.geom.Point;

	public class Handle extends BaseUIComponent implements IHandle {

		//Selection Timer Info
		protected var _idleIcon:DisplayObject;
		protected var _icon:DisplayObject;
		protected var _centerPoint:Point = new Point();
		protected var _cursor:Cursor;
		
		protected var _selectedIcon:DisplayObject;

		protected var _maxPull:Number;
		protected var _minPull:Number;

		protected var _capturePadding:Number = .45;
		protected var _captureArea:Shape;
		protected var _showCaptureArea:Boolean;


		protected var _globalCursorPosition:Point = new Point();
		protected var _localCursorPosition:Point = new Point();
		
		public function Handle(icon:DisplayObject, selectedIcon:DisplayObject = null, minPull:Number = .1, maxPull:Number = 1){
			_idleIcon = _icon = icon;
			_selectedIcon = selectedIcon;
			super();

			_captureArea = new Shape();
			_minPull = minPull;
			_maxPull = maxPull;
		}

		override protected function onAddedToStage():void {
			super.onAddedToStage();
			this.addChild(_captureArea);
			this.addChild(_icon);
			this.addEventListener(CursorEvent.OVER, onCursorOver);
			this.addEventListener(CursorEvent.OUT, onCursorOut);
			
			createCaptureArea();
		}

		override protected function onRemovedFromStage():void {
			super.onRemovedFromStage();
			_cursor = null;
			if(this.contains(_captureArea)) this.removeChild(_captureArea);
			if(this.contains(_icon)) this.removeChild(_icon);
			this.removeEventListener(CursorEvent.OVER, onCursorOver);
			this.removeEventListener(CursorEvent.OUT, onCursorOut);

			_captureArea.graphics.clear();
		}

		protected function createCaptureArea():void {
			_captureArea.graphics.clear();
			_captureArea.graphics.beginFill(0xff0000, _showCaptureArea ? .5 : 0);
			
			var width:uint = this.width + (_capturePadding * this.width);
			var height:uint = this.height + (_capturePadding * this.height);
			_captureArea.graphics.drawRect(-(_capturePadding * this.width)/2, -(_capturePadding * this.height)/2, width, height);
		}

		public function showCaptureArea():void {
			_showCaptureArea = true;
			createCaptureArea();
		}

		public function hideCaptureArea():void {
			_showCaptureArea = false;
			createCaptureArea();
		}

		protected function onCursorOver(event:CursorEvent):void {
			this.dispatchEvent(new UIEvent(UIEvent.OVER, event.cursor, event.localX, event.localY, event.stageX, event.stageY));
		}

		protected function onCursorOut(event:CursorEvent):void {
			this.dispatchEvent(new UIEvent(UIEvent.OUT, event.cursor, event.localX, event.localY, event.stageX, event.stageY));
			_cursor = null;
		}

		public function capture(cursor:Cursor):void {
			var globalPosition:Point = this.localToGlobal(_centerPoint);
			this.dispatchEvent(new UIEvent(UIEvent.CAPTURE, cursor, 0, 0, globalPosition.x, globalPosition.y));
			cursor.capture(this);
			_cursor = cursor;

			onIconCapture();
			onHandleCapture();
		}

		public function release(cursor:Cursor):void {
			var globalPosition:Point = this.localToGlobal(_centerPoint);
			this.dispatchEvent(new UIEvent(UIEvent.RELEASE, cursor, 0,0, globalPosition.x,  globalPosition.y));
			_cursor.release();
			_cursor = null;
			onIconRelease();
			onHandleRelease();
		}

		protected function onIconCapture():void {
			if(_selectedIcon){
				_selectedIcon.x = _icon.x;
				_selectedIcon.y = _icon.y;
				this.removeChild(_icon);
				_icon = _selectedIcon;
				this.addChild(_icon);
			}else if (_icon is MovieClip){
				if((_icon as MovieClip).currentLabels.indexOf("_capture") != -1) (_icon as MovieClip).gotoAndStop("_capture");
			}
		}

		protected function onIconRelease():void {
			if(_selectedIcon){
				_idleIcon.x = _icon.x;
				_idleIcon.y = _icon.y;
				this.removeChild(_icon);
				_icon = _idleIcon;
				this.addChild(_icon);
			}else if (_icon is MovieClip){
				if((_icon as MovieClip).currentLabels.indexOf("_idle") != -1) (_icon as MovieClip).gotoAndStop("_idle");
			}
		}

		protected function onHandleCapture():void {

		}

		protected function onHandleRelease():void {

		}

		//----------------------------------
		// IAttractor
		//----------------------------------
		public function get captureHost():ICaptureHost {
			return this;
		}

		public function get globalCenter():Point {
			return this.localToGlobal(centerPoint);
		}

		public function get centerPoint():Point {
			_centerPoint.x = _icon.width/2;
			_centerPoint.y = _icon.height/2;
			return _centerPoint;
		}

		public function get captureWidth():Number {
			return _captureArea.width;
		}

		public function get captureHeight():Number {
			return  _captureArea.height;
		}
		
		public function get minPull():Number {
			return _minPull;
		}

		public function get maxPull():Number {
			return _maxPull;
		}

		public function set maxPull(value:Number):void {
			_maxPull = value;
		}

		public function set minPull(value:Number):void {
			_minPull = value;
		}

		//----------------------------------
		// ICaptureHost
		//----------------------------------
		public function get hasCursor():Boolean {
			return _cursor != null;
		}

	}
}