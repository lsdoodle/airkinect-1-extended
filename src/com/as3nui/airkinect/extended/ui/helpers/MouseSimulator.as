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

	/**
	 * MouseSimulator Class provides simple access to use the mouse as a Cursor in the UIManager.
	 * To use the this helper simple add the folloowing line to your code
	 * <p>
	 * <code>
	 * 		MouseSimulator.init(stage);
	 * </code>
	 * </p>
	 */
	public class MouseSimulator {
		protected static var _stage:Stage;
		protected static var _source:String = "mouse_adapter";
		protected static var _hasBeenAdded:Boolean;
		protected static var _mouseCursor:Cursor;
		protected static var _enabled:Boolean;

		/**
		 * Initializes the Mouse Simulator by creating a cursor for your mouse and attempting to add it to the UIManager.
		 * If the UIManager is not initialized yet the simulator will continue to attempt registration on MouseMove
		 * @param stage		stage reference
		 */
		public static function init(stage:Stage):void {
			trace("Simulator Initialized");
			_stage = stage;
			_hasBeenAdded = false;
			_mouseCursor = new Cursor("_mouse_", 1, new MouseGraphic());
			enable();
		}

		/**
		 * Removes the mouse cursor from the UIManager and removes the MouseSimulator From memory
		 */
		public static function uninit():void {
			disable();
			removeMouseCursor();
			_mouseCursor = null;
			_stage = null;
		}

		/**
		 * Enables the Mouse Cursor by hiding the actual mouse and adding the cursor to the UIManager
		 */
		public static function enable():void {
			if(_enabled) return;

			_enabled = true;
			Mouse.hide();
			_stage.addEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove);
			if(UIManager.isInitialized) addMouseCursor();
		}

		/**
		 * Disables the Mouse Cursor by unregistering it form the UIManager, turns on the real mouse cursor.
		 */
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
			if(UIManager.isInitialized) {
				_mouseCursor.x = _stage.mouseX / _stage.stageWidth;
				_mouseCursor.y = _stage.mouseY / _stage.stageHeight;
				
				_mouseCursor.icon.x = _stage.mouseX;
				_mouseCursor.icon.y = _stage.mouseY;
				
				UIManager.addCursor(_mouseCursor);
				_hasBeenAdded = true;
			}
		}

		private static function removeMouseCursor():void {
			if(UIManager.isInitialized) UIManager.removeCursor(_mouseCursor);
			_hasBeenAdded = false;
		}

		/**
		 * Returns Initialized status of the MouseSimulator
		 */
		public static function get isInitialized():Boolean {
			return !(_stage == null);
		}

		/**
		 * Returns enabled status of the Mouse Simulator
		 */
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