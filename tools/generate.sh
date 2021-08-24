#!/bin/zsh

alias swgoh-tool=/Applications/swgoh-tool.app/Contents/MacOS/swgoh-tool

guilds=(
	'oae 979789966'
	'bad 619182389'
	'end 845439946'
	'ds 921768629'
	'ig 259229473'

)

# prime the pipe -- fetch the first guild
echo "==============="
echo "FETCH: $guilds[1]"
args=("${(@s/ /)guilds[1]}")

echo "swgoh-tool --fetch $args[2] $args[1]"
time swgoh-tool --fetch $args[2] $args[1] || exit 1


for ((i = 1; i < $#guilds; i++)) ; do 
	args=("${(@s/ /)guilds[i]}")
	
	# now build the guild we just fetched
	echo "swgoh-tool --guild $args[1].json --site docs"
	time swgoh-tool --guild $args[1].json --site docs &
	
	# and fetch the next one
	
	echo "==============="
	args=("${(@s/ /)guilds[i + 1]}")
	echo "FETCH: $args"

	echo "swgoh-tool --fetch $args[2] $args[1]"
	time swgoh-tool --fetch $args[2] $args[1] || exit 1
	
	# wait for both to complete
	wait
	
done

# finish the pipeline
args=("${(@s/ /)guilds[$#guilds]}")
echo "swgoh-tool --guild $args[1].json --site docs"
time swgoh-tool --guild $args[1].json --site docs &

echo "==============="
echo "ALLIANCE"

time swgoh-tool --alliance docs *.json

wait

ret=$?

times 

### Hotfixes ###
echo "==============="
echo "HOTFIXES"

echo "Fixing character icons"
sed -i '' "s/content:/background-size: cover; background-image:/g" docs/toons.css

echo "Rebranding BGA to LPC"
# Because html files get overwritten every time
find docs/ -type f -name '*.html' -exec sed -i '' 's/BRG Alliance/LP Community/g' {} \;

echo "Renaming Alliance to Community"
# Remove extra "Alliance" from page names
find docs/ -type f -name '*.html' -exec sed -i '' 's/: Alliance/:/g' {} \;

# Rename "Alliance" to "Community"
find docs/ -type f -name '*.html' -exec sed -i '' 's/Alliance/Community/g' {} \;

### End of script ###
exit "$ret"
