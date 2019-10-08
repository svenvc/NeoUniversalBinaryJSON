Extension { #name : #String }

{ #category : #'*Neo-Universal-Binary-JSON' }
String >> neoUBJSONOn: writer [
	writer writeString: self
]
