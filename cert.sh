dir=$(cd `dirname $0`;pwd)
cd $dir
isInstall=$(which bundler)
if [[ "$isInstall" == "" ]]
then
	source ./install.sh
fi
bundle exec ruby ./config_store.rb --cert