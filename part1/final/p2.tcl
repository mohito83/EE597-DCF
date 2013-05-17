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
set val(ifqlen)	250				;#queue length
set val(nn)	20				;#number of nodes
set val(rp)	DSDV				;#routing protocol



#########################################################
# intialize simulator and trace files
#########################################################
set ns [new Simulator]

set tracefile1 [open p1.tr w]
$ns trace-all $tracefile1

proc finish {c} {
global ns tracefile1 namfile1
$ns flush-trace
close $tracefile1
exec awk -f throughput.awk p1.tr &
set ab [open part1.dat a]
puts $ab "$c"
exit 0
}

create-god $val(nn)

set topo [new Topography]
$topo load_flatgrid 500 500

$ns node-config -adhocRouting $val(rp) -llType $val(ll) -macType $val(mac) -ifqType $val(ifq) -ifqLen $val(ifqlen) -antType $val(ant) -propType $val(prop) -phyType $val(netif) -channel [new $val(chan)]                                                                                                                                -topoInstance $topo -agentTrace ON -routerTrace ON -macTrace OFF -movementTrace OFF



####################################################################
# define nodes
####################################################################
set r 1000000
set ps 512


# placing transmitter nodes in the grid

set x {250.0 300.0 283.01583541220401 243.60181551862976 208.53450835684248 201.63747058630588 227.59631919354149 268.77547988835062 297.19920695761573 293.55737005161717 260.32411146689054 220.07699654710709 200.15857025152846 214.10074580151434 252.43167502694845 289.11060549711357 299.21909753162527 275.88977943254065 234.97181033249583 204.26349110323125}

set y {250.0 250.0 212.45063766141618 200.41105732784422 222.06054755741917 262.69116813810183 294.69983318002789 296.34092527088927 266.4995412836891 225.44892030507654 201.07748246033103 209.94236821330847 246.02107041678582 284.80292441724555 299.94083456014039 281.15061055018265 241.19770267643943 207.22478146245896 202.31191432530005 229.79673902718196}
	
#set stepSize 360/[expr $val(nn)-1]
#set theta 0 
#set x 250.0
#set y 250.0
#for {set i 1} {$i < $val(nn)} {incr i} {
#	lappend x [expr 50.0*cos($theta)+250.0]
#       lappend y [expr 50.0*sin($theta)+250.0]
#	set theta [expr $stepSize + $theta]
#}	


#layout the nodes
set a 0.0
set b 0.0
for {set i 0} {$i < $val(nn)} {incr i} {
	set a [lindex $x $i]
	set b [lindex $y $i]
	set n($i) [$ns node]
        $n($i) random-motion 0
        $n($i) set Y_ $b
        $n($i) set X_ $a
	$n($i) set Z_ 0.0
	$ns at 0.1 "puts \"$i: $a $b\""
	#set a [expr $a + 5.0]
}
	
	#attach sink with the receiver node
	set sink [new Agent/Null]
	$ns attach-agent $n(0) $sink


for {set i 1} {$i < $val(nn)} {incr i} {
	# set up agent and traffic for each node
	set udp($i) [new Agent/UDP]
	$ns attach-agent $n($i) $udp($i)
	$ns connect $udp($i) $sink
	
	# set up CBR
	set cbr($i) [new Application/Traffic/CBR]
	$cbr($i) attach-agent $udp($i)
	$cbr($i) set rate_ $r
	$cbr($i) set packetSize_ $ps
	
	#set events
	$ns at 1.0 "$cbr($i) start"
	$ns at 31.0 "$cbr($i) stop"
}


	
####################################################################
# Scheduling events 
####################################################################
$ns at 32.0 "finish {$r}"
$ns at 32.1 "puts \"NS EXITING...\"; $ns halt"


$ns run



