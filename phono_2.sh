#!/bin/bash
#SBATCH --job-name=APphono              # Job name
#SBATCH --time=24:00:00               # Time limit hrs:min:sec
#SBATCH -p nocona
#SBATCH --account=aquino
#SBATCH -N 1
#SBATCH --ntasks-per-node=128

# This script runs the VASP calculations on prepared phonopy inputs.

# Modules
module load gcc/10.1.0 openmpi/4.0.4 vasp/5.4.4-openmp

home=$(pwd)
files='CHG EIGENVAL REPORT vasp.out CHGCAR DOSCAR IBZKPT OSZICAR PCDAT XDATCAR POTCAR'
broken=0

dir=$( ls -d disp-* ) 

rm control >& /dev/null

for i in $dir; do
	cd $home
	if [ -f "$i/OUTCAR" ] && [ -f "$i/vasprun.xml" ] && grep -q Voluntary "$i/OUTCAR" ; then
                for fil in $files; do
                        rm $i/WAVECAR >& /dev/null
                done
		echo $i done >> control
	else
		echo $i Starting >> control
		cp POTCAR         $i/POTCAR
		cp INCAR          $i/INCAR
		cp $prev/WAVECAR  $i/WAVECAR 2> /dev/null
		rm $prev/WAVECAR             2> /dev/null

        	cd $i && mpirun vasp_std >& vasp.out || echo $i Broken! >> $home/control

		if [ -f "$home/$i/OUTCAR" ] && grep -q Voluntary "$home/$i/OUTCAR" ; then
			echo $i done >> $home/control
			for fil in $files; do
				rm $home/$i/$fil >& /dev/null
			done
			prev=$i
		else
			broken=$(($broken +1))
			echo $i Broken! total = $broken  >> $home/control
			if [ $broken -eq 5 ];then
				exit
			fi
		fi
		rm $home/$i/POTCAR >& /dev/null
	fi
done

cd $home
for i in $dir; do
	for fil in $files; do
		rm $i/$fil    >& /dev/null
	done
	rm $i/WAVECAR >& /dev/null
done
