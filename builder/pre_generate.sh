while read p; do
	rm $p
done <dapt_generated_files.txt

/home/andrey/projects/dapt/dapt -p /home/andrey/projects/builder/src/processors -s /home/andrey/projects/builder/src -r /home/andrey/projects/builder
dub run --build=dapt
