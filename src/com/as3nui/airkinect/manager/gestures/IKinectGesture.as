/**
 *
 * User: rgerbasi
 * Date: 10/3/11
 * Time: 5:28 PM
 */
package com.as3nui.airkinect.manager.gestures {
	import com.as3nui.airkinect.manager.regions.Region;
	import com.as3nui.airkinect.manager.skeleton.Skeleton;

	import org.osflash.signals.Signal;

	public interface IKinectGesture {
		function dispose():void;

		function update():void;

		function get priority():uint;

		function get skeleton():Skeleton;

		function get currentState():String;

		function get regions():Vector.<Region>

		function get onGestureBegin():Signal;

		function get onGestureProgress():Signal;
		
		function get onGestureCanceled():Signal;

		function get onGestureComplete():Signal;
	}
}