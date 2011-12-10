/**
 *
 * User: Ross
 * Date: 11/19/11
 * Time: 7:28 PM
 */
package com.as3nui.airkinect.extended.ui.display {
	import flash.display.Sprite;

	/**
	 * Base class for all UI Timer Sprites. All Timers should extend this class
	 * and properly handle onProgress
	 */
	public class BaseTimerSprite extends Sprite {
		protected var _progress:Number;
		
		public function BaseTimerSprite() {
			_progress = 0;
		}

		/**
		 * Function should be overridden by custom Timer Sprite
		 * @param progress		Progress will be a number between 0-1 indecating the progress of the timer.
		 */
		public function onProgress(progress:Number):void {
			_progress = progress;
		}
	}
}