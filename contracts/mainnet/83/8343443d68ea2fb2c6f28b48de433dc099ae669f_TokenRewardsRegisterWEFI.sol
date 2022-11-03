/**
 *Submitted for verification at BscScan.com on 2022-11-03
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

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
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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
}

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
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}

contract TokenRewardsRegisterWEFI is Context, ReentrancyGuard {
    IERC20 public tokenAddress;
    uint256 public constant registerDurationForRewards = 2629743;
    uint256 private constant _monthlyUnixTime = registerDurationForRewards;
    uint256 private _totalBalanceWEFI = 0;

    mapping(address => uint256) private _balances;
    mapping(address => uint256) private _registerTime;

    event RegisteredWEFI(address beneficiary, uint256 amount);
    event UnregisteredWEFI(address beneficiary, uint256 amount);
    event ClaimedWEFI(address beneficiary, uint256 amount);
    event TotalWEFIUpdated(uint256 amount);
    event UserWEFIUpdated(uint256 amount);

    modifier ifRegisterExists(address beneficiary) {
        require(
            balanceOf(beneficiary) > 0,
            "TokenRewardsRegisterWEFI: no registered amount exists for respective beneficiary"
        );
        _;
    }

    constructor(address _tokenAddress) {
        require(
            _tokenAddress != address(0x0),
            "TokenPresaleWEFI: token contract address must not be null"
        );
        tokenAddress = IERC20(_tokenAddress);
    }

    function name() external pure returns (string memory) {
        return "Registered WEFI";
    }

    function symbol() external pure returns (string memory) {
        return "rWEFI";
    }

    function decimals() external pure returns (uint8) {
        return 18;
    }

    function totalSupply() external view returns (uint256) {
        return _totalBalanceWEFI;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function registerTokens(uint256 amount) external returns (bool) {
        address from = _msgSender();
        _registerTokens(from, amount);

        emit RegisteredWEFI(from, amount);
        emit TotalWEFIUpdated(_totalRegisteredBalanceWEFI());
        emit UserWEFIUpdated(balanceOf(from));
        return true;
    }

    function _registerTokens(address from, uint256 amount) private {
        address to = address(this);
        _balances[from] += amount;
        _totalBalanceWEFI += amount;
        _registerTime[from] = block.timestamp;

        require(
            tokenAddress.transferFrom(from, to, amount),
            "TokenRewardsRegisterWEFI: token WEFI transferFrom not succeeded"
        );
    }

    function unregisterTokens()
        external
        ifRegisterExists(msg.sender)
        nonReentrant
    {
        address to = _msgSender();
        uint256 amount = _balances[to];

        _unregisterTokens(to, amount);
    }

    function _unregisterTokens(address to, uint256 amount) private {
        _balances[to] -= amount;
        _totalBalanceWEFI -= amount;
        _registerTime[to] = 0;

        require(
            tokenAddress.transfer(to, amount),
            "TokenRewardsRegisterWEFI: token WEFI transfer not succeeded"
        );

        emit UnregisteredWEFI(to, amount);
        emit TotalWEFIUpdated(_totalRegisteredBalanceWEFI());
        emit UserWEFIUpdated(balanceOf(to));
    }

    function _isRegisteringDurationPassed(address beneficiary)
        private
        view
        returns (bool)
    {
        uint256 timePassed = block.timestamp - _registerTime[beneficiary];
        if (timePassed > registerDurationForRewards) {
            return true;
        }
        return false;
    }

    function claimRewards() external ifRegisterExists(msg.sender) nonReentrant {
        address beneficiary = _msgSender();
        uint256 claimableRewards = _claimRewards(beneficiary);

        emit ClaimedWEFI(beneficiary, claimableRewards);
    }

    function _claimRewards(address beneficiary) private returns (uint256) {
        require(
            _isRegisteringDurationPassed(beneficiary),
            "TokenRewardsRegisterWEFI: minimum duration for registering rewards not passed"
        );

        uint256 claimableRewards = _viewClaimableRewards(beneficiary);

        require(
            totalRewardsBalanceWEFI() >= claimableRewards,
            "TokenRewardsRegisterWEFI: not sufficient WEFI rewards balance in reward contract"
        );
        require(
            tokenAddress.transfer(beneficiary, claimableRewards),
            "TokenRewardsRegisterWEFI: token WEFI transfer not succeeded"
        );

        uint256 amount = _balances[beneficiary];
        _unregisterTokens(beneficiary, amount);

        return claimableRewards;
    }

    function _viewClaimableRewards(address beneficiary)
        private
        view
        returns (uint256)
    {
        uint256 registeredAmount = _balances[beneficiary];
        uint256 totalRegisteredWEFI = _totalRegisteredBalanceWEFI();
        uint256 totalRewardsWEFI = totalRewardsBalanceWEFI();

        return ((totalRewardsWEFI * registeredAmount) / totalRegisteredWEFI);
    }

    function viewClaimableRewardsAndReleaseTime(address beneficiary)
        external
        view
        returns (uint256, uint256)
    {
        if (_registerTime[beneficiary] == 0) {
            return (0, 0);
        }

        return (
            _viewClaimableRewards(beneficiary),
            (_registerTime[beneficiary] + _monthlyUnixTime)
        );
    }

    function getCurrentTime() external view returns (uint256) {
        return block.timestamp;
    }

    function _totalRegisteredBalanceWEFI() private view returns (uint256) {
        return _totalBalanceWEFI;
    }

    function totalRewardsBalanceWEFI() public view returns (uint256) {
        return (tokenAddress.balanceOf(address(this)) - _totalBalanceWEFI);
    }
}