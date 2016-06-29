deploy:
	rm -fR public
	hugo
	rsync -az --delete -e ssh public/ onion:/srv/lambdafu/lambdafu.net

update:
	ssh -A onion 'git -C /srv/lambdafu/lambdafu.net pull'

