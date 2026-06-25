Class {
	#name : 'MyCADPrimitiveBoxObject',
	#superclass : 'MyCADObject',
	#instVars : [
		'dimensions'
	],
	#category : 'MyOpenCascade-Model',
	#package : 'MyOpenCascade-Model'
}

{ #category : 'instance creation' }
MyCADPrimitiveBoxObject class >> renderedShape: aRenderedShape dimensions: dimensionsVector [

	^ (self renderedShape: aRenderedShape)
		  dimensions: dimensionsVector;
		  yourself
]

{ #category : 'accessing' }
MyCADPrimitiveBoxObject >> dimensions [

	^ dimensions ifNil: [ dimensions := Vector3 x: 1 y: 1 z: 1 ]
]

{ #category : 'accessing' }
MyCADPrimitiveBoxObject >> dimensions: aVector [

	dimensions := aVector
]

{ #category : 'metadata' }
MyCADPrimitiveBoxObject >> editableDimensionLabels [

	^ #( 'Length' 'Width' 'Height' )
]

{ #category : 'metadata' }
MyCADPrimitiveBoxObject >> editableDimensions [

	^ self dimensions
]

{ #category : 'testing' }
MyCADPrimitiveBoxObject >> hasEditableDimensions [

	^ true
]

{ #category : 'editing' }
MyCADPrimitiveBoxObject >> resizeToDimensions: aVector [

	| newShape |
	dimensions := aVector.
	newShape := MyBoxMaker
		            makeBoxDx: aVector x
		            dy: aVector y
		            dz: aVector z
		            named: self name.

	^ self renderedShape replaceShapeWith: newShape
]

{ #category : 'metadata' }
MyCADPrimitiveBoxObject >> typeName [

	^ 'Box'
]
