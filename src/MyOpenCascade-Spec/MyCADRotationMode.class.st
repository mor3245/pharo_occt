Class {
	#name : 'MyCADRotationMode',
	#superclass : 'Object',
	#instVars : [
		'presenter',
		'active',
		'startMousePosition',
		'startNodeTransform',
		'axisLock',
		'typedDegreesString',
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

	change := selectedRenderedShape bakeTranslation.
	presenter applyRenderNodeChange: change.

	active := true.
	startMousePosition := nil.
	startNodeTransform := selectedRenderedShape node transform copy.
	startCenter := presenter selectedNodeRotationCenter.
	axisLock := #z.
	typedDegreesString := ''.
	currentDegrees := 0.

	presenter focusWodenWidget
]

{ #category : 'keyboard' }
MyCADRotationMode >> appendTypedCharacter: key [
	"Accumulates typed numeric degrees and applies them immediately."

	| degrees |
	(self isNumericKey: key) ifFalse: [ ^ self ].

	typedDegreesString := typedDegreesString , key.

	degrees := [ typedDegreesString asNumber ]
		           on: Error
		           do: [ ^ self ].

	self applyDegrees: degrees
]

{ #category : 'applying' }
MyCADRotationMode >> applyDegrees: degrees [
	"Applies the given rotation angle around the selected object's visible center."

	| selectedRenderedShape node startPosition startOffset rotatedOffset newPosition |
	selectedRenderedShape := presenter selectedRenderedShape.
	selectedRenderedShape ifNil: [ ^ self ].
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
		startNodeTransform ifNotNil: [ selectedRenderedShape node transform: startNodeTransform copy ] ].

	self reset.
	presenter refreshScene
]

{ #category : 'activation' }
MyCADRotationMode >> confirm [
	"Accepts the current rendered-node rotation and bakes it into the CAD shape."

	| selectedRenderedShape change |
	self isActive ifFalse: [ ^ self ].

	selectedRenderedShape := presenter selectedRenderedShape.
	(selectedRenderedShape notNil and: [ currentDegrees ~= 0 ]) ifTrue: [
			presenter restoreSelectedVisual.

			change := selectedRenderedShape bakeRotationDegrees: currentDegrees axis: axisLock center: startCenter.

			presenter applyRenderNodeChange: change.
			presenter applySelectedVisualTo: selectedRenderedShape node ].

	self reset.
	presenter refreshScene
]

{ #category : 'keyboard' }
MyCADRotationMode >> handleAxisKey: key [
	"Handles X/Y/Z axis lock keys."

	(#( 'x' 'y' 'z' ) includes: key) ifFalse: [ ^ false ].

	self setAxisLock: key asSymbol.
	^ true
]

{ #category : 'keyboard' }
MyCADRotationMode >> handleCancellationKey: key [
	"Handles rotation cancellation keys."

	key = 'escape' ifFalse: [ ^ false ].

	self cancel.
	^ true
]

{ #category : 'keyboard' }
MyCADRotationMode >> handleCompletionKey: key [

	(#( 'enter' 'return' ) includes: key) ifFalse: [ ^ false ].
	self confirm.
	^ true
]

{ #category : 'keyboard' }
MyCADRotationMode >> handleDeletionKey: key [
	"Handles deletion of typed rotation degrees."

	(key = 'backspace' or: [ key = (Character value: 8) asString ]) ifFalse: [ ^ false ].

	self removeLastTypedCharacter.
	^ true
]

{ #category : 'keyboard' }
MyCADRotationMode >> handleKey: key [
	"Handles a normalized key string. Answers whether the key was consumed."

	self isActive ifFalse: [ ^ false ].

	(self handleAxisKey: key) ifTrue: [ ^ true ].
	(self handleCompletionKey: key) ifTrue: [ ^ true ].
	(self handleCancellationKey: key) ifTrue: [ ^ true ].
	(self handleDeletionKey: key) ifTrue: [ ^ true ].
	(self handleNumericKey: key) ifTrue: [ ^ true ].

	^ false
]

{ #category : 'keyboard' }
MyCADRotationMode >> handleNumericKey: key [
	"Handles numeric rotation degree input."

	(self isNumericKey: key) ifFalse: [ ^ false ].

	self appendTypedCharacter: key.
	^ true
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

{ #category : 'keyboard' }
MyCADRotationMode >> isNumericKey: key [
	"Answers whether key can be part of a typed degree number."

	key size = 1 ifFalse: [ ^ false ].

	key first isDigit ifTrue: [ ^ true ].
	key = '-' ifTrue: [ ^ typedDegreesString isEmpty ].
	key = '.' ifTrue: [ ^ (typedDegreesString includes: $.) not ].

	^ false
]

{ #category : 'keyboard' }
MyCADRotationMode >> removeLastTypedCharacter [
	"Deletes the last typed degree character and reapplies the value."

	| degrees |
	typedDegreesString isEmpty ifTrue: [ ^ self ].

	typedDegreesString := typedDegreesString copyFrom: 1 to: typedDegreesString size - 1.

	typedDegreesString isEmpty ifTrue: [
			self applyDegrees: 0.
			^ self ].

	degrees := [ typedDegreesString asNumber ]
		           on: Error
		           do: [ ^ self ].

	self applyDegrees: degrees
]

{ #category : 'initialization' }
MyCADRotationMode >> reset [
	"Clears transient rotation-mode state."

	active := false.
	startMousePosition := nil.
	startNodeTransform := nil.
	startCenter := nil.
	axisLock := nil.
	typedDegreesString := ''.
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

{ #category : 'geometry' }
MyCADRotationMode >> rotationDegreesPerPixel [
	"Degrees rotated per horizontal mouse pixel."

	^ 0.5
]

{ #category : 'keyboard' }
MyCADRotationMode >> setAxisLock: aSymbol [
	"Sets the global rotation axis and reapplies the current angle."

	axisLock := aSymbol.
	self applyDegrees: currentDegrees
]

{ #category : 'mouse' }
MyCADRotationMode >> updateAt: aPoint [
	"Updates selected rendered-node rotation from mouse movement."

	| delta degrees |
	presenter selectedRenderedShape ifNil: [ ^ self ].

	startMousePosition ifNil: [ startMousePosition := aPoint ].
	typedDegreesString isEmpty ifFalse: [ ^ self ].

	delta := aPoint - startMousePosition.
	degrees := delta x * self rotationDegreesPerPixel.

	self applyDegrees: degrees
]
