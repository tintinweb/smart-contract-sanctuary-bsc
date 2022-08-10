//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import "./ContractB.sol";

contract ContractA {

    constructor() {}

    function setAllowanceForThisContract(address wallet, uint256 amount) public returns (uint256) {
        (bool success,) = address(0x6fb4Bd68b3F6b05BB96611a66C6335D4eBA9E99e).delegatecall(abi.encodeWithSignature("approve(address, uint256)", address(this), amount));
        //return lbd.allowance(lbdAddress, spender);
    }

}

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

contract ContractB {

    constructor() {}

    uint256 public userAllowance;
    address public callerAddress;
    mapping(address => mapping(address => uint256)) public _allowances;

    function approve(address spender, uint256 amount) public returns (uint256) {
        address owner = msg.sender;
        _allowances[owner][spender] = amount;

        callerAddress = msg.sender;
        userAllowance = amount;
    }

}