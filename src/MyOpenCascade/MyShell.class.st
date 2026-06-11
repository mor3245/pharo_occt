Class {
	#name : 'MyShell',
	#superclass : 'MyShape',
	#category : 'MyOpenCascade-Base',
	#package : 'MyOpenCascade',
	#tag : 'Base'
}

{ #category : 'inspection' }
MyShell >> refreshTopologyChildrenForInspection [
	"Populates the faces contained in this shell for the raw inspector."

	faces := self subshapesOfType: self faceType as: MyFace
]

{ #category : 'inspection' }
MyShell >> topologyChildrenForInspection [

	^ faces ifNil: [ #(  ) ]
]
