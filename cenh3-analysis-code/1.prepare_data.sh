#/bin/bash

#install 
#conda install trim_galore
work=
fq=

rm -fr $work/input_data
mkdir -p $work/input_data
cd $work/input_data
num=0
rm -fr sample_fastq.list
for i in `find $fq -name "*fastq.gz" -or -name "*lean*fq.gz" | sort`
do
	num=$[num+1];
	if [ $[$num%2] == 0 ]
	then
		echo -e "S$[$num/2]\tS$[$num/2]_2.fq.gz\t$i"
		ln -s $i S$[$num/2]_2.fq.gz
	else
		echo -e "S$[$[num+1]/2]\tS$[$[num+1]/2]_1.fq.gz\t$i"
		ln -s $i S$[$[num+1]/2]_1.fq.gz
	fi
done >>sample_fastq.list
