"
I am BaselineOfNeoUniversalBinaryJSON.
I am a BaselineOf.

I load the code of the Neo Binary JSON project.
"
Class {
	#name : #BaselineOfNeoUniversalBinaryJSON,
	#superclass : #BaselineOf,
	#category : #BaselineOfNeoUniversalBinaryJSON
}

{ #category : #baselines }
BaselineOfNeoUniversalBinaryJSON >> baselineOf: spec [
	spec for: #common do: [ 
		spec package: 'Neo-Universal-Binary-JSON'.
		spec package: 'Neo-Universal-Binary-JSON-Tests' with: [ spec requires: #('Neo-Universal-Binary-JSON') ].
		spec group: 'default' with: #('Neo-Universal-Binary-JSON' 'Neo-Universal-Binary-JSON-Tests').
		spec group: 'core' with: #('Neo-Universal-Binary-JSON') ]
]
