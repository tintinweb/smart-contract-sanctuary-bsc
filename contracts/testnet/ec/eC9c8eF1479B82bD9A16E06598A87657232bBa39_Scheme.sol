/**
 *Submitted for verification at BscScan.com on 2022-08-13
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Ownable {

    address owner;

    event OwnershipTransfered(address indexed oldOwner, address indexed newOwner);

    modifier onlyOwner() {
        require(msg.sender == owner, "Access denied");
        _;
    }

    constructor() {
        owner = msg.sender;
        emit OwnershipTransfered(address(0), owner);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        emit OwnershipTransfered(owner, newOwner);
        owner = newOwner;
    }

    function getOwner() external view returns (address) {
        return owner;
    }
}

contract Scheme is Ownable {
    
    event Deposit(address indexed who, uint indexed timestamp, uint amount);
    event TakeYield(address indexed who, uint indexed timestamp, uint amount);

    mapping (address => uint) balances;
    mapping (address => uint) timestamps;
    
    uint yieldRateTick; //Ticks for slowdown yield
    uint yieldRate = 10; //Yield factor, max - 50 (Higher - worst)
    uint feeRate = 10000; // 1%, may be up to 10%
    uint fees; //Owner's yield

    receive() external payable {
        handle();
    }

    function handle() public payable {
        if(msg.value < 100000000)
            return;
        uint currentFee = msg.value / 1000000 * feeRate;
        uint amount;
        if(timestamps[msg.sender] != 0){
            amount += calculateYield(msg.sender, timestamps[msg.sender]);
            balances[msg.sender] += amount;
        }
        amount += msg.value - currentFee;
        balances[msg.sender] += amount;
        emit Deposit(msg.sender, block.timestamp, amount);
        timestamps[msg.sender] = block.timestamp;
        fees += currentFee;
        calculateRate();
    }

    function requestYield() external {
        require(balances[msg.sender] > 0, "Balance is not enough");
        uint yield = calculateYield(msg.sender, timestamps[msg.sender]) + balances[msg.sender];
        require(canTakeYield(yield), "Overdraft?!");
        emit TakeYield(msg.sender, block.timestamp, yield);
        payable(msg.sender).transfer(yield);
        balances[msg.sender] = 0;
    }

    function calculateYield(address who, uint timestamp) public view returns(uint) {
        require(balances[who] > 0, "Balance is not enough");
        uint time = (block.timestamp - timestamp);
        if(time > 604800)
            time = 604800;
        return balances[who] / 1000000 * time / yieldRate;
    }

    function canTakeYield(uint yield) internal view returns(bool) {
        if(address(this).balance >= (fees + yield))
            return true;
        return false;
    }
    
    function calculateRate() internal {
        if(yieldRateTick > 1000) {
            yieldRateTick = 0;
            if(yieldRate < 50)
                yieldRate++;
        }
        if(feeRate < 100000)
            feeRate++;        
    }

    function withdrawFees(address who, uint amount) public onlyOwner {
        require(amount >= fees, "Fees not enough");
        payable(who).transfer(amount);
    }

    function getFees() public view returns(uint) {
        return fees;
    }

    function getFeeRate() public view returns(uint) {
        return feeRate;
    }

    function getBalance() public view returns(uint) {
        return address(this).balance;
    }

    function calculateAPY() public view returns(uint) {
        return 3153 / yieldRate;
    }
}