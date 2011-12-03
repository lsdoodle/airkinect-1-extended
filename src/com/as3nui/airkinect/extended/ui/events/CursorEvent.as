package com.as3nui.airkinect.extended.ui.events {
	import com.as3nui.airkinect.extended.ui.objects.Cursor;

	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.events.Event;

	public class CursorEvent extends Event {
		public static const OVER:String		= "com.as3nui.airkinect.extended.ui.events.OVER"; //
		public static const OUT:String 		= "com.as3nui.airkinect.extended.ui.events.OUT"; //
		public static const MOVE:String 	= "com.as3nui.airkinect.extended.ui.events.MOVE"; //

		private var _cursor:Cursor;
		private var _localX:Number = 0;
		private var _localY:Number = 0;
		private var _stageX:Number = 0;
		private var _stageY:Number = 0;
		private var _relatedObject:InteractiveObject;


		public function CursorEvent(type:String, cursor:Cursor, relatedObject:InteractiveObject, localX:Number, localY:Number, stageX:Number, stageY:Number) {
			super(type);
			this._cursor = cursor;

			this._relatedObject = relatedObject;

			this._stageX = stageX;
			this._stageY = stageY;

			this._localX = localX;
			this._localY = localY;
		}

		public override function clone():Event {
			return new CursorEvent(type, _cursor, _relatedObject, _localX, _localY, _stageX, _stageY);
		}

		public function get cursor():Cursor {
			return this._cursor;
		}

		public function get localX():Number {
			return _localX;
		}

		public function get localY():Number {
			return _localY;
		}

		public function get stageX():Number {
			return _stageX;
		}

		public function get stageY():Number {
			return _stageY;
		}

		public function get relatedObject():DisplayObject {
			return _relatedObject;
		}
	}
}