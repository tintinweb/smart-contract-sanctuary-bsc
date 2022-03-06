// SPDX-License-Identifier: NO-LICENSE
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
//

interface IERC20 {
  function totalSupply() external view returns (uint256);

  function balanceOf(address who) external view returns (uint256);

  function allowance(address owner, address spender)
    external view returns (uint256);

  function transfer(address to, uint256 value) external returns (bool);

  function approve(address spender, uint256 value)
    external returns (bool);

  function transferFrom(address from, address to, uint256 value)
    external returns (bool);

  event Transfer(
    address indexed from,
    address indexed to,
    uint256 value
  );

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

interface IUniswapV2Factory {
  function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface IUniswapV2Pair {
  function factory() external view returns (address);
  function token0() external view returns (address);
  function token1() external view returns (address);
}

contract TokenLocker is Pausable, Ownable {
    uint256 public price;
    uint256 public penaltyfee;
    address factory;

    struct holder {
        address holderAddress;
        mapping(address => Token) tokens;
    }

    struct Token {
        uint256 balance;
        address tokenAddress;
        uint256 unlockTime;
    }
    
    mapping(address => holder) public holders;

    constructor(address _owner, uint256 _price, address _factory) {
        transferOwnership(_owner);
        price = _price;
        penaltyfee = 10; // default value
        factory = _factory;
    }
    
    event Hold(address indexed holder, address token, uint256 amount, uint256 unlockTime);

    event PanicWithdraw(address indexed holder, address token, uint256 amount, uint256 unlockTime);

    event Withdrawal(address indexed holder, address token, uint256 amount);

    event FeesClaimed();
    
    event SetOwnerSuccess(address owner);
    
    event SetPriceSuccess(uint256 _price);
    
    event SetPenaltyFeeSuccess(uint256 _fee);
    
    event OwnerWithdrawSuccess(uint256 amount);

    function lpLock(address token, uint256 amount, uint256 unlockTime) payable public {
        require(msg.value >= price, "Required price is low");

        holder storage holder0 = holders[msg.sender];
        holder0.holderAddress = msg.sender;
        
        Token storage lockedToken = holders[msg.sender].tokens[token];
        
        if (lockedToken.balance > 0) {
            
            lockedToken.balance += amount;

            if (lockedToken.unlockTime < unlockTime) {
                lockedToken.unlockTime = unlockTime;
            }
        }
        else {
            holders[msg.sender].tokens[token] = Token(amount, token, unlockTime);
        }

        IERC20(token).transferFrom(msg.sender, address(this), amount);
        // uint256 balance = IERC20(token).balanceOf(address(this));

        emit Hold(msg.sender, token, amount, unlockTime);
    }
    
    function withdraw(address token) public {
        holder storage holder0 = holders[msg.sender];
        require(msg.sender == holder0.holderAddress, "Only available to the token owner.");
        require(block.timestamp > holder0.tokens[token].unlockTime, "Unlock time not reached yet.");
        
        uint256 amount = holder0.tokens[token].balance;
        holder0.tokens[token].balance = 0;
        
        IERC20(token).transfer(msg.sender, amount);
        emit Withdrawal(msg.sender, token, amount);
    }

    function panicWithdraw(address token) public {
        holder storage holder0 = holders[msg.sender];
        require(msg.sender == holder0.holderAddress, "Only available to the token owner.");

        uint256 feeAmount = (holder0.tokens[token].balance / 100) * penaltyfee;
        uint256 withdrawalAmount = holder0.tokens[token].balance - feeAmount;

        holder0.tokens[token].balance = 0;
        
        //Transfers fees to the contract administrator/owner
        // holders[address(owner)].tokens[token].balance = feeAmount;
        
        // Transfers fees to the token owner
        IERC20(token).transfer(msg.sender, withdrawalAmount);
        
        // Transfers fees to the contract administrator/owner
        IERC20(token).transfer(owner(), feeAmount);
        emit PanicWithdraw(msg.sender, token, withdrawalAmount, holder0.tokens[token].unlockTime);
    }
    
    function ownerWithdraw(address token) public onlyOwner {   
        uint256 balance = IERC20(token).balanceOf(address(this));
        IERC20(token).transfer(owner(), balance);

        emit OwnerWithdrawSuccess(balance);
    }
    
    function getcurtime() public view returns (uint256) {
        return block.timestamp;
    }

    function GetBalance(address token) public view returns (uint256) {
        Token storage lockedToken = holders[msg.sender].tokens[token];
        return lockedToken.balance;
    }
    
    function SetPrice(uint256 _price) public onlyOwner {
        price = _price;
        emit SetPriceSuccess(price);
    }
    
    // function GetPrice() public view returns (uint256) {
    //     return price;
    // }
    
    function SetPenaltyFee(uint256 _penaltyfee) public onlyOwner {
        penaltyfee = _penaltyfee;
        emit SetPenaltyFeeSuccess(penaltyfee);
    }
    
    // function GetPenaltyFee() public view returns (uint256) {
    //     return penaltyfee;
    // }
    
    function GetUnlockTime(address token) public view returns (uint256) {
        Token storage lockedToken = holders[msg.sender].tokens[token];
        return lockedToken.unlockTime;
    }
    
    function checkLp(address _lpToken) public view returns (bool) {
        IUniswapV2Pair pair = IUniswapV2Pair(_lpToken);
        address factoryPair = IUniswapV2Factory(factory).getPair(pair.token0(), pair.token1());
        return factoryPair == _lpToken;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
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