//===================================================================
//
// Copyright (C) Wavious 2019 - All Rights Reserved
//
// Unauthorized copying of this file, via any medium is strictly prohibited
//
// Created by sbridges on November/11/2019 at 13:18:06
//
// spi_regs_addr_defines.vh
//
//===================================================================



`define SPI_REGS_ENABLE                                                        'h00000000
`define SPI_REGS_ENABLE__CLOCK_GATE                                                     1
`define SPI_REGS_ENABLE__SPI_EN                                                         0
`define SPI_REGS_ENABLE___POR                                                32'h00000001

`define SPI_REGS_CONTROLS                                                      'h00000004
`define SPI_REGS_CONTROLS__CPHA                                                         2
`define SPI_REGS_CONTROLS__CPOL                                                         1
`define SPI_REGS_CONTROLS__SS_POLARITY                                                  0
`define SPI_REGS_CONTROLS___POR                                              32'h00000000

`define SPI_REGS_INTERRUPT                                                     'h00000008
`define SPI_REGS_INTERRUPT__TRANSACTION_COMP_INT_EN                                     1
`define SPI_REGS_INTERRUPT__TRANSACTION_COMP                                            0
`define SPI_REGS_INTERRUPT___POR                                             32'h00000002

`define SPI_REGS_WDATA                                                         'h0000000C
`define SPI_REGS_WDATA__WDATA                                                         7:0
`define SPI_REGS_WDATA___POR                                                 32'h00000000

`define SPI_REGS_RDATA                                                         'h00000010
`define SPI_REGS_RDATA__RDATA                                                         7:0
`define SPI_REGS_RDATA___POR                                                 32'h00000000

`define SPI_REGS_STATUS                                                        'h00000014
`define SPI_REGS_STATUS__FSM_STATE                                                    2:0
`define SPI_REGS_STATUS___POR                                                32'h00000000

//===================================================================
//
// Copyright (C) Wavious 2019 - All Rights Reserved
//
// Unauthorized copying of this file, via any medium is strictly prohibited
//
// Created by sbridges on November/11/2019 at 13:18:06
//
// i2c_regs_addr_defines.vh
//
//===================================================================



`define I2C_REGS_ENABLE                                                        'h00000000
`define I2C_REGS_ENABLE__CLOCK_GATE                                                     1
`define I2C_REGS_ENABLE__I2C_EN                                                         0
`define I2C_REGS_ENABLE___POR                                                32'h00000001

`define I2C_REGS_INTERRUPT                                                     'h00000004
`define I2C_REGS_INTERRUPT__TRANSACTION_COMP_INT_EN                                     1
`define I2C_REGS_INTERRUPT__TRANSACTION_COMP                                            0
`define I2C_REGS_INTERRUPT___POR                                             32'h00000002

`define I2C_REGS_SLAVE_ADDR                                                    'h00000008
`define I2C_REGS_SLAVE_ADDR__SLAVE_ADDR                                               9:0
`define I2C_REGS_SLAVE_ADDR___POR                                            32'h0000005B

`define I2C_REGS_WDATA                                                         'h0000000C
`define I2C_REGS_WDATA__WDATA                                                         7:0
`define I2C_REGS_WDATA___POR                                                 32'h00000000

`define I2C_REGS_RDATA                                                         'h00000010
`define I2C_REGS_RDATA__RDATA                                                         7:0
`define I2C_REGS_RDATA___POR                                                 32'h00000000

`define I2C_REGS_STATUS                                                        'h00000014
`define I2C_REGS_STATUS__FSM_STATE                                                    2:0
`define I2C_REGS_STATUS___POR                                                32'h00000000

