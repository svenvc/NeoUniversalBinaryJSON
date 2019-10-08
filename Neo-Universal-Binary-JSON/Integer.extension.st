Extension { #name : #Integer }

{ #category : #'*Neo-Universal-Binary-JSON' }
Integer >> neoUBJSONOn: writer [
	writer writeInteger: self
]
