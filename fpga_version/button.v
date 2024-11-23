module button
#(
    parameter INVERTED = 1
)
(
    input  wire  clk,
    input  wire  KEY,
    output  reg skey
);


    reg but1, but2;


    always @(posedge clk) begin
        but1 <= INVERTED ? ~KEY0 : KEY0;
        but2 <= but0_1;
    end
    
    always @(posedge clk)
        skey <= ~but1 & but2;
