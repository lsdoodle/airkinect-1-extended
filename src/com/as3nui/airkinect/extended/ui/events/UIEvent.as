package com.as3nui.airkinect.extended.ui.events {
	import com.as3nui.airkinect.extended.ui.objects.Cursor;

	import flash.events.Event;

	public class UIEvent extends Event {
		public static const OVER:String		= "com.as3nui.airkinect.extended.ui.components.events.OVER"; //
		public static const OUT:String 		= "com.as3nui.airkinect.extended.ui.components.events.OUT"; //
		public static const CAPTURE:String 	= "com.as3nui.airkinect.extended.ui.components.events.CAPTURE"; //
		public static const RELEASE:String 	= "com.as3nui.airkinect.extended.ui.components.events.RELEASE"; //
		public static const SELECTED:String = "com.as3nui.airkinect.extended.ui.components.events.SELECTED"; //
		public static const MOVE:String 	= "com.as3nui.airkinect.extended.ui.components.events.MOVE"; //

		private var _localX:Number = 0;
		private var _localY:Number = 0;
		private var _stageX:Number = 0;
		private var _stageY:Number = 0;
		private var _value:Number = 0;
		private var _delta:Number = 0;
		private var _cursor:Cursor;

		public function UIEvent(type:String, cursor:Cursor, localX:Number, localY:Number, stageX:Number, stageY:Number, value:Number = 0, delta:Number = 0) {
			super(type);

			this._cursor = cursor;
			this._stageX = stageX;
			this._stageY = stageY;

			this._localX = localX;
			this._localY = localY;

			this._value = value;
			this._delta = delta;
		}

		public override function clone():Event {
			return new UIEvent(type, _cursor, _localX, _localY, _stageX, _stageY);
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

		public function get cursor():Cursor {
			return _cursor;
		}

		public function get delta():Number {
			return _delta;
		}

		public function get value():Number {
			return _value;
		}
	}
}