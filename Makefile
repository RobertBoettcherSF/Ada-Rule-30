GNAT    := gnatmake
FLAGS   := -gnatwa -gnat2022 -gnata
OBJ_DIR := obj
BIN_DIR := bin
# Generations: make play GEN=80
GEN     ?=
# Animation: make play LIVE=1   OR   make live
# (Do NOT use: make play --live  — that is a make flag, not ours.)
LIVE    ?=

.PHONY: all test play run live clean

all: $(BIN_DIR)/tests $(BIN_DIR)/play

$(BIN_DIR)/tests: src/*.ads src/*.adb tests/tests.adb
	mkdir -p $(OBJ_DIR) $(BIN_DIR)
	$(GNAT) $(FLAGS) -D $(OBJ_DIR) -Isrc tests/tests.adb -o $(BIN_DIR)/tests

$(BIN_DIR)/play: src/*.ads src/*.adb src/play.adb
	mkdir -p $(OBJ_DIR) $(BIN_DIR)
	$(GNAT) $(FLAGS) -D $(OBJ_DIR) -Isrc src/play.adb -o $(BIN_DIR)/play

test: $(BIN_DIR)/tests
	$(BIN_DIR)/tests

# Default: one clean final frame (Linux Mint safe).
play run: $(BIN_DIR)/play
ifeq ($(LIVE),1)
	$(BIN_DIR)/play $(GEN) --live
else
	$(BIN_DIR)/play $(GEN)
endif

# Convenience: make live   /   make live GEN=40
live: $(BIN_DIR)/play
	$(BIN_DIR)/play $(GEN) --live

clean:
	rm -rf $(OBJ_DIR) $(BIN_DIR)
