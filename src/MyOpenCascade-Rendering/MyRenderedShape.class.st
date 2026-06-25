"
I bridge an OCCT MyShape to its current Woden scene node.

I own transient rendering state: the native shape handle, tessellation
deflection, accumulated display placement, and the Woden node built from the
shape. Document semantics such as primitive dimensions, type names, materials,
or user-facing properties belong in MyCADObject subclasses, not here.
"
Class {
	#name : 'MyRenderedShape',
	#superclass : 'Object',
	#instVars : [
		'shape',
		'node',
		'deflection',
		'placementPosition'
	],
	#category : 'MyOpenCascade-Rendering',
	#package : 'MyOpenCascade-Rendering'
}

{ #category : 'instance creation' }
MyRenderedShape class >> shape: aShape deflection: aNumber [

	^ self new
		  shape: aShape;
		  deflection: aNumber;
		  rebuildNode;
		  yourself
]

{ #category : 'baking' }
MyRenderedShape >> bakeRotationDegrees: degrees axis: axisSymbol center: centerPoint [

	| oldNode |
	self isAlive ifFalse: [ ^ MyRenderNodeChange unchanged ].


	oldNode := node.

	shape rotateDegrees: degrees aroundAxis: axisSymbol center: centerPoint.

	self rebuildNode.

	^ MyRenderNodeChange oldNode: oldNode newNode: node
]

{ #category : 'baking' }
MyRenderedShape >> bakeTranslation [

	| oldNode translation |
	self isAlive ifFalse: [ ^ MyRenderNodeChange unchanged ].


	oldNode := node.
	translation := node position.
	placementPosition := self placementPosition + translation.

	shape translateBy: translation.
	self rebuildNode.

	^ MyRenderNodeChange oldNode: oldNode newNode: node
]

{ #category : 'boolean operations' }
MyRenderedShape >> cutWithSeparatedSolids: anotherRenderedShape [
	"Answer one rendered shape per OCCT solid produced by the cut."

	^ (shape cutWithSeparatedSolids: anotherRenderedShape shape) collect: [ :each | self class shape: each deflection: deflection ]
]

{ #category : 'accessing' }
MyRenderedShape >> deflection: anObject [

	deflection := anObject
]

{ #category : 'accessing' }
MyRenderedShape >> displayPosition [
	"Answers the committed placement plus any current preview node offset."

	^ self placementPosition + (node ifNil: [ Vector3 x: 0 y: 0 z: 0 ] ifNotNil: [ node position ])
]

{ #category : 'finalization' }
MyRenderedShape >> free [

	shape ifNotNil: [
			shape free.
			shape := nil ].
	node := nil
]

{ #category : 'testing' }
MyRenderedShape >> isAlive [
	"Answers whether this wrapper still owns a usable rendered/native shape."

	^ shape notNil and: [ node notNil ]
]

{ #category : 'accessing' }
MyRenderedShape >> name [

	shape ifNil: [ ^ '<released shape>' ].
	^ shape name asString
]

{ #category : 'accessing' }
MyRenderedShape >> node [

	^ node
]

{ #category : 'accessing' }
MyRenderedShape >> placementPosition [
	"Answers accumulated committed translation. Existing instances from older images default to zero."

	placementPosition ifNil: [ placementPosition := Vector3 x: 0 y: 0 z: 0 ].
	^ placementPosition
]

{ #category : 'inspection' }
MyRenderedShape >> prepareForInspection [
		"Refreshes cached shape topology so the raw inspector can expand useful fields."

	shape ifNotNil: [
		shape hasTopologyInspectionData ifFalse: [
			shape refreshTopologyForInspection ] ].
	^ self
]

{ #category : 'rendering' }
MyRenderedShape >> rebuildNode [

	| renderStyle shapeAdapter |
	shape tessellateDeflection: deflection.
	renderStyle := MyWodenRenderStyle default.
	shapeAdapter := MyShapeWodenAdapter renderStyle: renderStyle.
	node := shapeAdapter asWDDisplayNode: shape edgeDeflection: (renderStyle edgeDeflectionFor: deflection).
	^ node
]

{ #category : 'accessing' }
MyRenderedShape >> renameTo: aString [

	shape renameTo: aString
]

{ #category : 'editing' }
MyRenderedShape >> replaceShapeWith: aShape [
	"Replaces the native CAD shape and rebuilds the render node, preserving accumulated placement."

	| oldNode oldShape |
	(aShape isNil or: [ self isAlive not ]) ifTrue: [
			aShape ifNotNil: [ aShape free ].
			^ MyRenderNodeChange unchanged ].

	oldNode := node.
	oldShape := shape.
	self placementPosition = (Vector3 x: 0 y: 0 z: 0) ifFalse: [ aShape translateBy: self placementPosition ].
	shape := aShape.
	self rebuildNode.

	oldShape ifNotNil: [ oldShape free ].
	^ MyRenderNodeChange oldNode: oldNode newNode: node
]

{ #category : 'accessing' }
MyRenderedShape >> shape [

	^ shape
]

{ #category : 'accessing' }
MyRenderedShape >> shape: anObject [

	shape := anObject
]
