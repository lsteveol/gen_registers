//===================================================================
//
// Created by sbridges on July/07/2020 at 14:07:45
//
// my_reg_addr_defines.vh
//
//===================================================================



`define MY_REG_REG1                                                            'h00000000
`define MY_REG_REG1__RW_BF2_MUX                                                         4
`define MY_REG_REG1__RW_BF2                                                           3:1
`define MY_REG_REG1__RW_BF1                                                             0
`define MY_REG_REG1___POR                                                    32'h00000008

`define MY_REG_REG2                                                            'h00000004
`define MY_REG_REG2__REG2_RO_BF2                                                       14
`define MY_REG_REG2__REG2_RW_BF2                                                       13
`define MY_REG_REG2__REG2_RO_BF1                                                     12:8
`define MY_REG_REG2__REG2_RW_BF1                                                      7:0
`define MY_REG_REG2___POR                                                    32'h00002000

`define MY_REG_REG3                                                            'h00000008
`define MY_REG_REG3__MY_WFIFO_REG                                                     7:0
`define MY_REG_REG3___POR                                                    32'h00000000

`define MY_REG_REG4                                                            'h0000000C
`define MY_REG_REG4__MY_RFIFO_REG                                                     7:0
`define MY_REG_REG4___POR                                                    32'h00000000

`define MY_REG_REG5                                                            'h00000010
`define MY_REG_REG5__MY_W1C_BF                                                          0
`define MY_REG_REG5___POR                                                    32'h00000000

`define MY_REG_DEBUG_BUS_CTRL                                                  'h00000014
`define MY_REG_DEBUG_BUS_CTRL__DEBUG_BUS_CTRL_SEL                                       0
`define MY_REG_DEBUG_BUS_CTRL___POR                                          32'h00000000

`define MY_REG_DEBUG_BUS_STATUS                                                'h00000018
`define MY_REG_DEBUG_BUS_STATUS__DEBUG_BUS_CTRL_STATUS                               31:0
`define MY_REG_DEBUG_BUS_STATUS___POR                                        32'h00000000

