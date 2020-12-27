#!/bin/zsh


guilds=(
	'baltic 228765519'
	'exile 656997348'
	'hope 369351434'
	'hoth 329251861'
	'jnj 932325566'
	'llvy 454754726'
	'lop 388924554'
	'mandalorians 591287488'
	'porgs 986843228'
	'sbr 141812836'
	'twd 414232583'
	'wk 221913824'
	'tumbleweed 115961515'
	'templar 135722653'
	'kotd 126515217'
	'honor 558111281'
	'phoenixhawk 767641473'
	'ebonhand 783828985'
	'ewoking 714847433'
	'rambos 739491776'
	'brother 494962926'
	'lazerfaces 469344695'
	'kotor 815925164'
	'thrawn 464574793'
	'esb 496642589'
)

# prime the pipe -- fetch the first guild
echo "==============="
echo "FETCH: $guilds[1]"
args=("${(@s/ /)guilds[1]}")

echo "~/bin/swgoh-tool --fetch $args[2] $args[1]"
time ~/bin/swgoh-tool --fetch $args[2] $args[1] || exit 1


for ((i = 1; i < $#guilds; i++)) ; do 
	args=("${(@s/ /)guilds[i]}")
	
	# now build the guild we just fetched
	echo "~/bin/swgoh-tool --guild $args[1].json --site docs"
	time ~/bin/swgoh-tool --guild $args[1].json --site docs &
	
	# and fetch the next one
	
	echo "==============="
	args=("${(@s/ /)guilds[i + 1]}")
	echo "FETCH: $args"

	echo "~/bin/swgoh-tool --fetch $args[2] $args[1]"
	time ~/bin/swgoh-tool --fetch $args[2] $args[1] || exit 1
	
	# wait for both to complete
	wait
	
done

# finish the pipeline
args=("${(@s/ /)guilds[$#guilds]}")
echo "~/bin/swgoh-tool --guild $args[1].json --site docs"
time ~/bin/swgoh-tool --guild $args[1].json --site docs &

echo "==============="
echo "ALLIANCE"

time ~/bin/swgoh-tool --alliance docs *.json

wait

ret=$?; times; exit "$ret"
