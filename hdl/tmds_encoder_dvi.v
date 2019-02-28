`timescale 1ns / 1ps
`default_nettype none

// Project F: Display TMDS Encoder for DVI
// (C)2019 Will Green, Open source hardware released under the MIT License
// Learn more at https://projectf.io

module tmds_encoder_dvi(
    input  wire i_clk,          // clock
    input  wire i_rst,          // reset (active high)
    input  wire [7:0] i_data,   // colour data
    input  wire [1:0] i_ctrl,   // control data
    input  wire i_de,           // display enable (active high)
    output reg [9:0] o_tmds     // encoded TMDS data
    );

    // select basic encoding based on the ones in the input data   
    wire [3:0] one_cnt = {3'b0,i_data[0]} + {3'b0,i_data[1]} + {3'b0,i_data[2]}
        + {3'b0,i_data[3]} + {3'b0,i_data[4]} + {3'b0,i_data[5]} 
        + {3'b0,i_data[6]} + {3'b0,i_data[7]};
    wire use_xnor = (one_cnt > 4'd4) || ((one_cnt == 4'd4) && (i_data[0] == 0));
    
    // encode colour data with xor/xnor 
    wire [8:0] enc_qm;
    assign enc_qm[0] = i_data[0];
    assign enc_qm[1] = (use_xnor) ? (enc_qm[0] ~^ i_data[1]) : (enc_qm[0] ^ i_data[1]);
    assign enc_qm[2] = (use_xnor) ? (enc_qm[1] ~^ i_data[2]) : (enc_qm[1] ^ i_data[2]);
    assign enc_qm[3] = (use_xnor) ? (enc_qm[2] ~^ i_data[3]) : (enc_qm[2] ^ i_data[3]);
    assign enc_qm[4] = (use_xnor) ? (enc_qm[3] ~^ i_data[4]) : (enc_qm[3] ^ i_data[4]);
    assign enc_qm[5] = (use_xnor) ? (enc_qm[4] ~^ i_data[5]) : (enc_qm[4] ^ i_data[5]);
    assign enc_qm[6] = (use_xnor) ? (enc_qm[5] ~^ i_data[6]) : (enc_qm[5] ^ i_data[6]);
    assign enc_qm[7] = (use_xnor) ? (enc_qm[6] ~^ i_data[7]) : (enc_qm[6] ^ i_data[7]);
    assign enc_qm[8] = (use_xnor) ? 0 : 1;

    // calculate disparity in encoded data - rolls over to zero when four ones
    wire [3:0] disparity = 4'b1100 + {3'b0,enc_qm[0]} + {3'b0,enc_qm[1]} 
        + {3'b0,enc_qm[2]} + {3'b0,enc_qm[3]} + {3'b0,enc_qm[4]}
        + {3'b0,enc_qm[5]} + {3'b0,enc_qm[6]} + {3'b0,enc_qm[7]};

    // record ongoing bias
    reg  [3:0] bias;
        
    always @ (posedge i_clk)
    begin
        if (i_rst)
        begin
            o_tmds <= 10'b1101010100;  // equiv. to ctrl 2'b00
            bias <= 4'b0000;
        end
        else if (i_de == 0)  // send control data in blanking interval
        begin
            case (i_ctrl)
                2'b00:   o_tmds <= 10'b1101010100;
                2'b01:   o_tmds <= 10'b0010101011;
                2'b10:   o_tmds <= 10'b0101010100;
                default: o_tmds <= 10'b1010101011;
            endcase
            bias <= 4'b0000;
        end
        else // send video data - four options for each pixel
        begin  
            if ((bias == 0) || (disparity == 0)) // no prior bias or no disparity 
            begin
                if (enc_qm[8])
                begin
                    o_tmds[9:0] <= {2'b01, enc_qm[7:0]};
                    bias <= bias + disparity;
                end
                else begin
                    o_tmds[9:0] <= {2'b10, ~enc_qm[7:0]};
                    bias <= bias - disparity;
                end  
            end
            else if (bias[3] == disparity[3])  // if both bias and disparity have the same sign
            begin
                o_tmds[9:0] <= {1'b1, enc_qm[8], ~enc_qm[7:0]};
                bias <= bias + 2 * enc_qm[8] - disparity;
            end
            else
            begin
                o_tmds[9:0] <= {1'b0, enc_qm[8], enc_qm[7:0]};
                bias <= bias - 2 * enc_qm[8] + disparity;
            end
        end
    end
endmodule
