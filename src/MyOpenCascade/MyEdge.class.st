Class {
	#name : 'MyEdge',
	#superclass : 'MyShape',
	#category : 'MyOpenCascade-Base',
	#package : 'MyOpenCascade',
	#tag : 'Base'
}

{ #category : 'inspection' }
MyEdge >> refreshTopologyChildrenForInspection [
	"Populates the vertices contained in this edge for the raw inspector."

	topologicalVertices := self subshapesOfType: self vertexType as: MyVertex
]

{ #category : 'inspection' }
MyEdge >> topologyChildrenForInspection [

	^ topologicalVertices ifNil: [ #(  ) ]
]

{ #category : 'accessing' }
MyEdge >> vertices [
	"Answers the unique vertices contained in this edge."

	^ self topologicalVertices
]
