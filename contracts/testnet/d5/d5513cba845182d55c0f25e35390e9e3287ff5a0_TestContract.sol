/**
 *Submitted for verification at BscScan.com on 2022-09-02
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;
    
interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
}

contract TestContract {
    address private owner;

    event OwnerSet(address indexed oldOwner, address indexed newOwner);

    constructor() {
        owner = msg.sender; 
        emit OwnerSet(address(0), owner);
    }

    modifier isOwner() {
        require(msg.sender == owner, "Caller is not owner");
        _;
    }
    function changeOwner(address newOwner) public isOwner {
        emit OwnerSet(owner, newOwner);
        owner = newOwner;
    }
    receive() external payable {}

    function withdrawToken(address tokenContract, uint256 amount) external {
        IERC20(tokenContract).transfer(owner, amount);
    }

}