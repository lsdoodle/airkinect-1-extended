/**
 *
 * User: rgerbasi
 * Date: 10/3/11
 * Time: 11:03 AM
 */
package com.as3nui.airkinect.manager.regions {
	import flash.display.DisplayObject;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;

	public class Region {

		protected var _top:Number;
		protected var _left:Number;
		protected var _bottom:Number;
		protected var _right:Number;
		protected var _back:Number;
		protected var _front:Number;

		protected var _kinectRegionPlanes:RegionPlanes;

		public function Region(top:Number, left:Number, bottom:Number, right:Number, front:Number, back:Number) {
			this._top 		= top;
			this._left 		= left;
			this._bottom 	= bottom;
			this._right 	= right;
			this._front 	= front;
			this._back		= back;

			_kinectRegionPlanes = new RegionPlanes(null, null);
		}

		public function get width():Number {
			return left - right;
		}
		
		public function get height():Number {
			return bottom - top;
		}

		public function get depth():Number {
			return back - front;
		}

		public function contains3D(position:Vector3D):Boolean {
			if(position.z >= this.front && position.z <= this.back){
				if(position.x >= this.left && position.x <= this.right){
					if(position.y >= this.top && position.y <= this.bottom){
						return true;
					}
				}
			}
			return false;
		}

		public function scale(width:Number, height:Number, depth:Number):Region {
			return new Region(top*height, left*width, bottom*height, right *width,  front* depth,  back*depth);
		}
		
		public function local3DToGlobal(displayObject:DisplayObject):RegionPlanes {
			var point:Vector3D = new Vector3D();

			//Front Face
			point.z = front;
			point.y = top;
			point.x = left;
			var frontTopLeft:Point = displayObject.local3DToGlobal(point);

			point.x = right;
			point.y = bottom;
			var frontBottomRight:Point = displayObject.local3DToGlobal(point);

			//Back Face
			point.z = back;
			point.y = top;
			point.x = left;
			var backTopLeft:Point = displayObject.local3DToGlobal(point);
			
			point.y = bottom;
			point.x = right;
			var backBottomRight:Point = displayObject.local3DToGlobal(point);

			var frontRectangle:Rectangle = new Rectangle(frontTopLeft.x,  frontTopLeft.y,  frontBottomRight.x - frontTopLeft.x,  frontBottomRight.y - frontTopLeft.y);
			var backRectangle:Rectangle = new Rectangle(backTopLeft.x,  backTopLeft.y,  backBottomRight.x - backTopLeft.x,  backBottomRight.y - backTopLeft.y);

			_kinectRegionPlanes._front = frontRectangle;
			_kinectRegionPlanes._back = backRectangle;
			return _kinectRegionPlanes;
		}

		public function get top():Number {
			return _top;
		}

		public function set top(value:Number):void {
			_top = value;
		}

		public function get left():Number {
			return _left;
		}

		public function set left(value:Number):void {
			_left = value;
		}

		public function get bottom():Number {
			return _bottom;
		}

		public function set bottom(value:Number):void {
			_bottom = value;
		}

		public function get right():Number {
			return _right;
		}

		public function set right(value:Number):void {
			_right = value;
		}

		public function get back():Number {
			return _back;
		}

		public function set back(value:Number):void {
			_back = value;
		}

		public function get front():Number {
			return _front;
		}

		public function set front(value:Number):void {
			_front = value;
		}
	}
}