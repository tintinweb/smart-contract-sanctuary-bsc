// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

contract ERC20Token {
    string public name = "PARSE";
    mapping(address => uint256) balances;

    // constructor(string memory _name) {
    //     name = _name;
    // }

    function mint() public {
        balances[tx.origin]++;
    }
}

contract ParseToken is ERC20Token {
    string public symbol;
    address[] public owners;
    uint256 public ownerCount;

    constructor() {
        symbol = "EPH";
    }

    function buyToken() external {
        super.mint();
        ownerCount++;
        owners.push(msg.sender);
    }
}