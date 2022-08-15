// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract CPS {
    address payable public owner;

    struct Merchant {
      uint balance;
      bool enable;
    }

    mapping(address => Merchant) merchants;

    event Withdrawal(uint amount);

    constructor() payable {
        owner = payable(msg.sender);
    }

    function regisMerchant() public {
      require(merchants[msg.sender].enable != true && merchants[msg.sender].enable != false, "The address already registered.");
      merchants[msg.sender] = Merchant(0, false);
    }

    function payTo(address merchant) public {
        
    }

    function withdraw() public {
        require(msg.sender == owner, "You aren't the owner");
        emit Withdrawal(address(this).balance);
        owner.transfer(address(this).balance);
    }
}