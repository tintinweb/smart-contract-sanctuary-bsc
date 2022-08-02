// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";

pragma solidity ^0.8.9;

interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function decimals() external view returns (uint8);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

contract Staking is Ownable {

    uint constant private oneHundredPercent = 100000;
    uint constant private secondPerDay = 60 * 60 * 24;
    uint private secondsPerMonth = secondPerDay * 30;
    uint public decimals;
    uint public minTokenStake; 
    uint private feeToStake; // %
    
    uint public totalTokenInPool;
    uint public totalStaker;

    IERC20 tokenCt;

    struct StakeInfo{
        uint claimAt;
        uint amount;
        uint estimateReward;
        uint totalAmount;
        bool isClaim;
        bool isUnStake;
    }

    struct StakerInfo{
        uint totalStake;
        bool isStaker;

    }

    struct StrategyInfo {
        uint months;
        uint cliffTime;
        uint APY;
    }

    enum Strategy {
        ThreeMonths, SixMonths, TwelveMonths
    }

    mapping(Strategy => StrategyInfo) public strategyInfo;
    mapping(address => mapping(uint => StakeInfo)) public stakeInfo;
    mapping(address => uint[]) public stakerTrack;
    mapping(address => StakerInfo) public stakerInfo;
    address[] public stakerInPool;

     constructor (address _token) {
        tokenCt = IERC20(_token);
        decimals = tokenCt.decimals();
    }

    event StakeEven(uint _amount, uint _claimAt);

    event UnStakeEven(uint _amount, uint _claimAt);

    event ClaimToken(address sender,uint _stakeTime,uint amount);

    modifier onlyStaker(){
        require(stakerInfo[_msgSender()].isStaker, "Staking: not address staker");
        _;
    }

    function stakeToken(Strategy _strategy, uint _amount) external {
        require(_amount >= minTokenStake, "Staking: stake token must greater or equal 1000" );
        address sender = _msgSender();
        if(!stakerInfo[sender].isStaker){
            stakerInPool.push(sender);
            totalStaker += 1;
            stakerInfo[sender].isStaker = true;
        }
        totalTokenInPool = tokenCt.balanceOf(address(this)) + _amount;
        uint amount = _amount * (oneHundredPercent - feeToStake) / oneHundredPercent;
        stakerInfo[sender].totalStake += amount;
        uint timeStake = block.timestamp;
        StrategyInfo memory staInfo = strategyInfo[_strategy];
        uint claimAt = timeStake + staInfo.cliffTime;
        uint estimateReward = ((amount * staInfo.APY/ oneHundredPercent) / 12 )* staInfo.months;
        uint total = estimateReward + amount;
        stakerTrack[sender].push(timeStake);
        stakeInfo[sender][timeStake] = StakeInfo(claimAt, amount, estimateReward,total, false, false);

        tokenCt.transferFrom(sender, address(this), _amount);
        emit StakeEven(amount, claimAt);
    }

    function unStakeToken(uint _stakeTime) external onlyStaker {
        address sender = _msgSender();
        stakeInfo[sender][_stakeTime].claimAt = block.timestamp;
        stakeInfo[sender][_stakeTime].isUnStake = true;
        stakeInfo[sender][_stakeTime].isClaim = true;
        uint amount = stakeInfo[sender][_stakeTime].amount;
        tokenCt.transfer(sender, amount);

        emit UnStakeEven(amount,block.timestamp);
    }

    function claimToken(uint _stakeTime) external onlyStaker {
        address sender = _msgSender();
        uint claimAt = stakeInfo[sender][_stakeTime].claimAt;
        require(block.timestamp >= claimAt, "Staking: is not the due date");
        stakeInfo[sender][_stakeTime].claimAt = block.timestamp;
        stakeInfo[sender][_stakeTime].isClaim = true;
        uint amount = stakeInfo[sender][_stakeTime].totalAmount;
        tokenCt.transfer(sender, amount);
        emit ClaimToken(sender,_stakeTime, amount);
    }

    //setter
    function setStrategyInfo(Strategy _strategy, uint _apy) external onlyOwner {
        uint time;
        uint months;
        uint apy = _apy * 1000;
        if(_strategy == Strategy.ThreeMonths){
            time = secondsPerMonth * 3;
            months = 3;
        }else if(_strategy == Strategy.SixMonths) {
            time = secondsPerMonth * 6;
            months = 6;
        }else {
            time = secondsPerMonth * 12;
            months = 12;
        }
        strategyInfo[_strategy] = StrategyInfo(months,time, apy);
    }
  
    // input _amount value is eth not wei
    function setMinTokenStake(uint _amount) external onlyOwner {
        minTokenStake = _amount* 10**decimals;
    }

    function setFeeToStake(uint _fee) external onlyOwner {
        feeToStake = _fee * 1000;
    }

    //getter
    function getFeeToStake() external view returns(uint) {
        return feeToStake;
    }

    function getTotalUserAndAmount() external view returns(uint totalToken, uint total){
        totalToken = totalTokenInPool;
        total = stakerInPool.length;
        return(totalToken, total);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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