"
I am a Spec2 presenter that provides an interactive 3D viewport with a context menu for managing geometric objects.

I integrate the Woden 3D engine with the Pharo Spec framework, allowing users to dynamically add and remove 3D boxes within a scene via a ctrl-right-click menu. I act as the controller that coordinates between the user interface, the Woden scene graph, and the OpenCascade-based 'MyBoxMaker' logic.

Responsibilities:
- Scene Management: I initialize and maintain a 'WDScene', including lighting and a camera positioned to view the 3D workspace.
- Interactive Commands: I provide logic to create tessellated boxes (using 'MyBoxMaker') and add them to the scene as nodes.
- Resource Tracking: I maintain a collection of 'meshNodes' (associations between scene nodes and their underlying 'MyShape' objects) to ensure that when a box is deleted, its external C++ memory is correctly freed.
- Event Handling: I intercept mouse events on the Woden widget to detect ctrl-right-clicks and trigger the display of a context menu at the cursor position.

Public API:
- #openWithContextMenu - Opens the presenter window and attaches the right-click event handlers.
- #addBox - Generates a new 1x1x1 tessellated box and adds it to the 3D scene.
- #deleteBox - Removes the most recently added box from the scene and frees its associated external resources.

Internal Representation:
- wodenPresenter: The 'WDSpInteractiveScenePresenter' that handles the actual 3D rendering.
- scene: The 'WDScene' instance containing the lights and geometric nodes.
- meshNodes: An 'OrderedCollection' used to track the relationship between visual nodes and 'MyShape' handles for cleanup.

Example:
    MyContextMenuPresenter new openWithContextMenu.

Class {
	#name : 'MyContextMenuPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'wodenPresenter',
		'scene',
		'meshNodes'
	],
	#category : 'MyOpenCascade-UFFI',
	#package : 'MyOpenCascade-UFFI'
}
"
Class {
	#name : 'MyContextMenuPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'wodenPresenter',
		'scene',
		'meshNodes'
	],
	#category : 'MyOpenCascade-UFFI-Base',
	#package : 'MyOpenCascade-UFFI',
	#tag : 'Base'
}

{ #category : 'scene geometry management' }
MyContextMenuPresenter >> addBox [

	| shape mesh node |
	shape := (MyBoxMaker
		          tessellatedBoxDx: 1
		          dy: 1
		          dz: 1
		          deflection: 0.01).
	mesh := shape asWDMesh.
	node := mesh asSceneNode.

	scene add: node.
	meshNodes addLast: node -> shape.

	wodenPresenter adapter widget changed
]

{ #category : 'event handling and interactive menu' }
MyContextMenuPresenter >> buildContextMenu [

	^ SpMenuPresenter new addGroup: [ :group |
			  group addItem: [ :item |
					  item
						  name: 'Add Box';
						  action: [ self addBox ] ] ;
					addItem: [ :item |
						item
							name: 'Delete Box';
							action: [ self deleteBox ] ]


					] yourself
]

{ #category : 'scene geometry management' }
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

{ #category : 'layout' }
MyContextMenuPresenter >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		add: wodenPresenter ;
		yourself
]

{ #category : 'scene geometry management' }
MyContextMenuPresenter >> deleteBox [

	| entry |
	meshNodes ifEmpty: [ ^ self ].

	entry := meshNodes removeLast.
	scene remove: entry key.
	entry value free.

	wodenPresenter adapter widget changed
]

{ #category : 'event handling and interactive menu' }
MyContextMenuPresenter >> handleMouseEvent: anEvent [

	Transcript
		nextPutAll: 'Mouse button: ';
		nextPutAll: anEvent whichButton asString;
		cr.
	anEvent controlKeyPressed ifFalse: [ ^ self ].
	anEvent yellowButtonPressed ifFalse: [ ^ self ].
	Transcript
		nextPutAll: 'Ctrl-Right-click detected - showing menu';
		cr.
	self showContextMenuAt: anEvent position
]

{ #category : 'initialization' }
MyContextMenuPresenter >> initializePresenters [

	super initializePresenters.

	meshNodes := OrderedCollection new.
	scene := self buildScene.

	wodenPresenter := self instantiate: WDSpInteractiveScenePresenter.
	wodenPresenter
		scene: scene;
		camera: (WDCamera new asSceneNode position: (Vector3 x: 0 y: 0 z: 3))
]

{ #category : 'initialization' }
MyContextMenuPresenter >> initializeWindow: aWindowPresenter [

	super initializeWindow: aWindowPresenter.
	aWindowPresenter
		title: 'Woden Render Area';
		initialExtent: 650 @ 500.

	aWindowPresenter whenOpenedDo: [ self setupContextMenu ]
]

{ #category : 'event handling and interactive menu' }
MyContextMenuPresenter >> openWithContextMenu [

	self open.
	self withWindowDo: [ :widnow | self setupContextMenu ]
]

{ #category : 'event handling and interactive menu' }
MyContextMenuPresenter >> setupContextMenu [

	| widget |
	widget := wodenPresenter adapter widget.
	widget ifNil: [ ^ self ].

	Transcript
		nextPutAll: 'Setting up context menu on: ';
		nextPutAll: widget asString;
		cr.

	widget on: #mouseDown send: #handleMouseEvent: to: self
]

{ #category : 'accessing' }
MyContextMenuPresenter >> showContextMenuAt: aPoint [

	| menu |
	menu := self buildContextMenu.
	menu openWithSpecAt: aPoint
]
