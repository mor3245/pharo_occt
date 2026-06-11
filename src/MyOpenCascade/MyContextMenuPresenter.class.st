"
I coordinate the Spec UI, Woden scene graph, and rendered CAD shape wrappers. Clicking overlapping shapes cycles through the shapes under the cursor.
"
Class {
	#name : 'MyContextMenuPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'wodenPresenter',
		'scene',
		'cameraNode',
		'contextMenuDownPosition',
		'contextMenuWasDragged',
		'selection',
		'translationMode',
		'rotationMode',
		'renderedShapes'
	],
	#category : 'MyOpenCascade-Woden',
	#package : 'MyOpenCascade',
	#tag : 'Woden'
}

{ #category : 'geometry rotation' }
MyContextMenuPresenter >> activateRotationMode [
	"Starts interactive rotation for the selected rendered node."

	translationMode isActive ifTrue: [ translationMode confirm ].
	rotationMode activateFor: self
]

{ #category : 'geometry translation' }
MyContextMenuPresenter >> activateTranslationMode [
	"Starts interactive translation for the selected rendered node."

	rotationMode isActive ifTrue: [ rotationMode confirm ].
	translationMode activateFor: self
]

{ #category : 'rendered geometry management' }
MyContextMenuPresenter >> addBox [
	"Creates a 1×1×1 tessellated box, adds it to the Woden scene, and records the node-shape pair."

	| renderedShape |
	renderedShape := MyRenderedShape shape: (MyBoxMaker makeBoxDx: 1 dy: 1 dz: 1) deflection: 0.01.

	scene add: renderedShape node.
	renderedShapes addLast: renderedShape.

	self refreshScene
]

{ #category : 'rendered geometry management' }
MyContextMenuPresenter >> addCylinder [
	"Creates a tessellated cylinder, adds it to the Woden scene, and records the node-shape pair."

	| renderedShape |
	renderedShape := MyRenderedShape shape: (MyCylinderMaker makeCylinderRadius: 1 height: 1) deflection: 0.01.

	scene add: renderedShape node.
	renderedShapes addLast: renderedShape.

	self refreshScene
]

{ #category : 'user interface' }
MyContextMenuPresenter >> addMenuItemNamed: aString action: aBlock to: aGroup [
	"Adds a simple action item to a Spec menu group."

	aGroup addItem: [ :item |
			item
				name: aString;
				action: aBlock ]
]

{ #category : 'rendered geometry management' }
MyContextMenuPresenter >> applyRenderNodeChange: aChange [

	aChange isUnchanged ifTrue: [ ^ self ].

	scene remove: aChange oldNode.
	scene add: aChange newNode.

	self refreshScene
]

{ #category : 'geometry selection' }
MyContextMenuPresenter >> applySelectedVisualTo: aNode [
	"Highlights a selected scene node."

	selection applyVisualTo: aNode
]

{ #category : 'user interface' }
MyContextMenuPresenter >> buildContextMenu [
	"Constructs the right-click menu for scene and selected-shape actions."

	^ self newMenu
		  addGroup: [ :group |
				  self addMenuItemNamed: 'Add Box' action: [ self addBox ] to: group.
				  self addMenuItemNamed: 'Add Cylinder' action: [ self addCylinder ] to: group ];
		  addGroup: [ :group |
				  self addMenuItemNamed: 'Translate Selected' action: [ self activateTranslationMode ] to: group.
				  self addMenuItemNamed: 'Rotate Selected' action: [ self activateRotationMode ] to: group.
				  self addMenuItemNamed: 'Delete Selected' action: [ self deleteSelected ] to: group.
				  self addMenuItemNamed: 'Delete Last Inserted' action: [ self deleteLastAdded ] to: group ];
		  addGroup: [ :group |
				  self addMenuItemNamed: 'Cut Selected With Other Bodies' action: [ self cutSelectedWithOtherBodies ] to: group.
				  self addMenuItemNamed: 'Cut Other Bodies With Selected' action: [ self cutOtherBodiesWithSelected ] to: group ];
		  addGroup: [ :group |
				  self addMenuItemNamed: 'Fit All' action: [ self fitAll ] to: group.
				  self addMenuItemNamed: 'Fit Selected' action: [ self fitSelected ] to: group.
				  self addMenuItemNamed: 'Use Selected as Pivot' action: [ self useSelectedAsPivot ] to: group.
				  self addMenuItemNamed: 'Inspect Selected' action: [ self inspectSelectedShape ] to: group ];
		  yourself
]

{ #category : 'rendered geometry management' }
MyContextMenuPresenter >> buildScene [
	"Initialises a fresh WDScene containing only a point light; mesh nodes are added later on demand."

	| light lightNode |
	scene := WDScene new.

	light := WDPointLightSource new
		         intensity: 5.0;
		         yourself.
	lightNode := light asSceneNode.
	lightNode position: (Vector3 x: -1.5 y: 1.5 z: 1.0). "scene add: mesh."
	scene add: lightNode.
	^ scene
]

{ #category : 'user interface' }
MyContextMenuPresenter >> cameraControlMorph [

	^ self wodenWidget
]

{ #category : 'geometry translation' }
MyContextMenuPresenter >> cameraForwardDirection [
	"Returns the camera forward direction in world space."

	^ (self transformCameraDirection: (Vector3 x: 0 y: 0 z: -1)) normalized
]

{ #category : 'geometry rotation' }
MyContextMenuPresenter >> cancelRotationMode [
	"Restores the selected node transform to its state before rotation mode started."

	rotationMode cancel
]

{ #category : 'geometry translation' }
MyContextMenuPresenter >> cancelTranslationMode [
	"Restores the selected node to its position before grab mode started."

	translationMode cancel
]

{ #category : 'geometry selection' }
MyContextMenuPresenter >> clearSelection [
	"Restores the previously selected node's visuals and clears the selection state."

	selection clear
]

{ #category : 'geometry rotation' }
MyContextMenuPresenter >> confirmRotationMode [
	"Accepts the current rendered-node rotation and bakes it into the CAD shape."

	rotationMode confirm
]

{ #category : 'geometry translation' }
MyContextMenuPresenter >> confirmTranslationMode [
	"Accepts the current rendered-node translation."

	translationMode confirm
]

{ #category : 'event handling' }
MyContextMenuPresenter >> contextMenuDragThreshold [
	"Returns the pixel radius beyond which a right-button drag suppresses the context menu."

	^ 4
]

{ #category : 'boolean operations' }
MyContextMenuPresenter >> cutOtherBodiesWithSelected [
	"Use the selected body as the cutter and cut every other body in the scene."

	| tool targets replacements |
	self selectedRenderedShape ifNil: [ ^ self ].
	renderedShapes size < 2 ifTrue: [ ^ self ].

	self restoreSelectedVisual.

	tool := self selectedRenderedShape.
	targets := renderedShapes reject: [ :each | each == tool ].

	self applyRenderNodeChange: tool bakeTranslation.
	targets do: [ :each | self applyRenderNodeChange: each bakeTranslation ].

	replacements := OrderedCollection new.
	targets do: [ :target |
			| resultRenderedShapes |
			(target shape isNull or: [ tool shape isNull ]) ifFalse: [
					resultRenderedShapes := target cutWithSeparatedSolids: tool.
					resultRenderedShapes := resultRenderedShapes reject: [ :each | each isNil or: [ each shape isNull ] ].
					resultRenderedShapes ifNotEmpty: [ replacements add: target -> resultRenderedShapes ] ] ].

	replacements ifEmpty: [ ^ self ].

	replacements do: [ :replacement | self replaceRenderedShape: replacement key withAll: replacement value ].

	selection forget.

	self refreshScene
]

{ #category : 'boolean operations' }
MyContextMenuPresenter >> cutSelectedWithLastAdded [
	"Cut the selected shape with the last inserted shape, after baking visible translations into CAD space."

	| target tool toolChange resultRenderedShapes |
	self selectedRenderedShape ifNil: [ ^ self ].
	renderedShapes size < 2 ifTrue: [ ^ self ].

	target := self selectedRenderedShape.
	tool := renderedShapes last.

	toolChange := tool bakeTranslation.
	self applyRenderNodeChange: toolChange.

	(target shape isNull or: [ tool shape isNull ]) ifTrue: [ ^ self ].

	resultRenderedShapes := target cutWithSeparatedSolids: tool.
	resultRenderedShapes := resultRenderedShapes reject: [ :each | each isNil or: [ each shape isNull ] ].
	resultRenderedShapes ifEmpty: [ ^ self ].

	scene remove: target node.
	renderedShapes remove: target ifAbsent: [ ].
	target free.

	resultRenderedShapes do: [ :resultRenderedShape |
			scene add: resultRenderedShape node.
			renderedShapes addLast: resultRenderedShape ].

	selection forget.

	self refreshScene
]

{ #category : 'boolean operations' }
MyContextMenuPresenter >> cutSelectedWithOtherBodies [
	"Cut the selected body with all other bodies in the scene."

	| target tools resultRenderedShapes |
	self selectedRenderedShape ifNil: [ ^ self ].
	renderedShapes size < 2 ifTrue: [ ^ self ].

	self restoreSelectedVisual.

	target := self selectedRenderedShape.
	tools := renderedShapes reject: [ :each | each == target ].

	self applyRenderNodeChange: target bakeTranslation.
	tools do: [ :each | self applyRenderNodeChange: each bakeTranslation ].

	resultRenderedShapes := self cutTarget: target withTools: tools.
	resultRenderedShapes ifEmpty: [ ^ self ].

	self replaceRenderedShape: target withAll: resultRenderedShapes.

	selection forget.

	self refreshScene
]

{ #category : 'boolean operations' }
MyContextMenuPresenter >> cutTarget: targetRenderedShape withTools: toolRenderedShapes [
	"Answers rendered shapes produced by cutting targetRenderedShape by each tool in order."

	| currentShapes changed |
	currentShapes := OrderedCollection with: targetRenderedShape.
	changed := false.

	toolRenderedShapes do: [ :tool |
			| nextShapes |
			nextShapes := OrderedCollection new.
			currentShapes do: [ :target |
					| resultRenderedShapes |
					(target shape isNull or: [ tool shape isNull ])
						ifTrue: [ nextShapes add: target ]
						ifFalse: [
								resultRenderedShapes := target cutWithSeparatedSolids: tool.
								resultRenderedShapes := resultRenderedShapes reject: [ :each | each isNil or: [ each shape isNull ] ].
								resultRenderedShapes ifEmpty: [ nextShapes add: target ] ifNotEmpty: [
										changed := true.
										target == targetRenderedShape ifFalse: [ target free ].
										nextShapes addAll: resultRenderedShapes ] ] ].
			currentShapes := nextShapes ].

	changed ifFalse: [ ^ #(  ) ].

	^ currentShapes asArray
]

{ #category : 'layout' }
MyContextMenuPresenter >> defaultLayout [
	"Returns the top-to-bottom Spec layout containing the Woden presenter."

	^ SpBoxLayout newTopToBottom
		  add: wodenPresenter;
		  yourself
]

{ #category : 'rendered geometry management' }
MyContextMenuPresenter >> deleteLastAdded [
	"Removes the most recently added node from the scene and frees its C++ shape."

	| renderedShape |
	renderedShapes ifEmpty: [ ^ self ].

	renderedShape := renderedShapes removeLast.

	self selectedRenderedShape == renderedShape ifTrue: [
			self restoreSelectedVisual.
			selection forget ].

	scene remove: renderedShape node.
	renderedShape free.

	self refreshScene
]

{ #category : 'rendered geometry management' }
MyContextMenuPresenter >> deleteSelected [
	"Removes the currently selected node from the scene and frees its C++ shape."

	| renderedShape |
	renderedShape := self selectedRenderedShape.
	renderedShape ifNil: [ ^ self ].

	self restoreSelectedVisual.

	renderedShapes remove: renderedShape ifAbsent: [ ].
	scene remove: renderedShape node.
	renderedShape free.

	selection forget.

	self refreshScene
]

{ #category : 'user interface' }
MyContextMenuPresenter >> fitAll [

	self cameraControlMorph fitScene
]

{ #category : 'user interface' }
MyContextMenuPresenter >> fitSelected [

	self selectedNode ifNotNil: [ :node | self cameraControlMorph fitNode: node ]
]

{ #category : 'input event handling' }
MyContextMenuPresenter >> focusWodenWidget [
	"Requests keyboard focus so X/Y/Z/Enter work after choosing the menu item."

	| widget |
	widget := self wodenWidget.
	widget ifNil: [ ^ self ].

	widget takeKeyboardFocus
]

{ #category : 'input event handling' }
MyContextMenuPresenter >> handleKeyStroke: anEvent [

	| key |
	key := self keyStringFromEvent: anEvent.

	(rotationMode handleKey: key) ifTrue: [
			anEvent wasHandled: true.
			^ self ].

	(translationMode handleKey: key) ifTrue: [
			anEvent wasHandled: true.
			^ self ].

	key = 'r' ifFalse: [ ^ self ].
	anEvent wasHandled: true.
	self activateRotationMode.
	^ self
]

{ #category : 'event handling' }
MyContextMenuPresenter >> handleMouseDown: anEvent [
	"Handles selection, translation confirmation, and rotation confirmation."

	rotationMode isActive ifTrue: [
			anEvent redButtonPressed ifTrue: [
					anEvent wasHandled: true.
					self confirmRotationMode.
					^ self ] ].

	translationMode isActive ifTrue: [
			anEvent redButtonPressed ifTrue: [
					anEvent wasHandled: true.
					self confirmTranslationMode.
					^ self ] ].

	anEvent yellowButtonPressed ifTrue: [
			contextMenuDownPosition := anEvent position.
			contextMenuWasDragged := false ].

	anEvent redButtonPressed ifTrue: [ self selectShapeAt: anEvent position ]
]

{ #category : 'event handling' }
MyContextMenuPresenter >> handleMouseMove: anEvent [
	"Updates active transform preview, or marks right-button drags for context-menu suppression."

	rotationMode isActive ifTrue: [
			rotationMode updateAt: anEvent position.
			anEvent wasHandled: true.
			^ self ].

	translationMode isActive ifTrue: [
			translationMode updateAt: anEvent position.
			anEvent wasHandled: true.
			^ self ].

	contextMenuDownPosition ifNil: [ ^ self ].
	anEvent yellowButtonPressed ifFalse: [ ^ self ].

	(anEvent position - contextMenuDownPosition) r > self contextMenuDragThreshold ifTrue: [ contextMenuWasDragged := true ]
]

{ #category : 'event handling' }
MyContextMenuPresenter >> handleMouseUp: anEvent [
	"Shows the context menu on a right-button click that was not a drag; resets drag tracking."

	| shouldOpen |
	shouldOpen := contextMenuDownPosition notNil and: [ anEvent yellowButtonChanged and: [ contextMenuWasDragged not ] ].
	contextMenuDownPosition := nil.
	contextMenuWasDragged := false.

	shouldOpen ifFalse: [ ^ self ].
	anEvent wasHandled: true.
	^ self showContextMenuAt: anEvent position
]

{ #category : 'initialization' }
MyContextMenuPresenter >> initializePresenters [
	"Sets up mesh node collection, builds the scene, positions the camera, and wires the Woden sub-presenter."

	super initializePresenters.

	renderedShapes := OrderedCollection new.
	selection := MyContextMenuSelection on: self.
	translationMode := MyContextMenuTranslationMode new.
	rotationMode := MyContextMenuRotationMode new.
	scene := self buildScene.

	cameraNode := WDCamera new asSceneNode.
	cameraNode position: (Vector3 x: 0 y: 0 z: 3).

	wodenPresenter := self instantiate: WDSpInteractiveScenePresenter.
	wodenPresenter
		scene: scene;
		camera: cameraNode.
	scene add: ((WDPointLightSource new
			  color: (Vector3 x: 0.8 y: 0.8 z: 0.2);
			  intensity: 5.0;
			  influenceRadius: 4.0;
			  asSceneNode)
			 position: (Vector3 x: -1.5 y: 1.5 z: 1.6);
			 yourself)
]

{ #category : 'initialization' }
MyContextMenuPresenter >> initializeWindow: aWindowPresenter [
	"Sets the window title and initial size, and installs the context menu once the window opens."

	super initializeWindow: aWindowPresenter.
	aWindowPresenter
		title: 'Woden Render Area';
		initialExtent: 650 @ 500.

	aWindowPresenter whenOpenedDo: [ self setupContextMenu ]
]

{ #category : 'rendered geometry management' }
MyContextMenuPresenter >> inspectSelectedShape [
	"Opens a Pharo inspector on the currently selected rendered shape, if any."

	self selectedRenderedShape ifNotNil: [ :renderedShape | renderedShape inspect ]
]

{ #category : 'input event handling' }
MyContextMenuPresenter >> keyStringFromEvent: anEvent [
	"Normalizes common Morphic key event variants."

	^ self normalizedKeyCharacter: anEvent keyCharacter
]

{ #category : 'input event handling' }
MyContextMenuPresenter >> normalizedKeyCharacter: aCharacter [
	"Answers the key name used by the transform modes."

	aCharacter ifNil: [ ^ '' ].
	aCharacter = (Character value: 13) ifTrue: [ ^ 'return' ].
	aCharacter = (Character value: 27) ifTrue: [ ^ 'escape' ].
	aCharacter = (Character value: 8) ifTrue: [ ^ 'backspace' ].

	^ aCharacter asString asLowercase
]

{ #category : 'geometry selection' }
MyContextMenuPresenter >> normalizedScreenPosition: aPoint [
	"Converts a raw screen point to a [0,1]×[0,1] viewport coordinate with Y flipped for OpenGL convention."

	| widget localPoint widgetExtent |
	widget := self wodenWidget.
	localPoint := aPoint - widget bounds origin.
	widgetExtent := widget extent.

	^ localPoint x / widgetExtent x asFloat @ (1.0 - (localPoint y / widgetExtent y asFloat))
]

{ #category : 'user interface' }
MyContextMenuPresenter >> openWithContextMenu [
	"Opens the presenter window and ensures the context menu event hooks are installed."

	self open.
	self withWindowDo: [ :window | self setupContextMenu ]
]

{ #category : 'geometry selection' }
MyContextMenuPresenter >> rayForScreenPosition: aPoint [
	"Screen point -> normalized viewport point -> camera-space ray -> world-space ray"

	"Builds a world-space picking ray from a screen pixel position using the camera frustum."

	| widget widgetExtent aspect frustum ray |
	widget := self wodenWidget.
	widgetExtent := widget extent.
	aspect := widgetExtent x asFloat / (widgetExtent y max: 1).

	frustum := cameraNode cameras first frustumWithAspect: aspect. "Get the viewing frustum."
	ray := frustum rayForNormalizedPoint: (self normalizedScreenPosition: aPoint). "construct a picking ray relative to the viewing frustum."

	^ ray transformedWith: cameraNode transform "Convert ray position to woden/scene coordinates."
]

{ #category : 'geometry selection' }
MyContextMenuPresenter >> rayPickEntriesAt: aPoint [
	"Ray-casts against all mesh node bounding boxes and returns hit entries sorted by distance."

	| ray hits |
	ray := self rayForScreenPosition: aPoint.
	hits := OrderedCollection new.

	renderedShapes do: [ :renderedShape |
			| node box distance |
			node := renderedShape node.
			box := node localBoundingBox transformedWith: node globalTransform.
			distance := box intersectionWithRay: ray.

			distance ifNotNil: [ hits add: distance -> renderedShape ] ].

	^ (hits asSortedCollection: [ :a :b | a key < b key ]) collect: [ :each | each value ]
]

{ #category : 'user interface' }
MyContextMenuPresenter >> refreshScene [
	"Requests a redraw of the embedded Woden widget."

	self wodenWidget ifNotNil: [ :widget | widget changed ]
]

{ #category : 'boolean operations' }
MyContextMenuPresenter >> replaceRenderedShape: oldRenderedShape withAll: newRenderedShapes [
	"Replace one scene body with zero or more rendered bodies."

	scene remove: oldRenderedShape node.
	renderedShapes remove: oldRenderedShape ifAbsent: [ ].
	oldRenderedShape free.

	newRenderedShapes do: [ :newRenderedShape |
			scene add: newRenderedShape node.
			renderedShapes addLast: newRenderedShape ]
]

{ #category : 'geometry selection' }
MyContextMenuPresenter >> restoreSelectedVisual [
	"Puts the originally saved renderables back on the selected node."

	selection restoreVisual
]

{ #category : 'geometry rotation' }
MyContextMenuPresenter >> rotationDegreesPerPixel [
	"Degrees rotated per horizontal mouse pixel."

	^ 0.5
]

{ #category : 'geometry selection' }
MyContextMenuPresenter >> selectShapeAt: aPoint [
	"Picks the shape under the cursor; cycles to the next hit if the same node was already selected."

	selection selectFrom: (self rayPickEntriesAt: aPoint)
]

{ #category : 'geometry selection' }
MyContextMenuPresenter >> selectedNode [
	"Returns the scene node of the currently selected entry, or nil if nothing is selected."

	^ selection selectedNode
]

{ #category : 'geometry rotation' }
MyContextMenuPresenter >> selectedNodeRotationCenter [
	"Returns the visible world-space center of the selected rendered node."

	^ selection selectedRotationCenter
]

{ #category : 'geometry selection' }
MyContextMenuPresenter >> selectedRenderedShape [

	^ selection selectedRenderedShape
]

{ #category : 'geometry selection' }
MyContextMenuPresenter >> selectedShape [
	"Returns the MyShape of the currently selected entry, or nil if nothing is selected."

	^ selection selectedShape
]

{ #category : 'input event handling' }
MyContextMenuPresenter >> setupContextMenu [
	"Registers mouseDown, mouseMove, and mouseUp handlers on the underlying Woden widget."

	| widget |
	widget := self wodenWidget.
	widget ifNil: [ ^ self ].

	widget
		on: #mouseDown send: #handleMouseDown: to: self;
		on: #mouseMove send: #handleMouseMove: to: self;
		on: #mouseUp send: #handleMouseUp: to: self;
		on: #keyStroke send: #handleKeyStroke: to: self "If your image does not understand #keyStroke, try this instead:

	on: #keyDown send: #handleKeyStroke: to: self"
]

{ #category : 'user interface' }
MyContextMenuPresenter >> showContextMenuAt: aPoint [
	"Builds and displays the context menu at the given screen position."

	| menu |
	menu := self buildContextMenu.
	menu openWithSpecAt: aPoint
]

{ #category : 'geometry translation' }
MyContextMenuPresenter >> transformCameraDirection: aVector [
	"Transforms a direction vector using the camera transform."

	^ cameraNode transform transformVector3: aVector
]

{ #category : 'user interface' }
MyContextMenuPresenter >> useSelectedAsPivot [

	self selectedNode ifNotNil: [ :node | self cameraControlMorph useNodePivot: node ]
]

{ #category : 'user interface' }
MyContextMenuPresenter >> wodenWidget [
	"Returns the embedded Woden widget, if it has been built."

	wodenPresenter ifNil: [ ^ nil ].
	wodenPresenter adapter ifNil: [ ^ nil ].

	^ wodenPresenter adapter widget
]
