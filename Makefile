ripple.love:
	zip -r ripple.love *

clean:
	rm -f ripple.love

run: ripple.love
	love-hg ripple.love
