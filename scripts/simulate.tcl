# -----------------------------------------------------------------------
# Author: Szymon Bogus
# Date:   10.07.2025
#
# Description:
# This TCL script aims to automate running multiple tesbenches. Each tesbench
# creates its own directory inside simulation/waveforms inside which logs and
# results are saved.
# License: GNU GPL
# -----------------------------------------------------------------------


# Arguments: language hdl_dir sim_dir wave_dir [tb1 tb2 ...]
set language    [lindex $argv 0]
set hdl_dir     [file normalize [lindex $argv 1]]
set sim_src_dir [file normalize [lindex $argv 2]]
set wave_dir    [file normalize [lindex $argv 3]]
set tb_names    [lrange $argv 4 end]

# Determine HDL file extension
if {$language eq "verilog"} {
    set lang v
} elseif {$language eq "vhdl"} {
    set lang vhd
} elseif {$language eq "systemverilog"} {
    set lang sv
} else {
    error "Unrecognized HDL: $language"
}

# Prepare output directory
file mkdir $wave_dir

# Find design and testbench source files
set design_files    [glob -nocomplain "$hdl_dir/*.$lang"]
set all_tb_files    [glob -nocomplain "$sim_src_dir/*.$lang"]

# Filter testbenches
set tb_files {}
if {[llength $tb_names] == 0} {
    set tb_files $all_tb_files
} else {
    foreach tb_name $tb_names {
        set base_name [file rootname $tb_name]
        set tb_file "$sim_src_dir/$base_name.$lang"
        if {[file exists $tb_file]} {
            lappend tb_files $tb_file
        } else {
            puts "Warning: Testbench not found: $tb_file"
        }
    }
}

if {[llength $tb_files] == 0} {
    puts "ERROR: No valid testbench files to simulate."
    exit 1
}

# Simulate each testbench
foreach tb_file $tb_files {
    set tb_mod [file rootname [file tail $tb_file]]
    puts "\n--- Simulating: $tb_mod ---"

    # Per-testbench output directory
    set tb_dir "$wave_dir/$tb_mod"
    file delete -force $tb_dir
    file mkdir $tb_dir
    cd $tb_dir

    # Compile
    foreach file [concat $design_files $tb_file] {
        puts "Compiling $file"
        if {$language eq "verilog"} {
            exec xvlog $file -log "xvlog.log"
        } elseif {$language eq "vhdl"} {
            exec xvhdl $file -log "xvhdl.log"
        } elseif {$language eq "systemverilog"} {
            exec xvlog -sv $file -log "xvlog.log"
        }
    }

    # Elaborate
    exec xelab -debug typical -top $tb_mod -snapshot ${tb_mod}_snap -log xelab.log

    # Simulate and capture output
    exec xsim ${tb_mod}_snap -R -log xsim.log > sim_output.txt

    # Rename waveform if created
    if {[file exists "waveform.vcd"]} {
        file rename -force "waveform.vcd" "$tb_mod.vcd"
        puts "Waveform saved as $tb_mod.vcd"
    }

    # Report possible failures
    set fp [open "sim_output.txt" r]
    set log_contents [read $fp]
    close $fp

    if {[regexp -nocase {FAIL|FATAL|ASSERT|ERROR} $log_contents]} {
        puts "$tb_mod: Simulation may have failed. Check sim_output.txt"
    } else {
        puts "$tb_mod: Simulation passed."
    }

    puts "Logs saved to: $tb_dir"
}