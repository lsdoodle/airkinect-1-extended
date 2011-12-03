/**
 *
 * User: Ross
 * Date: 11/19/11
 * Time: 1:04 PM
 */
package com.as3nui.airkinect.extended.ui.objects {
	import com.as3nui.airkinect.extended.ui.components.interfaces.core.IAttractor;
	import com.as3nui.airkinect.extended.ui.components.interfaces.core.ICaptureHost;

	import flash.display.DisplayObject;
	import flash.geom.Point;

	public class Cursor {
		public static const FREE:String = "free";
		public static const CAPTURED:String = "captured";

		protected var _source:String;
		protected var _id:uint;

		protected var _x:Number;
		protected var _y:Number;
		protected var _z:Number;
		protected var _X:Number;
		protected var _Y:Number;
		protected var _Z:Number;

		protected var _xVelocity:Number;
		protected var _yVelocity:Number;

		//reusable point
		protected var _point:Point = new Point();

		protected var _isInteractive:Boolean;
		protected var _icon:DisplayObject;

		protected var _state:String = FREE;
		
		protected var _captureHost:ICaptureHost;
		protected var _attractor:IAttractor;

		protected var _enabled:Boolean;
		protected var _visible:Boolean;

		protected var _easing:Number;

		public function Cursor(source:String, id:uint, icon:DisplayObject, easing:Number = .3) {
			_source = source;
			_id = id;
			_enabled = true;

			_icon = icon;
			_isInteractive = true;
			_x = _y = _z = _X = _Y = _Z = 0;

			_xVelocity = _yVelocity = 0;
			_easing = easing;
		}

		//----------------------------------
		// Capture/Release Function
		//----------------------------------
		public function capture(host:ICaptureHost):void {
			_captureHost = host;
			_state = CAPTURED;
			this._icon.visible = false;
			this.stopAttraction();
		}

		public function release():void {
			_captureHost = null;
			_state = FREE;
			this._icon.visible = true;
		}

		public function startAttraction(attractor:IAttractor):void {
			_attractor = attractor;
		}

		public function stopAttraction():void {
			_attractor = null;
		}

		//----------------------------------
		// Source
		//----------------------------------
		public function get source():String {
			return _source;
		}

		public function set source(value:String):void {
			_source = value;
		}

		//----------------------------------
		// ID
		//----------------------------------
		public function get id():uint {
			return _id;
		}

		public function set id(value:uint):void {
			_id = value;
		}

		//----------------------------------
		// Location Getters/Setters
		//----------------------------------
		public function update(x:Number, y:Number, z:Number):void {
			this.x = x;
			this.y = y;
			this.z = z;
		}

		public function get x():Number {
			return _x;
		}

		public function get y():Number {
			return _y;
		}

		public function get z():Number {
			return _z;
		}

		public function set x(value:Number):void {
			_X = value - _x;
			_x = value;
		}

		public function set y(value:Number):void {
			_Y = value - _y;
			_y = value;
		}

		public function set z(value:Number):void {
			_Z = value - _z;
			_z = value;
		}

		//----------------------------------
		// Acceleration Getters
		//----------------------------------
		public function get X():Number {
			return _X;
		}

		public function get Y():Number {
			return _Y;
		}

		public function get Z():Number {
			return _Z;
		}

		public function toPoint():Point {
			_point.x = _x;
			_point.y = _y;
			return _point;
		}

		//----------------------------------
		// Interactivity
		//----------------------------------
		public function get isInteractive():Boolean {
			return _isInteractive;
		}

		public function set isInteractive(value:Boolean):void {
			_isInteractive = value;
		}

		//----------------------------------
		// Icon
		//----------------------------------
		public function get icon():DisplayObject {
			return _icon;
		}

		public function set icon(value:DisplayObject):void {
			_icon = value;
		}

		public function get state():String {
			return _state;
		}

		public function get xVelocity():Number {
			return _xVelocity;
		}

		public function set xVelocity(value:Number):void {
			_xVelocity = value;
		}

		public function get yVelocity():Number {
			return _yVelocity;
		}

		public function set yVelocity(value:Number):void {
			_yVelocity = value;
		}

		public function get captureHost():ICaptureHost {
			return _captureHost;
		}

		public function get attractor():IAttractor {
			return _attractor;
		}

		public function get enabled():Boolean {
			return _enabled;
		}

		public function set enabled(value:Boolean):void {
			_enabled = value;
			if(_state == FREE && _visible) _icon.visible = _enabled
		}

		public function set visible(value:Boolean):void{
			_visible = value;
			_icon.visible = _visible
		}

		public function get visible():Boolean {
			return _visible;
		}

		public function get easing():Number {
			return _easing;
		}

		public function set easing(value:Number):void {
			_easing = value;
		}
	}
}