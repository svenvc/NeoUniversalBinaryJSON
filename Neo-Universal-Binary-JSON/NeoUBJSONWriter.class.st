"
I am NeoUBJSONWriter.

I write/generate a Universal Binary JSON stream.

See also

http://ubjson.org
https://en.wikipedia.org/wiki/UBJSON

Usage

Use #on: to initialize me on a binary write stream and encode a value using #nextPut:.
My class side #toByteArray: is convenient too.

Notes

Integers are encoded using the smallest variant possible.
Lists (arrays) and maps (dictionaries) are always encoded with a count (#).
String of size 1 containing an ASCII character are encoded as a character (C).
Floats (and all non-integers) are always encoded as 64 bit doubles (D).
No list or map element types are emitted, except for ByteArray (uint8).

"
Class {
	#name : #NeoUBJSONWriter,
	#superclass : #Object,
	#instVars : [
		'stream'
	],
	#category : #'Neo-Universal-Binary-JSON'
}

{ #category : #'instance creation' }
NeoUBJSONWriter class >> on: binaryReadStream [
	^ self new
		on: binaryReadStream;
		yourself
]

{ #category : #convenience }
NeoUBJSONWriter class >> toByteArray: anObject [
	^ ByteArray streamContents: [ :out |
			(self on: out) nextPut: anObject ]
]

{ #category : #accessing }
NeoUBJSONWriter >> nextPut: anObject [
	"Encode anObject using UBJSON on my stream"
	
	anObject neoUBJSONOn: self
]

{ #category : #'instance creation' }
NeoUBJSONWriter >> on: binaryWriteStream [
	stream := binaryWriteStream
]

{ #category : #writing }
NeoUBJSONWriter >> writeByteArray: byteArray [
	"An array of element type uint8"
	stream nextPut: 91 "$[ asInteger"; nextPut: 36 "$$ asInteger"; nextPut: 85 "$U asInteger".
	self writeCount: byteArray size.
	stream nextPutAll: byteArray
]

{ #category : #writing }
NeoUBJSONWriter >> writeCount: count [ 	
	stream nextPut: 35 "$# asInteger".
	self writeInteger: count
]

{ #category : #writing }
NeoUBJSONWriter >> writeFalse [
	stream nextPut: 70 "$F asInteger"
]

{ #category : #writing }
NeoUBJSONWriter >> writeFloat: float [
	stream nextPut: 68 "$D asInteger".
	self writeInteger: (float at: 1) ofSize: 4 signed: false bigEndian: true.
	self writeInteger: (float at: 2) ofSize: 4 signed: false bigEndian: true.
]

{ #category : #writing }
NeoUBJSONWriter >> writeInteger: integer [
	(integer between: 0 and: 255)
		ifTrue: [ 
			stream nextPut: 85 "$U asInteger".
			^ stream nextPut: integer ].
	(integer between: -128 and: 127)
		ifTrue: [ 
			stream nextPut: 105 "$i asInteger".
			^ self writeInteger: integer ofSize: 1 signed: true bigEndian: true ].
	(integer between: -32768 and: 32767)
		ifTrue: [ 
			stream nextPut: 73 "$I asInteger".
			^ self writeInteger: integer ofSize: 2 signed: true bigEndian: true ].
	(integer between: -2147483648 and: 2147483647)
		ifTrue: [ 
			stream nextPut: 108 "$l asInteger".
			^ self writeInteger: integer ofSize: 4 signed: true bigEndian: true ].
	(integer between: -9223372036854775808 and: 9223372036854775807)
		ifTrue: [ 
			stream nextPut: 76 "$L asInteger".
			^ self writeInteger: integer ofSize: 8 signed: true bigEndian: true ].
	stream nextPut: 72 "$H asInteger".
	self writeStringData: integer asString
]

{ #category : #private }
NeoUBJSONWriter >> writeInteger: value ofSize: numberOfBytes signed: signed bigEndian: bigEndian [
	"Assuming the receiver is a stream of bytes, write value as the next integer of size numberOfBytes.
	If bigEndian is true, use network byte order, most significant byte first, 
	else use little endian order, least significant byte first.
	If signed is true, encode as a two-complement signed value, 
	else encode as a plain unsigned value."
	
	| unsignedValue |
	unsignedValue := (signed and: [ value negative ])
		ifTrue: [ (1 << (numberOfBytes * 8)) + value ] 
		ifFalse: [ value ].
	(unsignedValue between: 0 and: (2 ** (numberOfBytes * 8)) - 1)
		ifFalse: [ DomainError signalFrom: 0 to: (2 ** (numberOfBytes * 8)) - 1 ].
	bigEndian
		ifTrue: [ 
			numberOfBytes to: 1 by: -1 do: [ :index |
				stream nextPut: (unsignedValue byteAt: index) ] ]
		ifFalse: [ 
			1 to: numberOfBytes do: [ :index |
				stream nextPut: (unsignedValue byteAt: index) ] ].
	^ value
]

{ #category : #writing }
NeoUBJSONWriter >> writeList: collection [
	stream nextPut: 91 "$[ asInteger".
	self writeCount: collection size.
	collection do: [ :each | self nextPut: each ]
]

{ #category : #writing }
NeoUBJSONWriter >> writeMap: keysAndValues [
	stream nextPut: 123 "${ asInteger".
	self writeCount: keysAndValues size.
	keysAndValues keysAndValuesDo: [ :key :value |
		key isString ifFalse: [ self error: 'UBJSON requires strings keys' ].
		self writeStringData: key.
		self nextPut: value ]
]

{ #category : #writing }
NeoUBJSONWriter >> writeNil [
	stream nextPut: 90 "$Z asInteger"
]

{ #category : #writing }
NeoUBJSONWriter >> writeNoOp [
	stream nextPut: 78 "$N asInteger"
]

{ #category : #writing }
NeoUBJSONWriter >> writeObject: anObject [
	self error: 'UBJSON cannot serialize arbitrary objects'
]

{ #category : #writing }
NeoUBJSONWriter >> writeString: string [
	(string size = 1 and: [ string first asInteger < 128 ])
		ifTrue: [ 
			stream nextPut: 67 "$C asInteger".
			stream nextPut: string first asInteger ]
		ifFalse: [
			stream nextPut: 83 "$S asInteger".
			self writeStringData: string ]
]

{ #category : #writing }
NeoUBJSONWriter >> writeStringData: string [
	self writeInteger: (ZnUTF8Encoder default encodedByteCountForString: string).
	ZnUTF8Encoder default
		next: string size 
		putAll: string 
		startingAt: 1 
		toStream: stream
]

{ #category : #writing }
NeoUBJSONWriter >> writeTrue [
	stream nextPut: 84 "$T asInteger"
]
