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
		protected var _stage:Stage;
		protected var _source:String = "mouse_adapter";
		protected var _hasBeenAdded:Boolean;
		protected var _mouseCursor:Cursor;
		
		public function MouseSimulator(stage:Stage) {
			_stage = stage;
			_hasBeenAdded = false;

			_mouseCursor = new Cursor("_mouse_", 1, new MouseGraphic());
			_stage.addEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove);

			Mouse.hide();
			if(UIManager.isInitialized) addMouseCursor();
		}

		private function handleMouseMove(event:MouseEvent):void {
			_mouseCursor.x = event.stageX / _stage.stageWidth;
			_mouseCursor.y = event.stageY / _stage.stageHeight;

			if(UIManager.isInitialized && !_hasBeenAdded) addMouseCursor();
		}

		private function addMouseCursor():void {
			 UIManager.addCursor(_mouseCursor);
			_hasBeenAdded = true;
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