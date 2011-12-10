/**
 *
 * User: rgerbasi
 * Date: 10/3/11
 * Time: 11:03 AM
 */
package com.as3nui.airkinect.extended.manager.regions {
	import com.as3nui.airkinect.extended.manager.skeleton.Skeleton;

	import flash.geom.Vector3D;

	/**
	 * Tracked Region is used to attach a region relative to any element on a skeleton
	 * Positions are then defined relative to the elements positions.
	 * For example a top of -1 and bottom of 1 attached to any element would always contain the full
	 * height of the Kinect. a top of -.5 would always be half the height upwards from the current element, and so on.
	 */
	public class TrackedRegion extends Region {
		private var _skeleton:Skeleton;
		private var _elementID:uint;

		private var _element:Vector3D;

		/**
		 * Creates a New Tracked region
		 * @param skeleton		Skeleton to attach region to
		 * @param elementID		Element to track
		 * @param top			Top position relative to Element position
		 * @param left			Left position relative to Element position
		 * @param bottom		Bottom position relative to Element position
		 * @param right			Right position relative to Element position
		 * @param front			Front position relative to Element position
		 * @param back			Back position relative to Element position
		 */
		public function TrackedRegion(skeleton:Skeleton, elementID:uint, top:Number, left:Number, bottom:Number, right:Number, front:Number, back:Number):void {
			super(top, left, bottom, right, front, back);
			_skeleton = skeleton;
			_elementID = elementID;
		}

		/**
		 * Cleanup for Tracked Region
		 */
		public function dispose():void {
			_skeleton = null;
			_elementID = NaN;
		}

		/**
		 * Returns the top position based on the elements position plus the relative offset
		 */
		override public function get top():Number {
			_element = _skeleton.getElement(_elementID);
			return _element.y + _top;
		}

		/**
		 * Returns the left position based on the elements position plus the relative offset
		 */
		override public function get left():Number {
			_element = _skeleton.getElement(_elementID);
			return _element.x + _left;
		}

		/**
		 * Returns the bottom position based on the elements position plus the relative offset
		 */
		override public function get bottom():Number {
			_element = _skeleton.getElement(_elementID);
			return _element.y + _bottom;
		}

		/**
		 * Returns the right position based on the elements position plus the relative offset
		 */
		override public function get right():Number {
			_element = _skeleton.getElement(_elementID);
			return _element.x + _right;
		}

		/**
		 * Returns the back position based on the elements position plus the relative offset
		 */
		override public function get back():Number {
			_element = _skeleton.getElement(_elementID);
			if (_element.z + _back > 4) return 4;
			return _element.z + _back;
		}

		/**
		 * Returns the front position based on the elements position plus the relative offset
		 */
		override public function get front():Number {
			_element = _skeleton.getElement(_elementID);
			if (_element.z + _front < 0) return 0;
			return _element.z + _front;
		}
	}
}