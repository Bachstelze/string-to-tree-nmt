#!/bin/sh

base_path=/home/nlp/aharonr6

# path to nematus ( https://www.github.com/rsennrich/nematus )
nematus=$base_path/git/nematus

# path to moses decoder: https://github.com/moses-smt/mosesdecoder
mosesdecoder=$base_path/git/mosesdecoder

# model prefix
model_prefix=$base_path/git/research/nmt/models/de_en_bpe_raw/de_en_bpe_raw_model.npz

# dev ref file
ref=$base_path/git/research/nmt/data/WMT16/de-en-raw/dev/newstest-2013-2014-deen.en

# dev predictions file
dev_target=$base_path/git/research/nmt/models/de_en_bpe_raw/newstest-2013-2014-deen.tok.clean.true.bpe.de.output.dev.postprocessed

# dev alignments file
dev_alignments=$base_path/git/research/nmt/models/de_en_bpe_raw/dev_alignments.txt

# get prev best BLEU
BEST=`cat ${model_prefix}_best_bleu || echo 0`
echo "prev best BLEU: $BEST"

# write current BLEU
$mosesdecoder/scripts/generic/multi-bleu.perl $ref < $dev_target >> ${model_prefix}_bleu_scores
echo "wrote current BLEU to: ${model_prefix}_bleu_scores"

# extract current BLEU
BLEU=`$mosesdecoder/scripts/generic/multi-bleu.perl $ref < $dev_target | cut -f 3 -d ' ' | cut -f 1 -d ','`
echo "extracted current BLEU: $BLEU"

# check if to save new model as best model
echo 'check if better...'
echo "current: $BLEU"
echo "best: $BEST"

if (( $(echo "$BLEU > $BEST" |bc -l) )); then
    echo "new best; saving"
    echo $BLEU > ${model_prefix}_best_bleu
    cp ${model_prefix}.dev.npz ${model_prefix}.npz.best_bleu
    cp ${dev_target} ${dev_target}.best
    cp ${dev_alignments} ${dev_alignments}.best
    echo "improved! saved best in: ${model_prefix}.npz.best_bleu"
else
    echo "no improvement"
fi
