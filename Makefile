deploy:
	rm -fR public
	hugo
	rsync -azvP --delete -e ssh public/ onion:/srv/lambdafu/lambdafu.net

update:
	ssh -A onion 'git -C /srv/lambdafu/lambdafu.net pull'

run:
	hugo server -D -d dev

