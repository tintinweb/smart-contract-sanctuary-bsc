// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IBEP20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract IDO is Ownable {

    //price of the token
    uint256 price;
    // token that will be sold
    IBEP20 TOKEN;
    // busd token for buying the token
    IBEP20 BUSD;
    // total token can be sold
    uint256 public totalSupply;
    // total token that sent
    uint256 public totalSold;
    // total busd that received
    uint256 public totalRaised;
    // pause contract
    bool paused;


    event purchased(address buyer, uint256 tokenAmount, uint256 BUSDAmount);

    constructor(IBEP20 _token, IBEP20 _busd, uint256 _price) {
        TOKEN = _token;
        BUSD = _busd;
        price = _price;
    }

    modifier isPaused {
        require(!paused, "IDO is on pause");
        _;
    }

    function supply(uint256 _amount) public onlyOwner {
        require(TOKEN.allowance(msg.sender, address(this)) >= _amount, "You must first approve the contract to spend your token");
        require(TOKEN.transferFrom(msg.sender, address(this), _amount), "token transfer failed");
        totalSupply += _amount;
    }

    function purchase(uint256 _amount) external isPaused {
        require(BUSD.allowance(msg.sender, address(this)) >= _amount, "You must first approve the contract to spend your BUSDs");
        require(BUSD.transferFrom(msg.sender, address(this), _amount), "BUSD transfer failed");
        totalRaised += _amount;
        uint8 tokenDecimal = TOKEN.decimals();
        uint256 tokenAmount = (_amount/price)*(10**tokenDecimal);
        require(TOKEN.balanceOf(msg.sender)>tokenAmount, "Not Enough token available");
        require(TOKEN.transfer(msg.sender,tokenAmount), "Token transfer failed");
        totalSold += tokenAmount;
        emit purchased(msg.sender, tokenAmount, _amount);
    }

    function setPrice(uint256 _price) external onlyOwner {
        price = _price;
    }

    function pause() public onlyOwner isPaused{
        paused = true;
    }

    function unpause() public onlyOwner{
        require(paused, "IDO is not paused");
        paused = false;
    }

    function withdraw() external onlyOwner {
        uint256 busdAvailable = BUSD.balanceOf(address(this));
        require(busdAvailable > 0, "No BUSD to withdraw");
        BUSD.transfer(msg.sender, busdAvailable);
    }

    function withdrawRemainingTokens() external onlyOwner{
        uint256 tokenAvailable = TOKEN.balanceOf(address(this));
        require(tokenAvailable > 0, "No TOKEN to withdraw");
        TOKEN.transfer(msg.sender, tokenAvailable);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IBEP20 {

    function name() external view returns (string memory);
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
    * @dev Returns the token decimals.
    */
    function decimals() external view returns (uint8);

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
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
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