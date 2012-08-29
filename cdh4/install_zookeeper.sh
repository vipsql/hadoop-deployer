#!/usr/bin/env bash
# -- utf-8 --
DIR=$(cd $(dirname $0); pwd)
. $DIR/PUB.sh

#必要工具的检查和安装,需要root或者sodu,考虑单独脚本
check_tools()
{
}

# $0 host
deploy()
{
  echo ">> deploy $1";
  # 1. 分发安装
  ssh "$USER@$1" "
    cd $D;
    . support/PUB.sh
    . support/deploy_zookeeper_env.sh
    tar -xzf tars/$ZK_TAR -C $HOME;
    ln -sf ./$ZK_VERSION $ZK_HOME;
  "
  # 2. profile文件
  ssh $USER@$1 "
    cd $D;
    . support/PUB.sh;
    . support/profile_zookeeper.sh;
    profile;
  "
  # 3. 配置 xml文件 
  ssh $USER@$1 sh $DIR/support/xml_zookeeper.sh; 
}

main() 
{
  cd $DIR
  
  show_head;
  
  file_die logs/install_zookeeper_ok "zookeeper is installed"
  notfile_die logs/install_deployer_ok
  
  check_tools;

  . ./config_zookeeper.sh

  download

  for s in $ZK_NODES; do
    same_to $s $DIR
    [ -f "logs/install_zookeeper_ok_${s}" ] && continue 
    deploy $s; 
    touch "logs/install_zookeeper_ok_${s}"
  done

  . $HOME/.bash_profile

  touch logs/zookeeper_ok
  echo ">> OK"
  cd $OLD_DIR
}

#=================
main $*;

