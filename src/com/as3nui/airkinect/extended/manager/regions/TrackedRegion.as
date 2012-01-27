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
	import com.as3nui.airkinect.extended.manager.skeleton.ExtendedSkeleton;
	import com.as3nui.nativeExtensions.kinect.data.AIRKinectSkeletonJoint;

	/**
	 * Tracked Region is used to attach a region relative to any joint on a skeleton
	 * Positions are then defined relative to the joints positions.
	 * For example a top of -1 and bottom of 1 attached to any joint would always contain the full
	 * height of the Kinect. a top of -.5 would always be half the height upwards from the current joint, and so on.
	 */
	public class TrackedRegion extends Region {
		private var _skeleton:ExtendedSkeleton;
		private var __jointID:uint;

		private var _joint:AIRKinectSkeletonJoint;

		/**
		 * Creates a New Tracked region
		 * @param skeleton		Skeleton to attach region to
		 * @param jointID		Joint to track
		 * @param top			Top position relative to Joint position
		 * @param left			Left position relative to Joint position
		 * @param bottom		Bottom position relative to Joint position
		 * @param right			Right position relative to Joint position
		 * @param front			Front position relative to Joint position
		 * @param back			Back position relative to Joint position
		 */
		public function TrackedRegion(skeleton:ExtendedSkeleton, jointID:uint, top:Number, left:Number, bottom:Number, right:Number, front:Number, back:Number):void {
			super(top, left, bottom, right, front, back);
			_skeleton = skeleton;
			__jointID = jointID;
		}

		/**
		 * Cleanup for Tracked Region
		 */
		public function dispose():void {
			_skeleton = null;
			__jointID = NaN;
		}

		/**
		 * Returns the top position based on the joints position plus the relative offset
		 */
		override public function get top():Number {
			_joint = _skeleton.getJoint(__jointID);
			return _joint.y + _top;
		}

		/**
		 * Returns the left position based on the joints position plus the relative offset
		 */
		override public function get left():Number {
			_joint = _skeleton.getJoint(__jointID);
			return _joint.x + _left;
		}

		/**
		 * Returns the bottom position based on the joints position plus the relative offset
		 */
		override public function get bottom():Number {
			_joint = _skeleton.getJoint(__jointID);
			return _joint.y + _bottom;
		}

		/**
		 * Returns the right position based on the joints position plus the relative offset
		 */
		override public function get right():Number {
			_joint = _skeleton.getJoint(__jointID);
			return _joint.x + _right;
		}

		/**
		 * Returns the back position based on the joints position plus the relative offset
		 */
		override public function get back():Number {
			_joint = _skeleton.getJoint(__jointID);
			if (_joint.z + _back > 4) return 4;
			return _joint.z + _back;
		}

		/**
		 * Returns the front position based on the joints position plus the relative offset
		 */
		override public function get front():Number {
			_joint = _skeleton.getJoint(__jointID);
			if (_joint.z + _front < 0) return 0;
			return _joint.z + _front;
		}
	}
}