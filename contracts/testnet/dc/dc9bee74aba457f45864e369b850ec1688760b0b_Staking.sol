/**
 *Submitted for verification at BscScan.com on 2023-02-10
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function transferFrom(
            address from,
            address to,
            uint256 amount
        ) external returns (bool);
}

contract Staking {
        address internal _owner;
        address public gaming_token_address;
        uint256 public amount;

        struct Gamers {
           uint256 status;
           uint256 lastgame;
        }
        mapping(address => Gamers) public farmers;

        uint256 public queue_1_last;
        uint256 public queue_1_first;
        struct Queue_1 {
            address gamer;
            bool status;
        }
        mapping(uint256 => Queue_1) public queue_1;
        

        uint256 public queue_2_last;
        uint256 public queue_2_first;
        struct Queue_2 {
            address gamer;
            bool status;
        }
        mapping(uint256 => Queue_2) public queue_2;
      
        
        
        constructor(address _gaming_token_address, uint256 _amount) {
            amount = _amount;
            _owner = msg.sender;
            gaming_token_address = _gaming_token_address;
        }

        modifier onlyOwner() {
            require(_owner == msg.sender, "Ownable: caller is not the owner");
            _;
        }

        function game(uint outcome) public {
            require(outcome < 2, "outcome out range");
            require(IERC20(gaming_token_address).allowance(msg.sender, address(this)) > 0, "game token consumption not allowed");
            //address user = msg.sender;
            
            // outcome #1
            if (outcome == 1) {
            //game immediately
     
            address user = msg.sender;
            //queuing        
           
            
            // outcome #2        
            } else {

            }
                      
           
            


        }

        function random() public view virtual returns(uint){
            uint randomInt = uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp)));
            randomInt = randomInt % 2;
            return randomInt;
        }

}