/**
 *
 * User: rgerbasi
 * Date: 10/1/11
 * Time: 4:42 PM
 */
package com.as3nui.airkinect.extended.manager.skeleton {
	import com.as3nui.nativeExtensions.kinect.data.SkeletonPosition;

	import flash.geom.Vector3D;
	import flash.utils.Dictionary;

	/**
	 * Skeleton Class is used to hold the current position of all the elements of a skeleton
	 * along with storing all positing in a history lookup.
	 *
	 * This class also adds the ability to calculate the differences of element position over time.
	 */
	public class Skeleton {
		/**
		 * Depth of history to maintain for all skeletons. Be warned this history depth
		 * is used in Gestures currently and setting too low will break gesture support.
		 */
		public static var SKELETON_DATA_HISTORY_DEPTH:uint = 30;

		/**
		 * History of this skeletons positions
		 */
		private var _skeletonPositionsHistory:Vector.<SkeletonPosition>;
		/**
		 * Current Position of this skeleton
		 */
		private var _currentSkeletonData:SkeletonPosition;
		/**
		 * Re-usable empty vector3D
		 */
		private var _emptyResult:Vector3D = new Vector3D();

		/**
		 * Creates a new skeleton
		 * @param skeletonPosition		Option position to set this skeleton at
		 */
		public function Skeleton(skeletonPosition:SkeletonPosition = null) {
			_skeletonPositionsHistory = new Vector.<SkeletonPosition>();
			if (skeletonPosition) update(skeletonPosition)
		}

		/**
		 * Cleans up the history for this skeleton
		 */
		public function dispose():void {
			_skeletonPositionsHistory = new Vector.<SkeletonPosition>();
		}

		/**
		 * Updates the current position for the skeleton, recording the previous position
		 * into the history lookup
		 * @param skeletonPosition		SkeletonPosition to update skeleton to
		 */
		public function update(skeletonPosition:SkeletonPosition):void {
			_currentSkeletonData = skeletonPosition;
			_skeletonPositionsHistory.unshift(skeletonPosition);

			while(_skeletonPositionsHistory.length > SKELETON_DATA_HISTORY_DEPTH) _skeletonPositionsHistory.pop();
		}

		/**
		 * Returns the current position for this skeleton
		 */
		public function get currentSkeleton():SkeletonPosition {
			return _currentSkeletonData;
		}

		/**
		 * Returns all the positions current in the History buffer for this skeleton
		 */
		public function get skeletonPositionsHistory():Vector.<SkeletonPosition> {
			return _skeletonPositionsHistory;
		}

		/**
		 * Allows access to any element at any time currently in the history buffer.
		 * If an attempt to get a position further back then the buffer has a empty result
		 * will be returned.
		 * @param elementID		Element to get position of
		 * @param step			Steps in time to go back
		 * @return				Vector3D of elements position at steps back in time
		 */
		public function getPositionInHistory(elementID:uint, step:uint):Vector3D {
			if(_skeletonPositionsHistory.length <= step ){
				return _emptyResult;
			}else{
				return _skeletonPositionsHistory[step].getElement(elementID);
			}
		}

		/**
		 * Calculates the different in position between the current time and
		 * a previous time. Result will be a Vector3D showing differences.
		 * @param elementID		Element to Calculate delta change of
		 * @param step			Steps to compare back
		 * @return				DeltaResult object for the current element over steps
		 */
		public function calculateDelta(elementID:uint, step:uint):DeltaResult {
			var elements:Vector.<uint> = new <uint>[elementID];
			var steps:Vector.<Vector.<uint>> = new <Vector.<uint>>[new <uint>[step]];
			var result:Dictionary = calculateMultipleStepDeltas(elements,  steps);
			return result[elementID][step] as DeltaResult;
		}

		/**
		 * Calculates multiple deltas at the same time.
		 * @param elementIDs	Elements to calculate differences over time
		 * @param steps			Steps to check
		 * @return				Dictionary of Deltas in the form
		 * 						[elementID][Steps] as a DeltaResult
		 */
		public function calculateMultipleStepDeltas(elementIDs:Vector.<uint>, steps:Vector.<Vector.<uint>>):Dictionary {
			if(elementIDs.length != steps.length) throw new Error("Elements and Steps vectors must be of same length");

			var elementLookup:Dictionary = new Dictionary();
			if(_skeletonPositionsHistory == null) return elementLookup;
			var elementIndex:uint;

			var elementID:uint;
			for(elementIndex = 0;elementIndex<elementIDs.length;elementIndex++){
				elementID = elementIDs[elementIndex];
				elementLookup[elementID] = new Dictionary();
			}
			
			var skeletonPositionInTime:SkeletonPosition;
			var elementPositionInTime:Vector3D;
			var currentAxisPosition:Vector3D;
			var currentElementStep:uint;
			var stepIndex:uint;
			
			for(elementIndex = 0;elementIndex<elementIDs.length;elementIndex++){
				elementID = elementIDs[elementIndex];
				currentAxisPosition = getElement(elementID);
				for(stepIndex=0; stepIndex<steps[elementIndex].length;stepIndex++){
					currentElementStep = steps[elementIndex][stepIndex];
					if(_skeletonPositionsHistory.length <= currentElementStep ){
						elementLookup[elementID][currentElementStep] = new DeltaResult(elementID, currentElementStep, _emptyResult);
					}else{
						skeletonPositionInTime = _skeletonPositionsHistory[currentElementStep];
						elementPositionInTime = skeletonPositionInTime.getElement(elementID);
						elementLookup[elementID][currentElementStep] = new DeltaResult(elementID, currentElementStep, currentAxisPosition.subtract(elementPositionInTime));
					}
				}
			}
			return elementLookup;
		}


		/**
		 * The current position of any skeleton element
		 * @param index		Element index to retrieve
		 * @return			Vector3D of current element position
		 */
		public function getElement(index:uint):Vector3D {
			return currentSkeleton.getElement(index);
		}

		/**
		 * Scaled position of any element.
		 * @param index			Element index to retrieve
		 * @param scale			Vector3D to scale vector by
		 * @return				Scaled Vector for Element
		 */
		public function getElementScaled(index:uint, scale:Vector3D):Vector3D {
			return currentSkeleton.getElementScaled(index,  scale);
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
		 * Total number of elements in this skeleton
		 */
		public function get numElements():uint {
			return currentSkeleton.elements.length;
		}

		/**
		 * Returns all the elements as a Vector
		 */
		public function get elements():Vector.<Vector3D> {
			return currentSkeleton.elements;
		}

	}
}