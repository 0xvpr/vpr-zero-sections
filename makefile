TARGET    = vpr-omega-zero

CC        = g++
CFLAGS    = -std=c++2a -O2 -Wall -Wextra -Werror -Wshadow -Wpedantic -Wconversion

LD        = g++
LDFLAGS   = 

BIN       = Bin
OBJ       = Build
BUILD     = Build
SOURCE    = Sources

SOURCES   = $(wildcard $(SOURCE)/*.cpp)
DEBUG     = $(patsubst $(SOURCE)/%.cpp,$(OBJ)/debug/%.obj,$(SOURCES))
RELEASE   = $(patsubst $(SOURCE)/%.cpp,$(OBJ)/release/%.obj,$(SOURCES))

INCLUDE   = Includes
INCLUDES  = $(addprefix -I,$(INCLUDE))

ifeq ($(PREFIX),)
PREFIX    = /usr/local
endif

MAKEFLAGS += -j$(shell nproc)

all: debug

debug:   CFLAGS  += -g
release: CFLAGS  += -DRELEASE -O3 -fno-ident -ffast-math -fvisibility=hidden
release: LDFLAGS += -s

debug:   $(BIN)/$(TARGET)_d
release: $(BIN)/$(TARGET)

$(BIN)/$(TARGET)_d: $(BIN) $(BUILD) $(DEBUG)
	$(LD) $(LDFLAGS) $(DEBUG) -o $(BIN)/$(TARGET)_d

$(BIN)/$(TARGET): $(BIN) $(BUILD) $(RELEASE)
	$(LD) $(LDFLAGS) $(RELEASE) -o $(BIN)/$(TARGET)

$(DEBUG): $(OBJ)/debug/%.obj : $(SOURCE)/%.cpp
	$(CC) $(CFLAGS) $(INCLUDES) -c $< -o $@

$(RELEASE): $(OBJ)/release/%.obj : $(SOURCE)/%.cpp
	$(CC) $(CFLAGS) $(INCLUDES) -c $< -o $@

$(BIN):
	mkdir -p $@

$(BUILD):
	mkdir -p $@/debug
	mkdir -p $@/release


.PHONY: tests
tests:
	make -C Tests/ELF all
	make -C Tests/PE all

.PHONY: install
install: release
	install -d $(PREFIX)/bin
	install -m 555 $(BIN)/$(TARGET) $(PREFIX)/bin

.PHONY: clean
clean:
	rm -fr $(BIN)/*
	rm -fr $(BUILD)/*
	make -C Tests/ELF clean
	make -C Tests/PE clean

.PHONY: extra-clean
extra-clean:
	rm -fr $(BIN)
	rm -fr $(BUILD)
	make -C Tests/ELF clean
	make -C Tests/PE clean
