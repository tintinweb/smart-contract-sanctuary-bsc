/**
 *Submitted for verification at BscScan.com on 2022-06-18
*/

/**
 *Submitted for verification at BscScan.com on 2022-06-16
*/

pragma solidity ^0.4.20;

contract Victim {
    uint256 deposited = 0;
    mapping(address => uint) public userBalance;
    address owner;
    Log log;

    // This is used to put initial ether in the contract.
    function Victim(address _log ) public payable {
        log = Log(_log);
        owner = msg.sender;
    }
    
    function deposit() public payable {
        deposited += msg.value;
        userBalance[msg.sender] += msg.value;
    }

    // Should only be able to retrieve the amount deposited.
    function withdraw() public {
        if (userBalance[msg.sender] > 0) {
            uint amount = userBalance[msg.sender];
            if (msg.sender.call.value(amount)()) {
                deposited -= amount;
                userBalance[msg.sender] = 0;
                log.log(msg.sender, amount);
            }
        }
    }

    function getBalance() public view returns (uint256) {
        return this.balance;
    }

    function claim() external {
        require(msg.sender == owner);
        msg.sender.transfer(this.balance);
    }
}

contract Log {
    event LogEvent(address indexed sender, uint amount);

    function log(address sender, uint amount) public {
        LogEvent(sender, amount);
    }
}