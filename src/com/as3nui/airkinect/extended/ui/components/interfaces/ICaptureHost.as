/**
 *
 * User: Ross
 * Date: 11/19/11
 * Time: 7:15 PM
 */
package com.as3nui.airkinect.extended.ui.components.interfaces {
	import com.as3nui.airkinect.extended.ui.objects.Cursor;

	/**
	 * Capture host can capturew and release a cursor. This is used by the UIManager
	 */
	public interface ICaptureHost {
		/**
		 * Boolean to determine cursor capture status
		 */
		function get hasCursor():Boolean;

		/**
		 * Causes the CaptureHost to Capture a Cursor
		 * @param cursor		Cursor to capture
		 */
		function capture(cursor:Cursor):void;

		/**
		 * Causes the CaptureHost to Release a Cursor
		 * @param cursor		Cursor to release
		 */
		function release(cursor:Cursor):void;
	}
}