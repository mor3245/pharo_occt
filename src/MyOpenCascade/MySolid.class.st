Class {
	#name : 'MySolid',
	#superclass : 'MyShape',
	#category : 'MyOpenCascade-Base',
	#package : 'MyOpenCascade',
	#tag : 'Base'
}

{ #category : 'inspection' }
MySolid >> refreshTopologyChildrenForInspection [
	"Populates the shells contained in this solid for the raw inspector."

	shells := self subshapesOfType: self shellType as: MyShell
]

{ #category : 'inspection' }
MySolid >> topologyChildrenForInspection [

	^ shells ifNil: [ #(  ) ]
]
