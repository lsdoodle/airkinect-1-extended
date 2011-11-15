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

	public class Skeleton {

		public static const SKELETON_DATA_HISTORY_DEPTH:uint = 30;

		private var _skeletonPositionsHistory:Vector.<SkeletonPosition>;
		private var _currentSkeletonData:SkeletonPosition;
		private var _emptyResult:Vector3D = new Vector3D();

		public function Skeleton(skeletonPosition:SkeletonPosition = null) {
			_skeletonPositionsHistory = new Vector.<SkeletonPosition>();
			if (skeletonPosition) update(skeletonPosition)
		}

		public function dispose():void {
			_skeletonPositionsHistory = new Vector.<SkeletonPosition>();
		}

		public function update(skeletonPosition:SkeletonPosition):void {
			_currentSkeletonData = skeletonPosition;
			_skeletonPositionsHistory.unshift(skeletonPosition);

			while(_skeletonPositionsHistory.length > SKELETON_DATA_HISTORY_DEPTH) _skeletonPositionsHistory.pop();
		}

		public function get currentSkeleton():SkeletonPosition {
			return _currentSkeletonData;
		}

		public function get skeletonPositionsHistory():Vector.<SkeletonPosition> {
			return _skeletonPositionsHistory;
		}

		public function getPositionInHistory(elementID:uint, step:uint):Vector3D {
			if(_skeletonPositionsHistory.length <= step ){
				return _emptyResult;
			}else{
				return _skeletonPositionsHistory[step].getElement(elementID);
			}
		}

		public function calculateDelta(elementID:uint, step:uint):DeltaResult {
			var elements:Vector.<uint> = new <uint>[elementID];
			var steps:Vector.<Vector.<uint>> = new <Vector.<uint>>[new <uint>[step]];
			var result:Dictionary = calculateMultipleStepDeltas(elements,  steps);
			return result[elementID][step] as DeltaResult;
		}

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

		
		//----------------------------------
		// SkeletonPosition Accessor Functions
		//----------------------------------
		public function getElement(index:uint):Vector3D {
			return currentSkeleton.getElement(index);
		}

		public function getElementScaled(index:uint, scale:Vector3D):Vector3D {
			return currentSkeleton.getElementScaled(index,  scale);
		}

		public function get frameNumber():uint {
			return currentSkeleton.frameNumber;
		}

		public function get timestamp():uint {
			return currentSkeleton.timestamp;
		}

		public function get trackingID():uint {
			return currentSkeleton.trackingID;
		}

		public function get trackingState():uint {
			return currentSkeleton.trackingState;
		}

		public function get numElements():uint {
			return currentSkeleton.elements.length;
		}

		public function get elements():Vector.<Vector3D> {
			return currentSkeleton.elements;
		}

	}
}