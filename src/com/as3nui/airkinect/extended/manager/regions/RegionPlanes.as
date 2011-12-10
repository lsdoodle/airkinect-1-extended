/**
 *
 * User: rgerbasi
 * Date: 10/3/11
 * Time: 4:33 PM
 */
package com.as3nui.airkinect.extended.manager.regions {
	import flash.geom.Rectangle;

	/**
	 * Region planes are used to create front and back rectangles from a Region.
	 * This is useful for drawing a region visually on the stage.
	 */
	public class RegionPlanes {
		
		internal var _front:Rectangle;
		internal var _back:Rectangle;

		/**
		 * Creates new RegionPlanes
		 * @param front			Front Plane
		 * @param back			Black Plane
		 */
		public function RegionPlanes(front:Rectangle, back:Rectangle) {
			_front 		= front;
			_back		= back;
		}

		public function get front():Rectangle {
			return _front;
		}

		public function get back():Rectangle {
			return _back;
		}
	}
}