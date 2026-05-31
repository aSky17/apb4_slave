class apb_coverage extends uvm_subscriber #(apb_seq_item);

    `uvm_component_utils(apb_coverage)

    apb_seq_item tr;

    covergroup apb_cov;

        option.per_instance = 1;

        //address coverage
        ADDR_CP: coverpoint tr.addr {
            bins ctrl = {CTRL_ADDR};
            bins status = {STATUS_ADDR};
            bins txdata = {TXDATA_ADDR};
            bins rxdata = {RXDATA_ADDR};
            bins configg = {CONFIG_ADDR};

            bins invalid = default;
        }

        //READ/WRITE coverage
        WRITE_CP: coverpoint tr.write {
            bins read = {0};
            bins write = {1};
        }

        //PSTRB coverage
        PSTRB_CP: coverpoint tr.strb {
            bins zero = {4'b0000};

            bins single[] = {
                4'b0001,
                4'b0010,
                4'b0100,
                4'b1000
            };

            bins half[] = {
                4'b1100,
                4'b0011,
                4'b0110,
                4'b1001
            };

            bins full = {4'b1111};

            bins sparse[] = {
                4'b0101,
                4'b1010
            };
        }

        //error coverage
        ERROR_CP : coverpoint tr.slverr {

            bins no_error = {0};
            bins error    = {1};

        }

        //cross coverage 
        ADDR_X_WRITE: cross ADDR_CP, WRITE_CP;
        PSTRB_X_WRITE: cross PSTRB_CP, WRITE_CP;
        ERROR_X_ADDR : cross ERROR_CP, ADDR_CP;

    endgroup

    function new(string name, uvm_component parent);
        super.new(name, parent);

        apb_cov = new();
    endfunction

    //to automatically call it  from monitor
    function void write(apb_seq_item t);
        tr = t;
        apb_cov.sample();
    endfunction
endclass