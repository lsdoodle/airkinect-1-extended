/**
 *
 * User: Ross
 * Date: 11/19/11
 * Time: 4:52 PM
 */
package com.as3nui.airkinect.extended.ui.components {
	import com.as3nui.airkinect.extended.ui.components.interfaces.core.IUIComponent;

	import flash.display.Sprite;
	import flash.events.Event;

	public class BaseUIComponent extends Sprite implements IUIComponent {
		public var data:*;
		protected var _enabled:Boolean;

		public function BaseUIComponent() {
			_enabled = true;
			this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStageHandler);
		}

		private function onAddedToStageHandler(e:Event):void {
			this.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStageHandler);
			this.addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStageHandler);
			onAddedToStage();
		}

		private function onRemovedFromStageHandler(e:Event):void {
			this.removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStageHandler);
			this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStageHandler);
			onRemovedFromStage();
		}

		protected function onAddedToStage():void {
		}

		protected function onRemovedFromStage():void {
		}

		public function get enabled():Boolean {
			return _enabled;
		}

		public function set enabled(value:Boolean):void {
			_enabled = value;
		}
	}
}