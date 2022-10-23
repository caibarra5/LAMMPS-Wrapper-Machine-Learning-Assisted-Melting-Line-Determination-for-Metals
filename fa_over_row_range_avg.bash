FILE=$1
col=$2
i=$3
j=$4
rowsn=$(($(($j - $i)) + 1))
#echo $rowsn
#AVERAGE=$(awk ' NR>=11 && NR<= 17{sum +=$3; if(NR == 17){exit}} END {print sum/7}' $FILE)
AVERAGE=$(awk -v i=$i -v j=$j -v col=$col -v rowsn=$rowsn ' NR>=i && NR<= j{sum +=$col; if(NR == j){exit}} END {print sum/rowsn}' $FILE)

echo $AVERAGE
