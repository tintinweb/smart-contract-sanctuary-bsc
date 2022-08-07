/**
 *Submitted for verification at BscScan.com on 2022-08-06
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

contract Context {
    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view returns (bytes memory) {
        this;
        return msg.data;
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}
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
contract airdropLock
 {
    using Counters for Counters.Counter;
    uint256 public airdropToken;
    uint256 public token_per_user = 2;
    address payable public ownerable;
    Counters.Counter private _unlockedNumber;
    uint256[] amount;
    address[] user;
    address token;
    uint256 lockedTime;    
    modifier ownerableonly() 
    {
        require(msg.sender == ownerable);
        _;
    }
    bool airdrop_active = true;
    IERC20 Token;
    mapping(address => bool) result;
   
 struct data
 {
     address  user;
     uint256  id;
     IERC20 _token;  
     uint256  totalToken;
     uint256 releaseTime;
     bool isGet;
 } 
 // mapping(uint256 => data) allData;
    data [] allData;
   
    constructor(IERC20 token_)
     {
        require(address(token_) != address(0), "address must be available"); //airdrop tokeN address not = to 0
        ownerable = payable(msg.sender);
        Token = token_;
    }
    function initializeAirDrop(uint256 _airdropToken) public ownerableonly
    {
        require(_airdropToken != 0);
        airdropToken == _airdropToken;
        require(Token.balanceOf(msg.sender) >= _airdropToken, "balance too low");
        Token.transferFrom(msg.sender, address(this),_airdropToken );
    }
    function claimToken() external 
    {
        require(payable(msg.sender) != ownerable, "owner can not claim tokens");
        require(
            Token.balanceOf(address(this)) >= token_per_user,
            "balance must be greater than require amount"
        );
        require(airdrop_active == true, " airdrop should be active");
        require(result[msg.sender] == false, "you have already taken airdrop");
        lockedTime = block.timestamp + 3600;
        result[msg.sender] = true;
        uint256 id =  _unlockedNumber.current();
          allData.push(
          data(
          msg.sender,
          id,
          Token,
          token_per_user,
          lockedTime,
          false         
            )
        );
        _unlockedNumber.increment();
    }
    function claimLockedToken(uint256 index)external 
    {
        data memory stored = allData[index];      
        require (stored.user == msg.sender ); 
        require(stored.isGet == false, "you already withdrawn !");    
        require( block.timestamp >= lockedTime,"your time is not reached yet") ;    
        Token.transferFrom(msg.sender,address(this),token_per_user);
          allData[index].isGet= true;
    }    

    function cancel() external {
        require(payable(msg.sender) == ownerable);      
        airdrop_active = false;
    }

    function changeTokenAdres(IERC20 newTokenAdres) public ownerableonly {
        Token = newTokenAdres;
    }

    function update_tokensPerUser(uint256 newPerUser) public ownerableonly {
        token_per_user = newPerUser;
    }
}