"
I am a non-parametric CAD object backed by a MyShape.

Imported BREP bodies and baked boolean results land here until we add a feature
history model.
"
Class {
	#name : 'MyCADShapeObject',
	#superclass : 'MyCADObject',
	#category : 'MyOpenCascade-Model',
	#package : 'MyOpenCascade-Model'
}

{ #category : 'metadata' }
MyCADShapeObject >> typeName [

	^ 'Shape'
]
