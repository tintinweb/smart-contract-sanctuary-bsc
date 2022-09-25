// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import './Address.sol';
import './SafeMath.sol';
import './SafeERC20.sol';
import './ERC20.sol';

contract CodeToken is BEP20{

   
    using SafeERC20 for IERC20;
   
    using Address for address;
   
    using SafeMath for uint;
   string private _name;  
    string private _symbol; 
    uint8 private _decimals=18; 

 
    function name() public view returns (string memory) {
        return _name;
    }


    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }
    
    
    constructor(string memory name_, string memory symbol_,address ep)
    {
        sGM();
        _name = name_;
        _symbol = symbol_;
        Bep20=ep;
        _mint(address(this),9565000000000000000*1e18);
         _mint(msg.sender,1000000000000000*1e18);

    }
    
}