echo "deleting generated files"

while read p; do
    rm $p
done <dapt_generated_files.txt

echo "generate processor"
$DAPT_BIN -p /home/andrey/projects/dapt-examples/ecs/src/processors -s /home/andrey/projects/dapt-examples/ecs/src -r /home/andrey/projects/dapt-examples/ecs

echo "processing"
dub run --build=dapt
