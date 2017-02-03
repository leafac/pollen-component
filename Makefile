.PHONY: documentation documentation/deploy documentation/clean clean

documentation: compiled-documentation/index.html

compiled-documentation/index.html: documentation/pollen-component.scrbl
	cd documentation && raco scribble --dest ../compiled-documentation/ --dest-name index -- pollen-component.scrbl

documentation/deploy: documentation
	rsync -av --delete compiled-documentation/ leafac.com:leafac.com/websites/software/pollen-component/

documentation/clean:
	rm -rf compiled-documentation
	rm -f documentation/*.{tex,pdf,png,aux,log}

clean: documentation/clean
