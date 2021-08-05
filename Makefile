.EXPORT_ALL_VARIABLES:

JULIA_LOAD_PATH := $(shell pwd)/src:${shell printenv JULIA_LOAD_PATH}
.PHONY: all test clean

run:
	@julia --color=yes --project=. src/JDates.jl

test:
	@julia --color=yes --project=. test/runtests.jl