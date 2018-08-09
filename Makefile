
SRC_DIR = SEAL/seal
SEAL_URL = "https://download.microsoft.com/download/B/3/7/B3720F6B-4F4A-4B54-9C6C-751EF194CBE7/SEAL_2.3.1.tar.gz"
SEAL_ROOT_DIR = SEAL_2.3.1


all: download fix_original
.PHONY: download fix_original

# OBTAINING LIBRARY: download and extract
download:
	wget $(SEAL_URL)
	tar xf $(SEAL_ROOT_DIR).tar.gz --strip-components=1
	@rm $(SEAL_ROOT_DIR).tar.gz

fix_original:
	# Removing unnecesary files
	@rm -rf SEALExamples SEALNETExamples SEALTest\
		   SEALNET SEALNETTest SEAL.sln INSTALL.txt\
	       SEAL/CMakeLists.txt SEAL/SEAL.vcxproj \
		   SEAL/SEAL.vcxproj.filters SEAL/cmake
	# Fixing errors in relative paths wrt. imports
	@mv $(SRC_DIR)/util/* $(SRC_DIR)
	@find ./$(SRC_DIR) -name '*.*' -exec sed -i 's-"seal/-"-g' {} \;
	@find ./$(SRC_DIR) -name '*.*' -exec sed -i 's-"util/-"-g' {} \;
	# Including precompiled config.h
	@cp config.h ./$(SRC_DIR)
