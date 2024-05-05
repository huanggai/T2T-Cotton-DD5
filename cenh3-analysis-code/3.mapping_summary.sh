#/bin/bash

#install bamCoverage
#conda install deeptools
## set some shell variables
thread=8
genome=
work=
sh1=picard.jar
samtools=samtools

#build genome index
rm $work/index
mkdir -p $work/index
cd $work/index
ln -s $genome genome.fa
bowtie2-build genome.fa genome
refx=$work/index/genome

## map read to genome reference using bowtie2
rm -fr $work/mapping
mkdir -p $work/mapping
cd $work/mapping
list=`wc -l $work/input_data/sample_fastq.list |cut -f 1 -d " "`

for((i=1;i<=$[list/2];i=$[i+1]))
do
	sample=S${i}
	bowtie2 -x ${refx} -p $thread -X 2000 -1 $work/input_data/S${i}*_val_1.fq.gz -2 $work/input_data/S$i*_val_2.fq.gz 2>$sample.mapping.log | $samtools view -Sb -h -o $sample.bam -
	$samtools sort -m 5G -@ $thread $sample.bam -o $sample.s.bam
	$samtools index $sample.s.bam
	$samtools flagstat $sample.s.bam >$sample.s.metrics.txt
	rm -fr $sample.bam
## basic filtering
	$samtools view -@ $thread -F 3844 -b $sample.s.bam -o $sample.af.bam
	$samtools index $sample.af.bam
	$samtools flagstat $sample.af.bam >$sample.af.metrics.txt
	rm -fr $sample.s.bam $sample.s.bam.bai

## filtering alignment having low mapping quality
	$samtools view -b -q 30 $sample.af.bam -o $sample.qf.bam
	$samtools index $sample.qf.bam
	$samtools flagstat $sample.qf.bam >$sample.qf.metrics.txt
	rm -fr $sample.af.bam $sample.af.bam.bai

## filtering pcr duplicates
	java -jar $sh1 MarkDuplicates INPUT=$sample.qf.bam OUTPUT=$sample.df.bam METRICS_FILE=$sample.df.metrics.txt VALIDATION_STRINGENCY=LENIENT REMOVE_DUPLICATES=true
	$samtools index $sample.df.bam
	$samtools flagstat $sample.df.bam >$sample.df.metrics.txt
	rm -fr $sample.qf.bam $sample.qf.bam.bai

ln -s $sample.df.bam $sample.ff.bam
ln -s $sample.df.bam.bai $sample.ff.bam.bai

## convert bam to bigwig for genome browser
dsize=200
bamCoverage -b $sample.ff.bam -o $sample.ff.bw -p $thread --normalizeUsing CPM --binSize 10 --extendReads $dsize

## get the number of reads returned at mapping and each
## alignment filtering step
>$sample.summary.metrics.txt
for tp in s af qf df; do
               num=$(head -n 1 ./$sample.$tp.metrics.txt | awk '{print $1}')
               echo -e "$tp\t$num" >>$sample.summary.metrics.txt
done

done
