/**
 *Submitted for verification at BscScan.com on 2023-02-10
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(
            address from,
            address to,
            uint256 amount
        ) external returns (bool);
}

contract Staking {
        address internal _owner;
        address public gaming_token_address;

        struct Gamers {
           uint256 status;
           uint256 lastgame;
           mapping(uint256 => uint256) historygames;
           //number of game => result
        }

        mapping(address => Gamers) public farmers;
        
        constructor(address _gaming_token_address) {
            _owner = msg.sender;
            gaming_token_address = _gaming_token_address;
        }

        modifier onlyOwner() {
            require(_owner == msg.sender, "Ownable: caller is not the owner");
            _;
        }

        
        



}