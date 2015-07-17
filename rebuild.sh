#!/bin/bash

make clean -f smallestPlaneMake;
make -f smallestPlaneMake;
make clean -f fixedPlaneMake;
make -f fixedPlaneMake;
make clean -f noleaderMake;
make -f noleaderMake;
