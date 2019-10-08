Extension { #name : #OrderedDictionary }

{ #category : #'*Neo-Universal-Binary-JSON' }
OrderedDictionary >> neoUBJSONOn: writer [
	writer writeMap: self
]
