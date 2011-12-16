/**
 *
 * User: rgerbasi
 * Date: 12/16/11
 * Time: 10:26 AM
 */
package com.as3nui.airkinect.extended.pointcloud {
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.net.FileReference;
	import flash.utils.ByteArray;

	public class PointCloudHelper {
		private static var _onSave:Function;
		private static var _onCancel:Function;

		public static function savePTS(depthData:ByteArray, intensity:Number = .1, saveCallback:Function = null, cancelCallback:Function = null):void {
			var ba:ByteArray = new ByteArray();
			ba.writeUTFBytes((depthData.length / 6).toString());
			ba.writeUTFBytes(File.lineEnding);

			_onSave = saveCallback;
			_onCancel = cancelCallback;

			var xygRGB:XYZRGBData;

			depthData.position = 0;
			while (depthData.bytesAvailable) {
				xygRGB = XYZRGBData.fromDepth(depthData);

				ba.writeUTFBytes(xygRGB.x.toString());
				ba.writeUTFBytes(" ");
				ba.writeUTFBytes(xygRGB.y.toString());
				ba.writeUTFBytes(" ");
				ba.writeUTFBytes(xygRGB.z.toString());
				ba.writeUTFBytes("   ");
				ba.writeUTFBytes(intensity.toString());
				ba.writeUTFBytes("  ");
				ba.writeUTFBytes(xygRGB.rgbString());
				ba.writeUTFBytes(File.lineEnding);

			}
			saveByteArray(ba, "pts");
		}

		public static function saveXYZ(depthData:ByteArray, saveCallback:Function = null, cancelCallback:Function = null):void {
			var ba:ByteArray = new ByteArray();
			ba.writeUTFBytes((depthData.length / 6).toString());
			ba.writeUTFBytes(File.lineEnding);

			_onSave = saveCallback;
			_onCancel = cancelCallback;

			var xygRGB:XYZRGBData;

			depthData.position = 0;
			while (depthData.bytesAvailable) {
				xygRGB = XYZRGBData.fromDepth(depthData);
				ba.writeUTFBytes(xygRGB.x.toString() + "\t");
				ba.writeUTFBytes(xygRGB.y.toString() + "\t");
				ba.writeUTFBytes(xygRGB.z.toString() + "\n");
				ba.writeUTFBytes(File.lineEnding);

			}
			saveByteArray(ba, "xyz");
		}

		public static function savePLY(depthData:ByteArray, saveCallback:Function = null, cancelCallback:Function = null):void {

			var header:String = "ply" + File.lineEnding;
			header += "format ascii 1.0" + File.lineEnding;
			header += "comment author: AS3NUI" + File.lineEnding;
			header += "element vertex " + (depthData.length / 6).toString() + File.lineEnding;
			header += "property float x" + File.lineEnding;
			header += "property float y" + File.lineEnding;
			header += "property float z" + File.lineEnding;
			header += "property uchar red" + File.lineEnding;
			header += "property uchar green" + File.lineEnding;
			header += "property uchar blue" + File.lineEnding;
			header += "end_header" + File.lineEnding;

			var ba:ByteArray = new ByteArray();
			ba.writeUTFBytes(header);
			_onSave = saveCallback;
			_onCancel = cancelCallback;

			var xygRGB:XYZRGBData;

			depthData.position = 0;
			while (depthData.bytesAvailable) {
				xygRGB = XYZRGBData.fromDepth(depthData);
				ba.writeUTFBytes(xygRGB.x.toString());
				ba.writeUTFBytes(" ");
				ba.writeUTFBytes(xygRGB.y.toString());
				ba.writeUTFBytes(" ");
				ba.writeUTFBytes(xygRGB.z.toString());
				ba.writeUTFBytes(" ");
				ba.writeUTFBytes(xygRGB.rgbString());
				ba.writeUTFBytes(File.lineEnding);

			}
			saveByteArray(ba, "ply");
		}


		private static function saveByteArray(byteArray:ByteArray, extension:String):void {
			var fr:FileReference = new FileReference();
			fr.addEventListener(Event.SELECT, onSaveSuccess);
			fr.addEventListener(Event.CANCEL, onSaveCancel);
			fr.save(byteArray, "PointCloud." + extension);
		}

		private static function onSaveCancel(event:Event):void {
			(event.target as FileReference).removeEventListener(Event.SELECT, onSaveSuccess);
			(event.target as FileReference).removeEventListener(Event.CANCEL, onSaveCancel);
			if (_onCancel != null) _onCancel.apply(null, [event]);
			_onSave = _onCancel = null;
		}


		private static function onSaveSuccess(event:Event):void {
			(event.target as FileReference).removeEventListener(Event.SELECT, onSaveSuccess);
			(event.target as FileReference).removeEventListener(Event.CANCEL, onSaveCancel);
			if (_onSave != null) _onSave.apply(null, [event]);
			_onSave = _onCancel = null;
		}
	}
}

import flash.utils.ByteArray;

class XYZRGBData {
	private var _x:Number;
	private var _y:Number;
	private var _z:Number;
	private var _r:uint;
	private var _g:uint;
	private var _b:uint;

	public static function fromDepth(depthData:ByteArray):XYZRGBData {
		var x:Number = depthData.readShort();
		x /= 320;
		var y:Number = depthData.readShort();
		y /= 240;
		var z:Number = depthData.readShort();
		if (z < 1) z = 1;
		if (z > 2047) z = 2047;
		z /= 2047;

		var gray:uint = z * 255;
		z *= 4;
		return new XYZRGBData(x, y, z, gray, gray, gray);
	}

	function XYZRGBData(x:Number, y:Number, z:Number, r:uint = 255, g:uint = 255, b:uint = 255):void {
		_x = x;
		_y = y;
		_z = z;
		_r = r;
		_g = g;
		_b = b;
	}

	public function rgbString():String {
		return r.toString() + " " + g.toString() + " " + b.toString();
	}

	public function get x():Number {
		return _x;
	}

	public function get y():Number {
		return _y;
	}

	public function get z():Number {
		return _z;
	}

	public function get r():uint {
		return _r;
	}

	public function get g():uint {
		return _g;
	}

	public function get b():uint {
		return _b;
	}
}