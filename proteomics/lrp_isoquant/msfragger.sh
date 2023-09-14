#!/bin/bash

set -xe

# Add jdk to path
export PATH=../../tools/jdk-19.0.1/bin:$PATH

# Specify paths of tools and files to be analyzed.
dataDirPath="../../data/proteomics/raw_data/trypsin"
fastaPath="../../data/proteomics/2023-04-18-decoys-contam-hnr_50_hybrid.fasta.fas"
msfraggerPath="../../tools/MSFragger-3.7/MSFragger-3.7.jar" # download from http://msfragger-upgrader.nesvilab.org/upgrader/
fraggerParamsPath="../open_fragger_trypsin.params"
philosopherPath="../../tools/philosopher-4.8.1/philosopher" # download from https://github.com/Nesvilab/philosopher/releases/latest
ionquantPath="../../tools/MSFragger-3.7/ext/IonQuant-1.8.10.jar" # download from https://github.com/Nesvilab/IonQuant/releases/latest
decoyPrefix="rev_"

# Create database with contaminants
$philosopherPath workspace --clean
$philosopherPath workspace --init
$philosopherPath database --custom ../../data/proteomics/isoquant/15_hybrid_database/hnr_50_hybrid.fasta --contam 

#Run MSFragger. Change the -Xmx value according to your computer's memory.
java -Xmx64G -jar $msfraggerPath $fraggerParamsPath $dataDirPath/*.d

#Move pepXML files to current directory.
mv $dataDirPath/*.pepXML ./

#  Run PeptideProphet, ProteinProphet, and FDR filtering with Philosopher
$philosopherPath database --annotate $fastaPath --prefix $decoyPrefix

# Pick one from the following three commands and comment the other two.
$philosopherPath peptideprophet --nonparam --expectscore --decoyprobs --masswidth 1000.0 --clevel -2 --decoy $decoyPrefix --combine --database $fastaPath ./*.pepXML # Open search if you did NOT ran Crystal-C
$philosopherPath proteinprophet --maxppmdiff 2000000 --output combined ./*.pep.xml
$philosopherPath filter --sequential --razor --mapmods --tag $decoyPrefix --pepxml ./interact.pep.xml --protxml ./combined.prot.xml # Open search

# Generate reports.
$philosopherPath report
$philosopherPath workspace --clean

# Run IonQuant. Change the -Xmx value according to your computer's memory.
java -Xmx64G -jar $ionquantPath \
--ionmobility 1 \
--specdir $dataDirPath \
--psm psm.tsv \
--threads 20

