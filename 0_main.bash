rm log.lammps
SECONDS=0
ls > wy*
#**********************Simulation Parameters*******************************
steps_per_run=$(($((1 * $((10 ** 4)))) + $((5 * $((10 ** 3))))))
steps_per_data_point=$(($steps_per_run / 200))
#steps_per_data_point=1
steps_per_dump=$(($steps_per_run / 2000))
remove=$(($((75 / $steps_per_data_point)) + 1))
dt=0.001
user_input_error_tol=100
error_tol=$(./ed* $user_input_error_tol 2.0)

cp zy* wz*
sort -V c0* > ca*

#************Check needed files are there, else stop program**************

mapfile -t needed_files < wy*

for file in ${needed_files[@]}
do
  if [[ ! -f $file ]]
  then
    echo "file $file is not there. Needed for wrapper program to work. Exiting..."
    exit 0
  fi
done

#***********Reading list of lattice constants into array****************
mapfile -t latts < ca*
let "ca_array_len = ${#latts[@]}"
let "ca_last_index = ${#latts[@]} - 1"

output_file=ga_${latts[0]}_to_${latts[$ca_last_index]}A_lattice_melt_temp_in_k_melt_press_in_GPa.out

#****************Looping through array from end to end****************
#*********************************************************************

for((i=0;i<$ca_array_len;i++)) #******Start of lattice constants for loop*******
do

#*************************Upper bound***************************************

  lattice_dir=${latts[i]}A_${steps_per_run}_steps_${dt}ps_timestep
  mkdir -p $lattice_dir


#***********************Reading Initial Range*****************************
  mapfile -t initial_range < wz*
  
  l_bound=${initial_range[0]}
  u_bound=${initial_range[1]}
  
  m_point=$(./ea* $l_bound $u_bound)



  rm *.dat

#**********************Right end search in the PV curve*****************************

#*****************Initialization of Search******************
  mpirun -np 4\
    lmp\
    -var prev_temp null\
    -var temp $l_bound\
    -var a ${latts[i]}\
    -var n $steps_per_run\
    -var k $steps_per_data_point\
    -var l $steps_per_dump\
    -var dt $dt\
    -var res null\
    -i in.melt.0

  thermo_file=*.dat

  sed -i -e "1,${remove}d" $thermo_file
  ./az* ${thermo_file}
  mv $thermo_file $lattice_dir
  mv ${thermo_file}.jpg $lattice_dir

  ./cnn.py ${lattice_dir}/${thermo_file}.jpg melting.txt

  melted_signal=$(cat melting.txt)
  u_l_m_temps_and_melting_signal=aa_${latts[i]}_u_l_m_temps_and_melted_signal.txt
  m_temp_and_melting_signal=ab_${latts[i]}_m_temp_and_melted_signal.txt
  echo "$l_bound $(./ec* $u_bound $l_bound) $melted_signal" > $u_l_m_temps_and_melting_signal
  echo "$l_bound $melted_signal" > $m_temp_and_melting_signal
  echo "melted_signal = $melted_signal"

  if [[ $melted_signal -eq 1 ]]
  then
    echo "Lower bound of range to high, need too lower it. Exiting program..."
    exit 0
  fi


  error=$(./ec* $u_bound $l_bound)

  error_less_than_tol=$(./eb* $error $error_tol)


#***********Iterative Search**************
  while [[ $error_less_than_tol -eq 0 ]]
  do
  mpirun -np 4\
    lmp\
    -var prev_temp $l_bound\
    -var temp $m_point\
    -var a ${latts[i]}\
    -var n $steps_per_run\
    -var k $steps_per_data_point\
    -var l $steps_per_dump\
    -var dt $dt\
    -var res from_${l_bound}_restart_from_last_run.${steps_per_run}\
    -i in.melt.iterate.restart_input

  thermo_file=*.dat

  sed -i -e "1,${remove}d" $thermo_file
  ./az* ${thermo_file}

  ./cnn.py ${thermo_file}.jpg melting.txt
  mv $thermo_file $lattice_dir
  mv ${thermo_file}.jpg $lattice_dir

  melted_signal=$(cat melting.txt)

  echo "melted_signal = $melted_signal"
  echo "$l_bound $m_point $u_bound $(./ec* $u_bound $l_bound) $melted_signal" \
  >> $u_l_m_temps_and_melting_signal
  echo "$m_point $melted_signal" >> $m_temp_and_melting_signal

  if [[ $melted_signal -eq 0 ]]
  then
    rm from_${l_bound}_restart_from_last_run.${steps_per_run}
    l_bound=$m_point
  fi

  if [[ $melted_signal -eq 1 ]]
  then
    rm from_${u_bound}_restart_from_last_run.${steps_per_run}
    u_bound=$m_point
  fi

  m_point=$(./ea* $l_bound $u_bound)

  echo $l_bound
  echo $m_point
  echo $u_bound

  error=$(./ec* $u_bound $l_bound)

  error_less_than_tol=$(./eb* $error $error_tol)

  done

  m_point=$(./ea* $l_bound $u_bound)

  mpirun -np 4\
    lmp\
    -var prev_temp $l_bound\
    -var temp $m_point\
    -var a ${latts[i]}\
    -var n $steps_per_run\
    -var k $steps_per_data_point\
    -var l $steps_per_dump\
    -var dt $dt\
    -var res from_${l_bound}_restart_from_last_run.${steps_per_run}\
    -i in.melt.iterate.restart_input

  rm from_*
  sed -i -e "1,${remove}d" $thermo_file
  thermo_file=*.dat
  ./az* ${thermo_file}
  melt_temp=$(./fa* *.dat 2 1 100)
  melt_press=$(./fa* *.dat 3 1 100)
  echo "${latts[i]} $melt_press $melt_temp" >> $output_file 

  ./cnn.py ${thermo_file}.jpg melting.txt
  mv $thermo_file $lattice_dir
  mv ${thermo_file}.jpg $lattice_dir

  melted_signal=$(cat melting.txt)

  echo "melted_signal = $melted_signal"
  echo "$l_bound $m_point $u_bound $(./ec* $u_bound $l_bound) $melted_signal" \
  >> $u_l_m_temps_and_melting_signal
  echo "$m_point $melted_signal" >> $m_temp_and_melting_signal

  mv *.dat $lattice_dir

  > wz*
  echo ${initial_range[0]} >> wz*
  echo $m_point >> wz*

  mv $u_l_m_temps_and_melting_signal $lattice_dir
  mv $m_temp_and_melting_signal $lattice_dir

done #******End of lattice constants for loop********

rm log.lammps
d=$SECONDS
  echo "$(($d / 3600)) hours, $(($(($d % 3600)) / 60)) minutes and $(($(($d % 3600)) % 60))\
    seconds" > \
    ta_wall-clock_time_a_${latts[i]}_n_${steps_per_run}_k_${steps_per_data_point}_T_${temps[0]}_to_${temps[len_cb]}K_over_${array_cb_len}.txt

echo "Results: "
cat ga*
echo "Wall-clock time: "
cat ta*
