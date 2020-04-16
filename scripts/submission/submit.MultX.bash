#!/bin/bash
#SBATCH -N 16
#SBATCH -n 64 
#SBATCH --time=24:00:00
#SBATCH --exclusive
#SBATCH -J 2UC.NUMM
#SBATCH -p short
#SBATCH -o 2UC.NUMM.out

GMX=/home/whitford/BIN/nd/gmx-5.1.4_gnu6_openmpi3.1.2/bin/gmx_mpi

EPS=400
TEMPP=60

#IMPORTANT SETTINGS

dir=/scratch/ellenwang/Umbrella/full_ribo_umbRun/std_smog_2UC
top=$dir/system/6qnr-AA.noL10.nofirstU.condense.top
ndx=$dir/system/elbow_cca_2UC.noL10.nofirstU.ndx
RELBOW=NUMM

ddtext="-ntomp 7 -dd 4 4 4"
ddir=$dir/$TEMPP.ex1.0.eps$EPS.start.6.4
cd $ddir

i=$RELBOW
LASTLE=7
for L14_dist in 6 5 
do
L14_distreplacement=$(echo $L14_dist | awk '{printf("%4.3f",$1)}')
echo L14_dist replacement is: $L14_distreplacement

#minimize
sed 's/ELBOWDISTANCE/'$i'/g;s/L14DISTANCE/'$L14_dist'/g;s/EPSILONN/'$EPS'/g;s/TEMPP/'$TEMPP'/g' $dir/md.min.TMP > md.$i.$L14_dist.min.mdp
$GMX grompp -f md.$i.$L14_dist.min.mdp -n $ndx -c equil.$i.$LASTLE.gro -p $top -o min.$i.$L14_dist.tpr
mpirun -n 64 $GMX mdrun $ddtext -v -s min.$i.$L14_dist.tpr -noddcheck -c min.$i.$L14_dist.gro -e min.$i.$L14_dist.edr -g min.$i.$L14_dist.log

#equilibrate
sed 's/ELBOWDISTANCE/'$i'/g;s/L14DISTANCE/'$L14_dist'/g;s/EPSILONN/'$EPS'/g;s/TEMPP/'$TEMPP'/g' $dir/mdEquil.TMP > mdEquil.$i.$L14_dist.mdp
$GMX grompp -f mdEquil.$i.$L14_dist.mdp -n $ndx -c min.$i.$L14_dist.gro -p $top -o equil.$i.$L14_dist.tpr 
mpirun -n 64 $GMX mdrun $ddtext -v -s equil.$i.$L14_dist.tpr -noddcheck -c equil.$i.$L14_dist.gro -x traj.$i.$L14_dist.xtc -e equil.$i.$L14_dist.edr -g equil.$i.$L14_dist.log -px pullx.$i.$L14_dist.xvg

LASTLE=$L14_dist
rm \#*
done


LASTLE=7
L14_dist=8 

L14_distreplacement=$(echo $L14_dist | awk '{printf("%4.3f",$1)}')
echo L14_dist replacement is: $L14_distreplacement

#minimize
sed 's/ELBOWDISTANCE/'$i'/g;s/L14DISTANCE/'$L14_dist'/g;s/EPSILONN/'$EPS'/g;s/TEMPP/'$TEMPP'/g' $dir/md.min.TMP > md.$i.$L14_dist.min.mdp
$GMX grompp -f md.$i.$L14_dist.min.mdp -n $ndx -c equil.$i.$LASTLE.gro -p $top -o min.$i.$L14_dist.tpr
mpirun -n 64 $GMX mdrun $ddtext -v -s min.$i.$L14_dist.tpr -noddcheck -c min.$i.$L14_dist.gro -e min.$i.$L14_dist.edr -g min.$i.$L14_dist.log

#equilibrate
sed 's/ELBOWDISTANCE/'$i'/g;s/L14DISTANCE/'$L14_dist'/g;s/EPSILONN/'$EPS'/g;s/TEMPP/'$TEMPP'/g' $dir/mdEquil.TMP > mdEquil.$i.$L14_dist.mdp
$GMX grompp -f mdEquil.$i.$L14_dist.mdp -n $ndx -c min.$i.$L14_dist.gro -p $top -o equil.$i.$L14_dist.tpr 
mpirun -n 64 $GMX mdrun $ddtext -v -s equil.$i.$L14_dist.tpr -noddcheck -c equil.$i.$L14_dist.gro -x traj.$i.$L14_dist.xtc -e equil.$i.$L14_dist.edr -g equil.$i.$L14_dist.log -px pullx.$i.$L14_dist.xvg

LASTLE=$L14_dist
rm \#*

