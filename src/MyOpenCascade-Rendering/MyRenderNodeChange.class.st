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

{ #category : 'as yet unclassified' }
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
