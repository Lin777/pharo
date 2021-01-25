Class {
	#name : #RBChangeMessageDriver,
	#superclass : #RBAbstractDriver,
	#instVars : [
		'originalMessage'
	],
	#category : #'SystemCommands-Utilities'
}

{ #category : #accessing }
RBChangeMessageDriver >> originalMessage [
	^ originalMessage ifNil: [ originalMessage := context lastSelectedMessage ]
]

{ #category : #actions }
RBChangeMessageDriver >> prepareFullExecution [
	self originalMessage
]
