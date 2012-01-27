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