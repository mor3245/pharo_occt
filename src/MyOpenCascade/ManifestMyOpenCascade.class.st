"
Please describe the package using the class comment of the included manifest class. The manifest class also includes other additional metadata for the package. These meta data are used by other tools such as the SmalllintManifestChecker and the critics Browser
"
Class {
	#name : 'ManifestMyOpenCascade',
	#superclass : 'PackageManifest',
	#category : 'MyOpenCascade-Manifest',
	#package : 'MyOpenCascade',
	#tag : 'Manifest'
}

{ #category : 'code-critics' }
ManifestMyOpenCascade class >> ruleClassNotReferencedRuleV1FalsePositive [

	<ignoreForCoverage>
	^ #(#(#(#RGClassDefinition #(#Example)) #'2026-05-05T11:28:11.99+08:00') )
]

{ #category : 'code-critics' }
ManifestMyOpenCascade class >> ruleImplementedNotSentRuleV1FalsePositive [

	<ignoreForCoverage>
	^ #(#(#(#RGMethodDefinition #(#CxxOcctLibrary #ffiLibrary #false)) #'2026-05-05T11:28:12.004+08:00') #(#(#RGMethodDefinition #(#'Example class' #exampleBoxRender #true)) #'2026-05-05T11:28:12.004+08:00') #(#(#RGMethodDefinition #(#'Example class' #exampleBoxRenderWithContextMenu #true)) #'2026-05-05T11:28:12.004+08:00') #(#(#RGMethodDefinition #(#MyCADViewportPresenter #initializePresenters #false)) #'2026-05-05T11:28:12.004+08:00') #(#(#RGMethodDefinition #(#MyCADViewportPresenter #initializeWindow: #false)) #'2026-05-05T11:28:12.004+08:00') #(#(#RGMethodDefinition #(#MyCADViewportPresenter #openWithContextMenu #false)) #'2026-05-05T11:28:12.004+08:00') #(#(#RGMethodDefinition #(#MyCADViewportPresenter #handleMouseEvent: #false)) #'2026-05-05T11:28:12.004+08:00') )
]
