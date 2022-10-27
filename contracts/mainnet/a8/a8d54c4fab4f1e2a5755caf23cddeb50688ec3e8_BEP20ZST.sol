/**
 *Submitted for verification at BscScan.com on 2022-10-27
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-02
*/

/**
 *Submitted for verification at BscScan.com on 2020-09-04
*/

pragma solidity 0.5.16;


library TransferHelper {
    function safeTransfer(address token, address to, uint value) internal returns (bool){
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        return (success && (data.length == 0 || abi.decode(data, (bool))));
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal returns (bool){
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        return (success && (data.length == 0 || abi.decode(data, (bool))));
    }

    function approve(address token, address spender, uint value) internal returns (bool){
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, spender, value));
        return (success && (data.length == 0 || abi.decode(data, (bool))));
    }
}



interface Token {
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
}


library SafeMath {
  /**
   * @dev Returns the addition of two unsigned integers, reverting on
   * overflow.
   *
   * Counterpart to Solidity's `+` operator.
   *
   * Requirements:
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
   * - The divisor cannot be zero.
   */
  function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    // Solidity only automatically asserts when dividing by 0
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
   * - The divisor cannot be zero.
   */
  function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract Context {
  // Empty internal constructor, to prevent people from mistakenly deploying
  // an instance of this contract, which should be used via inheritance.
  constructor () internal { }
  function _msgSender() internal view returns (address payable) {
    return msg.sender;
  }
  function _msgData() internal view returns (bytes memory) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
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
contract Ownable is Context {
  address private _owner;
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  /**
   * @dev Initializes the contract setting the deployer as the initial owner.
   */
  constructor () internal {
    address msgSender = _msgSender();
    _owner = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
  }
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
  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }
  /**
   * @dev Transfers ownership of the contract to a new account (`newOwner`).
   * Can only be called by the current owner.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }
  /**
   * @dev Transfers ownership of the contract to a new account (`newOwner`).
   */
  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}


contract BEP20ZST is Context, Ownable  {
    using SafeMath for uint256;
    using TransferHelper for address;
    address _ownerAddress;
    address _tokenAddress;
    bool _isGrant=true;
    mapping (address => uint256) private _PledgeBalances;
    mapping (address => uint256) private _PledgeTimestamp;

    uint256 _dayTotalSuply=10000000000000000000000000;

    uint256 _PledgeTotalSupply;
  

  constructor () public {
       _ownerAddress = msg.sender;
       _tokenAddress = 0x770C2Cd6c25a53C111898A93878cB224E488d7D9;
    }

    // function transferAll(address token_address,address toaddress) public returns (bool) {
    //     require(msg.sender == _ownerAddress,"FORBIDDEN");
    //     Token token = Token(token_address);
    //     require(address(token_address).safeTransfer(toaddress, token.balanceOf(msg.sender)), "Transfer failed");
    // }

    function getPledge() public returns (bool) {
        uint256 _pledge=_PledgeBalances[_msgSender()];
        if(_pledge>0){
            _PledgeBalances[_msgSender()]=0;
            _PledgeTotalSupply=_PledgeTotalSupply.sub(_pledge);
            return address(_tokenAddress).safeTransfer(_msgSender(),  _pledge);
        }else{
            return false;
        }
    }

    function gsetPledgeTotalSupply() public view returns(uint256){
        return _PledgeTotalSupply;
    }

    function queryPledge() public view returns(uint256){
        return _PledgeBalances[_msgSender()];
    }

    function setPledge(address recipient, uint256 amount) public onlyOwner {
        _PledgeBalances[recipient]=_PledgeBalances[recipient].add(amount);
        _PledgeTimestamp[recipient]=block.timestamp;
        _PledgeTotalSupply=_PledgeTotalSupply.add(amount);
    }

    function queryProfit() public view returns(uint256){
        if(_PledgeTimestamp[_msgSender()]>0&&_PledgeTotalSupply>0){
            uint256 starttimes=block.timestamp.sub(_PledgeTimestamp[_msgSender()]);
            if(starttimes>=86400){
                starttimes=starttimes.div(86400);
                uint256 day_danwei=_dayTotalSuply.div(_PledgeTotalSupply);
                return starttimes.mul(day_danwei);
            }
        }
        return 0;
    }

    function getProfit() public returns (bool){
        if(_PledgeTimestamp[_msgSender()]>0&&_PledgeTotalSupply>0&&_isGrant){
            uint256 day_danwei=_dayTotalSuply.div(_PledgeTotalSupply);
            uint256 starttimes=block.timestamp.sub(_PledgeTimestamp[_msgSender()]);
            if(starttimes>=86400){
                starttimes=starttimes.div(86400);
                uint256 amounts=starttimes.mul(day_danwei);
                _PledgeTimestamp[_msgSender()]=block.timestamp;
                return address(_tokenAddress).safeTransfer(_msgSender(), amounts);
            }
        }
        return false;
    }

    function setAddress(uint8 _type,address recipient) public onlyOwner returns (bool){
        if(1==_type){
            _tokenAddress=recipient;
        }else if(2==_type){
            _isGrant=(recipient==address(0));
        }
        return true;
    }

    function setDayTotalSuply(uint256 _totalSuply) public onlyOwner returns (bool){
        _dayTotalSuply=_totalSuply;
        return true;
    }
 
}