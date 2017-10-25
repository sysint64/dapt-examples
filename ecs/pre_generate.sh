while read p; do
	rm $p
done <dapt_generated_files.txt

$DAPT_BIN -p /home/andrey/projects/dapt-examples/ecs/src/processors -s /home/andrey/projects/dapt-examples/ecs/src -r /home/andrey/projects/dapt-examples/ecs
dub run --build=dapt
