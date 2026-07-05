"
I describe the Woden scene-node replacement caused by rebuilding or baking a
rendered CAD shape.

MyRenderedShape answers me after an operation that may replace its node. The
viewport uses my old and new nodes to update the scene graph without needing to
know why the shape changed. An unchanged instance means no scene update is
required.
"
Class {
	#name : 'MyRenderNodeChange',
	#superclass : 'Object',
	#instVars : [
		'oldNode',
		'newNode'
	],
	#category : 'MyOpenCascade-Rendering',
	#package : 'MyOpenCascade-Rendering'
}

{ #category : 'instance creation' }
MyRenderNodeChange class >> oldNode: oldNode newNode: newNode [

	^ self new
		  oldNode: oldNode;
		  newNode: newNode;
		  yourself
]

{ #category : 'instance creation' }
MyRenderNodeChange class >> unchanged [

	^ self oldNode: nil newNode: nil
]

{ #category : 'testing' }
MyRenderNodeChange >> isUnchanged [

	^ oldNode isNil and: [ newNode isNil ]
]

{ #category : 'accessing' }
MyRenderNodeChange >> newNode [

	^ newNode
]

{ #category : 'accessing' }
MyRenderNodeChange >> newNode: anObject [

	newNode := anObject
]

{ #category : 'accessing' }
MyRenderNodeChange >> oldNode [

	^ oldNode
]

{ #category : 'accessing' }
MyRenderNodeChange >> oldNode: anObject [

	oldNode := anObject
]
