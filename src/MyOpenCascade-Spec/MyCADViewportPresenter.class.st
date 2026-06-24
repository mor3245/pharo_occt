"
I coordinate the Spec UI, Woden scene graph, and rendered CAD shape wrappers. Clicking overlapping shapes cycles through the shapes under the cursor.
"
Class {
	#name : 'MyCADViewportPresenter',
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
		'cadDocument',
		'renderedShapes',
		'geometryChangedAction',
		'selectionChangedAction',
		'transformModeChangedAction',
		'visualChangedAction',
		'contextMenuWidget'
	],
	#category : 'MyOpenCascade-Spec',
	#package : 'MyOpenCascade-Spec'
}

{ #category : 'transform modes - rotation' }
MyCADViewportPresenter >> activateRotationMode [
	"Starts interactive rotation for the selected rendered node."

	translationMode isActive ifTrue: [ translationMode confirm ].
	rotationMode activateFor: self
]

{ #category : 'transform modes - translation' }
MyCADViewportPresenter >> activateTranslationMode [
	"Starts interactive translation for the selected rendered node."

	rotationMode isActive ifTrue: [ rotationMode confirm ].
	translationMode activateFor: self.
	translationMode isActive ifTrue: [ self transformModeChanged: #translation ]
]

{ #category : 'actions - creation' }
MyCADViewportPresenter >> addBox [
	"Creates a 1×1×1 tessellated box, adds it to the Woden scene, and records the node-shape pair."

	| renderedShape |
	renderedShape := MyRenderedShape
		                 shape: (MyBoxMaker
				                  makeBoxDx: 1
				                  dy: 1
				                  dz: 1
				                  named: (self nextAvailableNameFor: 'Box'))
		                 deflection: 0.01.
	renderedShape beBoxDx: 1 dy: 1 dz: 1.

	self addRenderedShape: renderedShape asCADObject: MyCADPrimitiveBoxObject.

	self geometryChanged
]

{ #category : 'actions - creation' }
MyCADViewportPresenter >> addCylinder [
	"Creates a tessellated cylinder, adds it to the Woden scene, and records the node-shape pair."

	| renderedShape |
	renderedShape := MyRenderedShape
		                 shape: (MyCylinderMaker makeCylinderRadius: 1 height: 1 named: (self nextAvailableNameFor: 'Cylinder'))
		                 deflection: 0.01.

	self addRenderedShape: renderedShape asCADObject: MyCADPrimitiveCylinderObject.

	self geometryChanged
]

{ #category : 'context menu - building' }
MyCADViewportPresenter >> addMenuItemNamed: aString action: aBlock to: aGroup [
	"Adds a simple action item to a Spec menu group."

	aGroup addItem: [ :item |
			item
				name: aString;
				action: aBlock ]
]

{ #category : 'scene - geometry management' }
MyCADViewportPresenter >> addRenderedShape: aRenderedShape asCADObject: cadObjectClass [
	"Adds a rendered shape to the scene and creates the document object that owns it."

	scene add: aRenderedShape node.
	renderedShapes addLast: aRenderedShape.
	self cadDocument addObject: (cadObjectClass renderedShape: aRenderedShape)
]

{ #category : 'actions - file' }
MyCADViewportPresenter >> addShapeFromFile: aFileReference [
	"Explicitly imports one BREP file into the current in-memory scene."

	| renderedShape |
	renderedShape := MyRenderedShape shape: (MyShape loadFromFile: aFileReference) deflection: 0.01.

	self addRenderedShape: renderedShape asCADObject: MyCADShapeObject.
	self geometryChanged
]

{ #category : 'scene - updating' }
MyCADViewportPresenter >> applyRenderNodeChange: aChange [

	aChange isUnchanged ifTrue: [ ^ self ].

	scene remove: aChange oldNode.
	scene add: aChange newNode.

	self refreshScene
]

{ #category : 'selection - highlighting' }
MyCADViewportPresenter >> applySelectedVisualTo: aNode [
	"Highlights a selected scene node."

	selection applyVisualTo: aNode
]

{ #category : 'context menu - building' }
MyCADViewportPresenter >> buildBooleanMenuGroup: aGroup [
	"Adds boolean operation actions to a menu group."

	self addMenuItemNamed: 'Cut Selected With Other Bodies' action: [ self cutSelectedWithOtherBodies ] to: aGroup.
	self addMenuItemNamed: 'Cut Other Bodies With Selected' action: [ self cutOtherBodiesWithSelected ] to: aGroup
]

{ #category : 'context menu - building' }
MyCADViewportPresenter >> buildContextMenu [
	"Constructs the right-click menu for scene and selected-shape actions."

	^ self newMenu
		  addGroup: [ :group | self buildCreationMenuGroup: group ];
		  addGroup: [ :group | self buildSelectionMenuGroup: group ];
		  addGroup: [ :group | self buildBooleanMenuGroup: group ];
		  addGroup: [ :group | self buildViewMenuGroup: group ];
		  yourself
]

{ #category : 'context menu - building' }
MyCADViewportPresenter >> buildCreationMenuGroup: aGroup [
	"Adds shape creation actions to a menu group."

	self addMenuItemNamed: 'Add Box' action: [ self addBox ] to: aGroup.
	self addMenuItemNamed: 'Add Cylinder' action: [ self addCylinder ] to: aGroup
]

{ #category : 'scene building' }
MyCADViewportPresenter >> buildScene [
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

{ #category : 'context menu - building' }
MyCADViewportPresenter >> buildSelectionMenuGroup: aGroup [
	"Adds selected-shape editing actions to a menu group."

	self addMenuItemNamed: 'Translate Selected' action: [ self activateTranslationMode ] to: aGroup.
	self addMenuItemNamed: 'Rotate Selected' action: [ self activateRotationMode ] to: aGroup.
		self addMenuItemNamed: 'Rename Selected' action: [ self renameSelectedShape ] to: aGroup.
	self addMenuItemNamed: 'Delete Selected' action: [ self deleteSelected ] to: aGroup.
	self addMenuItemNamed: 'Delete Last Inserted' action: [ self deleteLastAdded ] to: aGroup
]

{ #category : 'context menu - building' }
MyCADViewportPresenter >> buildViewMenuGroup: aGroup [
	"Adds camera and inspection actions to a menu group."

	self addMenuItemNamed: 'Fit All' action: [ self fitAll ] to: aGroup.
	self addMenuItemNamed: 'Fit Selected' action: [ self fitSelected ] to: aGroup.
	self addMenuItemNamed: 'Use Selected as Pivot' action: [ self useSelectedAsPivot ] to: aGroup.
	self addMenuItemNamed: 'Inspect Selected' action: [ self inspectSelectedShape ] to: aGroup
]

{ #category : 'geometry - accessing' }
MyCADViewportPresenter >> cadDocument [
	"Answers the document model, lazily creating it for old live presenters after code reload."

	cadDocument ifNil: [
			cadDocument := MyCADDocument new.
			renderedShapes ifNotNil: [
					renderedShapes do: [ :renderedShape |
							cadDocument addObject: ((renderedShape isBox
									  ifTrue: [ MyCADPrimitiveBoxObject ]
									  ifFalse: [ MyCADShapeObject ]) renderedShape: renderedShape) ] ] ].
	^ cadDocument
]

{ #category : 'geometry - accessing' }
MyCADViewportPresenter >> cadObjectForRenderedShape: aRenderedShape [

	^ self cadDocument objectForRenderedShape: aRenderedShape
]

{ #category : 'geometry - accessing' }
MyCADViewportPresenter >> cadObjects [

	^ self cadDocument objects
]

{ #category : 'camera - accessing' }
MyCADViewportPresenter >> cameraControlMorph [

	^ self wodenWidget
]

{ #category : 'camera - transforming' }
MyCADViewportPresenter >> cameraForwardDirection [
	"Returns the camera forward direction in world space."

	^ (self transformCameraDirection: (Vector3 x: 0 y: 0 z: -1)) normalized
]

{ #category : 'transform modes - rotation' }
MyCADViewportPresenter >> cancelRotationMode [
	"Restores the selected node transform to its state before rotation mode started."

	rotationMode cancel
]

{ #category : 'transform modes - translation' }
MyCADViewportPresenter >> cancelTranslationMode [
	"Restores the selected node to its position before grab mode started."

	translationMode cancel
]

{ #category : 'actions - file' }
MyCADViewportPresenter >> clearAllShapes [
	"Starts a new empty in-memory scene without deleting any user files."

	self clearSelection.
	renderedShapes do: [ :renderedShape |
			scene remove: renderedShape node.
			renderedShape free ].
	renderedShapes removeAll.
	self cadDocument clear.
	self geometryChanged
]

{ #category : 'selection - managing' }
MyCADViewportPresenter >> clearSelection [
	"Restores the previously selected node's visuals and clears the selection state."

	selection clear
]

{ #category : 'transform modes - rotation' }
MyCADViewportPresenter >> confirmRotationMode [
	"Accepts the current rendered-node rotation and bakes it into the CAD shape."

	rotationMode confirm
]

{ #category : 'transform modes - translation' }
MyCADViewportPresenter >> confirmTranslationMode [
	"Accepts the current rendered-node translation."

	translationMode confirm
]

{ #category : 'context menu - configuration' }
MyCADViewportPresenter >> contextMenuDragThreshold [
	"Returns the pixel radius beyond which a right-button drag suppresses the context menu."

	^ 4
]

{ #category : 'actions - boolean operations' }
MyCADViewportPresenter >> cutOtherBodiesWithSelected [
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

	self geometryChanged
]

{ #category : 'actions - boolean operations' }
MyCADViewportPresenter >> cutSelectedWithLastAdded [
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

	self replaceRenderedShape: target withAll: resultRenderedShapes.

	selection forget.

	self geometryChanged
]

{ #category : 'actions - boolean operations' }
MyCADViewportPresenter >> cutSelectedWithOtherBodies [
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

	self geometryChanged
]

{ #category : 'actions - boolean operations' }
MyCADViewportPresenter >> cutTarget: targetRenderedShape withTools: toolRenderedShapes [
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
MyCADViewportPresenter >> defaultLayout [
	"Returns the top-to-bottom Spec layout containing the Woden presenter."

	^ SpBoxLayout newTopToBottom
		  add: wodenPresenter;
		  yourself
]

{ #category : 'actions - deletion' }
MyCADViewportPresenter >> deleteLastAdded [
	"Removes the most recently added node from the scene and frees its C++ shape."

	| renderedShape cadObject |
	renderedShapes ifEmpty: [ ^ self ].

	renderedShape := renderedShapes removeLast.
	cadObject := self cadObjectForRenderedShape: renderedShape.
	cadObject ifNotNil: [ self cadDocument removeObject: cadObject ].

	self selectedRenderedShape == renderedShape ifTrue: [
			self restoreSelectedVisual.
			selection forget ].

	scene remove: renderedShape node.
	renderedShape free.

	self geometryChanged
]

{ #category : 'actions - deletion' }
MyCADViewportPresenter >> deleteSelected [
	"Removes the currently selected node from the scene and frees its C++ shape."

	| renderedShape cadObject |
	renderedShape := self selectedRenderedShape.
	renderedShape ifNil: [ ^ self ].
	cadObject := self cadObjectForRenderedShape: renderedShape.

	self restoreSelectedVisual.

	renderedShapes remove: renderedShape ifAbsent: [ ].
	cadObject ifNotNil: [ self cadDocument removeObject: cadObject ].
	scene remove: renderedShape node.
	renderedShape free.

	selection forget.

	self geometryChanged
]

{ #category : 'camera - actions' }
MyCADViewportPresenter >> fitAll [

	self cameraControlMorph fitScene
]

{ #category : 'camera - actions' }
MyCADViewportPresenter >> fitSelected [

	self selectedNode ifNotNil: [ :node | self cameraControlMorph fitNode: node ]
]

{ #category : 'events - focus' }
MyCADViewportPresenter >> focusWodenWidget [
	"Requests keyboard focus so X/Y/Z/Enter work after choosing the menu item."

	| widget |
	widget := self wodenWidget.
	widget ifNil: [ ^ self ].

	widget takeKeyboardFocus
]

{ #category : 'announcing' }
MyCADViewportPresenter >> geometryChanged [
	"Redraws the viewport and informs owner presenters that the geometry list changed."

	self refreshScene.
	geometryChangedAction value.
	self setupContextMenu

]

{ #category : 'events - keyboard' }
MyCADViewportPresenter >> handleKeyStroke: anEvent [

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

{ #category : 'events - mouse' }
MyCADViewportPresenter >> handleMouseDown: anEvent [
	"Handles selection, translation confirmation, and rotation confirmation."

	rotationMode isActive ifTrue: [
			anEvent redButtonPressed ifTrue: [
					anEvent wasHandled: true.
					self confirmRotationMode.
					^ self ] ].

	translationMode isActive ifTrue: [
			anEvent redButtonPressed ifTrue: [
					anEvent wasHandled: true.
					^ self ] ].

	(self shouldTrackContextMenuFrom: anEvent) ifTrue: [
			contextMenuDownPosition := anEvent position.
			contextMenuWasDragged := false ].

	anEvent redButtonPressed ifTrue: [ self selectShapeAt: anEvent position ]
]

{ #category : 'events - mouse' }
MyCADViewportPresenter >> handleMouseMove: anEvent [
	"Updates active transform preview, or marks right-button drags for context-menu suppression."

	rotationMode isActive ifTrue: [
			rotationMode updateAt: anEvent position.
			anEvent wasHandled: true.
			^ self ].

	contextMenuDownPosition ifNil: [ ^ self ].
	anEvent yellowButtonPressed ifFalse: [ ^ self ].

	(anEvent position - contextMenuDownPosition) r > self contextMenuDragThreshold ifTrue: [ contextMenuWasDragged := true ]
]

{ #category : 'events - mouse' }
MyCADViewportPresenter >> handleMouseUp: anEvent [
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
MyCADViewportPresenter >> initializePresenters [
	"Sets up mesh node collection, builds the scene, positions the camera, and wires the Woden sub-presenter."

	super initializePresenters.

	renderedShapes := OrderedCollection new.
	geometryChangedAction := [ ].
	selectionChangedAction := [ ].
	transformModeChangedAction := [ :mode |  ].
	visualChangedAction := [ ].
	cadDocument := MyCADDocument new.
	selection := MyCADSelectionController on: self.
	translationMode := MyCADTranslationMode new.
	rotationMode := MyCADRotationMode new.
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
MyCADViewportPresenter >> initializeWindow: aWindowPresenter [
	"Sets the window title and initial size, and installs the context menu once the window opens."

	super initializeWindow: aWindowPresenter.
	aWindowPresenter
		title: 'Woden Render Area';
		initialExtent: 650 @ 500.

	aWindowPresenter whenOpenedDo: [ self setupContextMenu ]
]

{ #category : 'actions - inspection' }
MyCADViewportPresenter >> inspectSelectedShape [
	"Opens a Pharo inspector on the currently selected rendered shape, if any."

	self selectedRenderedShape ifNotNil: [ :renderedShape |
			renderedShape prepareForInspection.
			renderedShape inspect ]
]

{ #category : 'events - keyboard' }
MyCADViewportPresenter >> keyStringFromEvent: anEvent [
	"Normalizes common Morphic key event variants."

	^ self normalizedKeyCharacter: anEvent keyCharacter
]

{ #category : 'geometry - naming' }
MyCADViewportPresenter >> nextAvailableNameFor: baseName [
	"Answers the first unused numbered display name for this scene."

	| index candidate |
	index := 1.
	[
		candidate := baseName , ' ' , index asString.
		renderedShapes noneSatisfy: [ :renderedShape | renderedShape name = candidate ] ] whileFalse: [ index := index + 1 ].
	^ candidate
]

{ #category : 'events - keyboard' }
MyCADViewportPresenter >> normalizedKeyCharacter: aCharacter [
	"Answers the key name used by the transform modes."

	aCharacter ifNil: [ ^ '' ].
	aCharacter = (Character value: 13) ifTrue: [ ^ 'return' ].
	aCharacter = (Character value: 27) ifTrue: [ ^ 'escape' ].
	aCharacter = (Character value: 8) ifTrue: [ ^ 'backspace' ].

	^ aCharacter asString asLowercase
]

{ #category : 'picking - coordinates' }
MyCADViewportPresenter >> normalizedScreenPosition: aPoint [
	"Converts a raw screen point to a [0,1]×[0,1] viewport coordinate with Y flipped for OpenGL convention."

	| widget localPoint widgetExtent |
	widget := self wodenWidget.
	localPoint := aPoint - widget bounds origin.
	widgetExtent := widget extent.

	^ localPoint x / widgetExtent x asFloat @ (1.0 - (localPoint y / widgetExtent y asFloat))
]

{ #category : 'opening' }
MyCADViewportPresenter >> openWithContextMenu [
	"Opens the presenter window and ensures the context menu event hooks are installed."

	self open.
	self withWindowDo: [ :window | self setupContextMenu ]
]

{ #category : 'transform modes - translation' }
MyCADViewportPresenter >> previewTranslation: aVector [
	"Previews an absolute U/V/W translation from the active transform panel."

	translationMode previewTranslation: aVector.
	self visualChanged
]

{ #category : 'picking - rays' }
MyCADViewportPresenter >> ray: aRay triangleIntersectionDistanceFrom: p0 to: p1 to: p2 [
	"Answers the ray distance to a triangle using the Moller-Trumbore test, or nil for no hit."

	| epsilon edge1 edge2 h determinant inverseDeterminant s u q v t |
	epsilon := 0.0000001.
	edge1 := p1 - p0.
	edge2 := p2 - p0.
	h := aRay direction cross: edge2.
	determinant := edge1 dot: h.

	determinant abs < epsilon ifTrue: [ ^ nil ].
	inverseDeterminant := 1.0 / determinant.

	s := aRay origin - p0.
	u := inverseDeterminant * (s dot: h).
	(u < 0.0 or: [ u > 1.0 ]) ifTrue: [ ^ nil ].

	q := s cross: edge1.
	v := inverseDeterminant * (aRay direction dot: q).
	(v < 0.0 or: [ u + v > 1.0 ]) ifTrue: [ ^ nil ].

	t := inverseDeterminant * (edge2 dot: q).
	t < epsilon ifTrue: [ ^ nil ].

	^ t
]

{ #category : 'picking - rays' }
MyCADViewportPresenter >> ray: worldRay trianglePickDistanceFor: aRenderedShape [
	"Answers the nearest world-ray distance to the rendered shape's tessellated face triangles, or nil when the ray only hits the broad bounding box."

	| node localRay vertices triangles nearestLocalDistance triangleDistance hitWorldDistance |
	node := aRenderedShape node.
	localRay := worldRay inverseTransformedWith: node globalTransform.
	vertices := aRenderedShape shape vertices.
	triangles := aRenderedShape shape triangles.
	nearestLocalDistance := nil.

	0 to: aRenderedShape shape triangleCount - 1 do: [ :triangleIndex |
			| i0 i1 i2 p0 p1 p2 |
			i0 := triangles at: triangleIndex * 3 + 1.
			i1 := triangles at: triangleIndex * 3 + 2.
			i2 := triangles at: triangleIndex * 3 + 3.

			p0 := self vertexAtZeroBasedIndex: i0 in: vertices.
			p1 := self vertexAtZeroBasedIndex: i1 in: vertices.
			p2 := self vertexAtZeroBasedIndex: i2 in: vertices.

			triangleDistance := self
				                    ray: localRay
				                    triangleIntersectionDistanceFrom: p0
				                    to: p1
				                    to: p2.

			triangleDistance ifNotNil: [
				(nearestLocalDistance isNil or: [ triangleDistance < nearestLocalDistance ]) ifTrue: [
					nearestLocalDistance := triangleDistance ] ] ].

	nearestLocalDistance ifNil: [ ^ nil ].

	hitWorldDistance := worldRay distanceForPoint:
		                    (node globalTransform transformPosition: (localRay pointAtDistance: nearestLocalDistance)).
	^ hitWorldDistance
]

{ #category : 'picking - rays' }
MyCADViewportPresenter >> rayForScreenPosition: aPoint [
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

{ #category : 'picking - rays' }
MyCADViewportPresenter >> rayPickEntriesAt: aPoint [
	"Ray-casts against rendered CAD triangles and returns hit entries sorted by distance.
	The face bounding box is used only as a cheap broad-phase reject; it is not enough for selection because it includes empty space around curved silhouettes."

	| ray hits |
	ray := self rayForScreenPosition: aPoint.
	hits := OrderedCollection new.

	renderedShapes do: [ :renderedShape |
			| box distance |
			box := self selectionBoundingBoxFor: renderedShape.
			(box intersectionWithRay: ray) ifNotNil: [
					distance := self ray: ray trianglePickDistanceFor: renderedShape.
					distance ifNotNil: [ hits add: distance -> renderedShape ] ] ].

	^ (hits asSortedCollection: [ :a :b | a key < b key ]) collect: [ :each | each value ]
]

{ #category : 'scene - updating' }
MyCADViewportPresenter >> refreshScene [
	"Requests a redraw of the embedded Woden widget."

	self wodenWidget ifNotNil: [ :widget | widget changed ]
]

{ #category : 'actions - editing' }
MyCADViewportPresenter >> renameSelectedShape [
	"Uses a Spec2 request dialog to rename the selected in-memory shape."

	| renderedShape |
	renderedShape := self selectedRenderedShape.
	renderedShape ifNil: [ ^ self ].

	SpRequestDialog new
		application: self application;
		title: 'Rename Shape';
		message: 'Shape name';
		text: renderedShape name;
		acceptLabel: 'Rename';
		cancelLabel: 'Cancel';
		onAccept: [ :dialog | self renameSelectedShapeTo: dialog presenter text ];
		openModal
]

{ #category : 'actions - editing' }
MyCADViewportPresenter >> renameSelectedShapeTo: aString [

	| renderedShape newName |
	renderedShape := self selectedRenderedShape.
	renderedShape ifNil: [ ^ self ].
	newName := aString trimBoth.
	newName isEmpty ifTrue: [ ^ self ].

	renderedShape renameTo: newName.
	self geometryChanged
]

{ #category : 'geometry - accessing' }
MyCADViewportPresenter >> renderedShapes [

	^ renderedShapes asArray
]

{ #category : 'scene - geometry management' }
MyCADViewportPresenter >> replaceRenderedShape: oldRenderedShape withAll: newRenderedShapes [
	"Replace one scene body with zero or more rendered bodies."

	| oldObject newObjects |
	oldObject := self cadObjectForRenderedShape: oldRenderedShape.
	newObjects := newRenderedShapes collect: [ :newRenderedShape | MyCADBooleanResultObject renderedShape: newRenderedShape ].

	scene remove: oldRenderedShape node.
	renderedShapes remove: oldRenderedShape ifAbsent: [ ].
	oldRenderedShape free.
	oldObject
		ifNil: [ newObjects do: [ :each | self cadDocument addObject: each ] ]
		ifNotNil: [ self cadDocument replaceObject: oldObject withAll: newObjects ].

	newRenderedShapes do: [ :newRenderedShape |
			scene add: newRenderedShape node.
			renderedShapes addLast: newRenderedShape ]
]

{ #category : 'actions - editing' }
MyCADViewportPresenter >> resizeSelectedBoxDx: dx dy: dy dz: dz [

	self resizeSelectedCADObjectToDimensions: (Vector3 x: dx y: dy z: dz)
]

{ #category : 'actions - editing' }
MyCADViewportPresenter >> resizeSelectedCADObjectToDimensions: dimensionsVector [

	| cadObject change |
	cadObject := self selectedCADObject.
	cadObject ifNil: [ ^ self ].
	cadObject isAlive ifFalse: [ ^ self ].
	cadObject editableDimensionLabels isEmpty ifTrue: [ ^ self ].

	self restoreSelectedVisual.
	change := cadObject resizeToDimensions: dimensionsVector.
	self applyRenderNodeChange: change.
	self applySelectedVisualTo: cadObject renderedShape node.
	self visualChanged
]

{ #category : 'selection - highlighting' }
MyCADViewportPresenter >> restoreSelectedVisual [
	"Puts the originally saved renderables back on the selected node."

	selection restoreVisual
]

{ #category : 'transform modes - rotation' }
MyCADViewportPresenter >> rotationDegreesPerPixel [
	"Degrees rotated per horizontal mouse pixel."

	^ 0.5
]

{ #category : 'actions - editing' }
MyCADViewportPresenter >> saveSelectedShapeTo: aFileReference [
	"Explicitly exports the selected shape. No editing operation calls this method."

	self selectedShape ifNil: [ ^ self ].
	self selectedShape saveToFile: aFileReference.
	self geometryChanged
]

{ #category : 'selection - managing' }
MyCADViewportPresenter >> selectCADObject: aCADObject [

	aCADObject ifNil: [ self clearSelection ] ifNotNil: [ self selectRenderedShape: aCADObject renderedShape ]
]

{ #category : 'selection - managing' }
MyCADViewportPresenter >> selectRenderedShape: aRenderedShape [

	(aRenderedShape notNil and: [ aRenderedShape isAlive not ]) ifTrue: [
			selection clear.
			^ self ].
	selection selectedRenderedShape == aRenderedShape ifTrue: [ ^ self ].
	selection select: aRenderedShape
]

{ #category : 'picking - selection' }
MyCADViewportPresenter >> selectShapeAt: aPoint [
	"Picks the shape under the cursor; cycles to the next hit if the same node was already selected."

	selection selectFrom: (self rayPickEntriesAt: aPoint)
]

{ #category : 'selection - accessing' }
MyCADViewportPresenter >> selectedCADObject [

	^ self cadObjectForRenderedShape: self selectedRenderedShape
]

{ #category : 'selection - accessing' }
MyCADViewportPresenter >> selectedNode [
	"Returns the scene node of the currently selected entry, or nil if nothing is selected."

	^ selection selectedNode
]

{ #category : 'selection - accessing' }
MyCADViewportPresenter >> selectedNodeRotationCenter [
	"Returns the visible world-space center of the selected rendered node."

	^ selection selectedRotationCenter
]

{ #category : 'selection - accessing' }
MyCADViewportPresenter >> selectedRenderedShape [

	^ selection selectedRenderedShape
]

{ #category : 'selection - accessing' }
MyCADViewportPresenter >> selectedShape [
	"Returns the MyShape of the currently selected entry, or nil if nothing is selected."

	^ selection selectedShape
]

{ #category : 'picking - selection' }
MyCADViewportPresenter >> selectionBoundingBoxFor: aRenderedShape [
	"Answers the selectable world-space bounds for a rendered CAD shape.
	The first renderable is the shaded face mesh; later renderables are decorative edge overlays and should not expand picking or pivot bounds."

	| node renderables faceRenderable |
	node := aRenderedShape node.
	renderables := node renderables.
	renderables ifEmpty: [ ^ node localBoundingBox transformedWith: node globalTransform ].

	faceRenderable := renderables first.
	^ faceRenderable boundingBox transformedWith: node globalTransform
]

{ #category : 'announcing' }
MyCADViewportPresenter >> selectionChanged [
	"Redraws the viewport and informs owner presenters that selection changed."

	self refreshScene.
	selectionChangedAction value
]

{ #category : 'events - registration' }
MyCADViewportPresenter >> setupContextMenu [
	"Registers mouseDown, mouseMove, and mouseUp handlers on the underlying Woden widget."

	| widget |
	widget := self wodenWidget.
	widget ifNil: [ ^ self ].
	contextMenuWidget == widget ifTrue: [ ^ self ].

	widget
		on: #mouseDown send: #handleMouseDown: to: self;
		on: #mouseMove send: #handleMouseMove: to: self;
		on: #mouseUp send: #handleMouseUp: to: self;
		on: #keyStroke send: #handleKeyStroke: to: self. "If your image does not understand #keyStroke, try this instead:

	on: #keyDown send: #handleKeyStroke: to: self"
	contextMenuWidget := widget
]

{ #category : 'context menu - handling' }
MyCADViewportPresenter >> shouldTrackContextMenuFrom: anEvent [
	"Answers whether this right-button press should open a context menu when released."

	^ anEvent yellowButtonPressed and: [ anEvent shiftPressed not and: [ anEvent controlKeyPressed not ] ]
]

{ #category : 'context menu - handling' }
MyCADViewportPresenter >> showContextMenuAt: aPoint [
	"Builds and displays the context menu at the given screen position."

	| menu |
	menu := self buildContextMenu.
	menu openWithSpecAt: aPoint
]

{ #category : 'camera - transforming' }
MyCADViewportPresenter >> transformCameraDirection: aVector [
	"Transforms a direction vector using the camera transform."

	^ cameraNode transform transformVector3: aVector
]

{ #category : 'announcing' }
MyCADViewportPresenter >> transformModeChanged: mode [

	transformModeChangedAction value: mode
]

{ #category : 'camera - actions' }
MyCADViewportPresenter >> useSelectedAsPivot [

	self selectedNode ifNotNil: [ :node | self cameraControlMorph useNodePivot: node ]
]

{ #category : 'picking - geometry' }
MyCADViewportPresenter >> vertexAtZeroBasedIndex: vertexIndex in: vertices [
	"Answers a Vector3 from a flat xyz vertex buffer whose mesh indices are zero-based."

	| baseIndex |
	baseIndex := vertexIndex * 3.
	^ Vector3 x: (vertices at: baseIndex + 1) y: (vertices at: baseIndex + 2) z: (vertices at: baseIndex + 3)
]

{ #category : 'announcing' }
MyCADViewportPresenter >> visualChanged [
	"Announces that rendered node state changed without necessarily changing the scene's shape list."

	visualChangedAction value
]

{ #category : 'announcing' }
MyCADViewportPresenter >> whenGeometryChangedDo: aBlock [

	geometryChangedAction := aBlock
]

{ #category : 'announcing' }
MyCADViewportPresenter >> whenSelectionChangedDo: aBlock [

	selectionChangedAction := aBlock
]

{ #category : 'announcing' }
MyCADViewportPresenter >> whenTransformModeChangedDo: aBlock [

	transformModeChangedAction := aBlock
]

{ #category : 'announcing' }
MyCADViewportPresenter >> whenVisualChangedDo: aBlock [

	visualChangedAction := aBlock
]

{ #category : 'accessing - widgets' }
MyCADViewportPresenter >> wodenWidget [
	"Returns the embedded Woden widget, if it has been built."

	wodenPresenter ifNil: [ ^ nil ].
	wodenPresenter adapter ifNil: [ ^ nil ].

	^ wodenPresenter adapter widget
]
