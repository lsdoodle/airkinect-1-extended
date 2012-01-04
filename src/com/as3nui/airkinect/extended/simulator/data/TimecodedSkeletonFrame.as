/**
 *
 * User: Ross
 * Date: 1/4/12
 * Time: 3:20 PM
 */
package com.as3nui.airkinect.extended.simulator.data {
	import com.as3nui.nativeExtensions.kinect.data.AIRKinectSkeletonFrame;

	/**
	 * Timecoded Skeleton Frame is used to associate a Skeleton Frame with the time of a recording.
	 */
	public class TimeCodedSkeletonFrame {
		protected var _time:uint;
		protected var _skeletonFrame:AIRKinectSkeletonFrame;

		public function TimeCodedSkeletonFrame(time:uint, skeletonFrame:AIRKinectSkeletonFrame):void {
			_time = time;
			_skeletonFrame = skeletonFrame;
		}

		public function get time():uint {
			return _time;
		}

		public function get skeletonFrame():AIRKinectSkeletonFrame {
			return _skeletonFrame;
		}
	}
}