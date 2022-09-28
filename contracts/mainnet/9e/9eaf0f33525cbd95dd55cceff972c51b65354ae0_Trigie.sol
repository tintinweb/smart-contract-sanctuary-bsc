/**
 *Submitted for verification at BscScan.com on 2022-09-27
*/

/** 
    Trigie Test
**/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

abstract contract Context {

    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract ReentrancyGuard {
    bool internal locked;

    modifier noReentrant() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
    }
}

contract Trigie is Context , ReentrancyGuard {
    using SafeMath for uint256;
    bool public contractStarted;
    uint256 public constant min = 50 ether;
    uint256 public constant max = 30000 ether;
    uint256 public roi = 12;
    uint256 public constant fee = 1;
    uint256 public constant ref_fee = 4;
    uint256 public withdrawDays = 7 days;
    uint256 public claimDays = 1 days;
    address private dev;
    address private dev1;
    address private partner1;
    IERC20 private BusdInterface;
    address public tokenAdress;
    bool public antibotActive = true;
    mapping(address => bool) public AntiBotlisted;


    constructor(address _dev,address _dev1,address _partner1) {
        tokenAdress = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
        BusdInterface = IERC20(tokenAdress);
        owner = msg.sender;
        dev = _dev;
        dev1 = _dev1;
        partner1 = _partner1;
    }

    struct refferal_system {
        address ref_address;
        uint256 reward;
    }

    struct refferal_withdraw {
        address ref_address;
        uint256 totalWithdraw;
    }

    struct user_investment_details {
        address user_address;
        uint256 invested;
    }

    struct weeklyWithdraw {
        address user_address;
        uint256 startTime;
        uint256 deadline;
    }

    struct claimDaily {
        address user_address;
        uint256 startTime;
        uint256 deadline;
    }

    struct userWithdrawal {
        address user_address;
        uint256 amount;
    }

    struct userTotalWithdraw {
        address user_address;
        uint256 amount;
    }

    struct userTotalRewards {
        address user_address;
        uint256 amount;
    } 

    mapping(address => refferal_system) public refferal;
    mapping(address => user_investment_details) public investments;
    mapping(address => weeklyWithdraw) public weekly;
    mapping(address => claimDaily) public claimTime;
    mapping(address => userWithdrawal) public approvedWithdrawal;
    mapping(address => userTotalWithdraw) public totalWithdraw;
    mapping(address => userTotalRewards) public totalRewards; 
    mapping(address => refferal_withdraw) public refTotalWithdraw;
    mapping(address => bool) public isInvested;
    address public owner;

    function setAntiBotActive(bool isActive) public{
        require(msg.sender == owner, "Admin use only.");
        antibotActive = isActive;
    }

    function antiBotWallet(address Wallet, bool isAntiBotlisted) public{
        require(msg.sender == owner, "Admin use only.");
        AntiBotlisted[Wallet] = isAntiBotlisted;
    }

    function antiBotMultipleWallets(address[] calldata Wallet, bool isAntiBotlisted) public{
        require(msg.sender == owner, "Admin use only.");
        for(uint256 i = 0; i < Wallet.length; i++) {
            AntiBotlisted[Wallet[i]] = isAntiBotlisted;
        }
    }
    function checkIfAntiBotlisted(address Wallet) public view returns(bool antibotlisted) {
        require(msg.sender == owner, "Admin use only.");
        antibotlisted = AntiBotlisted[Wallet];
    }

    function userReward(address _userAddress) public view returns(uint256) {
        uint256 totalTime = claimTime[_userAddress].deadline.sub(claimTime[_userAddress].startTime);
        uint256 value = DailyRoi(investments[_userAddress].invested).div(totalTime);

        if(claimTime[_userAddress].deadline >= block.timestamp) {
            uint256 earned = block.timestamp.sub(claimTime[_userAddress].startTime);
            return earned.mul(value);
        }
        else {
            return DailyRoi(investments[_userAddress].invested);
        }
    }

    function deposit(address _ref, uint256 _amount) public noReentrant  {
        require(contractStarted, "Not Launched!");
        require(_amount >= min && _amount <= max, "User cannot deposit. Please check minimum/maximum deposit.");

        //referral bonus
        if(_ref != address(0) && _ref != msg.sender){
            uint256 ref_fee_add = refFee(_amount);
            refferal[_ref] = refferal_system(_ref, ref_fee_add.add(refferal[_ref].reward));
        }
        
        //claim existing dividends
        if(isInvested[msg.sender] && userReward(msg.sender) > 0){
            uint256 rewards = userReward(msg.sender);
            approvedWithdrawal[msg.sender] = userWithdrawal(msg.sender, approvedWithdrawal[msg.sender].amount.add(rewards));
            totalRewards[msg.sender].amount = totalRewards[msg.sender].amount.add(rewards);
        }

        //record investment
        investments[msg.sender] = user_investment_details(msg.sender, investments[msg.sender].invested.add(_amount));

        //reset weekly withdraw time
        weekly[msg.sender] = weeklyWithdraw(msg.sender, block.timestamp, block.timestamp.add(withdrawDays));

        //reset daily claim time
        claimTime[msg.sender] = claimDaily(msg.sender, block.timestamp, block.timestamp.add(claimDays));      
        
        //transfer amount
        payFeesAndGetRemaining(_amount, true);

        //will be set to true if new investor
        isInvested[msg.sender] = true;
    }

    function payFeesAndGetRemaining(uint256 _amount, bool fromDeposit) internal {
        uint256 taxFee = projectFee(_amount);
        uint256 totalAmount = _amount.sub(taxFee.mul(5));
        if(fromDeposit){
            BusdInterface.transferFrom(msg.sender, dev, taxFee);
            BusdInterface.transferFrom(msg.sender, dev1, taxFee);
            BusdInterface.transferFrom(msg.sender, partner1, taxFee);
            BusdInterface.transferFrom(msg.sender, address(this), totalAmount);        
        }else{
            BusdInterface.transfer(dev, taxFee);
            BusdInterface.transfer(dev1, taxFee);
            BusdInterface.transfer(partner1, taxFee);
            BusdInterface.transfer(msg.sender, totalAmount);
        } 
    }

    function withdrawal() public noReentrant {
        require(contractStarted, "Not Launched!");  
        if (antibotActive) {
            require(!AntiBotlisted[msg.sender], "Address is blacklisted.");
        }  
        require(weekly[msg.sender].deadline <= block.timestamp, "User can't withdraw.");
        require(totalWithdraw[msg.sender].amount <= investments[msg.sender].invested.mul(3), "User's total withdrawn is already 3x of his investment.");
        uint256 aval_withdraw = approvedWithdrawal[msg.sender].amount;

        if(totalWithdraw[msg.sender].amount.add(aval_withdraw) >= investments[msg.sender].invested.mul(3)){
            aval_withdraw = investments[msg.sender].invested.mul(3).sub(totalWithdraw[msg.sender].amount);
        }

        //current reward / 2
        uint256 aval_withdraw2 = aval_withdraw.div(2);

        //reset to 0
        approvedWithdrawal[msg.sender] = userWithdrawal(msg.sender, 0);
        
        //50% re-invested.
        investments[msg.sender] = user_investment_details(msg.sender, investments[msg.sender].invested.add(aval_withdraw2));

        //50% withdrawn
        totalWithdraw[msg.sender] = userTotalWithdraw(msg.sender, totalWithdraw[msg.sender].amount.add(aval_withdraw2));

        //reset weekly withdraw time
        weekly[msg.sender] = weeklyWithdraw(msg.sender, block.timestamp, block.timestamp.add(withdrawDays));

        //transfer amount
        payFeesAndGetRemaining(aval_withdraw2, false);
    }

    function claimDailyRewards() public noReentrant{
        require(contractStarted, "Not Launched!");
        require(claimTime[msg.sender].deadline <= block.timestamp, "User can't claim yet.");

        //update withdrawable amount
        approvedWithdrawal[msg.sender] = userWithdrawal(msg.sender, userReward(msg.sender).add(approvedWithdrawal[msg.sender].amount));
        
        //update available rewards
        totalRewards[msg.sender].amount = totalRewards[msg.sender].amount.add(userReward(msg.sender));

        //reset claim time
        claimTime[msg.sender] = claimDaily(msg.sender, block.timestamp, block.timestamp.add(claimDays));  
    }

    function Ref_Withdraw() external noReentrant {
        require(contractStarted, "Not Launched!");
        require(investments[msg.sender].invested > 0, "Need to invest!");
        uint256 value = refferal[msg.sender].reward.div(2);
        refferal[msg.sender] = refferal_system(msg.sender, 0);
        
        //50% re-invested 
        investments[msg.sender] = user_investment_details(msg.sender, investments[msg.sender].invested.add(value));
        
        //50% referral bonus withdrawn
        refTotalWithdraw[msg.sender] = refferal_withdraw(msg.sender, refTotalWithdraw[msg.sender].totalWithdraw.add(value));
        
        //transfer referral bonus
        BusdInterface.transfer(msg.sender, value);
    }

    function updateDailyRoi(uint256 value) external {
        require(msg.sender == owner, "Admin use only.");
        require(value >= 8 && value <= 14 );
        roi = value;
    }

    function Start(bool value) public {
        require(msg.sender == owner, "Admin use only.");
        contractStarted = value; 
    }   

    function DailyRoi(uint256 _amount) public view returns(uint256) {
        return _amount.mul(roi).div(100);
    }

    function refFee(uint256 _amount) public pure returns(uint256) {
        return _amount.mul(ref_fee).div(100);
    }

    function projectFee(uint256 _amount) public pure returns(uint256) {
        return _amount.mul(fee).div(100);
    }

    function getBalance() public view returns(uint256){
         return BusdInterface.balanceOf(address(this));
    }

    function CHANGE_OWNERSHIP(address value) external {
        require(msg.sender == owner, "Admin use only.");
        owner = value;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }
    
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}