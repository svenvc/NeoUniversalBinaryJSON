Extension { #name : #ByteArray }

{ #category : #'*Neo-Universal-Binary-JSON' }
ByteArray >> neoUBJSONOn: writer [
	writer writeByteArray: self
]
