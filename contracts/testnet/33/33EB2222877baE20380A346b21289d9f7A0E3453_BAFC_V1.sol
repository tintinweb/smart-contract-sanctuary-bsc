/**
 *Submitted for verification at BscScan.com on 2022-05-19
*/

// File: @openzeppelin\contracts\utils\Context.sol

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// File: @openzeppelin\contracts\access\Ownable.sol

// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
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
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

// File: @openzeppelin\contracts\utils\math\Math.sol

// OpenZeppelin Contracts (last updated v4.5.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a / b + (a % b == 0 ? 0 : 1);
    }
}

// File: contracts\BAFC_V1.sol

pragma solidity 0.8.0;

contract BAFC_V1 is Ownable {
    using Math for uint256;

    uint256 private constant SECONDS_PER_DAY = 120; //24 * 60 * 60;
    uint256 private constant MAX_COMPOUND_FREQUENCY = 5;

	bool public feeEnabled = true;
    bool public gameStarted = true;

    uint256 public minContribution = 0.1 * (10**18);    // 0.1 BNB  
    uint256 public maxContribution = 1 * (10**18);     // 10 BNB  

    uint256 public baseRate = 5;
	uint256 public compoundBonusRate = 2;
    uint256 public maxCompoundBonusRate = 10;
    uint256 public referralBonusRate = 1;
    uint256 public maxReferralBonusRate = 5;
    uint256 public fee = 10;
    uint256 public maxRewardsMultiplier = 2;

    /* addresses */
    address payable public feeAddr;

    struct User {
        address referrer;
        address[] refereeList;
        uint256 refereeCount;
        uint256 refereeTotalContribution;
        uint256 depositAmount;
        uint256 totalDepositAmount;
        uint256 depositTimeStamp;
        uint256 totalHarvested;
        uint256 compoundAmount;
        uint256 compoundCount;
        uint256 lastCompoundOrHarvestTimestamp;
        uint256 nextCompoundOrHarvestTimestamp;
        bool gameActive;
        bytes name;
    }
    
    mapping(address => User) public userInfo;
    mapping(address => address[]) public refereeList;

    // constructor(address payable _feeAddr) {
    //     feeAddr = _feeAddr;
    // }

    constructor() {
        feeAddr = payable(msg.sender);
    }

    function joinGame(address referrer, bytes memory _name) external payable {
        require(referrer != msg.sender, "Referrer with own address is not allowed");
        require(referrer != address(0), "Referrer with address zero is not allowed");
        require(_name.length == 0, "No user name provided");
        require(gameStarted, "Game is not started yet");
        require(msg.value >= minContribution, "Below minimum threshold");
        require(msg.value <= maxContribution, "Exceeded maximum threshold");
        require(!userInfo[msg.sender].gameActive, "Active game found, only ONE game is allowed at a time"); 

        // Transfer fee to wallet if enabled
        if(feeEnabled) {
            payable(feeAddr).transfer(calculateAmount(msg.value, fee));
        }

        // Set user Info
        User storage _userInfo = userInfo[msg.sender];
        uint256 timeNow = block.timestamp;

        // Only allow set referrer in first game
        if(_userInfo.referrer == address(0))
            _userInfo.referrer = referrer;
            
        _userInfo.name = _name;
        _userInfo.depositAmount = msg.value;
        _userInfo.totalDepositAmount += msg.value;
        _userInfo.depositTimeStamp = timeNow;
        _userInfo.totalHarvested = 0;
        _userInfo.compoundCount = 0;
        _userInfo.compoundAmount = 0;
        _userInfo.lastCompoundOrHarvestTimestamp = timeNow;
        _userInfo.nextCompoundOrHarvestTimestamp = timeNow + SECONDS_PER_DAY;
        _userInfo.gameActive = true;

        // Set user referrer info
        User storage _referrerInfo = userInfo[referrer];
        _referrerInfo.refereeList.push(msg.sender);
        _referrerInfo.refereeCount++;
        _referrerInfo.refereeTotalContribution += msg.value;

        // Update refereeList
        address[] storage list = refereeList[referrer];
        list.push(msg.sender);
        refereeList[referrer] = list;

        emit JoinGame(msg.sender, referrer, msg.value);
    }

    function compound() external {
        User storage _userInfo = userInfo[msg.sender];

        require(_userInfo.gameActive, "No active game found"); 
        require(_userInfo.compoundCount < MAX_COMPOUND_FREQUENCY, "Max compound frequency reached");
        require(_userInfo.nextCompoundOrHarvestTimestamp <= block.timestamp, "Compound time not yet reached");

        _userInfo.compoundAmount += getCurrentReward(msg.sender);
        _userInfo.compoundCount += 1;
        _userInfo.lastCompoundOrHarvestTimestamp = block.timestamp;
        _userInfo.nextCompoundOrHarvestTimestamp = block.timestamp + SECONDS_PER_DAY;

        emit Compound(msg.sender);
    }

    function harvest() external {
        User storage _userInfo = userInfo[msg.sender];

        require(_userInfo.gameActive, "No active game found"); 

        uint256 _maxRewards = _userInfo.depositAmount * maxRewardsMultiplier;
        require(_userInfo.nextCompoundOrHarvestTimestamp <= block.timestamp, "Harvest time not yet reached");
        require(_userInfo.totalHarvested < _maxRewards, "All rewards harvested");
        
        uint256 _rewards = getCurrentReward(msg.sender);
        require(_rewards > 0, "No rewards found");
        require(address(this).balance > _rewards, "Insufficient balance in contract");

        _userInfo.totalHarvested += _rewards;
        _userInfo.lastCompoundOrHarvestTimestamp = block.timestamp;
        _userInfo.nextCompoundOrHarvestTimestamp = block.timestamp + SECONDS_PER_DAY;
        _userInfo.compoundCount = 0;

        // Update info when harvested all rewards
        if(_maxRewards == _userInfo.totalHarvested) {
           
            _userInfo.gameActive = false;
            _userInfo.nextCompoundOrHarvestTimestamp = 0;
            _userInfo.compoundAmount = 0;

            // Deduct contribution amount record from referrer
            User storage _referrerInfo = userInfo[_userInfo.referrer];
            _referrerInfo.refereeTotalContribution -= _userInfo.depositAmount;
            _referrerInfo.refereeCount --;
        }
        
        payable(msg.sender).transfer(_rewards);
        emit Harvest(msg.sender, _rewards);
    }

    function updateUserName(bytes memory _name) external {
        User storage _userInfo = userInfo[msg.sender];
        _userInfo.name = _name;

        emit UpdateUserName(msg.sender, _name);
    }

    function getCurrentReward(address addr) public view returns(uint256) {
        User storage _userInfo = userInfo[addr];

        // Get user last action time
        uint256 _daysPast = getDaysPast(_userInfo.lastCompoundOrHarvestTimestamp);
        if(_daysPast == 0) return 0;

        // Total rate = base + compound bonus + referral bonus
        uint256 _totalRate = baseRate + getCompoundBonusRate(addr) + getReferralBonusRate(addr);

        // Calculate rewards
        uint256 _rewards = _daysPast * (calculateAmount(_userInfo.depositAmount + _userInfo.compoundAmount, _totalRate));

        // Check whether rewards exceeded the max allowed rewards
        uint256 _totalRewards = _userInfo.totalHarvested + _rewards;
        uint256 _maxRewards = _userInfo.depositAmount * maxRewardsMultiplier;

        if(_totalRewards > _maxRewards)
            return _maxRewards - _userInfo.totalHarvested;
        else
            return _rewards;
    }

    function getCompoundBonusRate(address addr) public view returns(uint256) {
        User storage _userInfo = userInfo[addr];
        uint256 _compoundBonus =_userInfo.compoundCount * compoundBonusRate;

        return Math.min(_compoundBonus, maxCompoundBonusRate);
    }

    function getReferralBonusRate(address addr) public view returns(uint256) {
        User storage _userInfo = userInfo[addr];
        uint256 _contribution =_userInfo.refereeTotalContribution / (10**18);

        return Math.min(_contribution * referralBonusRate, maxReferralBonusRate);
    }

    function getNextRewardTimestamp(address addr) external view returns(uint256) {
        User storage _userInfo = userInfo[addr];
        uint256 _nextRewardTimestamp =_userInfo.nextCompoundOrHarvestTimestamp;

        if(_nextRewardTimestamp == 0) return 0;

        while(_nextRewardTimestamp < block.timestamp) {
            _nextRewardTimestamp += SECONDS_PER_DAY;
        }

        return _nextRewardTimestamp;
    }

    function getRefereeListLength(address _addr) external view returns(uint256) {
        return refereeList[_addr].length;
    }

    function getDaysPast(uint256 _time) public view returns(uint256) {
        uint256 timeDiff = block.timestamp - _time;
        return timeDiff / SECONDS_PER_DAY;
    }

    function calculateAmount(uint256 _amount, uint256 _percent) internal pure returns(uint256) {
        return _amount * _percent / 100;
    }

    function enableFee(bool _bool) external onlyOwner {
        feeEnabled = _bool;

        emit EnableFee(_bool);
    }

    function setGameStarted(bool _bool) external onlyOwner {
        gameStarted = _bool;

        emit SetGameStarted(_bool);
    }

    function setContribution(uint256 _minContribution, uint256 _maxContribution) external onlyOwner {
        minContribution = _minContribution;
        maxContribution = _maxContribution;

        emit SetContribution(_minContribution, _maxContribution);
    }

    function setMaxBonusRate(uint256 _maxCompoundBonusRate, uint256 _maxReferralBonusRate) external onlyOwner {
        maxCompoundBonusRate = _maxCompoundBonusRate;
        maxReferralBonusRate = _maxReferralBonusRate;

        emit SetMaxBonusRate(_maxCompoundBonusRate, _maxReferralBonusRate);
    }

    function setBonusRate(uint256 _baseRate, uint256 _compoundBonusRate, uint256 _referralBonusRate) external onlyOwner {
        baseRate = _baseRate;
        compoundBonusRate = _compoundBonusRate;
        referralBonusRate = _referralBonusRate;

        emit SetBonusRate(baseRate, compoundBonusRate, referralBonusRate);
    }

    function setFee(uint256 _fee) external onlyOwner {
        require(_fee <= 10, "Max 10% fee");
        fee = _fee;

        emit SetFee(_fee);
    }

    function setMaxRewardsMultiplier(uint256 _maxRewardsMultiplier) external onlyOwner {
        maxRewardsMultiplier = _maxRewardsMultiplier;

        emit SetMaxRewardsMultiplier(_maxRewardsMultiplier);
    }

    function clearStuckBalance() external onlyOwner {
        uint256 balance = address(this).balance;
        payable(owner()).transfer(balance);
    }

    receive() external payable {}

    event JoinGame(address userAddress, address referrer, uint256 amount);
    event Compound(address userAddress);
    event Harvest(address userAddress, uint256 harvestedAmount);
    event EnableFee(bool feeEnabled);
    event SetGameStarted(bool gameStarted);
    event SetContribution(uint256 minContribution, uint256 maxContribution);
    event SetMaxBonusRate(uint256 maxCompoundBonusRate, uint256 maxReferralBonusRate);
    event SetBonusRate(uint256 baseRate, uint256 compoundBonusRate, uint256 referralBonusRate);
    event SetFee(uint256 fee);
    event SetMaxRewardsMultiplier(uint256 maxRewardsMultiplier);
    event UpdateUserName(address userAddress, bytes name);

}