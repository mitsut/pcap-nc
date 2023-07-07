#!/usr/bin/env bash

# case 15.
#                      server                         client
# SPP/PCAP => SPP/RMAPWC/PCAP => {SPP/RMAPWC/PCAP} => SPP/RMAPWC/PCAP
#  (check) <=     RMAPWR/PCAP <=     {RMAPWR/PCAP} <=     RMAPWR/PCAP

mkdir -p outdir

CHAN='--config=sample.json --channel=channel2' # RMAP Write Command with Acknowledge

PCAPNC='stdbuf -i 0 -o 0 ../bin/pcap-nc'
OPTSEND='--original-time --interval=0.001 --before=2'
OPTSERV='-l 14800'
OPTCLNT='127.0.0.1 14800 --no-stdin'

echo starting server
$PCAPNC $OPTSERV $OPTSEND $CHAN < test-spp.pcap --after=1.0 --check-reply &

sleep 1
echo starting client
FIFO=/tmp/pcap-fifo
mkfifo $FIFO
$PCAPNC $OPTCLNT --link-type=spw <$FIFO | ../bin/pcap-rmap-target $CHAN >$FIFO
rm $FIFO
