# GPIO Test Failure - Systematic Debugging Action Plan

## Overview
This document provides a step-by-step action plan to identify exactly where the VexRiscv version fails. We'll verify the complete signal path from processor execution through to GPIO pad control.

---

## Action 1: Check if Firmware Even Runs in VexRiscv Version

### **Why This Matters:**
If the processor isn't executing firmware, nothing will happen - no wishbone transactions, no GPIO updates, test stays at `0x00`. This is the **first critical checkpoint**.

### **What We're Testing:**
- Is the VexRiscv processor actually fetching and executing instructions?
- Is the processor stuck in reset or hung state?
- Is the instruction memory properly initialized?

### **Signals to Monitor:**

#### **Sub-Check 1A: Program Counter (PC) Activity**
```verilog
Signal: uut.chip_core.soc.VexRiscv.iBusWishbone_ADR[31:0]
Why: This is the instruction address - PC increments here
Expected: Should change every 1-4 clock cycles (instruction fetches)
What to Look For:
  ✅ PASS: PC = 0x00000000 initially, then increments (0x00000004, 0x00000008, etc.)
  ✅ PASS: PC wraps around memory boundaries (e.g., 0x00000FFC → 0x00000000)
  ❌ FAIL: PC stays at 0x00000000 forever
  ❌ FAIL: PC shows random/garbage values
  ❌ FAIL: PC increments but then stops
```

#### **Sub-Check 1B: Instruction Fetch Handshake**
```verilog
Signals to trace together:
  - uut.chip_core.soc.VexRiscv.iBusWishbone_CYC     (Instruction cycle)
  - uut.chip_core.soc.VexRiscv.iBusWishbone_STB     (Instruction strobe)
  - uut.chip_core.soc.VexRiscv.iBusWishbone_ACK     (Instruction acknowledge)

Why: Wishbone handshake shows processor-to-memory communication
Expected: CYC and STB pulse together, then ACK comes back

Wishbone Handshake Sequence:
  Cycle N:   CYC=1, STB=1, ADR=0x00000000  (Processor requests)
  Cycle N+1: CYC=1, STB=1, ACK=1          (Memory responds)
  Cycle N+2: CYC=1, STB=1, ADR=0x00000004  (Next instruction)

What to Look For:
  ✅ PASS: Regular CYC/STB pulses (every 2-4 cycles)
  ✅ PASS: ACK comes back quickly (1-2 cycles after STB)
  ✅ PASS: ADR increments by 4 (standard 32-bit instruction size)
  ❌ FAIL: CYC=0, STB=0 always (no instruction fetches)
  ❌ FAIL: CYC=1, STB=1, but ACK never comes (memory dead)
  ❌ FAIL: CYC/STB but ADR never changes
```

#### **Sub-Check 1C: Instruction Data Return**
```verilog
Signal: uut.chip_core.soc.VexRiscv.iBusWishbone_DAT_MISO[31:0]
Why: Instruction data - should contain actual firmware instructions

Expected Pattern:
  - First instruction boot address (typically 0x00000000)
  - Binary instruction opcodes (not zeros, not all ones)
  - Different values as program progresses

What to Look For:
  ✅ PASS: DAT_MISO shows valid instruction opcodes
  ✅ PASS: Values change as different instructions are fetched
  ❌ FAIL: DAT_MISO = 0x00000000 always (memory not initialized)
  ❌ FAIL: DAT_MISO = 0xFFFFFFFF always (uninitialized memory)
  ❌ FAIL: DAT_MISO = 0xDEADBEEF (debug value - firmware not loaded)
```

### **How to Implement Check 1:**

**Add to testbench (`gpio_tb.v`):**

```verilog
// Add these monitoring statements after reset release
initial begin
    @(negedge RSTB);
    #100ns;
    
    // Monitor for 1000 clock cycles
    repeat(1000) begin
        if (uut.chip_core.soc.VexRiscv.iBusWishbone_CYC === 1'b1 &&
            uut.chip_core.soc.VexRiscv.iBusWishbone_STB === 1'b1) begin
            
            $display("INSTRUCTION FETCH: ADR=%h, DATA=%h, ACK=%b",
                uut.chip_core.soc.VexRiscv.iBusWishbone_ADR,
                uut.chip_core.soc.VexRiscv.iBusWishbone_DAT_MISO,
                uut.chip_core.soc.VexRiscv.iBusWishbone_ACK);
        end
        @(posedge clock);
    end
end

// Dump key signals for waveform
initial begin
    $dumpfile("gpio_debug.vcd");
    $dumpvars(0, 
        uut.chip_core.soc.VexRiscv.iBusWishbone_ADR,
        uut.chip_core.soc.VexRiscv.iBusWishbone_CYC,
        uut.chip_core.soc.VexRiscv.iBusWishbone_STB,
        uut.chip_core.soc.VexRiscv.iBusWishbone_ACK,
        uut.chip_core.soc.VexRiscv.iBusWishbone_DAT_MISO
    );
end
```

**Or add to GTKWave:**
```
Add these signals to waveform:
- uut.chip_core.soc.VexRiscv.iBusWishbone_ADR
- uut.chip_core.soc.VexRiscv.iBusWishbone_CYC
- uut.chip_core.soc.VexRiscv.iBusWishbone_STB
- uut.chip_core.soc.VexRiscv.iBusWishbone_ACK
- uut.chip_core.soc.VexRiscv.iBusWishbone_DAT_MISO

Zoom in to first 100 cycles and look for:
  CYC/STB pulses every few cycles
  ADR incrementing by 4
  ACK following CYC+STB
```

### **Decision Point:**
- **If CYC/STB present and incrementing:** ✅ Firmware is running → Go to Action 2
- **If NO CYC/STB ever:** ❌ Processor not executing → Check reset, clock, memory init
- **If CYC/STB but ACK never comes:** ❌ Instruction memory dead → Check RAM initialization

---

## Action 2: Verify if Wishbone Data Transactions Are Generated

### **Why This Matters:**
Even if firmware executes, it needs to perform memory-mapped I/O writes to GPIO registers. The data bus carries these critical writes.

### **What We're Testing:**
- Is the processor attempting to write to GPIO registers (address 0x2600000C)?
- Is the data value correct (0xA0000000, 0x0B000000, etc.)?
- Are write signals being asserted?

### **Signals to Monitor:**

#### **Sub-Check 2A: Data Bus Write Requests**
```verilog
Signals to trace together:
  - uut.chip_core.soc.VexRiscv.dBusWishbone_ADR[31:0]      (Data address)
  - uut.chip_core.soc.VexRiscv.dBusWishbone_DAT_MOSI[31:0] (Data to write)
  - uut.chip_core.soc.VexRiscv.dBusWishbone_WE[3:0]        (Write enable)
  - uut.chip_core.soc.VexRiscv.dBusWishbone_CYC            (Data cycle)
  - uut.chip_core.soc.VexRiscv.dBusWishbone_STB            (Data strobe)

Why: Shows what data the processor is trying to write where

Expected Sequence for GPIO test:
  Time T1: ADR=0x2600000C, DAT=0xA0000000, WE=0xF, CYC=1, STB=1
  Time T2: Same with ACK=1 (write completes)
  Time T3: ADR=0x2600000C, DAT=0x0B000000, WE=0xF, CYC=1, STB=1
  ...and so on

What to Look For:
  ✅ PASS: ADR = 0x2600000C (GPIO register address)
  ✅ PASS: DAT shows progression: 0xA0000000, 0x0B000000, 0xAB000000, etc.
  ✅ PASS: WE = 0xF (all 4 bytes enabled - 32-bit write)
  ✅ PASS: CYC and STB assert together
  ❌ FAIL: No data transactions at all (WE always 0)
  ❌ FAIL: ADR = 0x00000000 or other addresses (wrong memory access)
  ❌ FAIL: DAT = 0x00000000 (not writing actual values)
  ❌ FAIL: WE = 0x0 (write disabled)
```

#### **Sub-Check 2B: Data Bus Handshake**
```verilog
Signals:
  - uut.chip_core.soc.VexRiscv.dBusWishbone_CYC
  - uut.chip_core.soc.VexRiscv.dBusWishbone_STB
  - uut.chip_core.soc.VexRiscv.dBusWishbone_ACK

Why: Confirms housekeeping is acknowledging the write

Expected: ACK comes back after CYC+STB, indicating write accepted

What to Look For:
  ✅ PASS: ACK=1 appears 1-2 cycles after STB=1
  ✅ PASS: CYC/STB/ACK handshake completes, then next write starts
  ❌ FAIL: CYC=1, STB=1, but ACK never comes (housekeeping not responding)
  ❌ FAIL: ACK stays 0 forever (write never completes)
```

### **How to Implement Check 2:**

**Add to testbench:**

```verilog
initial begin
    @(negedge RSTB);
    #100ns;
    
    // Monitor for data bus writes
    repeat(10000) begin
        if (uut.chip_core.soc.VexRiscv.dBusWishbone_WE !== 4'h0) begin
            $display("DATA WRITE: ADR=%h, DATA=%h, WE=%h, ACK=%b",
                uut.chip_core.soc.VexRiscv.dBusWishbone_ADR,
                uut.chip_core.soc.VexRiscv.dBusWishbone_DAT_MOSI,
                uut.chip_core.soc.VexRiscv.dBusWishbone_WE,
                uut.chip_core.soc.VexRiscv.dBusWishbone_ACK);
        end
        @(posedge clock);
    end
end
```

### **Decision Point:**
- **If writes to 0x2600000C with correct data:** ✅ Data bus works → Go to Action 3
- **If writes but wrong address (not 0x2600000C):** ⚠️ Address mapping issue → Check firmware
- **If NO writes at all:** ❌ Data bus dead → Check interrupt/exception handling
- **If writes but ACK never comes:** ❌ Housekeeping not responding → Check Action 3

---

## Action 3: Check if Housekeeping Receives the Transactions

### **Why This Matters:**
Even if the processor sends transactions, housekeeping must receive and process them. If housekeeping is broken, GPIO will never update.

### **What We're Testing:**
- Does housekeeping see the incoming Wishbone transaction?
- Does housekeeping update the GPIO register (`mgmt_gpio_data`)?
- Does housekeeping send acknowledgment back?

### **Signals to Monitor:**

#### **Sub-Check 3A: Housekeeping Wishbone Input**
```verilog
Signals:
  - uut.chip_core.housekeeping.wb_adr_i[31:0]     (Address input)
  - uut.chip_core.housekeeping.wb_dat_i[31:0]     (Data input)
  - uut.chip_core.housekeeping.wb_we_i            (Write enable input)
  - uut.chip_core.housekeeping.wb_cyc_i           (Cycle input)
  - uut.chip_core.housekeeping.wb_stb_i           (Strobe input)

Why: Verify housekeeping is receiving data from processor

Expected: Should match what processor sends
  - wb_adr_i = 0x2600000C
  - wb_dat_i = 0xA0000000, then 0x0B000000, etc.
  - wb_we_i = 1
  - wb_cyc_i = 1, wb_stb_i = 1

What to Look For:
  ✅ PASS: wb_adr_i shows 0x2600000C
  ✅ PASS: wb_dat_i shows correct GPIO values
  ✅ PASS: wb_we_i = 1, wb_cyc_i = 1, wb_stb_i = 1
  ❌ FAIL: All inputs stuck at 0 (no connection)
  ❌ FAIL: wb_adr_i ≠ 0x2600000C (address not reaching)
  ❌ FAIL: wb_dat_i = 0 (data not reaching)
```

#### **Sub-Check 3B: GPIO Register Update**
```verilog
Signal: uut.chip_core.housekeeping.mgmt_gpio_data[31:0]

Why: This is THE critical register - if it updates, housekeeping is working

Expected Progression:
  Cycle 1: mgmt_gpio_data = 0x00000000 (initial)
  Cycle 2: mgmt_gpio_data = 0xA0000000 (first write)
  Cycle 3: mgmt_gpio_data = 0x0B000000 (second write)
  Cycle 4: mgmt_gpio_data = 0xAB000000 (third write)
  ...
  Final: mgmt_gpio_data = 0x04000000 (last increment result)

What to Look For:
  ✅ PASS: Register changes from 0x00 to 0xA0 in upper byte
  ✅ PASS: Values progress: A0 → 0B → AB → 02 → 04
  ✅ PASS: Updates happen soon after wishbone write (within a few cycles)
  ❌ FAIL: mgmt_gpio_data stays 0x00000000 forever
  ❌ FAIL: Only some bits update (e.g., 0x000000A0 instead of 0xA0000000)
  ❌ FAIL: Random values appear
```

#### **Sub-Check 3C: Housekeeping Acknowledge Output**
```verilog
Signal: uut.chip_core.housekeeping.wb_ack_o

Why: Housekeeping must send ACK back to processor to complete transaction

Expected: ACK pulses after each write, matching wb_cyc_i + wb_stb_i

What to Look For:
  ✅ PASS: wb_ack_o = 1 appears 1-2 cycles after wb_cyc_i = 1
  ✅ PASS: ACK pulses are clean and regular
  ❌ FAIL: wb_ack_o always 0 (housekeeping not responding)
  ❌ FAIL: ACK appears without CYC/STB (spurious ACK)
```

### **How to Implement Check 3:**

**Add to testbench:**

```verilog
// Most important check - the "golden signal"
initial begin
    @(negedge RSTB);
    #100ns;
    
    // Wait for first GPIO write
    wait(uut.chip_core.housekeeping.mgmt_gpio_data !== 32'h00000000);
    $display("SUCCESS: GPIO register updated to %h", 
        uut.chip_core.housekeeping.mgmt_gpio_data);
    
    // Monitor updates
    repeat(100) begin
        @(posedge clock);
        $display("mgmt_gpio_data = %h", 
            uut.chip_core.housekeeping.mgmt_gpio_data);
    end
end

// Check housekeeping responses
initial begin
    repeat(10000) begin
        if (uut.chip_core.housekeeping.wb_cyc_i === 1'b1 &&
            uut.chip_core.housekeeping.wb_stb_i === 1'b1) begin
            $display("HK WRITE: ADR=%h, DATA=%h, ACK=%b",
                uut.chip_core.housekeeping.wb_adr_i,
                uut.chip_core.housekeeping.wb_dat_i,
                uut.chip_core.housekeeping.wb_ack_o);
        end
        @(posedge clock);
    end
end
```

### **Decision Point:**
- **If mgmt_gpio_data changes:** ✅ Housekeeping working → Go to Action 4
- **If mgmt_gpio_data stays 0:** ❌ Housekeeping not responding → Check address decoding
- **If ACK never comes:** ❌ Housekeeping hung → Check internal logic

---

## Action 4: Verify Register Addresses Match

### **Why This Matters:**
The firmware writes to address `0x2600000C`, which must map correctly to the housekeeping GPIO register handler. If the address mapping is wrong, writes go to the wrong register or nowhere.

### **What We're Testing:**
- Is address `0x2600000C` correctly decoded by housekeeping?
- Does it map to the right internal handler (should be `8'h6a` for 32-bit update)?
- Are writes reaching `mgmt_gpio_data` register?

### **Signals to Monitor:**

#### **Sub-Check 4A: Address Mapping in Housekeeping**
```verilog
Signal: uut.chip_core.housekeeping.caddr (internal address after mapping)

Why: Shows what address has been decoded

Expected: For firmware write to 0x2600000C:
  - gpio_adr = 0x2600000C
  - spiaddr() function should output 0x6A
  - caddr should become 0x6A

Location to check: housekeeping.v, function spiaddr()
  Line 616: gpio_adr | 12'h00c : spiaddr = 8'h6d;  // CURRENT
  Should be: gpio_adr | 12'h00c : spiaddr = 8'h6a;  // FOR 32-bit

What to Look For:
  ✅ PASS: caddr = 0x6A when writing to 0x2600000C
  ✅ PASS: This triggers the 32-bit update handler
  ❌ FAIL: caddr = 0x6D (only updates 8 bits, not full 32)
  ❌ FAIL: caddr = 0x00 (address not recognized)
```

#### **Sub-Check 4B: Handler Execution**
```verilog
For address 0x6A, check which register gets updated:

In housekeeping.v, line 1397-1407:
  8'h6a: begin
      if (spi_is_active) begin
          mgmt_gpio_data[31:24] <= cdata;
      end else begin
          mgmt_gpio_data[31:0] <= {cdata, mgmt_gpio_data_buf};  // ← THIS LINE
      end
  end

Why: This handler does the full 32-bit update

Expected: When address = 0x6A and spi_is_active = 0:
  - mgmt_gpio_data[31:0] updates with new value
  - This is what triggers GPIO output changes

What to Look For:
  ✅ PASS: mgmt_gpio_data[31:0] updates completely
  ✅ PASS: Upper byte (31:24) shows 0xA0, 0x0B, 0xAB, etc.
  ❌ FAIL: Only mgmt_gpio_data[7:0] updates (8'h6D handler, not 0x6A)
  ❌ FAIL: mgmt_gpio_data[31:16] never changes
```

#### **Sub-Check 4C: Buffer Staging Register**
```verilog
Signal: uut.chip_core.housekeeping.mgmt_gpio_data_buf[23:0]

Why: For 32-bit writes, lower 24 bits go here first, then all 32 bits at once

Expected for firmware address 0x2600000C:
  - First write 0xA0000000: Sets data_buf = 0x000000, then mgmt_gpio_data = 0xA0000000
  - Works correctly for single 32-bit write

What to Look For:
  ✅ PASS: Registers update cleanly with single write
  ❌ FAIL: Split updates (some bits now, some later)
  ❌ FAIL: Staging register not clearing
```

### **How to Implement Check 4:**

**Compare actual behavior vs expected:**

```verilog
initial begin
    @(negedge RSTB);
    #1000ns;
    
    // Verify address mapping
    $display("=== ADDRESS MAPPING TEST ===");
    $display("Firmware writes to: 0x2600000C");
    $display("Expected internal address: 0x6A (for 32-bit update)");
    $display("Expected handler: mgmt_gpio_data[31:0] <= {cdata, buf}");
    
    // Check register progression
    $display("\n=== EXPECTED REGISTER PROGRESSION ===");
    repeat(100) begin
        $display("Time=%0d, mgmt_gpio_data=%h, checkbits_hi=%h",
            $time,
            uut.chip_core.housekeeping.mgmt_gpio_data,
            checkbits_hi);
        @(posedge clock);
    end
end
```

**Manual verification in housekeeping.v:**

```
Check Line 616:
  Current: gpio_adr | 12'h00c : spiaddr = 8'h6d;  ← WRONG (8-bit handler)
  Correct: gpio_adr | 12'h00c : spiaddr = 8'h6a;  ← RIGHT (32-bit handler)

If this is wrong, firmware writes go to wrong handler!
```

### **Decision Point:**
- **If address maps to 0x6A:** ✅ Mapping correct → Problem elsewhere
- **If address maps to 0x6D:** ❌ CRITICAL BUG → Change line 616 in housekeeping.v
- **If address maps to 0x00:** ❌ No address recognition → Check spiaddr function

---

## Summary Decision Tree

```
START: GPIO test returns 0x00, should return 0xA0

├─ ACTION 1: Check if firmware executes
│  ├─ ✅ CYC/STB/ACK present on instruction bus → Go to ACTION 2
│  └─ ❌ No instruction fetches → STOP: Reset/clock/memory init broken
│
├─ ACTION 2: Check data bus writes
│  ├─ ✅ Writes to 0x2600000C with 0xA0000000 → Go to ACTION 3
│  └─ ❌ No data writes → STOP: Firmware not executing GPIO code
│
├─ ACTION 3: Check housekeeping response
│  ├─ ✅ mgmt_gpio_data changes to 0xA0000000 → Go to ACTION 4
│  ├─ ⚠️ mgmt_gpio_data changes but wrong value → Check data bus
│  └─ ❌ mgmt_gpio_data stays 0x00 → STOP: Housekeeping not processing
│
└─ ACTION 4: Check address mapping
   ├─ ✅ Address 0x2600000C → 0x6A (correct) → Problem is GPIO control blocks
   ├─ ❌ Address 0x2600000C → 0x6D (wrong) → FIX: Change housekeeping.v line 616
   └─ ❌ No address recognition → Check spiaddr() function
```

---

## Quick Start Checklist

```
□ Step 1: Run simulation, generate VCD
□ Step 2: Monitor mgmt_gpio_data[31:0] for changes
  - If changes: Housekeeping works, check GPIO control blocks
  - If no change: Continue to steps 3-4
□ Step 3: Check iBusWishbone signals for instruction fetches
  - If present: Firmware executing, check data bus
  - If absent: Processor not running
□ Step 4: Check dBusWishbone signals for data writes
  - If address 0x2600000C present: Correct address
  - If not: Firmware not writing to GPIO
□ Step 5: Check housekeeping inputs match processor outputs
□ Step 6: Verify address mapping in housekeeping.v line 616
  - Should be: 8'h6a (not 8'h6d)
```

