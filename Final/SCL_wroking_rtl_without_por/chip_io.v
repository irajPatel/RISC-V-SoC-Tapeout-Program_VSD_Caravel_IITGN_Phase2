// SPDX-FileCopyrightText: 2020 Efabless Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0

// `default_nettype none
module chip_io(
	// Package Pins
	inout  vddio_pad,		// Common padframe/ESD supply
	inout  vddio_pad2,
	inout  vssio_pad,		// Common padframe/ESD ground
	inout  vssio_pad2,
	inout  vccd_pad,		// Common 1.8V supply
	inout  vssd_pad,		// Common digital ground
	inout  vdda_pad,		// Management analog 3.3V supply
	inout  vssa_pad,		// Management analog ground
	inout  vdda1_pad,		// User area 1 3.3V supply
	inout  vdda1_pad2,		
	inout  vdda2_pad,		// User area 2 3.3V supply
	inout  vssa1_pad,		// User area 1 analog ground
	inout  vssa1_pad2,
	inout  vssa2_pad,		// User area 2 analog ground
	inout  vccd1_pad,		// User area 1 1.8V supply
	inout  vccd2_pad,		// User area 2 1.8V supply
	inout  vssd1_pad,		// User area 1 digital ground
	inout  vssd2_pad,		// User area 2 digital ground

	// Core Side
	inout  vddio,		// Common padframe/ESD supply
	inout  vssio,		// Common padframe/ESD ground
	inout  vccd,		// Common 1.8V supply
	inout  vssd,		// Common digital ground
	inout  vdda,		// Management analog 3.3V supply
	inout  vssa,		// Management analog ground
	inout  vdda1,		// User area 1 3.3V supply
	inout  vdda2,		// User area 2 3.3V supply
	inout  vssa1,		// User area 1 analog ground
	inout  vssa2,		// User area 2 analog ground
	inout  vccd1,		// User area 1 1.8V supply
	inout  vccd2,		// User area 2 1.8V supply
	inout  vssd1,		// User area 1 digital ground
	inout  vssd2,		// User area 2 digital ground

	inout  gpio,
	input  clock,
	input  resetb,
	output flash_csb,
	output flash_clk,
	inout  flash_io0,
	inout  flash_io1,
	// Chip Core Interface
	input  porb_h,
	input  por,
	output resetb_core_h,
	output clock_core,
	input  gpio_out_core,
	output gpio_in_core,
	input  gpio_mode0_core,
	input  gpio_mode1_core,
	input  gpio_outenb_core,
	input  gpio_inenb_core,
	input  flash_csb_core,
	input  flash_clk_core,
	input  flash_csb_oeb_core,
	input  flash_clk_oeb_core,
	input  flash_io0_oeb_core,
	input  flash_io1_oeb_core,
	input  flash_io0_ieb_core,
	input  flash_io1_ieb_core,
	input  flash_io0_do_core,
	input  flash_io1_do_core,
	output flash_io0_di_core,
	output flash_io1_di_core,
	// User project IOs
	inout [`MPRJ_IO_PADS-1:0] mprj_io,
	input [`MPRJ_IO_PADS-1:0] mprj_io_out,
	input [`MPRJ_IO_PADS-1:0] mprj_io_oeb,
	input [`MPRJ_IO_PADS-1:0] mprj_io_inp_dis,
	input [`MPRJ_IO_PADS-1:0] mprj_io_ib_mode_sel,
	input [`MPRJ_IO_PADS-1:0] mprj_io_vtrip_sel,
	input [`MPRJ_IO_PADS-1:0] mprj_io_slow_sel,
	input [`MPRJ_IO_PADS-1:0] mprj_io_holdover,
	input [`MPRJ_IO_PADS-1:0] mprj_io_analog_en,
	input [`MPRJ_IO_PADS-1:0] mprj_io_analog_sel,
	input [`MPRJ_IO_PADS-1:0] mprj_io_analog_pol,
	input [`MPRJ_IO_PADS*3-1:0] mprj_io_dm,
	output [`MPRJ_IO_PADS-1:0] mprj_io_in,
	// Loopbacks to constant value 1 in the 1.8V domain
	input [`MPRJ_IO_PADS-1:0] mprj_io_one,
	// User project direct access to gpio pad connections for analog
	// (all but the lowest-numbered 7 pads)
	inout [`MPRJ_IO_PADS-10:0] mprj_analog_io
);

    // Note: analog_io connections are not supported in SCL180
    // These remain as ports for compatibility but are not connected

    wire [`MPRJ_IO_PADS-1:0] mprj_io_enh;
    assign mprj_io_enh = {`MPRJ_IO_PADS{porb_h}};
	
	wire analog_a, analog_b;
	wire vddio_q, vssio_q;

	// ========================================================================
	// SCL180 POWER PADS - Replacing Sky130 ESD Clamp Pads
	// Note: SCL180 has no integrated ESD clamps - add external protection
	// ========================================================================

	// Management domain VDDIO pads (replacing hvclamp pads)
    	pvda mgmt_vddio_pad_0 (.VDDO(vddio_pad));
    	pvda mgmt_vddio_pad_1 (.VDDO(vddio_pad2));

	// Management domain VDDA pad
    	pvda mgmt_vdda_pad (.VDDO(vdda_pad));

	// Management domain VCCD pad
    	pvdi mgmt_vccd_pad (.VDD(vccd_pad));

	// Management domain VSSIO pads
    	pv0a mgmt_vssio_pad_0 (.VSSO(vssio_pad));
    	pv0a mgmt_vssio_pad_1 (.VSSO(vssio_pad2));

	// Management domain VSSA pad
    	pv0a mgmt_vssa_pad (.VSSO(vssa_pad));

	// Management domain VSSD pad
    	pv0i mgmt_vssd_pad (.VSS(vssd_pad));

	// User area 1 VDDA pads
    	pvda user1_vdda_pad_0 (.VDDO(vdda1_pad));
	pvda user1_vdda_pad_1 (.VDDO(vdda1_pad2));

	// User area 1 VCCD pad
    	pvdi user1_vccd_pad (.VDD(vccd1_pad));

	// User area 1 VSSA pads
    	pv0a user1_vssa_pad_0 (.VSSO(vssa1_pad));
    	pv0a user1_vssa_pad_1 (.VSSO(vssa1_pad2));

	// User area 1 VSSD pad
    	pv0i user1_vssd_pad (.VSS(vssd1_pad));

	// User area 2 VDDA pad
    	pvda user2_vdda_pad (.VDDO(vdda2_pad));

	// User area 2 VCCD pad
    	pvdi user2_vccd_pad (.VDD(vccd2_pad));

	// User area 2 VSSA pad
    	pv0a user2_vssa_pad (.VSSO(vssa2_pad));

	// User area 2 VSSD pad
    	pv0i user2_vssd_pad (.VSS(vssd2_pad));

	// ========================================================================
	// MODE CONTROL SIGNAL TRANSLATION
	// Sky130 uses dm[2:0], SCL180 uses OEN (active low) and RENB (active low)
	// ========================================================================
	
	wire [2:0] dm_all = {gpio_mode1_core, gpio_mode1_core, gpio_mode0_core};
	wire[2:0] flash_io0_mode = {flash_io0_ieb_core, flash_io0_ieb_core, flash_io0_oeb_core};
	wire[2:0] flash_io1_mode = {flash_io1_ieb_core, flash_io1_ieb_core, flash_io1_oeb_core};

    	wire [6:0] vccd_const_one;	// Constant value for management pins
    	wire [6:0] vssd_const_zero;	// Constant value for management pins

    	constant_block constant_value_inst [6:0] (
	`ifdef USE_POWER_PINS
		.vccd(vccd),
		.vssd(vssd),
	`endif
		.one(vccd_const_one),
		.zero(vssd_const_zero)
    	);

	// ========================================================================
	// MANAGEMENT SIGNAL PADS - Using SCL180 I/O cells
	// ========================================================================

	// Management clock input pad
	pc3d01 clock_pad (
		.PAD(clock),
		.CIN(clock_core)
	);

	// Management GPIO pad (bidirectional)
	pc3b03ed gpio_pad (
		.PAD(gpio),
		.OEN(gpio_outenb_core),
		.RENB(1'b1),  // Pull-down disabled
		.I(gpio_out_core),
		.CIN(gpio_in_core)
	);

	// Management Flash SPI pads
	pc3b03ed flash_io0_pad (
		.PAD(flash_io0),
		.OEN(flash_io0_oeb_core),
		.RENB(1'b1),
		.I(flash_io0_do_core),
		.CIN(flash_io0_di_core)
	);
	
	pc3b03ed flash_io1_pad (
		.PAD(flash_io1),
		.OEN(flash_io1_oeb_core),
		.RENB(1'b1),
		.I(flash_io1_do_core),
		.CIN(flash_io1_di_core)
	);

	pc3o01 flash_csb_pad (
		.PAD(flash_csb),
		.I(flash_csb_core)
	);

	pc3o01 flash_clk_pad (
		.PAD(flash_clk),
		.I(flash_clk_core)
	);

	// ========================================================================
	// RESET PAD
	// Note: SCL180 has no dedicated reset pad with glitch filtering
	// Using simple input pad - add external RC filter on PCB
	// Recommended: 10k pull-up + 100nF cap to ground
	// ========================================================================
	
	pc3d01 resetb_pad (
		.PAD(resetb),
		.CIN(resetb_core_h)
	);

	// Corner cells removed - SCL180 has no corner pad cells
	// Ensure power ring connectivity through proper metal routing

	// ========================================================================
	// USER PROJECT I/O PADS
	// ========================================================================

	mprj_io mprj_pads(
		.vddio(vddio),
		.vssio(vssio),
		.vccd(vccd),
		.vssd(vssd),
		.vdda1(vdda1),
		.vdda2(vdda2),
		.vssa1(vssa1),
		.vssa2(vssa2),
		.vddio_q(vddio_q),
		.vssio_q(vssio_q),
		.analog_a(analog_a),
		.analog_b(analog_b),
		.porb_h(porb_h),
		.vccd_conb(mprj_io_one),
		.io(mprj_io),
		.io_out(mprj_io_out),
		.oeb(mprj_io_oeb),
		.enh(mprj_io_enh),
		.inp_dis(mprj_io_inp_dis),
		.ib_mode_sel(mprj_io_ib_mode_sel),
		.vtrip_sel(mprj_io_vtrip_sel),
		.holdover(mprj_io_holdover),
		.slow_sel(mprj_io_slow_sel),
		.analog_en(mprj_io_analog_en),
		.analog_sel(mprj_io_analog_sel),
		.analog_pol(mprj_io_analog_pol),
		.dm(mprj_io_dm),
		.io_in(mprj_io_in),
		.analog_io(mprj_analog_io)
	);

endmodule
// `default_nettype wire
