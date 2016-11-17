PROJ_NAME=vcof

PROJ_DIR=/home/sig/stmprojects/vcof
PROJ_BUILD_DIR=/home/sig/stmprojects/vcof/bin

STM_DIR=$(PROJ_DIR)/lib
STM_SRC=$(STM_DIR)/STM32F4xx_StdPeriph_Driver/src

vpath %.c $(STM_SRC)

SRC_DIR = $(PROJ_DIR)/src

SRCS = $(SRC_DIR)/main.c
SRCS += $(STM_DIR)/STM32F4-Discovery/stm32f4_discovery.c
SRCS += $(SRC_DIR)/system_stm32f4xx.c
SRCS += $(STM_SRC)/stm32f4xx_rcc.c 
SRCS += $(STM_SRC)/stm32f4xx_gpio.c
SRCS += $(STM_SRC)/stm32f4xx_dac.c
SRCS += $(STM_SRC)/stm32f4xx_tim.c
SRCS += $(STM_SRC)/stm32f4xx_dma.c
SRCS += $(STM_SRC)/stm32f4xx_exti.c
SRCS += $(STM_SRC)/stm32f4xx_syscfg.c
SRCS += $(STM_SRC)/misc.c


SRCS += $(STM_DIR)/CMSIS/ST/STM32F4xx/Source/Templates/TrueSTUDIO/startup_stm32f4xx.s

INC_DIRS  = $(STM_DIR)/STM32F4-Discovery
INC_DIRS += $(PROJ_DIR)/include
INC_DIRS += $(STM_DIR)/CMSIS/Include
INC_DIRS += $(STM_DIR)/CMSIS/ST/STM32F4xx/Include
INC_DIRS += $(STM_DIR)/STM32F4xx_StdPeriph_Driver/inc
INC_DIRS += .

CC	= arm-none-eabi-gcc
OBJCOPY = arm-none-eabi-objcopy
GDB	= arm-none-eabi-gdb

INCLUDE	= $(addprefix -I,$(INC_DIRS))

DEFS	= -DUSE_STDPERIPH_DRIVER
#DEFS	+= -DUSE_FULL_ASSERT

CFLAGS	= -ggdb

CFLAGS	+= -O0
CFLAGS	+= -Wall -Wextra -Warray-bounds
CFLAGS	+= -mlittle-endian -mthumb -mcpu=cortex-m4 -mthumb-interwork
CFLAGS	+= -mfloat-abi=hard -mfpu=fpv4-sp-d16
CFLAGS	+= -lc -lm -specs=nosys.specs

LFLAGS	= -T$(STM_DIR)/stm32_flash.ld

######################################################################
#                         SETUP TARGETS                              #
######################################################################

.PHONY: $(PROJ_NAME)
	$(PROJ_NAME): $(PROJ_BUILD_DIR)/$(PROJ_NAME).elf

$(PROJ_BUILD_DIR)/$(PROJ_NAME).elf: $(SRCS)
	$(CC) $(INCLUDE) $(DEFS) $(CFLAGS) $(LFLAGS) $^ -o $@ 
	$(OBJCOPY) -O ihex $(PROJ_BUILD_DIR)/$(PROJ_NAME).elf $(PROJ_BUILD_DIR)/$(PROJ_NAME).hex
	$(OBJCOPY) -O binary $(PROJ_BUILD_DIR)/$(PROJ_NAME).elf $(PROJ_BUILD_DIR)/$(PROJ_NAME).bin

clean:
	rm -f $(PROJ_BUILD_DIR)/*.o $(PROJ_BUILD_DIR)/$(PROJ_NAME).elf $(PROJ_BUILD_DIR)/$(PROJ_NAME).hex $(PROJ_BUILD_DIR)/$(PROJ_NAME).bin

# Flash the STM32F4
flash: 
	/home/sig/stlink/build/st-flash write $(PROJ_BUILD_DIR)/$(PROJ_NAME).bin 0x8000000

.PHONY: debug
debug:
# before you start gdb, you must start st-util
	$(GDB) $(PROJ_BUILD_DIR)/$(PROJ_NAME).elf

