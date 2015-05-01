TARGET = main
.DEFAULT_GOAL = all

CROSS_COMPILE ?= arm-none-eabi-
CC := $(CROSS_COMPILE)gcc
CFLAGS = -fno-common -O0 \
	 -std=c99 \
	 -gdwarf-2 -ffreestanding -g3 \
	 -mcpu=cortex-m4 -mthumb -mfpu=fpv4-sp-d16 -mfloat-abi=softfp\
	 -Wall -Werror \
	 -Tmain.ld -nostartfiles \
	 -DUSER_NAME=\"$(USER)\"

ARCH = CM4F
VENDOR = ST
PLAT = STM32F4xx

CODEBASE = .
CMSIS_LIB = $(CODEBASE)/Libraries/CMSIS
STM32_LIB = $(CODEBASE)/Libraries/STM32F4xx_StdPeriph_Driver

CMSIS_PLAT_SRC = $(CMSIS_LIB)

FREERTOS_SRC = $(CODEBASE)/Libraries/freertos/Source
FREERTOS_INC = $(FREERTOS_SRC)/include/                                       
FREERTOS_PORT_INC = $(FREERTOS_SRC)/portable/GCC/ARM_$(ARCH)/

OUTDIR = build
SRCDIR = src\
         $(CMSIS_LIB) \
         $(STM32_LIB)/src \
         $(FREERTOS_SRC)
INCDIR = include \
         $(CMSIS_LIB) \
         $(STM32_LIB)/inc \
         $(FREERTOS_INC) \
	     $(FREERTOS_PORT_INC)
INCLUDES = $(addprefix -I,$(INCDIR))
DATDIR = data
TOOLDIR = tool
TMPDiR = output

HEAP_IMPL = heap_1
SRC = $(wildcard $(addsuffix /*.c,$(SRCDIR))) \
      $(wildcard $(addsuffix /*.s,$(SRCDIR))) \
      $(FREERTOS_SRC)/portable/MemMang/$(HEAP_IMPL).c \
      $(FREERTOS_SRC)/portable/GCC/ARM_$(ARCH)/port.c \
      $(CMSIS_PLAT_SRC)/startup_stm32f4xx.s
OBJ := $(addprefix $(OUTDIR)/,$(patsubst %.s,%.o,$(SRC:.c=.o)))
DEP = $(OBJ:.o=.o.d)
DAT =
 
MAKDIR = mk
MAK = $(wildcard $(MAKDIR)/*.mk)

include $(MAK)


all: $(OUTDIR)/$(TARGET).bin $(OUTDIR)/$(TARGET).lst

$(OUTDIR)/$(TARGET).bin: $(OUTDIR)/$(TARGET).elf
	@echo "    OBJCOPY "$@
	@$(CROSS_COMPILE)objcopy -Obinary $< $@

$(OUTDIR)/$(TARGET).lst: $(OUTDIR)/$(TARGET).elf
	@echo "    LIST    "$@
	@$(CROSS_COMPILE)objdump -S $< > $@

$(OUTDIR)/$(TARGET).elf: $(OBJ) $(DAT)
	@echo "    LD      "$@
	@echo "    MAP     "$(OUTDIR)/$(TARGET).map
	@$(CROSS_COMPILE)gcc $(CFLAGS) -Wl,-Map=$(OUTDIR)/$(TARGET).map -o $@ $^

$(OUTDIR)/%.o: %.c
	@mkdir -p $(dir $@)
	@echo "    CC      "$@
	@$(CROSS_COMPILE)gcc $(CFLAGS) -MMD -MF $@.d -o $@ -c $(INCLUDES) $<

$(OUTDIR)/%.o: %.s
	@mkdir -p $(dir $@)
	@echo "    CC      "$@
	@$(CROSS_COMPILE)gcc $(CFLAGS) -MMD -MF $@.d -o $@ -c $(INCLUDES) $<

clean:
	rm -rf $(OUTDIR) $(TMPDIR)

-include $(DEP)



