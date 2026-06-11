Class {
	#name : 'MyFace',
	#superclass : 'MyShape',
	#category : 'MyOpenCascade-Base',
	#package : 'MyOpenCascade',
	#tag : 'Base'
}

{ #category : 'inspection' }
MyFace >> refreshTopologyChildrenForInspection [
	"Populates the wires contained in this face for the raw inspector."

	wires := self subshapesOfType: self wireType as: MyWire
]

{ #category : 'inspection' }
MyFace >> topologyChildrenForInspection [

	^ wires ifNil: [ #(  ) ]
]
