/**
 *
 * User: rgerbasi
 * Date: 10/1/11
 * Time: 10:43 PM
 */
package com.as3nui.airkinect.extended.manager.skeleton {
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;

	/**
	 * Used is History comparisions of Skeleton classes a Delta Result
	 * contains a collection of data about the difference of an elements position over time.
	 * Can be useful for determining the direction and magnitude over time.
	 */
	public class DeltaResult {
		/**
		 * Static helper for X-Axis
		 */
		public static const X_ORIENTATION:String = "x";
		/**
		 * Static helper for Y-axis
		 */
		public static const Y_ORIENTATION:String = "y";
		/**
		 * Static helper for Z-Axis
		 */
		public static const Z_ORIENTATION:String = "z";

		/**
		 * No Direction
		 */
		public static const NONE:String = "none";
		/**
		 * Helper for Left Direction
		 */
		public static const LEFT:String = "left";
		/**
		 * Helper for Right Direction
		 */
		public static const RIGHT:String = "right";
		/**
		 * Helper for Up Directon
		 */
		public static const UP:String = "up";
		/**
		 * Helper for Down Direction
		 */
		public static const DOWN:String = "down";
		/**
		 * Helper for Back Direction
		 */
		public static const BACK:String = "back";
		/**
		 * Helper for Forward Direction
		 */
		public static const FORWARD:String = "forward";

		/**
		 * ElementID for current Delta Result
		 */
		private var _elementID:uint;
		/**
		 * Depths in history used in calculations
		 */
		private var _depth:uint;
		/**
		 * Delta change in Vector3D form
		 */
		private var _delta:Vector3D;
		/**
		 * Dictionary of all Axis Orientations (Left, Right, Up, Down, Forward, Back)
		 */
		private var _orientation:Dictionary;

		/**
		 * Creates a New DeltaResult for a Element over dpeth in history.
		 * @param elementID		ElementID for Result
		 * @param depth			Depth in history
		 * @param delta			Delta change over the depth in history for this element
		 */
		public function DeltaResult(elementID:uint, depth:uint, delta:Vector3D) {
			_elementID = elementID;
			_depth = depth;
			_delta = delta;

			_orientation = new Dictionary();
			_orientation[X_ORIENTATION] = delta.x == 0 ? NONE : delta.x > 0 ? RIGHT : LEFT;
			_orientation[Y_ORIENTATION] = delta.y == 0 ? NONE : delta.y > 0 ? DOWN : UP;
			_orientation[Z_ORIENTATION] = delta.z == 0 ? NONE : delta.z > 0 ? BACK : FORWARD;
		}

		/**
		 * Getter for Current ElementID used in calulcations
		 */
		public function get elementID():uint {
			return _elementID;
		}

		/**
		 * Depth in history used for this calulcation
		 */
		public function get depth():uint {
			return _depth;
		}

		/**
		 * Delta change
		 */
		public function get delta():Vector3D {
			return _delta;
		}

		/**
		 * Access to a string version of orientation on any axis
		 * @param axis		Axis to check (X_ORIENTATION, Y_ORIENTATION, Z_ORIENTATION)
		 * @return			Direction for this axis (NONE, LEFT, RIGHT, UP, DOWN, FORWARD, BACK)
		 */
		public function getOrientation(axis:String):String {
			return _orientation[axis];
		}
	}
}