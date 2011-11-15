/**
 *
 * User: rgerbasi
 * Date: 10/3/11
 * Time: 4:33 PM
 */
package com.as3nui.airkinect.extended.manager.regions {
	import flash.geom.Rectangle;

	public class RegionPlanes {
		
		internal var _front:Rectangle;
		internal var _back:Rectangle;
		
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