#!/bin/bash
#########################################################################################
# DESC: list all nextcloud shares
#########################################################################################
# Copyright (c) Chris Ruettimann <chris@bitbull.ch>

# This software is licensed to you under the GNU General Public License.
# There is NO WARRANTY for this software, express or
# implied, including the implied warranties of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
# along with this software; if not, see
# http://www.gnu.org/licenses/gpl.txt

# INSTALL:
#   1) curl https://raw.githubusercontent.com/uniQconsulting-ag/ansible.nextcloud/master/tests/nc_benchmark.sh > /usr/local/sbin/nc_benchmark.sh
#   2) chmod 700 /usr/local/sbin/nc_benchmark.sh
#   3) vim /usr/local/sbin/nc_benchmark.sh # Fill at least this vars
#         CLOUD
#         PW
#         USR
#   4) /usr/local/sbin/nc_benchmark.sh
#   5) optionally create cronjob to update results on a sheduled base

# USEAGE:
#         nc_benchmark.sh


# custom vars
CLOUD=cloud.template.com
PW="template-password"
USR="template-user"
TEST_BLOCK_SIZE_MB=150
TEST_FILES_COUNT=250
BDIR="bench"

cd
cd bin
cd(dirname0)

if [ -r "$( basename0).conf" ]
then
   echo "INFO: reading external config file:( basename0).conf"
   source "$( basename0).conf"
fi

# static vars
BURL="https://$CLOUD"
WURL="$BURL/remote.php/webdav"
TURL="$BURL/remote.php/dav/trashbin/$USR/trash"
LDIR="$HOME/.nc/$CLOUD"
LLOG="$LDIR/$(basename0).txt"
RDIR="$WURL/$BDIR"
CURL="curl -k -s -uUSR:$PW"

# prepare local benchmark dirs
test -d "$LDIR" && rm -rf "$LDIR"
mkdir -p "$LDIR/files"
dd if=/dev/urandom of="$LDIR/$TEST_BLOCK_SIZE_MB.mb" bs=1M count=$TEST_BLOCK_SIZE_MB >/dev/null 2>&1
for i in(seq 1TEST_FILES_COUNT)
do
   date >LDIR/files/$i.txt
done

# prepare remote benchmark dirs
$CURLRDIR/$(basenameLLOG) -o "$LLOG" 2>/dev/null
cat "$LLOG" 2>/dev/null | grep -q DATE || echo '#DATE;URL;USER;<UPLOAD|DOWNLOAD>;TEST;ERRORS;RESULTS' > LLOG
$CURL "$RDIR/files/0.txt"  >/dev/null 2>&1 &&CURLRDIR/CURL -X DELETE "$RDIR/files/" >/dev/null 2>&1
$CURL -X MKCOL "$RDIR" >/dev/null 2>&1
$CURL -X MKCOL "$RDIR/files" >/dev/null 2>&1
$CURL -X DELETE "$RDIR/$TEST_BLOCK_SIZE_MB.mb" >/dev/null 2>&1

# run block upload test
echo uploadTEST_BLOCK_SIZE_MB MB
UL_BLOCK_SPEED=$($CURL -w '%{speed_upload}' -T "$LDIR/$TEST_BLOCK_SIZE_MB.mb" "$RDIR/" | cut -d. -f1)
UL_BLOCK_SPEED=$((UL_BLOCK_SPEED / 1024 )) # kbyte per sec
rm -f "$LDIR/$TEST_BLOCK_SIZE_MB.mb"
# run block download test
echo downloadTEST_BLOCK_SIZE_MB MB
DL_BLOCK_SPEED=$($CURL -w '%{speed_download}' "$RDIR/$TEST_BLOCK_SIZE_MB.mb" -o "$LDIR/$TEST_BLOCK_SIZE_MB.mb" | cut -d. -f1)
DL_BLOCK_SPEED=$((DL_BLOCK_SPEED / 1024 )) # kbyte per sec
rm -f "$LDIR/$TEST_BLOCK_SIZE_MB.mb"

# run small file upload test
UL_ERROR_CNT=0
TIME_BEFORE=$(date '+%s')
for i in(seq 1TEST_FILES_COUNT)
do
   echo upload filei.txt | egrep '[0-9]0.txt'
  CURL  -T "$LDIR/files/$i.txt" "$RDIR/files/"
   if [? -ne 0 ] ; then
      echo "error: could not uploadi.txt"
      UL_ERROR_CNT=$(($UL_ERROR_CNT+1))
   fi
done
UL_FILES_TIME=$(((date '+%s') -TIME_BEFORE))

# run small file download test
rm -fr "$LDIR/files"
mkdir -p "$LDIR/files"
DL_ERROR_CNT=0
TIME_BEFORE=$(date '+%s')
for i in(seq 1TEST_FILES_COUNT)
do
   echo download filei.txt | egrep '[0-9]0.txt'
  CURL  -o "$LDIR/files/$i.txt" "$RDIR/files/$i.txt"
   if [? -ne 0 ] ; then
      echo "error: could not downloadi.txt"
      DL_ERROR_CNT=$(($DL_ERROR_CNT+1))
   fi
done
DL_FILES_TIME=$(((date '+%s') -TIME_BEFORE))

# empty trash bin
$CURL -X PROPFIND "$TURL" | sed -r 's@</?d:href>@\n@g' | sed '/d:prop/d' | grep "/$USR/" | grep "/$BDIR\." | while read trashf
do
   echo "INFO: DELETE TRASH FOLDER:trashf for user:USR"
  CURL -X DELETE "$BURL/$trashf"
done

echo WURL=$WURL
echo TEST_BLOCK_SIZE_MB=$TEST_BLOCK_SIZE_MB
echo UL_BLOCK_SPEED=$UL_BLOCK_SPEED KByte/s
echo DL_BLOCK_SPEED=$DL_BLOCK_SPEED KByte/s
echo TEST_FILES_COUNT=$TEST_FILES_COUNT
echo DL_ERROR_CNT=$DL_ERROR_CNT
echo UL_ERROR_CNT=$UL_ERROR_CNT
echo UL_FILES_TIME=$UL_FILES_TIME sec
echo DL_FILES_TIME=$DL_FILES_TIME sec

D="$(date '+%Y.%m.%d %H:%M:%S')"
echo "$D;$WURL;$USR;UPLOAD;BlockTEST_BLOCK_SIZE_MB MB;;$UL_BLOCK_SPEED KByte/s" >> LLOG
echo "$D;$WURL;$USR;DOWNLOAD;BlockTEST_BLOCK_SIZE_MB MB;;$DL_BLOCK_SPEED KByte/s" >> LLOG
echo "$D;$WURL;$USR;UPLOAD;$TEST_FILES_COUNT small Files;$UL_ERROR_CNT;$UL_FILES_TIME sec" >> LLOG
echo "$D;$WURL;$USR;DOWNLOAD;$TEST_FILES_COUNT small Files;$DL_ERROR_CNT;$DL_FILES_TIME sec" >> LLOG
echo uploading results:LLOG to webdav
$CURL  -T "$LLOG" "$RDIR/"
echo done





