#!/bin/bash

# STEP 1
# This script prepare the phonopy calculations.
# Conda phonopy env must be active.

#cond activate phonopy      
read -p "amp (eg: 0.015 ) = " a
read -p "dim (eg: 2 2 2 ) = " d

phonopy --vasp -d --dim="$d" --amplitude=$a

n=$( ls -dq *POSCAR-* | wc -l )
echo $n calculations will be prepared.
rm -rf disp-*


for i in $(seq -w 001 001 999 ) $(seq -w 1001 0001 9999); do
        if [ $i -gt $n ]; then
                echo $n calculations prepared.; break
        fi

        if [ ! -f POSCAR-$i ]; then
              echo POSCAR-$i not found! Breaking loop; break

        fi

        mkdir disp-$i
        mv POSCAR-$i    disp-$i/POSCAR || break
        cp INCAR        disp-$i/.
        cp KPOINTS      disp-$i/.
done
