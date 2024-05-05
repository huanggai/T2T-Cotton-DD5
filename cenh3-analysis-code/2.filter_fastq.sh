#/bin/bash
thread=5
work=

cd $work/input_data
num=`wc -l sample_fastq.list |cut -f 1 -d " "`

#pair-end reads
for ((i=1;i <= $[$num/2];i=$[i+1]))
do
	trim_galore -q 20 --fastqc --length 35 --paired -j $thread S${i}_1.fq.gz S${i}_2.fq.gz --gzip -o ./
	rm -fr S${i}_1.fq.gz S${i}_2.fq.gz
done

