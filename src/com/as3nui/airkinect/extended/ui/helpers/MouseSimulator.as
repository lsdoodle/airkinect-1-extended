/**
 *
 * User: rgerbasi
 * Date: 7/6/11
 * Time: 4:18 PM
 */
package com.as3nui.airkinect.extended.ui.helpers {
	import com.as3nui.airkinect.extended.ui.managers.UIManager;
	import com.as3nui.airkinect.extended.ui.objects.Cursor;

	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.ui.Mouse;

	public class MouseSimulator {
		protected static var _stage:Stage;
		protected static var _source:String = "mouse_adapter";
		protected static var _hasBeenAdded:Boolean;
		protected static var _mouseCursor:Cursor;
		protected static var _enabled:Boolean;

		public static function init(stage:Stage):void {
			_stage = stage;
			_hasBeenAdded = false;
			_mouseCursor = new Cursor("_mouse_", 1, new MouseGraphic());
			enable();
		}

		public static function uninit():void {
			disable();
			_stage = null;
			_mouseCursor = null;
		}

		public static function enable():void {
			if(_enabled) return;

			_enabled = true;
			Mouse.hide();
			_stage.addEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove);
			if(UIManager.isInitialized) addMouseCursor();
		}

		public static function disable():void {
			if(!_enabled) return;
			_enabled = false;

			Mouse.show();
			_stage.removeEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove);
			if(UIManager.isInitialized) removeMouseCursor();
		}

		private static function handleMouseMove(event:MouseEvent):void {
			_mouseCursor.x = event.stageX / _stage.stageWidth;
			_mouseCursor.y = event.stageY / _stage.stageHeight;

			if(UIManager.isInitialized && !_hasBeenAdded) addMouseCursor();
		}

		private static function addMouseCursor():void {
			 UIManager.addCursor(_mouseCursor);
			_hasBeenAdded = true;
		}

		private static function removeMouseCursor():void {
			UIManager.removeCursor(_mouseCursor);
			_hasBeenAdded = false;
		}


		public static function get isInitialized():Boolean {
			return !(_stage == null);
		}

		public static function get enabled():Boolean {
			return _enabled;
		}
	}
}

import flash.display.Sprite;

class MouseGraphic extends Sprite {
	public function MouseGraphic():void {
		draw();
	}

	private function draw():void {
		this.graphics.lineStyle(2,0x000000);
		this.graphics.beginFill(0x00ff00, 1);
		this.graphics.drawCircle(0,0,10);
	}
}