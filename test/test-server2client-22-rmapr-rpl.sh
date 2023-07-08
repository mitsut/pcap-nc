#!/usr/bin/env bash

# case 22.
#                  server       network       client
# xxx/PCAP => RMAPRD/PCAP => {RMAPRD/PCAP} => RMAPRD/PCAP =+> SPP/RMAPRR/PCAP
#                                                SPP/PCAP =+

mkdir -p outdir

CHAN='--config=sample.json --channel=channel3' # RMAP Read Command

PCAPNC='../bin/pcap-nc'
NC='stdbuf -i 0 -o 0 nc -w 10'
OPTSEND='--original-time --interval=0.001 --before=2'
OPTSERV='-l 14800'
OPTCLNT='127.0.0.1 14800'

echo starting server
$PCAPNC $OPTSERV $OPTSEND $CHAN < test-spp.pcap >/dev/null &

sleep 1
echo starting client
$NC $OPTCLNT | ../bin/pcap-rmap-target $CHAN --send-data=test-spp.pcap | ../bin/pcap-store --link-type=spw >outdir/test-rmapr-rpl-out.pcap
