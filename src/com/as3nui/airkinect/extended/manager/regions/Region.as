/*
 * Copyright 2012 AS3NUI
 *
 *    Licensed under the Apache License, Version 2.0 (the "License");
 *    you may not use this file except in compliance with the License.
 *    You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *    Unless required by applicable law or agreed to in writing, software
 *    distributed under the License is distributed on an "AS IS" BASIS,
 *    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *    See the License for the specific language governing permissions and
 *    limitations under the License.
 */

package com.as3nui.airkinect.extended.manager.regions {
	import flash.display.DisplayObject;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;

	/**
	 * Region is a 3D Rectangle in space. it contains a Width, Height and Depth.
	 * Added functions allow for checking if a vector 3D is contained inside of a region.
	 * Region can be created like
	 * <p>
	 * <code>
	 *  	var frontTopLeft:Region = new Region(.3, .3, .4, .4, 1, 2, "ftl");
	 * </code>
	 * </p>
	 *
	 *
	 */
	public class Region {
		/**
		 * Internal count of regions used for naming
		 */
		private static var REGION_COUNT:uint = 0;

		/**
		 * Region ID
		 */
		protected var _id:String;
		/**
		 * Optional Data of any type tied to a region
		 */
		protected var _data:*;
		/**
		 * Top position of region
		 */
		protected var _top:Number;
		/*
		Left Position of region
		 */
		protected var _left:Number;
		/**
		 * Bottom Position of region
		 */
		protected var _bottom:Number;
		/**
		 * Right position of Region
		 */
		protected var _right:Number;
		/**
		 * Back position of region
		 */
		protected var _back:Number;
		/**
		 * Front position of Region
		 */
		protected var _front:Number;

		/**
		 * Single Rectangle representations of a Region useful for drawing out in debugging.
		 */
		protected var _kinectRegionPlanes:RegionPlanes;

		/**
		 * Creates a region
		 * Number below are defaults from the kinect though a region can be of any scale.
		 * @param top		Position of the top of the region (0 is top, .5 is middle, 1 is the bottom)
		 * @param left		Position of the left of the region (0 is left, .5 is middle, 1 is right)
		 * @param bottom	Position of the bottom of the region (0 is top, .5 is middle, 1 is the bottom)
		 * @param right		Position of the right of the region (0 is left, .5 is middle, 1 is right)
		 * @param front		Position of the front of the region (0 is front, 2 is middle, 4 is back)
		 * @param back		Position of the back of the region (0 is front, 2 is middle, 4 is back)
		 * @param id		Optional Id for region, if blank id will be region_(count of regions)
		 * @param data		Optional Data to associate to region.
		 */
		public function Region(top:Number, left:Number, bottom:Number, right:Number, front:Number, back:Number, id:String = null, data:* = null) {
			_id = id ? id : "region_" + REGION_COUNT;
			Region.REGION_COUNT++;

			_data = data;
			
			this._top 		= top;
			this._left 		= left;
			this._bottom 	= bottom;
			this._right 	= right;
			this._front 	= front;
			this._back		= back;

			_kinectRegionPlanes = new RegionPlanes(null, null);
		}

		/**
		 * Returns the Width of a Region
		 */
		public function get width():Number {
			return left - right;
		}

		/**
		 * Returns the height of a region
		 */
		public function get height():Number {
			return bottom - top;
		}

		/**
		 * Returns the Depth of a region
		 */
		public function get depth():Number {
			return back - front;
		}

		/**
		 * Test if a Vector3D is contained within a region
		 * @param position		Position to test
		 * @return				Boolean true if position is within region.
		 */
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

		/**
		 * Scales a region to any width, height and depth
		 * @param width		Width to scale to
		 * @param height	Height to scale to
		 * @param depth		Depth to scale to
		 * @return			Region of scaled size
		 */
		public function scale(width:Number, height:Number, depth:Number):Region {
			return new Region(top*height, left*width, bottom*height, right *width,  front* depth,  back*depth);
		}

		/**
		 * Returns region planes for drawing in 2D space of any display object
		 * @param displayObject		Display object to contain Region Planes
		 * @return					Region planes with proper 2d locations inside displayObject
		 */
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

		public function get data():* {
			return _data;
		}

		public function set data(value:*):void {
			_data = value;
		}

		public function get id():String {
			return _id;
		}
	}
}