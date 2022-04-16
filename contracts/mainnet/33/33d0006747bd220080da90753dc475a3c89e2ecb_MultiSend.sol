/**
 *Submitted for verification at BscScan.com on 2022-04-16
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

interface IERC20Token {
    function balanceOf(address owner) external returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function decimals() external returns (uint256);
}


contract Owned {
    address public owner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address payable _newOwner) public onlyOwner {
        require(_newOwner != address(0), "ERC20: sending to the zero address");
        owner = _newOwner;
        emit OwnershipTransferred(msg.sender, _newOwner);
    }
}


contract MultiSend is Owned {
    function multisend(address _tokenAddr, address[] memory dests, uint256[] memory values) external onlyOwner
    returns (uint256) {
        uint256 i = 0;
        while (i < dests.length) {
            IERC20Token(_tokenAddr).transfer(dests[i], values[i]);
            i += 1;
        }
        return(i);
    }
}