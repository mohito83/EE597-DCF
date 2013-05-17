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

set topo [new Topography]
$topo load_flatgrid 500 500

$ns node-config -adhocRouting $val(rp) -llType $val(ll) -macType $val(mac) -ifqType $val(ifq) -ifqLen $val(ifqlen) -antType $val(ant) -propType $val(prop) -phyType $val(netif) -channel [new $val(chan)]																 -topoInstance $topo -agentTrace ON -routerTrace ON -macTrace OFF -movementTrace OFF


set tracefile1 [open part1.tr w]
$ns trace-all $tracefile1


proc finish {c} {
global ns tracefile1 namfile1
$ns flush-trace
close $tracefile1
exec awk -f throughput.awk part1.tr &
set ab [open part1.dat a]
puts $ab " $c"
exit 0
}


####################################################################
# define nodes
####################################################################
set r 1M
set ps 512
proc w_topo {nn} {
	global ns r ps
	create-god $nn

	#placing the receiver node at the center of the grid
	set n(0) [$ns node]
	$n(0) random-motion 0
	$n(0) set Y_ 250.0
	$n(0) set Z_ 0.0
	$n(0) set X_ 250.0
	
	#attach sink with the receiver node
	set sink [new Agent/Null]
	$ns attach-agent $n(0) $sink
	
	
	# placing transmitter nodes in the grid	
	set stepSize 360/$nn
	set theta 0
	for {set i 1} {$i < $nn} {incr i} {
		set n($i) [$ns node]
		$n($i) random-motion 0
		set x [expr 125*cos($theta)+250]
		set y [expr 125*sin($theta)+250]
		$n($i) set Y_ y
		$n($i) set X_ x
		$n($i) set Z_ 0.0
		$theta [expr $theta+stepSize]
		
		# set up agent and traffic for each node
		set udp($i) [new Agent/UDP]
		$ns attach-agent $n($i) $udp($i)
		$ns connect $udp($i) $sink
		
		# set up CBR
		set cbr($i) [new Application/Traffic/CBR]
		$cbr($i) attach-agent $udp($i)
		$cbr($i) set rate_ $r
		$cbr($i) set packetSize_ $ps
	}

}


####################################################################
# Scheduling events 
####################################################################
set x 2
$ns at 0.1 "w_topo {$x}"
#schedule events
#for {set k 1} {$k < $x} {incr k} {
#	$ns at 1.5 "$cbr({$k}) start"
#	$ns at 31.5 "$cbr({$k}) stop"
#}
$ns at 32.0 "finish {2}"
$ns at 32.1 "puts \"NS EXITING...\"; $ns halt"


$ns run



