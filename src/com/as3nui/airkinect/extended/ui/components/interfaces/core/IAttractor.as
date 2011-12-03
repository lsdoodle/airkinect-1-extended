package com.as3nui.airkinect.extended.ui.components.interfaces.core {
	import flash.geom.Point;

	public interface IAttractor {
		function get captureHost():ICaptureHost;
		function get globalCenter():Point;
		function get captureWidth():Number;
		function get captureHeight():Number;

		function get minPull():Number;
		function get maxPull():Number;
	}
}