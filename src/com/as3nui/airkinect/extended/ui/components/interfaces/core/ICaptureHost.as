/**
 *
 * User: Ross
 * Date: 11/19/11
 * Time: 7:15 PM
 */
package com.as3nui.airkinect.extended.ui.components.interfaces.core {
	import com.as3nui.airkinect.extended.ui.objects.Cursor;

	public interface ICaptureHost {
		function get hasCursor():Boolean;
		function capture(cursor:Cursor):void;
		function release(cursor:Cursor):void;
	}
}