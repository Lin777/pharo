Class {
	#name : #RBChildrenToSiblingsTransformationTest,
	#superclass : #RBTransformationTest,
	#category : #'Refactoring2-Transformations-Tests'
}

{ #category : #running }
RBChildrenToSiblingsTransformationTest >> childrenToSiblingTestData [

	^ '
| m |
(m:= RBNamespace2 
			onEnvironment: ((RBClassEnvironment onEnvironment: RBBrowserEnvironment new) 
					classes: (#(#ConcreteSubclass #ConcreteSuperclass #NoMoveSubclass) 
							inject: OrderedCollection new
							into: 
								[:sum :each | 
								| class |
								class := Smalltalk at: each ifAbsent: [nil].
								class notNil ifTrue: [sum add: class].
								sum]) 
								, (#(#ConcreteSubclass #ConcreteSuperclass #NoMoveSubclass) 
										inject: OrderedCollection new
										into: 
											[:sum :each | 
											| class |
											class := Smalltalk at: each ifAbsent: [nil].
											class notNil ifTrue: [sum add: class class].
											sum])) 
						not) 
		name: ''Test''.
#(''ConcreteSuperclass subclass: #NoMoveSubclass
	instanceVariableNames: ''''''''
	classVariableNames: ''''''''
	poolDictionaries: ''''''''
	category: ''''Testing'''''' ''Object subclass: #ConcreteSuperclass
	instanceVariableNames: ''''instVarName1 instVarName2 ''''
	classVariableNames: ''''ClassVarName1 ClassVarName2 ''''
	poolDictionaries: ''''''''
	category: ''''Testing'''''' ''ConcreteSuperclass subclass: #ConcreteSubclass
	instanceVariableNames: ''''''''
	classVariableNames: ''''''''
	poolDictionaries: ''''''''
	category: ''''Testing'''''') 
	do: [:each | m defineClass: each].
(m metaclassNamed: #ConcreteSuperclass) 
	addInstanceVariable: ''classInstVarName1''.
#(#(#ConcreteSubclass #(#(''initialize
	super initialize.
	instVarName1 := nil'' #everyone) #(''different
	^0'' #everyone))) #(#ConcreteSuperclass #(#(''same
	^self initialize isKindOf: ConcreteSuperclass'' #''one def'') #(''different
	^instVarName1 + instVarName2'' #everyone) #(''initialize
	instVarName1 := instVarName2 := ClassVarName1 := ClassVarName2 := 0'' #everyone))) #(#NoMoveSubclass #(#(''same
	^123'' #''one def''))) #(''ConcreteSubclass class'' #(#(''bar
	^self storeString'' #testing))) #(''ConcreteSuperclass class'' #(#(''foo
	^classInstVarName1 + ClassVarName1 + ClassVarName2'' #testing) #(''new
	^super new initialize'' #testing) #(''bar
	^self printString'' #testing))) #(''NoMoveSubclass class'' #())) 
	do: 
		[:each | 
		| class |
		class := m classNamed: each first.
		each last do: [:meth | class compile: meth first classified: meth last]].
m
'
]

{ #category : #running }
RBChildrenToSiblingsTransformationTest >> testBadName [

	self shouldFail: (RBChildrenToSiblingsTransformation
			 name: #'Obje ct'
			 class: RBLintRuleTestData
			 subclasses:
			 (Array
				  with: RBBasicLintRuleTestData
				  with: RBCompositeLintRuleTestData)) asRefactoring
]

{ #category : #running }
RBChildrenToSiblingsTransformationTest >> testExistingName [

	self
		shouldFail: (RBChildrenToSiblingsTransformation
				 name: #Object
				 class: RBLintRuleTestData
				 subclasses:
					 (Array
						  with: RBBasicLintRuleTestData
						  with: RBCompositeLintRuleTestData)) asRefactoring;
		shouldFail: (RBChildrenToSiblingsTransformation
				 name: #Processor
				 class: RBLintRuleTestData
				 subclasses:
					 (Array
						  with: RBBasicLintRuleTestData
						  with: RBCompositeLintRuleTestData)) asRefactoring
]

{ #category : #running }
RBChildrenToSiblingsTransformationTest >> testInvalidSubclass [

	self shouldFail: (RBChildrenToSiblingsTransformation
			 name: #Foo
			 class: RBRefactoringTest
			 subclasses:
			 (Array
				  with: RBBasicLintRuleTestData
				  with: RBCompositeLintRuleTestData)) asRefactoring
]

{ #category : #running }
RBChildrenToSiblingsTransformationTest >> testMetaClassFailure [

	self shouldFail: (RBChildrenToSiblingsTransformation
			 name: #Foo
			 class: RBLintRuleTestData class
			 subclasses: (Array
					  with: RBBasicLintRuleTestData class
					  with: RBCompositeLintRuleTestData class)) asRefactoring
]

{ #category : #running }
RBChildrenToSiblingsTransformationTest >> testModelChildrenToSibling [

	| refactoring class subclass superclass |
	model := Smalltalk compiler evaluate: self childrenToSiblingTestData.
	class := model classNamed: #ConcreteSuperclass.
	subclass := model classNamed: #ConcreteSubclass.
	refactoring := RBChildrenToSiblingsTransformation
		               model: model
		               name: #AbstractSuperclass
		               class: class
		               subclasses: (Array with: subclass).
	refactoring asRefactoring transform.
	superclass := refactoring model classNamed: #AbstractSuperclass.
	self assert: class superclass equals: superclass.
	self assert: class classSide superclass equals: superclass classSide.
	self assert: subclass superclass equals: superclass.
	self
		assert: subclass classSide superclass
		equals: superclass classSide.
	self
		assert: (superclass parseTreeFor: #same)
		equals: (self parseMethod:
				 'same ^self initialize isKindOf: AbstractSuperclass').
	self
		assert: (superclass parseTreeFor: #different)
		equals: (self parseMethod: 'different self subclassResponsibility').
	self
		assert: (superclass parseTreeFor: #initialize)
		equals: (self parseMethod: 'initialize
							instVarName1 := instVarName2 := ClassVarName1 := ClassVarName2 := 0').
	self assert:
		(superclass directlyDefinesInstanceVariable: 'instVarName1').
	self assert:
		(superclass directlyDefinesInstanceVariable: 'instVarName2').
	self assert:
		(superclass directlyDefinesClassVariable: 'ClassVarName1').
	self assert:
		(superclass directlyDefinesClassVariable: 'ClassVarName2').
	self assert: (superclass classSide directlyDefinesInstanceVariable:
			 'classInstVarName1').
	self
		assert: (superclass classSide parseTreeFor: #foo)
		equals: (self parseMethod: 'foo
							^classInstVarName1 + ClassVarName1 + ClassVarName2').
	self
		assert: (superclass classSide parseTreeFor: #new)
		equals: (self parseMethod: 'new
							^super new initialize').
	self
		assert: (superclass classSide parseTreeFor: #bar)
		equals: (self parseMethod: 'bar
							self subclassResponsibility').
	self deny: (class directlyDefinesInstanceVariable: 'instVarName1').
	self deny: (class directlyDefinesInstanceVariable: 'instVarName2').
	self deny: (class directlyDefinesClassVariable: 'ClassVarName1').
	self deny: (class directlyDefinesClassVariable: 'ClassVarName2').
	self deny:
		(class classSide directlyDefinesInstanceVariable:
			 'classInstVarName1').
	self deny: (class directlyDefinesMethod: #same).
	self deny: (class directlyDefinesMethod: #initialize).
	self deny: (class classSide directlyDefinesMethod: #new).
	self
		assert: (class parseTreeFor: #different)
		equals: (self parseMethod: 'different
							^instVarName1 + instVarName2').
	self
		assert: (class classSide parseTreeFor: #bar)
		equals: (self parseMethod: 'bar
							^self printString')
]
