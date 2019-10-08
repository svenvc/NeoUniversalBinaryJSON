Extension { #name : #Collection }

{ #category : #'*Neo-Universal-Binary-JSON' }
Collection >> neoUBJSONOn: writer [
	writer writeList: self
]
