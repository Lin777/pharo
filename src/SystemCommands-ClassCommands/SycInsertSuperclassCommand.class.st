"
I am a command to insert new superclass into my target class.
I create new class using supeclass of my target class. And I replace superclass of target class with new created class
"
Class {
	#name : #SycInsertSuperclassCommand,
	#superclass : #SycNewClassCreationCommand,
	#category : #'SystemCommands-ClassCommands'
}

{ #category : #activation }
SycInsertSuperclassCommand class >> browserContextMenuActivation [
	<classAnnotation>
	
	^ CmdContextMenuActivation  
		byItemOf: ClyMoreRefactorsMenuGroup  
		order: 30 
		for: ClyClass asCalypsoItemContext 
]

{ #category : #execution }
SycInsertSuperclassCommand >> asRefactorings [ 
	^ {RBAddClassRefactoring
		addClass: newClassName
		superclass: targetClass superclass
		subclasses: {targetClass}
		category: targetClass category}
]

{ #category : #accessing }
SycInsertSuperclassCommand >> defaultMenuIconName [
	^#smallLoadProject
]

{ #category : #accessing }
SycInsertSuperclassCommand >> defaultMenuItemName [
	^'Insert superclass'
]
