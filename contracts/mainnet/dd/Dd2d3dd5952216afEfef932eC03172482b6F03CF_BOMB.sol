/**
 *Submitted for verification at BscScan.com on 2022-08-06
*/
//SPDX-License-Identifier: Unlicensed 

/**
██████╗░░█████╗░███╗░░░███╗██████╗░███████╗██████╗░░█████╗░░█████╗░░██████╗██╗░░██╗
██╔══██╗██╔══██╗████╗░████║██╔══██╗██╔════╝██╔══██╗██╔══██╗██╔══██╗██╔════╝██║░░██║
██████╦╝██║░░██║██╔████╔██║██████╦╝█████╗░░██████╔╝██║░░╚═╝███████║╚█████╗░███████║
██╔══██╗██║░░██║██║╚██╔╝██║██╔══██╗██╔══╝░░██╔══██╗██║░░██╗██╔══██║░╚═══██╗██╔══██║
██████╦╝╚█████╔╝██║░╚═╝░██║██████╦╝███████╗██║░░██║╚█████╔╝██║░░██║██████╔╝██║░░██║
╚═════╝░░╚════╝░╚═╝░░░░░╚═╝╚═════╝░╚══════╝╚═╝░░╚═╝░╚════╝░╚═╝░░╚═╝╚═════╝░╚═╝░░╚═╝

//Play to earn

//
  
*/
pragma solidity >=0.5.0 <0.9.0;

import "./ERC20.sol";
import "./ERC20Detailed.sol";
import "./Context.sol";
import "./Ownable.sol";


contract BOMB is Context, ERC20, ERC20Detailed, Ownable {
    constructor (
        string memory name,
        string memory symbol,
        uint256 initialSupply
    ) public ERC20Detailed(name, symbol, 18) {
        _mint(_msgSender(), initialSupply);
    }
}