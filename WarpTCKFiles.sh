#!/bin/bash
workingDir=/scratch/hartwell/Olga/Tractography_Nagesh
cd ${workingDir}

movingImg=H001_fod.mif
movedImg=wmfod_template.mif

echo "MRTRIX"
echo "Creating an empty warp grid in the moved image space."
warpinit ${movedImg} InitWarp-[].mif -force

echo "Warping this empty warp grid to the moving image space."
for i in `echo 0 1 2`
do
echo "Warping InitWarp-${i}.mif."
mrtransform -warp H001_2temp_warp.mif -template ${movingImg} InitWarp-${i}.mif FinalWarpAffInvCompDiffeo-${i}.mif -force
done

echo "Correct the warped grid."
warpcorrect FinalWarpAffInvCompDiffeo-[].mif FinalWarpAffInvCompDiffeoCorrected.mif -force

echo "Now warping the tck files to the population space."
warp=FinalWarpAffInvCompDiffeoCorrected.mif

for tck in `ls *tck`
do
echo ${tck%.tck*}
tcknormalise ${tck} ${warp} ${tck%.tck*}AffInvCompDiffeoWarpedToSubj.tck -force
done
