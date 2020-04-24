//===================================================================
//
// Copyright (C) Wavious 2019 - All Rights Reserved
//
// Unauthorized copying of this file, via any medium is strictly prohibited
//
// Created by sbridges on November/08/2019 at 08:09:59
//
// rfifo_example_addr_defines.vh
//
//===================================================================



`define RFIFO_EXAMPLE_REG1                                                     'h00000000
`define RFIFO_EXAMPLE_REG1__BF1_MUX                                                     5
`define RFIFO_EXAMPLE_REG1__BF1                                                       4:0
`define RFIFO_EXAMPLE_REG1___POR                                             32'h00000000

`define RFIFO_EXAMPLE_REG_WITH_RFIFO                                           'h00000004
`define RFIFO_EXAMPLE_REG_WITH_RFIFO__READ_DATA                                       7:0
`define RFIFO_EXAMPLE_REG_WITH_RFIFO___POR                                   32'h00000000

`define RFIFO_EXAMPLE_DEBUG_BUS_CTRL                                           'h00000008
`define RFIFO_EXAMPLE_DEBUG_BUS_CTRL__DEBUG_BUS_CTRL_SEL                                0
`define RFIFO_EXAMPLE_DEBUG_BUS_CTRL___POR                                   32'h00000000

`define RFIFO_EXAMPLE_DEBUG_BUS_STATUS                                         'h0000000C
`define RFIFO_EXAMPLE_DEBUG_BUS_STATUS__DEBUG_BUS_CTRL_STATUS                        31:0
`define RFIFO_EXAMPLE_DEBUG_BUS_STATUS___POR                                 32'h00000000

