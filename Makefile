GNAT    := gnatmake
FLAGS   := -gnatwa -gnat2022
OBJ_DIR := obj
BIN_DIR := bin

.PHONY: all test run clean

all: $(BIN_DIR)/tests

$(BIN_DIR)/tests: *.ads *.adb *.gpr
	mkdir -p $(OBJ_DIR) $(BIN_DIR)
	$(GNAT) $(FLAGS) -Prule_30.gpr

test: all
	@echo "Running tests..."
	@$(BIN_DIR)/tests

run: all
	@$(BIN_DIR)/tests

clean:
	rm -rf $(OBJ_DIR) $(BIN_DIR)
