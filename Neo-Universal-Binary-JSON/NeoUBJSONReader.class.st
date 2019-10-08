"
I am NeoUBJSONReader.

I read/parse a Universal Binary JSON stream.

See also

http://ubjson.org
https://en.wikipedia.org/wiki/UBJSON

Usage

Use #on: to initialize me on a binary read stream and decode a value using #next.
My class side #fromByteArray: is convenient too.

Notes

This is a complete implementation of the specification.
Lists/arrays of type uint8 are converted to a ByteArray.
"
Class {
	#name : #NeoUBJSONReader,
	#superclass : #Object,
	#instVars : [
		'stream',
		'handlers',
		'stringStream',
		'byteStream'
	],
	#category : #'Neo-Universal-Binary-JSON'
}

{ #category : #convenience }
NeoUBJSONReader class >> fromByteArray: byteArray [
	^ (self on: byteArray readStream) next
]

{ #category : #'instance creation' }
NeoUBJSONReader class >> on: binaryReadStream [
	^ self new
		on: binaryReadStream;
		yourself
]

{ #category : #testing }
NeoUBJSONReader >> atEnd [
	^ stream atEnd
]

{ #category : #private }
NeoUBJSONReader >> errorEOF [
	self error: 'End of UBJSON stream reached'
]

{ #category : #initialization }
NeoUBJSONReader >> initialize [
	handlers := (self typeTagHandlers
		collect: [ :each | each key asInteger -> each value ]) asDictionary.
	handlers at: nil put: #errorEOF
]

{ #category : #accessing }
NeoUBJSONReader >> next [
	"Return the next UBJSON encoded value from my stream."
	
	| handler |
	handler := self readType.
	^ self perform: handler
]

{ #category : #'instance creation' }
NeoUBJSONReader >> on: binaryReadStream [
	stream := binaryReadStream
]

{ #category : #reading }
NeoUBJSONReader >> readByteArray: size [
	"An array of element type uint8"
	^ stream next: size
]

{ #category : #reading }
NeoUBJSONReader >> readChar [
	| code |
	code := stream next.
	code > 127
		ifTrue: [ ^ self error: 'Non-ASCII code point for UBJSON character' ].
	^ code asCharacter asString
]

{ #category : #reading }
NeoUBJSONReader >> readFloat32 [
	^ Float fromIEEE32Bit: (self readIntegerOfSize: 4 signed: false bigEndian: true)
]

{ #category : #reading }
NeoUBJSONReader >> readFloat64 [
	^ Float fromIEEE64Bit: (self readIntegerOfSize: 8 signed: false bigEndian: true)
]

{ #category : #reading }
NeoUBJSONReader >> readHighPrecisionNumber [
	^ self readString asNumber
]

{ #category : #reading }
NeoUBJSONReader >> readInt16 [
	^ self readIntegerOfSize: 2 signed: true bigEndian: true
]

{ #category : #reading }
NeoUBJSONReader >> readInt32 [
	^ self readIntegerOfSize: 4 signed: true bigEndian: true
]

{ #category : #reading }
NeoUBJSONReader >> readInt64 [
	^ self readIntegerOfSize: 8 signed: true bigEndian: true
]

{ #category : #reading }
NeoUBJSONReader >> readInt8 [
	^ self readIntegerOfSize: 1 signed: true bigEndian: true
]

{ #category : #private }
NeoUBJSONReader >> readIntegerOfSize: numberOfBytes signed: signed bigEndian: bigEndian [
	"Read the next integer of size numberOfBytes from stream.
	If bigEndian is true, use network byte order, most significant byte first, 
	else use little endian order, least significant byte first.
	If signed is true, interpret as a two-complement signed value, 
	else interpret as a plain unsigned value."
	
	| value |
	value := 0.
	bigEndian
		ifTrue: [ 
			(numberOfBytes - 1) * 8 to: 0 by: -8 do: [ :shift |
				value := value + (stream next bitShift: shift) ] ]
		ifFalse: [ 
			0 to: (numberOfBytes - 1) * 8 by: 8 do: [ :shift |
				value := value + (stream next bitShift: shift) ] ].
	^ (signed and: [ (value bitAt: numberOfBytes * 8) = 1 ])
		ifTrue: [ value - (1 << (numberOfBytes * 8)) ]
		ifFalse: [ value ]
]

{ #category : #private }
NeoUBJSONReader >> readIntoByteBuffer: byteLength [
	byteStream ifNil: [ byteStream := (ByteArray new: 256) readStream ].
	byteLength > byteStream originalContents size
		ifTrue: [ byteStream on: (ByteArray new: (byteLength // 256 + 1) * 256) ].
	stream
		readInto: byteStream originalContents
		startingAt: 1
		count: byteLength.
	byteStream setFrom: 1 to: byteLength
]

{ #category : #private }
NeoUBJSONReader >> readLength [
	| length |
	length := self next.
	(length isInteger and: [ length positive ])
		ifFalse: [ self error: 'UBJSON integer expected for length' ].
	^ length
]

{ #category : #reading }
NeoUBJSONReader >> readList [
	^ self withElementTypeAndCount: [ :elementType :count |
		count
			ifNil: [ 
				Array streamContents: [ :out |
					[ stream peekFor: 93 "$] asInteger" ] 
						whileFalse: [ out nextPut: self next ] ] ]
			ifNotNil: [
				elementType = #readUInt8 
					ifTrue: [ ^ self readByteArray: count ].
				Array new: count streamContents: [ :out |
					elementType 
						ifNil: [
							count timesRepeat: [ out nextPut: self next ] ] 
						ifNotNil: [
							count timesRepeat: [ out nextPut: (self perform: elementType) ] ]  ] ] ]
]

{ #category : #reading }
NeoUBJSONReader >> readMap [
	^ self withElementTypeAndCount: [ :elementType :count | | dictionary |
		dictionary := count ifNil: [ Dictionary new ] ifNotNil: [ Dictionary new: count ].
		count
			ifNil: [ 
				[ stream peekFor: 125 "$} asInteger" ] 
					whileFalse: [ dictionary at: self readString put: self next ] ]
			ifNotNil: [ 
				elementType 
					ifNil: [
						count timesRepeat: [ dictionary at: self readString put: self next ] ]
					ifNotNil: [
						count timesRepeat: [ dictionary at: self readString put: (self perform: elementType ) ] ] ].
		dictionary ]
]

{ #category : #reading }
NeoUBJSONReader >> readString [
	| byteLength encoder |
	byteLength := self readLength.
	self readIntoByteBuffer: byteLength.
	encoder := ZnUTF8Encoder default.
	^ self stringStreamContents: [ :out |
		[ byteStream atEnd ] whileFalse: [ | codePoint |
			codePoint := encoder nextCodePointFromStream: byteStream.
			(codePoint > 255 and: [ out originalContents isWideString not ])
				ifTrue: [ | wideString position |
					position := out position.
					wideString := WideString from: out originalContents.
					out on: wideString; setFrom: position + 1 to: position ].
			out nextPut: (Character value: codePoint) ] ]
]

{ #category : #reading }
NeoUBJSONReader >> readType [
	| typeTag |
	^ handlers 
		at: (typeTag := stream next)
		ifPresent: [ :handler | ^ handler ] 
		ifAbsent: [ self error: 'Unknown UBJSON type tag: ' , typeTag asString ]
]

{ #category : #reading }
NeoUBJSONReader >> readUInt8 [
	^ stream next
]

{ #category : #reading }
NeoUBJSONReader >> returnFalse [
	^ false
]

{ #category : #reading }
NeoUBJSONReader >> returnNil [
	^ nil
]

{ #category : #reading }
NeoUBJSONReader >> returnTrue [
	^ true
]

{ #category : #private }
NeoUBJSONReader >> stringStreamContents: block [
	stringStream ifNil: [ 
		stringStream := (String new: 32) writeStream ].
	stringStream reset.
	block value: stringStream.
	^ stringStream contents
]

{ #category : #private }
NeoUBJSONReader >> typeTagHandlers [
	^ { 
		$N -> #next. $Z -> #returnNil. $T -> #returnTrue. $F -> #returnFalse.
		$i -> #readInt8. $U -> #readUInt8. $I -> #readInt16. $l -> #readInt32. $L -> #readInt64.
		$d -> #readFloat32. $D -> #readFloat64. $H -> #readHighPrecisionNumber.
		$C -> #readChar. $S -> #readString.
		$[ -> #readList. ${ -> #readMap.
	 }
]

{ #category : #private }
NeoUBJSONReader >> withElementTypeAndCount: block [
	| elementType count |
	elementType := count := nil.
	(stream peekFor: 36 "$$ asInteger")
		ifTrue: [ elementType := self readType ].
	(stream peekFor: 35 "$# asInteger")
		ifTrue: [ count := self readLength ].
	(elementType notNil and: [ count isNil ])
		ifTrue: [ self error: 'UBJSON container with type has no count' ].
	^ block value: elementType value: count
]
