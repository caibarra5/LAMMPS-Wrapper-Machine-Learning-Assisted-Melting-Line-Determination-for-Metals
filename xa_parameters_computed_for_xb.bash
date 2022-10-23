>xb_parameters_for_ab.txt
steps_per_run=$((1 * $((10 ** 3)))) # Number of steps per run
dump_freq=2        # Dump every dump_freq time steps
data_points_freq=2 # Output data points every data_points_freq time steps

echo $steps_per_run >> xb_parameters_for_ab.txt
echo $dump_freq >> xb_parameters_for_ab.txt
echo $data_points_freq >> xb_parameters_for_ab.txt

