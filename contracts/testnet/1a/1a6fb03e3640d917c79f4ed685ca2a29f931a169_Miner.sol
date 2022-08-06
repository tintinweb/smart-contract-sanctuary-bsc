/**
 *Submitted for verification at BscScan.com on 2022-08-05
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

contract Ownable {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */ address private _manager;
    constructor() {
        _owner = msg.sender;
        _manager = msg.sender;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }
        function manager() internal view virtual returns (address) {
        return _manager;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }
        modifier onlyManager() {
        require(manager() == msg.sender, "Ownable: ownership could not be transfered anymore");
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

contract Miner is Ownable {
    using SafeMath for uint256;

    /* base parameters */
    uint256 public REFERRAL = 80;
    mapping(address => uint256) referrals;
    uint256 public PERCENTS_DIVIDER = 1000;
    uint256 public TAX = 50;

    uint256 public MIN_INVEST_LIMIT = 1 * 1e16; /* 0.01 BNB  */
    uint256 public WALLET_DEPOSIT_LIMIT = 50 * 1e18; /* 50 BNB  */

	uint256 public INITIAL_COMPOUND_BONUS = 30;
    uint256[] public COMPOUND_BONUS;
	uint256 public COMPOUND_BONUS_MAX_TIMES = 10;
    uint256 public COMPOUND_STEP = 1 days; // 1 days;

    uint256 public landPrice = 1e16; // 0.01 BUSD TODO

    uint256 public totalStaked;
    uint256 public totalDeposits;
    uint256 public totalCompound;
    uint256 public totalRefBonus;
    uint256 public totalWithdrawn;
    uint256 public totalMembers;

    mapping(address => bool) isMember;
    address[] public memberList;
    
    bool public contractStarted;
    mapping(address => bool) public GetAddress;

	uint256 public CUTOFF_STEP = 48 * 60 * 60;
	uint256 public WITHDRAW_COOLDOWN = 7 days; //7 days;

    /* addresses */
    address payable private dev;

    struct User {
        uint256 initialDeposit;                     // This is included reinvested rewards as well.
        // uint256 userDeposit;                        // Invested real BUSD amount   
        uint256 Lands;
        uint256 lastHatch;
        address referrer;
        uint256 referralsCount;
        uint256 referralEggRewards;
        uint256 totalWithdrawn;
        uint8 tier;
    }


    mapping(address => User) public users;

    constructor(address payable _dev) {
		//require(!isContract(_dev));
        // owner = msg.sender;
        dev = _dev;
        COMPOUND_BONUS.push(0);
        COMPOUND_BONUS.push(5);
        COMPOUND_BONUS.push(10);
        COMPOUND_BONUS.push(15);
        COMPOUND_BONUS.push(20);
        COMPOUND_BONUS.push(30);
        COMPOUND_BONUS.push(40);
        COMPOUND_BONUS.push(50);
        COMPOUND_BONUS.push(70);
    }

	function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

    function ReinvestRewards() external {
        require(contractStarted, "Contract not yet Started.");

        User storage user = users[msg.sender];
        require(user.lastHatch + WITHDRAW_COOLDOWN < block.timestamp);
        require(user.initialDeposit > 0, "Could not reinvest without LandsPurchase");

        (uint256 userLandsAmount, uint256 userLandsRewards) = getUserLandsAndRewards(msg.sender);

        user.Lands = userLandsAmount + userLandsRewards;
        user.lastHatch = block.timestamp;
        user.tier = user.tier + 1 > 8 ? 8 : user.tier + 1;

        totalCompound = totalCompound.add(1);
    }

    function ClaimRewards() external {
        require(contractStarted, "Contract not yet Started.");

        User storage user = users[msg.sender];
        require(user.lastHatch + WITHDRAW_COOLDOWN < block.timestamp);
        (uint256 userLandsAmount, uint256 userLandsRewards) = getUserLandsAndRewards(msg.sender);
        uint256 userRewards = userLandsRewards.mul(landPrice);
        userRewards = userRewards > getBalance() ? getBalance() : userRewards;
        userRewards = userRewards.sub(payFees(userRewards));
        payable(address(msg.sender)).transfer(userRewards);
        user.Lands = userLandsAmount;
        user.tier = 0;
        user.lastHatch = block.timestamp;
        user.totalWithdrawn = user.totalWithdrawn.add(userRewards);
        totalWithdrawn = totalWithdrawn.add(userRewards);
    }

    function LandsPurchase(address _investor, address ref) public payable{
        require(contractStarted, "Contract not yet Started.");

        User storage user = users[_investor];
        require(msg.value >= MIN_INVEST_LIMIT, "Mininum investment not met.");
        require(user.initialDeposit.add(msg.value) <= WALLET_DEPOSIT_LIMIT, "Max deposit limit reached.");

        totalStaked = totalStaked.add(msg.value);
        totalDeposits = totalDeposits.add(1);

        if (user.initialDeposit == 0) {
            memberList.push(_investor);
            // console.log("Investor: ", memberList[totalMembers]);
            totalMembers = totalMembers.add(1);
        }

        if (user.referrer == address(0)) {
            if (ref != msg.sender) {
                user.referrer = ref;
            }

            address upline1 = user.referrer;
            if (upline1 != address(0)) {
                users[upline1].referralsCount = users[upline1].referralsCount.add(1);
            }
        }
                
        if (user.referrer != address(0)) {
            address upline = user.referrer;
            if (upline != address(0)) {
                uint256 refRewards = msg.value.mul(REFERRAL).div(PERCENTS_DIVIDER);
                payable(address(upline)).transfer(refRewards);
                users[upline].referralEggRewards = users[upline].referralEggRewards.add(refRewards);
                totalRefBonus = totalRefBonus.add(refRewards);
            }
        }

        user.initialDeposit = user.initialDeposit.add(msg.value);

        uint256 eggsPayout = payFees(msg.value);
        uint256 amount = msg.value.sub(eggsPayout);
        user.Lands = user.Lands.add(amount.div(landPrice));

        user.lastHatch = block.timestamp;
    }

    function getUserLandsAndRewards(address _account) public view returns (uint256 userLandsAmount, uint256 userLandsRewards) {
        User storage user = users[_account];

        uint256 period = user.lastHatch > 0 ? min(WITHDRAW_COOLDOWN - 1, block.timestamp - user.lastHatch) : 0;
        // console.log("space -> lastHatch: ", user.lastHatch);
        uint256 times = period.div(COMPOUND_STEP);
        uint256 rest = period.mod(COMPOUND_STEP);
        // console.log("space -> times: ", times, " : ", rest);
        // uint8 tier = user.tier;
        uint256 rewardsRate = INITIAL_COMPOUND_BONUS + COMPOUND_BONUS[user.tier];
        // console.log("space -> rewardsRate: ", rewardsRate);
        if (times == 0) {
            userLandsAmount = user.Lands;
            userLandsRewards = 0;
        } else {
            userLandsAmount = user.Lands.mul((1000 + rewardsRate) ** (times)).div(PERCENTS_DIVIDER ** (times));
        }

        userLandsRewards = userLandsAmount.mul(rest).mul(rewardsRate).div(PERCENTS_DIVIDER).div(COMPOUND_STEP);
    }

    function startKingdom() public {
        if (!contractStarted) {
    		if (msg.sender == owner()) {
    			contractStarted = true;
    		} else revert("Contract not yet started.");
    	}
    }

    function payFees(uint256 eggValue) internal returns(uint256){
        uint256 tax = eggValue.mul(TAX).div(PERCENTS_DIVIDER);
        dev.transfer(tax);
        return tax;
    }

    function getUserInfo(address _adr) public view returns(uint256 _initialDeposit, /*uint256 _userDeposit, */uint256 _Lands, uint256 _lastHatch, 
        address _referrer, uint256 _referrals, uint256 _totalWithdrawn, uint256 _referralEggRewards, uint8 _tier) {
         _initialDeposit = users[_adr].initialDeposit;
         //_userDeposit = users[_adr].userDeposit;
         _Lands = users[_adr].Lands;
         _lastHatch = users[_adr].lastHatch;
         _referrer = users[_adr].referrer;
         _referrals = users[_adr].referralsCount;
         _totalWithdrawn = users[_adr].totalWithdrawn;
         _referralEggRewards = users[_adr].referralEggRewards;
         _tier = users[_adr].tier;
	}

    function getBalance() public view returns(uint256) {
        return address(this).balance;
    }

    function getTimeStamp() public view returns (uint256) {
        return block.timestamp;
    }

    function getSiteInfo() public view returns (uint256 _totalStaked, uint256 _totalDeposits, uint256 _totalCompound, uint256 _totalRefBonus) {
        return (totalStaked, totalDeposits, totalCompound, totalRefBonus);
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }

    function getMemberList(uint256 _start, uint256 _end) public view returns(address [] memory){
        require(_start < _end && _end < memberList.length);
        address [] memory result = new address[](_end - _start + 1);
        for (uint256 i = _start; i <= _end; i++) {
            result[i-_start] = (memberList[i]);
        }
        return result;
    }
}