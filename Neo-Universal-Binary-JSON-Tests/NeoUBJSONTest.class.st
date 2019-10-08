Class {
	#name : #NeoUBJSONTest,
	#superclass : #TestCase,
	#category : #'Neo-Universal-Binary-JSON-Tests'
}

{ #category : #accessing }
NeoUBJSONTest class >> dataset1 [
	^ ZnConstants httpStatusCodes associations 
		collect: [ :each | { #code->each key. #reason->each value } asDictionary ].
]

{ #category : #accessing }
NeoUBJSONTest class >> dataset2 [
	^ Collection allSubclasses 
		collect: [ :cl | 
			{ 
				#name->cl name. 
				#superclass->cl superclass name. 
				#ivars->cl instVarNames. 
				#package->cl category. 
				#kind->cl kindOfSubclass trimBoth allButLast. 
				#subclasses->(cl subclasses collect: #name).
				#count->cl allInstances size } asDictionary ]
		as: Array
]

{ #category : #accessing }
NeoUBJSONTest class >> dataset3 [
	^ (1 to: 100) collect: [ :each | 
			{ 
				#int->each. 
				#dec->(each printStringBase: 10). 
				#hex->(each printStringBase: 16). 
				#oct->(each printStringBase: 8). 
				#binary->(each printStringBase: 2). 
				#roman->each printStringRoman. 
				#words->each asWords.
				#negative->each negated } asDictionary ]
]

{ #category : #asserting }
NeoUBJSONTest >> assertSerializeMaterialize: anObject [
	| encoded decoded |
	encoded := NeoUBJSONWriter toByteArray: anObject.
	decoded := NeoUBJSONReader fromByteArray: encoded.
	self assert: decoded equals: anObject 
]

{ #category : #private }
NeoUBJSONTest >> serializeMaterialize: anObject [
	| encoded |
	encoded := NeoUBJSONWriter toByteArray: anObject.
	^ NeoUBJSONReader fromByteArray: encoded
]

{ #category : #tests }
NeoUBJSONTest >> testByteArrays [
	self assertSerializeMaterialize: #[1 2 3].
	self assertSerializeMaterialize: #[].
	self assertSerializeMaterialize: ((0 to: 16rFF) as: ByteArray).
]

{ #category : #tests }
NeoUBJSONTest >> testDataset1 [
	self assertSerializeMaterialize: self class dataset1
]

{ #category : #tests }
NeoUBJSONTest >> testDataset2 [
	self assertSerializeMaterialize: self class dataset2
]

{ #category : #tests }
NeoUBJSONTest >> testDataset3 [
	self assertSerializeMaterialize: self class dataset3
]

{ #category : #tests }
NeoUBJSONTest >> testFloats [
	| numbers |
	numbers := { 0.0. 1.0. -1.0. Float pi. Float e. Float pi. Float e }.
	numbers do: [ :each |
		self assert: (self serializeMaterialize: each) closeTo: each ]
]

{ #category : #tests }
NeoUBJSONTest >> testHighPrecisionInteger [
	self assertSerializeMaterialize: { 42 factorial. 42 factorial negated }
]

{ #category : #tests }
NeoUBJSONTest >> testIntegers [
	| numbers |
	numbers := Array streamContents: [ :out |
		out nextPut: 0.
		1 to: 62 do: [ :each |
			out nextPut: (2 raisedTo: each); nextPut: (2 raisedTo: each) negated ] ].
	self assertSerializeMaterialize: numbers
]

{ #category : #tests }
NeoUBJSONTest >> testSimpleArrays [
	self assertSerializeMaterialize: #().
	self assertSerializeMaterialize: #(1 2 3).
	self assertSerializeMaterialize: #(true false nil).
	self assertSerializeMaterialize: #('one' 'two' 'three').
	self assertSerializeMaterialize: #('a' 'b' 'c').
]

{ #category : #tests }
NeoUBJSONTest >> testSimpleDictionaries [
	self assertSerializeMaterialize: Dictionary new.
	self assertSerializeMaterialize: { #one->1. #two->2. #three->3 } asDictionary.
	self assertSerializeMaterialize: { #one->true. #two->false. #three->nil } asDictionary.
	self assertSerializeMaterialize: { #one->'one'. #two->'two'. #three->'three' } asDictionary.
]

{ #category : #tests }
NeoUBJSONTest >> testStrings [
	self assertSerializeMaterialize: #('' 'a' 'A' '€' 'Les élèves Françaises' '100 €').
	self assertSerializeMaterialize: (String loremIpsum: 2048).
	self assertSerializeMaterialize: (((String loremIpsum: 2048) replaceAll: $A with: $Å) replaceAll: $E with: $€).
]
