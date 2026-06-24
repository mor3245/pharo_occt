"
I am a document-level CAD object.

I represent what an item means in the CAD document. The current implementation
keeps a MyRenderedShape bridge so the existing Woden viewport can keep working
while presenters migrate away from using MyRenderedShape directly.
"
Class {
	#name : 'MyCADObject',
	#superclass : 'Object',
	#instVars : [
		'renderedShape'
	],
	#category : 'MyOpenCascade-Model',
	#package : 'MyOpenCascade-Model'
}

{ #category : 'instance creation' }
MyCADObject class >> renderedShape: aRenderedShape [

	^ self new
		  renderedShape: aRenderedShape;
		  yourself
]

{ #category : 'metadata' }
MyCADObject >> displayPosition [

	^ renderedShape displayPosition
]

{ #category : 'metadata' }
MyCADObject >> editableDimensionLabels [
	"Answers the user-facing dimension fields this object exposes.
	Generic CAD objects expose none; primitive feature objects can override this."

	^ #(  )
]

{ #category : 'metadata' }
MyCADObject >> editableDimensions [
	"Answers the current dimension values used by the editable dimension fields.
	Only meaningful when #editableDimensionLabels is not empty."

	^ Vector3 x: 0 y: 0 z: 0
]

{ #category : 'testing' }
MyCADObject >> isAlive [

	^ renderedShape notNil and: [ renderedShape isAlive ]
]

{ #category : 'accessing' }
MyCADObject >> name [

	^ renderedShape ifNil: [ '<released object>' ] ifNotNil: [ renderedShape name ]
]

{ #category : 'accessing' }
MyCADObject >> renderedShape [

	^ renderedShape
]

{ #category : 'accessing' }
MyCADObject >> renderedShape: aRenderedShape [

	renderedShape := aRenderedShape
]

{ #category : 'editing' }
MyCADObject >> resizeToDimensions: aVector [

	^ MyRenderNodeChange unchanged
]

{ #category : 'accessing' }
MyCADObject >> shape [

	^ renderedShape ifNil: [ nil ] ifNotNil: [ renderedShape shape ]
]

{ #category : 'metadata' }
MyCADObject >> triangleCount [

	^ self shape ifNil: [ 0 ] ifNotNil: [ :aShape | aShape triangleCount ]
]

{ #category : 'metadata' }
MyCADObject >> typeName [

	^ self class name
]

{ #category : 'metadata' }
MyCADObject >> vertexCount [

	^ self shape ifNil: [ 0 ] ifNotNil: [ :aShape | aShape vertexCount ]
]
