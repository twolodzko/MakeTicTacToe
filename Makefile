MAKEFLAGS += --no-print-directory

BOARD := . . . . . . . . .
ROW1 := $(wordlist 1, 3, $(BOARD))
ROW2 := $(wordlist 4, 6, $(BOARD))
ROW3 := $(wordlist 7, 9, $(BOARD))
X := $(firstword $(MOVE))
Y := $(word 2, $(MOVE))

PLAYER := o
ifeq ($(PLAYER), o)
NEXTPLAYER := x
else
NEXTPLAYER := o
endif

ifdef MOVE
HERE := $(word $(X), $(ROW$(Y)))
else
HERE := .
endif

wrongmove = $(error "Invalid move:" $(MOVE))
takenfields = $(words $(filter $(PLAYER), $(1)))

play: show
ifeq ($(words $(filter ., $(BOARD))), 0)
	@ $(warning "Nobody won.")
else
	@ $(MAKE) makemove \
		MOVE="$(shell $(MAKE) getinput PLAYER=$(PLAYER))" \
		BOARD="$(BOARD)" \
		PLAYER=$(PLAYER)
endif

show:
	@ echo "y\x 1 2 3"
	@ echo "1   $(ROW1)"
	@ echo "2   $(ROW2)"
	@ echo "3   $(ROW3)"

getinput:
	@ echo
	@ read -p "Player $(PLAYER) what's your move? (x y) " x y; echo $$x $$y;

makemove:
ifneq ($(HERE), .)
	$(warning "This position is already taken")
	@ $(MAKE) play \
		BOARD="$(BOARD)" \
		PLAYER=$(PLAYER)
else ifeq ($(Y), 1)
	@ $(MAKE) isfinished \
		BOARD="$(shell $(MAKE) set MOVE="$(MOVE)" ROW="$(ROW1)") $(ROW2) $(ROW3)" \
		PLAYER=$(PLAYER)
else ifeq ($(Y), 2)
	@ $(MAKE) isfinished \
		BOARD="$(ROW1) $(shell $(MAKE) set MOVE="$(MOVE)" ROW="$(ROW2)") $(ROW3)" \
		PLAYER=$(PLAYER)
else ifeq ($(Y), 3)
	@ $(MAKE) isfinished \
		BOARD="$(ROW1) $(ROW2) $(shell $(MAKE) set MOVE="$(MOVE)" ROW="$(ROW3)")" \
		PLAYER=$(PLAYER)
else
	@ $(wrongmove)
endif

isfinished:
	@ $(MAKE) nextturn \
		BOARD="$(BOARD)" \
		PLAYER=$(PLAYER) \
		CHECK=$(shell $(MAKE) check BOARD="$(BOARD)" PLAYER=$(PLAYER))

nextturn:
ifeq ($(CHECK), 3)
	@ echo
	@ echo "Player $(PLAYER) won!"
	@ $(MAKE) show BOARD="$(BOARD)"
else
	@ $(MAKE) play \
		BOARD="$(BOARD)" \
		PLAYER=$(NEXTPLAYER)
endif

set:
ifeq ($(X), 1)
	@ echo "$(PLAYER) $(wordlist 2, 3, $(ROW))"
else ifeq ($(X), 2)
	@ echo "$(firstword $(ROW)) $(PLAYER) $(word 3, $(ROW))"
else ifeq ($(X), 3)
	@ echo "$(wordlist 1, 2, $(ROW)) $(PLAYER)"
else
	@ $(wrongmove)
endif

check:
	@ echo $(firstword \
				$(filter 3, \
					$(shell $(MAKE) checkrows BOARD="$(BOARD)" PLAYER=$(PLAYER)) \
					$(shell $(MAKE) checkcols BOARD="$(BOARD)" PLAYER=$(PLAYER)) \
					$(shell $(MAKE) checkdiags BOARD="$(BOARD)" PLAYER=$(PLAYER))))

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
