/**
 *
 * User: Ross
 * Date: 11/19/11
 * Time: 4:49 PM
 */
package com.as3nui.airkinect.extended.ui.components {
	import com.as3nui.airkinect.extended.ui.events.CursorEvent;
	import com.as3nui.airkinect.extended.ui.events.UIEvent;

	import flash.display.DisplayObject;

	public class HotSpot extends BaseUIComponent {
		protected var _icon:DisplayObject;
		protected var _idleIcon:DisplayObject;
		protected var _disabledIcon:DisplayObject;

		public function HotSpot(icon:DisplayObject,disabledIcon:DisplayObject=null){
			super();
			_icon = _idleIcon = icon;
			_disabledIcon = disabledIcon;
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
		}

		protected function onCursorMove(event:CursorEvent):void {
			this.dispatchEvent(new UIEvent(UIEvent.MOVE, event.cursor, event.localX, event.localY, event.stageX, event.stageY));
		}

		protected function onCursorOver(event:CursorEvent):void {
			this.dispatchEvent(new UIEvent(UIEvent.OVER, event.cursor, event.localX, event.localY, event.stageX, event.stageY));
			this.addEventListener(CursorEvent.MOVE, onCursorMove);
		}

		protected function onCursorOut(event:CursorEvent):void {
			this.dispatchEvent(new UIEvent(UIEvent.OUT, event.cursor, event.localX, event.localY, event.stageX, event.stageY));
			this.removeEventListener(CursorEvent.MOVE, onCursorMove);
		}

		override public function set enabled(value:Boolean):void {
			super.enabled = value;
			if(_enabled){
				if(_idleIcon != _icon){
					if(this.contains(_icon)) this.removeChild(_icon);
					_icon = _idleIcon;
					this.addChild(_icon);
				}
			}else if(_disabledIcon){
				if(this.contains(_icon)) this.removeChild(_icon);
				_icon = _disabledIcon;
				this.addChild(_icon);
			}
		}

	}
}