// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IRouter} from "./interfaces/IDex.sol";


contract RewardsManager is Ownable, ReentrancyGuard{

    IERC20 public immutable VIRAL;

    IRouter public router;

    bool public rewardsActive;

    mapping(address => UserData) private userData;

    struct UserData{
        uint256 amountClaimed; // total amount claimed
        uint256 lastClaimRound; // round of the last claim
        uint256 lpLocked; // amount of lpToken locked
    }
    
    uint256 public startDate;

    IERC20 public sponsorToken; // token required to claim x2
    IERC20 public lpToken; // LP token required to claim

    struct RatePerLock{
        uint256 sponsor; // rate: 1 sponsorToken = ??? VIRAL
        uint256 lp; // rate: 1 lpToken = ??? VIRAL
    }

    RatePerLock public ratesPerLock = RatePerLock(1000*10**18, 1000*10**18);

    struct AmountRequired {
        uint256 sponsor; // amount of sponsorToken required to claim x2
        uint256 lp; // amount of lpToken required to claim
    }

    AmountRequired public amountsRequired = AmountRequired(100*10**18, 100*10**18);

    event LockedAndClaimed(address user, uint256 lpLocker, uint256 claimableAmount);
    event AddedLPAndClaimed(address user, uint256 lpLocker, uint256 claimableAmount);
    event SponsorTokenUpdated(address _sponsorToken);
    event LPTokenUpdated(address _lpToken);
    event AmountsRequiredUpdated(uint256 _sponsorAmount, uint256 _lpAmount);
    event RewardsActiveUpdated(bool state);

    constructor(address _VIRAL) {
        VIRAL = IERC20(_VIRAL);
        router = IRouter(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
    }

    function addLpAndClaim(uint256 viralAmount, uint256 ethAmount) external payable nonReentrant {
        require(rewardsActive, "ERROR: RewardsMenager not active");
        require(msg.value >= ethAmount, "ERROR: Insufficient ETH balance");
        require(VIRAL.balanceOf(msg.sender) >= viralAmount, "ERROR: Insufficient VIRAL balance");
        uint256 lpAmount = addLiquidity(viralAmount, ethAmount);
        userData[msg.sender].lpLocked += lpAmount;
        (bool allowed, uint256 claimableAmount) = _canClaim(msg.sender, lpAmount);
        require(allowed, "ERROR: You can't claim now");
        userData[msg.sender].lastClaimRound = getCurrentRound();
        userData[msg.sender].amountClaimed += claimableAmount;
        VIRAL.transfer(msg.sender, claimableAmount);
        emit AddedLPAndClaimed(msg.sender, lpAmount, claimableAmount);
    }

    function addLiquidity(uint256 viralAmount, uint256 ethAmount) internal returns(uint256){
        (,, uint256 lpAmount) = router.addLiquidityETH{value: ethAmount}(
            address(VIRAL),
            viralAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(this),
            block.timestamp
        );
        return lpAmount;
    }

    /**
     * @notice Lock tokens and claim (if _sponsorToken >= amountsRequired.sponsor) claim x2
     * @param _lpAmount amount of LP token
     */
    function lockAndClaim(uint256 _lpAmount) external nonReentrant{
        require(rewardsActive, "ERROR: RewardsMenager not active");
        (bool allowed, uint256 claimableAmount) = _canClaim(msg.sender, _lpAmount);
        require(allowed, "ERROR: You can't claim now");
        require(lpToken.balanceOf(msg.sender) >= _lpAmount, "ERROR: Insufficient lpToken balance");
        require(lpToken.transferFrom(msg.sender, address(this), _lpAmount), "ERROR: Impossible to lock");
        userData[msg.sender].lpLocked += _lpAmount;
        userData[msg.sender].lastClaimRound = getCurrentRound();
        userData[msg.sender].amountClaimed += claimableAmount;
        VIRAL.transfer(msg.sender, claimableAmount);
        emit LockedAndClaimed(msg.sender, _lpAmount, claimableAmount);
    }

    /**
     * @notice Check whether it is possible to claim and the claimable amount
     * @param user address of the user
     */
    function canClaim(address user) external view returns (bool, uint256) {
        return _canClaim(user, lpToken.balanceOf(user));
    }

    function _canClaim(address _user, uint256 _lpAmount) internal view returns (bool state, uint256){
        if(userData[_user].lastClaimRound < getCurrentRound()){
            if(_lpAmount >= amountsRequired.lp){
                uint256 amount = _lpAmount * ratesPerLock.lp;
                if(sponsorToken.balanceOf(_user) >= amountsRequired.sponsor){
                    amount += amount * ratesPerLock.sponsor;
                }
                return (true,amount);
            }
        }
        return (false,0);
    }

    /**
     * @notice Update Sponsor Token required to claim
     * @param _sponsorToken address of the new sponsor token
     */
    function setSponsorToken(address _sponsorToken) external onlyOwner{
        sponsorToken = IERC20(_sponsorToken);
        emit SponsorTokenUpdated(_sponsorToken);
    }

    /**
     * @notice Update LP Token required to claim
     * @param _lpToken address of the new lpToken
     */
    function setLpToken(address _lpToken) external onlyOwner{
        lpToken= IERC20(_lpToken);
        emit LPTokenUpdated(_lpToken);
    }

    /**
     * @notice Update minimum amounts required to claim
     * @param _lpAmount amount of LP token required to claim
     * @param _sponsorAmount amount of sponsor token required to claim x2
     */
    function setAmountsRequire(uint256 _lpAmount, uint256 _sponsorAmount) external onlyOwner{
        amountsRequired = AmountRequired(_sponsorAmount, _lpAmount);
        emit AmountsRequiredUpdated(_sponsorAmount, _lpAmount);
    }

    /**
     * @notice Update rates per tokens locked
     * @param _lpAmount amount of VIRAL per 1 LP token
     * @param _sponsorAmount amount of VIRAL per 1 sponsor token
     */
    function setRatesPerLock(uint256 _lpAmount, uint256 _sponsorAmount) external onlyOwner{
        ratesPerLock = RatePerLock(_sponsorAmount, _lpAmount);
        emit AmountsRequiredUpdated(_sponsorAmount, _lpAmount);
    }

    /**
     * @notice Enable/Disable the rewards process
     * @param state "true" to enable, "false" to disable
     */
    function setRewardsActive(bool state) external onlyOwner{
        if(state && startDate == 0) startDate = block.timestamp;
        rewardsActive = state;
        emit RewardsActiveUpdated(state);
    }

    /**
     * @notice Emergency function to rescue ERC20 tokens
     * @param tokenAdd address of the token to rescue
     * @param amount amount of tokens
     */
    function rescueERC20(address tokenAdd, uint256 amount) external onlyOwner{
        IERC20(tokenAdd).transfer(owner(), amount);
    }

    /**
     * @notice Check total amount claimed and last claim round of user
     * @param user address of the user
     */
    function checkUserData(address user) external view returns(uint256 amountClaimed, uint256 lastClaimRound, uint256 lpLocked){
        return (userData[user].amountClaimed, userData[user].lastClaimRound, userData[user].lpLocked);
    }

    function getCurrentRound() public view returns(uint256 round){
        return (block.timestamp - startDate) / 7 days;
    } 
    
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
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
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

interface IPair {
    function sync() external;
}

interface IFactory{
        function createPair(address tokenA, address tokenB) external returns (address pair);
        function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface IRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline) external;
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