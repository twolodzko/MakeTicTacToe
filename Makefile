MAKEFLAGS += --no-print-directory
MAKEFLAGS += --no-builtin-rules

BOARD := . . . . . . . . .
ROW1 := $(wordlist 1, 3, $(BOARD))
ROW2 := $(wordlist 4, 6, $(BOARD))
ROW3 := $(wordlist 7, 9, $(BOARD))
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
ifeq ($(words $(filter ., $(BOARD))), 0)
	@ $(warning "Nobody won.")
else
	@ $(MAKE) move \
		MOVE="$(shell $(MAKE) input PLAYER=$(PLAYER))" \
		BOARD="$(BOARD)" \
		PLAYER=$(PLAYER)
endif

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
		BOARD="$(BOARD)" \
		PLAYER=$(PLAYER)
else ifeq ($(Y), 1)
	@ $(MAKE) isfinished \
		BOARD="$(shell $(MAKE) setrow MOVE="$(MOVE)" ROW="$(ROW1)") $(ROW2) $(ROW3)" \
		PLAYER=$(PLAYER)
else ifeq ($(Y), 2)
	@ $(MAKE) isfinished \
		BOARD="$(ROW1) $(shell $(MAKE) setrow MOVE="$(MOVE)" ROW="$(ROW2)") $(ROW3)" \
		PLAYER=$(PLAYER)
else ifeq ($(Y), 3)
	@ $(MAKE) isfinished \
		BOARD="$(ROW1) $(ROW2) $(shell $(MAKE) setrow MOVE="$(MOVE)" ROW="$(ROW3)")" \
		PLAYER=$(PLAYER)
else
	@ $(WRONGMOVE)
endif

isfinished:
	@ $(MAKE) next \
		BOARD="$(BOARD)" \
		PLAYER=$(PLAYER) \
		CHECK=$(shell $(MAKE) check \
			BOARD="$(BOARD)" \
			PLAYER=$(PLAYER))

next:
ifeq ($(CHECK), 3)
	@ echo
	@ echo "Player $(PLAYER) won!"
	@ $(MAKE) print BOARD="$(BOARD)"
else
	@ $(MAKE) play \
		BOARD="$(BOARD)" \
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
