Extension { #name : #Dictionary }

{ #category : #'*Neo-Universal-Binary-JSON' }
Dictionary >> neoUBJSONOn: writer [
	writer writeMap: self
]
