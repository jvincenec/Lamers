#!/bin/zsh

guilds=(
	'baltic 228765519'
	'censored 263362286'
	'exile 656997348'
	'hope 369351434'
	'hoth 329251861'
	'jnj 932325566'
	'llvy 454754726'
	'lop 388924554'
	'mandalorians 591287488'
	'ozzerg 815193777'
	'porgs 986843228'
	'sbr 141812836'
	'space-dragons 831264412'
	'twd 414232583'
	'wk 861877851'
	'tumbleweed 115961515'
	'badbatch 814449267'
)

for g in $guilds ; do 
	args=("${(@s/ /)g}")
	echo "==============="
	echo "$args[1]"
	
	echo "FETCH: $guild"
	echo "python ~/bin/swgoh.help.py $args[2] $args[1]"
	
	python ~/bin/swgoh.help.py $args[2] $args[1] || (sleep 60 && python ~/bin/swgoh.help.py $args[2] $args[1]) || (sleep 120 && python ~/bin/swgoh.help.py $args[2] $args[1]) || (sleep 60 && python ~/bin/swgoh.help.py $args[2] $args[1]) || (sleep 60 && python ~/bin/swgoh.help.py $args[2] $args[1]) || (sleep 60 && python ~/bin/swgoh.help.py $args[2] $args[1]) || (sleep 60 && python ~/bin/swgoh.help.py $args[2] $args[1]) || (sleep 60 && python ~/bin/swgoh.help.py $args[2] $args[1]) || exit 1
	
	time ~/bin/swgoh --guild $args[1].json --site docs 
	sleep 60
done

echo "==============="
echo "ALLIANCE"

time ~/bin/swgoh --alliance docs *.json
