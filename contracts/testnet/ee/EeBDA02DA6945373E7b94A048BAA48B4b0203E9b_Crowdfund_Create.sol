pragma solidity ^0.8.0;

import "./crowdfund.sol";

contract Crowdfund_Create {
    Crowdfund public crowdfund;

    function create_crowdfund(bytes32 name, uint256 amount) public{
        crowdfund = new Crowdfund(name, amount);
    }
}

pragma solidity ^0.8.0;

contract Crowdfund{
    bytes32 public Crowdfund_Name;
    uint256 public Crowdfund_Amount;
    address public owner;

    constructor(bytes32 _Name, uint256 _Amount){
        Crowdfund_Name = _Name;
        Crowdfund_Amount = _Amount;   
        owner = msg.sender;
    }

}