Class {
	#name : #NeoUBJSONReaderTest,
	#superclass : #TestCase,
	#category : #'Neo-Universal-Binary-JSON-Tests'
}

{ #category : #tests }
NeoUBJSONReaderTest >> testEmpty [
	self assert: (NeoUBJSONReader on: #[] readStream) atEnd.
	self should: [ (NeoUBJSONReader on: #[] readStream) next ] raise: Error.
	self should: [ (NeoUBJSONReader on: #[78 78 78] readStream) next ] raise: Error.
]

{ #category : #tests }
NeoUBJSONReaderTest >> testFalse [
	self assert: (NeoUBJSONReader on: #[70] readStream) next equals: false
]

{ #category : #tests }
NeoUBJSONReaderTest >> testInt8 [
	self assert: (NeoUBJSONReader on: #[105 42] readStream) next equals: 42.
	self assert: (NeoUBJSONReader on: #[105 0] readStream) next equals: 0.
	self assert: (NeoUBJSONReader on: #[105 127] readStream) next equals: 127.
	self assert: (NeoUBJSONReader on: #[105 128] readStream) next equals: -128.
	self assert: (NeoUBJSONReader on: #[105 255] readStream) next equals: -1.
]

{ #category : #tests }
NeoUBJSONReaderTest >> testNil [
	self assert: (NeoUBJSONReader on: #[90] readStream) next equals: nil
]

{ #category : #tests }
NeoUBJSONReaderTest >> testNoOp [
	self assert: (NeoUBJSONReader on: #[78 90] readStream) next equals: nil
]

{ #category : #tests }
NeoUBJSONReaderTest >> testTrue [
	self assert: (NeoUBJSONReader on: #[84] readStream) next equals: true
]

{ #category : #tests }
NeoUBJSONReaderTest >> testUInt8 [
	self assert: (NeoUBJSONReader on: #[85 42] readStream) next equals: 42.
	self assert: (NeoUBJSONReader on: #[85 0] readStream) next equals: 0.
	self assert: (NeoUBJSONReader on: #[85 127] readStream) next equals: 127.
	self assert: (NeoUBJSONReader on: #[85 128] readStream) next equals: 128.
	self assert: (NeoUBJSONReader on: #[85 255] readStream) next equals: 255.
]
