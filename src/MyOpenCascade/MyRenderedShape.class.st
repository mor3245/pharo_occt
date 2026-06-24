Class {
	#name : 'MyRenderedShape',
	#superclass : 'Object',
	#instVars : [
		'shape',
		'node',
		'deflection',
		'adapter',
		'placementPosition',
		'primitiveKind',
		'boxDimensions',
		'renderStyle'
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
	placementPosition := self placementPosition + translation.

	shape translateBy: translation.
	self rebuildNode.

	^ MyRenderNodeChange oldNode: oldNode newNode: node
]

{ #category : 'metadata' }
MyRenderedShape >> beBoxDx: dx dy: dy dz: dz [

	primitiveKind := #box.
	boxDimensions := Vector3 x: dx y: dy z: dz
]

{ #category : 'metadata' }
MyRenderedShape >> boxDimensions [

	^ boxDimensions ifNil: [ Vector3 x: 0 y: 0 z: 0 ]
]

{ #category : 'boolean operations' }
MyRenderedShape >> cutWith: anotherRenderedShape [

	| resultShape |
	resultShape := shape cutWith: anotherRenderedShape shape.

	^ self class shape: resultShape deflection: deflection
]

{ #category : 'boolean operations' }
MyRenderedShape >> cutWithSeparatedSolids: anotherRenderedShape [
	"Answer one rendered shape per OCCT solid produced by the cut."

	^ (shape cutWithSeparatedSolids: anotherRenderedShape shape) collect: [ :each | self class shape: each deflection: deflection ]
]

{ #category : 'accessing' }
MyRenderedShape >> deflection [

	^ deflection
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

{ #category : 'testing' }
MyRenderedShape >> isBox [

	^ primitiveKind = #box
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
MyRenderedShape >> node: anObject [

	node := anObject
]

{ #category : 'accessing' }
MyRenderedShape >> placementPosition [
	"Answers accumulated committed translation. Existing instances from older images default to zero."

	placementPosition ifNil: [ placementPosition := Vector3 x: 0 y: 0 z: 0 ].
	^ placementPosition
]

{ #category : 'accessing' }
MyRenderedShape >> placementPosition: aVector [

	placementPosition := aVector
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

	shape tessellateDeflection: deflection.
	adapter := MyShapeWodenAdapter renderStyle: self renderStyle.
	node := adapter asWDDisplayNode: shape edgeDeflection: (self renderStyle edgeDeflectionFor: deflection).
	^ node
]

{ #category : 'accessing' }
MyRenderedShape >> renameTo: aString [

	shape renameTo: aString
]

{ #category : 'accessing' }
MyRenderedShape >> renderStyle [

	^ renderStyle ifNil: [ renderStyle := MyWodenRenderStyle default ]
]

{ #category : 'accessing' }
MyRenderedShape >> renderStyle: aRenderStyle [

	renderStyle := aRenderStyle
]

{ #category : 'editing' }
MyRenderedShape >> resizeBoxDx: dx dy: dy dz: dz [
	"Rebuilds this rendered box with new dimensions, preserving display name and accumulated placement."

	| oldNode oldShape newShape |
	self isBox ifFalse: [ ^ MyRenderNodeChange unchanged ].
	node ifNil: [ ^ MyRenderNodeChange unchanged ].

	oldNode := node.
	oldShape := shape.
	newShape := MyBoxMaker
		            makeBoxDx: dx
		            dy: dy
		            dz: dz
		            named: oldShape name.
	self placementPosition = (Vector3 x: 0 y: 0 z: 0) ifFalse: [ newShape translateBy: self placementPosition ].
	shape := newShape.
	boxDimensions := Vector3 x: dx y: dy z: dz.
	self rebuildNode.

	oldShape free.
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
