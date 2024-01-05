build/frp34.pdf: frp34.tex macro.tex build/frp34.bbl
	mkdir -p build
	pdflatex -synctex=1 -interaction=batchmode -output-directory=build frp34

build-once:
	pdflatex -synctex=1 -interaction=batchmode -output-directory=build frp34

debug:
	pdflatex -synctex=1 -output-directory=build frp34


build/frp34.bbl: build/frp34.bcf
	biber build/frp34 --quiet

build/frp34.bcf: frp34.tex  
	pdflatex -synctex=1 -interaction=batchmode -output-directory=build frp34

clean:
	rm build/*