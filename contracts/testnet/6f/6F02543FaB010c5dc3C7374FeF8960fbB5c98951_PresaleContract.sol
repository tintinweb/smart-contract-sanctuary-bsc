/**
 *Submitted for verification at BscScan.com on 2023-03-31
*/

// SPDX-License-Identifier: UNLICENSED
/**
 *Submitted for verification at BscScan.com on 2022-10-03
*/

// File: @openzeppelin/contracts/security/ReentrancyGuard.sol


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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

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

// File: @openzeppelin/contracts/utils/Context.sol


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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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

// File: PresaleContract.sol


pragma solidity ^0.8.4;




contract PresaleContract is Ownable, ReentrancyGuard {

    /* ========== CONSTANTS AND STATE VARIABLES ========== */
    IERC20 private constant TALContract = IERC20(0x4547cD91103aDe80ceba21c8344c4DAD1DcF8A53);
    IERC20 private constant USDTContract = IERC20(0x337610d27c682E347C9cD60BD4b3b107C9d34dDd);
    address constant AdminAddress = 0x2F68E5c445e5D86b32E30A63cCa66c2B3f53C032;
    uint256[] private roundLengths = [2592000,3283200,3888000,5270400];
    uint256[] private talSupplies = new uint256[](roundLengths.length);
    uint256 private timestampStart = 0;

    /* ========== CONSTRUCTOR ========== */
    constructor() {}

    /* ========== VIEWS ========== */

    function getRoundLengths() external view returns (uint256[] memory) {
        return roundLengths;
    }

    function totalTalSupplies() external view returns (uint256[] memory) {
        return talSupplies;
    }

    function getCurrentRound() external view returns (uint256) {
        if (timestampStart == 0) return 0;

        uint256 totalRounds = roundLengths.length;
        uint256 currentRound = 1;

        for (uint256 i = 1; i < totalRounds + 1; i++) {
            uint256 roundTimestamp = timestampStart + roundLengths[i - 1];

            if (roundTimestamp >= block.timestamp) {
                currentRound = i;
                break;
            }

            if (i == totalRounds) currentRound = totalRounds;
        }

        return currentRound;
    }

    function getRoundIsFinished(uint256 round) external view returns (bool) {
        require(round > 0, "Invalid round");

        uint256 totalRounds = roundLengths.length;
        uint256 roundTimestamp = timestampStart + roundLengths[round - 1];

        if(round == totalRounds)
            return false;
        if (roundTimestamp <= block.timestamp)
            return true;

        return false;
    }

    /* ========== MUTATIVE FUNCTIONS ========== */
    function buyTALTokenByBNB(
        uint256 _amountTAL,
        uint256 round
    )
        external
        payable
        nonReentrant
        isStarted
        checkRoundTalSupply(_amountTAL, round)
    {
        require(_amountTAL > 0, "Amount TAL must be more than 0");
        require(msg.value > 0, "Invalid buyer supply");
        bool isFinished = this.getRoundIsFinished(round);
        require(isFinished == false, "The round is finished");

        payable(owner()).transfer(msg.value);
        TALContract.transfer(msg.sender, _amountTAL);
        talSupplies[round - 1] -= _amountTAL;

        emit BuyTALTokenByBNB(
            msg.sender, 
            _amountTAL,
            msg.value
        );
    }

    function buyTALTokenByUSDT(
        uint256 _amountTAL,
        uint256 _amountUSDT,
        uint256 round
    ) external nonReentrant isStarted checkRoundTalSupply(_amountTAL, round) {
        require(_amountTAL > 0, "Amount TAL must be more than 0");
        bool isFinished = this.getRoundIsFinished(round);
        require(isFinished == false, "The round is finished");

        USDTContract.transferFrom(
            msg.sender,
            owner(),
            _amountUSDT
        );

        TALContract.transfer(msg.sender, _amountTAL);
        talSupplies[round - 1] -= _amountTAL;

        emit BuyTALTokenByUSDT(
            msg.sender,
            _amountTAL,
            _amountUSDT
        );
    }

    function buyTALTokenByCash(
        uint256 _amountTAL,
        uint256 round,
        address receiver
    ) external nonReentrant isStarted checkRoundTalSupply(_amountTAL, round) {
        require(_amountTAL > 0, "Amount TAL must be more than 0");
        bool isFinished = this.getRoundIsFinished(round);
        require(isFinished == false, "The round is finished");

        TALContract.transfer(receiver, _amountTAL);
        talSupplies[round - 1] -= _amountTAL;

        emit BuyTALTokenByCash(
            receiver, 
            _amountTAL
        );
    }

    /* ========== OWNER FUNCTIONS ========== */
    function start() external onlyOwner {
        require(timestampStart == 0, "Presale started");

        uint256 currentTimestamp = block.timestamp;

        timestampStart = currentTimestamp;

    }

    function fundContractBalance(uint256 _amount, uint256 _round)
        external
        onlyOwner
    {
        require(_amount > 0, "Invalid fund");

        if (_round == 0) talSupplies.push(_amount);
        else talSupplies[_round - 1] += _amount;

        TALContract.transferFrom(msg.sender, address(this), _amount);
    }

    function withdrawTALToken(address receiver, uint256 _round)
        external
        onlyOwner
    {
        require(talSupplies.length > 0, "TAL supply is 0");
        require(
            _round <= roundLengths.length && _round > 0,
            "Round is not existed"
        );
        require(talSupplies[_round - 1] > 0, "Round supply is 0");

        uint256 totalCurrentSupply = talSupplies[_round - 1];

        talSupplies[_round - 1] = 0;

        TALContract.transfer(receiver, totalCurrentSupply);
    }

    /* ========== MODIFIERS ========== */
    modifier isStarted() {
        require(timestampStart > 0, "The round has not started yet");

        _;
    }

    modifier checkRoundTalSupply(uint256 _amount, uint256 _round) {
        require(_round <= roundLengths.length, "Round is not existed");
        require(_round > 0, "Round is not equal to 0");

        uint256 roundSupply = talSupplies[_round - 1];

        require(roundSupply >= _amount, "The round supply is not enough");

        _;
    }

    /* ========== EVENTS ========== */
    event BuyTALTokenByBNB(
        address indexed buyer,
        uint256 talAmount,
        uint256 bnbAmount
    );
    event BuyTALTokenByUSDT(
        address indexed buyer,
        uint256 talAmount,
        uint256 usdtAmount
    );
    event BuyTALTokenByCash(
        address indexed buyer,
        uint256 talAmount
    );
}