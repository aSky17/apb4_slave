//apb4 assertions

//assertion 1: PENABLE requires PSEL
property p_penable_requires_psel;

    //if PENABLE is 1, then PSEL should also be 1
    @(posedge PCLK)
    PENABLE |-> PSEL; // |-> same cycle implication

endproperty
assert property (p_penable_requires_psel)
    else $error("APB ERROR: PENABLE asserted without PSEL");

//assertion 2: SETUP must transition to ACCESS
property p_setup_to_access;

    @(posedge PCLK)

    (PSEL && !PENABLE)
    |=> PENABLE; // |=> next cycle implication

endproperty
assert property (p_setup_to_access)
    else $error("APB ERROR: SETUP did not transition to ACCESS");

//assertion 3: Stable signals during wait states
property p_stable_wait;

    @(posedge PCLK)
    (PSEL && PENABLE && !PREADY)
    |->
    (
        $stable(PADDR) &&
        $stable(PWRITE) &&
        $stable(PWDATA) &&
        $stable(PSTRB) &&
        $stable(PPROT)
    );
endproperty
assert property (p_stable_wait)
    else $error("APB ERROR: Signals changed during wait state");

//assertion 4: PSLVERR valid onlu during completion
property p_pslverr_valid;

    @(posedge PCLK)
    PSLVERR |-> (PSEL && PENABLE && PREADY);

endproperty
assert property (p_pslverr_valid)
    else $error("APB ERROR: PSLVERR asserted illegally");

//assertion 5: ACCESS state requires PENABLE
property p_access_requires_penable;

    @(posedge PCLK)
    (state == ACCESS|)
    |-> PENABLE;

endproperty
assert property (p_access_requires_penable)
    else $error("APB ERROR: ACCESS state without PENABLE");

//assertion 6: SETUP state rewuires PENABLE low
property p_setup_penable_low;

    @(posedge PCLK)
    (state == SETUP)
    |-> !PENABLE;
    
endproperty
assert property (p_setup_penable_low)
    else $error("APB ERROR: PENABLE high during SETUP");

//assertion 7: PSTRB should be 0 during reads
property p_pstrb_read_zero;

    @(posedge PCLK)
    (!PWRITE && PSEL)
    |-> (PSTRB == 4'b0000);
    
endproperty
assert property (p_pstrb_read_zero)
    else $error("APB ERROR: PSTRB non-zero during read");

//assertion 8: Transfer completion definition
property p_transfer_complete;

    @(posedge PCLK)
    (PSEL && PENABLE && PREADY)
    |-> ##1 (state == IDLE || state == SETUP);

endproperty

assert property (p_transfer_complete)
    else $error("APB ERROR: Transfer did not exit ACCESS");

//assertion 9: PREADY only during ACCESS
property p_pready_access_only;

    @(posedge PCLK)

    PREADY |-> (state == ACCESS);

endproperty

assert property (p_pready_access_only)
    else $error("APB ERROR: PREADY asserted outside ACCESS");

//assertion 10: Illegal write to RO register
property p_ro_write_error;

    @(posedge PCLK)
    (
        PSEL &&
        PENABLE &&
        PWRITE &&
        (PADDR == STATUS_ADDR || PADDR == RXDATA_ADDR)
    )

    |-> PSLVERR;

endproperty

assert property (p_ro_write_error)
    else $error("APB ERROR: RO write did not generate PSLVERR");