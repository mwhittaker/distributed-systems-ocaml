dirs="async readwrite tcp"

for d in $dirs; do
    cat ../$d/doc.odocl
done > doc.odocl
