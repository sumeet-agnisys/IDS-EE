module por (output logic reset);

    initial 
        begin
            force reset = 1'b0;
            #10;
            force reset = 1'b1;
        end
endmodule
