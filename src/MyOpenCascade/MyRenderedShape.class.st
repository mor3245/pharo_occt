Class {
	#name : 'MyRenderedShape',
	#superclass : 'Object',
	#instVars : [
		'shape',
		'node',
		'deflection',
		'adapter'
	],
	#category : 'MyOpenCascade-Woden',
	#package : 'MyOpenCascade',
	#tag : 'Woden'
}

{ #category : 'instance creation' }
MyRenderedShape class >> shape: aShape deflection: aNumber [

	^ self new
		  shape: aShape;
		  deflection: aNumber;
		  rebuildNode;
		  yourself
]

{ #category : 'accessing' }
MyRenderedShape >> adapter [

	^ adapter
]

{ #category : 'accessing' }
MyRenderedShape >> adapter: anObject [

	adapter := anObject
]

{ #category : 'baking' }
MyRenderedShape >> bakeRotationDegrees: degrees axis: axisSymbol center: centerPoint [

	| oldNode |
	node ifNil: [ ^ MyRenderNodeChange unchanged ].

	oldNode := node.

	shape rotateDegrees: degrees aroundAxis: axisSymbol center: centerPoint.

	self rebuildNode.

	^ MyRenderNodeChange oldNode: oldNode newNode: node
]

{ #category : 'baking' }
MyRenderedShape >> bakeTranslation [

	| oldNode translation |
	node ifNil: [ ^ MyRenderNodeChange unchanged ].

	oldNode := node.
	translation := node position.

	shape translateBy: translation.
	self rebuildNode.

	^ MyRenderNodeChange oldNode: oldNode newNode: node
]

{ #category : 'boolean operations' }
MyRenderedShape >> cutWith: anotherRenderedShape [

	| resultShape |
	resultShape := shape cutWith: anotherRenderedShape shape.

	^ self class shape: resultShape deflection: deflection
]

{ #category : 'accessing' }
MyRenderedShape >> deflection [

	^ deflection
]

{ #category : 'accessing' }
MyRenderedShape >> deflection: anObject [

	deflection := anObject
]

{ #category : 'finalization' }
MyRenderedShape >> free [

	shape ifNotNil: [
			shape free.
			shape := nil ].
	node := nil
]

{ #category : 'accessing' }
MyRenderedShape >> node [

	^ node
]

{ #category : 'accessing' }
MyRenderedShape >> node: anObject [

	node := anObject
]

{ #category : 'rendering' }
MyRenderedShape >> rebuildNode [

	shape tessellateDeflection: deflection.
	node := (MyShapeWodenAdapter new asWDMesh: shape) asSceneNode.
	^ node
]

{ #category : 'accessing' }
MyRenderedShape >> shape [

	^ shape
]

{ #category : 'accessing' }
MyRenderedShape >> shape: anObject [

	shape := anObject
]
