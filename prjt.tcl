####################################################################
#set config parameters
####################################################################
set val(chan)	Channel/WirelessChannel		;#channel type
set val(prop)	Propagation/TwoRayGround	;#radio propagation model
set val(netif)	Phy/WirelessPhy			;#network interface type
set val(mac)	Mac/802_11			;#MAC type
set val(ifq)	Queue/DropTail/PriQueue		;#interface queue type
set val(ll)	LL				;#link layer type
set val(ant)	Antenna/OmniAntenna		;#antenna model
set val(ifqlen)	100				;#queue length
set val(nn)	3				;#number of nodes
set val(rp)	AODV				;#routing protocol



#########################################################
# intialize simulator and trace files
#########################################################
set ns [new Simulator]
set tracefile [open out.tr w]
$ns trace-all $tracefile


create-god $val(nn)

#set topology
set topo [new Topography]
$topo load_flatgrid 1000 1000

$ns node-config -adhocRouting $val(rp) -llType $val(ll) -macType $val(mac) -ifqType $val(ifq) -ifqLen $val(ifqlen) -antType $val(ant) -propType $val(prop) -phyType $val(netif) -channel [new $val(chan)]																 -topoInstance $topo -agentTrace ON -routerTrace ON -macTrace OFF -movementTrace OFF


####################################################################
# define nodes
####################################################################
#set n0 [$ns node]
#set n1 [$ns node]
#set n2 [$ns node]


for {set i 0} {$i < $val(nn)} {incr i} {
set n($i) [$ns node]
$n($i) random-motion 0
$n($i) set Y_ 0.0
$n($i) set Z_ 0.0
}

$n(0) set X_ 0.0
$n(1) set X_ 20.0
$n(2) set X_ 15.0



#####################################################################
# define sink and source; define traffic configuration
#####################################################################
set tcp [new Agent/TCP]
$ns attach-agent $n(1) $tcp
set tcp1 [new Agent/TCP]
$ns attach-agent $n(2) $tcp1
set sink [new Agent/TCPSink]
$ns attach-agent $n(0) $sink
$ns connect $tcp $sink
$ns connect $tcp1 $sink

######################################################################
# Set FTP 
######################################################################
#set ftp [new Application/FTP]
#$ftp attach-agent $tcp
#set ftp1 [new Application/FTP]
#$ftp attach-agent $tcp1

###################################################################
# Set CBR
###################################################################
set r 1M
set ps 512
set cbr [new Application/Traffic/CBR]
$cbr attach-agent $tcp
$cbr set rate_ $r
$cbr set packetSize_ $ps
set cbr1 [new Application/Traffic/CBR]
$cbr1 attach-agent $tcp1
$cbr1 set rate_ $r
$cbr1 set packetSize_ $ps
####################################################################
# Scheduling events 
####################################################################
$ns at 1.0 "$cbr start"
$ns at 1.0 "$cbr1 start"
#$ns at 2.0 "$ftp start"
#$ns at 2.0 "$ftp1 start"
$ns at 30.0 "$cbr stop"
$ns at 30.0 "$cbr1 stop"
#$ns at 31.0 "$ftp stop"
#$ns at 31.0 "$ftp1 stop"
$ns at 31.0 "exit 0"

$ns run



