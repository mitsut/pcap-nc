#!/usr/bin/env bash

# case 15.
#                      server                         client
# SPP/PCAP => SPP/RMAPWC/PCAP => {SPP/RMAPWC/PCAP} => SPP/RMAPWC/PCAP
#  (check) <=     RMAPWR/PCAP <=     {RMAPWR/PCAP} <=     RMAPWR/PCAP

mkdir -p outdir

CHAN='--config=sample.json --channel=channel2' # RMAP Write Command with Acknowledge
FIFO=/tmp/pcap-fifo
mkfifo $FIFO

PCAPNC='stdbuf -i 0 -o 0 ../bin/pcap-nc'
OPTSEND='--original-time --interval=0.001 --after=5'
OPTRSPN='--original-time --interval=0.0'
OPTSERV='-l 14800'
OPTCLNT='127.0.0.1 14800 --no-stdin'

SVOPT1='-l 14800'
SVOPT2='--interval=0.001 --after=5 --original-time'

echo starting server
$PCAPNC $OPTSERV $OPTSEND $CHAN --check-reply < test-spp.pcap >&/dev/null &

sleep 1
echo starting client
$PCAPNC $OPTCLNT --link-type=spw <$FIFO | ../bin/pcap-rmap-target $CHAN | ../bin/pcap-replay $OPTRSPN >$FIFO

rm $FIFO