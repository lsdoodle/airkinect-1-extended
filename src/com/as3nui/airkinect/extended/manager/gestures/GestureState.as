/**
 *
 * User: rgerbasi
 * Date: 10/3/11
 * Time: 5:53 PM
 */
package com.as3nui.airkinect.extended.manager.gestures {

	/**
	 * Different states a gesture can go through
	 */
	public class GestureState {
		public static const GESTURE_IDLE:String 		= "idle";
		public static const GESTURE_STARTED:String 		= "started";
		public static const GESTURE_PROGRESS:String 	= "progress";
		public static const GESTURE_CANCELED:String		= "canceled";
		public static const GESTURE_COMPLETE:String		= "complete";
	}
}