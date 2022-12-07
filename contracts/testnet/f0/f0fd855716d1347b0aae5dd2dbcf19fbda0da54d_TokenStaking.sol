/**
 *Submitted for verification at BscScan.com on 2022-12-07
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor(address newOwner) {
        _setOwner(newOwner);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) internal {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }
}

contract TokenStaking is Ownable {
    using SafeMath for uint256;
    IERC20 public token;
    uint256 public DailyEarning = 50;
    uint256 public depositeTax = 0;
    uint256 public unStakeTax = 20;
    address public treasuryWallet;
    address public devWallet;
    address marketingWallet;

    constructor() Ownable(msg.sender) {
        treasuryWallet = 0x68e1b506f5211D4913fCef18Ba19d64908111A77;
        devWallet = 0x1Fb0C631dF78c4Bb723e293D04d687bc0cEfc869;
        marketingWallet = 0xE99650448Fa274c929cfCC45dC283986E23f4c73;
        token = IERC20(0x4b7DdF374E02F5F3dbB2597cBE1C6b786A3d9596);
    }

    function addToken(address _token) public onlyOwner {
        token = IERC20(_token);
    }

    function setTax(uint256 withdrawfees, uint256 dipositefees)
        public
        onlyOwner
    {
        require(
            withdrawfees >= 0 && withdrawfees <= 20,
            "you can set withdraw fees maximum 20 %"
        );
        require(
            dipositefees >= 0 && dipositefees <= 20,
            "you can set diposite fees maximum 20 %"
        );
        depositeTax = dipositefees;
        unStakeTax = withdrawfees;
    }

    function getContractBalacne() public view returns (uint256) {
        return token.balanceOf(address(this));
    }

    function setDailyEarning(uint256 _earninig) public onlyOwner {
        require(_earninig >= 50 && _earninig <= 100, "you have out of limit");
        DailyEarning = _earninig;
    }

    function setWallet(address _treasury, address _devWallet) public onlyOwner {
        require(
            _treasury != address(0),
            "treasury address is the zero address."
        );
        require(
            _devWallet != address(0),
            "devWallet address is the zero address."
        );
        treasuryWallet = _treasury;
        devWallet = _devWallet;
    }

    struct boost {
        address userAddress;
        uint256 ratePerDay;
        uint256 boostTime;
        uint256 boostDuration;
        uint256 boostAmount;
    }

    struct user {
        boost boostlaval;
        uint256 depositeAmount;
        address refferaladdress;
        uint256 refferReward;
        uint256 userStoreReward;
        uint256 timeForCalculateReward;
        uint256 withdrawReward;
        uint256 checkTime;
        uint256 lastWithdrawReward;
    }
    mapping(address => user) public investment;

    address[] total_users;

    function invest(uint256 _amount, address refferAddress) public {
        user storage users = investment[msg.sender];
        require(_amount >= 20 ether, "Please stake the minimum 20 BUSD token");
        require(
            _amount <= token.allowance(msg.sender, address(this)),
            "Insufficient Allowence to the contract"
        );

        if (checkNewUser() != true) {
            total_users.push(msg.sender);
        }
        users.userStoreReward += calculateReward(msg.sender);
        uint256 treasuryTax = _amount.mul(6).div(100);
        uint256 marketTax = _amount.mul(5).div(100);
        uint256 devTax = _amount.mul(4).div(100);
        uint256 depoditeTax = _amount.mul(depositeTax).div(100);
        token.transferFrom(msg.sender, devWallet, devTax);
        token.transferFrom(
            msg.sender,
            treasuryWallet,
            treasuryTax.add(depoditeTax)
        );
        token.transferFrom(msg.sender, marketingWallet, marketTax);
        token.transferFrom(
            msg.sender,
            address(this),
            _amount.sub(treasuryTax.add(marketTax).add(devTax))
        );
        if (refferAddress == address(0) || refferAddress == msg.sender) {
            investment[msg.sender].refferaladdress = treasuryWallet;
        } else {
            investment[msg.sender].refferaladdress = refferAddress;
        }
        users.depositeAmount += _amount.sub(depoditeTax);
        users.boostlaval.userAddress = msg.sender;
        users.timeForCalculateReward = block.timestamp;
        users.checkTime = block.timestamp;
        users.boostlaval.boostDuration = 0;
        users.boostlaval.boostTime = 0;
        users.boostlaval.ratePerDay = 0;
    }

    function checkBoostAmount() internal {
        user storage users = investment[msg.sender];
        uint256 depositAmount = getUserdipositAddamount(msg.sender);
        users.boostlaval.boostAmount = ((depositAmount.sub(1e18)).mul(25) /
            100e19 +
            1);
    }

    function booster(uint256 count, uint256 mulAmount) public {
        user storage users = investment[msg.sender];
        require(
            users.boostlaval.userAddress == msg.sender,
            "please invest first then you can booster earning"
        );
        require(
            mulAmount <= token.allowance(msg.sender, address(this)),
            "Insufficient Allowence to the contract"
        );
        require(
            users.boostlaval.boostDuration.add(users.boostlaval.boostTime) <
                block.timestamp,
            "please wait some time"
        );
        // checkBoostAmount();
        users.userStoreReward += calculateReward(msg.sender);
        if (count == 1) {
            token.transferFrom(msg.sender, address(this), (mulAmount));
            users.boostlaval.ratePerDay = 25;
        } else if (count == 2) {
            token.transferFrom(msg.sender, address(this), (mulAmount));
            users.boostlaval.ratePerDay = 50;
        } else if (count == 3) {
            token.transferFrom(msg.sender, address(this), (mulAmount));
            users.boostlaval.ratePerDay = 75;
        } else if (count == 4) {
            token.transferFrom(msg.sender, address(this), (mulAmount));
            users.boostlaval.ratePerDay = 100;
        } else if (count == 5) {
            token.transferFrom(msg.sender, address(this), (mulAmount));
            users.boostlaval.ratePerDay = 125;
        } else if (count == 6) {
            token.transferFrom(msg.sender, address(this), (mulAmount));
            users.boostlaval.ratePerDay = 150;
        } else if (count == 7) {
            token.transferFrom(msg.sender, address(this), (mulAmount));
            users.boostlaval.ratePerDay = 175;
        } else if (count == 8) {
            token.transferFrom(msg.sender, address(this), (mulAmount));
            users.boostlaval.ratePerDay = 200;
        }
        users.boostlaval.boostDuration = 1 days;
        users.boostlaval.boostTime = block.timestamp;
        users.timeForCalculateReward = block.timestamp;
    }

    function removeplayer(uint256 indexnum) internal {
        for (uint256 i = indexnum; i < total_users.length - 1; i++) {
            total_users[i] = total_users[i + 1];
        }
        total_users.pop();
    }

    function withdrawToken() public {
        user storage users = investment[msg.sender];
        uint256 duration = block.timestamp - users.checkTime;
        require(duration >= 15 minutes, "Please wait 15 minutes ");
        uint256 addAmount = getUserdipositAddamount(msg.sender);
        require(addAmount > 0, "your deposite is zero");
        uint256 withdrawAmount = addAmount.mul(20).div(100);
        token.transfer(msg.sender, withdrawAmount);
        users.depositeAmount -= withdrawAmount;
        users.userStoreReward = 0;
        users.boostlaval.ratePerDay = 0;
        users.boostlaval.boostTime = 0;
        users.boostlaval.boostDuration = 0;
        users.timeForCalculateReward = block.timestamp;
        users.checkTime = block.timestamp;
    }

    function compound() public {
        user storage users = investment[msg.sender];
        uint256 duration = block.timestamp - users.checkTime;
        require(duration >= 15 minutes, "Please wait 15 minutes");
        uint256 reward = calculateReward(msg.sender).add(users.userStoreReward);
        require(reward > 0, "No rewards found");
        uint256 treasuryTax = reward.mul(10).div(100);
        token.transfer(treasuryWallet, treasuryTax);
        users.depositeAmount += reward.sub(treasuryTax);
        users.timeForCalculateReward = block.timestamp;
        users.lastWithdrawReward = block.timestamp;
        users.checkTime = block.timestamp;
        users.userStoreReward = 0;
        users.boostlaval.boostDuration = 0;
        users.boostlaval.boostTime = 0;
        users.boostlaval.ratePerDay = 0;
        users.boostlaval.boostAmount = 0;
    }

    function claimReward(address _refferraladdress) public {
        user storage users = investment[msg.sender];
        uint256 duration = block.timestamp - users.checkTime;
        require(duration >= 15 minutes, "Please wait 15 minutes");
        uint256 reward = calculateReward(msg.sender).add(users.userStoreReward);
        require(reward > 0, "No rewards found");
        uint256 treasuryTax = reward.mul(10).div(100);
        uint256 refferTax = reward.mul(5).div(100);
        uint256 devTax = reward.mul(5).div(100);
        uint256 leftReward = reward.sub(treasuryTax).sub(refferTax).sub(devTax);
        token.transfer(treasuryWallet, treasuryTax);
        token.transfer(devWallet, devTax);
        if (treasuryWallet == _refferraladdress) {
            token.transfer(users.refferaladdress, refferTax);
        } else {
            investment[_refferraladdress].refferReward += refferTax;
        }
        token.transfer(msg.sender, leftReward);
        users.withdrawReward += leftReward;
        users.lastWithdrawReward = block.timestamp;
        users.timeForCalculateReward = block.timestamp;
        users.userStoreReward = 0;
        users.checkTime = block.timestamp;
        users.boostlaval.ratePerDay = 0;
        users.boostlaval.boostTime = 0;
        users.boostlaval.boostDuration = 0;
    }

    function withdrawRefferalReward() public {
        uint256 totalRefferReward = investment[msg.sender].refferReward;
        require(totalRefferReward > 0, "No refferal rewards found");
        token.transfer(msg.sender, totalRefferReward);
        investment[msg.sender].withdrawReward += totalRefferReward;
        investment[msg.sender].refferReward = 0;
    }

    function reStakeRefferalReward() public {
        user storage users = investment[msg.sender];
        uint256 duration = block.timestamp - users.checkTime;
        require(duration >= 15 minutes, "Please wait 15 minutes");
        uint256 totalRefferReward = investment[msg.sender].refferReward;
        require(totalRefferReward > 0, "No refferal rewards found");
        users.userStoreReward += calculateReward(msg.sender);
        users.boostlaval.ratePerDay = 0;
        users.boostlaval.boostTime = 0;
        users.boostlaval.boostDuration = 0;
        users.boostlaval.boostAmount = 0;
        users.boostlaval.userAddress = msg.sender;
        users.timeForCalculateReward = block.timestamp;
        users.depositeAmount += totalRefferReward;
        if (checkNewUser() != true) {
            total_users.push(msg.sender);
        }
        users.refferReward = 0;
    }

    function getUserdipositAddamount(address _user)
        public
        view
        returns (uint256)
    {
        user memory users = investment[_user];
        return users.depositeAmount;
    }

    function calculateReward(address _user) public view returns (uint256) {
        user memory users = investment[_user];
        uint256 boostedReward = 0;
        uint256 normalReward = 0;

        uint256 depositTimestamp = users.timeForCalculateReward;
        uint256 boostTimestamp = users.boostlaval.boostTime;

        if (boostTimestamp == 0) {
            uint256 normalRewardDuration = block.timestamp - depositTimestamp;
            normalReward = getUserdipositAddamount(_user)
                .mul(DailyEarning)
                .mul(normalRewardDuration)
                .div(1 days);
            normalReward = normalReward.div(10000);
        } else if (
            (block.timestamp - boostTimestamp) <= users.boostlaval.boostDuration
        ) {
            uint256 boostRewardtime = block.timestamp - boostTimestamp;

            boostedReward = getUserdipositAddamount(_user)
                .mul(DailyEarning.add(users.boostlaval.ratePerDay))
                .mul(boostRewardtime)
                .div(1 days);
            boostedReward = boostedReward.div(10000);
        } else if (
            (block.timestamp - boostTimestamp) >
            users.boostlaval.boostDuration &&
            boostTimestamp != 0
        ) {
            uint256 normalRewardtime = block.timestamp -
                boostTimestamp -
                users.boostlaval.boostDuration;
            boostedReward = getUserdipositAddamount(_user)
                .mul(DailyEarning.add(users.boostlaval.ratePerDay))
                .mul(users.boostlaval.boostDuration)
                .div(1 days);
            boostedReward = boostedReward.div(10000);
            normalReward = getUserdipositAddamount(_user)
                .mul(DailyEarning)
                .mul(normalRewardtime)
                .div(1 days);
            normalReward = normalReward.div(10000);
        }
        return (boostedReward + normalReward);
    }

    function userStoreRewards(address _user) public view returns (uint256) {
        return investment[_user].userStoreReward;
    }

    function minimumWithdrawDuration(address _user)
        public
        view
        returns (uint256)
    {
        uint256 check15days = investment[_user].checkTime + 15 minutes;
        return check15days;
    }

    function userRefferAddress(address _user) public view returns (address) {
        return investment[_user].refferaladdress;
    }

    function getUserTotalRefferalRewards(address _user)
        public
        view
        returns (uint256)
    {
        return investment[_user].refferReward;
    }

    function getUserTotalWithdrawRewards(address _user)
        public
        view
        returns (uint256)
    {
        return investment[_user].withdrawReward;
    }

    function getUserlastWithdrawRewardTime(address _user)
        public
        view
        returns (uint256)
    {
        return investment[_user].lastWithdrawReward;
    }

    function currentRate(address _user) public view returns (uint256) {
        return DailyEarning.add(investment[_user].boostlaval.ratePerDay);
    }

    function getUserBoosterAmount(address _user) public view returns (uint256) {
        return investment[_user].boostlaval.boostAmount;
    }

    function getUserBoostTimestamp(address _user)
        public
        view
        returns (uint256)
    {
        user memory users = investment[_user];
        return users.boostlaval.boostTime + users.boostlaval.boostDuration;
    }

    function checkNewUser() public view returns (bool) {
        for (uint256 i = 0; i < total_users.length; i++) {
            if (total_users[i] == msg.sender) {
                return true;
            }
        }
        return false;
    }

    function totalPlayer() public view returns (uint256) {
        return total_users.length;
    }
}