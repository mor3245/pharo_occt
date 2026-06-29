Class {
	#name : 'MyCADRotationMode',
	#superclass : 'Object',
	#instVars : [
		'presenter',
		'active',
		'startNodeTransform',
		'axisLock',
		'currentDegrees',
		'startCenter'
	],
	#category : 'MyOpenCascade-Spec',
	#package : 'MyOpenCascade-Spec'
}

{ #category : 'activation' }
MyCADRotationMode >> activateFor: aPresenter [
	"Starts interactive rotation for the selected rendered node, around its visible center."

	| change selectedRenderedShape |
	presenter := aPresenter.
	selectedRenderedShape := presenter selectedRenderedShape.
	selectedRenderedShape ifNil: [ ^ self ].
	selectedRenderedShape isAlive ifFalse: [ ^ self ].

	presenter restoreSelectedVisual.
	change := selectedRenderedShape bakeTranslation.
	presenter applyRenderNodeChange: change.
	presenter applySelectedVisualTo: selectedRenderedShape node.

	active := true.
	startNodeTransform := selectedRenderedShape node transform copy.
	startCenter := presenter selectedNodeRotationCenter.
	axisLock := #z.
	currentDegrees := 0.

	presenter focusWodenWidget
]

{ #category : 'applying' }
MyCADRotationMode >> applyDegrees: degrees [
	"Applies the given rotation angle around the selected object's visible center."

	| selectedRenderedShape node startPosition startOffset rotatedOffset newPosition |
	selectedRenderedShape := presenter selectedRenderedShape.
	selectedRenderedShape ifNil: [ ^ self ].
	selectedRenderedShape isAlive ifFalse: [ ^ self ].
	startNodeTransform ifNil: [ ^ self ].
	startCenter ifNil: [ ^ self ].

	node := selectedRenderedShape node.

	node transform: startNodeTransform copy.

	startPosition := node position.
	startOffset := startPosition - startCenter.
	rotatedOffset := self rotateVector: startOffset degrees: degrees axis: axisLock.
	newPosition := startCenter + rotatedOffset.

	node position: newPosition.

	axisLock = #x ifTrue: [ node rotateDegreesOnX: degrees ].
	axisLock = #y ifTrue: [ node rotateDegreesOnY: degrees ].
	axisLock = #z ifTrue: [ node rotateDegreesOnZ: degrees ].

	currentDegrees := degrees.
	presenter refreshScene
]

{ #category : 'activation' }
MyCADRotationMode >> cancel [
	"Restores the selected node transform to its state before rotation mode started."

	self isActive ifFalse: [ ^ self ].

	presenter selectedRenderedShape ifNotNil: [ :selectedRenderedShape |
			(selectedRenderedShape isAlive and: [ self hasCurrentRotation ]) ifTrue: [
				selectedRenderedShape node transform: startNodeTransform copy ] ].

	self reset.
	presenter refreshScene.
	presenter transformModeChanged: #none
]

{ #category : 'activation' }
MyCADRotationMode >> confirm [
	"Accepts the current rendered-node rotation and bakes it into the CAD shape."

	| selectedRenderedShape change |
	self isActive ifFalse: [ ^ self ].

	selectedRenderedShape := presenter selectedRenderedShape.
	(selectedRenderedShape notNil and: [ self hasCurrentRotation ]) ifTrue: [
			presenter restoreSelectedVisual.

			change := selectedRenderedShape bakeRotationDegrees: currentDegrees axis: axisLock center: startCenter.
			presenter applyRenderNodeChange: change.
			presenter applySelectedVisualTo: selectedRenderedShape node ].

	self reset.
	presenter refreshScene.
	presenter transformModeChanged: #none
]

{ #category : 'testing' }
MyCADRotationMode >> hasCurrentRotation [

	^ currentDegrees ~= 0
]

{ #category : 'initialization' }
MyCADRotationMode >> initialize [

	super initialize.
	self reset
]

{ #category : 'testing' }
MyCADRotationMode >> isActive [

	^ active
]

{ #category : 'applying' }
MyCADRotationMode >> previewDegrees: degreesVector [
	"Previews the single active X/Y/Z degree value from the transform panel."

	degreesVector x ~= 0 ifTrue: [
			axisLock := #x.
			^ self applyDegrees: degreesVector x ].
	degreesVector y ~= 0 ifTrue: [
			axisLock := #y.
			^ self applyDegrees: degreesVector y ].
	degreesVector z ~= 0 ifTrue: [
			axisLock := #z.
			^ self applyDegrees: degreesVector z ].

	self applyDegrees: 0
]

{ #category : 'initialization' }
MyCADRotationMode >> reset [
	"Clears transient rotation-mode state."

	active := false.
	startNodeTransform := nil.
	startCenter := nil.
	axisLock := nil.
	currentDegrees := 0
]

{ #category : 'geometry' }
MyCADRotationMode >> rotateVector: aVector degrees: degrees axis: axisSymbol [
	"Rotates aVector around a global axis."

	| radians c s x y z |
	radians := degrees * Float pi / 180.0.
	c := radians cos.
	s := radians sin.

	x := aVector x.
	y := aVector y.
	z := aVector z.

	axisSymbol = #x ifTrue: [ ^ Vector3 x: x y: y * c - (z * s) z: y * s + (z * c) ].

	axisSymbol = #y ifTrue: [ ^ Vector3 x: x * c + (z * s) y: y z: z * c - (x * s) ].

	axisSymbol = #z ifTrue: [ ^ Vector3 x: x * c - (y * s) y: x * s + (y * c) z: z ].

	^ aVector
]

{ #category : 'applying' }
MyCADRotationMode >> setAxisLock: aSymbol [
	"Sets the global rotation axis and reapplies the current angle."

	axisLock := aSymbol.
	self applyDegrees: currentDegrees
]

{ #category : 'mouse' }
MyCADRotationMode >> updateAt: aPoint [
	"Mouse-drag rotation is intentionally disabled.
	Rotation is edited through the transform panel's X/Y/Z degree fields and committed with OK."

	^ self
]
