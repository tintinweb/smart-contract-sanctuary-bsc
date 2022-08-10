/**
 *Submitted for verification at BscScan.com on 2022-08-10
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.5.16;
pragma experimental ABIEncoderV2;

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
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
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

/**
 * @dev Collection of functions related to the address type,
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * This test is non-exhaustive, and there may be false-negatives: during the
     * execution of a contract's constructor, its address will be reported as
     * not containing a contract.
     *
     * > It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies in extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
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

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the `nonReentrant` modifier
 * available, which can be aplied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 */
contract ReentrancyGuard {
    /// @dev counter to allow mutex lock with only one SSTORE operation
    uint256 private _guardCounter;

    constructor () internal {
        // The counter starts at one to prevent changing it from zero to a non-zero
        // value, which is a more expensive operation.
        _guardCounter = 1;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _guardCounter += 1;
        uint256 localCounter = _guardCounter;
        _;
        require(localCounter == _guardCounter, "ReentrancyGuard: reentrant call");
    }
}

interface IBEP20 {
  /**
   * @dev Returns the amount of tokens in existence.
   */
  function totalSupply() external view returns (uint256);

  /**
   * @dev Returns the token decimals.
   */
  function decimals() external view returns (uint8);

  /**
   * @dev Returns the token symbol.
   */
  function symbol() external view returns (string memory);

  /**
  * @dev Returns the token name.
  */
  function name() external view returns (string memory);

  /**
   * @dev Returns the bep token owner.
   */
  function getOwner() external view returns (address);

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
  function allowance(address _owner, address spender) external view returns (uint256);

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

contract StakingV3 is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using Address for address;

    event Stake(address _account, uint256 _amount, uint256 _id);
    event Unstake(address _account, uint256[] _indexes);
    event DepositProfit(address _bep20, uint256 _amount, address[] _users, uint256[] _bagIndexs);
    event OwnerStake(uint256 _totalAmount);
    event OwnerCompensateRewards(address _bep20, uint256 _totalAmount);

    struct Bag {
        uint256 start;
        uint256 amount;
        mapping(address => uint256) userBalance; // asset => balance
    }

    struct Package {
        uint256[] bagLength;
        mapping(uint256 => Bag) bags;
    }

    mapping(address => Package) private packages;

    IBEP20 public bep20 = IBEP20(0xcD5dc972DBC4dF70F64871D87Ae8f64D32988279);
    address public takeBep20 = 0x64470E5F5DD38e497194BbcAF8Daa7CA578926F6;
    uint256 public stakeTime = 1209600; // 14 days
    uint256 public minStake = 1 ether;
    uint256 public panaltyPercent = 10;
    uint256 public stakeFeePercent = 1;
    uint256 public percentDecimal = 6; // % two places after the decimal separator    
    address[] public bep20Profit = [0x76D6b68fa7a0C8855a60e1ABB994308e9F0f0546,0x3628837891d5FD303d5f1CAa1B9Cf8F1d3c591Ab,0x6dB30C54eb9640520817c21D57a376CCfF68454A,0x56a5dD67252D036172e3C69AC6CdBed3B7050dcE];
    
    modifier notContract() {
        address account = _msgSender();
        require(!(account).isContract(), "Contract not allowed");
        require(account == tx.origin, "Contract not allowed");
        _;
    }

    function() payable external{}

    function _stake(address _account, uint256 _id, uint256 _amount, uint256 _time) private {
      require(packages[_account].bags[_id].amount == 0, "Stake: Already exist");
      packages[_account].bags[_id] = Bag(_time, _amount);
      packages[_account].bagLength.push(_id);
      emit Stake(_account, _amount, _id);
    }

    function stake(uint256 _id, uint256 _amount) external notContract nonReentrant {
      require(_amount >= minStake, "Stake: Amount less than min stake");
      require(bep20.transferFrom(msg.sender, address(this), _amount), "Stake: Insufficient-allowance");
      _stake(msg.sender, _id, _amount, block.timestamp);
    }

    function ownerStake(address[] calldata _accounts, uint256[] calldata _ids, uint256[] calldata _amounts) external onlyOwner {
      uint256 length = _accounts.length;
      require(length == _ids.length && length == _amounts.length, "Stake: Length mismatch");
      uint256 totalAmount = 0;
      for(uint256 i = 0; i < length; i++) {
        require(packages[_accounts[i]].bags[_ids[i]].amount == 0, "Stake: Already exist");
        packages[_accounts[i]].bags[_ids[i]] = Bag(_ids[i], _amounts[i]);
        packages[_accounts[i]].bagLength.push(_ids[i]);
        totalAmount = totalAmount.add(_amounts[i]);
      }
      emit OwnerStake(totalAmount);
    }

    function _removeBagIndex(uint256 _bagLengthIndex) private {
        packages[msg.sender].bags[packages[msg.sender].bagLength[_bagLengthIndex]] = Bag(0, 0);
        packages[msg.sender].bagLength[_bagLengthIndex] = packages[msg.sender].bagLength[packages[msg.sender].bagLength.length - 1];
        packages[msg.sender].bagLength.length--;
    }

    function _refundReward(uint256 index) private {
      uint256 bnbBalance = packages[_msgSender()].bags[index].userBalance[address(0)];
      if(bnbBalance > 0) msg.sender.transfer(bnbBalance);
      for(uint256 i = 0; i < bep20Profit.length; i++) {
        uint256 bep20pfBalance = packages[_msgSender()].bags[index].userBalance[bep20Profit[i]];
        if(bep20pfBalance > 0) {
          IBEP20 bep20pf = IBEP20(bep20Profit[i]);
          bep20pf.transfer(msg.sender, bep20pfBalance);
        }
      }
    }
    
    function _refundToken(uint256 index) private {
      address account = _msgSender();
      require(packages[account].bags[index].amount > 0, "Stake: index is not exist");
      uint256 stakeStart = packages[account].bags[index].start;
      uint256 stakeAmount = packages[account].bags[index].amount;
      uint256 percent = block.timestamp.sub(stakeStart) < stakeTime ? panaltyPercent : stakeFeePercent;
      uint256 fee = stakeAmount.mul(percent).div(100);
      bep20.transfer(takeBep20, fee);
      bep20.transfer(account, stakeAmount.sub(fee));
    }

    function unstake(uint256 _bagLengthIndex) external notContract nonReentrant {
        address account = _msgSender();
        uint256[] memory indexes = new uint256[](1);
        uint256 index = packages[account].bagLength[_bagLengthIndex];
        indexes[0] = index;
        _refundToken(index);
        _refundReward(index);
        _removeBagIndex(_bagLengthIndex);
        emit Unstake(account, indexes);
    }
    
    function unstakes(uint256[] memory indexs) public notContract nonReentrant {
      address account = _msgSender();
      uint256 length = indexs.length;
      uint256[] memory indexes = new uint256[](length);

      for(uint256 i = 0; i < length; i++) {
          uint256 index = packages[account].bagLength[indexs[i]];
          indexes[i] = index;
          _refundToken(index);
          _refundReward(index);
          packages[account].bags[index] = Bag(0, 0);
          packages[account].bagLength[indexs[i]] = packages[account].bagLength[packages[account].bagLength.length - (i+1)];
      }
      packages[account].bagLength.length = packages[account].bagLength.length.sub(length);
      emit Unstake(account, indexes);
    }

    function _updateBalance(uint256[] memory _amounts, address[] memory _users, address _asset, uint256[] memory _bagIndexs) private returns (uint256){
        uint256 length = _users.length;
        uint256 amount = 0;
        for(uint256 i = 0; i < length; i++) {
            packages[_users[i]].bags[_bagIndexs[i]].userBalance[_asset] = packages[_users[i]].bags[_bagIndexs[i]].userBalance[_asset].add(_amounts[i]);
            amount = amount.add(_amounts[i]);
        }
        return amount;
    }

    function depositProfit(uint256[] memory _amounts, address[] memory _users, uint256[] memory _bagIndexs) public payable onlyOwner {
      require(_amounts.length == _users.length && _amounts.length == _bagIndexs.length && _amounts.length > 0, "Stake: Length mismatch");
      uint256 _amount = _updateBalance(_amounts, _users, address(0), _bagIndexs);
      require(msg.value >= _amount, "Stake: insufficient-allowance");
      emit DepositProfit(address(0), _amount, _users, _bagIndexs);
    }

    function depositProfitBep20(address _bep20pf, uint256[] memory _amounts, address[] memory _users, uint256[] memory _bagIndexs) public onlyOwner {
      require(_amounts.length == _users.length && _amounts.length == _bagIndexs.length && _amounts.length > 0, "Stake: Length mismatch");

      uint256 _amount = _updateBalance(_amounts, _users, _bep20pf, _bagIndexs);
      require(IBEP20(_bep20pf).transferFrom(msg.sender, address(this), _amount), "Stake: insufficient-allowance");
      bool existed;
      for(uint256 i = 0; i < bep20Profit.length; i++) {
          if(bep20Profit[i] == _bep20pf) {
            existed = true;
            break;
          }
      }
      if(!existed) bep20Profit.push(_bep20pf);
      emit DepositProfit(_bep20pf, _amount, _users, _bagIndexs);
    }

    function compensateRewards(address _bep20pf, uint256[] memory _amounts, address[] memory _users, uint256[] memory _bagIndexs) public onlyOwner {
      uint256 _amount = _updateBalance(_amounts, _users, _bep20pf, _bagIndexs);
      emit OwnerCompensateRewards(_bep20pf, _amount);
    }

    function getOccupancy(uint256 _stakeAmount) external view returns (uint256) {
        uint256 bep20Balance = getRemainingToken(bep20);
        if(bep20Balance == 0) return 0;
        return _stakeAmount.mul(10 ** percentDecimal).div(bep20Balance);
    }

    function getBep20Profit() public view returns(address[] memory) {
        return bep20Profit;
    }

    function getStake(address _guy) public view returns(uint256[] memory bagLength) {
        bagLength = packages[_guy].bagLength; 
    }

    function getStake(address _guy, uint256 _index) public view returns(uint256 start, uint256 amount) {
        return (packages[_guy].bags[_index].start, packages[_guy].bags[_index].amount); 
    }

    function getStakeReward(address _guy, uint256 _index, address _asset) public view returns(uint256 reward) {
        return packages[_guy].bags[_index].userBalance[_asset];
    }

    function config(uint256 _stakeTime, uint256 _minStake, address _takeBep20,  uint256 _percentDecimal, uint256 _panaltyPercent, uint256 _stakeFeePercent) public onlyOwner {
        stakeTime = _stakeTime;
        minStake = _minStake;
        takeBep20 = _takeBep20;
        percentDecimal = _percentDecimal;
        panaltyPercent = _panaltyPercent;
        stakeFeePercent = _stakeFeePercent;
    }

    function getRemainingToken(IBEP20 _token) public view returns (uint256) {
        return _token.balanceOf(address(this));
    }

    function withdrawBEP20(address _to, IBEP20 _bep20, uint256 _amount) external onlyOwner {
        _bep20.transfer(_to, _amount);
    }

    function withdraw(address payable _to, uint256 _amount) external onlyOwner {
        _to.transfer(_amount);
    }
}