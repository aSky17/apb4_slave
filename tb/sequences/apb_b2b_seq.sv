class apb_b2b_seq extends apb_base_seq;

    `uvm_object_utils(apb_b2b_seq)

    apb_seq_item tr;

    logic [31:0] addr_q[$];

    function new(string name = "apb_b2b_seq");
        super.new(name);

        addr_q.push_back(CTRL_ADDR);
        addr_q.push_back(TXDATA_ADDR);
        addr_q.push_back(CONFIG_ADDR);
        addr_q.push_back(STATUS_ADDR);

    endfunction

    task body();
        
        for(int i = 0; i < addr_q.size(); i++) begin
            tr = apb_seq_item::type_id::create($sformatf("tr_%0d", i));

            start_item(tr);
            tr.addr   = addr_q[i];
            tr.write  = $urandom_range(0,1);
            tr.wdata  = $random;
            tr.strb   = 4'b1111;
            tr.prot   = 3'b000;
            finish_item(tr);

            `uvm_info("B2B_SEQ",
                      $sformatf(
                        "B2B transfer addr=%h write=%0d",
                        tr.addr,
                        tr.write
                      ),
                      UVM_LOW)
        end
    endtask
endclass