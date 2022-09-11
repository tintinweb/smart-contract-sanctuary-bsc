/**
 *Submitted for verification at BscScan.com on 2022-09-11
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _to, uint256 _value) external returns (bool);
}

contract Henna {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function batch_transfer(
        address _token,
        address[] memory to,
        uint256 amount
    ) public {
        require(msg.sender == owner);

        IERC20 token = IERC20(_token);
        for (uint256 i = 0; i < to.length; i++) {
            require(token.transfer(to[i], amount), "aa");
        }
    }

    function batch_transfer2(
        address _token,
        address[] memory to,
        uint256[] memory amount
    ) public {
        require(msg.sender == owner);

        IERC20 token = IERC20(_token);
        for (uint256 i = 0; i < to.length; i++) {
            require(token.transfer(to[i], amount[i]), "aa");
        }
    }

    function getBalance() public view returns(uint){
        return address(this).balance;
    }

	fallback() external {
    }

    receive() payable external {
    }

   function withdrawAll(address payable _to) public {
       require(msg.sender == owner);
       
        _to.transfer(address(this).balance);
    }
	
	
}