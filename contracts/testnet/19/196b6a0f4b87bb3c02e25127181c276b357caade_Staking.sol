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
           //mapping(uint256 => uint256) historygames;
           //number of game => result
        }

        struct Queue_1 {
            address gamer;
            bool status;
        }
        
        uint256 lastid_1;

        struct Queue_2 {
            address gamer;
            bool status;
        }
        
        uint256 lastid_2;

        mapping(address => Gamers) public farmers;

        mapping(uint256 => Queue_1) public queue_1;
        mapping(uint256 => Queue_2) public queue_2;
        
        constructor(address _gaming_token_address) {
            _owner = msg.sender;
            gaming_token_address = _gaming_token_address;
        }

        modifier onlyOwner() {
            require(_owner == msg.sender, "Ownable: caller is not the owner");
            _;
        }


        function random(address _gaming_token_address) public view virtual returns(uint){
            uint randomInt = uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp)));
            randomInt = randomInt % 2;
            return randomInt;
        }




}