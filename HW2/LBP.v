module LBP # (
    parameter DATA_WIDTH = 8,              // AXI4 data width
    parameter ADDR_WIDTH = 15,             // AXI4 address width
    parameter STRB_WIDTH = (DATA_WIDTH/8)  // AXI4 strobe width
)
(
    // Clock and synchronous high reset
    input                   clk_A,
    input                   clk_B,
    input                   rst,

    input                   start,
    output                  finish,

    // Data AXI4 master interface
    output [ADDR_WIDTH-1:0] data_awaddr,
    output [           7:0] data_awlen,
    output [           2:0] data_awsize,
    output [           1:0] data_awburst,
    output                  data_awvalid,
    input                   data_awready,
    output [DATA_WIDTH-1:0] data_wdata,
    output [STRB_WIDTH-1:0] data_wstrb,
    output                  data_wlast,
    output                  data_wvalid,
    input                   data_wready,
    // input  [           1:0] data_bresp,
    // input                   data_bvalid,
    // output                  data_bready,
    output [ADDR_WIDTH-1:0] data_araddr,
    output [           7:0] data_arlen,
    output [           2:0] data_arsize,
    output [           1:0] data_arburst,
    output                  data_arvalid,
    input                   data_arready,
    input  [DATA_WIDTH-1:0] data_rdata,
    input  [           1:0] data_rresp,
    input                   data_rlast,
    input                   data_rvalid,
    output                  data_rready
);


parameter IDLE = 0;
parameter READ = 1;
//---------  DRAM READ --------//
parameter DRAM_READ_IDLE = 0;
parameter DRAM_READ_READY = 1;
parameter DRAM_READ_DATA = 2;
//---------  DRAM WRITE -------//
parameter DRAM_WRITE_IDLE  = 0;
parameter DRAM_WRITE_ADDRESS = 1;
parameter DRAM_WRITE_DATA  = 2;

integer i;

wire pulse;
reg state, nxt_state;
reg [1:0] dram_read_state,nxt_dram_read_state;
reg [1:0] dram_write_state,nxt_dram_write_state;
reg start_temp1,nxt_start_temp1;
reg start_temp2,nxt_start_temp2;
reg [7:0] LBP_result;
wire [7:0] LBP_1, LBP_2, LBP_3, LBP_4,LBP_gc, LBP_6, LBP_7, LBP_8, LBP_9;
reg [7:0] reg_0, nxt_reg_0, reg_1, nxt_reg_1, reg_2, nxt_reg_2, reg_3, nxt_reg_3, reg_4, nxt_reg_4, reg_5, nxt_reg_5;
reg [7:0] reg_6, nxt_reg_6, reg_7, nxt_reg_7, reg_8, nxt_reg_8, reg_9, nxt_reg_9, reg_10, nxt_reg_10, reg_11, nxt_reg_11;
reg [7:0] reg_12, nxt_reg_12, tmp_1, nxt_tmp_1, tmp_2, nxt_tmp_2, tmp_3, nxt_tmp_3, tmp_4, nxt_tmp_4, tmp_5, nxt_tmp_5, tmp_6, nxt_tmp_6;

reg [7:0] x, nxt_x , y, nxt_y;
reg [4:0] cnt, nxt_cnt;
reg  wcnt,nxt_wcnt;

reg [2:0] wlast_cnt, nxt_wlast_cnt;
reg [6:0] x_waddr, nxt_x_waddr;
reg [6:0] y_waddr, nxt_y_waddr;
wire [14:0] waddr_debug;
reg ar_flag, nxt_ar_flag;
reg aw_flag, nxt_aw_flag;
reg [14:0] araddr, nxt_araddr;
reg [1:0] ar_cnt, nxt_ar_cnt;


assign waddr_debug = data_awaddr - 16384;
always @(*) begin
    nxt_start_temp1 = start;
end
always @(*) begin
    nxt_start_temp2 = start_temp1;
end

assign data_awaddr = x_waddr + 16513 + (y_waddr<<7);
assign data_awlen = 8'd5;
assign data_awsize = 3'd1;
assign data_awburst = 2'b01;
assign data_awvalid = (aw_flag) ? 1 : 0;
//W
assign data_wdata = LBP_result;
assign data_wvalid = (wcnt == 1) ? 1 : 0;
assign data_wlast = ((wlast_cnt == 5)) ? 1 : 0; 
assign data_wstrb = 1;
//AR
assign data_arlen = 8'd3;
assign data_arsize = 3'd1;
assign data_araddr = araddr;

assign data_arvalid = (ar_flag) ? 1 : 0;
assign data_arburst = 2'b01;
//R
assign data_rready = ((dram_read_state == DRAM_READ_DATA) && (((x<4) && (cnt<=10)) || ((x>=4) && (cnt<=8)))) ? 1 : (wcnt == 0) ? 1 : 0;

assign pulse = ((y==128) && ((cnt == 1) || (cnt == 3) || (cnt == 5)));

Pluse_syn P0 (.aclk(clk_A), .bclk(clk_B), .rst(rst), .IN(pulse), .b_p(finish));


//AXI
// LOAD DATA
always @(*) begin
    if ((x<4) && (cnt == 0) && (data_rvalid && data_rready)) begin
        nxt_tmp_1 = data_rdata;
    end
    else if ((x<4) && (data_rvalid && data_rready)) begin
        case (cnt)
            0,11: nxt_tmp_1 = tmp_2;
            default: nxt_tmp_1 = tmp_1;
        endcase
    end
    else begin
        if (x>=4 && (data_rvalid && data_rready)) begin
            case (cnt)
                0,9,10,11:begin
                    nxt_tmp_1 = tmp_2;
                end 
                default: nxt_tmp_1 = tmp_1;
            endcase            
        end
        else nxt_tmp_1 = tmp_1;
    end
end
always @(*) begin
    if ((x<4) && (cnt == 1) && (data_rvalid && data_rready)) begin
        nxt_tmp_2 = data_rdata;
    end
    else if ((x<4) && (data_rvalid && data_rready)) begin
        case (cnt)
            0,11: nxt_tmp_2 = reg_0;
            default: nxt_tmp_2 = tmp_2;
        endcase
    end
    else begin
        if (x>=4 && (data_rvalid && data_rready)) begin
            case (cnt)
                0,9,10,11:begin
                    nxt_tmp_2 = reg_0;
                end 
                default: nxt_tmp_2 = tmp_2;
            endcase            
        end
        else nxt_tmp_2 = tmp_2;
    end
end
always @(*) begin
    if ((x<4) && (cnt == 4) && (data_rvalid && data_rready)) begin
        nxt_tmp_3 = data_rdata;
    end
    else if ((x<4) && (data_rvalid && data_rready)) begin
        case (cnt)
            0,11: nxt_tmp_3 = tmp_4;
            default: nxt_tmp_3 = tmp_3;
        endcase
    end
    else begin
        if (x>=4 && (data_rvalid && data_rready)) begin
            case (cnt)
                0,9,10,11:begin
                    nxt_tmp_3 = tmp_4;
                end 
                default: nxt_tmp_3 = tmp_3;
            endcase            
        end
        else nxt_tmp_3 = tmp_3;
    end
end
always @(*) begin
    if ((x<4) && (cnt == 5) && (data_rvalid && data_rready)) begin
        nxt_tmp_4 = data_rdata;
    end
    else if ((x<4) && (data_rvalid && data_rready)) begin
        case (cnt)
            0,11: nxt_tmp_4 = reg_4;
            default: nxt_tmp_4 = tmp_4;
        endcase
    end
    else begin
        if (x>=4 && (data_rvalid && data_rready)) begin
            case (cnt)
                0,9,10,11:begin
                    nxt_tmp_4 = reg_4;
                end 
                default: nxt_tmp_4 = tmp_4;
            endcase            
        end
        else nxt_tmp_4 = tmp_4;
    end
end
always @(*) begin
    if ((x<4) && (cnt == 8) && (data_rvalid && data_rready)) begin
        nxt_tmp_5 = data_rdata;
    end
    else if ((x<4) && (data_rvalid && data_rready)) begin
        case (cnt)
            0,11: nxt_tmp_5 = tmp_6;
            default: nxt_tmp_5 = tmp_5;
        endcase
    end
    else begin
        if (x>=4 && (data_rvalid && data_rready)) begin
            case (cnt)
                0,9,10,11:begin
                    nxt_tmp_5 = tmp_6;
                end 
                default: nxt_tmp_5 = tmp_5;
            endcase            
        end
        else nxt_tmp_5 = tmp_5;
    end
end
always @(*) begin

    if ((x<4) && (cnt == 9) && (data_rvalid && data_rready)) begin
        nxt_tmp_6 = data_rdata;
    end
    else if ((x<4) && (data_rvalid && data_rready)) begin
        case (cnt)
            0,11: nxt_tmp_6 = reg_8;
            default: nxt_tmp_6 = tmp_6;
        endcase
    end
    else begin
        if (x>=4 && (data_rvalid && data_rready)) begin
            case (cnt)
                0,9,10,11:begin
                    nxt_tmp_6 = reg_8;
                end 
                default: nxt_tmp_6 = tmp_6;
            endcase            
        end
        else nxt_tmp_6 = tmp_6;
    end
end
always @(*) begin
    if ((x<4) && (cnt == 2) && (data_rvalid && data_rready)) begin
        nxt_reg_0 = data_rdata;
    end
    else if ((x>=4) && (cnt == 0) && (data_rvalid && data_rready)) begin
        nxt_reg_0 = data_rdata;
    end
    else if ((x<4) && ((cnt == 0) ||(cnt == 11)) && (data_rvalid && data_rready)) begin
        nxt_reg_0 = reg_1;
    end
    else if ((x>=4) && ((cnt == 0) || (cnt == 9) || (cnt == 10) || (cnt == 11)) && (data_rvalid && data_rready)) begin
        nxt_reg_0 = reg_1;
    end
    else nxt_reg_0 = reg_0;
end
always @(*) begin
    if ((x<4) && (cnt == 3) && (data_rvalid && data_rready)) begin
        nxt_reg_1 = data_rdata;
    end
    else if ((x>=4) && (cnt == 1) && (data_rvalid && data_rready)) begin
        nxt_reg_1 = data_rdata;
    end
    else if ((x<4) && ((cnt == 0) ||(cnt == 11)) && (data_rvalid && data_rready)) begin
        nxt_reg_1 = reg_2;
    end
    else if ((x>=4) && ((cnt == 0) || (cnt == 9) || (cnt == 10) || (cnt == 11)) && (data_rvalid && data_rready)) begin
        nxt_reg_1 = reg_2;
    end
    else nxt_reg_1 = reg_1;
end
always @(*) begin
    if ((x>=4) && (cnt == 2) && (data_rvalid && data_rready)) begin
        nxt_reg_2 = data_rdata;
    end
    else if ((x>=4) && ((cnt == 0) || (cnt == 9) || (cnt == 10) || (cnt == 11)) && (data_rvalid && data_rready)) begin
        nxt_reg_2 = reg_3;
    end
    else nxt_reg_2 = reg_2;
end
always @(*) begin
    if ((x>=4) && (cnt == 3) && (data_rvalid && data_rready)) begin
        nxt_reg_3 = data_rdata;
    end
    else nxt_reg_3 = reg_3;
end
always @(*) begin
    if ((x<4) && (cnt == 6) && (data_rvalid && data_rready)) begin
        nxt_reg_4 = data_rdata;
    end
    else if ((x>=4) && (cnt == 4) && (data_rvalid && data_rready)) begin
        nxt_reg_4 = data_rdata;
    end
    else if ((x<4) && ((cnt == 0) || (cnt == 11)) && (data_rvalid && data_rready)) begin
        nxt_reg_4 = reg_5;
    end
    else if ((x>=4) && ((cnt == 0) || (cnt == 9) || (cnt == 10) || (cnt == 11)) && (data_rvalid && data_rready)) begin
        nxt_reg_4 = reg_5;
    end
    else nxt_reg_4 = reg_4;
end
always @(*) begin
    if ((x<4) && (cnt == 7) && (data_rvalid && data_rready)) begin
        nxt_reg_5 = data_rdata;
    end
    else if ((x>=4) && (cnt == 5) && (data_rvalid && data_rready)) begin
        nxt_reg_5 = data_rdata;
    end
    else if ((x<4) && ((cnt == 0) || (cnt == 11)) && (data_rvalid && data_rready)) begin
        nxt_reg_5 = reg_6;
    end
    else if ((x>=4) && ((cnt == 0) || (cnt == 9) || (cnt == 10) || (cnt == 11)) && (data_rvalid && data_rready)) begin
        nxt_reg_5 = reg_6;
    end
    else nxt_reg_5 = reg_5;
end
always @(*) begin
    if ((x>=4) && (cnt == 6) && (data_rvalid && data_rready)) begin
        nxt_reg_6 = data_rdata;
    end
    else if ((x>=4) && ((cnt == 0) || (cnt == 9) || (cnt == 10) || (cnt == 11)) && (data_rvalid && data_rready)) begin
        nxt_reg_6 = reg_7;
    end
    else nxt_reg_6 = reg_6;
end
always @(*) begin
    if ((x>=4) && (cnt == 7) && (data_rvalid && data_rready)) begin
        nxt_reg_7 = data_rdata;
    end
    else nxt_reg_7 = reg_7;
end

always @(*) begin
    if ((x<4) && (cnt>=10) && (data_rvalid && data_rready)) begin
        nxt_reg_8 = data_rdata;
    end
    else if ((x>=4) && (cnt>=8) && (data_rvalid && data_rready)) begin
        nxt_reg_8 = data_rdata;
    end
    else nxt_reg_8 = reg_8;
end

//cnt
always @(*) begin
    if ((wlast_cnt == 5) && data_wready && data_wvalid) begin
        nxt_wlast_cnt = 0;
    end
    else if (data_wready && data_wvalid) begin
        nxt_wlast_cnt = wlast_cnt + 1;
    end
    else nxt_wlast_cnt = wlast_cnt;
end
always @(*) begin
    if ((cnt == 11) && (data_rvalid && data_rready)) begin
        nxt_cnt = 0;
    end
    else if (data_rvalid && data_rready) begin
        nxt_cnt = cnt + 1;
    end
    else nxt_cnt = cnt;  
end
always @(*) begin
    if ((y==128) && (cnt > 1)) begin
        nxt_wcnt = 0;
    end
    else if ((data_wvalid && data_wready) && (((x<4) && (cnt>=10)) || ((x>=4) && (cnt>=8)) || (cnt == 0) || (cnt == 6) )) begin 
        nxt_wcnt = wcnt - 1;
    end
    else if ((data_rvalid && data_rready) && (((x<4) && (cnt>=10)) || ((x>=4) && (cnt>=8)))) begin
        nxt_wcnt = wcnt + 1;
    end
    else nxt_wcnt = wcnt;
end

always @(*) begin
    if ((x == 127) && (cnt == 11) && (data_rvalid && data_rready)) begin
        nxt_x = 0;
    end
    else if (((cnt == 3) || (cnt == 7)) && (data_rvalid && data_rready)) begin
        nxt_x = x - 3;
    end
    else if (data_rvalid && data_rready) begin
        nxt_x = x + 1;
    end
    else nxt_x = x;
end
always @(*) begin
    if ((x==127) && (cnt==11) && (y==127) && (data_rvalid && data_rready)) begin
        nxt_y = 128;
    end
    else if (y==128) begin
        nxt_y = 128;
    end
    else if ((x==127) && (cnt==11) && (data_rvalid && data_rready)) begin
        nxt_y = y - 1;
    end
    else if ((cnt == 11) && (x != 127) && (data_rvalid && data_rready)) begin
        nxt_y = y - 2;
    end
    else if (((cnt == 3) || (cnt == 7)) && (data_rvalid && data_rready)) begin
        nxt_y = y + 1;
    end
    else nxt_y = y;
end

//FSM
always @(*) begin
    case (state)
        IDLE: begin
            if (start_temp2) begin
                nxt_state = READ;
            end
            else nxt_state = state;
        end
        READ: begin
            nxt_state = state;
        end
        default: nxt_state = state;
    endcase
end
//DRAM READ STATE
always @(*) begin
    if (state == READ) begin
        case (dram_read_state)
            DRAM_READ_IDLE: begin
                nxt_dram_read_state = DRAM_READ_READY;
            end
            DRAM_READ_READY: begin
                if (data_arvalid && data_arready) begin
                    nxt_dram_read_state = DRAM_READ_DATA;
                end
                else nxt_dram_read_state = dram_read_state;
            end
            DRAM_READ_DATA: begin
                if (data_rlast && data_rvalid && data_rready) begin
                    nxt_dram_read_state = DRAM_READ_READY;
                end
                else nxt_dram_read_state = dram_read_state;
            end          
            default: nxt_dram_read_state = dram_read_state;
        endcase
    end
    else nxt_dram_read_state = dram_read_state;
end
always @(*) begin
    if (state == READ) begin
        case (ar_flag)
            0:nxt_ar_flag = 1;
            1:begin
                if (data_arvalid && data_arready) begin
                    nxt_ar_flag = 0;
                end
                else nxt_ar_flag = ar_flag;
            end 
            default: nxt_ar_flag = ar_flag;
        endcase
    end
    else nxt_ar_flag = ar_flag;
end
always @(*) begin
    if (data_arvalid && data_arready && (ar_cnt == 2)) begin
        nxt_araddr = araddr - 252;
    end
    else if (data_arvalid && data_arready) begin
        nxt_araddr = araddr + 128;
    end
    else nxt_araddr = araddr;
end
always @(*) begin
    if ((ar_cnt == 2) && data_arvalid && data_arready) begin
        nxt_ar_cnt = 0;
    end
    else if (data_arvalid && data_arready) begin
        nxt_ar_cnt = ar_cnt + 1;
    end
    else nxt_ar_cnt = ar_cnt;
end
//write outstanding
always @(*) begin
    if ((x_waddr == 120) && data_awvalid && data_awready) begin
        nxt_x_waddr = 0;
    end
    else if ((data_awvalid && data_awready)) begin
        nxt_x_waddr = x_waddr + 6;
    end
    else nxt_x_waddr = x_waddr;
end
always @(*) begin
    if ((x_waddr == 120) && data_awvalid && data_awready) begin
        nxt_y_waddr = y_waddr + 1;
    end
    else nxt_y_waddr = y_waddr;
end

always @(*) begin
    if (state == READ) begin
        case (aw_flag)
            0:nxt_aw_flag = 1;
            1:begin
                if (data_awvalid && data_awready) begin
                    nxt_aw_flag = 0;
                end
                else nxt_aw_flag = aw_flag;
            end 
            default: nxt_aw_flag = aw_flag;
        endcase
    end
    else nxt_aw_flag = aw_flag;
end

always @(*) begin
    if (state == READ) begin
        case (dram_write_state)
            DRAM_WRITE_IDLE: begin
                nxt_dram_write_state = DRAM_WRITE_ADDRESS;
            end
            DRAM_WRITE_ADDRESS: begin
                if (data_awvalid && data_awready) begin
                    nxt_dram_write_state = DRAM_WRITE_DATA;
                end
                else nxt_dram_write_state = dram_write_state;
            end
            DRAM_WRITE_DATA: begin
                if (data_wlast && data_wvalid && data_wready) begin
                    nxt_dram_write_state = DRAM_WRITE_ADDRESS;
                end
                else nxt_dram_write_state = dram_write_state;
            end
            default: nxt_dram_write_state = dram_write_state;
        endcase
    end
    else nxt_dram_write_state = dram_write_state;
end

//LBP compute
assign LBP_1 = tmp_1;
assign LBP_2 = tmp_2;
assign LBP_3 = reg_0;
assign LBP_4 = tmp_3;
assign LBP_gc = tmp_4;
assign LBP_6 = reg_4;
assign LBP_7 = tmp_5;
assign LBP_8 = tmp_6;
assign LBP_9 = reg_8;

always @(*) begin
    LBP_result[0] = (LBP_1 >= LBP_gc) ? 1 : 0; 
    LBP_result[1] = (LBP_2 >= LBP_gc) ? 1 : 0; 
    LBP_result[2] = (LBP_3 >= LBP_gc) ? 1 : 0;
    LBP_result[3] = (LBP_4 >= LBP_gc) ? 1 : 0;
    LBP_result[4] = (LBP_6 >= LBP_gc) ? 1 : 0;
    LBP_result[5] = (LBP_7 >= LBP_gc) ? 1 : 0;
    LBP_result[6] = (LBP_8 >= LBP_gc) ? 1 : 0;
    LBP_result[7] = (LBP_9 >= LBP_gc) ? 1 : 0;    
end



always @(posedge clk_B or posedge rst) begin
    if (rst) begin
        start_temp1 <= 0;
        start_temp2 <= 0;
        reg_0 <= 0;
        reg_1  <= 0;
        reg_2  <= 0;
        reg_3  <= 0;
        reg_4  <= 0;
        reg_5  <= 0;
        reg_6  <= 0;
        reg_7  <= 0;
        reg_8  <= 0;
        reg_9  <= 0;
        reg_10 <= 0;
        reg_11 <= 0;
        reg_12 <= 0;
        tmp_5 <= 0;
        tmp_1 <= 0;
        tmp_2 <= 0;
        tmp_3 <= 0;
        tmp_4 <= 0;
        tmp_6 <= 0;
        x <= 0;//      
        y <= 0;
        state <= 0;
        dram_read_state <= 0;
        dram_write_state <= 0;
        cnt <= 0;
        wlast_cnt <= 0;
        x_waddr <= 0;
        y_waddr <= 0;
        wcnt <= 0;
        ar_flag <= 0;
        araddr <= 0;
        ar_cnt <= 0;
        aw_flag <= 0;
    end
    else begin
        start_temp1 <= nxt_start_temp1;
        start_temp2 <= nxt_start_temp2;
        reg_0  <= nxt_reg_0 ;
        reg_1  <= nxt_reg_1 ;
        reg_2  <= nxt_reg_2 ;
        reg_3  <= nxt_reg_3 ;
        reg_4  <= nxt_reg_4 ;
        reg_5  <= nxt_reg_5 ;
        reg_6  <= nxt_reg_6 ;
        reg_7  <= nxt_reg_7 ;
        reg_8  <= nxt_reg_8 ;
        reg_9  <= nxt_reg_9 ;
        reg_10 <= nxt_reg_10;
        reg_11 <= nxt_reg_11;
        reg_12 <= nxt_reg_12;
        tmp_5 <= nxt_tmp_5;
        tmp_1 <= nxt_tmp_1;
        tmp_2 <= nxt_tmp_2;
        tmp_3 <= nxt_tmp_3;
        tmp_4 <= nxt_tmp_4;
        tmp_6 <= nxt_tmp_6;
        x <= nxt_x;
        y <= nxt_y;
        state <= nxt_state;
        dram_read_state <= nxt_dram_read_state;
        dram_write_state <= nxt_dram_write_state;
        cnt <= nxt_cnt;
        wlast_cnt <= nxt_wlast_cnt;
        x_waddr <= nxt_x_waddr;
        y_waddr <= nxt_y_waddr;
        wcnt <= nxt_wcnt;
        ar_flag <= nxt_ar_flag;
        araddr <= nxt_araddr;
        ar_cnt <= nxt_ar_cnt;
        aw_flag <= nxt_aw_flag;
    end
end

endmodule

module Pluse_syn (aclk, bclk, rst, IN, b_p);
    input aclk;
    input bclk;
    input IN;
    input rst;
    output b_p;

reg A, nxt_A;
reg B1, nxt_B1;
reg B2, nxt_B2;
reg B3, nxt_B3;

wire a_p_in;
assign a_p_in = IN ^ A;
always @(*) begin
    nxt_A = a_p_in;
end
always @(*) begin
    nxt_B1 = A;
end
always @(*) begin
    nxt_B2 = B1;
end
always @(*) begin
    nxt_B3 = B2;
end
assign b_p = B2 ^ B3;

always @(posedge bclk or posedge rst) begin
    if (rst) begin
        A <= 0;
    end
    else begin
        A <= nxt_A;
    end
end
always @(posedge aclk or posedge rst) begin
    if (rst) begin
        B1 <= 0;
        B2 <= 0;
        B3 <= 0;
    end
    else begin
        B1 <= nxt_B1;
        B2 <= nxt_B2;
        B3 <= nxt_B3;
    end
end

endmodule