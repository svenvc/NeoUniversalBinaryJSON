Extension { #name : #SmallDictionary }

{ #category : #'*Neo-Universal-Binary-JSON' }
SmallDictionary >> neoUBJSONOn: writer [
	writer writeMap: self
]
