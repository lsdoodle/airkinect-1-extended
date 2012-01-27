/*
 * Copyright 2012 AS3NUI
 *
 *    Licensed under the Apache License, Version 2.0 (the "License");
 *    you may not use this file except in compliance with the License.
 *    You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *    Unless required by applicable law or agreed to in writing, software
 *    distributed under the License is distributed on an "AS IS" BASIS,
 *    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *    See the License for the specific language governing permissions and
 *    limitations under the License.
 */

package com.as3nui.airkinect.extended.manager.gestures {

	/**
	 * Different states a gesture can go through
	 */
	public class GestureState {
		public static const GESTURE_IDLE:String 		= "idle";
		public static const GESTURE_STARTED:String 		= "started";
		public static const GESTURE_PROGRESS:String 	= "progress";
		public static const GESTURE_CANCELED:String		= "canceled";
		public static const GESTURE_COMPLETE:String		= "complete";
	}
}