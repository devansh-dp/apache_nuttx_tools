#!/bin/sh

ARCHLIST="arm avr hc mips misoc or1k renesas risc-v sim x86 xtensa z16 z80"

FILE=$1
if [ -z "$FILE" ]; then
  FILE=$PWD/armlist.template
fi

cd ..
if [ ! -d nuttx ]; then
  cd ..
  if [ ! -d nuttx ]; then
    echo "ERROR:  Cannot find the nuttx/ directory"
  fi
fi

nuttx=$PWD/nuttx

LIST=`cat $FILE`
for line in $LIST; do
# firstch=${line:0:1}
  firstch=`echo $line | cut -c1-1`
  if [ "X$firstch" != "X#" ]; then
    # Parse the configuration spec

    configspec=`echo $line | cut -d',' -f1`
    board=`echo $configspec | cut -d':' -f1`
    config=`echo $configspec | cut -d':' -f2`

    # Detect the architecture of this board.

    for entry in ${ARCHLIST}; do
      if [ -f $nuttx/boards/${entry}/${board}/Kconfig ]; then
        arch=${entry}
      fi
    done

    if [ -z "${arch}" ]; then
      echo "ERROR:  Architecture of ${board} not found"
    else
      path=$nuttx/boards/$arch/$board/configs/$config/defconfig
      if [ ! -r $path ]; then
        echo "ERROR: $path does not exist"
      fi
    fi
  fi
done
