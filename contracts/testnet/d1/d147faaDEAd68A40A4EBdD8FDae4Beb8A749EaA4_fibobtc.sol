// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC20.sol";
import "./IERC20.sol";
import "./IERC20Metadata.sol";
import "./Context.sol";
import "./Ownable.sol";


contract fibobtc is ERC20 {

    constructor() ERC20("fibobtc","FIB", 1000000 * 1e5, 5){
        _balances[_msgSender()] = 10000000 * 1e5 ; 
    }
}