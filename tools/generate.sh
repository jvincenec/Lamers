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
	'wk 221913824'
	'tumbleweed 115961515'
	'badbatch 814449267'
	'templar 135722653'
	'cursed-legacy 259119853'
	'order66 195638347'
	'kotd 126515217'
	'honor 558111281'
	'giggity 431616455'
)

for g in $guilds ; do 
	args=("${(@s/ /)g}")
	echo "==============="
	echo "$args[1]"
	
	echo "FETCH: $guild"

	echo "~/bin/swgoh-tool --fetch $args[2] $args[1]"
	time ~/bin/swgoh-tool --fetch $args[2] $args[1] || exit 1
	
	echo "~/bin/swgoh-tool --guild $args[1].json --site docs"
	time ~/bin/swgoh-tool --guild $args[1].json --site docs
done

echo "==============="
echo "ALLIANCE"

time ~/bin/swgoh-tool --alliance docs *.json
