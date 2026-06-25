Class {
	#name : 'MyCADPrimitiveCylinderObject',
	#superclass : 'MyCADObject',
	#instVars : [
		'radius',
		'height'
	],
	#category : 'MyOpenCascade-Model',
	#package : 'MyOpenCascade-Model'
}

{ #category : 'instance creation' }
MyCADPrimitiveCylinderObject class >> renderedShape: aRenderedShape radius: radiusValue height: heightValue [

	^ (self renderedShape: aRenderedShape)
		  radius: radiusValue;
		  height: heightValue;
		  yourself
]

{ #category : 'metadata' }
MyCADPrimitiveCylinderObject >> editableDimensionLabels [

	^ #( 'Radius' 'Height' )
]

{ #category : 'metadata' }
MyCADPrimitiveCylinderObject >> editableDimensions [

	^ Vector3 x: self radius y: self height z: 0
]

{ #category : 'testing' }
MyCADPrimitiveCylinderObject >> hasEditableDimensions [

	^ true
]

{ #category : 'accessing' }
MyCADPrimitiveCylinderObject >> height [

	^ height ifNil: [ height := 1 ]
]

{ #category : 'accessing' }
MyCADPrimitiveCylinderObject >> height: aNumber [

	height := aNumber
]

{ #category : 'accessing' }
MyCADPrimitiveCylinderObject >> radius [

	^ radius ifNil: [ radius := 1 ]
]

{ #category : 'accessing' }
MyCADPrimitiveCylinderObject >> radius: aNumber [

	radius := aNumber
]

{ #category : 'editing' }
MyCADPrimitiveCylinderObject >> resizeToDimensions: aVector [

	| newShape |
	radius := aVector x.
	height := aVector y.
	newShape := MyCylinderMaker makeCylinderRadius: radius height: height named: self name.

	^ self renderedShape replaceShapeWith: newShape
]

{ #category : 'metadata' }
MyCADPrimitiveCylinderObject >> typeName [

	^ 'Cylinder'
]
