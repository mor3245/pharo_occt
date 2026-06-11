Class {
	#name : 'MyVertex',
	#superclass : 'MyShape',
	#category : 'MyOpenCascade-Base',
	#package : 'MyOpenCascade',
	#tag : 'Base'
}

{ #category : 'inspection' }
MyVertex >> refreshTopologyChildrenForInspection [
	"Vertices do not contain lower topology nodes."

	^ self
]
