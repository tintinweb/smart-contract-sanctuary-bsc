//SPDX-License-Identifier: Unlicensed 

pragma solidity >=0.5.0 <0.9.0;

import "./ERC20.sol";
import "./ERC20Detailed.sol";
import "./Context.sol";

contract HGToken is Context, ERC20, ERC20Detailed {
    constructor (
        string memory name,
        string memory symbol,
        uint256 initialSupply
    ) public ERC20Detailed(name, symbol, 18) {
        _mint(_msgSender(), initialSupply);
    }
}