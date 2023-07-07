#!/usr/bin/env bash

# case 21.
#                  client       network       server
# xxx/PCAP => RMAPRD/PCAP => {RMAPRD/PCAP} => RMAPRD/PCAP

mkdir -p outdir

CHAN='--config=sample.json --channel=channel3' # RMAP Read Command
PCAPNC='../bin/pcap-nc'
OPTSEND='--original-time --interval=0.001'
OPTSERV='--no-stdin -l 14800'
OPTCLNT='127.0.0.1 14800 --sleep=1'

echo starting client
$PCAPNC $OPTCLNT $OPTSEND $CHAN < test-spp.pcap >/dev/null &

echo starting server
$PCAPNC $OPTSERV --link-type=spw >outdir/test-rmapr-out.pcap
