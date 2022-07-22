/**
 *Submitted for verification at BscScan.com on 2022-07-22
*/

//SPDX-License-Identifier:NOLICENSE
pragma solidity 0.8.14;

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
    event Approval(address indexed owner, address indexed spender, uint256 value);

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

pragma solidity 0.8.14;

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

pragma solidity 0.8.14;

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

pragma solidity 0.8.14;

abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
     */
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!Address.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }
}

pragma solidity 0.8.14;

library SafeCast {
    /**
     * @dev Returns the downcasted uint64 from uint256, reverting on
     * overflow (when the input is greater than largest uint64).
     *
     * Counterpart to Solidity's `uint64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     *
     * _Available since v2.5._
     */
    function toUint64(uint256 value) internal pure returns (uint64) {
        require(value <= type(uint64).max, "SafeCast: value doesn't fit in 64 bits");
        return uint64(value);
    }
}

pragma solidity 0.8.14;

library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }
}

pragma solidity 0.8.14;

contract Escrow is Ownable,Initializable {
    using SafeCast for uint256;

    struct CoreTeam {
        address account;
        uint allocated;
        uint released;
        uint64 startTime;
        uint64 lastClaim;
    }

    struct Dividend {
        address token;        
        uint initialRelease;        
        uint64 period;
        uint64 cliffTime;
        uint16 percent;
        bool isInitialReleased;
    }

    uint16 constant DIVISOR = 10000;
    Dividend public dividend;
    CoreTeam public coreTeam;

    event Claim(
        address indexed account,
        uint dividend,
        uint time
    );

    ///@dev Initializing the contract setting
    ///@param dividentParams parameters of dividend
    ///@param coreTeamAddress coreTeam address
    ///@param allocated coreTeam allocation amount in wei
    ///@param allocated coreTeam start time
    function initialize(Dividend memory dividentParams, address coreTeamAddress, uint allocated, uint64 startTime) external onlyOwner initializer {
        require(!isZero(uint160(dividentParams.token)), "the dividend token must not be zero");
        require(!isZero(uint160(coreTeamAddress)), "the coreTeam address must not be zero");
        require(!isZero(dividentParams.cliffTime), "the dividend cliff must be higher than zero");
        require(dividentParams.percent <= DIVISOR, "the dividend percent must be lesser than divisor");
        require(dividentParams.initialRelease <= DIVISOR, "the dividend initial release must be less than divisor");
        require(!isZero(dividentParams.period), "the dividend period must not be zero");
        require(startTime >= blockTimestamp(), "the start time must not be lesser than current block");
        require(!isZero(allocated), "the coreTeam allocation must not be zero");
        
        dividend = dividentParams;
        coreTeam.account = coreTeamAddress;
        coreTeam.allocated = allocated;
        coreTeam.lastClaim = coreTeam.startTime = startTime;
    }

    receive() external payable {
        require(isZero(msg.value), "receive: the contract will not accept");
    }

    fallback() external {
        revert("fallback: no fallback");
    }

    ///@dev update the coreTeam address
    ///@param coreTeamAddress coreTeam address
    function updateCoreTeam(address coreTeamAddress) external onlyOwner {
        require(!isZero(uint160(coreTeamAddress)), "updateCoreTeam: the coreTeam address must not be zero");
        coreTeam.account = coreTeamAddress;
    }

    ///@dev update the dividend token address
    ///@param token token address
    function updateDivToken(address token) external onlyOwner {
        require(!isZero(uint160(token)), "updateDivToken: the dividend token must not be zero");
        dividend.token = token;
    }

    ///@dev update the dividend cliff time
    ///@param cliffTime cliff time in epoch
    function updateDivCliff(uint64 cliffTime) external onlyOwner {
        require(!isZero(cliffTime), "updateDivCliff: the dividend cliff must not be zero");
        dividend.cliffTime = cliffTime;
    }

    ///@dev update the dividend percentage
    ///@param percent percentage, 10000 equals to 100%
    function updateDivPercent(uint16 percent) external onlyOwner {
        require(percent <= DIVISOR, "updateDivPercent: the dividend percent must be lesser than divisor");
        dividend.percent = percent;
    }

    ///@dev update the dividend period
    ///@param period dividend period in seconds
    function updateDivPeriod(uint64 period) external onlyOwner {
        require(!isZero(period), "updateDivPeriod: the dividend period must not be zero");
        dividend.period = period;
    }

    ///@dev coreTeam address claim its dividends from here
    function claim() external {
        require(coreTeam.account == _msgSender(), "claim: the coreTeam wallet is not a caller");
        require(!isZero(coreTeam.startTime), "claim: start time must not be zero");
        require(!isZero(coreTeam.allocated), "claim: allocation must not be zero");
        require(coreTeam.released <= coreTeam.allocated, "claim: the coreTeam wallet has claimed all dividends");

        if(!dividend.isInitialReleased) {
            _claimInitial();
        } else {
            require(
                coreTeam.lastClaim + dividend.period <= blockTimestamp(),
                "claim: time hasn't passed for the next dividend"
            );
            _claim();
        }
    }

    ///@dev claim initial release
    function _claimInitial() private {
        dividend.isInitialReleased = true;
        coreTeam.released += (coreTeam.allocated * dividend.initialRelease) / DIVISOR;
        
        if(coreTeam.lastClaim + dividend.period <= blockTimestamp()) {
            _claim();
        }
    }

    ///@dev claim dividends
    function _claim() private {
        (uint dividends, uint claims) = viewDividend();

        if(!isZero(dividends)) {
            coreTeam.released += dividends;
            coreTeam.lastClaim += (dividend.period * claims).toUint64();

            IERC20(dividend.token).transfer(
                _msgSender(),
                dividends
            );

            emit Claim(
                _msgSender(),
                dividends,
                blockTimestamp()
            );
        }
    }

    ///@dev returns the avaiable dividend from the contract
    ///@return dividends available dividend
    ///@return claims no of available dividends
    function viewDividend() public view returns(uint dividends, uint claims) {        
        if(!isValidClaim(coreTeam)) {   
            return (0,0);
        }

        uint months = (blockTimestamp() - coreTeam.lastClaim) / dividend.period;

        if(!isZero(months)) {
            uint divAmount = (coreTeam.allocated * dividend.percent) / DIVISOR;
            dividends = divAmount * months;
            claims = months;

            if((coreTeam.released + dividends) > coreTeam.allocated) {
                dividends = coreTeam.allocated - coreTeam.released;
            }
        }
    }

    ///@dev returns true if coreTeam is allowed to claim
    ///@param wallet coreTeam info
    ///@return bool is it a valid claim, returns in boolean
    function isValidClaim(CoreTeam memory wallet) private view returns(bool) {
        return !(
            isZero(wallet.startTime) ||
            isZero(wallet.allocated) ||
            wallet.released >= wallet.allocated ||
            (wallet.startTime + (dividend.cliffTime + 1 days)) < blockTimestamp()
        );
    }

    ///@dev returns true if value contains zero
    ///@param value value
    ///@return contains if it contains zero, returns true
    function isZero(uint256 value) private pure returns (bool contains) {
        assembly {
            contains := iszero(value)
        }
    }

    ///@dev returns current block timestamp
    ///@return time returns current block timestamp
    function blockTimestamp() public view returns (uint time) {
        assembly {
            time := timestamp()
        }
    }
}