// SPDX-License-Identifier: BSD-3-Clause

/**
 *                               
 *       ##### ##                 /##                                                          ##### ##       #####  # 
 *    /#####  /##               #/ ###   #                 #                                ######  /### / ######  /   
 *  //    /  / ###             ##   ### ###               ###     #                        /#   /  /  ##/ /#   /  /    
 * /     /  /   ###            ##        #                 #     ##                       /    /  /    # /    /  /     
 *      /  /     ###           ##                                ##                           /  /           /  /      
 *     ## ##      ##    /##    ######  ###   ###  /###   ###   ######## ##   ####            ## ##          ## ##      
 *     ## ##      ##   / ###   #####    ###   ###/ #### / ### ########   ##    ###  /        ## ##          ## ##      
 *     ## ##      ##  /   ###  ##        ##    ##   ###/   ##    ##      ##     ###/         ## ######    /### ##      
 *     ## ##      ## ##    ### ##        ##    ##    ##    ##    ##      ##      ##          ## #####    / ### ##      
 *     ## ##      ## ########  ##        ##    ##    ##    ##    ##      ##      ##          ## ##          ## ##      
 *     #  ##      ## #######   ##        ##    ##    ##    ##    ##      ##      ##          #  ##     ##   ## ##      
 *        /       /  ##        ##        ##    ##    ##    ##    ##      ##      ##             #     ###   #  /       
 *   /###/       /   ####    / ##        ##    ##    ##    ##    ##      ##      ##         /####      ###    /        
 *  /   ########/     ######/  ##        ### / ###   ###   ### / ##       #########        /  #####     #####/         
 * /       ####        #####    ##        ##/   ###   ###   ##/   ##        #### ###      /    ###        ###          
 * #                                                                              ###     #                            
 *  ##          # #    ####    ##   #####  ###### #    # #   #             #####   ###     ##                          
 *             #   #  #    #  #  #  #    # #      ##  ##  # #            /#######  /#                                  
 *            #     # #      #    # #    # #####  # ## #   #            /      ###/                                    
 *            ####### #      ###### #    # #      #    #   #   
 *            #     # #    # #    # #    # #      #    #   #                                       
 *            #     #  ####  #    # #####  ###### #    #   #   
 *
 * Where education, community and opportunities go hand in hand.
 * https://www.definityfi.io
 * Start your education today!                                                          
 */

pragma solidity 0.8.4;

import './BonusHandlerABI.sol';

contract BonusPayout {
  BonusHandlerABI internal b_handle;

  address internal owner;
  address internal payoutHandler;

  modifier isOwner(address _addr) {
    require(owner == _addr, "E5");
    _;
  }

  modifier canInitiatePayout(address _addr) {
    require(owner == _addr || payoutHandler == _addr, "E5");
    _;
  }

  constructor(BonusHandlerABI _addr) {
    owner = msg.sender;
    b_handle = _addr;
  }

  fallback() external payable {
  }

  receive() external payable {
  }
  
  function getSystemBalance() external view canInitiatePayout(msg.sender) returns (uint) {
    return address(this).balance;
  }
  
  function initiatePayout() external payable canInitiatePayout(msg.sender) {
    b_handle.createPayout{value:address(this).balance, gas: 6500000 }();
  }

  function setPayoutHandler(address _addr) external isOwner(msg.sender) {
    payoutHandler = _addr;
  }
}