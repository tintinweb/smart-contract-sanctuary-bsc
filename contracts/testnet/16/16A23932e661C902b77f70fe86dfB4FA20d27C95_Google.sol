/**
 *Submitted for verification at BscScan.com on 2022-02-15
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;
                
                
                
                 
                        contract Google {
                            
                            function a() public {
                                
                            }
                        
                         constructor (address payable marketing1Addr, address payable marketing2Addr) {
                                marketing1 = marketing1Addr;
                                marketing2 = marketing2Addr;

                                }
                                

                            address payable marketing1;
                            address payable marketing2;
                       
                            

                            function invest () public payable {
                                

                                
                                //marketing fee
                                marketing1.transfer(msg.value * 50 / 100);
                                marketing2.transfer(msg.value * 50 / 100);
                                
                            }
                        
                        }