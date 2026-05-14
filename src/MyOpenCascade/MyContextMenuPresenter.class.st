"
I am a Spec2 presenter that provides an interactive 3D viewport with a context menu for managing geometric objects.

I integrate the Woden 3D engine with the Pharo Spec framework, allowing users to dynamically add and remove 3D boxes within a scene via a ctrl-right-click menu. I act as the controller that coordinates between the user interface, the Woden scene graph, and the OpenCascade-based 'MyBoxMaker' logic.

Note to self: Clicking on overlapping shapes cycles to the other shape


"
Class {
	#name : 'MyContextMenuPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'wodenPresenter',
		'scene',
		'meshNodes',
		'cameraNode',
		'selectedEntry',
		'selectedOriginalRenderables',
		'contextMenuDownPosition',
		'contextMenuWasDragged'
	],
	#category : 'MyOpenCascade-Woden',
	#package : 'MyOpenCascade',
	#tag : 'Woden'
}

{ #category : 'rendered geometry management' }
MyContextMenuPresenter >> addBox [

	| shape mesh node |
	shape := (MyBoxMaker
		          tessellatedBoxDx: 1
		          dy: 1
		          dz: 1
		          deflection: 0.01).
	mesh := MyShapeWodenAdapter new asWDMesh: shape.
	node := mesh asSceneNode.

	scene add: node.
	meshNodes addLast: node -> shape.

	wodenPresenter adapter widget changed
]

{ #category : 'rendered geometry management' }
MyContextMenuPresenter >> addCylinder [

	| shape mesh node |
	shape := MyCylinderMaker tessellatedCylinderRadius: 1 height: 1 deflection: 0.01.
	mesh := MyShapeWodenAdapter new asWDMesh: shape.
	node := mesh asSceneNode.

	scene add: node.
	meshNodes addLast: node -> shape.

	wodenPresenter adapter widget changed
]

{ #category : 'geometry selection' }
MyContextMenuPresenter >> applySelectedVisualTo: aNode [

    selectedOriginalRenderables := aNode renderables.

    aNode renderables:
        (selectedOriginalRenderables collect: [ :each |
            each copyWithMaterial: self selectionMaterial
        ]).
]

{ #category : 'user interface' }
MyContextMenuPresenter >> buildContextMenu [

	^ SpMenuPresenter new addGroup: [ :group |
			  group
				  addItem: [ :item |
						  item
							  name: 'Add Box';
							  action: [ self addBox ] ];
				  addItem: [ :item |
						  item
							  name: 'Delete last inserted';
							  action: [ self deleteLastAdded ] ];
				  addItem: [ :item |
						  item
							  name: 'Add Cylinder';
							  action: [ self addCylinder ] ];
				  addItem: [ :item |
						  item
							  name: 'Delete Selected';
							  action: [ self deleteSelected ] ];
				 addItem: [ :item |
						  item
							  name: 'Inspect Selected';
							  action: [ self inspectSelectedShape ] ]
						] yourself
]

{ #category : 'rendered geometry management' }
MyContextMenuPresenter >> buildScene [

	"| mesh light lightNode |"
	| light lightNode |
	scene := WDScene new.

	"mesh := (MyBoxMaker
		         tessellatedBoxDx: 1
		         dy: 1
		         dz: 1
		         deflection: 0.01) asWDMesh."

	light := WDPointLightSource new
		         intensity: 5.0;
		         yourself.
	lightNode := light asSceneNode.
	lightNode position: (Vector3 x: -1.5 y: 1.5 z: 1.0).

	"scene add: mesh."
	scene add: lightNode.
	^ scene
]

{ #category : 'geometry selection' }
MyContextMenuPresenter >> clearSelection [

    self restoreSelectedVisual.
    selectedEntry := nil.
    wodenPresenter adapter widget changed.
]

{ #category : 'events-processing' }
MyContextMenuPresenter >> contextMenuDragThreshold [

    ^ 4
]

{ #category : 'layout' }
MyContextMenuPresenter >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		add: wodenPresenter ;
		yourself
]

{ #category : 'rendered geometry management' }
MyContextMenuPresenter >> deleteLastAdded [

    | entry |
    meshNodes ifEmpty: [ ^ self ].

    entry := meshNodes removeLast.

    selectedEntry == entry ifTrue: [
        self restoreSelectedVisual.
        selectedEntry := nil.
        selectedOriginalRenderables := nil
    ].

    scene remove: entry key.
    entry value free.

    wodenPresenter adapter widget changed
]

{ #category : 'rendered geometry management' }
MyContextMenuPresenter >> deleteSelected [

    | node shape |
    selectedEntry ifNil: [ ^ self ].

    node := selectedEntry key.
    shape := selectedEntry value.

    self restoreSelectedVisual.

    meshNodes remove: selectedEntry ifAbsent: [ ].
    scene remove: node.
    shape free.

    selectedEntry := nil.
    selectedOriginalRenderables := nil.

    wodenPresenter adapter widget changed.
]

{ #category : 'event handling' }
MyContextMenuPresenter >> handleMouseDown: anEvent [

    anEvent yellowButtonPressed ifTrue: [
        contextMenuDownPosition := anEvent position.
        contextMenuWasDragged := false
    ].

    anEvent redButtonPressed ifTrue: [
        self selectShapeAt: anEvent position
    ]
]

{ #category : 'events-processing' }
MyContextMenuPresenter >> handleMouseMove: anEvent [

    contextMenuDownPosition ifNil: [ ^ self ].
    anEvent yellowButtonPressed ifFalse: [ ^ self ].

    ((anEvent position - contextMenuDownPosition) r > self contextMenuDragThreshold)
        ifTrue: [ contextMenuWasDragged := true ]
]

{ #category : 'events-processing' }
MyContextMenuPresenter >> handleMouseUp: anEvent [

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

	super initializePresenters.

	meshNodes := OrderedCollection new.
selectedEntry := nil.
selectedOriginalRenderables := nil.
scene := self buildScene.

cameraNode := WDCamera new asSceneNode.
cameraNode position: (Vector3 x: 0 y: 0 z: 3).

wodenPresenter := self instantiate: WDSpInteractiveScenePresenter.
wodenPresenter
    scene: scene;
    camera: cameraNode
]

{ #category : 'initialization' }
MyContextMenuPresenter >> initializeWindow: aWindowPresenter [

	super initializeWindow: aWindowPresenter.
	aWindowPresenter
		title: 'Woden Render Area';
		initialExtent: 650 @ 500.

	aWindowPresenter whenOpenedDo: [ self setupContextMenu ]
]

{ #category : 'rendered geometry management' }
MyContextMenuPresenter >> inspectSelectedShape [
    self selectedShape ifNotNil: [ :shape | shape inspect ]
]

{ #category : 'geometry selection' }
MyContextMenuPresenter >> normalizedScreenPosition: aPoint [

    | widget localPoint widgetExtent |
    widget := wodenPresenter adapter widget.
    localPoint := aPoint - widget bounds origin.
    widgetExtent := widget extent.

    ^ (localPoint x / widgetExtent x asFloat)
        @ (1.0 - (localPoint y / widgetExtent y asFloat))

]

{ #category : 'user interface' }
MyContextMenuPresenter >> openWithContextMenu [

	self open.
	self withWindowDo: [ :widnow | self setupContextMenu ]
]

{ #category : 'geometry selection' }
MyContextMenuPresenter >> rayForScreenPosition: aPoint [
	"""Screen point -> normalized viewport point -> camera-space ray -> world-space ray"""

	| widget widgetExtent aspect frustum ray |
	widget := wodenPresenter adapter widget.
	widgetExtent := widget extent.
	aspect := widgetExtent x asFloat / (widgetExtent y max: 1).

	frustum := cameraNode cameras first frustumWithAspect: aspect. "Get the viewing frustum"
	ray := frustum rayForNormalizedPoint: (self normalizedScreenPosition: aPoint). "construct a picking ray relative to the viewing frustum"

	^ ray transformedWith: cameraNode transform "Convert ray position to woden/scene coordinates"
]

{ #category : 'accessing' }
MyContextMenuPresenter >> rayPickEntriesAt: aPoint [

    | ray hits |
    ray := self rayForScreenPosition: aPoint.
    hits := OrderedCollection new.

    meshNodes do: [ :entry |
        | node box distance |
        node := entry key.
        box := node localBoundingBox transformedWith: node globalTransform.
        distance := box intersectionWithRay: ray.

        distance ifNotNil: [
            hits add: distance -> entry
        ]
    ].

    ^ (hits asSortedCollection: [ :a :b | a key < b key ])
        collect: [ :each | each value ]
]

{ #category : 'geometry selection' }
MyContextMenuPresenter >> restoreSelectedVisual [

    selectedEntry ifNil: [ ^ self ].
    selectedOriginalRenderables ifNil: [ ^ self ].

    selectedEntry key renderables: selectedOriginalRenderables.
    selectedOriginalRenderables := nil.
]

{ #category : 'accessing' }
MyContextMenuPresenter >> selectShapeAt: aPoint [

    | pickedEntries pickedIndex pickedEntry |
    pickedEntries := self rayPickEntriesAt: aPoint.

    pickedEntries ifEmpty: [
        self clearSelection.
        ^ self
    ].

    pickedIndex := selectedEntry
        ifNil: [ 0 ]
        ifNotNil: [ pickedEntries indexOf: selectedEntry ifAbsent: [ 0 ] ].

    pickedEntry := pickedEntries at: (pickedIndex \\ pickedEntries size) + 1.

    self restoreSelectedVisual.
    selectedEntry := pickedEntry.
    self applySelectedVisualTo: selectedEntry key.

    wodenPresenter adapter widget changed.
]

{ #category : 'accessing' }
MyContextMenuPresenter >> selectedNode [
    ^ selectedEntry ifNil: [ nil ] ifNotNil: [ selectedEntry key ]
]

{ #category : 'accessing' }
MyContextMenuPresenter >> selectedShape [
    ^ selectedEntry ifNil: [ nil ] ifNotNil: [ selectedEntry value ]
]

{ #category : 'geometry selection' }
MyContextMenuPresenter >> selectionMaterial [

    ^ WDUnlitMaterial new
        colorFactor: Color yellow;
        yourself
]

{ #category : 'input event handling' }
MyContextMenuPresenter >> setupContextMenu [

    | widget |
    widget := wodenPresenter adapter widget.
    widget ifNil: [ ^ self ].

    widget
        on: #mouseDown send: #handleMouseDown: to: self;
        on: #mouseMove send: #handleMouseMove: to: self;
        on: #mouseUp send: #handleMouseUp: to: self

]

{ #category : 'accessing' }
MyContextMenuPresenter >> showContextMenuAt: aPoint [

	| menu |
	menu := self buildContextMenu.
	menu openWithSpecAt: aPoint
]

{ #category : 'geometry translation' }
MyContextMenuPresenter >> translateSelectedBy: aVector [
    self selectedNode ifNotNil: [ :node |
        node translateBy: aVector.
        wodenPresenter adapter widget changed
    ].
]
