// SPDX-FileCopyrightText: 2025 VSD
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

/*---------------------------------------------------------------------*/
/* Vsdcaravel, RISC-V SoC Implementation using Synopsys and SCL180 PDK,*/
/* a project for the VSD/Semiconductor Laboratory SCL180	           */
/* fabrication process 			                                       */
/*                                                          	       */
/* Copyright 2025 VSD                           	                   */
/* Originally written by Bharat                                        */
/* 			    	                                                   */
/* Edited by Dhanvanti Bhavsar and Kunal Ghosh on (11/02/2025)		   */
/* Updated on 11/02/2025:  Revised using SCL180 PDK	                   */
/* This file is open source hardware released under the     	       */
/* Apache 2.0 license.  See file LICENSE.                   	       */
/* from housekeeping.v (refactoring a number of functions from	       */
/* the management SoC).						                           */
/*                                                          	       */
/*---------------------------------------------------------------------*/


/*
`include "pc3b03ed.v"
module pc3b03ed_wrapper(OUT, PAD, IN, INPUT_DIS, OUT_EN_N, dm);
output  IN;
input   OUT, INPUT_DIS, OUT_EN_N;
inout   PAD;
input [2:0]dm;


wire output_EN_N;
wire pull_down_enb;

//assign output_EN_N = (dm[2:0] != 3'b110 && ~OUT_EN_N) && ((~INPUT_DIS && (dm[2:0] == 3'b001)) || (~INPUT_DIS && (dm[2:0] == 3'b010))|| OUT_EN_N || (dm[2:0] == 3'b000)) ;

assign output_EN_N = (~INPUT_DIS && (dm[2:0] == 3'b001)) || OUT_EN_N || (dm[2:0] == 3'b000)|| (~INPUT_DIS && (dm[2:0] == 3'b010));
//assign output_EN_N = (OUT_EN_N == 1'b0) ? 1'b0 : 1'b1;
assign pull_down_enb = (dm[2:0] == 3'b000);


pc3b03ed pad(.CIN( IN ),
		.OEN(output_EN_N),
		.RENB(pull_down_enb),
		.I(OUT),
		.PAD(PAD));
endmodule 
*/

///////////////////////////////////////////////////////////////////////////////
// SCL180 I/O Pad Wrapper - Sky130 GPIO Compatible Interface
// Maps pc3b03ed (SCL180) to sky130_ef_io__gpiov2_pad_wrapped interface
///////////////////////////////////////////////////////////////////////////////
//  pc3b03ed_wrapper  fixed by Ravi Patel
module pc3b03ed_wrapper (
    // -------- Sky130 Compatible Port Names --------
    input        OUT,
    input        OE_N,
    input        HLD_H_N,
    input        ENABLE_H,
    input        ENABLE_INP_H,
    input        ENABLE_VDDA_H,
    input        ENABLE_VSWITCH_H,
    input        ENABLE_VDDIO,
    input        INP_DIS,
    input        IB_MODE_SEL,
    input        VTRIP_SEL,
    input        SLOW,
    input        HLD_OVR,
    input        ANALOG_EN,
    input        ANALOG_SEL,
    input        ANALOG_POL,
    input  [2:0] DM,
    
    // -------- Power/Ground (tie-offs for SCL180) --------
    inout        VDDIO,
    inout        VDDIO_Q,
    inout        VDDA,
    inout        VCCD,
    inout        VSWITCH,
    inout        VCCHIB,
    inout        VSSA,
    inout        VSSD,
    inout        VSSIO_Q,
    inout        VSSIO,
    
    // -------- Physical PAD --------
    inout        PAD,
    inout        PAD_A_NOESD_H,
    inout        PAD_A_ESD_0_H,
    inout        PAD_A_ESD_1_H,
    
    // -------- Analog mux (not implemented) --------
    inout        AMUXBUS_A,
    inout        AMUXBUS_B,
    
    // -------- Outputs to Core --------
    output       IN,
    output       IN_H,
    output       TIE_HI_ESD,
    output       TIE_LO_ESD
);

    // ========================================================================
    // Control Signal Processing - SYNTHESIS OPTIMIZED
    // ========================================================================
    // Note: True hold mode requires latches which are not recommended for
    // modern synthesis. For SCL180, we use direct pass-through with enable gating.
    // If true hold mode is needed, add clock and use flip-flops.
    
    wire [2:0] dm_final;
    wire       oe_n_final;
    wire       out_final;
    wire       inp_dis_final;
    
    // Simple enable gating - synthesis friendly
    // When ENABLE_H is low, force safe defaults
    assign dm_final = ENABLE_H ? DM : 3'b000;
    assign oe_n_final = ENABLE_H ? OE_N : 1'b1;
    assign out_final = ENABLE_H ? OUT : 1'b0;
    assign inp_dis_final = ENABLE_H ? INP_DIS : 1'b1;
    
    // ========================================================================
    // Drive Mode Decoder - Sky130 DM[2:0] to SCL180 Controls
    // ========================================================================
    // DM[2:0] modes (synthesis-optimized):
    // 000 - High-Z (analog)
    // 001 - Input only
    // 010 - Output with pull-down (weak 0, strong 1)
    // 011 - Output with pull-up (weak 1, strong 0) - NOT SUPPORTED in SCL180
    // 100 - Strong output pull-down
    // 101 - Strong output pull-up
    // 110 - Strong push-pull
    // 111 - Open-drain pull-up+down - NOT FULLY SUPPORTED
    
    wire is_output_mode = (dm_final[2] == 1'b1) || 
                          (dm_final == 3'b010) || 
                          (dm_final == 3'b011);
    
    wire is_input_only = (dm_final == 3'b000) || (dm_final == 3'b001);
    
    wire output_enabled = ENABLE_H && ENABLE_VDDIO && !oe_n_final && is_output_mode;
    
    // Pull-down enable: only for DM=010 (output with pull-down)
    wire enable_pulldown = (dm_final == 3'b010) && output_enabled;
    
    // ========================================================================
    // Output Driver Control
    // ========================================================================
    wire pad_oen;      // Active-low output enable for pc3b03ed
    wire pad_i;        // Data to drive
    wire pad_renb;     // Active-low pull-down enable
    
    // Tristate pad when:
    // - Not in output mode
    // - Output disabled (OE_N=1)
    // - Power not enabled
    assign pad_oen = output_enabled ? 1'b0 : 1'b1;
    
    // Drive the output value
    assign pad_i = out_final;
    
    // Enable pull-down only for DM=010
    assign pad_renb = enable_pulldown ? 1'b0 : 1'b1;
    
    // ========================================================================
    // Input Buffer Control - Match Sky130 Behavior
    // ========================================================================
    wire pad_cin;  // Raw pad input from pc3b03ed
    
    // Input buffer disabled when:
    // - INP_DIS = 1
    // - DM = 000 (analog mode)
    // - ENABLE_H = 0
    // - ENABLE_INP_H = 0 (when ENABLE_H = 0)
    wire inp_buff_disabled = inp_dis_final || 
                             (dm_final == 3'b000) || 
                             !ENABLE_H ||
                             (ENABLE_H == 1'b0 && ENABLE_INP_H == 1'b0);
    
    // ========================================================================
    // Instantiate SCL180 I/O Pad
    // ========================================================================
    pc3b03ed u_io_pad (
        .PAD(PAD),
        .OEN(pad_oen),
        .RENB(pad_renb),
        .I(pad_i),
        .CIN(pad_cin)
    );
    
    // ========================================================================
    // Input Path - Match Sky130 Behavior
    // ========================================================================
    // When input buffer disabled, force to 0 (like Sky130)
    // When enabled, pass through PAD value
    assign IN   = inp_buff_disabled ? 1'b0 : pad_cin;
    assign IN_H = inp_buff_disabled ? 1'b0 : pad_cin;
    
    // ========================================================================
    // ESD Tie Signals - Static in SCL180
    // ========================================================================
    assign TIE_HI_ESD = 1'b1;  // Tie to VDD
    assign TIE_LO_ESD = 1'b0;  // Tie to VSS
    
    // ========================================================================
    // Analog Connections - Not Implemented (Leave floating/unconnected)
    // ========================================================================
    // AMUXBUS_A, AMUXBUS_B - no connection in SCL180
    // PAD_A_NOESD_H, PAD_A_ESD_0_H, PAD_A_ESD_1_H - no equivalent
    
    // ========================================================================
    // Warning Messages for Unsupported Features
    // NOTE: These are for simulation only and will be removed during synthesis
    // ========================================================================
    `ifdef SIMULATION
    initial begin
        $display("INFO: pc3b03ed_wrapper instantiated - SCL180 I/O pad with Sky130 interface");
        $display("INFO: Unsupported features: ANALOG_EN, full DM modes, SLOW, IB_MODE_SEL, VTRIP_SEL");
        $display("INFO: HLD_H_N and HLD_OVR are simplified - no true hold/latch functionality");
    end
    
    // Monitor for unsupported feature usage
    always @(ANALOG_EN) begin
        if (ANALOG_EN === 1'b1) begin
            $display("WARNING @ %t: ANALOG_EN=1 not supported in pc3b03ed_wrapper", $time);
        end
    end
    
    always @(DM) begin
        if (DM == 3'b011 && ENABLE_H) begin
            $display("WARNING @ %t: DM=011 (pull-up) not fully supported, using strong output", $time);
        end
        if (DM == 3'b111 && ENABLE_H) begin
            $display("WARNING @ %t: DM=111 (open-drain) not fully supported, using push-pull", $time);
        end
    end
    `endif

endmodule
