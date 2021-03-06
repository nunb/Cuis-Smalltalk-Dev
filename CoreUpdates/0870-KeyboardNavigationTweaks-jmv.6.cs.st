'From Cuis 3.1 of 4 March 2011 [latest update: #850] on 16 March 2011 at 5:48:06 pm'!!Editor methodsFor: 'typing/selecting keys' stamp: 'jmv 9/2/2009 12:38'!normalCharacter: aKeyboardEvent 	"A nonspecial character is to be added to the stream of characters."	self addString: aKeyboardEvent keyCharacter asString.	^false! !!Morph methodsFor: 'events-processing' stamp: 'jmv 3/16/2011 16:07'!focusKeyboardFor: aKeyboardEvent	"If aKeyboardEvent ctrl-tab or shift-ctrl-tab use it to navigate keyboard focus"	(aKeyboardEvent keyValue = 9 and: [ aKeyboardEvent controlKeyPressed ])		ifFalse: [ ^false ].	aKeyboardEvent shiftPressed		ifFalse: [ aKeyboardEvent hand keyboardFocusNext ]		ifTrue: [ aKeyboardEvent hand keyboardFocusPrevious ].	^ true! !!Morph methodsFor: 'macpal' stamp: 'jmv 3/16/2011 15:39'!flash	Display flash: self displayBounds! !!Morph methodsFor: 'testing' stamp: 'jmv 3/16/2011 15:48'!isReallyVisible	"Answer true only if all the owner chain is visible (i.e. if we are really visible!!)"	^self visible and: [ owner isReallyVisible ]! !!BareTextMorph methodsFor: 'event handling' stamp: 'jmv 3/16/2011 17:45'!keyboardFocusChange: aBoolean		"The message is sent to a morph when its keyboard focus changes.	The given argument indicates that the receiver is gaining (versus losing) the keyboard focus.	In this case, all we need to do is to redraw border feedback"	paragraph ifNotNil: [ paragraph focused: aBoolean ].	aBoolean		ifTrue: [			"A hand is wanting to send us characters..."			editor ifNil: [ self editor storeSelectionInParagraph ].	"Forces install"			self startBlinking ]		ifFalse: [ self stopBlinking ].	"Selection might be shown differently when focused"	"If (as usual) we are part of a TextModelMorph, invalidate it, to update the keyboard focus indicator"	owner ifNotNil: [ owner owner ifNotNil: [ :grandPa | ^ grandPa redrawNeeded ]].	self redrawNeeded! !!BareTextMorph methodsFor: 'private' stamp: 'jmv 3/16/2011 17:40'!updateFromParagraph	"A change has taken place in my paragraph, as a result of editing and I must be updated.  If a line break causes recomposition of the current paragraph, or it the selection has entered a different paragraph, then the current editor will be released, and must be reinstalled with the resulting new paragraph, while retaining any editor state, such as selection, undo state, and current typing emphasis."	"removed multiple lined paragraph support (predecessor and successor)"	| sel oldEditor |	paragraph ifNotNil: [		editor ifNotNil: [			oldEditor := editor.			sel := editor selectionInterval.			editor storeSelectionInParagraph].		self fit.		self layoutChanged.		sel ifNotNil: [			editor ifNil: [				"Reinstate selection after, eg, style change"				self installEditorToReplace: oldEditor]]].	editView setScrollDeltas! !!HandMorph methodsFor: 'focus handling' stamp: 'jmv 3/16/2011 16:10'!keyboardFocusNext	| firstCandidate candidate |	firstCandidate _ keyboardFocus		ifNil: [ World ]		ifNotNil: [ keyboardFocus previousMorph ].	candidate _ firstCandidate.	candidate handlesKeyboard ifFalse: [		[			candidate _ candidate previousMorph.			(candidate handlesKeyboard not or: [ candidate isReallyVisible not ])				and: [ candidate ~~ firstCandidate ] ] whileTrue ].	candidate activateWindowAndSendTopToBack: false.	self newKeyboardFocus: candidate! !!HandMorph methodsFor: 'focus handling' stamp: 'jmv 3/16/2011 16:10'!keyboardFocusPrevious	| firstCandidate candidate |	firstCandidate _ keyboardFocus		ifNil: [ World submorphs first ]		ifNotNil: [ keyboardFocus nextMorph ].		candidate _ firstCandidate.	candidate handlesKeyboard ifFalse: [		[			candidate _ candidate nextMorph.			(candidate handlesKeyboard not or: [ candidate isReallyVisible not ])				and: [ candidate ~~ firstCandidate ] ] whileTrue ].	candidate activateWindowAndSendTopToBack: true.	self newKeyboardFocus: candidate! !!HandMorph methodsFor: 'private events' stamp: 'jmv 3/16/2011 16:04'!generateKeyboardEvent: evtBuf 	"Generate the appropriate mouse event for the given raw event buffer"	| buttons modifiers type keyValue pressType stamp |	stamp _ evtBuf second.	stamp = 0 ifTrue: [stamp _ Time millisecondClockValue].	(evtBuf sixth <= 0 or: [		(keyValue _ (Character iso8859s15CodeForUnicodeCodePoint: evtBuf sixth)) isNil ])			ifTrue: [ keyValue _ Character macRomanToLatin1: evtBuf third ].	modifiers _ evtBuf fifth.	pressType _ evtBuf fourth.	pressType = EventSensor eventKeyDown ifTrue: [		type _ #keyDown.		lastKeyDownValue _ keyValue].	pressType = EventSensor eventKeyUp ifTrue: [type _ #keyUp].	pressType = EventSensor eventKeyChar ifTrue: [		type _ #keystroke.		"If Control key pressed, and the VM answers a code below 27,		 it means it did the translation, convert it back to regular character:		We want to handle the meaning of ctrl ourselves."		(modifiers anyMask: 2) ifTrue: [		"Control key pressed"			keyValue < 27 ifTrue: [								"But we don't want to do it for Home/End/PgUp/PgDn, just for alphabetic keys"				lastKeyDownValue = keyValue ifFalse: [		"If equal, real Home/End/PgUp/PgDn in Windows => don't translate"					(keyValue + 64 = lastKeyDownValue or: [ 	"If Equal, Ctrl-alphabetic in Windows => do translate"							lastKeyDownValue < 47 ]) ifTrue: [		"Not on windows. If less (not sure about the bound, but do not translate 48: tab on Mac), alphabetic on Mac => do translate"						keyValue _ (modifiers anyMask: 1)							ifFalse: [ keyValue + 96 ]	"shift not pressed: conver to lowercase letter"							ifTrue: [ keyValue + 64 ]].	"shift pressed: conver to uppercase letter"					]				].			"Act as if command/alt was pressed for some usual Windows ctrl-key combinations"			(self shouldControlEmulateAltFor: keyValue) ifTrue: [				modifiers _ modifiers bitOr: 8 ]			]].	buttons _ modifiers bitShift: 3.	^KeyboardEvent new 		setType: type		buttons: buttons		position: self position		keyValue: keyValue		hand: self		stamp: stamp! !!OneLineEditorMorph methodsFor: 'events-processing' stamp: 'jmv 3/16/2011 17:32'!focusKeyboardFor: aKeyboardEvent	"If aKeyboardEvent tab or shift-tab use it to navigate keyboard focus.	ctrl key ignored."	aKeyboardEvent keyValue = 9		ifFalse: [ ^false ].	aKeyboardEvent shiftPressed		ifFalse: [ aKeyboardEvent hand keyboardFocusNext ]		ifTrue: [ aKeyboardEvent hand keyboardFocusPrevious ].	^ true! !!PasteUpMorph methodsFor: 'testing' stamp: 'jmv 3/16/2011 15:48'!isReallyVisible	"Answer true only if all the owner chain is visible (i.e. if we are really visible!!)"	^self visible and: [ self isWorldMorph or: [ owner isReallyVisible ]]! !!TextEditor methodsFor: 'typing support' stamp: 'jmv 3/16/2011 15:59'!dispatchOn: aKeyboardEvent	"Carry out the action associated with this character, if any."	| asciiValue |	self clearParens.  	asciiValue _ aKeyboardEvent keyValue.	"Control keys are handled by KeystrokeActions even if they have any modifiers"	(asciiValue >= 32 and: [		aKeyboardEvent commandAltKeyPressed ]) ifTrue: [		^self perform: (self class cmdActions at: asciiValue + 1) with: aKeyboardEvent ].	(')]}' includes: aKeyboardEvent keyCharacter)		ifTrue: [ self blinkPrevParen: aKeyboardEvent ].	^ self perform: (KeystrokeActions at: asciiValue + 1) with: aKeyboardEvent! !!TextEditor methodsFor: 'typing support' stamp: 'jmv 3/16/2011 15:59'!processKeyStroke: aKeyboardEvent	"Key struck on the keyboard. Find out which one and, if special, carry 	out the associated special action. Otherwise, add the character to the 	stream of characters.  Undoer & Redoer: see closeTypeIn."			self deselect.					(self dispatchOn: aKeyboardEvent) ifTrue: [		self doneTyping.		self storeSelectionInParagraph.		^self].	self openTypeIn.							self hasSelection ifTrue: [ "save highlighted characters"		UndoSelection _ self selection].	self unselect.					self storeSelectionInParagraph! !