#!/bin/zsh

# dir is the working directory for the script,
# where all the compressed files are stored
# will be uncompressed in the same directory

dir=$1

if [ -z "$dir" ]; then
   dir=$(pwd)
fi

tgzCount=$(find "$dir" -maxdepth 1 -name "*.tgz" | wc -l)
targzCount=$(find "$dir" -maxdepth 1 -name "*.tar.gz" | wc -l)
zipCount=$(find "$dir" -maxdepth 1 -name "*.zip" | wc -l)
dirString="${dir}"

echo "*****************************"
echo "\n Working directory set to ${dir} \n"
echo "*****************************"
echo "*****************************"
echo "\nFound: $tgzCount --> .tgz  $targzCount --> .tar.gz  $zipCount --> .zip\n"
echo "*****************************"

if [[ $tgzCount -eq 0 && $targzCount -eq 0 && $zipCount -eq 0 ]]; then
   echo "*****************************"
   echo "\nERROR -  Unable to find any compressed file in $dir\n"
   echo "*****************************"
else
   if [ $tgzCount -gt 0 ]; then
      for file in $(ls "$dir"/*.tgz); do
         fileName=$(basename -s .tgz "${file}")
         echo "*****************************"
         echo "\nExtracting ${fileName}\n"
         echo "*****************************"
         mkdir -p ${dir}/${fileName}
         tar -xzf ${file} -C ${dir}/${fileName}
      done
   fi
   if [ $targzCount -gt 0 ]; then
      for file in $(ls "${dir}"/*.tar.gz); do
         fileName=$(basename -s .tar.gz "${file}")
         echo "*****************************"
         echo "\nExtracting ${fileName}\n"
         echo "*****************************"
         mkdir -p ${dir}/${fileName}
         tar -xzf ${file} -C ${dir}/${fileName}
      done
   fi
   if [ $zipCount -gt 0 ]; then
      for file in $(ls "$dir"/*.zip); do
         fileName=$(basename -s .zip "${file}")
         echo "*****************************"
         echo "\nExtracting ${fileName}\n"
         echo "*****************************"
         mkdir -p ${dir}/${fileName}
         unzip -oq ${file} -d ${dir}/${fileName}
      done
   fi
fi