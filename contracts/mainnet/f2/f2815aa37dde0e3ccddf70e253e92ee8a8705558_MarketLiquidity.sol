/**
 *Submitted for verification at BscScan.com on 2023-01-22
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

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

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
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

interface IWOLFPACKStakingManager {
    function notifyReward(uint256 amount) external;
}

interface IWOLFPACKRewardManager {
    function notifyReward(address rewardee, bool predictionQualified, bool liquidityQualified, bool managementQualified) external;
}

/// @title MarketLiquidity
/// @author 'LONEWOLF'
///
/// Staking contract for MARKET currency tokens. 
/// MARKET currency (ETH) is collected by this contract (via prediction fees) and used 
/// as a fallback in the event a prediction market payout does not meet the 
/// MRT (Minimum Reward Threshold)
///
/// Accounts may stake MARKET currency (ETH) and be 
/// rewarded with fee-generated market currency (ETH).
/// Rewards weighted by proportional stake and time staked.

contract MarketLiquidity is Ownable, ReentrancyGuard {

    struct StakeData {
        uint256 storedRewards;
        uint256 timestamp;
    }

    mapping(address => uint256) public balances;
    mapping(address => StakeData) public userStake;

    uint256 public totalStaked;
    uint256 public rewards; 
    uint256 public period;
    uint256 public qualifier;
    address public WPACKRewardManager = 0x3D68386dC11EB41Ec1074D2b03aB1DB66341E1d6; 
    address payable public WPACKStakingManager = payable(0xcFBeD56c74227CaEf68880A4BB4461b992C320fA); 
    address payable public WOLFYBridge = payable(0xab7200ec2E8F771e7570f35a3DB56834952075C2);
    address[] private authorizedCallers;

    constructor(uint256 _qualifier, uint256 _period) {
        qualifier = _qualifier;
        period = _period;
    }

    event Staked(address indexed staker, uint256 amount);
    event Withdrawn(address indexed staker, uint256 amount);
    event RewardClaimed(address indexed staker, uint256 amount);
    event MarketPayoutExecuted(address indexed market, uint256 payout);

    function updatePeriod(uint256 _period) external onlyOwner {
        period = _period;
    }

    function addAuthorizedCaller(address _caller) external onlyOwner {
        authorizedCallers.push(_caller);
    }

    // market decommission
    function removeAuthorizedCaller(address _caller) external onlyOwner {
        uint256 len = authorizedCallers.length;
        for (uint256 i; i < len - 1; i++) {
            while (authorizedCallers[i] == _caller) {
                // shift index, pop. 
                authorizedCallers[i] = authorizedCallers[i + 1];   
            }
        }
        authorizedCallers.pop();
    }

    function modifyQualifier(uint256 _qualifier) external onlyOwner {
        qualifier = _qualifier;
    }

    function modifyWPACKStakingManagerAddr(address payable _WPACKStakingManager) external onlyOwner {
        WPACKStakingManager = _WPACKStakingManager;
    }

    function stake(uint256 amount) external payable {
        require(amount > 0 && amount == msg.value, "invalid amount");
        if (amount >= qualifier) {
            notifyWOLFPACKRewardManager(msg.sender);
        }
        balances[msg.sender] += amount;
        userStake[msg.sender].storedRewards = rewards;
        userStake[msg.sender].timestamp = block.timestamp;
        totalStaked += amount;
        emit Staked(msg.sender, amount);
    }

    function withdraw(uint256 amount) public nonReentrant {
        require(amount <= balances[msg.sender]);
        require(block.timestamp > userStake[msg.sender].timestamp + period);
        uint256 fee = amount / 200; // 0.5%
        distributeWithdrawalFee(fee);
        uint256 withdrawal = amount - fee;
        balances[msg.sender] -= amount;
        address payable recipient = payable(msg.sender);
        (bool success, ) = recipient.call{value: withdrawal}("");
        require(success, "failed to send ether");
        emit Withdrawn(msg.sender, withdrawal);
    }

    function claimRewards(bool isExit) public nonReentrant {
        uint256 rew = earned();
        require(rew > 0, "no reward earned");
        require(rew < rewards, "too many rewards");
        if (!isExit) {
            userStake[msg.sender].timestamp = block.timestamp; 
        }
        address payable recipient = payable(msg.sender);
        (bool success, ) = recipient.call{value: rew}("");
        require(success, "failed to send ether");
        emit RewardClaimed(msg.sender, rew);
    }

    function exit() external {
        claimRewards(true);
        withdraw(balances[msg.sender]);
    }

    function compound() external nonReentrant {
        uint256 rew = earned();
        require(rew > 0, "no reward earned");
        balances[msg.sender] += rew;
        userStake[msg.sender].storedRewards = rewards;
        userStake[msg.sender].timestamp = block.timestamp;
        totalStaked += rew;
    }

    function earned() public view returns (uint256) {
        uint256 share = (balances[msg.sender] * 100) /  totalStaked;
        uint256 rate = getRate();
        uint256 duration = block.timestamp - userStake[msg.sender].timestamp;
        uint256 earn = (share * rate * duration) / 100;
        return earn;
    }

    function getRate() private view returns (uint256) {
        uint256 average;
        uint256 r0 = userStake[msg.sender].storedRewards;
        uint256 r1 = rewards;
        if (r0 > r1) {
            average = (r0 - r1) / 2;
        }
        else if (r1 > r0) {
            average = (r1 -r0) / 2;
        }
        else if (r0 == r1) {
            average = r0;
        }
        return (average / period);
    }

    function notifyReward(uint256 amount) public nonReentrant {
        require(checkNotificationSource(msg.sender), "unauthorized caller");
        rewards += amount;
    }

    function requestMarketPayout(uint256 payout) public view returns (uint256) {
        uint256 ret;
        if (payout < rewards) {
            ret = rewards - payout;
        }
        else {
            ret = rewards;
        }
        return ret;
    }

    function getMarketPayout(uint256 amount) public nonReentrant {
        require(checkNotificationSource(msg.sender), "unauthorized caller");
        require(address(this).balance <= amount, "return exceeds contract balance");
        rewards -= amount;
        address payable marketCaller = payable(msg.sender); 
        (bool success, ) = marketCaller.call{value: amount}("");
        require(success, "failed to send ether");
        emit MarketPayoutExecuted(msg.sender, amount);
    }

    function distributeWithdrawalFee(uint256 fee) private {
        uint256 base = fee / 10; // 0.05%
        uint256 WPACKStakers = base * 4; // 0.2%
        uint256 WOLFYStakers = base * 2; // 0.1%
        uint256 marketLiquidityReserve = base * 3; // 0.15% 
        uint256 ecosystem = base;

        rewards += marketLiquidityReserve;
        IWOLFPACKStakingManager(WPACKStakingManager).notifyReward(WPACKStakers);
        address payable operator = payable(owner());
        (bool successOwner, ) = operator.call{value: ecosystem}("");
        require(successOwner, "failed to send ether");
        (bool successContract, ) = WPACKStakingManager.call{value: WPACKStakers}("");
        require(successContract, "failed to send ether");
        (bool successWolfy, ) = WOLFYBridge.call{value: WOLFYStakers}("");
        require (successWolfy, "failed to send ether");
    }

    function checkNotificationSource(address caller) private view returns (bool) {
        bool auth;
        uint256 len = authorizedCallers.length;
        for (uint256 i; i < len; i++) {
            address authCaller = authorizedCallers[i];
            if (caller == authCaller) {
                auth = true;
            }
        }
        return auth;
    }

    function notifyWOLFPACKRewardManager(address rewardee) private {
        IWOLFPACKRewardManager(WPACKRewardManager).notifyReward(rewardee, false, true, false);
    }

    receive() external payable {}

}