Class {
	#name : #RBChangeMessageInteraction,
	#superclass : #RBAbstractInteraction,
	#instVars : [
		'originalMessage'
	],
	#category : #'Refactoring-Utilities'
}

{ #category : #accessing }
RBChangeMessageInteraction >> originalMessage [
	^ originalMessage ifNil: [ originalMessage := context lastSelectedMessage ]
]

{ #category : #actions }
RBChangeMessageInteraction >> prepareFullExecution [
	self originalMessage
]
