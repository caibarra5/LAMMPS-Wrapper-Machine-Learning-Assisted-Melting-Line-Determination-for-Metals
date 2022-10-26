echo " "
for dir in *timestep/
do
  echo $dir
  cat ${dir}ab*
  echo " "
done

