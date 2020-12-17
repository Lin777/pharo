"
I am a command to create new subclass og given class (my targetClass)
"
Class {
	#name : #SycAddSubclassCommand,
	#superclass : #SycNewClassCreationCommand,
	#category : #'SystemCommands-ClassCommands'
}

{ #category : #activation }
SycAddSubclassCommand class >> browserContextMenuActivation [
	<classAnnotation>
	
	^ CmdContextMenuActivation  
		byItemOf: ClyMoreRefactorsMenuGroup  
		order: 10  
		for: ClyClass asCalypsoItemContext 
]

{ #category : #execution }
SycAddSubclassCommand >> asRefactorings [
	^ { RBAddClassRefactoring
		addClass: newClassName
		superclass: targetClass
		subclasses: #()
		category: targetClass category }
]

{ #category : #accessing }
SycAddSubclassCommand >> defaultMenuIconName [
	^#add
]

{ #category : #accessing }
SycAddSubclassCommand >> defaultMenuItemName [
	^'New subclass'
]
