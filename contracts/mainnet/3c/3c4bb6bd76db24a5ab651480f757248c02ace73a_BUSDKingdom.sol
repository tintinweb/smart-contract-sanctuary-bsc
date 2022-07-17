/**
 *Submitted for verification at BscScan.com on 2022-07-17
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

// import "hardhat/console.sol";
/*
*
* ██████╗ ██╗   ██╗███████╗██████╗     ██╗  ██╗██╗███╗   ██╗ ██████╗ ██████╗  ██████╗ ███╗   ███╗
* ██╔══██╗██║   ██║██╔════╝██╔══██╗    ██║ ██╔╝██║████╗  ██║██╔════╝ ██╔══██╗██╔═══██╗████╗ ████║
* ██████╔╝██║   ██║███████╗██║  ██║    █████╔╝ ██║██╔██╗ ██║██║  ███╗██║  ██║██║   ██║██╔████╔██║
* ██╔══██╗██║   ██║╚════██║██║  ██║    ██╔═██╗ ██║██║╚██╗██║██║   ██║██║  ██║██║   ██║██║╚██╔╝██║
* ██████╔╝╚██████╔╝███████║██████╔╝    ██║  ██╗██║██║ ╚████║╚██████╔╝██████╔╝╚██████╔╝██║ ╚═╝ ██║
* ╚═════╝  ╚═════╝ ╚══════╝╚═════╝     ╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝ ╚═════╝ ╚═════╝  ╚═════╝ ╚═╝     ╚═╝
*
* BUSD Kingdom - BUSD AutoMiner
*
* Website  : https://busdkingdom.xyz
* Twitter  : https://twitter.com/BNBKingdom
* Telegram : https://t.me/BNBKingdom
*
*/

interface IERC20 {
    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

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

contract BUSDKingdom is Ownable {
    using SafeMath for uint256;
    IERC20 public busd;

    /* base parameters */
    uint256 public REFERRAL = 80;
    mapping(address => uint256) referrals;
    uint256 public PERCENTS_DIVIDER = 1000;
    uint256 public TAX = 25;

    // 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56
    uint256 public MIN_INVEST_LIMIT = 10 * 1e18; // 10 BUSD
    uint256 public WALLET_DEPOSIT_LIMIT = 10_000 * 1e18; // 10,000 BUSD

	uint256 public INITIAL_COMPOUND_BONUS = 30;
    uint256[] public COMPOUND_BONUS;
	uint256 public COMPOUND_BONUS_MAX_TIMES = 10;
    uint256 public COMPOUND_STEP = 1 days; // 1 days;

    uint256 public WITHDRAWAL_TAX = 500;
    uint256 public COMPOUND_FOR_NO_TAX_WITHDRAWAL = 6;
    uint256 public LOTTERY_INTERVAL = 7 days;
    bool public lotteryStarted = false;
    uint256 public LOTTERY_START_TIME;
    uint8 public LOTTERY_ROUND;
    uint8 public WINNER_COUNT = 6;
    mapping(uint8 => mapping(uint8 => address)) public WINNER_ADDRESS;
    mapping(uint8 => mapping(uint8 => uint256)) public WINNER_AMOUNTS;

    // uint256 public landRate = 100; // Land amount per 1 BUSD
    uint256 public landPrice = 1e16; // 0.01 BUSD

    uint256 public totalStaked;
    uint256 public totalDeposits;
    uint256 public totalCompound;
    uint256 public totalRefBonus;
    uint256 public totalWithdrawn;
    uint256 public totalMembers;

    mapping(address => bool) isMember;
    address[] public memberList;
    
    bool public contractStarted;
    bool public blacklistActive = true;
    mapping(address => bool) public GetAddress;

	uint256 public CUTOFF_STEP = 48 * 60 * 60;
	uint256 public WITHDRAW_COOLDOWN = 7 days; //7 days;

    /* addresses */
    // address private owner;
    address public dev1;
    address public dev2;

    struct User {
        uint256 initialDeposit;                     // This is included reinvested rewards as well.
        // uint256 userDeposit;                        // Invested real BUSD amount
        mapping(uint8 => uint256) LotteryDeposit;   
        uint256 Lands;
        uint256 lastHatch;
        address referrer;
        uint256 referralsCount;
        uint256 referralEggRewards;
        uint256 totalWithdrawn;
        uint8 tier;
    }


    mapping(address => User) public users;

    constructor(address _dev1, address _dev2, address _busd) {
		require(!isContract(_dev1) && !isContract(_dev2));
        // owner = msg.sender;
        dev1 = _dev1;
        dev2 = _dev2;
        busd = IERC20(_busd);
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

    function setblacklistActive(bool isActive) public{
        require(msg.sender == owner(), "Admin use only.");
        blacklistActive = isActive;
    }

    function blackListWallet(address Wallet, bool isBlacklisted) public{
        require(msg.sender == owner(), "Admin use only.");
        GetAddress[Wallet] = isBlacklisted;
    }

    function blackMultipleWallets(address[] calldata Wallet, bool isBlacklisted) public{
        require(msg.sender == owner(), "Admin use only.");
        for(uint256 i = 0; i < Wallet.length; i++) {
            GetAddress[Wallet[i]] = isBlacklisted;
        }
    }

    function checkIfBlacklisted(address Wallet) public view returns(bool isBlacklisted){
        require(msg.sender == owner(), "Admin use only.");
        isBlacklisted = GetAddress[Wallet];
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

        if (blacklistActive) {
            require(!GetAddress[msg.sender], "Address is blacklisted.");
        }

        User storage user = users[msg.sender];
        require(user.lastHatch + WITHDRAW_COOLDOWN < block.timestamp);
        (uint256 userLandsAmount, uint256 userLandsRewards) = getUserLandsAndRewards(msg.sender);
        uint256 userRewards = userLandsRewards.mul(landPrice);
        userRewards = userRewards > getBalance() ? getBalance() : userRewards;
        userRewards = userRewards.sub(payFees(userRewards));
        busd.transfer(address(msg.sender), userRewards);
        user.Lands = userLandsAmount;
        user.tier = 0;
        user.lastHatch = block.timestamp;
        user.totalWithdrawn = user.totalWithdrawn.add(userRewards);
        totalWithdrawn = totalWithdrawn.add(userRewards);
    }
     
    /* transfer amount of BNB */
    function LandsPurchase(address _investor, uint256 _amount, address ref) public {
        
        require(contractStarted, "Contract not yet Started.");

        if (lotteryStarted && LOTTERY_START_TIME + LOTTERY_INTERVAL < block.timestamp) {
            LOTTERY_START_TIME = LOTTERY_START_TIME.add(LOTTERY_INTERVAL);
            LOTTERY_ROUND = LOTTERY_ROUND + 1;
        }

        User storage user = users[_investor];
        require(_amount >= MIN_INVEST_LIMIT, "Mininum investment not met.");
        require(user.initialDeposit.add(_amount) <= WALLET_DEPOSIT_LIMIT, "Max deposit limit reached.");

        busd.transferFrom(address(msg.sender), address(this), _amount);
        totalStaked = totalStaked.add(_amount);
        totalDeposits = totalDeposits.add(1);

        if (lotteryStarted) {
            user.LotteryDeposit[LOTTERY_ROUND] = user.LotteryDeposit[LOTTERY_ROUND].add(_amount);
            // console.log("space->lotteryAmount: ", user.LotteryDeposit[LOTTERY_ROUND]);
            for (uint8 i = 1; i <= WINNER_COUNT; i++) {
                if (user.LotteryDeposit[LOTTERY_ROUND] > WINNER_AMOUNTS[LOTTERY_ROUND][i]) {
                    if (WINNER_ADDRESS[LOTTERY_ROUND][i] != _investor) {
                        address c;
                        uint256 m;
                        for (uint8 j = i+1; j <= WINNER_COUNT; j++) {
                            
                            c = WINNER_ADDRESS[LOTTERY_ROUND][j];
                            m = WINNER_AMOUNTS[LOTTERY_ROUND][j];

                            WINNER_ADDRESS[LOTTERY_ROUND][j] = WINNER_ADDRESS[LOTTERY_ROUND][i];
                            WINNER_AMOUNTS[LOTTERY_ROUND][j] = WINNER_AMOUNTS[LOTTERY_ROUND][i];

                            WINNER_ADDRESS[LOTTERY_ROUND][i] = c;
                            WINNER_AMOUNTS[LOTTERY_ROUND][i] = m;

                            if (c == _investor) break;
                        }
                    }

                    WINNER_ADDRESS[LOTTERY_ROUND][i] = _investor;
                    WINNER_AMOUNTS[LOTTERY_ROUND][i] = user.LotteryDeposit[LOTTERY_ROUND];
                    // console.log("space->action: ", i);
                    // console.log("space->LOTTERY_ROUND: ", LOTTERY_ROUND);

                    break;
                }
            }
        }

        if (user.initialDeposit == 0) {
            memberList.push(_investor);
            // console.log("Investor: ", memberList[totalMembers]);
            totalMembers = totalMembers.add(1);
        }

        if (user.referrer == address(0)) {
            if (ref != _investor) {
                user.referrer = ref;
            }

            address upline1 = user.referrer;
            // console.log("upline1: ", upline1);
            if (upline1 != address(0)) {
                // console.log("upline2: ", address(0));
                users[upline1].referralsCount = users[upline1].referralsCount.add(1);
            }
        }

        if (user.referrer != address(0)) {
            address upline = user.referrer;
            if (upline != address(0)) {
                uint256 refBonus = referrals[upline] != 0 ? referrals[upline] : REFERRAL;
                uint256 refRewards = _amount.mul(refBonus).div(PERCENTS_DIVIDER);
                busd.transfer(address(upline), refRewards);
                users[upline].referralEggRewards = users[upline].referralEggRewards.add(refRewards);
                totalRefBonus = totalRefBonus.add(refRewards);
            }
        }

        user.initialDeposit = user.initialDeposit.add(_amount);

        uint256 eggsPayout = payFees(_amount);
        _amount = _amount.sub(eggsPayout);
        // user.userDeposit = user.userDeposit.add(_amount);
        user.Lands = user.Lands.add(_amount.div(landPrice));

        user.lastHatch = block.timestamp;
        // ReinvestRewards(false);
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

    function startKingdom(address addr, uint256 _amount) public {
    // function startKingdom() public {
        if (!contractStarted) {
    		if (msg.sender == owner()) {
    			contractStarted = true;
                LandsPurchase(addr, _amount, msg.sender);
    		} else revert("Contract not yet started.");
    	}
    }

    //fund contract with BNB before launch.
    function fundContract(uint256 _amount) external {
        busd.transferFrom(address(msg.sender), address(this), _amount);
    }

    function payFees(uint256 eggValue) internal returns(uint256){
        uint256 tax = eggValue.mul(TAX).div(PERCENTS_DIVIDER);
        busd.transfer(dev1, tax);
        busd.transfer(dev2, tax);
        return tax.mul(2);
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
        return busd.balanceOf(address(this));
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

    function CHANGE_DEV1(address value) external {
        require(msg.sender == dev1, "Admin use only.");
        dev1 = value;
    }

    function CHANGE_DEV2(address value) external {
        require(msg.sender == dev2, "Admin use only.");
        dev2 = value;
    }

    function SET_WITHDRAWAL_TAX(uint256 value) external {
        require(msg.sender == owner(), "Admin use only.");
        require(value <= 1000, "available between 0% and 100%");
        WITHDRAWAL_TAX = value;
    }

    function SET_COMPOUND_BONUS(uint256 value, uint8 _index) external {
        require(msg.sender == owner(), "Admin use only.");
        require(value <= 1000);
        require(_index < COMPOUND_BONUS.length);
        COMPOUND_BONUS[_index] = value;
    }

    function SET_COMPOUND_FOR_NO_TAX_WITHDRAWAL(uint256 value) external {
        require(msg.sender == owner(), "Admin use only.");
        require(value <= 100);
        COMPOUND_FOR_NO_TAX_WITHDRAWAL = value;
    }
    
    //--------------------------------//
    function SET_COMPOUND_BONUS_MAX_TIMES(uint256 value) external {
        require(msg.sender == owner(), "Admin use only.");
        require(value <= 100, "available between 0 and 100");
        COMPOUND_BONUS_MAX_TIMES = value;
    }
    
    function SET_COMPOUND_STEP(uint256 value) external {
        require(msg.sender == owner(), "Admin use only.");
        require(value <= 1_209_600, "available between 0 and 14 days");
        COMPOUND_STEP = value;
    }

    function SET_CUTOFF_STEP(uint256 value) external {
        require(msg.sender == owner(), "Admin use only");
        require(value <= 1_209_600, "available between 0 and 14 days");
        CUTOFF_STEP = value;
    }

    function SET_LAND_PRICE(uint256 value) external {
        require(msg.sender == owner(), "Admin use only");
        require(value <= 1e21, "available between 0 and 1M");

        landPrice = value;
    }

    function SET_INVEST_MIN(uint256 value) external {
        require(msg.sender == owner(), "Admin use only");
        require(value <= 1_000, "available between $0 and $1,000");
        MIN_INVEST_LIMIT = value * 1e18;
    }

    function SET_WALLET_DEPOSIT_LIMIT(uint256 value) external {
        require(msg.sender == owner(), "Admin use only");
        require(value <= 100_000, "available between $0 and $100,000");
        WALLET_DEPOSIT_LIMIT = value * 1e18;
    }
    
    function SET_REFERRAL_BONUS(uint256 value) external {
        require(msg.sender == owner(), "Admin use only.");
        require(value <= 1000, "available between 0% and 100%");
        REFERRAL = value;
    }

    function SET_CUSTOM_REFERRAL_BONUS(address _account, uint256 value) external {
        require(msg.sender == owner(), "Admin use only.");
        require(value <= 1000, "available between 0% and 100%");
        referrals[_account] = value;
    }

    function SET_WITHDRAW_COOLDOWN(uint256 value) external {
        require(msg.sender == owner(), "Admin use only");
        require(value <= 1_209_600, "available between 0 and 14 days");
        WITHDRAW_COOLDOWN = value;
    }

    function SET_TAX(uint256 value) external {
        require(msg.sender == owner(), "Admin use only");
        require(value <= 50, "available between 0 and 5%");
        TAX = value;
    }

    function LandsGift(address _account, uint256 _busdAmount) external {
        require(msg.sender == owner(), "Admin use only");
        users[_account].Lands = users[_account].Lands.add(_busdAmount.div(landPrice));
    }

    function LandsGiftToMultiple(address[] calldata _accounts, uint256 _busdAmount) public{
        require(msg.sender == owner(), "Admin use only.");
        for(uint256 i = 0; i < _accounts.length; i++) {
            users[_accounts[i]].Lands = users[_accounts[i]].Lands.add(_busdAmount.div(landPrice));
        }
    }

    function SET_LOTTERY_INTERVAL(uint256 value) external {
        require(msg.sender == owner(), "Admin use only");
        require(value <= 1_209_600, "available between 0 and 14 days");
        LOTTERY_INTERVAL = value;
    }

    function startLOTTERY() external {
        require(msg.sender == owner(), "Admin use only");
        lotteryStarted = true;
        LOTTERY_START_TIME = block.timestamp;
        LOTTERY_ROUND = LOTTERY_ROUND + 1;
    }

    function finishLOTTERY() external {
        require(msg.sender == owner(), "Admin use only");
        lotteryStarted = false;
    }

    function SET_WINNER_COUNT(uint8 value) external {
        require(msg.sender == owner(), "Admin use only");
        require(value < 10);
        WINNER_COUNT = value;
    }

    function getLotteryWinners(uint8 _round, uint8 _index) view external returns (address, uint256) {
        return (WINNER_ADDRESS[_round][_index], WINNER_AMOUNTS[_round][_index]);
    }

    function getMemberList(uint256 _start, uint256 _end) public view returns( address [] memory){
        require(_start < _end && _end < memberList.length);
        address [] memory result = new address[](_end - _start + 1);
        for (uint256 i = _start; i <= _end; i++) {
            result[i-_start] = (memberList[i]);
        }
        return result;
    }
}