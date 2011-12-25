/**
 *
 * User: Ross
 * Date: 11/19/11
 * Time: 4:49 PM
 */
package com.as3nui.airkinect.extended.ui.components {
	import com.as3nui.airkinect.extended.ui.events.UIEvent;

	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.geom.Point;

	public class PushHandle extends Handle {
		private var _originalZ:Number;
		private var _pushChangeThreshold:Number;

		public function PushHandle(icon:DisplayObject, selectedIcon:DisplayObject = null, disabledIcon:DisplayObject = null, pushThreshold:Number = .07, capturePadding:Number = .45, minPull:Number = .1, maxPull:Number = 1) {
			super(icon, selectedIcon, disabledIcon, capturePadding, minPull, maxPull);
			_pushChangeThreshold = pushThreshold;
		}

		override protected function onRemovedFromStage():void {
			super.onRemovedFromStage();
			this.removeEventListener(Event.ENTER_FRAME, onUpdate);
		}

		override protected function onHandleCapture():void {
			super.onHandleCapture();

			_originalZ = _cursor.z;
			this.addEventListener(Event.ENTER_FRAME, onUpdate);
		}

		override protected function onHandleRelease():void {
			super.onHandleRelease();
			this.removeEventListener(Event.ENTER_FRAME, onUpdate);
		}

		private function onUpdate(event:Event):void {
			var overallDiff:Number = _originalZ - _cursor.z;
			if (overallDiff >= _pushChangeThreshold) onSelected();
		}

		protected function onSelected():void {
			release(_cursor);
			var globalPosition:Point = this.localToGlobal(centerPoint);
			this.dispatchEvent(new UIEvent(UIEvent.SELECTED, _cursor, centerPoint.x, centerPoint.y, globalPosition.x, globalPosition.y));
		}
	}
}