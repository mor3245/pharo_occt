"
This class is used to override the library object. A library object represents a library as an instance of `FFILibrary`.


"
Class {
	#name : 'MyOCPStLib',
	#superclass : 'FFILibrary',
	#category : 'LibImports-UFFI-CWrap',
	#package : 'LibImports-UFFI-CWrap'
}

{ #category : 'accessing - platform' }
MyOCPStLib >> macLibraryName [

	^ self error: 'Not implemented'
]

{ #category : 'accessing - platform' }
MyOCPStLib >> unixLibraryName [
	"Users should use unix32* or unix64*"

	^ self error: 'Not implemented'
]

{ #category : 'accessing - platform' }
MyOCPStLib >> win32LibraryName [

	^ 'my_occt_c_wrapper.dll'
]
