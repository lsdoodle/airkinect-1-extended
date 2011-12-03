/**
 *
 * User: Ross
 * Date: 11/19/11
 * Time: 4:49 PM
 */
package com.as3nui.airkinect.extended.ui.components {
	import com.as3nui.airkinect.extended.ui.display.BaseSelectionTimer;
	import com.as3nui.airkinect.extended.ui.events.UIEvent;

	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.utils.getTimer;

	public class SelectableHandle extends Handle {

		protected var _selectionTimer:BaseSelectionTimer;
		protected var _selectionStartTimer:int;
		protected var _selectionDelay:uint;

		
		public function SelectableHandle(icon:DisplayObject, selectionTimer:BaseSelectionTimer, selectedIcon:DisplayObject = null, selectionDelay:uint = 1, minPull:Number = .1, maxPull:Number = 1){
			super(icon, selectedIcon, minPull, maxPull);
			_selectionDelay = selectionDelay;
			_selectionTimer = selectionTimer;
		}
		
		override protected function onRemovedFromStage():void {
			super.onRemovedFromStage();
			this.removeEventListener(Event.ENTER_FRAME, onSelectionTimeUpdate);
		}

		override protected function onHandleCapture():void {
			super.onHandleCapture();
			this.addChild(_selectionTimer);
			_selectionTimer.x = centerPoint.x - (_selectionTimer.width/2);
			_selectionTimer.y = centerPoint.y - (_selectionTimer.height/2);


			_selectionTimer.onProgress(0);
			
			_selectionStartTimer = getTimer();
			this.addEventListener(Event.ENTER_FRAME, onSelectionTimeUpdate);
		}

		override protected function onHandleRelease():void {
			super.onHandleRelease();
			if (this.contains(_selectionTimer)) this.removeChild(_selectionTimer);
			this.removeEventListener(Event.ENTER_FRAME, onSelectionTimeUpdate);
		}

		protected function onSelectionTimeUpdate(event:Event):void {
			var progress:Number = (getTimer() - _selectionStartTimer) / (_selectionDelay * 1000);
			_selectionTimer.onProgress(progress);
			if (progress >= 1) onSelected();
		}

		protected function onSelected():void {
			if (this.contains(_selectionTimer)) this.removeChild(_selectionTimer);
			this.removeEventListener(Event.ENTER_FRAME, onSelectionTimeUpdate);
			release(_cursor);

			var globalPosition:Point = this.localToGlobal(centerPoint);
			this.dispatchEvent(new UIEvent(UIEvent.SELECTED, _cursor, centerPoint.x, centerPoint.y, globalPosition.x, globalPosition.y));
		}

		//----------------------------------
		// Selection Delay
		//----------------------------------
		public function get selectionDelay():uint {
			return _selectionDelay;
		}

		public function set selectionDelay(value:uint):void {
			_selectionDelay = value;
		}
	}
}