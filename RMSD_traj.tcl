

if {[llength $argv] != 3} {
    puts "Usage: vmd -dispdev text -e RMSD_traj.tcl -args psf traj fileout"
    exit
}

foreach {psf traj fileout} $argv { break }
set fp [open $fileout w]

set mol1 [mol load psf $psf]
mol addfile $traj first 0 waitfor all
puts $fp "frame\trmsd"

set reference [atomselect top "noh protein" frame 0]
set reference_mol [atomselect top "noh resname LIG" frame 0]
# the frame being compared
set compare [atomselect top "noh protein"]
set num_steps [molinfo top get numframes]
for {set frame 0} {$frame < $num_steps} {incr frame} {
        # get the correct frame
        $compare frame $frame

        # compute the transformation
        set trans_mat [measure fit $compare $reference]
        # do the alignment
	set system [atomselect top "all" frame $frame]
        $system move $trans_mat
	set unk_actual [atomselect top "noh resname LIG" frame $frame]
        # compute the RMSD
        set rmsd [measure rmsd $unk_actual $reference_mol]
        # print the RMSD
        puts $fp "$frame\t$rmsd"
}
close $fp
foreach v [ info vars ] { unset $v }
unset v 
quit
