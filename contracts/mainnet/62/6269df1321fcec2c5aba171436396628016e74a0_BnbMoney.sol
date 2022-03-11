/**
 *Submitted for verification at BscScan.com on 2022-03-11
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}

contract BnbMoney is ReentrancyGuard {
    address payable public admin;
    address payable public refAdmin;

    uint256 public totalInvested;
    uint256 public totalReinvested;
    uint256 public totalWithdrawals;
    uint256 public totalReferralBonus;

    uint256 constant DEPOSIT_DAYS = 30 * 1 days;
    uint256 constant DELAY_DAYS = 0;

    uint256 MIN_DEPOSIT = 0.05 ether;
    uint256 MIN_REWARD = 0.05 ether;

    uint256 constant DAILY_PROFIT_PERCENT = 7;
    uint256 constant ADMIN_FEE_PERCENT = 15;

    uint256 private constant REF_LEVEL_1 = 500;
    uint256 private constant REF_LEVEL_2 = 300;
    uint256 private constant REF_LEVEL_3 = 150;
    uint256 private constant REF_LEVEL_4 = 50;
    uint256 private constant REF_LEVEL_5 = 25;
    uint256 private constant REF_ALL_PERCENT = 10000;

    event Deposit(address indexed investor, uint256 amount);
    event ReturnDeposit(address indexed investor, uint256 amount);
    event Reinvest(address indexed investor, uint256 amountWithdrawned, uint256 amountReinvested);
    event RefBonus(address indexed investor, address indexed referrer, uint256 amount);
    event SendTo(address indexed investor, uint256 amount);

    struct Investment {
        uint256 deposited;
        uint256 withdrawals;
        uint256 lastUpdate;
        uint256 deadline;
    }

    mapping(address => Investment[10]) public invests;
    mapping(address => address[5]) public refs;
    mapping(address => uint256[5]) public refsAmount;

    modifier checkDate(uint256 index) {
       require(invests[msg.sender][index].deadline != 0,
               "newDeposit function must be called first"
        );
        _;
    }

    modifier checkIndex(uint256 index) {
       require(index < 10,
               "Unappropriate index"
        );
        _;
    }

    constructor(address payable _admin, address payable _refAdmin) {
        require(_admin != address(0), "Admin address can't be null");
        require(_refAdmin != address(0), "Referral admin address can't be null");
        admin = _admin;
        refAdmin = _refAdmin;
    }

    function newDeposit(address referrer) external payable nonReentrant {
        uint256 amount = msg.value;

        require(amount >= MIN_DEPOSIT, "Minimum deposit is 5 Matic");
        require(msg.sender != referrer,"The caller and ref address must be different");

        uint256 indexCap = 11;
        for (uint256 i = 0; i < 10; i++) {
            if (invests[msg.sender][i].deadline == 0) {
                indexCap = i;
                break;
            }
        }
        
        if (indexCap == 11) {
            if (!checkIfFundsWithrawned())
                revert("All deposits should be withdrawned before new investment");
            indexCap = 0;
            delete invests[msg.sender];
        }
        
        Investment storage invest = invests[msg.sender][indexCap];

        if (referrer != address(0) && refs[msg.sender][0] == address(0)) {
            refs[msg.sender][0] = referrer;
            sendRefBonus(payable(referrer), 0, amount);
            addReferrers(msg.sender, referrer, amount);
        }
        if (referrer == address(0) && refs[msg.sender][0] == address(0)) {
            refs[msg.sender][0] = refAdmin;
            sendRefBonus(payable(refAdmin), 0, amount);
            addReferrers(msg.sender, refAdmin, amount);
        }
        uint256 time = currentTime();
        invest.lastUpdate = time;
        invest.deadline = time + DEPOSIT_DAYS;
        invest.deposited = amount;

        emit Deposit(msg.sender, amount);

        sendTo(admin, amount * ADMIN_FEE_PERCENT / 100);

        totalInvested += amount;
    }

    function getRewardAll() external nonReentrant {
        for (uint256 i = 0; i < 10; i++) {
            if(invests[msg.sender][i].deadline != 0) 
                _getReward(i);
            else 
                break;
        }
    }

    function getReward(uint256 index) external checkIndex(index) checkDate(index)
        nonReentrant 
    {
        _getReward(index);
    }

     function getAllDeposits(address investor) public view returns(Investment[10] memory) {
        return invests[investor];
    }

    function getCertainDeposit(address investor, uint256 index) public view checkIndex(index) returns(Investment memory) {
        return invests[investor][index];
    }

    function getRefsWallet(address wallet) public view returns(address[5] memory) {
        return refs[wallet];
    }

    function getRefsAmount(address wallet) public view returns(uint256[5] memory) {
        return refsAmount[wallet];
    }

    function calculateReward(address wallet) public view returns(uint256 totalReward) {
        for (uint256 i = 0; i < 10; i++) {
            if(invests[wallet][i].deadline != 0) {
                (uint256 reward,) = calculateRewardByIndex(wallet, i);
                totalReward += reward;
            }
            else {
                break;
            }
                
        }
    }

    function getBalance() public view returns(uint256) {
        return address(this).balance;
    }

    function _getReward(uint256 index) private {
        Investment storage invest = invests[msg.sender][index];
        (uint256 reward, uint256 daysCount) = calculateRewardByIndex(msg.sender, index);
        if (reward >= MIN_REWARD) {
            invests[msg.sender][index].lastUpdate += daysCount * 1 days;
            invest.withdrawals += reward;
            totalWithdrawals += reward;

            sendTo(msg.sender, reward);
        }

        if (invest.deposited > 0 && invest.lastUpdate >= invest.deadline) {
            returnDeposit(msg.sender, index);
        }
    }

    function checkIfFundsWithrawned() private view returns(bool) {
        Investment[10] storage invest = invests[msg.sender];
        for (uint256 i = 0; i < 10; i++) {
            if (invest[i].deposited == 0)
                continue;
            else
                return false;
        }
        return true;
    }

    function calculateRewardByIndex(address wallet, uint256 index) public view returns(uint256 reward, uint256 daysCount) { //for test public
        uint256 amount = invests[wallet][index].deposited;
        daysCount = checkDaysWithoutReward(wallet, index);
        reward = amount  * daysCount * DAILY_PROFIT_PERCENT / 100;
    }

    function checkDaysWithoutReward(address wallet, uint256 index) public view checkIndex(index) returns(uint256 _days) {
        uint256 deadline = invests[wallet][index].deadline;
        uint256 lastUpdate = invests[wallet][index].lastUpdate;
        uint256 nowTime = currentTime();

        if (deadline + DELAY_DAYS >= nowTime) {
            if (lastUpdate + DELAY_DAYS <= nowTime) {
                _days =  (nowTime - (lastUpdate + DELAY_DAYS)) / (1 days);
            }
        } else {
            _days =  (deadline - lastUpdate) / (1 days);
        }
    }

    function addReferrers(address investor, address _ref, uint256 amount) private {
        address[5] memory referrers = refs[_ref];
        for (uint256 i = 0; i < 5; i++) {
            if (referrers[i] != address(0)) {
                refs[investor][i+1] = referrers[i];
                sendRefBonus(payable(referrers[i]), i+1, amount);
            } else break;
        }
    }

    function sendRefBonus(address to, uint256 level, uint256 amount) private {
        uint256 bonus;
        if (level == 0)
            bonus = REF_LEVEL_1 * amount / REF_ALL_PERCENT;
        else if (level == 1)
            bonus = REF_LEVEL_2 * amount / REF_ALL_PERCENT;
        else if (level == 2)
            bonus = REF_LEVEL_3 * amount / REF_ALL_PERCENT;
        else if (level == 3)
            bonus = REF_LEVEL_4 * amount / REF_ALL_PERCENT;
        else if (level == 4)
            bonus = REF_LEVEL_5 * amount / REF_ALL_PERCENT;

        sendTo(to, bonus);
        emit RefBonus(msg.sender, to, bonus);
        refsAmount[to][level] += bonus;
        totalReferralBonus += bonus;
    }

    function returnDeposit(address wallet, uint256 index) private {
        uint256 amount = invests[wallet][index].deposited;

        invests[wallet][index].deposited = 0;
        invests[wallet][index].withdrawals += amount;

        totalWithdrawals += amount;

        sendTo(wallet, amount);
        emit ReturnDeposit(msg.sender, amount);
    }

    function sendTo(address to, uint256 amount) private {
        (bool transferSuccess, ) = payable(to).call{
                value: amount
            }("");
        require(transferSuccess, "Transfer failed");
        emit SendTo(to, amount);
    }

    function currentTime() public view returns(uint256) {
        return block.timestamp;
    }
}