#!/bin/bash
workingDir=${studyRoot}/ANTSWarping

fixedImg=
movingImg=

cd ${workingDir}
movingImg=
movedImg=

echo "Composing the affine inv and diffeo inv in that order."
prefix="ANTS_"
antsApplyTransforms -r ${movingImg} -t [${prefix}0GenericAffine.mat,1] ${prefix}1InverseWarp.nii.gz -o [${prefix}FullInverseWarpAffInvCompDiffeo.nii.gz,1]

echo "MRTRIX"
echo "Creating an empty warp grid in the moved image space."
warpinit ${movedImg} InitWarp-[].nii.gz -force

echo "Warping this empty warp grid to the moving image space."
for i in `echo 0 1 2`
do
echo "Warping InitWarp-${i}.nii."
antsApplyTransforms -i InitWarp-${i}.nii.gz -o FinalWarpAffInvCompDiffeo-${i}.nii.gz -t ${prefix}FullInverseWarpAffInvCompDiffeo.nii.gz -r ${movingImg}
done

echo "Correct the warped grid."
warpcorrect FinalWarpAffInvCompDiffeo-[].nii.gz FinalWarpAffInvCompDiffeoCorrected.mif -force

echo "Now warping the tck files to the population space."
warp=${workingDir}/FinalWarpAffInvCompDiffeoCorrected.mif

for tck in `ls *tck`
do
echo ${tck%.tck*}
tcknormalise ${tck} ${warp} ${outRoot}/${tck%.tck*}AffInvCompDiffeoWarpedInInfPop.tck -force
done
