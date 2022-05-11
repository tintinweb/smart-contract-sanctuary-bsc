/**
 *Submitted for verification at BscScan.com on 2022-05-11
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-20
*/

/**
 *Submitted for verification at BscScan.com on 2022-01-20
*/

pragma solidity 0.5.16;

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
    * set inviter
    */
  function setInviter(address user, address inviter) external;

  /**
    * get inviter
    */
  function getInviter(address user) external view returns (address);

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

  function power(uint256 a, uint256 b) internal pure returns (uint256){

        if(a == 0) return 0;
        if(b == 0) return 1;

        uint256 c = a ** b;
        require(c > 0, "SafeMathForUint256: modulo by zero");
        return c;
    }
}

library TokenHelper {

    function getInviter(address token, address user) internal returns (address){
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xe05c5104, user));
        require(success, "get inviter fail");
        return _bytesToAddress(data);
    }

    function _bytesToAddress(bytes memory bys) internal pure returns (address addr) {
        assembly {
            addr := mload(add(bys, 32))
        }
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

interface ILp {
    function addHoldingReward(uint256 holdingReward) external;
    function updateTokenHoldingAmount(address user) external;

    function addLpReward(uint256 lpReward) external;
    function updateLpAmount(address user) external;

    function addSuperPartnerReward(uint256 superPartnerReward) external;

    function addCommunityPartnerReward(uint256 communityPartnerReward) external;
}

contract BEP20Token is Context, IBEP20, Ownable {
  using SafeMath for uint256;

  mapping (address => uint256) private _balances;

  mapping (address => mapping (address => uint256)) private _allowances;

  uint256 private _totalSupply;
  uint8 private _decimals;
  string private _symbol;
  string private _name;

  mapping (address => address) private _inviterMap;
	
  address private _lpAddress;

  uint256 private _inviteMinAmount;

  mapping (address => bool) private _whiteAddressMap;

  mapping (address => bool) private _dappOperaterMap;

  mapping (address => bool) private _settingpOeraterMap;

  uint256 private _totalFeePercent = 8;
  
  uint256 private _blackHolePercent = 20;

  uint256 private _lpPercent = 30;
  uint256 private _holdingPercent = 20;
  uint256 private _superPartnerPercent = 10;
  uint256 private _communityPartnerPercent = 10;
  uint256 private _ecoFundPercent = 10;

  address private _marketRemainReceiveAddress;

  address private _lpRewardReceiveAddress;

  address private _holdingRewardReceiveAddress;

  address private _superPartnerRewardReceiveAddress;

  address private _communityPartnerRewardReceiveAddress;

  address private _ecoFundReceiveAddress;

  address private _oldToken;

  address private _totalParentAddress;

  address private _dispatchPoolAddress;

  constructor(address oldToken) public {
    _name = "EIGHT";
    _symbol = "EGT";
    _decimals = 25;
    _totalSupply = 100000000 * 10**25;
    _balances[msg.sender] = _totalSupply;

    _oldToken = oldToken;

    emit Transfer(address(0), msg.sender, _totalSupply);
  }

  function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

  modifier onlyDapp() {
    require(_dappOperaterMap[_msgSender()], "caller is not the dapps");
    _;
  }


  modifier onlySetting() {
    require(_settingpOeraterMap[_msgSender()], "caller is not the settings");
    _;
  }

  /**
   * @dev Returns the bep token owner.
   */
  function getOwner() external view returns (address) {
    return owner();
  }

  /**
   * @dev Returns the token decimals.
   */
  function decimals() external view returns (uint8) {
    return _decimals;
  }

  /**
   * @dev Returns the token symbol.
   */
  function symbol() external view returns (string memory) {
    return _symbol;
  }

  /**
  * @dev Returns the token name.
  */
  function name() external view returns (string memory) {
    return _name;
  }

  /**
   * @dev See {BEP20-totalSupply}.
   */
  function totalSupply() external view returns (uint256) {
    return _totalSupply;
  }

  /**
   * @dev See {BEP20-balanceOf}.
   */
  function balanceOf(address account) external view returns (uint256) {
    return _balances[account];
  }

  /**
   * @dev See {BEP20-transfer}.
   *
   * Requirements:
   *
   * - `recipient` cannot be the zero address.
   * - the caller must have a balance of at least `amount`.
   */
  function transfer(address recipient, uint256 amount) external returns (bool) {
    _transfer(_msgSender(), recipient, amount);
    return true;
  }

  /**
   * @dev See {BEP20-allowance}.
   */
  function allowance(address owner, address spender) external view returns (uint256) {
    return _allowances[owner][spender];
  }

  /**
   * @dev See {BEP20-approve}.
   *
   * Requirements:
   *
   * - `spender` cannot be the zero address.
   */
  function approve(address spender, uint256 amount) external returns (bool) {
    _approve(_msgSender(), spender, amount);
    return true;
  }

  /**
   * @dev See {BEP20-transferFrom}.
   *
   * Emits an {Approval} event indicating the updated allowance. This is not
   * required by the EIP. See the note at the beginning of {BEP20};
   *
   * Requirements:
   * - `sender` and `recipient` cannot be the zero address.
   * - `sender` must have a balance of at least `amount`.
   * - the caller must have allowance for `sender`'s tokens of at least
   * `amount`.
   */
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
    _transfer(sender, recipient, amount);
    _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
    return true;
  }

  /**
   * @dev Atomically increases the allowance granted to `spender` by the caller.
   *
   * This is an alternative to {approve} that can be used as a mitigation for
   * problems described in {BEP20-approve}.
   *
   * Emits an {Approval} event indicating the updated allowance.
   *
   * Requirements:
   *
   * - `spender` cannot be the zero address.
   */
  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
    return true;
  }

  /**
   * @dev Atomically decreases the allowance granted to `spender` by the caller.
   *
   * This is an alternative to {approve} that can be used as a mitigation for
   * problems described in {BEP20-approve}.
   *
   * Emits an {Approval} event indicating the updated allowance.
   *
   * Requirements:
   *
   * - `spender` cannot be the zero address.
   * - `spender` must have allowance for the caller of at least
   * `subtractedValue`.
   */
  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
    return true;
  }

  /**
   * @dev Creates `amount` tokens and assigns them to `msg.sender`, increasing
   * the total supply.
   *
   * Requirements
   *
   * - `msg.sender` must be the token owner
   */
  function burn(uint256 amount) public returns (bool) {
    _burn(_msgSender(), amount);
    return true;
  }

  /**
   * @dev Moves tokens `amount` from `sender` to `recipient`.
   *
   * This is internal function is equivalent to {transfer}, and can be used to
   * e.g. implement automatic token fees, slashing mechanisms, etc.
   *
   * Emits a {Transfer} event.
   *
   * Requirements:
   *
   * - `sender` cannot be the zero address.
   * - `recipient` cannot be the zero address.
   * - `sender` must have a balance of at least `amount`.
   */
  function _transfer(address sender, address recipient, uint256 amount) internal {
    require(sender != address(0), "BEP20: transfer from the zero address");
    require(recipient != address(0), "BEP20: transfer to the zero address");

    bool takeFee = true;

    if(_whiteAddressMap[sender] || _whiteAddressMap[recipient]) { 
        takeFee = false; 
    }
    
    _transferStandard(sender, recipient, amount, takeFee);

    if (!isContract(sender)) {
        if (_inviterMap[sender] == address(0)) {
            address oldInviter = _syncOldInviter(sender);
            if (oldInviter != address(0)) {
                _inviterMap[sender] = oldInviter;
            } else {
                if (_totalParentAddress != address(0)) {
                    _inviterMap[sender] = _totalParentAddress;
                }
            }
        }
        updateTokenHoldingAmount(sender);
        updateLpAmount(sender);
    }

    if (!isContract(recipient)) {
        if (_inviterMap[recipient] == address(0)) {
            address oldInviter = _syncOldInviter(recipient);
            if (oldInviter != address(0)) {
                _inviterMap[recipient] = oldInviter;
            } else {
                bool shouldInvite = amount >= _inviteMinAmount
                && !isContract(sender) 
                && !isContract(recipient) && recipient != _totalParentAddress;
                if (shouldInvite) {
                    _inviterMap[recipient] = sender;
                }
            }
        }
        updateTokenHoldingAmount(recipient);
        updateLpAmount(recipient);
    }
  }

    function _syncOldInviter(address user) internal returns (address) {
        return TokenHelper.getInviter(_oldToken, user);
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount, bool takeFee) private {
        (uint256 rAmount, uint256 totalFee) = _getRealAmountAndFee(tAmount, takeFee);

        _balances[sender] = _balances[sender].sub(tAmount);
        _balances[recipient] = _balances[recipient].add(rAmount);
        emit Transfer(sender, recipient, rAmount);

        if (!takeFee) {
            return;
        }
        _blackHoleDestruction(sender, totalFee.mul(20).div(100));
        if (_lpAddress == sender) {// buy
            _marketReward(sender, recipient, totalFee.mul(80).div(100));
        } else {// sell or transfer
            _lpReward(sender, totalFee.mul(30).div(100));
            _holdingReward(sender, totalFee.mul(20).div(100));
            _superPartnerReward(sender, totalFee.mul(10).div(100));
            _communityPartnerReward(sender, totalFee.mul(10).div(100));
            _ecoFundReward(sender, totalFee.mul(10).div(100));
        }
    }

    function addHoldingReward(uint256 holdingReward) internal {
        if (_dispatchPoolAddress == address(0)) return;
        ILp(_dispatchPoolAddress).addHoldingReward(holdingReward);
    }

    function updateTokenHoldingAmount(address user) internal {
        if (_dispatchPoolAddress == address(0)) return;
        ILp(_dispatchPoolAddress).updateTokenHoldingAmount(user);
    }

    function addLpReward(uint256 lpReward) internal {
        if (_dispatchPoolAddress == address(0)) return;
        ILp(_dispatchPoolAddress).addLpReward(lpReward);
    }

    function updateLpAmount(address user) internal {
        if (_dispatchPoolAddress == address(0)) return;
        ILp(_dispatchPoolAddress).updateLpAmount(user);
    }

    function addSuperPartnerReward(uint256 amount) internal {
        if (_dispatchPoolAddress == address(0)) return;
        ILp(_dispatchPoolAddress).addSuperPartnerReward(amount);
    }

    function addCommunityPartnerReward(uint256 amount) internal {
        if (_dispatchPoolAddress == address(0)) return;
        ILp(_dispatchPoolAddress).addCommunityPartnerReward(amount);
    }

    function _getRealAmountAndFee(uint256 amount, bool takeFee) internal view returns (uint256, uint256) {
        if (!takeFee) return (amount, 0);
        uint256 totalFee = amount.mul(_totalFeePercent).div(100);
        return (amount.sub(totalFee), totalFee);
    }

    // 80% market reward for buy
    function _marketReward(address sender, address recipient, uint256 totalFee) internal {
        uint256 usedPercent = 0;
        address c = recipient;
        for (uint256 i = 0; i < 8; i++) {
            c = _inviterMap[c];
            if (c == address(0)) break;
            uint256 maxGen = _getMaxGenerationsByHoldingAmount(c);
            if (maxGen <= i) continue;
            uint256 rate = _getPercentByGeneration(i.add(1));
            if (rate <= 0) continue;
            usedPercent = usedPercent.add(rate);

            uint256 curTAmount = totalFee.mul(rate).div(100);
            _balances[c] = _balances[c].add(curTAmount);
            emit Transfer(sender, c, curTAmount);
        }
      
        if (usedPercent < 100) {
            uint256 remainAmount = uint256(100).sub(usedPercent).mul(totalFee).div(100);
            _balances[_marketRemainReceiveAddress] = _balances[_marketRemainReceiveAddress].add(remainAmount);
            emit Transfer(sender, _marketRemainReceiveAddress, remainAmount);
        }
    }

    // 20% black hole destruction for buy or sell or transfer
    function _blackHoleDestruction(address sender, uint256 blackHoleAmount) internal {
        _totalSupply = _totalSupply.sub(blackHoleAmount);
        emit Transfer(sender, address(0), blackHoleAmount);
    }

    // 30% lp reward for sell or transfer
    function _lpReward(address sender, uint256 lpRewardAmount) internal {
        addLpReward(lpRewardAmount);
        _balances[_lpRewardReceiveAddress] = _balances[_lpRewardReceiveAddress].add(lpRewardAmount);
        emit Transfer(sender, _lpRewardReceiveAddress, lpRewardAmount);
    }

    // 20% holding reward for sell or transfer
    function _holdingReward(address sender, uint256 holdingRewardAmount) internal {
        addHoldingReward(holdingRewardAmount);
        _balances[_holdingRewardReceiveAddress] = _balances[_holdingRewardReceiveAddress].add(holdingRewardAmount);
        emit Transfer(sender, _holdingRewardReceiveAddress, holdingRewardAmount);
    }

    // 10% super partner reward for sell or transfer
    function _superPartnerReward(address sender, uint256 superPartnerRewardAmount) internal {
        addSuperPartnerReward(superPartnerRewardAmount);
        _balances[_superPartnerRewardReceiveAddress] = _balances[_superPartnerRewardReceiveAddress].add(superPartnerRewardAmount);
        emit Transfer(sender, _superPartnerRewardReceiveAddress, superPartnerRewardAmount);
    }

    // 10% community partner reward for sell or transfer
    function _communityPartnerReward(address sender, uint256 communityPartnerRewardAmount) internal {
        addCommunityPartnerReward(communityPartnerRewardAmount);
        _balances[_communityPartnerRewardReceiveAddress] = _balances[_communityPartnerRewardReceiveAddress].add(communityPartnerRewardAmount);
        emit Transfer(sender, _communityPartnerRewardReceiveAddress, communityPartnerRewardAmount);
    }

    // 10% eco fund for sell or transfer
    function _ecoFundReward(address sender, uint256 ecoFundRewardAmount) internal {
        _balances[_ecoFundReceiveAddress] = _balances[_ecoFundReceiveAddress].add(ecoFundRewardAmount);
        emit Transfer(sender, _ecoFundReceiveAddress, ecoFundRewardAmount);
    }

    // get max generation through holding amount
    function _getMaxGenerationsByHoldingAmount(address user) internal view returns (uint256) {
        uint256 p = uint256(10).power(uint256(_decimals));
        if (_balances[user] >= uint256(100000).mul(p)) return 8;
        if (_balances[user] >= uint256(10000).mul(p)) return 6;
        if (_balances[user] >= uint256(1000).mul(p)) return 4;
        if (_balances[user] >= uint256(100).mul(p)) return 2;
        return 0;
    }

    // get reward percent through generation
    function _getPercentByGeneration(uint256 generation) internal pure returns (uint256) {
        if (generation == 1) return 40;
        if (generation == 2) return 20;
        if (generation == 3 || generation == 4) return 10;
        if (generation >= 5 && generation <= 8) return 5;
        return 0;
    }


  /** @dev Creates `amount` tokens and assigns them to `account`, increasing
   * the total supply.
   *
   * Emits a {Transfer} event with `from` set to the zero address.
   *
   * Requirements
   *
   * - `to` cannot be the zero address.
   */
  function _mint(address account, uint256 amount) internal {
    require(account != address(0), "BEP20: mint to the zero address");

    _totalSupply = _totalSupply.add(amount);
    _balances[account] = _balances[account].add(amount);
    emit Transfer(address(0), account, amount);
  }

  /**
   * @dev Destroys `amount` tokens from `account`, reducing the
   * total supply.
   *
   * Emits a {Transfer} event with `to` set to the zero address.
   *
   * Requirements
   *
   * - `account` cannot be the zero address.
   * - `account` must have at least `amount` tokens.
   */
  function _burn(address account, uint256 amount) internal {
    require(account != address(0), "BEP20: burn from the zero address");

    _balances[account] = _balances[account].sub(amount, "BEP20: burn amount exceeds balance");
    _totalSupply = _totalSupply.sub(amount);
    emit Transfer(account, address(0), amount);
  }

  /**
   * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
   *
   * This is internal function is equivalent to `approve`, and can be used to
   * e.g. set automatic allowances for certain subsystems, etc.
   *
   * Emits an {Approval} event.
   *
   * Requirements:
   *
   * - `owner` cannot be the zero address.
   * - `spender` cannot be the zero address.
   */
  function _approve(address owner, address spender, uint256 amount) internal {
    require(owner != address(0), "BEP20: approve from the zero address");
    require(spender != address(0), "BEP20: approve to the zero address");

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }

  /**
   * @dev Destroys `amount` tokens from `account`.`amount` is then deducted
   * from the caller's allowance.
   *
   * See {_burn} and {_approve}.
   */
  function _burnFrom(address account, uint256 amount) internal {
    _burn(account, amount);
    _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "BEP20: burn amount exceeds allowance"));
  }


    function setDappOperator(address user, bool permit) external onlyOwner {
        require(user != address(0), "address can't be zero");
        _dappOperaterMap[user] = permit;
    }

    function setSettingOperator(address user, bool permit) external onlyOwner {
        require(user != address(0), "address can't be zero");
        _settingpOeraterMap[user] = permit;
    }

    function getInviter(address user) external view returns (address) {
        return _inviterMap[user];
    }

    function getWhiteAddress(address user) external view returns (bool) {
        return _whiteAddressMap[user];
    }

    function setWhiteAddress(address user, bool white) external onlySetting {
        require(user != address(0), "address can't be zero");
        _whiteAddressMap[user] = white;
    }
	
	function setLpAddress(address lpAddress) external onlySetting {
        require(lpAddress != address(0), "address user can't be zero");
		_lpAddress = lpAddress;
	}

    function setDispatchPoolAddress(address dispatchPoolAddress) external onlySetting {
        require(dispatchPoolAddress != address(0), "address user can't be zero");
		_dispatchPoolAddress = dispatchPoolAddress;
	}
	
	function setInviteMinAmount(uint256 inviteMinAmount) external onlySetting {
		_inviteMinAmount = inviteMinAmount;
	}

    function setInviter(address user, address inviter) external onlyDapp {
        address oldInviter = TokenHelper.getInviter(_oldToken, user);
        if (oldInviter == address(0)) {
            require(user != address(0), "address user can't be zero");
            require(inviter != address(0), "address inviter can't be zero");
            require(_inviterMap[user] == address(0), "address has inviter");
            _inviterMap[user] = inviter;
        } else {
            _inviterMap[user] = oldInviter;
        }
	}


    function setMarketRemainReceiveAddress(address marketRemainReceiveAddress) external onlySetting {
        require(marketRemainReceiveAddress != address(0), "address can't be zero");
		_marketRemainReceiveAddress = marketRemainReceiveAddress;
	}

    function setLpRewardReceiveAddress(address lpRewardReceiveAddress) external onlySetting {
        require(lpRewardReceiveAddress != address(0), "address can't be zero");
		_lpRewardReceiveAddress = lpRewardReceiveAddress;
	}

    function setTotalParentAddress(address totalParentAddress) external onlySetting {
        require(_totalParentAddress == address(0), "total parent address has been set");
		_totalParentAddress = totalParentAddress;
	}

    function setHoldingRewardReceiveAddress(address holdingRewardReceiveAddress) external onlySetting {
        require(holdingRewardReceiveAddress != address(0), "address can't be zero");
		_holdingRewardReceiveAddress = holdingRewardReceiveAddress;
	}

    function setSuperPartnerRewardReceiveAddress(address superPartnerRewardReceiveAddress) external onlySetting {
        require(superPartnerRewardReceiveAddress != address(0), "address can't be zero");
		_superPartnerRewardReceiveAddress = superPartnerRewardReceiveAddress;
	}

    function setCommunityPartnerRewardReceiveAddress(address communityPartnerRewardReceiveAddress) external onlySetting {
        require(communityPartnerRewardReceiveAddress != address(0), "address can't be zero");
		_communityPartnerRewardReceiveAddress = communityPartnerRewardReceiveAddress;
	}

    function setEcoFundReceiveAddress(address ecoFundReceiveAddress) external onlySetting {
        require(ecoFundReceiveAddress != address(0), "address can't be zero");
		_ecoFundReceiveAddress = ecoFundReceiveAddress;
	}
}