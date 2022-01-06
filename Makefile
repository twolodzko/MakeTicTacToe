MAKEFLAGS += --no-print-directory
MAKEFLAGS += --no-builtin-rules

ROW1 := . . .
ROW2 := . . .
ROW3 := . . .
X := $(firstword $(MOVE))
Y := $(word 2, $(MOVE))
WRONGMOVE = $(error "Invalid move:" $(MOVE))

PLAYER := o
ifeq ($(PLAYER), o)
NEXTPLAYER := x
else
NEXTPLAYER := o
endif

ifdef MOVE
POSITION := $(word $(X), $(ROW$(Y)))
else
POSITION := .
endif

takenfields = $(words $(filter $(PLAYER), $(1)))

play: print
	@ $(MAKE) move \
		MOVE="$(shell $(MAKE) input PLAYER=$(PLAYER))" \
		ROW1="$(ROW1)" \
		ROW2="$(ROW2)" \
		ROW3="$(ROW3)" \
		PLAYER=$(PLAYER)

print:
	@ echo "y\x 1 2 3"
	@ echo "1   $(ROW1)"
	@ echo "2   $(ROW2)"
	@ echo "3   $(ROW3)"

input:
	@ echo
	@ read -p "Player $(PLAYER) what's your move? (x y) " x y; echo $$x $$y;

move:
ifneq ($(POSITION), .)
	$(warning "This position is already taken")
	@ $(MAKE) play \
		ROW1="$(shell $(MAKE) setrow MOVE="$(MOVE)" ROW="$(ROW1)")" \
		ROW2="$(ROW2)" \
		ROW3="$(ROW3)" \
		PLAYER=$(PLAYER)
else ifeq ($(Y), 1)
	@ $(MAKE) isfinished \
		ROW1="$(shell $(MAKE) setrow MOVE="$(MOVE)" ROW="$(ROW1)")" \
		ROW2="$(ROW2)" \
		ROW3="$(ROW3)" \
		PLAYER=$(PLAYER)
else ifeq ($(Y), 2)
	@ $(MAKE) isfinished \
		ROW1="$(ROW1)" \
		ROW2="$(shell $(MAKE) setrow MOVE="$(MOVE)" ROW="$(ROW2)")" \
		ROW3="$(ROW3)" \
		PLAYER=$(PLAYER)
else ifeq ($(Y), 3)
	@ $(MAKE) isfinished \
		ROW1="$(ROW1)" \
		ROW2="$(ROW2)" \
		ROW3="$(shell $(MAKE) setrow MOVE="$(MOVE)" ROW="$(ROW3)")" \
		PLAYER=$(PLAYER)
else
	@ $(WRONGMOVE)
endif

isfinished:
	@ $(MAKE) next \
		ROW1="$(ROW1)" \
		ROW2="$(ROW2)" \
		ROW3="$(ROW3)" \
		PLAYER=$(PLAYER) \
		CHECK=$(shell $(MAKE) check \
			ROW1="$(ROW1)" \
			ROW2="$(ROW2)" \
			ROW3="$(ROW3)" \
			PLAYER=$(PLAYER))

next:
ifeq ($(CHECK), 3)
	@ echo
	@ echo "Player $(PLAYER) won!"
	@ $(MAKE) print \
		ROW1="$(ROW1)" \
		ROW2="$(ROW2)" \
		ROW3="$(ROW3)"
else
	@ $(MAKE) play \
		ROW1="$(ROW1)" \
		ROW2="$(ROW2)" \
		ROW3="$(ROW3)" \
		PLAYER=$(NEXTPLAYER)
endif

setrow:
ifeq ($(X), 1)
	@ echo "$(PLAYER) $(wordlist 2, 3, $(ROW))"
else ifeq ($(X), 2)
	@ echo "$(firstword $(ROW)) $(PLAYER) $(word 3, $(ROW))"
else ifeq ($(X), 3)
	@ echo "$(wordlist 1, 2, $(ROW)) $(PLAYER)"
else
	@ $(WRONGMOVE)
endif

check:
	@ echo $(firstword \
				$(filter 3, \
					$(shell $(MAKE) checkrows ROW1="$(ROW1)" ROW2="$(ROW2)" ROW3="$(ROW3)" PLAYER=$(PLAYER)) \
					$(shell $(MAKE) checkcols ROW1="$(ROW1)" ROW2="$(ROW2)" ROW3="$(ROW3)" PLAYER=$(PLAYER)) \
					$(shell $(MAKE) checkdiags ROW1="$(ROW1)" ROW2="$(ROW2)" ROW3="$(ROW3)" PLAYER=$(PLAYER))))

checkrows:
	@ echo $(foreach i, 1 2 3, \
			$(call takenfields, $(ROW$(i))))

checkcols:
	@ echo $(foreach j, 1 2 3, \
			$(call takenfields, \
				$(foreach i, 1 2 3, \
					$(word $(j), $(ROW$(i))))))

checkdiags:
	@ echo \
		$(call takenfields, \
			$(foreach i, 1 2 3, \
				$(word $(i), $(ROW$(i))))) \
		$(call takenfields, \
			$(word 1, $(ROW3)) \
			$(word 2, $(ROW2)) \
			$(word 3, $(ROW1)))
