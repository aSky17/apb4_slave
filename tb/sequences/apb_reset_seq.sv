//simple reset from IDLE
class apb_reset_seq extends apb_base_seq;

    `uvm_object_utils(apb_reset_seq)

    virtual apb_if vif;

    function new(string name = "apb_reset_seq");
        super.new(name);
    endfunction

    task body();

        if (!uvm_config_db #(virtual apb_if):: get(
            null,
            "",
            "vif",
            vif
        )) begin
            `uvm_fatal("RESET_SEQ", "Cannot get vif")
        end

        vif.reset_dut();
    endtask
endclass