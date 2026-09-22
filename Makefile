GNAT    := gnatmake
FLAGS   := -gnatwa -gnat2022 -gnata
OBJ_DIR := obj
BIN_DIR := bin
# Optional: make play GEN=80
GEN     ?=

.PHONY: all test play run clean

all: $(BIN_DIR)/tests $(BIN_DIR)/play

$(BIN_DIR)/tests: src/*.ads src/*.adb tests/tests.adb
	mkdir -p $(OBJ_DIR) $(BIN_DIR)
	$(GNAT) $(FLAGS) -D $(OBJ_DIR) -Isrc tests/tests.adb -o $(BIN_DIR)/tests

$(BIN_DIR)/play: src/*.ads src/*.adb src/play.adb
	mkdir -p $(OBJ_DIR) $(BIN_DIR)
	$(GNAT) $(FLAGS) -D $(OBJ_DIR) -Isrc src/play.adb -o $(BIN_DIR)/play

test: $(BIN_DIR)/tests
	$(BIN_DIR)/tests

play run: $(BIN_DIR)/play
	$(BIN_DIR)/play $(GEN)

clean:
	rm -rf $(OBJ_DIR) $(BIN_DIR)
