TARGET = firmware

# Set to 1 to build against ARM semihosting (real printf via gdb, needs a
# live debug session) instead of the default ITM/SWO path in syscalls.c.
# Only one can be linked at a time - librdimon (semihosting) and syscalls.c
# both define _close/_lseek/_open/_isatty/_unlink/_times/
# initialise_monitor_handles as strong symbols, so linking both causes
# "multiple definition" errors. See docs/stm32-embedded.md, "Debug console
# output: ITM/SWO vs ARM semihosting".
#
#   make                  # ITM/SWO printf (default)
#   make SEMIHOSTING=1    # semihosted printf, debugger must be attached
SEMIHOSTING ?= 0

ifeq ($(SEMIHOSTING),1)
BUILD_DIR = build-semihost
else
BUILD_DIR = build
endif

# --- Sources ---
C_SOURCES = \
Core/Src/main.c \
Core/Src/sysmem.c \
Drivers/CMSIS/Device/ST/STM32F3xx/Source/system_stm32f3xx.c

ifeq ($(SEMIHOSTING),0)
C_SOURCES += Core/Src/syscalls.c
endif

ASM_SOURCES = startup_stm32f303xc.s

# --- Includes ---
C_INCLUDES = \
-ICore/Inc \
-IDrivers/CMSIS/Device/ST/STM32F3xx/Include \
-IDrivers/CMSIS/Include

# --- Toolchain ---
PREFIX = arm-none-eabi-
CC = $(PREFIX)gcc
AS = $(PREFIX)gcc -x assembler-with-cpp
CP = $(PREFIX)objcopy
SZ = $(PREFIX)size

# --- MCU: Cortex-M4 with hardware FPU (STM32F303VCT6) ---
MCU = -mcpu=cortex-m4 -mthumb -mfpu=fpv4-sp-d16 -mfloat-abi=hard

C_DEFS = -DSTM32F303xC

CFLAGS = $(MCU) $(C_DEFS) $(C_INCLUDES) -Wall -Wextra -fdata-sections -ffunction-sections -g -O0 -std=gnu11
ASFLAGS = $(MCU) -g

LDSCRIPT = STM32F303VCTx_FLASH.ld

ifeq ($(SEMIHOSTING),1)
LIBS = -lc -lm
LDFLAGS = $(MCU) -specs=nano.specs -specs=rdimon.specs -T$(LDSCRIPT) $(LIBS) -Wl,-Map=$(BUILD_DIR)/$(TARGET).map,--cref -Wl,--gc-sections,--no-warn-rwx-segments
else
LIBS = -lc -lm -lnosys
LDFLAGS = $(MCU) -specs=nano.specs -T$(LDSCRIPT) $(LIBS) -Wl,-Map=$(BUILD_DIR)/$(TARGET).map,--cref -Wl,--gc-sections,--no-warn-rwx-segments
endif

# --- Build rules ---
OBJECTS = $(addprefix $(BUILD_DIR)/,$(notdir $(C_SOURCES:.c=.o)))
vpath %.c $(sort $(dir $(C_SOURCES)))
OBJECTS += $(addprefix $(BUILD_DIR)/,$(notdir $(ASM_SOURCES:.s=.o)))
vpath %.s $(sort $(dir $(ASM_SOURCES)))

all: $(BUILD_DIR)/$(TARGET).elf $(BUILD_DIR)/$(TARGET).hex $(BUILD_DIR)/$(TARGET).bin

$(BUILD_DIR)/%.o: %.c Makefile | $(BUILD_DIR)
	$(CC) -c $(CFLAGS) $< -o $@

$(BUILD_DIR)/%.o: %.s Makefile | $(BUILD_DIR)
	$(AS) -c $(ASFLAGS) $< -o $@

$(BUILD_DIR)/$(TARGET).elf: $(OBJECTS) Makefile
	$(CC) $(OBJECTS) $(LDFLAGS) -o $@
	$(SZ) $@

$(BUILD_DIR)/%.hex: $(BUILD_DIR)/%.elf
	$(CP) -O ihex $< $@

$(BUILD_DIR)/%.bin: $(BUILD_DIR)/%.elf
	$(CP) -O binary -S $< $@

$(BUILD_DIR):
	mkdir -p $@

clean:
	rm -rf build build-semihost

flash: $(BUILD_DIR)/$(TARGET).elf
	openocd -f board/stm32f3discovery.cfg -c "program $< verify reset exit"

.PHONY: all clean flash
