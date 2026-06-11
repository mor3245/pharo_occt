Class {
	#name : 'MyWire',
	#superclass : 'MyShape',
	#category : 'MyOpenCascade-Base',
	#package : 'MyOpenCascade',
	#tag : 'Base'
}

{ #category : 'inspection' }
MyWire >> refreshTopologyChildrenForInspection [
	"Populates the edges contained in this wire for the raw inspector."

	edges := self subshapesOfType: self edgeType as: MyEdge
]

{ #category : 'inspection' }
MyWire >> topologyChildrenForInspection [

	^ edges ifNil: [ #(  ) ]
]
