BEGIN {
count = 0;
throughput = 0;
}
{
if ( $1 == "r" && $3 == "_0_" && $4 == "AGT" && $7 == "cbr" && $11 == 1){
count++; }
}
END {
throughput = count * 8 *512/ 30;
printf("\n #Packets received %d",count);
printf ( "\nThroughput is %f Kbps", throughput/1000);
printf("%f\n",throughput/1000) >> "part1.dat";
}
