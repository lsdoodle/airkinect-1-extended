/**
 *
 * User: Ross
 * Date: 11/19/11
 * Time: 4:49 PM
 */
package com.as3nui.airkinect.extended.ui.components {
	import com.as3nui.airkinect.extended.ui.display.BaseSelectionTimer;
	import com.as3nui.airkinect.extended.ui.events.CursorEvent;
	import com.as3nui.airkinect.extended.ui.events.UIEvent;
	import com.as3nui.airkinect.extended.ui.objects.Cursor;

	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.utils.getTimer;

	public class Target extends BaseUIComponent {
		protected var _icon:DisplayObject;

		protected var _globalCursorPosition:Point = new Point();
		protected var _localCursorPosition:Point = new Point();
		protected var _cursor:Cursor;

		protected var _selectionTimer:BaseSelectionTimer;
		protected var _selectionStartTimer:int;
		protected var _selectionDelay:uint;

		
		public function Target(icon:DisplayObject, selectionTimer:BaseSelectionTimer, selectionDelay:uint = 1){
			super();
			_icon = icon;
			_selectionTimer = selectionTimer;
			_selectionDelay = selectionDelay;
		}

		override protected function onAddedToStage():void {
			super.onAddedToStage();
			this.addChild(_icon);
			this.addEventListener(CursorEvent.OVER, onCursorOver);
			this.addEventListener(CursorEvent.OUT, onCursorOut);
		}

		override protected function onRemovedFromStage():void {
			super.onRemovedFromStage();
			if(this.contains(_icon)) this.removeChild(_icon);
			this.removeEventListener(CursorEvent.OVER, onCursorOver);
			this.removeEventListener(CursorEvent.MOVE, onCursorMove);
			this.removeEventListener(CursorEvent.OUT, onCursorOut);
			this.removeEventListener(Event.ENTER_FRAME, onSelectionTimeUpdate);
		}

		protected function onCursorMove(event:CursorEvent):void {
			this.dispatchEvent(new UIEvent(UIEvent.MOVE, event.cursor, event.localX, event.localY, event.stageX, event.stageY));
		}

		protected function onCursorOver(event:CursorEvent):void {
			this.dispatchEvent(new UIEvent(UIEvent.OVER, event.cursor, event.localX, event.localY, event.stageX, event.stageY));
			_cursor = event.cursor;
			_cursor.visible = false;
			this.addEventListener(CursorEvent.MOVE, onCursorMove);
			startSelectionTimer();
		}

		protected function onCursorOut(event:CursorEvent):void {
			this.dispatchEvent(new UIEvent(UIEvent.OUT, event.cursor, event.localX, event.localY, event.stageX, event.stageY));
			_cursor.visible = true;
			_cursor = null;

			this.removeEventListener(CursorEvent.MOVE, onCursorMove);
			if (this.contains(_selectionTimer)) this.removeChild(_selectionTimer);
			this.removeEventListener(Event.ENTER_FRAME, onSelectionTimeUpdate);
		}

		protected function startSelectionTimer():void {
			this.addChild(_selectionTimer);
			_selectionTimer.onProgress(0);
			
			_selectionStartTimer = getTimer();
			this.addEventListener(Event.ENTER_FRAME, onSelectionTimeUpdate);
			onSelectionTimeUpdate(null);
		}

		protected function onSelectionTimeUpdate(event:Event):void {
			_globalCursorPosition.x = _cursor.x * stage.stageWidth;
			_globalCursorPosition.y = _cursor.y * stage.stageHeight;
			_localCursorPosition = this.globalToLocal(_globalCursorPosition);

			_selectionTimer.x = _localCursorPosition.x;
			_selectionTimer.y = _localCursorPosition.y;

			var progress:Number = (getTimer() - _selectionStartTimer) / (_selectionDelay * 1000);
			_selectionTimer.onProgress(progress);
			if (progress >= 1) onSelected();
		}

		protected function onSelected():void {
			if (this.contains(_selectionTimer)) this.removeChild(_selectionTimer);
			this.removeEventListener(Event.ENTER_FRAME, onSelectionTimeUpdate);
			_cursor.visible = true;

			_globalCursorPosition.x = _cursor.x * stage.stageWidth;
			_globalCursorPosition.y = _cursor.y * stage.stageHeight;
			_localCursorPosition = this.globalToLocal(_globalCursorPosition);
			this.dispatchEvent(new UIEvent(UIEvent.SELECTED, _cursor, _localCursorPosition.x, _localCursorPosition.y, _globalCursorPosition.x, _globalCursorPosition.y));
			this.removeEventListener(CursorEvent.MOVE, onCursorMove);
		}

		//----------------------------------
		// Selection Delay
		//----------------------------------
		public function get selectionDelay():uint {
			return _selectionDelay;
		}

		public function set selectionDelay(value:uint):void {
			_selectionDelay = value;
		}
	}
}