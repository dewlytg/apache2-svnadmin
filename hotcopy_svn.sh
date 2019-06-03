#!/bin/bash

RootDir=$(pwd)
SvnDir=${SVN_REPOS}
HotcopyRootDir=${SVN_HOT_BACKUPS}
HotcopyDir=$HotcopyRootDir$(date +%a)/repos

echo "svn dir [$SvnDir]"
echo "hotcopy dir [$HotcopyDir]"

mkdir -p $HotcopyDir

ls $SvnDir | while read repo; do
    echo "Begin hotcopy repo [$repo]"
    echo "hotcopy from [$SvnDir/$repo] to [$HotcopyDir/$repo]"
    svnadmin hotcopy $SvnDir/$repo $HotcopyDir/$repo
done

tar -zcf HotcopyRootDir$(date +%a).tar.gz $HotcopyRootDir$(date +%a)/repos

rm -rf $HotcopyDir
