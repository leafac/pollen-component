.PHONY: documentation/clean clean

documentation/clean:
	rm -f documentation/*.{tex,pdf,png,aux,log}

clean: documentation/clean
