/**
 *
 * User: rgerbasi
 * Date: 10/1/11
 * Time: 10:43 PM
 */
package com.as3nui.airkinect.extended.manager.skeleton {
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;

	public class DeltaResult {
		public static const X_ORIENTATION:String 	= "x";
		public static const Y_ORIENTATION:String 	= "y";
		public static const Z_ORIENTATION:String 	= "z";

		public static const NONE:String 	= "none";
		public static const LEFT:String 	= "left";
		public static const RIGHT:String 	= "right";
		public static const UP:String 		= "up";
		public static const DOWN:String 	= "down";

		public static const BACK:String 	= "back";
		public static const FORWARD:String = "forward";

		
		private var _elementID:uint;
		private var _depth:uint;
		private var _delta:Vector3D;
		private var _orientation:Dictionary;

		public function DeltaResult(elementID:uint,  depth:uint,  delta:Vector3D) {
			_elementID 		= elementID;
			_depth 			= depth;
			_delta 			= delta;

			_orientation = new Dictionary();
			_orientation[X_ORIENTATION] = delta.x == 0 ? NONE : delta.x > 0 ? RIGHT : LEFT;
			_orientation[Y_ORIENTATION] = delta.y == 0 ? NONE : delta.y > 0 ? DOWN : UP;
			_orientation[Z_ORIENTATION] = delta.z == 0 ? NONE : delta.z > 0 ? BACK : FORWARD;
		}

		public function get elementID():uint {
			return _elementID;
		}

		public function get depth():uint {
			return _depth;
		}

		public function get delta():Vector3D {
			return _delta;
		}
		
		public function getOrientation(axis:String):String {
			return _orientation[axis];
		}
	}
}