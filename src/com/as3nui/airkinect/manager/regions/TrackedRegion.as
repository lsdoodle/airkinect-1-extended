/**
 *
 * User: rgerbasi
 * Date: 10/3/11
 * Time: 11:03 AM
 */
package com.as3nui.airkinect.manager.regions {
	import com.as3nui.airkinect.manager.skeleton.Skeleton;

	import flash.geom.Vector3D;

	public class TrackedRegion extends Region {
		private var _skeleton:Skeleton;
		private var _elementID:uint;

		private var _element:Vector3D;

		public function TrackedRegion(skeleton:Skeleton, elementID:uint, top:Number, left:Number, bottom:Number, right:Number, front:Number, back:Number):void {
			super(top,  left,  bottom,  right,  front,  back);
			_skeleton 	= skeleton;
			_elementID 	= elementID;
		}

		public function dispose():void {
			_skeleton 		= null;
			_elementID 		= NaN;
		}

		override public function get top():Number {
			_element = _skeleton.getElement(_elementID);
			return _element.y + _top;
		}

		override public function get left():Number {
			_element = _skeleton.getElement(_elementID);
			return _element.x + _left;
		}

		override public function get bottom():Number {
			_element = _skeleton.getElement(_elementID);
			return _element.y + _bottom;
		}

		override public function get right():Number {
			_element = _skeleton.getElement(_elementID);
			return _element.x + _right;
		}

		override public function get back():Number {
			_element = _skeleton.getElement(_elementID);
			if(_element.z + _back > 4) return 4;
			return _element.z + _back;
		}

		override public function get front():Number {
			_element = _skeleton.getElement(_elementID);
			if(_element.z + _front < 0) return 0;
			return _element.z + _front;
		}
	}
}