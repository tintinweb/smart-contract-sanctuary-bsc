/**
 *Submitted for verification at BscScan.com on 2022-10-01
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.6.8;

interface iBEP20 {
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

library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
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

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount); //Address: insufficient balance

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success); //Address: unable to send value, recipient may have reverted"
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data); //Address: low-level call failed
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value); //Address: low-level call with value failed
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value); //Address: insufficient balance for call
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target)); //Address: call to non-contract

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

library SafeBEP20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(iBEP20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(iBEP20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {iBEP20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(iBEP20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeBEP20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(iBEP20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(iBEP20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value); //SafeBEP20: decreased allowance below zero
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(iBEP20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data); //SafeBEP20: low-level call failed
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool))); //SafeBEP20: ERC20 operation did not succeed
        }
    }
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
    require(c >= a); //SafeMath: addition overflow

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
    return sub(a, b); //SafeMath: subtraction overflow
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
    require(c / a == b); //SafeMath: multiplication overflow

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
    return div(a, b); //SafeMath: division by zero
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
    return mod(a, b); //SafeMath: modulo by zero
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
    require(_owner == _msgSender()); //Ownable: caller is not the owner
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
    require(newOwner != address(0)); //Ownable: new owner is the zero address
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

interface USDT {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address _owner) external returns (uint256 balance);
    function mint(address wallet, address buyer, uint256 tokenAmount) external;
    function showMyTokenBalance(address addr) external;
}

contract ForsagePrime is Ownable {

    struct UserStruct {
        bool isExist;
        bool blocked;
        uint id;
        uint referrerID;
        uint8 currentLevel;
        uint totalDirects;
        address[] referral;
        mapping (uint8 => bool) levelStatus;
    }

    struct AutoPoolUserStruct {
        bool isExist;
        bool blocked;
        address userAddress;
        uint uniqueId;
        uint referrerID;
        uint8 currentLevel;
        mapping (uint8 => uint[]) referral;
        mapping (uint8 => bool) levelStatus;
        mapping (uint8 => uint) reInvestCount;
    }

  using SafeMath for uint256;
  using SafeBEP20 for iBEP20;
  iBEP20 usdt = iBEP20(0x804e38dE09E3eb0992212C39454DC4A02025F3b2);
  uint public minAmount;
  address public passup;
  address public rebirth;
  uint public userCurrentId = 0;

    mapping (uint8 => uint) public autoPoolcurrentId;
    mapping (uint8 => uint) public APId;
    mapping (uint => address) public userList;
    mapping (address => uint) public autoPoolId;
    mapping (address => UserStruct) public users;
    mapping (uint8 => uint) public levelPrice;
    mapping (uint8 => uint) public levelCom;
    mapping (uint8 => mapping (uint => address)) public autoPoolUserList;
    mapping (uint => AutoPoolUserStruct) public autoPoolUniqueUsers;
    mapping (uint8 => mapping (uint => AutoPoolUserStruct)) public autoPoolUsers;

  constructor() public {
        passup = msg.sender;
        rebirth = msg.sender;
        // LevelPrice
        levelPrice[1] = 15e18;
        levelPrice[2] = 75e18;
        levelPrice[3] = 200e18;
        levelPrice[4] = 500e18;
        levelPrice[5] = 1000e18;

        levelPrice[1] = 25;
        levelPrice[2] = 5;
        levelPrice[3] = 4;
        levelPrice[4] = 7;
        levelPrice[5] = 9;

        UserStruct memory userStruct;
        userCurrentId = 1;
        userStruct = UserStruct({
            isExist: true,
            blocked: false,
            id: userCurrentId,
            referrerID: 0,
            currentLevel:1,
            totalDirects:10,
            referral: new address[](0)
        });
        users[passup] = userStruct;
        userList[userCurrentId] = passup;
        AutoPoolUserStruct memory autoPoolStruct;
        autoPoolStruct = AutoPoolUserStruct({
            isExist: true,
            blocked: false,
            userAddress: passup,
            uniqueId: userCurrentId,
            referrerID: 0,
            currentLevel: 1
        });

        autoPoolUniqueUsers[userCurrentId] = autoPoolStruct;
        autoPoolId[passup] = userCurrentId;
        autoPoolUniqueUsers[userCurrentId].currentLevel = 5;
        users[passup].currentLevel = 5;

        for(uint8 i = 1; i <= 5; i++) {
            users[passup].levelStatus[i] = true;
            autoPoolcurrentId[i] = 1;
            autoPoolUsers[i][autoPoolcurrentId[i]].levelStatus[i] = true;
            autoPoolUserList[i][autoPoolcurrentId[i]] = passup;
            autoPoolUsers[i][autoPoolcurrentId[i]] = autoPoolStruct;
            autoPoolUniqueUsers[userCurrentId].levelStatus[i] = true;
            APId[i] = 1;
        }
  }

  /**
   * @dev Returns the contract owner.
   */

  function getOwner() external view virtual returns (address) {
    return owner();
  }

  function joinProgram(uint depAmount, uint _referrerID) public {

        uint _userId = autoPoolId[msg.sender];
        require(users[msg.sender].isExist == false && autoPoolUniqueUsers[_userId].isExist ==  false); //User Already Exist
        usdt.transferFrom(msg.sender, address(this), depAmount);
        require(_referrerID > 0 && _referrerID <= userCurrentId); // invalid REF ID
        require(depAmount == levelPrice[1]); //Invalid Amount

        // check
        address UserAddress = msg.sender;
        uint32 size;
        assembly {
            size := extcodesize(UserAddress)
        }
        require(size == 0); //Invalid Contract

        userCurrentId = userCurrentId.add(1);
        userList[userCurrentId] = msg.sender;

        _workPlanReg(_referrerID);
        _autoPoolReg();
    }


       function upgradePackage(uint8 _level,uint depAmount) public {
        uint _userId = autoPoolId[msg.sender];
        usdt.safeTransferFrom(msg.sender, address(this), levelPrice[_level]);
        require(usdt.transfer(msg.sender, levelPrice[_level]));
        require(users[msg.sender].isExist && autoPoolUniqueUsers[_userId].isExist); // No User Found
        require(users[msg.sender].levelStatus[_level] ==  false && autoPoolUniqueUsers[_userId].levelStatus[_level] == false); // Already Active in this Package
        require(_level > 0 && _level <= 5);  //Invalid Package
        require(depAmount == levelPrice[_level]); //Invalid Amount

        if(_level != 1)
        {
            for(uint8 l =_level - 1; l > 0; l--)
                require(users[msg.sender].levelStatus[l] == true && autoPoolUniqueUsers[_userId].levelStatus[l] == true); //Must Purchase Previous Level.
        }

        _workPlanBuy(_level);
        _autoPoolBuy(_userId,_level);
    }


    function failSafe(address payable _toUser, uint _amount) onlyOwner external returns (bool) {
        require(_toUser != address(0)); //Invalid Address
        require(address(this).balance >= _amount);  //insufficient balance
        (_toUser).transfer(_amount);
        return true;
    }

    function updateBlockStatus(address _user, bool _status) onlyOwner external returns(bool) {
        users[_user].blocked = _status;
        autoPoolUniqueUsers[autoPoolId[_user]].blocked = _status;
        return true;
    }

    function viewWPUserReferral(address _userAddress) public view returns(address[] memory) {
        return users[_userAddress].referral;
    }

    function viewAPUserReferral(uint _userId, uint8 _level) public view returns(uint[] memory) {
        return (autoPoolUniqueUsers[_userId].referral[_level]);
    }

    function viewAPInternalUserReferral(uint _userId, uint8 _level) public view returns(uint[] memory) {
        return (autoPoolUsers[_level][_userId].referral[_level]);
    }

    function viewUserLevelStatus(address _userAddress, uint8 _matrix, uint8 _level) public view returns(bool) {
        if(_matrix == 1)
            return users[_userAddress].levelStatus[_level];

        if(_matrix == 2) {
            uint256 _userId = autoPoolId[_userAddress];
            return autoPoolUniqueUsers[_userId].levelStatus[_level];
        }
    }

    function viewAPUserReInvestCount(uint _userId, uint8 _level) public view returns(uint) {
        return autoPoolUniqueUsers[_userId].reInvestCount[_level];
    }

    function _workPlanReg(uint _referrerID) internal  {
        address referer = userList[_referrerID];
        UserStruct memory userStruct;
        userStruct = UserStruct({
            isExist: true,
            blocked: false,
            id: userCurrentId,
            referrerID: _referrerID,
            currentLevel: 1,
            totalDirects:0,
            referral: new address[](0)
        });
        users[msg.sender] = userStruct;
        users[msg.sender].levelStatus[1] = true;
        users[referer].referral.push(msg.sender);
        users[referer].totalDirects += 1;
        _workPlanPay(0,1, msg.sender);
    }

    function _autoPoolReg() internal  {

        uint _referrerID;

        for(uint i = APId[1]; i <= autoPoolcurrentId[1]; i++) {
            if(autoPoolUsers[1][i].referral[1].length < 4) {
                _referrerID = i;
                break;
            }
            else if(autoPoolUsers[1][i].referral[1].length == 4) {
                APId[1] = i;
                continue;
            }
        }

        AutoPoolUserStruct memory nonWorkUserStruct;
        autoPoolcurrentId[1] = autoPoolcurrentId[1].add(1);

        nonWorkUserStruct = AutoPoolUserStruct({
            isExist: true,
            blocked: false,
            userAddress: msg.sender,
            uniqueId: userCurrentId,
            referrerID: _referrerID,
            currentLevel: 1
        });

        autoPoolUsers[1][autoPoolcurrentId[1]] = nonWorkUserStruct;
        autoPoolUserList[1][autoPoolcurrentId[1]] = msg.sender;
        autoPoolUsers[1][autoPoolcurrentId[1]].levelStatus[1] = true;
        autoPoolUsers[1][autoPoolcurrentId[1]].reInvestCount[1] = 0;

        autoPoolUniqueUsers[userCurrentId] = nonWorkUserStruct;
        autoPoolId[msg.sender] = userCurrentId;
        autoPoolUniqueUsers[userCurrentId].referral[1] = new uint[](0);
        autoPoolUniqueUsers[userCurrentId].levelStatus[1] = true;
        autoPoolUniqueUsers[userCurrentId].reInvestCount[1] = 0;

        autoPoolUsers[1][_referrerID].referral[1].push(autoPoolcurrentId[1]);
        autoPoolUniqueUsers[autoPoolId[autoPoolUsers[1][_referrerID].userAddress]].referral[1].push(userCurrentId);

        _updateNWDetails(_referrerID,1);
    }

    function _workPlanBuy(uint8 _level) internal  {

        users[msg.sender].levelStatus[_level] = true;
        users[msg.sender].currentLevel = _level;

        _workPlanPay(0,_level, msg.sender);
    }

    function _autoPoolBuy(uint _userId, uint8 _level) internal  {

        uint _referrerID;

        for(uint i = APId[_level]; i <= autoPoolcurrentId[_level]; i++) {
            if(autoPoolUsers[_level][i].referral[_level].length < 4) {
                _referrerID = i;
                break;
            }
            else if(autoPoolUsers[_level][i].referral[_level].length == 4) {
                APId[_level] = i;
                continue;
            }
        }

        AutoPoolUserStruct memory nonWorkUserStruct;
        autoPoolcurrentId[_level] = autoPoolcurrentId[_level].add(1);

        nonWorkUserStruct = AutoPoolUserStruct({
            isExist: true,
            blocked: false,
            userAddress: msg.sender,
            uniqueId: _userId,
            referrerID: _referrerID,
            currentLevel: _level
        });
        autoPoolUsers[_level][autoPoolcurrentId[_level]] = nonWorkUserStruct;
        autoPoolUserList[_level][autoPoolcurrentId[_level]] = msg.sender;
        autoPoolUsers[_level][autoPoolcurrentId[_level]].levelStatus[_level] = true;
        autoPoolUniqueUsers[_userId].levelStatus[_level] = true;
        autoPoolUniqueUsers[_userId].currentLevel = _level;
        autoPoolUniqueUsers[_userId].referral[_level] = new uint[](0);
        autoPoolUniqueUsers[_userId].reInvestCount[_level] = 0;

        autoPoolUsers[_level][_referrerID].referral[_level].push(autoPoolcurrentId[_level]);
        autoPoolUniqueUsers[autoPoolId[autoPoolUsers[_level][_referrerID].userAddress]].referral[_level].push(autoPoolId[autoPoolUsers[_level][autoPoolcurrentId[_level]].userAddress]);

        _updateNWDetails(_referrerID,_level);
    }

    function _updateNWDetails(uint _referrerID, uint8 _level) internal {

        autoPoolUsers[_level][autoPoolcurrentId[_level]].referral[_level] = new uint[](0);

        if(autoPoolUsers[_level][_referrerID].referral[_level].length == 4) {
            _autoPoolPay(0,_level,autoPoolcurrentId[_level]);

            if(autoPoolUniqueUsers[autoPoolId[autoPoolUsers[_level][_referrerID].userAddress]].levelStatus[_level] = true
                && autoPoolUniqueUsers[autoPoolId[autoPoolUsers[_level][_referrerID].userAddress]].reInvestCount[_level] < 7) {
                _reInvest(_referrerID,_level);
                autoPoolUniqueUsers[autoPoolId[autoPoolUsers[_level][_referrerID].userAddress]].referral[_level] = new uint[](0);
                autoPoolUniqueUsers[autoPoolId[autoPoolUsers[_level][_referrerID].userAddress]].reInvestCount[_level] =  autoPoolUniqueUsers[autoPoolId[autoPoolUsers[_level][_referrerID].userAddress]].reInvestCount[_level].add(1);
            }
            else if(autoPoolUniqueUsers[autoPoolId[autoPoolUsers[_level][_referrerID].userAddress]].reInvestCount[_level] == 7) {
                autoPoolUniqueUsers[autoPoolId[autoPoolUsers[_level][_referrerID].userAddress]].levelStatus[_level] = false;
                users[autoPoolUsers[_level][_referrerID].userAddress].levelStatus[_level] = false;
            }

        }
        else if(autoPoolUsers[_level][_referrerID].referral[_level].length == 1)
            _autoPoolPay(1,_level,autoPoolcurrentId[_level]);
        else if(autoPoolUsers[_level][_referrerID].referral[_level].length == 2)
            _autoPoolPay(1,_level,autoPoolcurrentId[_level]);
        else if(autoPoolUsers[_level][_referrerID].referral[_level].length == 3)
            _autoPoolPay(0,_level,autoPoolcurrentId[_level]);

    }

    function _reInvest(uint _refId, uint8 _level) internal  {

        uint _reInvestId;

        for(uint i = APId[_level]; i <= autoPoolcurrentId[_level]; i++) {

            if(autoPoolUsers[_level][i].referral[_level].length < 4) {
                _reInvestId = i;
                break;
            }
            else if(autoPoolUsers[_level][i].referral[_level].length == 4) {
                APId[_level] = i;
                continue;
            }

        }

        AutoPoolUserStruct memory nonWorkUserStruct;
        autoPoolcurrentId[_level] = autoPoolcurrentId[_level].add(1);

        nonWorkUserStruct = AutoPoolUserStruct({
            isExist: true,
            blocked: false,
            userAddress: autoPoolUserList[_level][_refId],
            uniqueId: autoPoolUsers[_level][_refId].uniqueId,
            referrerID: _reInvestId,
            currentLevel: _level
        });

        autoPoolUsers[_level][autoPoolcurrentId[_level]] = nonWorkUserStruct;
        autoPoolUserList[_level][autoPoolcurrentId[_level]] = autoPoolUserList[_level][_refId];
        autoPoolUsers[_level][autoPoolcurrentId[_level]].levelStatus[_level] = true;

        autoPoolUsers[_level][_reInvestId].referral[_level].push(autoPoolcurrentId[_level]);
        autoPoolUniqueUsers[autoPoolId[autoPoolUsers[_level][_reInvestId].userAddress]].referral[_level].push(autoPoolId[autoPoolUsers[_level][autoPoolcurrentId[_level]].userAddress]);

        autoPoolUsers[_level][autoPoolcurrentId[_level]].referral[_level] = new uint[](0);

        if(autoPoolUsers[_level][_reInvestId].referral[_level].length == 4) {

            if(autoPoolUniqueUsers[autoPoolId[autoPoolUsers[_level][_reInvestId].userAddress]].levelStatus[_level] = true
                && autoPoolUniqueUsers[autoPoolId[autoPoolUsers[_level][_reInvestId].userAddress]].reInvestCount[_level] < 7) {
                _reInvest(_reInvestId,_level);
                autoPoolUniqueUsers[autoPoolId[autoPoolUsers[_level][_reInvestId].userAddress]].referral[_level] = new uint[](0);
                autoPoolUniqueUsers[autoPoolId[autoPoolUsers[_level][_reInvestId].userAddress]].reInvestCount[_level] =  autoPoolUniqueUsers[autoPoolId[autoPoolUsers[_level][_reInvestId].userAddress]].reInvestCount[_level].add(1);
            }
            else if(autoPoolUniqueUsers[autoPoolId[autoPoolUsers[_level][_reInvestId].userAddress]].reInvestCount[_level] == 7) {
                autoPoolUniqueUsers[autoPoolId[autoPoolUsers[_level][_reInvestId].userAddress]].levelStatus[_level] = false;
                users[autoPoolUsers[_level][_reInvestId].userAddress].levelStatus[_level] = false;
            }

        }

    }

    function _getReferrer(uint8 _level, address _user) internal returns (address) {
        if (_level == 0 || _user == address(0)) {
            return _user;
        }

        return _getReferrer( _level - 1,userList[users[_user].referrerID]);
    }

    function _workPlanPay(uint8 _flag, uint8 _level, address _userAddress) internal {

        address referer;

        for(uint8 i = 1; i <= 5; i++) {
            uint _share =  (levelPrice[_level]).mul(levelCom[i]).div(100);
            if(_flag == 0){
                referer = _getReferrer(i,_userAddress);
            }
            else{
                referer = passup;
            }
            if(users[referer].levelStatus[_level] == true && users[referer].blocked ==false && users[referer].totalDirects >= i){
                 require(usdt.transfer(referer, _share));
            }
            else{
                require(usdt.transfer(passup, _share));
            }
        }
    }

    function _autoPoolPay(uint8 _flag, uint8 _level, uint _userId) internal {

        uint refId;
        address refererAddress;

        if(_flag == 0)
          refId = autoPoolUsers[_level][_userId].referrerID;

        if(autoPoolUniqueUsers[autoPoolId[autoPoolUsers[_level][refId].userAddress]].levelStatus[_level] = true|| _flag == 1) {

            uint _share = (levelPrice[_level]).div(2);

            if(_flag == 1 || autoPoolUniqueUsers[autoPoolId[autoPoolUserList[_level][refId]]].blocked == true)
                refererAddress = rebirth;
            else
                refererAddress = autoPoolUserList[_level][refId];

            require(usdt.transfer(refererAddress, _share));
        }
        else {
            refId = autoPoolUsers[_level][_userId].referrerID;
            refererAddress = autoPoolUserList[_level][refId];
            _autoPoolPay(1, _level, refId);

        }

    }

}