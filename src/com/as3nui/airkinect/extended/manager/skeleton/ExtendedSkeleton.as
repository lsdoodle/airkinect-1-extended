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

package com.as3nui.airkinect.extended.manager.skeleton {
	import com.as3nui.nativeExtensions.kinect.data.AIRKinectSkeleton;
	import com.as3nui.nativeExtensions.kinect.data.AIRKinectSkeletonJoint;

	import flash.geom.Vector3D;
	import flash.utils.Dictionary;

	/**
	 * Skeleton Class is used to hold the current position of all the joints of a skeleton
	 * along with storing all positing in a history lookup.
	 *
	 * This class also adds the ability to calculate the differences of joint position over time.
	 */
	public class ExtendedSkeleton {
		/**
		 * Depth of history to maintain for all skeletons. Be warned this history depth
		 * is used in Gestures currently and setting too low will break gesture support.
		 */
		public static var SKELETON_DATA_HISTORY_DEPTH:uint = 30;

		/**
		 * History of this skeletons positions
		 */
		private var _skeletonHistory:Vector.<AIRKinectSkeleton>;
		/**
		 * Current Position of this skeleton
		 */
		private var _currentSkeletonData:AIRKinectSkeleton;
		/**
		 * Re-usable empty AIRKinectSkeletonJoint
		 */
		private var _emptyResult:AIRKinectSkeletonJoint = new AIRKinectSkeletonJoint();

		/**
		 * Creates a new skeleton
		 * @param skeleton		Option position to set this skeleton at
		 */
		public function ExtendedSkeleton(skeleton:AIRKinectSkeleton = null) {
			_skeletonHistory = new Vector.<AIRKinectSkeleton>();
			if (skeleton) update(skeleton)
		}

		/**
		 * Cleans up the history for this skeleton
		 */
		public function dispose():void {
			_skeletonHistory = new Vector.<AIRKinectSkeleton>();
		}

		/**
		 * Updates the current position for the skeleton, recording the previous position
		 * into the history lookup
		 * @param skeleton			AIRKinectSkeleton to update skeleton to
		 */
		public function update(skeleton:AIRKinectSkeleton):void {
			_currentSkeletonData = skeleton;
			_skeletonHistory.unshift(skeleton);

			while(_skeletonHistory.length > SKELETON_DATA_HISTORY_DEPTH) _skeletonHistory.pop();
		}

		/**
		 * Returns the current position for this skeleton
		 */
		public function get currentSkeleton():AIRKinectSkeleton {
			return _currentSkeletonData;
		}

		/**
		 * Returns all the positions current in the History buffer for this skeleton
		 */
		public function get skeletonHistory():Vector.<AIRKinectSkeleton> {
			return _skeletonHistory;
		}

		/**
		 * Allows access to any joint at any time currently in the history buffer.
		 * If an attempt to get a position further back then the buffer has a empty result
		 * will be returned.
		 * @param jointID		Joint to get position of
		 * @param step			Steps in time to go back
		 * @return				AIRKinectSkeletonJoint of joints position at steps back in time
		 */
		public function getPositionInHistory(jointID:uint, step:uint):AIRKinectSkeletonJoint {
			if(_skeletonHistory.length <= step ){
				return _emptyResult;
			}else{
				return _skeletonHistory[step].getJoint(jointID);
			}
		}

		/**
		 * Calculates the different in position between the current time and
		 * a previous time. Result will be a AIRKinectSkeletonJoint showing differences.
		 * @param jointID		Joint to Calculate delta change of
		 * @param step			Steps to compare back
		 * @return				DeltaResult object for the current joint over steps
		 */
		public function calculateDelta(jointID:uint, step:uint):DeltaResult {
			var joints:Vector.<uint> = new <uint>[jointID];
			var steps:Vector.<Vector.<uint>> = new <Vector.<uint>>[new <uint>[step]];
			var result:Dictionary = calculateMultipleStepDeltas(joints,  steps);
			return result[jointID][step] as DeltaResult;
		}

		/**
		 * Calculates multiple deltas at the same time.
		 * @param jointIDs		Joints to calculate differences over time
		 * @param steps			Steps to check
		 * @return				Dictionary of Deltas in the form
		 * 						[jointID][Steps] as a DeltaResult
		 */
		public function calculateMultipleStepDeltas(jointIDs:Vector.<uint>, steps:Vector.<Vector.<uint>>):Dictionary {
			if(jointIDs.length != steps.length) throw new Error("Joints and Steps vectors must be of same length");

			var jointLookup:Dictionary = new Dictionary();
			if(_skeletonHistory == null) return jointLookup;
			var jointIndex:uint;

			var jointID:uint;
			for(jointIndex = 0;jointIndex<jointIDs.length;jointIndex++){
				jointID = jointIDs[jointIndex];
				jointLookup[jointID] = new Dictionary();
			}
			
			var skeletonInTime:AIRKinectSkeleton;
			var jointPositionInTime:AIRKinectSkeletonJoint;
			var currentAxisPosition:AIRKinectSkeletonJoint;
			var currentJointStep:uint;
			var stepIndex:uint;
			
			for(jointIndex = 0;jointIndex<jointIDs.length;jointIndex++){
				jointID = jointIDs[jointIndex];
				currentAxisPosition = getJoint(jointID);
				for(stepIndex=0; stepIndex<steps[jointIndex].length;stepIndex++){
					currentJointStep = steps[jointIndex][stepIndex];
					if(_skeletonHistory.length <= currentJointStep ){
						jointLookup[jointID][currentJointStep] = new DeltaResult(jointID, currentJointStep, _emptyResult);
					}else{
						skeletonInTime = _skeletonHistory[currentJointStep];
						jointPositionInTime = skeletonInTime.getJoint(jointID);
						jointLookup[jointID][currentJointStep] = new DeltaResult(jointID, currentJointStep, currentAxisPosition.subtract(jointPositionInTime));
					}
				}
			}
			return jointLookup;
		}


		/**
		 * The current position of any skeleton joint
		 * @param index		Joint index to retrieve
		 * @return			AIRKinectSkeletonJoint of current joint position
		 */
		public function getJoint(index:uint):AIRKinectSkeletonJoint {
			return currentSkeleton.getJoint(index);
		}

		/**
		 * Scaled position of any joint.
		 * @param index			Joint index to retrieve
		 * @param scale			Vector3D to scale vector by
		 * @return				AIRKinectSkeletonJoint Vector for Joint
		 */
		public function getJointScaled(index:uint, scale:Vector3D):AIRKinectSkeletonJoint {
			return currentSkeleton.getJointScaled(index,  scale);
		}

		/**
		 * Current Frame number of the skeleton
		 */
		public function get frameNumber():uint {
			return currentSkeleton.frameNumber;
		}

		/**
		 * Current Timestamp for the Skeleton
		 */
		public function get timestamp():uint {
			return currentSkeleton.timestamp;
		}

		/**
		 * TrackingId of the Skeleton
		 */
		public function get trackingID():uint {
			return currentSkeleton.trackingID;
		}

		/**
		 * Current Tracking state of the skeleton
		 */
		public function get trackingState():uint {
			return currentSkeleton.trackingState;
		}

		/**
		 * Total number of joints in this skeleton
		 */
		public function get numJoints():uint {
			return currentSkeleton.joints.length;
		}

		/**
		 * Returns all the joints as a Vector
		 */
		public function get joints():Vector.<AIRKinectSkeletonJoint> {
			return currentSkeleton.joints;
		}

	}
}