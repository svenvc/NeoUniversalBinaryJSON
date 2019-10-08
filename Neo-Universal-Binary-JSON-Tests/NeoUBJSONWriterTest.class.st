Class {
	#name : #NeoUBJSONWriterTest,
	#superclass : #TestCase,
	#category : #'Neo-Universal-Binary-JSON-Tests'
}

{ #category : #tests }
NeoUBJSONWriterTest >> testFalse [
	self assert: (NeoUBJSONWriter toByteArray: false) equals: #[70]
]

{ #category : #tests }
NeoUBJSONWriterTest >> testNil [
	self assert: (NeoUBJSONWriter toByteArray: nil) equals: #[90]
]

{ #category : #tests }
NeoUBJSONWriterTest >> testTrue [
	self assert: (NeoUBJSONWriter toByteArray: true) equals: #[84]
]
