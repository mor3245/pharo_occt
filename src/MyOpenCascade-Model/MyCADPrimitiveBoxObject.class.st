Class {
	#name : 'MyCADPrimitiveBoxObject',
	#superclass : 'MyCADObject',
	#category : 'MyOpenCascade-Model',
	#package : 'MyOpenCascade-Model'
}

{ #category : 'metadata' }
MyCADPrimitiveBoxObject >> editableDimensionLabels [

	^ #( 'Length' 'Width' 'Height' )
]

{ #category : 'metadata' }
MyCADPrimitiveBoxObject >> editableDimensions [

	^ self renderedShape boxDimensions
]

{ #category : 'metadata' }
MyCADPrimitiveBoxObject >> typeName [

	^ 'Box'
]
