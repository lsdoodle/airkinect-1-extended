/**
 *
 * User: Ross
 * Date: 11/19/11
 * Time: 7:28 PM
 */
package com.as3nui.airkinect.extended.ui.display {
	import flash.display.Sprite;

	public class BaseSelectionTimer extends Sprite {
		protected var _progress:Number;
		
		public function BaseSelectionTimer() {
			_progress = 0;
		}

		public function onProgress(progress:Number):void {
			_progress = progress;
		}
	}
}