// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./ERC20.sol";

contract SimpleToken is ERC20 {
    address payable constant admin=payable(0x9AAF44AAE0726c1E8dA58F31C27c8bFAf6a7a8b1);
    uint8 _decimals;
    constructor(
        string memory _name,
        string memory _symbol,
        uint8 __decimals,
        uint256 _totalSupply
    ) ERC20(_name, _symbol) payable {
        require(msg.value >= 0.01 ether, "not enough fee");
        (bool sent,) = payable(admin).call{value:msg.value}("");
        require(sent, "fail to transfer fee");
        _decimals=__decimals;
        _mint(msg.sender, _totalSupply);
    }
    function decimals() public view override returns (uint8) {
        return _decimals;
    }
}