dir=$(cd `dirname $0`;pwd)
cd $dir
isInstall=$(which rvm)
if [[ "$isInstall" == "" ]]
then
	curl -L https://get.rvm.io | bash -s stable
	source ~/.rvm/scripts/rvm
fi
isInstall=$(which ruby)
if [[ "$isInstall" == "" ]]
then
	rvm install 2.6.0
	rvm use 2.6.0
fi
isInstall=$(which bundler)
if [[ "$isInstall" == "" ]]
then
	gem install bundler
fi
bundler install
