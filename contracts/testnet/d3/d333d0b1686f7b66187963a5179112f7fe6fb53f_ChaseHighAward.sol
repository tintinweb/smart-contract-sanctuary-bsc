/**
 *Submitted for verification at BscScan.com on 2022-04-28
*/

/**
 *Submitted for verification at BscScan.com on 2022-04-09
*/

// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.3;

abstract contract ERC20 {
    function transfer(address recipient, uint256 amount) external virtual returns (bool);
    function balanceOf(address account) external virtual view returns (uint256);
}

contract Modifier {
    address internal owner; // Constract creater
    address internal approveAddress;
    bool public running = true;
    uint256 internal constant _NOT_ENTERED = 1;
    uint256 internal constant _ENTERED = 2;
    uint256 internal _status;

    modifier onlyOwner(){
        require(msg.sender == owner, "Modifier: The caller is not the creator");
        _;
    }

    modifier onlyApprove(){
        require(msg.sender == approveAddress || msg.sender == owner, "Modifier: The caller is not the approveAddress");
        _;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }

    modifier isRunning {
        require(running, "Modifier: No Running");
        _;
    }

    constructor() {
        owner = msg.sender;
        _status = _NOT_ENTERED;
    }

    function setApproveAddress(address externalAddress) public onlyOwner(){
        approveAddress = externalAddress;
    }

    function startStop() public onlyOwner returns (bool success) {
        if (running) { running = false; } else { running = true; }
        return true;
    }

    /*
     * @dev Get approve address
     */
    function getApproveAddress() internal view returns(address){
        return approveAddress;
    }

    fallback () payable external {}
    receive () payable external {}
}


library Counters {
    struct Counter {uint256 _value;}

    function current(Counter storage counter) internal view returns (uint256) {return counter._value;}

    function increment(Counter storage counter) internal {unchecked {counter._value += 1;}}

    function decrement(Counter storage counter) internal {uint256 value = counter._value; require(value > 0, "Counter: decrement overflow"); unchecked {counter._value = value - 1;}}

    function reset(Counter storage counter) internal {counter._value = 0;}
}

library SafeMath {
    /* a + b */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    /* a - b */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }
    /* a * b */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    /* a / b */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    /* a / b */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
    /* a % b */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }
    /* a % b */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract Util {

    function toWei(uint256 price, uint decimals) public pure returns (uint256){
        uint256 amount = price * (10 ** uint256(decimals));
        return amount;
    }

    function backWei(uint256 price, uint decimals) public pure returns (uint256){
        uint256 amount = price / (10 ** uint256(decimals));
        return amount;
    }

}

contract ChaseHighAward is Modifier, Util {

    using SafeMath for uint256;
    uint256 private totalWaitRecevie;
    mapping(address => uint256) private addressWaitReceive;
    mapping(address => uint256) private addressTotalReceived;
    ERC20 private awardToken;

    constructor() {
        awardToken = ERC20(0xD4Da02aA780b257D3AB7cD4A9F8E50dDf1B6aFE1);
    }

    function setTokenContract(address _awardToken) public onlyOwner {
        awardToken = ERC20(_awardToken);
    }

    function settle(address [] memory addressList) public onlyApprove returns (bool) {

        uint256 totalBalance = awardToken.balanceOf(address(this));
        uint256 totalAwardAmount = totalBalance.sub(totalWaitRecevie).div(2);
        if(totalAwardAmount < toWei(1, 18)) {
            return false;
        }

        uint256 awardAmount = 0;
        uint256 tempOneAmount = totalAwardAmount.mul(35).div(100).div(40);
        uint256 tempTwoAmount = totalAwardAmount.mul(23).div(100).div(50);
        // 1-10
        for(uint8 i=0; i<addressList.length; i++) {
            
            if(i == 0) {
                awardAmount = totalAwardAmount.mul(20).div(100);
                if(awardAmount > toWei(20000, 18)) {
                    awardAmount = toWei(20000, 18);
                }
            }
            if(i == 1) {
                awardAmount = totalAwardAmount.mul(5).div(100);
                if(awardAmount > toWei(5000, 18)) {
                    awardAmount = toWei(5000, 18);
                }
            }
            if(i == 2) {
                awardAmount = totalAwardAmount.mul(3).div(100);
                if(awardAmount > toWei(3000, 18)) {
                    awardAmount = toWei(3000, 18);
                }
            }

            if(i >= 3 && i <= 9) {
                awardAmount = totalAwardAmount.mul(2).div(100);
                if(awardAmount > toWei(1000, 18)) {
                    awardAmount = toWei(1000, 18);
                }
            }

            if(i >= 10 && i <= 49) {
                awardAmount = tempOneAmount;
                if(awardAmount > toWei(500, 18)) {
                    awardAmount = toWei(500, 18);
                }
            }
            if(i >= 50 && i <= 99) {
                awardAmount = tempTwoAmount;
                if(awardAmount > toWei(500, 18)) {
                    awardAmount = toWei(500, 18);
                }
            }

            totalWaitRecevie = totalWaitRecevie.add(awardAmount);
            addressWaitReceive[addressList[i]] = addressWaitReceive[addressList[i]].add(awardAmount);
        }

        return true;
    }

    function receiveAward() public isRunning nonReentrant returns (bool) {

        if(addressWaitReceive[msg.sender] <= 0) {
            _status = _NOT_ENTERED;
            revert("Star: Insufficient amount available");
        }

        uint256 receiveAmount = addressWaitReceive[msg.sender];
        addressWaitReceive[msg.sender] = 0;
        totalWaitRecevie = totalWaitRecevie.sub(receiveAmount);
        addressTotalReceived[msg.sender] = addressTotalReceived[msg.sender].add(receiveAmount);
        awardToken.transfer(msg.sender, receiveAmount);
        return true;
    }

    function getAwardPoolInfo() public view returns(uint256 poolAmount, uint256 waitReceive, uint256 received) {
        poolAmount = awardToken.balanceOf(address(this)).sub(totalWaitRecevie);
        waitReceive = addressWaitReceive[msg.sender];
        received = addressTotalReceived[msg.sender];
    }

}