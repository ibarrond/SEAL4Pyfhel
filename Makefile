
SEAL_URL="https://github.com/microsoft/SEAL/archive/master.zip"
GSL_URL="https://github.com/microsoft/GSL/archive/master.zip"
SRC_DIR=SEAL/seal
EXAMPLES_DIR=SEAL/examples
SHELL=/bin/bash

all: download fix_original
.PHONY: download fix_original

download:
	# OBTAINING LIBRARY: download and extract
	wget -q $(SEAL_URL)
	unzip -q master.zip -d ${SRC_DIR}
	rm master.zip
	wget  -q $(GSL_URL)
	unzip -q master.zip -d gsl
	rm master.zip

fix_original:
	# Run cmake .
	cd ${SRC_DIR}/SEAL-master/ && cmake . && cd -
	# # Moving license
	mv ${SRC_DIR}/SEAL-master/LICENSE LICENSE
	# Removing unnecesary files (all outside of native)
	find ${SRC_DIR}/SEAL-master/ -mindepth 1 -maxdepth 1 ! -wholename '*native*' -exec rm -rf {} \;
	# Moving the important .cpp and .h files
	find ${SRC_DIR}/SEAL-master/native/src/seal/  -name '*.cpp' ! -wholename '*/c/*' -exec cp {} ${SRC_DIR} \;
	find ${SRC_DIR}/SEAL-master/native/src/seal/  -name '*.h' ! -wholename '*/c/*' -exec cp {} ${SRC_DIR} \;
	find ${SRC_DIR}/SEAL-master/native/src/seal/  -name '*.c' ! -wholename '*/c/*' -exec cp {} ${SRC_DIR} \;
	mkdir -p ${EXAMPLES_DIR}
	find ${SRC_DIR}/SEAL-master/native/examples/  -name '*.cpp'  -exec cp {} ${EXAMPLES_DIR} \;
	find ${SRC_DIR}/SEAL-master/native/examples/  -name '*.h'  -exec cp {} ${EXAMPLES_DIR} \;
	# Removing the rest of the original repo
	rm -rf ${SRC_DIR}/SEAL-master
	# Fixing errors in relative paths wrt. imports
	find ./${SRC_DIR}/ -name '*.*' -exec sed -i 's-"seal/-"-g' {} \;
	find ./${SRC_DIR}/ -name '*.*' -exec sed -i 's-"util/-"-g' {} \;
	# Extracting Microsoft GSL headers
	mv gsl/GSL-master/include/gsl/* gsl
	rm -rf gsl/GSL-master/
	# Flattening GSL
	ls gsl/ -I "gsl_*" -I "gsl" -1 | xargs -I {} mv gsl/{} gsl/gsl_{}
	ls gsl/ -1 | xargs -I {} mv gsl/{} gsl/{}.h
	find ./gsl -name '*.*' -exec sed -i -E 's-<gsl/(.*)>-"gsl_\1"-g' {} \;
	find ./gsl -name '*.*' -exec sed -i -E 's-"gsl_gsl_(.*)"-"gsl_\1"-g' {} \;
	find ./gsl -name '*.*' -exec sed -i -E 's-"gsl_(.*)"-"gsl_\1.h"-g' {} \;
	# Moving GSL with SEAL library
	mv gsl/* ${SRC_DIR}/
	rm -rf gsl
	find ./${SRC_DIR} -name '*.*' -exec sed -i -E 's-<gsl/(.*)>-"gsl_\1.h"-g' {} \;
	# Copying handcrafted config.h (disable to ensure compatibility with your OS)
	cp config.h ${SRC_DIR}/config.h

clean:
	rm -rf gsl
	rm -rf SEAL/seal