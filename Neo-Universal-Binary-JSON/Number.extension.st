Extension { #name : #Number }

{ #category : #'*Neo-Universal-Binary-JSON' }
Number >> neoUBJSONOn: writer [
	writer writeFloat: self asFloat
]
