#
# This is a project Makefile. It is assumed the directory this Makefile resides in is a
# project subdirectory.
#

PROJECT_NAME := web_server_uploader_esp8266

EXTRA_COMPONENT_DIRS := $(IDF_PATH)/examples/common_components/protocol_examples_common 

include $(IDF_PATH)/make/project.mk

PROJECT_PATH ?= $(CURDIR)
BUILD_DIR_BASE ?= $(PROJECT_PATH)/build 

UTILITY_DIR := $(PROJECT_PATH)/utility
STORAGE_DIR ?= $(PROJECT_PATH)/storage
STORAGE_BIN ?= $(BUILD_DIR_BASE)/spiffs.bin
PARTITION_NAME := $(shell awk -F'[=]' '/^CONFIG_PARTITION_TABLE_CUSTOM_FILENAME/ {gsub(/[ "]/,""); print $$2}' $(PROJECT_PATH)/sdkconfig)
STORAGE_OFFSET := $(shell awk '/^storage/ {gsub(",",""); print $$4}' $(PROJECT_PATH)/$(PARTITION_NAME))
STORAGE_LEN := $(shell awk '/^storage/ {gsub(",",""); print $$5}' $(PROJECT_PATH)/$(PARTITION_NAME))
STORAGE_EXE := $(ESPTOOLPY) --port $(ESPPORT) --baud $(ESPBAUD) write_flash -z $(STORAGE_OFFSET) $(STORAGE_BIN) 
MKSPIFFS := $(UTILITY_DIR)/mkspiffs/mkspiffs
MKSPIFFS_DIR := $(UTILITY_DIR)/mkspiffs
MKSPIFFS_EXE := $(MKSPIFFS) -c $(STORAGE_DIR) -b 4096 -p 256 -s $(STORAGE_LEN) $(STORAGE_BIN)

storage: $(BUILD_DIR_BASE)/include/sdkconfig.h mkspiffs
	@echo $(STORAGE_EXE)
	$(STORAGE_EXE)
	
$(BUILD_DIR_BASE)/include/sdkconfig.h: all

mkspiffs: $(MKSPIFFS_DIR)/Makefile make_mkspiffs
	@echo $(MKSPIFFS_EXE)
	$(MKSPIFFS_EXE)
	
$(MKSPIFFS_DIR)/Makefile:
	git clone "https://github.com/igrr/mkspiffs.git"  $(MKSPIFFS_DIR)
	git -C $(MKSPIFFS_DIR) submodule update --init
	cat $(UTILITY_DIR)/mkspiffs.mk >> $(MKSPIFFS_DIR)/Makefile
	
make_mkspiffs: override CXX:=g++
make_mkspiffs: override CC:=$(HOSTCC)
make_mkspiffs: override LD:=$(HOSTLD)
make_mkspiffs: override AR:=$(HOSTAR)
make_mkspiffs: override OBJCOPY:=$(HOSTOBJCOPY)
make_mkspiffs: override SIZE:=$(HOSTSIZE)
make_mkspiffs: override CPPFLAGS:=
make_mkspiffs: override CXXFLAGS:=
make_mkspiffs: override CFLAGS:=
make_mkspiffs:
	cp -f $(BUILD_DIR_BASE)/include/sdkconfig.h  $(MKSPIFFS_DIR)/include
	$(MAKE) -C $(MKSPIFFS_DIR) all
	
cleanall: clean
	$(MAKE) -C $(MKSPIFFS_DIR) clean
	
.PHONY:	storage cleanall

