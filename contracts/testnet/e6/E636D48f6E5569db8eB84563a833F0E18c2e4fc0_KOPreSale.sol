//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.9;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract KOPreSale is Ownable {
  using SafeMath for uint256;

  uint256 public startAt;
  uint256 public closeAt;
  uint256 public tge;

  uint256 constant DECIMALS = 18;
  uint256 constant public initialTokensBalance = 10000000 * (10 ** DECIMALS);
  uint256 constant public minBuy = 300 * 10**DECIMALS; // this number will be $ 
  uint256 constant public maxBuy = 5000 * 10**DECIMALS; // this number will be $
  uint256 constant public price = 300; // 0.03, need to div 10000
  uint256 constant public DECIMAL_PRICE = 10000;

  uint256 constant public tgePercent = 500000; // receive 50% at tge, need to div 10.000
  uint256 public restPercent;

  uint256 public totalClaimedAmount;
  uint256 public totalSoldAmount;
  uint256 public totalUSDSoldAmount;

  address public kOBEP20;
  address public kOBEP20From;

  struct Data {
    uint256 amount; // KO Token bought
    uint256 claimedAmount;
    uint256 claimedAt;
    uint256 usdAmount;
  }

  // address buyer => data
  mapping(address => Data) public datas;

  // struct data input at constructor
  struct ConstrutorInput {
    address[] tokenAlloweds;
    uint256 startAt;
    uint256 closeAt;
    uint256 tge;
    address kOBEP20;
    address kOBEP20Owner;
    uint256[] releaseDays;
  }

  // release days
  uint256[] public releaseDays;

  mapping(address => bool) public tokenAlloweds;
  mapping(address => uint256) public tokenBalances;

  event Bought(address buyer, uint256 koAmount, address paymentToken, uint256 paymentTokenAmount);
  event Claimed(address buyer, uint256 koAmount);
  event Withdraw(address token, uint256 amount, address to);

  constructor(ConstrutorInput memory input, address _owner) public {
    require(input.closeAt < input.tge, "invalid_close_time");
    for (uint256 i = 0; i < input.tokenAlloweds.length; i++) {
      tokenAlloweds[input.tokenAlloweds[i]] = true;
    }
    startAt = input.startAt;
    closeAt = input.closeAt;
    tge = input.tge;
    kOBEP20 = input.kOBEP20;
    kOBEP20From = input.kOBEP20Owner;
    restPercent = (uint256(1000000).sub(tgePercent)).div(input.releaseDays.length); // 100% - tgePercent / length of release day
    for (uint256 i = 0; i < input.releaseDays.length; i++) {
      releaseDays.push(input.releaseDays[i]);
    }
    transferOwnership(_owner);
  }
  
  modifier requireTokenAllowed(address _token) {
    require(tokenAlloweds[_token] == true, "invalid_token");
    _;
  }

  function buyPreSale(uint256 _usdAmount, address _paymentToken) requireTokenAllowed(_paymentToken) external {
    require(_usdAmount > 0, "invalid_usd_amount");
    if (startAt > 0) require(block.timestamp >= startAt, "not_open_yet");
    if (closeAt > 0) require(block.timestamp <= closeAt, "closed");
    if (minBuy != 0) require(datas[msg.sender].usdAmount + _usdAmount >= minBuy, "invalid_min_amount");
    if (maxBuy != 0) require(datas[msg.sender].usdAmount + _usdAmount <= maxBuy, "invalid_max_amount");
    uint256 koTokenAmount = _usdAmount.mul(DECIMAL_PRICE).div(price);

    require(koTokenAmount + totalSoldAmount <= initialTokensBalance, "over_limitation");
    datas[msg.sender].amount = datas[msg.sender].amount.add(koTokenAmount);
    datas[msg.sender].usdAmount = datas[msg.sender].usdAmount.add(_usdAmount);
    datas[msg.sender].claimedAt = tge;

    // require amount token
    _safeTransferFrom(_paymentToken, msg.sender, address(this), _usdAmount);
    tokenBalances[_paymentToken] = tokenBalances[_paymentToken].add(_usdAmount);
    totalSoldAmount = totalSoldAmount.add(koTokenAmount);
    totalUSDSoldAmount = totalUSDSoldAmount.add(_usdAmount);

    emit Bought(msg.sender, koTokenAmount, _paymentToken, _usdAmount);
  }

  function claim() external {
    Data storage data = datas[msg.sender];
    (uint256 availableAmmount, ) = getAvailableClaimAmount();

    if (availableAmmount > 0) {
      // mint hay transfer
      _safeTransferFrom(kOBEP20, kOBEP20From, msg.sender, availableAmmount);
      data.claimedAt = block.timestamp;
      data.claimedAmount = data.claimedAmount.add(availableAmmount);
      totalClaimedAmount = totalClaimedAmount.add(availableAmmount);
      emit Claimed(msg.sender, availableAmmount);
    }
  }

  function getAvailableClaimAmount() public view returns(uint256 availableAmount, uint256 nextClaimAt) {
    Data memory data = datas[msg.sender];
    uint256 index = 0;
    if (data.amount > 0 && data.claimedAmount < data.amount) {
      if (block.timestamp < tge) {
        nextClaimAt = tge;
      } else {
        availableAmount =  tgePercent.mul(data.amount).div(100).div(10000);
        nextClaimAt = releaseDays[0];
        for (index = 0; index < releaseDays.length; index++) {
          if (block.timestamp < releaseDays[index]) break;
        }
        if (index > 0) {
          if (index == releaseDays.length) {
            availableAmount = data.amount;
            nextClaimAt = 0;
          } else {
            availableAmount = availableAmount.add((data.amount.mul(restPercent).mul(index)).div(100).div(10000));
            nextClaimAt = releaseDays[index];
          }
        }
        availableAmount = availableAmount.sub(data.claimedAmount);
      }
    } 
  }

  function withdrawToken(address _token, uint256 _amount, address _to) external onlyOwner {
    require(tokenBalances[_token] >= _amount, "insufficient_balance");
    _safeTransfer(_token, owner(), _amount);
    tokenBalances[_token] = tokenBalances[_token].sub(_amount);
    emit Withdraw(_token, _amount, _to);
  }

  function _safeTransferFrom(address _token, address _from, address _to, uint256 _amount) internal {
    (bool success, ) = _token.call(abi.encodeWithSignature("transferFrom(address,address,uint256)", _from, _to, _amount));
    require(success == true, "invalid_transfer_from_token");
  }  
  
  function _safeTransfer(address _token, address _to, uint256 _amount) internal {
    (bool success, ) = _token.call(abi.encodeWithSignature("transfer(address,uint256)", _to, _amount));
    require(success == true, "invalid_transfer_token");
  }

  function setStart(uint256 _startAt) external onlyOwner {
    require(_startAt >= block.timestamp && _startAt < closeAt, "invalid_start_time");
    startAt = _startAt;
  }

  function setClose(uint256 _closeAt) external onlyOwner { 
    require(_closeAt < tge, "invalid_close_time");
    closeAt = _closeAt;
  }

  function setKOBEP20From(address _newAddress) external onlyOwner {
    require(_newAddress != address(0), "invalid_address");
    kOBEP20From = _newAddress;
  }

  // msg.data is empty?
  receive() external payable {}

  // msg.data isn't empty?
  fallback() external payable {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
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