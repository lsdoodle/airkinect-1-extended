package com.as3nui.airkinect.extended.ui.components.interfaces {
	import flash.geom.Point;

	/**
	 * Attractor will pull a cursor towards it. This is managed bgy the UIManager currently a cursor moving OVER an object
	 * will start the attraction. Once attraction is complete a cursor will be capture into the captureHost
	 */
	public interface IAttractor {

		/**
		 * Capture host to capture the cursor upon attraction complete
		 */
		function get captureHost():ICaptureHost;

		/**
		 * Global Center position of attraction point
		 */
		function get globalCenter():Point;

		/**
		 * Width of the capture area
		 */
		function get captureWidth():Number;

		/**
		 * Height of the capture area
		 */
		function get captureHeight():Number;

		/**
		 * Minimum pull of the attraction
		 */
		function get minPull():Number;

		/**
		 * Maximum pull of the attraction
		 */
		function get maxPull():Number;
	}
}