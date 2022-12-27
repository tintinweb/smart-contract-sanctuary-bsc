// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import {IERC20} from "./IERC20.sol";

contract DiamondHands {
    
    address owner;
    string note;

    event OwnerUpdated(
        address old,
        address newOwner
    );

    constructor(){
        owner = msg.sender;
    }

    function getOwner() public view returns(address){
            return owner;
    }

    function updateOwner(address newOwner)public{
        require(msg.sender == owner, "DM may deo phai owner!");
        emit OwnerUpdated(owner, newOwner);
        owner = newOwner;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}