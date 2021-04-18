.EXPORT_ALL_VARIABLES:

JULIA_LOAD_PATH := $(shell pwd)/src:${shell printenv JULIA_LOAD_PATH}
.PHONY: all test clean

run:
	@echo $(JULIA_LOAD_PATH)
	@julia --color=yes --project=. src/JDates.jl

test:
	@echo $(JULIA_LOAD_PATH)
	@julia --color=yes --project=. test/runtests.jl