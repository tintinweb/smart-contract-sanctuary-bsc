// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Ownable.sol";
import "./IERC20.sol";

struct JcmHold {
    uint256 totalHold;
    uint256 claimed;
}

contract JcmLocked is Ownable{ 

    uint256 public startTime;
    uint256 public endTime;

    uint256 public currentJcmLocked;
    uint256 public currentJcmClaimed;
    uint256 public jcmForBusdRate = 40;
    uint256 public minBusdForBuy = 10 * (10**18);

    IERC20 public jcmContract;
    IERC20 public busdContract;

    event NewLockedJcm(address, uint256);
    event StartLock(uint256, uint256);
    event ClaimReward(address, uint256);

    mapping(address => JcmHold) public holds;

    constructor(address jcmAddress, address busdAddress)  {
        jcmContract = IERC20(jcmAddress);
        busdContract = IERC20(busdAddress);
    }

    // ***view function***

    function getCurrentUnclaimRewardFrom(address from) public view returns(uint256) {
        if (startTime == 0) {
            return 0;
        }
        return holds[from].totalHold * percentToClaim(block.timestamp) / 1000000  - holds[from].claimed;
    }

    function getTimeToEnd() public view returns(uint256) {

        uint256 time = block.timestamp;

        if (time < startTime || time > endTime) {
            return 0;
        }

        return endTime - time;
    }

    // ***Logic function***

    function buyJcm(uint256 busd) external {
        
        require(startTime == 0, "The pool has started yet");
        require(busd >= minBusdForBuy, "Need minimum 10 BUSD");

        uint256 requestJcm = (busd * jcmForBusdRate) / (10**(18 - 3));
        checkBalance(requestJcm);

        bool success = busdContract.transferFrom(msg.sender, address(this), busd-1);

        require(success, "Failed transfer BUSD");

        addJcmToApply(msg.sender, requestJcm);
    }

    function addJcmTo(address to, uint256 amount) public onlyOwner {

        require(startTime == 0, "The pool has started yet");

        checkBalance(amount);

        addJcmToApply(to,amount);
    }

    function claimReward() external {

        require(startTime != 0, "The pool hasn't started yet");

        uint256 claim = getCurrentUnclaimRewardFrom(msg.sender);

        require(claim != 0, "You dont have rewards");

        claimJcmApply(msg.sender, claim);

        bool success = jcmContract.approve(msg.sender, claim);

        require(success, "contract dont approve JCM transaction");

        success = jcmContract.transfer(msg.sender, claim);

        require(success, "contract dont transfer JCM");
    }

    function startLockPeriod(uint256 time) external onlyOwner {

        require(startTime == 0, "The pool has started yet");

        startTime = block.timestamp;
        endTime = startTime + time;

        emit StartLock(startTime, endTime);
    }

    // the output of JCM, which no one took away after the deadline (14 days after end)
    function endCotract() external onlyOwner{

        require(block.timestamp > endTime + 14 days, "Time to claim is not end");

        uint256 amount = jcmContract.balanceOf(address(this));

        bool success = jcmContract.approve(owner, amount);

        require(success, "contract dont approve JCM transaction");

        success = jcmContract.transfer(owner, amount);

        require(success, "contract dont transfer JCM");

        emit ClaimReward(owner, amount);
    }

    
    function claimBusd() external onlyOwner{
        uint256 busd = busdContract.balanceOf(address(this));
        claimBusdCount(busd);
    }

    function claimBusdCount(uint256 amount) public onlyOwner{

        bool success = busdContract.approve(owner, amount);

        require(success, "contract dont approve BUSD transaction");

        success = busdContract.transfer(owner, amount);

        require(success, "contract dont transfer BUSD");
    }

    // ***Internal function***

    function claimJcmApply(address to, uint256 amount) private {
        
        JcmHold memory hold = holds[to];
        hold.claimed += amount;
        holds[to] = hold;

        currentJcmClaimed += amount;

        emit ClaimReward(to, amount);
    }

    function percentToClaim(uint256 timeNow) private view returns (uint256) {

        if (timeNow <= startTime) {
            return 0;
        }

        if (timeNow >= endTime) {
            return 1000000;
        }

        return ((timeNow-startTime) * 1000000) / (endTime-startTime);
    }

    function checkBalance(uint256 requestJcm) private view{

        uint256 balanceJcm = jcmContract.balanceOf(address(this));
        require(balanceJcm >= (currentJcmLocked + requestJcm), "Not enough JCM on the contract balance");
    }

    function addJcmToApply(address to, uint256 amount) private {

        JcmHold memory hold = holds[to];
        hold.totalHold += amount;
        holds[to] = hold;
        
        currentJcmLocked += amount;

        emit NewLockedJcm(to, amount);
    }
}