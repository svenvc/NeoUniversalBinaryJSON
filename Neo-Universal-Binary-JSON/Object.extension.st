Extension { #name : #Object }

{ #category : #'*Neo-Universal-Binary-JSON' }
Object >> neoUBJSONOn: writer [
	writer writeObject: self
]
