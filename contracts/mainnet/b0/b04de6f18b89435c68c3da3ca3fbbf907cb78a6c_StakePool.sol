/**
 *Submitted for verification at BscScan.com on 2022-04-15
*/

pragma solidity ^0.6.12;
// SPDX-License-Identifier: MIT

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
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
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

interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);
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
 * @dev Collection of functions related to the address type
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
        assembly {size := extcodesize(account)}
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
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success,) = recipient.call{value : amount}("");
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
        (bool success, bytes memory returndata) = target.call{value : weiValue}(data);
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

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {// Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () public {
        address msgSender = msg.sender;
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
        require(_owner == msg.sender, "Ownable: caller is not the owner");
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
}

contract Adminable {
    address private _admin;

    event AdminTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () public {
        address msgSender = msg.sender;
        _admin = msgSender;
        emit AdminTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function admin() public view returns (address) {
        return _admin;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyAdmin() {
        require(_admin == msg.sender, "Ownable: caller is not the owner");
        _;
    }


    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferAdmin(address newOwner) public virtual onlyAdmin {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit AdminTransferred(_admin, newOwner);
        _admin = newOwner;
    }
}


interface IUniswapV2Router02 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}

contract USDTWrapper {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 public inToken;

    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;
    uint256 private _validCount;

    function validCount() public view returns (uint256){
        return _validCount;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function _stake(uint256 amount) internal {
        _totalSupply = _totalSupply.add(amount);
        if (_balances[msg.sender] == 0) {
            _validCount = _validCount.add(1);
        }
        _balances[msg.sender] = _balances[msg.sender].add(amount);
        inToken.safeTransferFrom(msg.sender, address(this), amount);
    }

    function withdraw(uint256 amount) public virtual {
        _totalSupply = _totalSupply.sub(amount);
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        inToken.safeTransfer(msg.sender, amount);
        if (_balances[msg.sender] == 0) {
            _validCount = _validCount.sub(1);
        }
    }
}

contract StakePool is USDTWrapper, Ownable, Adminable {
    IERC20 public outToken;

    uint256 public starttime;
    uint256 public periodFinish = 0;
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;
    uint256 ONE_DAY = 60;
    uint256 ONE_YEAR = ONE_DAY * 365;
    uint256 limitDayCount = 7;
    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;
    mapping(address => uint256) public totalRewards;

    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);
    event Bind(address indexed fa, address indexed ca);
    event UpdateMin(uint256 oldAmount, uint256 newAmount);
    event UpdateMinUsdt(uint256 oldAmount, uint256 newAmount);
    event AddRefRewardAmount(address indexed account, address indexed from, uint256 amount);
    event ClaimRefRewardAmount(address indexed account, uint256 amount);


    uint256[]public secondOutAmountArr;

    address constant firstAddress = 0x0000000000000000000000000000000000000001;
    mapping(address => address) refMap;
    mapping(address => bool) public addressUsedMap;
    mapping(address => address[]) teamMap;
    mapping(address => bool) validMap;
    mapping(address => uint256) refRewardMap;
    mapping(address => uint256) refTotalMap;
    //
    mapping(address => uint256) exitTimeMap;
    mapping(address => uint256) rewardTimeMap;
    mapping(address => uint256) refRewardTimeMap;
    //
    uint256 public minLp;
    uint256 public minUsdt;

    //swap price
    IUniswapV2Router02 router;
    address wethAddress;
    address usdtAddress;
    IERC20 lpPriceTokenAddress;
    uint256 onePriceToken;
    address[] calcPath;


    constructor(
        address outToken_,
        address inputLpToken_,
        address calcPriceToken_,
        address routerAddress_,
        address usdtAddress_,
        uint256 starttime_,
        uint256 one_day_,
        uint256 firstTotal,
        uint256 secondTotal,
        uint256 thirdTotal
    ) public {
        //
        router = IUniswapV2Router02(routerAddress_);
        wethAddress = router.WETH();
        usdtAddress = usdtAddress_;
        lpPriceTokenAddress = IERC20(calcPriceToken_);
        uint8 cDecimals = IERC20(calcPriceToken_).decimals();
        onePriceToken = 1 * 10 ** uint256(cDecimals);
        calcPath.push(calcPriceToken_);
        calcPath.push(wethAddress);
        calcPath.push(usdtAddress);
        //
        outToken = IERC20(outToken_);
        inToken = IERC20(inputLpToken_);
        starttime = starttime_;
        ONE_DAY = one_day_;
        ONE_YEAR = ONE_DAY * 365;
        periodFinish = starttime_ + ONE_YEAR * 3;
        lastUpdateTime = starttime;
        secondOutAmountArr.push(firstTotal.div(ONE_YEAR));
        secondOutAmountArr.push(secondTotal.div(ONE_YEAR));
        secondOutAmountArr.push(thirdTotal.div(ONE_YEAR));
        require(secondOutAmountArr.length == 3, "len3");
    }

    modifier onlyMaster() {
        require(owner() == msg.sender || admin() == msg.sender, "Ownable: caller is not the master");
        _;
    }

    function _bind(address f, address c) internal {
        //        require(refMap[f] != address(0) || f == firstAddress, "invalid referrer");
        require(f != c, "not allow yourself");
        require(!addressUsedMap[c], "not allow");
        require(refMap[c] == address(0), "already binded");
        refMap[c] = f;
        teamMap[f].push(c);
        if (!addressUsedMap[f]) {
            addressUsedMap[f] = true;
        }
        emit Bind(f, c);
    }

    function bind(address _ref) external {
        if (refMap[msg.sender] == address(0)) {
            _bind(_ref, msg.sender);
        }
    }

    function updateMinLp(uint256 _lp) public onlyMaster {
        emit UpdateMin(minLp, _lp);
        minLp = _lp;
    }

    function updateMinUsdt(uint256 _usdt) public onlyMaster {
        emit UpdateMinUsdt(minLp, _usdt);
        minUsdt = _usdt;
    }

    function getOnePrice() public view returns (uint256){

        return router.getAmountsOut(onePriceToken, calcPath)[2];
    }

    function getLpValue(uint256 lpAmount) public view returns (uint256){
        if(lpAmount == 0 ){
            return 0;
        }
        uint price = getOnePrice();
        require(price > 0, "price0");
        uint256 totalLp = inToken.totalSupply();
        uint256 priceTokenTotal = lpPriceTokenAddress.balanceOf(address(inToken));
        uint tokenAmount = lpAmount.mul(priceTokenTotal).div(totalLp);

        return tokenAmount.mul(price).mul(2).div(onePriceToken);

    }


    function _checkUserValid(bool isIn, address user) internal {
        if (minLp != 0) {
            if (isIn && !validMap[user] && balanceOf(user) >= minLp) {
                validMap[user] = true;
            } else if (!isIn && validMap[user] && balanceOf(user) < minLp) {
                validMap[user] = false;
            }
        } else {
            if (isIn && !validMap[user] && getLpValue(balanceOf(user)) >= minUsdt) {
                validMap[user] = true;
            } else if (!isIn && validMap[user] && getLpValue(balanceOf(user)) < minUsdt) {
                validMap[user] = false;
            }
        }
    }

    modifier checkStart() {
        require(block.timestamp >= starttime, 'not start');
        _;
    }

    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
    }

    function _checkDayMoreThan7(uint256 _time) view internal {
        require(block.timestamp.sub(_time) >= ONE_DAY.mul(limitDayCount), "more7");
    }

    function lastTimeRewardApplicable() public view returns (uint256) {
        return Math.min(block.timestamp, periodFinish);
    }

    function rewardPerToken() public view returns (uint256) {
        if (totalSupply() == 0) {
            return rewardPerTokenStored;
        }
        uint256 curTime = lastTimeRewardApplicable();
        uint256 lastTime = lastUpdateTime;
        uint256 curPer = getPeriod(curTime);
        uint256 lastPer = getPeriod(lastTime);
        if (curPer != lastPer) {

            uint256 tempIndex = lastPer;
            uint256 tempStored = rewardPerTokenStored;
            for (; tempIndex <= curPer; tempIndex++) {
                if (tempIndex == lastPer) {
                    tempStored = tempStored.add(
                        getPeriodTimestamp(tempIndex).sub(lastUpdateTime)
                        .mul(getRewardRateByTime(getPeriodTimestamp(tempIndex)))
                        .mul(1e18)
                        .div(totalSupply()));
                } else if (tempIndex == curPer) {
                    tempStored = tempStored.add(
                        curTime.sub(getPeriodTimestamp(tempIndex - 1))
                        .mul(getRewardRateByTime(getPeriodTimestamp(tempIndex)))
                        .mul(1e18)
                        .div(totalSupply()));
                } else {
                    tempStored = tempStored.add(
                        ONE_YEAR
                        .mul(getRewardRateByTime(getPeriodTimestamp(tempIndex)))
                        .mul(1e18)
                        .div(totalSupply()));
                }

            }
            return tempStored;
        }
        return
        rewardPerTokenStored.add(
            lastTimeRewardApplicable()
            .sub(lastUpdateTime)
            .mul(getRewardRateByTime(lastUpdateTime))
            .mul(1e18)
            .div(totalSupply()));

    }

    function earned(address account) public view returns (uint256) {
        return
        balanceOf(account)
        .mul(rewardPerToken().sub(userRewardPerTokenPaid[account]))
        .div(1e18)
        .add(rewards[account]);
    }


    function claimRefReward() external {
        uint256 amount = refRewardMap[msg.sender];
        require(amount > 0, "zero");
        //
        _checkDayMoreThan7(refRewardTimeMap[msg.sender]);
        refRewardTimeMap[msg.sender] = block.timestamp;
        //

        refRewardMap[msg.sender] = 0;
        refTotalMap[msg.sender] += amount;
        emit ClaimRefRewardAmount(msg.sender, amount);
        outToken.safeTransfer(msg.sender, amount);
    }

    // stake visibility is public as overriding LPTokenWrapper's stake() function
    function stake(uint256 amount)
    public
    updateReward(msg.sender)
    checkStart
    {
        require(amount > 0, 'Cannot stake 0');
        //
        if (balanceOf(msg.sender) == 0) {
            exitTimeMap[msg.sender] = block.timestamp;
            rewardTimeMap[msg.sender] = block.timestamp;
        }

        _stake(amount);
        emit Staked(msg.sender, amount);
        //        if (!validMap[msg.sender] && balanceOf(msg.sender) >= minLp) {
        //            validMap[msg.sender] = true;
        //        }
        _checkUserValid(true, msg.sender);
    }

    function withdraw(uint256 amount)
    public
    override
    updateReward(msg.sender)
    checkStart
    {
        require(amount > 0, 'Cannot withdraw 0');
        _checkDayMoreThan7(exitTimeMap[msg.sender]);
        exitTimeMap[msg.sender] = block.timestamp;

        super.withdraw(amount);
        emit Withdrawn(msg.sender, amount);
        //        if (validMap[msg.sender] && balanceOf(msg.sender) < minLp) {
        //            validMap[msg.sender] = false;
        //        }
        _checkUserValid(false, msg.sender);
    }

    function exit() external {
        withdraw(balanceOf(msg.sender));
        getReward();
    }

    function getReward() public updateReward(msg.sender) checkStart {
        uint256 reward = earned(msg.sender);
        if (reward > 0) {
            _checkDayMoreThan7(rewardTimeMap[msg.sender]);
            rewardTimeMap[msg.sender] = block.timestamp;

            totalRewards[msg.sender] = totalRewards[msg.sender].add(reward);
            rewards[msg.sender] = 0;
            outToken.safeTransfer(msg.sender, reward);
            emit RewardPaid(msg.sender, reward);
            //
            address up = refMap[msg.sender];
            if (up != address(0) && validMap[up]) {
                uint256 refAmount = reward.mul(2).div(10);
                refRewardMap[up] = refRewardMap[up].add(refAmount);
                emit AddRefRewardAmount(up, msg.sender, refAmount);
            }
        }
    }


    function getRewardRateByTime(uint256 _time) public view returns (uint256){
        uint per = getPeriod(_time);
        return secondOutAmountArr[per - 1];
    }

    function getPeriod(uint256 _time) public view returns (uint256){
        uint256 per = _time.sub(starttime).div(ONE_YEAR);
        uint256 rem = _time.sub(starttime).mod(ONE_YEAR);
        if (rem == 0) {
            if (per == 0) {
                return 1;
            }
            if (per >= 3) {
                return 3;
            }
            return per;
        } else {
            if (per >= 3) {
                return 3;
            } else {
                return per + 1;}
        }
    }

    function getPeriodTimestamp(uint256 _period) public view returns (uint256){
        uint n = 1;
        if (_period <= 1) {
            n = 1;
        } else if (_period >= 3) {
            return lastTimeRewardApplicable();
        } else {
            n = _period;
        }
        return starttime.add(ONE_YEAR.mul(n));
    }

    function getSystemTime() external view returns (uint256, uint256){
        return (starttime, periodFinish);
    }

    function userValid(address _addr) public view returns (bool){
        return validMap[_addr];
    }

    function getUserTime(address _addr) public view returns (uint256, uint256, uint256){
        return (exitTimeMap[_addr], rewardTimeMap[_addr], refRewardTimeMap[_addr]);
    }

    function getRewardInfo(address _addr) public view returns (uint256, uint256, uint256, uint256){
        return (earned(_addr), totalRewards[_addr], refRewardMap[_addr], refTotalMap[_addr]);
    }

    function getReferrer(address _addr) public view returns (address){
        return refMap[_addr];
    }

    function getTeamLength(address _addr) public view returns (uint256){
        return teamMap[_addr].length;
    }

    function getTeam(address _addr, uint256 pageNo, uint256 pageSize) public view returns (address[]memory team){
        uint256 max = teamMap[_addr].length;
        if (max == 0 || pageSize == 0) {
            return new address[](0);
        }
        uint start = 0;
        uint end = 0;
        if (max <= pageSize) {
            end = max;
        } else {
            start = pageNo * pageSize;
            end = start + pageSize;
            if (end >= max) {
                end = max;
            }
        }
        team = new address[](end - start);
        uint index;
        for (; start < end; start++) {
            team[index] = teamMap[_addr][start];
            index++;
        }
    }


}