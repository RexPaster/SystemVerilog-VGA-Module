# Upduino 3.1 SystemVerilog Development Template

A ready-to-use template for building SystemVerilog designs on the [Upduino 3.1](https://upduino.readthedocs.io/) (iCE40UP5K-SG48) FPGA, with a full toolchain inside a dev container (no local installs required).

## Quick start

1. Open this repository in VS Code with the Dev Containers extension — the container will build automatically.
2. Write your design in `top.sv` and your testbench in `top_tb.sv`.
3. Add pin assignments for any new ports to `top.pcf`.
4. Use the VS Code tasks (Terminal → Run Task) to build, verify, and program.

## File overview

| File | Purpose |
|---|---|
| `top.sv` | Top-level design module — edit this |
| `top_tb.sv` | Testbench for simulation |
| `top.pcf` | Pin constraint file (maps port names to physical pins) |
| `dependencies.mk` | Lists build targets and their source file dependencies |

## Tasks

All tasks are available via **Terminal → Run Task** (or the Tasks panel).

### Edit top.sv
Opens `top.sv` in the editor. Shortcut to jump straight to the design file.

### FPGA Image Server
Starts a local web server (port 3000) that serves the generated SVG and HTML visualisation files. Must be running before opening any routing/placement views in the browser. Runs in the background — start it once per session.

### Simulate top.sv
Runs Yosys on `top.sv` (RTL sources only, no testbench) and produces `products/top.rtl.json`. This JSON can be opened in the built-in netlist viewer to inspect the synthesised RTL. Useful for a quick sanity-check of your logic before running the full testbench.

### top testbench verification
Compiles `top.sv` + `top_tb.sv` with Icarus Verilog and runs the simulation. Produces `products/top_tb.vcd` — a waveform dump that can be opened with a VCD viewer (e.g. the VSCode WaveTrace extension). Check the terminal output for any assertion failures or unexpected `$finish` times.

### top AIG Mapping
Synthesises the design to an And-Inverter Graph (AIG) and opens an SVG schematic of the result. Useful for understanding the Boolean structure of combinational logic before mapping to FPGA primitives.

### top iCE40 Mapping
Runs `synth_ice40` in Yosys and opens an SVG schematic of the post-synthesis iCE40 netlist (LUTs, carry chains, flip-flops). Use this to check how many LUTs your design uses and how the logic has been decomposed into iCE40 primitives.

### top iCE40 Bitstream
Full build pipeline: Yosys synthesis → nextpnr place-and-route → icepack bitstream. Produces `products/top.bin`, which can be flashed to the Upduino with `iceprog`. Requires all ports listed in `top.sv` to have entries in `top.pcf`.

### top iCE40 Routing
Runs the full place-and-route (same as bitstream, but stops after routing) and opens an interactive HTML view showing the physical placement and routing on the iCE40 die. The FPGA Image Server must be running to view it. Also reports timing: max frequency, critical path, and slack histogram.

## Adding ports

1. Declare them in `top.sv` and `top_tb.sv`.
2. Add a `set_io <port> <pin>` line to `top.pcf`. Pin numbers are Upduino 3.1 physical pin numbers — see the [pin reference](https://upduino.readthedocs.io/en/latest/features/pins.html).

## Background and attribution

Adapted from Bill Siever's CS2600 homework templates (Washington University in St. Louis). Uses his Docker image as the dev environment foundation.
