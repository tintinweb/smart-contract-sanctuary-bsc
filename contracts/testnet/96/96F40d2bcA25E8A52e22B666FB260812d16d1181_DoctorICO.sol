pragma solidity ^0.8.17;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DoctorICO is Ownable {
    address Doctor;

    uint256 public constant CAP = 5000 ether; // Cap in bnb
    uint256 public constant FIRST_RATE = 500; // Number of tokens per Bnb at first step
    uint256 public constant SECOND_RATE = 400; // Number of tokens per Bnb at second step
    uint256 public constant THIRD_RATE = 300; // Number of tokens per Bnb at third step
    uint256 public START; // start date of ICO
    uint256 public FIRST_DAYS;  // end date of first step
    uint256 public SECOND_DAYS; // end date of second step
    uint256 public THIRD_DAYS; // end date of third step

    uint16 public airdropReferRate = 100; //10%
    uint16 public buyReferRate = 100; //10%
    uint256 public airdropFee = 0.01 ether;
    uint256 public airdropAmount = 10000 ether;
    uint256 public minBuyAmount = 100 ether; //at least have to buy 100 token per once

    uint256 public constant initialTokens = 2000000 * 10**18; // Initial number of tokens available
    bool public initialized = false;
    uint256 public raisedAmount = 0;

    mapping(address => bool) public airDropStatus;

    event BoughtTokens(address indexed to, uint256 value);
    event UsedReferLink(address indexed to, uint256 value);

    modifier whenSaleIsActive() {
        // Check if sale is active
        require(isActive(), "Sale is not active now!");
        _;
    }

    constructor(uint256 _START, uint8 first, uint8 second, uint8 third) {
        START = _START;
        FIRST_DAYS = START + first * 1 days;
        SECOND_DAYS = FIRST_DAYS + second * 1 days;
        THIRD_DAYS = SECOND_DAYS + third * 1 days;
    }

    function setToken(address _tokenAddr) public onlyOwner {
        Doctor = _tokenAddr;
    }

    function initialize() public onlyOwner {
        require(initialized == false, "Can only be initialized once.");
        require(
            tokensAvailable() == initialTokens,
            "Must have enough tokens allocated"
        );
        initialized = true;
    }

    function isActive() public view returns (bool) {
        return (initialized == true &&
            block.timestamp >= START && // Must be after the START date
            block.timestamp <= THIRD_DAYS && // Must be before the end date
            goalReached() == false); // Goal must not already be reached
    }

    function getICOPrice() public view returns (uint256) {
        uint256 rate;
        if (block.timestamp <= FIRST_DAYS) rate = FIRST_RATE;
        if (block.timestamp <= SECOND_DAYS && block.timestamp > FIRST_DAYS) return rate = SECOND_RATE;
        if (block.timestamp <= THIRD_DAYS && block.timestamp > SECOND_DAYS) return rate = THIRD_RATE;
        return rate;
    }

    function goalReached() public view returns (bool) {
        return raisedAmount >= CAP;
    }

    function airDrop(address _refer) public payable {
        require(msg.value == airdropFee && !airDropStatus[msg.sender], "Not enough fee!");
        IERC20(Doctor).transfer(msg.sender, airdropAmount);
        if (_refer != msg.sender && _refer != address(0)) {
            IERC20(Doctor).transfer(
                _refer,
                (airdropReferRate * airdropAmount) / 1000
            );
        }
        airDropStatus[msg.sender] = true;
        payable(owner()).transfer(msg.value); // Send money to owner
    }

    function buyTokens(address _refer) public payable whenSaleIsActive {
        uint256 RATE = getICOPrice();
        require(
            msg.value * RATE >= minBuyAmount,
            "Have to buy more than minimum amount."
        );
        uint256 buyAmount = msg.value * RATE;
        emit BoughtTokens(msg.sender, buyAmount); // log event onto the blockchain
        raisedAmount += msg.value; // Increment raised amount
        IERC20(Doctor).transfer(
            msg.sender,
            buyAmount
        ); // Send tokens to refer
        if (_refer != msg.sender && _refer != address(0)) {
            uint256 referAmount = (buyAmount * buyReferRate) / 1000;
            IERC20(Doctor).transfer(msg.sender, referAmount); // Send tokens to buyer
            emit UsedReferLink(_refer, referAmount);
        }
        payable(owner()).transfer(msg.value); // Send money to owner
    }

    function setAirdropParam(uint16 _airdropReferRate, uint256 _airdropFee, uint256 _airdropAmount) public onlyOwner{
        airdropReferRate = _airdropReferRate;
        airdropFee = _airdropFee;
        airdropAmount = _airdropAmount;
    }

    function setBuyParam(uint16 _buyReferRate, uint256 _minBuyAmount) public onlyOwner {
        buyReferRate = _buyReferRate;
        minBuyAmount = _minBuyAmount;
    }

    function tokensAvailable() public view returns (uint256) {
        return IERC20(Doctor).balanceOf(address(this));
    }

    function destroy() public onlyOwner {
        // Transfer tokens back to owner
        uint256 restAmount = tokensAvailable();
        if (restAmount > 0) {
            IERC20(Doctor).transfer(owner(), restAmount);
        }
        selfdestruct(payable(owner()));
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