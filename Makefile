GNAT    := gnatmake
FLAGS   := -gnatwa -gnat2022 -gnata
OBJ_DIR := obj
BIN_DIR := bin
# Generations: make play GEN=40  (default 16)
GEN     ?=
# ONCE=1 → single frame, no animation
ONCE    ?=

.PHONY: all test play run live once clean

all: $(BIN_DIR)/tests $(BIN_DIR)/play

$(BIN_DIR)/tests: src/*.ads src/*.adb tests/tests.adb
	mkdir -p $(OBJ_DIR) $(BIN_DIR)
	$(GNAT) $(FLAGS) -D $(OBJ_DIR) -Isrc tests/tests.adb -o $(BIN_DIR)/tests

$(BIN_DIR)/play: src/*.ads src/*.adb src/play.adb
	mkdir -p $(OBJ_DIR) $(BIN_DIR)
	$(GNAT) $(FLAGS) -D $(OBJ_DIR) -Isrc src/play.adb -o $(BIN_DIR)/play

test: $(BIN_DIR)/tests
	$(BIN_DIR)/tests

# Default: live animation, 16 generations (override with GEN=).
play run live: $(BIN_DIR)/play
ifeq ($(ONCE),1)
	$(BIN_DIR)/play $(GEN) --once
else
	$(BIN_DIR)/play $(GEN) --live
endif

# Single final frame (no clear / no animation).
once: $(BIN_DIR)/play
	$(BIN_DIR)/play $(GEN) --once

clean:
	rm -rf $(OBJ_DIR) $(BIN_DIR)
