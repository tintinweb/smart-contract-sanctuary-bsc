// SPDX-License-Identifier: NO-LICENSE
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
// import "hardhat/console.sol";

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
    uint256 private price;
    uint256 private penaltyfee;
    address private factory;

    struct holder {
        address holderAddress;
        mapping(address => Token[]) tokens;
    }

    struct Token {
        uint256 balance;
        address tokenAddress;
        uint256 unlockTime;
        bool exists;
    }
    
    mapping(address => holder) private holders;

    // mapping(address => uint256[]) private lockTimestamps;

    constructor(address _owner, uint256 _price, address _factory) {
        transferOwnership(_owner);
        price = _price;
        penaltyfee = 10;
        factory = _factory;
    }
    
    event Hold(address indexed holder, address token, uint256 amount, uint256 unlockTime);

    event PanicWithdraw(address indexed holder, address token, uint256 amount);

    event Withdrawal(address indexed holder, address token, uint256 amount);

    event FeesClaimed();
    
    event SetOwnerSuccess(address owner);
    
    // event SetPriceSuccess(uint256 _price);
    
    // event SetPenaltyFeeSuccess(uint256 _fee);
    
    event OwnerWithdrawSuccess(uint256 amount);

    event OwnerWithdrawSuccessBNB(uint256 amount);

    function tkrevLiquidityLock(address token, uint256 amount, uint256 unlockTime) payable public {
        lock(token, amount, unlockTime);
    }

    function tkrevTokenLock(address token, uint256 amount, uint256 unlockTime) payable public {
        lock(token, amount, unlockTime);
    }
    
    function lock(address token, uint256 amount, uint256 unlockTime) private {
        require(msg.value >= price, "Required price is low");
        // Risky. Better to enforce on the DAPP
        // require(unlockTime >= block.timestamp, "Cannot use a past date");

        // Fetch holder and token addresses
        holder storage holder0 = holders[msg.sender];
        holder0.holderAddress = msg.sender;
        
        // Transfer amount
        uint256 balanceBefore = IERC20(token).balanceOf(address(this));
        IERC20(token).transferFrom(msg.sender, address(this), amount);
        uint256 transferredAmount = IERC20(token).balanceOf(address(this)) - balanceBefore;

        // Add new lock
        holders[msg.sender].tokens[token].push(
            Token(
                transferredAmount, 
                token, 
                unlockTime,
                true));
        // lockTimestamps[token].push(unlockTime);

        emit Hold(msg.sender, token, transferredAmount, unlockTime);
    }
    
    function withdraw(address token) public {
        holder storage holder0 = holders[msg.sender];
        require(msg.sender == holder0.holderAddress, "Only available to the token owner.");
        uint256 amount = getPayableLockedAmount(msg.sender, token, false);
        require(amount > 0, "No lock found that is already expired");
        IERC20(token).transfer(msg.sender, amount);
        emit Withdrawal(msg.sender, token, amount);
    }

    function panicWithdraw(address token) public {
        holder storage holder0 = holders[msg.sender];
        require(msg.sender == holder0.holderAddress, "Only available to the token owner.");
        uint256 amount = getPayableLockedAmount(msg.sender, token, true);
        require(amount > 0, "No locked tokens found");
        uint256 feeAmount = (amount / 100) * penaltyfee;
        uint256 withdrawalAmount = amount - feeAmount;

        //Transfers fees to the contract administrator/owner
        // holders[address(owner)].tokens[token].balance = feeAmount;
        
        // Transfers fees to the token owner
        IERC20(token).transfer(msg.sender, withdrawalAmount);
        
        // Transfers fees to the contract administrator/owner
        IERC20(token).transfer(owner(), feeAmount);
        emit PanicWithdraw(msg.sender, token, withdrawalAmount);
    }
    
    function ownerWithdraw(address token) public onlyOwner {   
        uint256 balance = IERC20(token).balanceOf(address(this));
        IERC20(token).transfer(owner(), balance);
        // console.log("TokenLocker.ownerWithdraw",balance);
        emit OwnerWithdrawSuccess(balance);
    }
    
    function ownerWithdrawBNB() public onlyOwner {
        uint256 balance = address(this).balance;
        if (balance > 0) {
            (bool ret,) = payable(owner()).call{value: balance }("");
            require(ret, "Withdraw of BNBs failed");
            // console.log("TokenLocker.ownerWithdrawBNB",balance);
            emit OwnerWithdrawSuccessBNB(balance);
        }
    }

    // function SetPrice(uint256 _price) public onlyOwner {
    //     price = _price;
    //     emit SetPriceSuccess(price);
    // }
    
    // function SetPenaltyFee(uint256 _penaltyfee) public onlyOwner {
    //     penaltyfee = _penaltyfee;
    //     emit SetPenaltyFeeSuccess(penaltyfee);
    // }

    function GetLocks(address token) public view returns (Token[] memory) {
        return holders[msg.sender].tokens[token];
    }
    
    function checkLp(address _lpToken) public view returns (bool) {
        IUniswapV2Pair pair = IUniswapV2Pair(_lpToken);
        address factoryPair = IUniswapV2Factory(factory).getPair(pair.token0(), pair.token1());
        return factoryPair == _lpToken;
    }

    function getPayableLockedAmount(    
        address sender,
        address token,
        bool panic) internal returns (uint256) {
        holder storage holder0 = holders[sender];
        Token[] memory locks = holder0.tokens[token];

        uint256 amount = 0;
        uint256 locksLength = locks.length;
        // Withdraw all amounts that are unlocked
        for (uint8 i = 0; i < locksLength; i++) {
            // console.log("Iteration #%s",i);
            Token memory _lock = locks[i];
            if (panic || _lock.unlockTime < block.timestamp) {
                amount += _lock.balance;
                delete holder0.tokens[token][i];
                // console.log("Deleted %s",holder0.tokens[token][i].balance);
            }
        }
        return amount;
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