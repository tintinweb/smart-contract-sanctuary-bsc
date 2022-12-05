/**
 *Submitted for verification at BscScan.com on 2022-12-05
*/

pragma solidity ^0.8.0;
// SPDX-License-Identifier: Unlicensed


library SafeMath {
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
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
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
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
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
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
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
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
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
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
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
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address public _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);



    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function geUnlockTime() public view returns (uint256) {
        return _lockTime;
    }

    //Locks the contract for owner for the amount of time provided
    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = block.timestamp + time;
        emit OwnershipTransferred(_owner, address(0));
    }

    //Unlocks the contract for owner when _lockTime is exceeds
    function unlock() public virtual {
        require(_previousOwner == msg.sender, "You don't have permission to unlock");
        require(block.timestamp > _lockTime , "Contract is locked until 7 days");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

contract PresaleVLC is Ownable {
//   using SafeMath for uint;
//   using Address for address;

  	using SafeMath for uint256;
	using SafeERC20 for IERC20;
    
    IERC20 public token = IERC20(0xea536C17315B8836195052Dd8dBa4040ECDC7c65);

//   Velocity public token;

  mapping (address => uint256) public addresses;
  uint public cap;
  uint256 public minInvestment;
  uint256 public maxInvestment;
  uint256 public rate;
  uint public unlockLiquidity;
  bool private _isActive;
  uint256 public airdropcount;
  bool private _isAirdrop = false;
  uint256 public _temp;
  mapping(address => bool) public airdrops;
  
  address private _router;
  address private _factory;
  address private _weth;

  constructor()  {
      _owner = _msgSender();
    // token = createTokenContract(_owner);
    _isActive = false;
    rate = 100 * 10**18;
    _owner = _msgSender();
    _router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    _factory = 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73;
  }


  function isActive() public view returns (bool) {
    return _isActive == true && address(this).balance < cap;
  }

  function _isAirdropactive() public view returns (bool) {
    return _isAirdrop == true && address(this).balance < cap;
  }
  
  function startPresale(uint256 min, uint256 max, uint256 hardCap, uint256 tokensPerBNB) onlyOwner() public{
    require(!_isActive, "presale is starting");
    require(min >= 0);
    require(max >= min);
    require(hardCap > max);
    require(tokensPerBNB > 0);
    
    rate = tokensPerBNB;
    minInvestment = min;
    maxInvestment = max ;
    cap = hardCap;
    _isActive = true;
  }

//   function createTokenContract(address tokenowner) internal returns (Velocity) {
//     return new Velocity(tokenowner);
//   }

  function tokensale() payable public{
      _temp = msg.value;
    require(_isActive == true && address(this).balance <= cap, "ERROR: Presale is not active");
    require(msg.value <= maxInvestment && msg.value  >= minInvestment, "ERROR: Must be min -  max");
    require(addresses[msg.sender] + msg.value <= maxInvestment, "ERROR: Limit of 3 BNB");
    // require(!address(msg.sender).isContract() && msg.sender == tx.origin, "ERROR: Contracts are not allowed");
    
    uint256 tokens = msg.value;
    tokens = rate.mul(tokens).div(10**18);
    addresses[msg.sender] = addresses[msg.sender].add(msg.value);
    token.transfer(msg.sender, tokens);
  }
    function getBalance() public view returns( uint256) {
        return address(this).balance;
    }
  function endPresale() onlyOwner() public returns (bool){
      require(_isActive, "presale is not starting");
      payable(msg.sender).transfer(address(this).balance);
    //End presale
    _isActive = false;
    return true;
  }
  function startAirdrop() onlyOwner() public {
      _isAirdrop = true;
  }
  function endAirdrop() onlyOwner() public {
      _isAirdrop = false;
  }
  //get Airdrop
  function airdrop() payable public {
    require(airdropcount <= 10000 && _isAirdrop, "VLC:: Airdrop is finished");
    require(airdrops[msg.sender] == false, "VLC:: Already get airdrop");
    token.transfer(msg.sender, 1000000*10**18);

    airdropcount = airdropcount.add(1);
    airdrops[msg.sender] = true;
  }

}




library SafeERC20 {
    using SafeMath for uint;
    function safeTransfer(IERC20 token, address to, uint value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }
    function safeTransferFrom(IERC20 token, address from, address to, uint value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }
    function safeApprove(IERC20 token, address spender, uint value) internal {
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }
    function callOptionalReturn(IERC20 token, bytes memory data) private {
        require(isContract(address(token)), "SafeERC20: call to non-contract");
        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
	function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }
}