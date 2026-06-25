Class {
	#name : 'MyCADPrimitiveCylinderObject',
	#superclass : 'MyCADObject',
	#category : 'MyOpenCascade-Model',
	#package : 'MyOpenCascade-Model'
}

{ #category : 'metadata' }
MyCADPrimitiveCylinderObject >> editableDimensionLabels [

	^ #( 'Radius' 'Height' )
]

{ #category : 'metadata' }
MyCADPrimitiveCylinderObject >> editableDimensions [

	^ self renderedShape cylinderDimensions
]

{ #category : 'editing' }
MyCADPrimitiveCylinderObject >> resizeToDimensions: aVector [

	^ self renderedShape resizeCylinderRadius: aVector x height: aVector y
]

{ #category : 'metadata' }
MyCADPrimitiveCylinderObject >> typeName [

	^ 'Cylinder'
]
