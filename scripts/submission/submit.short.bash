#!/bin/bash
#SBATCH -N 16
#SBATCH -n 64
#SBATCH --time=120:00:00
#SBATCH --exclusive
#SBATCH -J redwood
#SBATCH -p redwood
#SBATCH -o full-short-2D.out

GMX=/home/whitford/BIN/nd/gmx-5.1.4_gnu6_openmpi3.1.2_redwood/bin/gmx_mpi
#GMX=/home/whitford/BIN/nd/gmx-5.1.4_gnu6_openmpi3.1.2/bin/gmx_mpi
EPS=400
TEMPP=60
dir=$(pwd)
ddir=$dir/$TEMPP.ex1.0.eps$EPS.start.6.4
tabledir=$(pwd)
#rm -r $ddir
mkdir $ddir
cd $ddir

#rm log
count=1
#so it works for initialization
cp $dir/system/6qnr-AT.noL10.nofirstU.gro $ddir/equil.6.5.5.gro

previ=6.5
L14_dist=7
top=$dir/system/6qnr-AA.noL10.nofirstU.condense.top
ndx=$dir/system/elbow_cca_2UC.noL10.nofirstU.ndx
#cp $dir/$top .
#cp $dir/restraint.nottRNA.itp .

###### pull the original configuration to L14_dist=7

#minimize
sed 's/ELBOWDISTANCE/'$previ'/g;s/L14DISTANCE/'$L14_dist'/g;s/EPSILONN/'$EPS'/g;s/TEMPP/'$TEMPP'/g' $dir/md.min.TMP > md.$previ.$L14_dist.min.mdp
$GMX grompp -f md.$previ.$L14_dist.min.mdp -n $ndx -c equil.$previ.5.gro -p $top -o min.$previ.$L14_dist.tpr 
mpirun -n 64 $GMX mdrun -ntomp 5 -dd 4 4 4 -v -s min.$previ.$L14_dist.tpr -noddcheck -c min.$previ.$L14_dist.gro 

#equilibrate
sed 's/ELBOWDISTANCE/'$previ'/g;s/L14DISTANCE/'$L14_dist'/g;s/EPSILONN/'$EPS'/g;s/TEMPP/'$TEMPP'/g' $dir/mdEquil.TMP > mdEquil.$previ.$L14_dist.mdp
$GMX grompp -f mdEquil.$previ.$L14_dist.mdp -n $ndx -c min.$previ.$L14_dist.gro -p $top -o traj.$previ.$L14_dist.tpr 
mpirun -n 64 $GMX mdrun -ntomp 5 -dd 4 4 4 -v -s traj.$previ.$L14_dist.tpr -noddcheck -c equil.$previ.$L14_dist.gro -x traj.$previ.$L14_dist.xtc -px pullx.$previ.$L14_dist.xvg


######### expand Relbow

#for i in $(seq 6.6 0.1 7.0)
for i in $(seq 6.4 -0.1 3.1)
do

#minimize
sed 's/ELBOWDISTANCE/'$i'/g;s/L14DISTANCE/'$L14_dist'/g;s/EPSILONN/'$EPS'/g;s/TEMPP/'$TEMPP'/g' $dir/md.min.TMP > md.$i.$L14_dist.min.mdp
$GMX grompp -f md.$i.$L14_dist.min.mdp -n $ndx -c equil.$previ.$L14_dist.gro -p $top -o min.$i.$L14_dist.tpr 
mpirun -n 64 $GMX mdrun -ntomp 5 -dd 4 4 4 -v -s min.$i.$L14_dist.tpr -noddcheck -c min.$i.$L14_dist.gro 

#equilibrate
sed 's/ELBOWDISTANCE/'$i'/g;s/L14DISTANCE/'$L14_dist'/g;s/EPSILONN/'$EPS'/g;s/TEMPP/'$TEMPP'/g' $dir/mdEquil.TMP > mdEquil.$i.$L14_dist.mdp
$GMX grompp -f mdEquil.$i.$L14_dist.mdp -n $ndx -c min.$i.$L14_dist.gro -p $top -o traj.$i.$L14_dist.tpr 
mpirun -n 64 $GMX mdrun -ntomp 5 -dd 4 4 4 -v -s traj.$i.$L14_dist.tpr -noddcheck -c equil.$i.$L14_dist.gro -x traj.$i.$L14_dist.xtc -px pullx.$i.$L14_dist.xvg

#echo $count $i $xdist >> log
echo $count $i >> log
count=$(( $count + 1 ))
rm \#*
#done
previ=$i
done
