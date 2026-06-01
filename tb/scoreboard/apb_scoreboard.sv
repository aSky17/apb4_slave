class apb_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(apb_scoreboard)

    uvm_analysis_imp #(apb_seq_item, apb_scoreboard) sb_port;

    logic [31:0] mirror_mem [logic [31:0]];

    function new(string name, uvm_component parent);
        super.new(name, parent);

        sb_port = new("sb_port", this);
    endfunction

    //byte preservation 
    function automatic [31:0] apply_strobe(
        input [31:0] old_data,
        input [31:0] new_data,
        input [3:0] strb
    );

        logic [31:0] temp;

        temp = old_data;

        for (int i = 0; i < 4; i++) begin
            if (strb[i]) begin
                 temp[i*8 +: 8] = new_data[i*8 +: 8];
            end
        end

        return temp;

    endfunction

    function void write(apb_seq_item tr);
        logic [31:0] expected;

        //write ops
        if (tr.write && !tr.slverr) begin //valid write
            if (mirror_mem.exists(tr.addr)) begin
                expected = mirror_mem[tr.addr];
            end else begin
                expected = 32'h0;
            end

            expected = apply_strobe(
                expected,
                tr.wdata,
                tr.strb
            );

            mirror_mem[tr.addr] = expected;

            `uvm_info("SCOREBOARD",
                      $sformatf(
                        "WRITE MIRROR addr=%h expected=%h",
                        tr.addr,
                        expected
                      ),
                      UVM_LOW)
        end

        //read ops
        if (!tr.write && !tr.slverr) begin
            if (mirror_mem.exists(tr.addr)) begin
                expected = mirror_mem[tr.addr];
            end else begin
                expected = 32'h0;
            end

            if (expected != tr.rdata) begin
                `uvm_error("SCOREBOARD",
                           $sformatf(
                             "READ MISMATCH addr=%h expected=%h actual=%h",
                             tr.addr,
                             expected,
                             tr.rdata
                           ))
            end else begin
                `uvm_info("SCOREBOARD",
                          $sformatf(
                            "READ MATCH addr=%h data=%h",
                            tr.addr,
                            tr.rdata
                          ),
                          UVM_LOW)
            end
        end

        if(tr.exp_slverr != tr.slverr) begin

            `uvm_error(
                "SCOREBOARD",
                $sformatf(
                    "PSLVERR mismatch expected=%0d actual=%0d",
                    tr.exp_slverr,
                    tr.slverr
                )
            );

        end

        if(tr.reset_seen) begin
            reset_model();
            `uvm_info("SB",
                    "Mirror model reset",
                    UVM_LOW)

            return;
        end

    endfunction

    virtual function reset_model();
        mirror_mem.delete();
    endfunction
endclass
