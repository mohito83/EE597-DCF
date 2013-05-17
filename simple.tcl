set ns [new Simulator]
$ns at 1 "puts \"Hello World\""
$ns at 5 "exit"
$ns run
