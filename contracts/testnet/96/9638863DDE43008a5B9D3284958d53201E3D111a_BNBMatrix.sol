/**
 *Submitted for verification at BscScan.com on 2022-11-08
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

/*
*
*    ______     ____  _____   ______       ____    ____        _        _________   _______      _____   ____  ____  
*   |_   _ \   |_   \|_   _| |_   _ \     |_   \  /   _|      / \      |  _   _  | |_   __ \    |_   _| |_  _||_  _| 
*     | |_) |    |   \ | |     | |_) |      |   \/   |       / _ \     |_/ | | \_|   | |__) |     | |     \ \  / /   
*     |  __'.    | |\ \| |     |  __'.      | |\  /| |      / ___ \        | |       |  __ /      | |      > `' <    
*    _| |__) |  _| |_\   |_   _| |__) |    _| |_\/_| |_   _/ /   \ \_     _| |_     _| |  \ \_   _| |_   _/ /'`\ \_  
*   |_______/  |_____|\____| |_______/    |_____||_____| |____| |____|   |_____|   |____| |___| |_____| |____||____| 
*                                                                                                                    
*
*/


contract Ownable{
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _owner = msg.sender;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

library SafeMath {

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a / b;
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}

contract BNBMatrix is Ownable {
    using SafeMath for uint256;

    /* base parameters */
    uint256 public DAILY_ROI = 115;   // 1.15% PER DAILY
    uint256 public PERCENTS_DIVIDER = 10000;
    uint256 public COMPOUND_LIMIT = 65;  // once per day
    uint256 public EARLY_WITHDRAW_FEE = 5000;   // 80%
    uint256 private TAX = 500;  // 5% for both deposit and withdraw
    uint256 public REFERRAL = 1000;
    uint256 public MIN_INVEST_LIMIT = 1e17; /* 0.1 BNB  */
    uint256 public WALLET_DEPOSIT_LIMIT = 1000 * 1e18; /* 1000 BNB  */
    uint256 public MATRIX_COUNT_LIMIT = 2;
	
    uint256 public ACTION_STEP = 1 * 60; // 1 days;
    uint256 public CUTOFF_STEP = 10 * 60; // 1 days;
    address public LAST_WINNER;
    address public CUR_WINNER;
    uint256 public UPDATE_POOL_LIMIT = 1e17; // 0.1BNB
    uint256 public LATEST_DEPOSIT_TIME;
    uint256 public POOL_PRIZE_SIZE;
    uint256 public LAST_POOL_PRIZE_SIZE;
    uint256 public POOL_PRIZE_FEE = 1000; //10%
    mapping(address => bool) isMember;
    uint256 public MEMBER_COUNT;
    struct Matrix {
        uint256 lastAction;
        uint256 cmps;
        uint256 initAmount;
        uint256 curAmount;
    }

    struct User {
        uint256 totalInits;
        uint256 totalWiths;
        uint256 lastWith;
        uint256 refBonus;
        uint256 referralsCount;
        address referrer;
        Matrix [] matrixList;
    }

    mapping(address => User) public users;
    mapping(address => uint256) public customRefFee;
    /******************************************************* */
    uint256 public totalInvested;
    uint256 public totalCompound;
    uint256 public totalClaimed;
    uint256 public totalRefBonus;

    bool private contractStarted;

    constructor() {
    }

	function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

    function startMatrix() public onlyOwner {
        if (!contractStarted) {
            contractStarted = true;
            LATEST_DEPOSIT_TIME = block.timestamp;
        } else {
            revert("Contract already started.");
        }
    }

    //fund contract with BNB before launch.
    function fundContract() external payable {}

    function Invest(address ref) public payable {
        require(contractStarted, "Contract not yet Started.");
        User storage user = users[msg.sender];
        require(msg.value >= MIN_INVEST_LIMIT, "Mininum investment not met.");
        require(msg.value <= WALLET_DEPOSIT_LIMIT, "Max deposit limit reached.");
        require(user.matrixList.length < MATRIX_COUNT_LIMIT, "Matrix count reached to limit");

        if (block.timestamp > LATEST_DEPOSIT_TIME + CUTOFF_STEP && CUR_WINNER != address(0)) {
            payable(CUR_WINNER).transfer(POOL_PRIZE_SIZE);
            LAST_WINNER = CUR_WINNER;
            LAST_POOL_PRIZE_SIZE = POOL_PRIZE_SIZE;
            CUR_WINNER = address(0);
            POOL_PRIZE_SIZE = 0;
        }

        if (msg.value >= UPDATE_POOL_LIMIT) {
            CUR_WINNER = msg.sender;
            LATEST_DEPOSIT_TIME = block.timestamp;
        }

        POOL_PRIZE_SIZE = POOL_PRIZE_SIZE + msg.value * POOL_PRIZE_FEE / PERCENTS_DIVIDER;

        user.totalInits = user.totalInits.add(msg.value);
        if (user.referrer == address(0) && ref != msg.sender) {
            if (ref == address(0)) {
                user.referrer = owner();
            } else {
                user.referrer = ref;
            }

            if (ref != address(0)) {
                users[ref].referralsCount = users[ref].referralsCount.add(1);
            }
        }
        
        if (user.referrer != address(0)) {
            address upline = user.referrer;
            uint256 refRewards = msg.value.mul( customRefFee[upline] > 0 ? customRefFee[upline] : REFERRAL).div(PERCENTS_DIVIDER);
            payable(address(upline)).transfer(refRewards);
            users[upline].refBonus = users[upline].refBonus.add(refRewards);
            totalRefBonus = totalRefBonus.add(refRewards);
        }

        uint256 devFee = msg.value * TAX / PERCENTS_DIVIDER;
        payable(owner()).transfer(devFee);

        user.matrixList.push(Matrix({
            lastAction: block.timestamp,
            cmps: 0,
            initAmount: msg.value,
            curAmount: msg.value - devFee
        }));

        if(isMember[msg.sender] == false) {
            isMember[msg.sender] = true;
            MEMBER_COUNT ++;
        }

        totalInvested += msg.value;
    }

    function Compound(uint256 _index) public {
        require(contractStarted, "Contract not yet Started.");
        
        User storage user = users[msg.sender];
        require(_index < user.matrixList.length, "invalid matrix index");
        require(user.matrixList[_index].lastAction + ACTION_STEP < block.timestamp, "You can compound once a day.");
        require(user.matrixList[_index].cmps < COMPOUND_LIMIT);
        
        user.matrixList[_index].lastAction = block.timestamp;
        user.matrixList[_index].cmps += 1;

        if (user.matrixList[_index].cmps ==  COMPOUND_LIMIT) {
            user.matrixList[_index].curAmount = user.matrixList[_index].initAmount * 2;
        } else {
            user.matrixList[_index].curAmount = user.matrixList[_index].curAmount * (PERCENTS_DIVIDER + DAILY_ROI) / PERCENTS_DIVIDER;
        }

        totalCompound ++;
    }

    function Claim(uint256 _index) public{
        require(contractStarted, "Contract not yet Started.");
        
        User storage user = users[msg.sender];
        require(_index < user.matrixList.length, "invalid matrix index");
        require(user.matrixList[_index].lastAction + ACTION_STEP < block.timestamp, "You can do action once a day.");

        uint256 amount = user.matrixList[_index].curAmount;
        uint256 compounds = user.matrixList[_index].cmps;
        if (amount > getBalance()) {
            amount = getBalance();
            user.matrixList[_index].curAmount = amount - getBalance();
        } else {
            user.matrixList[_index] = user.matrixList[user.matrixList.length - 1];
            user.matrixList.pop();
        }
        
        uint256 devFee = amount * TAX / PERCENTS_DIVIDER;
        if (compounds > COMPOUND_LIMIT) { // Normal case
            payable(owner()).transfer(devFee);
            payable(msg.sender).transfer(amount - devFee);
        } else { // Early withdraw case
            uint256 earlyTaxFee = amount * EARLY_WITHDRAW_FEE / PERCENTS_DIVIDER;
            payable(owner()).transfer(devFee);
            payable(msg.sender).transfer(amount - earlyTaxFee - devFee);
        }
        user.totalWiths += amount;
        user.lastWith = block.timestamp;
        totalClaimed += amount;
    }

    function setCustomReferralFee(address _account, uint256 _value) external onlyOwner {
        require(_value <= 1500, "ref fee could not over 15%");
        customRefFee[_account] = _value;
    }

    function userInfo(address _account) view external returns (Matrix [] memory matrixList) {
        User storage user = users[_account];
        return(
            user.matrixList
        );
    }

    function getBalance() public view returns(uint256){
        return address(this).balance;
    }

    function getTimeStamp() public view returns (uint256) {
        return block.timestamp;
    }

    function getSiteInfo() public view returns (uint256 _totalStaked, uint256 _totalDeposits, uint256 _totalCompound, uint256 _totalRefBonus, uint256 _totalMembers) {
        return (totalInvested, totalCompound, totalClaimed, totalRefBonus, MEMBER_COUNT);
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }
}