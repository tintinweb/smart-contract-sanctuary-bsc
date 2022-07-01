/**
 *Submitted for verification at BscScan.com on 2022-07-01
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }


    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract TimelockLedger {
    struct Message {
        address sender;
        uint amount;
        string data;
        uint createdAt;
    }

    Message[] public entries;
    Message lastEntry;

    function log(uint _amount, string memory _data) public {
        lastEntry.sender    = msg.sender;
        lastEntry.amount    = _amount;
        lastEntry.data      = _data;
        lastEntry.createdAt = block.timestamp;
        entries.push(lastEntry);
    }
}

contract TimeLock {
    using SafeMath for uint;

    uint min = 0.5 ether;

    TimelockLedger console;

    mapping(address => uint) balances;
    mapping(address => uint) lockTime;

    constructor(address _console) {
        console = TimelockLedger(_console);
    }

    receive() external payable {
        deposit(7 days);
    }

    function deposit(uint _seconds) public payable {
        require(msg.value >= min, 'deposit at leat 0.5 ether');

        balances[msg.sender] += msg.value;
        lockTime[msg.sender] = block.timestamp + _seconds;
    
        console.log(msg.value, 'deposit');
    }

    function increaseLockTime(uint _secondsToIncrease) public {
        lockTime[msg.sender] = lockTime[msg.sender].add(_secondsToIncrease);
        console.log(_secondsToIncrease, 'increaseLockTime');
    }

    function withdraw(uint _amount) public {
        uint balance = balances[msg.sender];

        require(balance >= _amount, 'insufficient funds');
        require(block.timestamp > lockTime[msg.sender], 'lock time has not expired');

        (bool sent, ) = msg.sender.call{ value: _amount }('');
        require(sent, 'failed to send ether');

        uint amountAfterWithdraw = balance.sub(_amount);
        balances[msg.sender] = amountAfterWithdraw;

        console.log(_amount, 'withdraw');
    }

    function balanceOf(address _address) external view returns (uint256) {
        return balances[_address];
    }

    function lockTimeOf(address _address) external view returns (uint256) {
        return lockTime[_address];
    }
}