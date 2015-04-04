ripple.love:
	zip -r ripple.love *

clean:
	rm -f ripple.love
	rm -rf releases/*

run: ripple.love
	love-hg ripple.love

release:
	love-release -lmw
