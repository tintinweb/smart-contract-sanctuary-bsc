/**
 *Submitted for verification at BscScan.com on 2022-05-04
*/

pragma solidity ^0.6.12;
// SPDX-License-Identifier: UNLICENSED
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}


abstract contract ContextUpgradeable is Initializable {
     function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    uint256[50] private __gap;
}


interface IBEP20Upgradeable {

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

library SafeMathUpgradeable {
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



/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
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
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
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
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
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
      return functionCall(target, data, "Address: low-level call failed");
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
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

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


library SafeBEP20Upgradeable {
    using AddressUpgradeable for address;

    function safeTransfer(
        IBEP20Upgradeable token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IBEP20Upgradeable token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IBEP20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IBEP20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeBEP20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IBEP20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IBEP20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeBEP20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));

    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IBEP20Upgradeable token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeBEP20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeBEP20: BEP20 operation did not succeed");
        }
    }
}


contract McarIco is Initializable, ContextUpgradeable{
    using SafeMathUpgradeable for uint256;
    using SafeBEP20Upgradeable for IBEP20Upgradeable;

    // Info of each pool.
    struct SaleInfo {
        uint256 supply;
        uint256 tokenbusdprice;
        uint256 tokenSalePercent;
        uint256 referralPercent;
        uint256 referralUserPercent;
        uint256 totalVestingDays;
        uint256 tokenLaunch;
        uint256 endTime;
    }
    SaleInfo[] public saleInfo;

    // Info of each user.
     struct UserInfo {
        uint256 amount;      // How many tokens the user has provided for stacking.
        uint256 startRewardTime;  // Last Reward pool timestamp
        uint256 referralcount;
        uint256 referralbonus;
        uint256 referralincome;
        uint256 lockedToken;
        uint256 totalToken;
        uint256 claimToken;
        address referrar;
    }

    address public owner;
    address public receiver;
    uint256 public tokenbusdprice;
    mapping (uint256 => mapping (address => UserInfo)) public userInfo;
    IBEP20Upgradeable public busdToken;
    IBEP20Upgradeable public mcarToken;
    uint256 public activesale;
    uint256 public tokenLaunch;

    function initialize(IBEP20Upgradeable _busdToken,IBEP20Upgradeable _mcarToken,uint256 _tokenLaunch,address _ownerAddress) public initializer  {
        mcarToken = _mcarToken;
        busdToken = _busdToken;
        owner = _ownerAddress;
        receiver = _ownerAddress;
        tokenLaunch = _tokenLaunch;
    }

     function getequaltoken(uint256 _amount,uint256 _sid) public view returns (uint256,uint256){
        uint256 perToken = saleInfo[_sid].tokenbusdprice.mul(_amount);
        uint256 pending = perToken.div(1000000);
        uint256 transferpending = pending/100;
        return (pending,transferpending);
      }

       function activeSale(uint256 _sid) public  {
           require(msg.sender==owner , "Not Owner");
           activesale = _sid;
        }

      function addSale(uint256 _supply,uint256 _price,uint256 _tokenSalePercent,uint256 _referralPercent,uint256 _referralUserPercent,uint256 _totalVestingDays,uint256 _tokenLaunch,uint256 _endtime) public  {
          require(msg.sender==owner , "Not Owner");
           saleInfo.push(SaleInfo({
                supply : _supply,
                tokenbusdprice : _price,
                tokenSalePercent : _tokenSalePercent,
                referralPercent : _referralPercent,
                referralUserPercent : _referralUserPercent,
                totalVestingDays: _totalVestingDays,
                tokenLaunch : _tokenLaunch,
                endTime : _endtime
           }));
      }

    function setSale(uint256 _sid, uint256 _supply,uint256 _price,uint256 _tokenSalePercent,uint256 _referralPercent,uint256 _referralUserPercent,uint256 _totalVestingDays,uint256 _tokenLaunch,uint256 _endtime) public  {
        require(msg.sender==owner , "Not Owner");
        saleInfo[_sid].supply = _supply;
        saleInfo[_sid].tokenbusdprice = _price;
        saleInfo[_sid].tokenSalePercent = _tokenSalePercent;
        saleInfo[_sid].referralPercent = _referralPercent;
        saleInfo[_sid].referralUserPercent = _referralUserPercent;
        saleInfo[_sid].totalVestingDays = _totalVestingDays;
        saleInfo[_sid].tokenLaunch = _tokenLaunch;
        saleInfo[_sid].endTime = _endtime;
    }


     function deposit(uint256 _amount,uint256 _sid) public {
        require(block.timestamp < saleInfo[_sid].endTime, 'Launch Time Completed');
        UserInfo storage user = userInfo[_sid][msg.sender];
        require (_amount > 0, 'need amount > 0');
        user.amount += _amount;
        busdToken.safeTransferFrom(address(msg.sender), address(this), _amount);
        busdToken.transfer(receiver ,_amount);
        uint256 perToken = saleInfo[_sid].tokenbusdprice.mul(_amount);
        uint256 pending = perToken.div(1000000);
        user.totalToken += pending;
        user.startRewardTime = saleInfo[_sid].tokenLaunch;
      }

      function depositWithReferral(uint256 _amount, address _address,uint256 _sid) public {
        require(block.timestamp < saleInfo[_sid].endTime, 'Launch Time Completed');
        UserInfo storage userParent = userInfo[_sid][_address];
        userParent.referralcount += 1;
        UserInfo storage user = userInfo[_sid][msg.sender];
        require (_amount > 0, 'need amount > 0');
        user.amount += _amount;
        user.referrar = _address;
        busdToken.safeTransferFrom(address(msg.sender), address(this), _amount);
        busdToken.transfer(receiver ,_amount);
        uint256 perToken = saleInfo[_sid].tokenbusdprice.mul(_amount);
        uint256 pending = perToken.div(1000000);
        user.totalToken += pending;
        uint256 referralPercentAmount = _amount * saleInfo[_sid].referralPercent/1000;
        userParent.referralbonus += referralPercentAmount;
        userParent.referralincome += referralPercentAmount;
        uint256 referraluserPercentAmount = _amount * saleInfo[_sid].referralUserPercent/1000;
        user.referralbonus += referraluserPercentAmount;
        user.referralincome += referraluserPercentAmount;
        user.startRewardTime = saleInfo[_sid].tokenLaunch;
      }


      function pendingMcar(address useraddress,uint256 _sid) public view returns (uint256) {
          UserInfo storage user = userInfo[_sid][useraddress];
          uint256 lockedpending = user.totalToken;
          uint256 lockedmcars = lockedpending -  user.claimToken;
          return  lockedmcars ;
       }

       function pendingReferralMcar(address useraddress,uint256 _sid) public view returns (uint256) {
          UserInfo storage user = userInfo[_sid][useraddress];
          uint256 referralPending = user.referralbonus;
          return  referralPending ;
       }
      function pendingReferralMcarAll(address useraddress) public view returns (uint256) {
          uint256 referralPending = 0;
          for(uint i=0; i< saleInfo.length;i++){
              UserInfo storage user = userInfo[i][useraddress];
              referralPending += user.referralbonus;
          }
          return  referralPending ;
       }
       function ReferralCount(address useraddress) public view returns (uint256,uint256) {
          uint256 referralCounts = 0;
          uint256 referralIncome = 0;
          for(uint i=0; i< saleInfo.length;i++){
              UserInfo storage user = userInfo[i][useraddress];
              referralCounts += user.referralcount;
              referralIncome+= user.referralincome;
          }
          return (referralCounts,referralIncome);
       }

      function availableMcar(address useraddress,uint256 _sid) public view returns (uint256) {
          UserInfo storage user = userInfo[_sid][useraddress];
            uint diff = block.timestamp - user.startRewardTime;
            uint256 available = 0;
            uint256 totalToken = user.totalToken - user.claimToken;
        
            if( block.timestamp > user.startRewardTime && diff > saleInfo[_sid].totalVestingDays ){
                 uint calcMcar = diff / saleInfo[_sid].totalVestingDays;
                if(calcMcar >= 100/saleInfo[_sid].tokenSalePercent){
                    calcMcar = 100/saleInfo[_sid].tokenSalePercent;
                }
                available = uint256(calcMcar) * totalToken.mul(saleInfo[_sid].tokenSalePercent)/100;
                available = available * 100000000;
            }else{
                available = 0;
            }
            uint256 returnavailable = available / 100000000;
            return returnavailable;

       }
     function claimReferralMcar(uint256 _sid) public {
            UserInfo storage user = userInfo[_sid][msg.sender];
            uint256 referralbonusToken = user.referralbonus;
            require(block.timestamp > tokenLaunch, 'You must wait until the claim Date');
            require(referralbonusToken > 0,"You dont have balance");
            uint256 bgtBal = mcarToken.balanceOf(address(this));
            require(bgtBal > referralbonusToken,"Contract balance less than referral Amount");
            mcarToken.transfer(msg.sender, referralbonusToken);
            user.referralbonus = 0;
            user.referralincome += referralbonusToken;
      }

       function claimReferralMcarAll() public {
           require(block.timestamp > tokenLaunch, 'You must wait until the claim Date');
           uint256 referralbonusToken = 0;
           for(uint i=0; i< saleInfo.length;i++){
                UserInfo storage user = userInfo[i][msg.sender];
                referralbonusToken += user.referralbonus;
                user.referralbonus = 0;
                user.referralincome += referralbonusToken;
           }
            require(referralbonusToken > 0,"You dont have balance");
            uint256 bgtBal = mcarToken.balanceOf(address(this));
            require(bgtBal > referralbonusToken,"Contract balance less than referral Amount");
            mcarToken.transfer(msg.sender, referralbonusToken);

      }

    function claimMcar(uint256 _sid) public {
            UserInfo storage user = userInfo[_sid][msg.sender];
            uint diff = block.timestamp - user.startRewardTime;
            uint256 available = 0;
            uint256 bgtBal = 0;
            uint256 totalToken = user.totalToken - user.claimToken;

            require(user.claimToken < totalToken,"You Already Claimed");
            if( block.timestamp > user.startRewardTime && diff > saleInfo[_sid].totalVestingDays ){
                 uint calcMcar = diff / saleInfo[_sid].totalVestingDays;
                if(calcMcar >= 100/saleInfo[_sid].tokenSalePercent){
                    calcMcar = 100/saleInfo[_sid].tokenSalePercent;
                }
                available = uint256(calcMcar) * totalToken.mul(saleInfo[_sid].tokenSalePercent)/100;
                available = available * 100000000;
                user.startRewardTime  =  user.startRewardTime + (calcMcar * saleInfo[_sid].totalVestingDays);
            }else{
                available = 0;
            }
           bgtBal = mcarToken.balanceOf(address(this));
           require (available / 100000000 > 0, 'No balance');
           user.claimToken += available / 100000000;
             if (available / 100000000 > bgtBal) {
                mcarToken.transfer(msg.sender, bgtBal);
            } else {
                mcarToken.transfer(msg.sender, available / 100000000);
            }
      }



     function safeWithDrawMcar(uint256 _amount,address addr) public  {
          require(msg.sender==owner , "Not Owner");
          mcarToken.transfer(addr,_amount);

     }

     function safeWithDrawBusd(uint256 _amount,address addr) public  {
          require(msg.sender==owner , "Not Owner");
          busdToken.transfer(addr ,_amount);
     }

    function setReceiver(address newreceiver) public {
        require(msg.sender==owner , "Not Owner");
        receiver = newreceiver;
    }

    function setTokenLaunch(uint256 _tokenLaunch) public {
        require(msg.sender==owner , "Not Owner");
        tokenLaunch = _tokenLaunch;
    }

    function setOwner(address newOwner) public {
        require(msg.sender==owner , "Not Owner");
        owner = newOwner;
    }

}