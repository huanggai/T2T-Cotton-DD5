#/bin/bash

work=./
sh1=./run_ChIP_fold_enrichment_hg.pl
input=$work/mapping/S2.df.bam
chip=$work/mapping/S1.df.bam
name=D


S1=`samtools flagstat $input |grep "0 mapped" |cut -f 1 -d " "`
S2=`samtools flagstat $chip |grep "0 mapped" |cut -f 1 -d " "`

rm -fr $work/cenh3_fold_enrichment
mkdir -p $work/cenh3_fold_enrichment
cd $work/cenh3_fold_enrichment

bedtools genomecov -ibam $input -d -pc >input.df.genomecov
bedtools genomecov -ibam $chip -d -pc >chip.df.genomecov

for((i=1;i<=13;i++));
do
	awk -v var1=$i '{if(var1<10 && $1=="D0"var1){print} else if(var1>=10 && $1=="D"var1){print}}' input.df.genomecov >input.$i.df.genomecov
	awk -v var1=$i '{if(var1<10 && $1=="D0"var1){print} else if(var1>=10 && $1=="D"var1){print}}' chip.df.genomecov >chip.$i.df.genomecov
	perl $sh1 input.$i.df.genomecov chip.$i.df.genomecov $S1 $S2
	mv cenpChip.IP_Input_Ratio.txt cenpChip.${name}${i}.IP_Input_Ratio.txt
	rm -fr input.$i.df.genomecov chip.$i.df.genomecov
done

