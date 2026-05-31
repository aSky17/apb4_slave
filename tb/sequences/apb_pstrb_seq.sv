class apb_pstrb_seq extends apb_base_seq;

    `uvm_object_utils(apb_pstrb_seq)

    apb_seq_item tr;

    bit [3:0] strb_patterns[$];

    function new(string name = "apb_pstrb_seq");
        super.new(name);

        strb_patterns.push_back(4'b0001);
        strb_patterns.push_back(4'b0010);
        strb_patterns.push_back(4'b0100);
        strb_patterns.push_back(4'b1000);
        
        strb_patterns.push_back(4'b0011);
        strb_patterns.push_back(4'b0110);
        strb_patterns.push_back(4'b1100);
        strb_patterns.push_back(4'b1001);
        
        strb_patterns.push_back(4'b0000);
        strb_patterns.push_back(4'b1111);
        
        strb_patterns.push_back(4'b0101);
        strb_patterns.push_back(4'b1010);
        
    endfunction

    task body();

        foreach (strb_patterns[i]) begin
            tr = apb_seq_item::type_id::create($sformatf("tr_%0d", i));

            start_item(tr);

            tr.addr   = CTRL_ADDR;
            tr.write  = 1'b1;
            tr.wdata  = $random;
            tr.strb   = strb_patterns[i];
            tr.prot   = 3'b000;

            finish_item(tr);

            `uvm_info("PSTRB_SEQ",
                      $sformatf(
                        "WRITE strb=%b data=%h",
                        tr.strb,
                        tr.wdata
                      ),
                      UVM_LOW)
        end
    endtask
endclass