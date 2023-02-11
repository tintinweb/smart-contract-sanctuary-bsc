/**
 *Submitted for verification at BscScan.com on 2023-02-11
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

contract TossGame {
        address internal _owner;
        address public g_t_address; //gaming_token_address
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
        
        
        constructor(address _g_t_address, uint256 _amount) {
            amount = _amount;
            _owner = msg.sender;
            g_t_address = _g_t_address;
        }

        modifier onlyOwner() {
            require(_owner == msg.sender, "Ownable: caller is not the owner");
            _;
        }

        function game(uint outcome) public {
            require( 0 < outcome && outcome < 3, ": Outcome out range");
            require(IERC20(g_t_address).allowance(msg.sender, address(this)) > amount, ": Game token consumption not allowed");
            require(IERC20(g_t_address).balanceOf(msg.sender) > amount, ": Your game token balance is insufficient");
            address this_gamer = msg.sender;
            uint result = random() + 1;
            
            // outcome == #1
            if (outcome == 1) {
                //game immediately?  
                if(queue_2[queue_2_first].status) {
                    address second_gamer =  queue_2[queue_2_first].gamer;
                    // msg.sender == winer?
                    if (result == outcome) {
                        //выплачиваем победителю
                        IERC20(g_t_address).transferFrom(second_gamer, this_gamer, amount);
                        //убираем второго игрока из очереди как неактивного
                        queue_2[queue_2_first].status = false;
                        //двигаем очередь следующего претендента на игру
                        queue_2_first++;
                    } else {
                        IERC20(g_t_address).transferFrom(this_gamer, second_gamer, amount);
                        queue_2[queue_2_first].status = false;
                        queue_2_first++;
                    }
                   
                //queuing: 
                } else {
                    //поставили в очередь и увеличили значение ласт на 
                    queue_1[queue_1_last].status = true;
                    queue_1[queue_1_last].gamer = this_gamer;
                    queue_1_last++;
                }
            // outcome == #2        
            } else {
                //game immediately?  
                if(queue_1[queue_1_first].status) {
                    address second_gamer =  queue_1[queue_1_first].gamer;
                    // msg.sender == winer?
                    if (result == outcome) {
                        //выплачиваем победителю
                        IERC20(g_t_address).transferFrom(second_gamer, this_gamer, amount);
                        //убираем второго игрока из очереди как неактивного
                        queue_1[queue_1_first].status = false;
                        //двигаем очередь следующего претендента на игру
                        queue_1_first++;
                    } else {
                        IERC20(g_t_address).transferFrom(this_gamer, second_gamer, amount);
                        queue_1[queue_1_first].status = false;
                        queue_1_first++;
                    }
                   
                //queuing: 
                } else {
                    //поставили в очередь и увеличили значение ласт на 
                    queue_2[queue_2_last].status = true;
                    queue_2[queue_2_last].gamer = this_gamer;
                    queue_2_last++;
                }
            }
        }

        function random() public view virtual returns(uint){
            uint randomInt = uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp)));
            randomInt = randomInt % 2;
            return randomInt;
        }

}