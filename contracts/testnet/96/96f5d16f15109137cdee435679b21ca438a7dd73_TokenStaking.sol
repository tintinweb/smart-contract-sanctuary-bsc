/**
 *Submitted for verification at BscScan.com on 2022-11-18
*/

/**
 *Submitted for verification at BscScan.com on 2022-10-31
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
    uint256 public depositeTax = 0;
    uint256 public unStakeTax = 20;
    uint256 devTax = 10;
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

    struct deposite {
        uint256 amount;
        uint256 depositeTime;
    }
    struct boost {
        address userAddress;
        uint256 ratePerDay;
        uint256 boostCount;
        uint256 boostTime;
        uint256 boostDuration;
    }

    struct user {
        boost boostlaval;
        deposite[] deposites;
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
        require(_amount > 0, "Please enter greater then value");
        require(
            _amount <= token.allowance(msg.sender, address(this)),
            "Insufficient Allowence to the contract"
        );

        if (checkNewUser() != true) {
            total_users.push(msg.sender);
        }

        if(users.boostlaval.boostTime+users.boostlaval.boostDuration > block.timestamp && (getUserdipositAddamount(msg.sender).add(_amount) <=40 ether )){
            users.userStoreReward += calculateReward(msg.sender);
            users.boostlaval.boostDuration = (users.boostlaval.boostDuration+users.boostlaval.boostTime) - block.timestamp;
            users.boostlaval.boostTime =block.timestamp;
        }
         else if(users.boostlaval.boostTime+users.boostlaval.boostDuration > block.timestamp && (getUserdipositAddamount(msg.sender).add(_amount) > 40 ether && getUserdipositAddamount(msg.sender).add(_amount) <= 80 ether)){
            users.userStoreReward += calculateReward(msg.sender);
            users.boostlaval.boostDuration = (users.boostlaval.boostDuration+users.boostlaval.boostTime) - block.timestamp;
            users.boostlaval.boostTime =block.timestamp;
        } else if(users.boostlaval.boostTime+users.boostlaval.boostDuration > block.timestamp && (getUserdipositAddamount(msg.sender).add(_amount) > 80 ether && getUserdipositAddamount(msg.sender).add(_amount) <= 120 ether)){
            users.userStoreReward += calculateReward(msg.sender);
            users.boostlaval.boostDuration = (users.boostlaval.boostDuration+users.boostlaval.boostTime) - block.timestamp;
            users.boostlaval.boostTime =block.timestamp;
        } else if(users.boostlaval.boostTime+users.boostlaval.boostDuration > block.timestamp && (getUserdipositAddamount(msg.sender).add(_amount) > 120 ether && getUserdipositAddamount(msg.sender).add(_amount) <= 160 ether)){
            users.userStoreReward += calculateReward(msg.sender);
            users.boostlaval.boostDuration = (users.boostlaval.boostDuration+users.boostlaval.boostTime) - block.timestamp;
            users.boostlaval.boostTime =block.timestamp;
        } else if(users.boostlaval.boostTime+users.boostlaval.boostDuration > block.timestamp && getUserdipositAddamount(msg.sender).add(_amount) > 160 ether){
            users.userStoreReward += calculateReward(msg.sender);
            users.boostlaval.boostDuration = (users.boostlaval.boostDuration+users.boostlaval.boostTime) - block.timestamp;
            users.boostlaval.boostTime =block.timestamp;
        }
        else{
           users.userStoreReward += calculateReward(msg.sender);
           users.boostlaval.ratePerDay = 100;
           users.boostlaval.boostCount = 0;
           users.boostlaval.boostTime = 0; 
           users.boostlaval.boostDuration = 0;
           users.boostlaval.userAddress = msg.sender;
           users.timeForCalculateReward = block.timestamp;
        }
        uint256 tax = _amount.mul(devTax).div(100);
        uint256 depoditeTax = _amount.mul(depositeTax).div(100);
        token.transferFrom(msg.sender, devWallet, tax.div(3));
        token.transferFrom(
            msg.sender,
            treasuryWallet,
            tax.div(3).add(depoditeTax)
        );
        token.transferFrom(msg.sender, marketingWallet, tax.div(3));
        token.transferFrom(
            msg.sender,
            address(this),
            _amount.sub(tax.add(depoditeTax))
        );
        if (refferAddress == address(0) || refferAddress == msg.sender) {
            investment[msg.sender].refferaladdress = treasuryWallet;
        } else {
            investment[msg.sender].refferaladdress = refferAddress;
        }
        users.deposites.push(
            deposite(_amount.sub(depoditeTax), block.timestamp)
        );
        
        users.checkTime = block.timestamp;
    }

    function booster(uint256 boostAmount) public {
        user storage users = investment[msg.sender];
        require(
            boostAmount <= token.allowance(msg.sender, address(this)),
            "Insufficient Allowence to the contract"
        );
        require(
            users.boostlaval.userAddress == msg.sender,
            "please invest first then you can booster earning"
        );
        require(
            users.boostlaval.boostCount < 6,
            "Not enough the boost chance."
        );

        uint256 depositAmount = getUserdipositAddamount(msg.sender);
        if (depositAmount > 0 ether && depositAmount <= 40 ether) {
            require(
                boostAmount >= 1 ,
                "Please enter the minimum value 1 token"
            );
            token.transferFrom(msg.sender, address(this), boostAmount);
            users.userStoreReward += calculateReward(msg.sender);
            if (users.boostlaval.boostTime+users.boostlaval.boostDuration > block.timestamp) {
                users.boostlaval.ratePerDay += 25;
                users.boostlaval.boostCount += 1;
                users.boostlaval.boostDuration = 10  minutes;
                users.boostlaval.boostTime = block.timestamp;
            } else {
                users.boostlaval.ratePerDay = 125;
                users.boostlaval.boostCount = 1;
                users.boostlaval.boostDuration = 10  minutes;
                users.boostlaval.boostTime = block.timestamp;
            }
        } else if (depositAmount > 40 ether && depositAmount <= 80 ether) {
            require(
                boostAmount >= 2 ether,
                "Please enter the minimum value 2 token"
            );
            token.transferFrom(msg.sender, address(this), boostAmount);
            users.userStoreReward += calculateReward(msg.sender);
            if (users.boostlaval.boostTime+users.boostlaval.boostDuration > block.timestamp) {
                users.boostlaval.ratePerDay += 25;
                users.boostlaval.boostCount += 1;
                users.boostlaval.boostDuration = 10  minutes;
                users.boostlaval.boostTime = block.timestamp;
            } else {
                users.boostlaval.ratePerDay = 125;
                users.boostlaval.boostCount = 1;
                users.boostlaval.boostDuration = 10  minutes;
                users.boostlaval.boostTime = block.timestamp;
            }
        } else if (depositAmount > 80 ether && depositAmount <= 120 ether) {
            require(
                boostAmount >= 3 ether,
                "Please enter the minimum value 3 token"
            );
            token.transferFrom(msg.sender, address(this), boostAmount);
            users.userStoreReward += calculateReward(msg.sender);
            if (users.boostlaval.boostTime+users.boostlaval.boostDuration > block.timestamp) {
                users.boostlaval.ratePerDay += 25;
                users.boostlaval.boostCount += 1;
                users.boostlaval.boostDuration = 10  minutes;
                users.boostlaval.boostTime = block.timestamp;
            } else {
                users.boostlaval.ratePerDay = 125;
                users.boostlaval.boostCount = 1;
                users.boostlaval.boostDuration = 10  minutes;
                users.boostlaval.boostTime = block.timestamp;
            }
        } else if (depositAmount > 120 ether && depositAmount <= 160 ether) {
            require(
                boostAmount >= 4 ether,
                "Please enter the minimum value 4 token"
            );
            token.transferFrom(msg.sender, address(this), boostAmount);
            users.userStoreReward += calculateReward(msg.sender);
            if (users.boostlaval.boostTime+users.boostlaval.boostDuration > block.timestamp) {
                users.boostlaval.ratePerDay += 25;
                users.boostlaval.boostCount += 1;
                users.boostlaval.boostDuration = 10  minutes;
                users.boostlaval.boostTime = block.timestamp;
            } else {
                users.boostlaval.ratePerDay = 125;
                users.boostlaval.boostCount = 1;
                users.boostlaval.boostDuration = 10  minutes;
                users.boostlaval.boostTime = block.timestamp;
            }
        } else if (depositAmount > 160 ether) {
            require(
                boostAmount >= 5 ether,
                "Please enter the minimum value 5 token"
            );
            token.transferFrom(msg.sender, address(this), boostAmount);
            users.userStoreReward += calculateReward(msg.sender);
            if (users.boostlaval.boostTime+users.boostlaval.boostDuration > block.timestamp) {
                users.boostlaval.ratePerDay += 25;
                users.boostlaval.boostCount += 1;
                users.boostlaval.boostDuration = 10  minutes;
                users.boostlaval.boostTime = block.timestamp;
            } else {
                users.boostlaval.ratePerDay = 125;
                users.boostlaval.boostCount = 1;
                users.boostlaval.boostDuration = 10  minutes;
                users.boostlaval.boostTime = block.timestamp;
            }
        }
    }

    function remove(uint256 index) internal {
        for (
            uint256 i = index;
            i < investment[msg.sender].deposites.length - 1;
            i++
        ) {
            investment[msg.sender].deposites[i] = investment[msg.sender]
                .deposites[i + 1];
        }
        investment[msg.sender].deposites.pop();
    }

    function removeplayer(uint256 indexnum) internal {
        for (
            uint256 i = indexnum;
            i < total_users.length - 1;
            i++
        ) {
            total_users[i] = total_users[i + 1];
        }
        total_users.pop();
    }

    function withdrawToken(uint256 id) public {
        user storage users = investment[msg.sender];
        uint256 duration = block.timestamp -
            users.checkTime;
        require(duration >= 10 minutes, "Please wait sometime ");
        require(id <= users.deposites.length, "Invalid Id");
        uint256 totalAmount = users.deposites[id].amount;
        uint256 withdrawTax = totalAmount.mul(unStakeTax).div(100);
        token.transfer(treasuryWallet, withdrawTax.div(2));
        token.transfer(address(this), withdrawTax.div(2));
        token.transfer(msg.sender, totalAmount.sub(withdrawTax));
        remove(id);
        if (users.boostlaval.boostTime+users.boostlaval.boostDuration > block.timestamp) {
            users.userStoreReward += calculateReward(msg.sender);
            users.boostlaval.boostDuration = (users.boostlaval.boostDuration+users.boostlaval.boostTime) - block.timestamp;
            users.boostlaval.boostTime =block.timestamp;
        }else{

        users.timeForCalculateReward = block.timestamp;
        }
        if(getUserdipositAddamount(msg.sender) <= 0){
        users.boostlaval.userAddress = 0x0000000000000000000000000000000000000000;
        users.boostlaval.ratePerDay = 0;
        users.boostlaval.boostCount = 0;
        users.boostlaval.boostTime = 0;
        users.userStoreReward =  0;
        users.timeForCalculateReward = 0;
        users.refferaladdress = address(this);
        users.refferReward = 0;
           removeplayer(id); 
        }
        users.checkTime = block.timestamp;
    }

    function compound() public {
        user storage users = investment[msg.sender];
        uint256 duration = block.timestamp -
            users.checkTime;
        require(duration >= 10 minutes, "Please wait sometime");
        uint256 reward = calculateReward(msg.sender);
        require(reward > 0, "No rewards found");
        uint256 treasuryTax = reward.mul(10).div(100);
        token.transfer(treasuryWallet, treasuryTax);

        if(users.boostlaval.boostTime+users.boostlaval.boostDuration > block.timestamp && (getUserdipositAddamount(msg.sender).add(reward.sub(treasuryTax)) <=40 ether )){
            users.userStoreReward += calculateReward(msg.sender);
            users.boostlaval.boostDuration = (users.boostlaval.boostDuration+users.boostlaval.boostTime) - block.timestamp;
            users.boostlaval.boostTime =block.timestamp;
        }
         else if(users.boostlaval.boostTime+users.boostlaval.boostDuration > block.timestamp && (getUserdipositAddamount(msg.sender).add(reward.sub(treasuryTax)) > 40 ether && getUserdipositAddamount(msg.sender).add(reward.sub(treasuryTax)) <= 80 ether)){
            users.userStoreReward += calculateReward(msg.sender);
            users.boostlaval.boostDuration = (users.boostlaval.boostDuration+users.boostlaval.boostTime) - block.timestamp;
            users.boostlaval.boostTime =block.timestamp;
        } else if(users.boostlaval.boostTime+users.boostlaval.boostDuration > block.timestamp && (getUserdipositAddamount(msg.sender).add(reward.sub(treasuryTax)) > 80 ether && getUserdipositAddamount(msg.sender).add(reward.sub(treasuryTax)) <= 120 ether)){
            users.userStoreReward += calculateReward(msg.sender);
            users.boostlaval.boostDuration = (users.boostlaval.boostDuration+users.boostlaval.boostTime) - block.timestamp;
            users.boostlaval.boostTime =block.timestamp;
        } else if(users.boostlaval.boostTime+users.boostlaval.boostDuration > block.timestamp && (getUserdipositAddamount(msg.sender).add(reward.sub(treasuryTax)) > 120 ether && getUserdipositAddamount(msg.sender).add(reward.sub(treasuryTax)) <= 160 ether)){
            users.userStoreReward += calculateReward(msg.sender);
            users.boostlaval.boostDuration = (users.boostlaval.boostDuration+users.boostlaval.boostTime) - block.timestamp;
            users.boostlaval.boostTime =block.timestamp;
        } else if(users.boostlaval.boostTime+users.boostlaval.boostDuration > block.timestamp && getUserdipositAddamount(msg.sender).add(reward.sub(treasuryTax)) > 160 ether){
            users.userStoreReward += calculateReward(msg.sender);
            users.boostlaval.boostDuration = (users.boostlaval.boostDuration+users.boostlaval.boostTime) - block.timestamp;
            users.boostlaval.boostTime =block.timestamp;
        }
        else{
           users.userStoreReward += calculateReward(msg.sender);
           users.boostlaval.ratePerDay = 100;
           users.boostlaval.boostCount = 0;
           users.boostlaval.boostTime = 0; 
           users.boostlaval.boostDuration = 0;
           users.boostlaval.userAddress = msg.sender;
           users.timeForCalculateReward = block.timestamp;
        }

        users.deposites.push(
            deposite(reward.sub(treasuryTax), block.timestamp)
        );

        users.lastWithdrawReward = block.timestamp;
        users.checkTime = block.timestamp;
        users.userStoreReward = 0;
    }

    function claimReward(address _refferraladdress) public {
        user storage users = investment[msg.sender];
        uint256 duration = block.timestamp -
            users.checkTime;
        require(duration >= 10 minutes, "Please wait sometime");
        uint256 reward = calculateReward(msg.sender);
        require(reward > 0, "No rewards found");
        uint256 treasuryTax = reward.mul(10).div(100);
        uint256 refferTax = reward.mul(5).div(100);
        uint256 leftReward = reward.sub(treasuryTax).sub(refferTax);
        token.transfer(treasuryWallet, treasuryTax);
        if(treasuryWallet == _refferraladdress){
        token.transfer(users.refferaladdress, refferTax);
        }else{
        investment[_refferraladdress].refferReward += refferTax;
        }
        token.transfer(msg.sender, leftReward);
        users.withdrawReward += leftReward;
        users.lastWithdrawReward = block.timestamp;
        users.timeForCalculateReward = block.timestamp;
        users.userStoreReward = 0;
        
        users.checkTime = block.timestamp;
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
        uint256 totalRefferReward = investment[msg.sender].refferReward;
        require(totalRefferReward > 0, "No refferal rewards found");
        if(users.boostlaval.boostTime+users.boostlaval.boostDuration > block.timestamp && (getUserdipositAddamount(msg.sender).add(totalRefferReward) <=40 ether )){
            users.userStoreReward += calculateReward(msg.sender);
            users.boostlaval.boostDuration = (users.boostlaval.boostDuration+users.boostlaval.boostTime) - block.timestamp;
            users.boostlaval.boostTime =block.timestamp;
        }
         else if(users.boostlaval.boostTime+users.boostlaval.boostDuration > block.timestamp && (getUserdipositAddamount(msg.sender).add(totalRefferReward) > 40 ether && getUserdipositAddamount(msg.sender).add(totalRefferReward) <= 80 ether)){
            users.userStoreReward += calculateReward(msg.sender);
            users.boostlaval.boostDuration = (users.boostlaval.boostDuration+users.boostlaval.boostTime) - block.timestamp;
            users.boostlaval.boostTime =block.timestamp;
        } else if(users.boostlaval.boostTime+users.boostlaval.boostDuration > block.timestamp && (getUserdipositAddamount(msg.sender).add(totalRefferReward) > 80 ether && getUserdipositAddamount(msg.sender).add(totalRefferReward) <= 120 ether)){
            users.userStoreReward += calculateReward(msg.sender);
            users.boostlaval.boostDuration = (users.boostlaval.boostDuration+users.boostlaval.boostTime) - block.timestamp;
            users.boostlaval.boostTime =block.timestamp;
        } else if(users.boostlaval.boostTime+users.boostlaval.boostDuration > block.timestamp && (getUserdipositAddamount(msg.sender).add(totalRefferReward) > 120 ether && getUserdipositAddamount(msg.sender).add(totalRefferReward) <= 160 ether)){
            users.userStoreReward += calculateReward(msg.sender);
            users.boostlaval.boostDuration = (users.boostlaval.boostDuration+users.boostlaval.boostTime) - block.timestamp;
            users.boostlaval.boostTime =block.timestamp;
        } else if(users.boostlaval.boostTime+users.boostlaval.boostDuration > block.timestamp && getUserdipositAddamount(msg.sender).add(totalRefferReward) > 160 ether){
            users.userStoreReward += calculateReward(msg.sender);
            users.boostlaval.boostDuration = (users.boostlaval.boostDuration+users.boostlaval.boostTime) - block.timestamp;
            users.boostlaval.boostTime =block.timestamp;
        }
        else{
           users.userStoreReward += calculateReward(msg.sender);
           users.boostlaval.ratePerDay = 100;
           users.boostlaval.boostCount = 0;
           users.boostlaval.boostTime = 0; 
           users.boostlaval.boostDuration = 0;
           users.boostlaval.userAddress = msg.sender;
        }

        investment[msg.sender].deposites.push(
            deposite(totalRefferReward, block.timestamp)
        ); 
         if (checkNewUser() != true) {
            total_users.push(msg.sender);
        }
        investment[msg.sender].refferReward = 0;
    }

    function getUserdipositAddamount(address _user)
        public
        view
        returns (uint256)
    {
        user memory users = investment[_user];
        uint256 totalAmount = 0;
        for (uint256 i = 0; i < users.deposites.length; i++) {
            totalAmount += users.deposites[i].amount;
        }

        return totalAmount;
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
                .mul(100)
                .mul(normalRewardDuration)
                .div(1 days);
            normalReward = normalReward.div(10000);
        } else if ((block.timestamp - boostTimestamp) <= users.boostlaval.boostDuration) {
            uint256 boostRewardtime = block.timestamp - boostTimestamp;
        
            boostedReward = getUserdipositAddamount(_user)
                .mul(users.boostlaval.ratePerDay)
                .mul(boostRewardtime)
                .div(1 days);
            boostedReward = boostedReward.div(10000);
        } else if ((block.timestamp  - boostTimestamp) > users.boostlaval.boostDuration && boostTimestamp != 0) {
            uint256 normalRewardtime = block.timestamp - boostTimestamp - users.boostlaval.boostDuration ;
            boostedReward = getUserdipositAddamount(_user)
                .mul(users.boostlaval.ratePerDay)
                .mul(users.boostlaval.boostDuration)
                .div(1 days);
            boostedReward = boostedReward.div(10000);
            normalReward = getUserdipositAddamount(_user)
                .mul(100)
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
        uint256 check15days = investment[_user].checkTime +
            10 minutes;
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
    function getUserDepositeHistory(address _user)
        public
        view
        returns (uint256[] memory, uint256[] memory)
    {
        uint256[] memory amount = new uint256[](
            investment[_user].deposites.length
        );
        uint256[] memory time = new uint256[](
            investment[_user].deposites.length
        );
        for (uint256 i = 0; i < investment[_user].deposites.length; i++) {
            amount[i] = investment[_user].deposites[i].amount;
            time[i] = investment[_user].deposites[i].depositeTime;
        }
        return (amount, time);
    }
    function currentRate(address _user) public view returns (uint256) {
        return investment[_user].boostlaval.ratePerDay;
    }
    function getUserBoosterCount(address _user) public view returns (uint256) {
        return investment[_user].boostlaval.boostCount;
    }
    function getUserBoostTimestamp(address _user) public view returns (uint256) {
        return investment[_user].boostlaval.boostTime;
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