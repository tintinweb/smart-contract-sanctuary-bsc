/**
 *Submitted for verification at BscScan.com on 2022-04-06
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
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

contract SwapPool
{
    using SafeMath for uint256;

    IERC20 rabbit;
    
    address owner;

    uint256 public platformFeesForToken;
    uint256 public platformFeesForbnb;
    uint256 public tokenProvide;

    event TokenTransfer(address _to,uint256 _amount);
    event bnbTransfer(address _to,uint256 _amount);

    modifier onlyOwner {
      require(msg.sender == owner,"you are not owner");
      _;
    }
    
    constructor(
        address _token,
        address _owner,
        uint256 _platformFeesForToken,
        uint256 _platformFeesForbnb,
        uint256 _tokenProvide
    )
    {
        rabbit = IERC20(_token);
        owner = _owner;
        platformFeesForToken = _platformFeesForToken;
        platformFeesForbnb = _platformFeesForbnb;
        tokenProvide = _tokenProvide;
    }

    function setTokenPrice(
        uint256 _amount
    ) external onlyOwner
    {
        tokenProvide = _amount;   //1 bnb = _amount 
    }

    function updatePlatformFeesForToken(
        uint256 _fees
    ) external onlyOwner
    {
        platformFeesForToken = _fees;
    }    

    function updatePlatformFeesForbnb(
        uint256 _fees
    ) external onlyOwner
    {
       platformFeesForbnb = _fees;
    } 

    function updateOwner(
        address _owner
    ) external onlyOwner
    {
       owner = _owner;
    }

    function withdrawToken(uint256 _amount)
       external
       onlyOwner
    {
        rabbit.transfer(owner,_amount);
    }
    
    function withdrwaBNB(uint256 _amount)
      external
      onlyOwner
    {
        (bool success,) = owner.call{value:_amount}("");
        require(success,"refund failed");    
    }

    function swapBNBToToken(
        address _address
    ) external payable 
    {
       uint256 amountForSwap =  cutPlatformFeesForToken(msg.value);
       uint256 tokenTransfer = (amountForSwap.mul(tokenProvide)).div(10**18);
       
       require(rabbit.balanceOf(address(this))>=tokenTransfer,"Contract don't have sufficient balance");
       rabbit.transfer(_address,tokenTransfer);
       
       emit TokenTransfer(_address,tokenTransfer);
    }
     
    function swapTokenToBNB(
        address _address,
        uint256 _amount
    ) external
    {
       require(rabbit.allowance(msg.sender,address(this)) >= _amount,"allowance is not enough");
       
       rabbit.transferFrom(msg.sender,address(this),_amount);
       uint256 bnbTransferTOUser =(_amount.mul(10**18)).div(tokenProvide); 
       
       require(address(this).balance>=bnbTransferTOUser,"Contract don't have bnb");
       cutPlatformFeesForBNB(bnbTransferTOUser,_address);    
    }

    function tokenValueCalculation(uint256 _amount) 
       external
       view
       returns(
        uint256
    )
    {
       uint256 feesAmount = (_amount.mul(platformFeesForToken)).div(100);
       uint256 amountForSwap = _amount.sub(feesAmount); 
       uint256 tokenAmount = (amountForSwap.mul(tokenProvide)).div(10**18);
       return tokenAmount;
    } 

    function bnbValueCalculation(uint256 _amount)
      external
      view
      returns(
        uint256
    )
    {
        uint256 feesAmount = (_amount.mul(platformFeesForbnb)).div(100);
        uint256 amountToSend = _amount.sub(feesAmount);
        uint256 bnbAmount = (amountToSend.mul(10**18)).div(tokenProvide);  
        return bnbAmount;
    }
    
    function tokenBalance() 
      external
      view
      returns(
        uint256
    )
    {
        return rabbit.balanceOf(address(this));
    }
    
    function bnbBalance()
      external
      view
      returns(
        uint256
    )
    {
        return address(this).balance;
    }


    function cutPlatformFeesForToken(
        uint256 _amount
    ) internal returns(
        uint256
    )
    {
        uint256 feesAmount = (_amount.mul(platformFeesForToken)).div(100);
        uint256 amountForSwap = _amount.sub(feesAmount);
        (bool success,) = owner.call{value:feesAmount}("");
        require(success,"refund failed"); 
        return amountForSwap;
    }
    
    function cutPlatformFeesForBNB(
        uint256 _amount,
        address _address
    ) internal 
    {
        uint256 feesAmount = (_amount.mul(platformFeesForbnb)).div(100);
        uint256 amountToSend = _amount.sub(feesAmount);
       
        (bool success,) = owner.call{value:feesAmount}("");
        require(success,"refund failed"); 
       
        (bool user,) = _address.call{value:amountToSend}("");
        require(user,"refund failed");

        emit bnbTransfer(_address,amountToSend); 
    }
    
    receive() payable external {}
}