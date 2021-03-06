/**
 *Submitted for verification at BscScan.com on 2021-09-07
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

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
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }

    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x < y ? x : y;
    }

    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
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
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address _owner, address spender)
        external
        view
        returns (uint256);

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
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

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
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            codehash := extcodehash(account)
        }
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
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
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
    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
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
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: weiValue}(
            data
        );
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

    function safeTransfer(
        IBEP20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IBEP20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IBEP20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeBEP20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function safeIncreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(
            value
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function safeDecreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(
            value,
            "SafeBEP20: decreased allowance below zero"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IBEP20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(
            data,
            "SafeBEP20: low-level call failed"
        );
        if (returndata.length > 0) {
            // Return data is optional
            // solhint-disable-next-line max-line-length
            require(
                abi.decode(returndata, (bool)),
                "SafeBEP20: BEP20 operation did not succeed"
            );
        }
    }
}

contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() internal {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

contract IFO2 is ReentrancyGuard {
    using SafeMath for uint256;
    using SafeBEP20 for IBEP20;

    // Info of each user.
    struct UserInfo {
        uint256 uid; //user uid
        address uAddr; //user address
        address pAddr; //parent address
        AssetInfo assetInfo; //????????????
        InvestInfo investInfo; //????????????
        RewardStat rewardStat; //????????????
        //??????
        uint256 lastRlsTime; //????????????
        uint256 lastWithdTime; //????????????
        uint256 lastOutTime; //??????????????????
        uint256 lastAirdropTime; //??????????????????
        uint256 regTime; //????????????
        //??????
        uint256 ulevel; //?????????v1,v2,v3,v4,v5
        uint256 ivsCnt; //????????????
        uint256 status; // default false
    }

    struct AssetInfo {
        //oxf ??????
        uint256 oxf0AmtFree; // ???????????????
        uint256 oxf0AmtFrezz; // ????????????
        uint256 oxf1AmtFree; // ???????????????
        uint256 oxfAmtDeposit; // ????????????
        uint256 oxfAmtWithdSum; // ????????????
        uint256 depositAmt; // ???????????? ????????? usdt
        //????????????
        uint256 hashRate; //  ????????????
        uint256 hashRateRight; //  ????????????
        uint256 hashRateReward; //  ????????????
        //?????????
        uint256 oxfBurnAmtSum; // ????????????
        uint256 ordBurnAmtSum; // ord burn
        uint256 usdtBurnAmtSum; //How many usdt the user has provided.
    }

    struct InvestInfo {
        uint256[] investType; //??????????????????
        mapping(uint256 => uint256) invesAmtMapping; //??????
        mapping(uint256 => uint256) invesTimeMapping; //??????
    }

    struct RewardStat {
        //??????
        uint256 tuiRwdAmt; //tuijian reward
        uint256 teamRwdAmt; //team reward
        uint256 leaderRwdAmt; //leader reward
        uint256 tuiRwdSum; //????????????
        uint256 teamRwdAmtSum; //????????????
        uint256 leaderRwdAmtSum; //????????????
        uint256 rlsAmt; //????????????
        uint256 rlsAmtSum; //????????????
        //??????
        uint256 tuiCnt; //????????????
        uint256 tuiAmtSum; //?????????????????????
        uint256 teamCnt; //??????????????????10???,??????
        uint256 teamAmtSum; //??????????????????10???,??????
    }

    // admin address
    address public adminAddress;
    // The oxf token
    IBEP20 public oxfToken;
    // The ord token
    IBEP20 public ordToken;
    // The usdt token
    IBEP20 private usdtToken;

    uint256 public uid = 100000;
    //????????????
    uint256 public oxfPrice = 3; //oxf ?????? usdt  ??????3U //?????????

    uint256 public ordPrice = 4; //ord ?????? usdt  ??????4U
    // total amount of oxfToken that will offer
    uint256 public airdropAmt = 3 * 1e15; //oxf ????????????

    //??????????????????
    uint256 private invHr0; //ord
    uint256 private invHr1; //??????
    uint256 private invHr2; //oxf ??????
    uint256 private invHr3; //oxf ??????

    //????????????
    uint256 private ordBurnAmtSum;
    // total amount of raising tokens that have already raised
    uint256 private oxfBurnAmtSum;
    // total amount of raising tokens that have already raised
    uint256 private oxfDepositAmtSum;
    // total amount of raising tokens that have already raised
    uint256 private oxfRlsAmtSum;
    // total amount of raising tokens that have already raised
    uint256 private usdtAmtSum;
    // address => amount
    mapping(address => UserInfo) userMapping;
    mapping(uint256 => address) private indexMapping; //??????,????????????,?????????????????????
    // participators
    address[] public addressCorList; //???????????????

    //??????????????????
    uint256 public lastNodeRewardTime; //??????????????????
    uint256 public txFeeSum; // ???????????????
    uint256 public txFee; // ???????????????

    event Deposit(address indexed user, uint256 amount);
    event NodeReward(address indexed user, uint256 amount);
    event Airdrop(address indexed user, uint256 amount);
    event OutLog(address indexed user, uint256 amount);
    event WthdFee(address indexed user, uint256 amount);
    event Harvest(address indexed user, uint256 oxf1amt, uint256 oxf0amt); //??????

    constructor(
        IBEP20 _ordToken,
        IBEP20 _oxfToken,
        IBEP20 _usdtToken,
        address _adminAddress
    ) public {
        ordToken = _ordToken;
        oxfToken = _oxfToken;
        usdtToken = _usdtToken;
        adminAddress = _adminAddress;
    }

    modifier onlyAdmin() {
        require(msg.sender == adminAddress, "admin: wut?");
        _;
    }

    //?????? ord ??????
    function setOrdPrice(uint256 _price) public onlyAdmin {
        require(_price > 0, "need _amount > 0");
        ordPrice = _price;
    }

    //?????? oxf ??????
    function setOxfPrice(uint256 _price) public onlyAdmin {
        require(_price > 0, "need _amount > 0");
        oxfPrice = _price;
    }

    //??????????????????
    function setAirdropAmt(uint256 _amt) public onlyAdmin {
        airdropAmt = _amt;
    }

    function isReg(address addr) public view returns (bool) {
        UserInfo memory user = userMapping[addr];
        return user.regTime != 0;
    }

    function regUser(address addr, address paddr) private {
        UserInfo storage user = userMapping[addr];
        uid++;
        user.uid = uid;
        user.uAddr = addr;
        //????????????????????????
        if (userMapping[paddr].regTime > 0) {
            user.pAddr = paddr;
            userMapping[paddr].rewardStat.tuiCnt += 1;
            incTeamCnt(paddr, 1);
        }
        user.ulevel = 0;
        user.status = 1;
        user.lastRlsTime = now;
        user.lastWithdTime = now;
        user.regTime = now;
        userMapping[addr] = user;
        indexMapping[uid] = addr;
    }

    //????????????????????????
    function incTeamCnt(address _pAddr, uint8 _deep) private {
        if (_deep > 10) {
            return;
        }
        userMapping[_pAddr].rewardStat.teamCnt += 1;
        if (userMapping[_pAddr].assetInfo.depositAmt > 0) {
            _deep++;
            incTeamCnt(userMapping[_pAddr].pAddr, _deep);
        }
    }

    //??????
    function sign(uint256 _pid) public {
        if (!isReg(address(msg.sender))) {
            regUser(address(msg.sender), indexMapping[_pid]);
        }
        require(
            now.sub(userMapping[msg.sender].lastAirdropTime) > 2 minutes,
            "already siged"
        );
        //?????????
        if (now.sub(userMapping[msg.sender].lastAirdropTime) > 2 minutes) {
            userMapping[msg.sender].assetInfo.oxf0AmtFree = userMapping[
                msg.sender
            ].assetInfo.oxf0AmtFree.add(airdropAmt);
            userMapping[msg.sender].lastAirdropTime = now;
            //????????????
            userMapping[userMapping[msg.sender].pAddr]
                .assetInfo
                .oxf0AmtFrezz = userMapping[userMapping[msg.sender].pAddr]
                .assetInfo
                .oxf0AmtFrezz
                .add(airdropAmt.div(10));
        }
        emit Airdrop(msg.sender, airdropAmt);
    }

    function inArray(address _self, address[] storage _array)
        internal
        view
        returns (bool _ret)
    {
        for (uint256 i = 0; i < _array.length; ++i) {
            if (_self == _array[i]) {
                return true;
            }
        }
        return false;
    }

    //??????
    function invest(
        uint256 _invType,
        uint256 _amount,
        uint256 _pid
    ) public {
        //????????????
        require(_amount > 0, "need _amount > 0");

        if (!isReg(address(msg.sender))) {
            regUser(address(msg.sender), indexMapping[_pid]);
        }

        //?????????????????????????????????????????????
        if (userMapping[msg.sender].lastRlsTime > 0) {
            require(
                now.sub(userMapping[msg.sender].lastRlsTime) < 2 minutes,
                "need havest first"
            );
        }

        uint256 invHr = 0;
        uint256 depositAmt = 0;
        if (_invType == 0) {
            //ord ??????
            //????????????????????????
            require(
                userMapping[msg.sender].investInfo.invesTimeMapping[0] == 0,
                "have not close"
            );

            ordToken.safeTransferFrom(
                address(msg.sender),
                address(this),
                _amount
            );
            invHr = _amount.mul(ordPrice).div(10).mul(2); //??????2?????????
            depositAmt = _amount.mul(ordPrice);
            if (userMapping[msg.sender].investInfo.invesAmtMapping[0] > 0) {
                require(
                    userMapping[msg.sender].investInfo.invesAmtMapping[0] <=
                        depositAmt,
                    "need more than last"
                );
            }

            userMapping[msg.sender].assetInfo.hashRate = userMapping[msg.sender]
                .assetInfo
                .hashRate
                .add(invHr);
            userMapping[msg.sender].assetInfo.ordBurnAmtSum = userMapping[
                msg.sender
            ].assetInfo.ordBurnAmtSum.add(_amount);
            userMapping[msg.sender].assetInfo.depositAmt = userMapping[
                msg.sender
            ].assetInfo.depositAmt.add(depositAmt);
            userMapping[msg.sender].assetInfo.hashRateRight = 10;
            userMapping[msg.sender].investInfo.invesAmtMapping[0] = depositAmt;
            userMapping[msg.sender].investInfo.invesTimeMapping[0] = now;

            ordBurnAmtSum = ordBurnAmtSum.add(_amount);
            invHr0 = invHr0.add(invHr);
        } else if (_invType == 1) {
            //oxf ??????
            require(oxfRlsAmtSum <= 3000000 * 1e18, "this type is close");
            require(
                userMapping[msg.sender].investInfo.invesTimeMapping[1] == 0,
                "have not close"
            );

            oxfToken.safeTransferFrom(
                address(msg.sender),
                address(this),
                _amount
            );
            usdtToken.safeTransferFrom(
                address(msg.sender),
                address(this),
                _amount
            );
            invHr = _amount.div(20) + _amount.mul(oxfPrice).div(20);
            depositAmt = _amount.mul(oxfPrice).add(_amount);
            if (userMapping[msg.sender].investInfo.invesAmtMapping[1] > 0) {
                require(
                    userMapping[msg.sender].investInfo.invesAmtMapping[1] <=
                        depositAmt,
                    "need more than last"
                );
            }

            userMapping[msg.sender].assetInfo.hashRate = userMapping[msg.sender]
                .assetInfo
                .hashRate
                .add(invHr);
            userMapping[msg.sender].assetInfo.oxfBurnAmtSum = userMapping[
                msg.sender
            ].assetInfo.oxfBurnAmtSum.add(_amount);
            userMapping[msg.sender].assetInfo.usdtBurnAmtSum = userMapping[
                msg.sender
            ].assetInfo.usdtBurnAmtSum.add(_amount);
            userMapping[msg.sender].assetInfo.depositAmt = userMapping[
                msg.sender
            ].assetInfo.depositAmt.add(depositAmt);
            userMapping[msg.sender].investInfo.invesAmtMapping[1] = depositAmt;
            userMapping[msg.sender].investInfo.invesTimeMapping[1] = now;

            userMapping[msg.sender].assetInfo.hashRateRight = 10;
            userMapping[msg.sender].assetInfo.hashRateReward = userMapping[
                msg.sender
            ].assetInfo.hashRateReward.add(invHr);

            oxfBurnAmtSum = oxfBurnAmtSum.add(_amount);
            usdtAmtSum = usdtAmtSum.add(_amount);
            invHr1 = invHr1.add(invHr);
        } else if (_invType == 2) {
            //oxf ??????
            require(oxfBurnAmtSum < 11000000 * 1e18, "this type is close");
            require(
                userMapping[msg.sender].investInfo.invesTimeMapping[2] == 0,
                "have not close"
            );

            oxfToken.safeTransferFrom(
                address(msg.sender),
                address(this),
                _amount
            );
            invHr = _amount.mul(oxfPrice).div(10);
            depositAmt = _amount.mul(oxfPrice);
            if (userMapping[msg.sender].investInfo.invesAmtMapping[2] > 0) {
                require(
                    userMapping[msg.sender].investInfo.invesAmtMapping[2] <=
                        depositAmt,
                    "need more than last"
                );
            }

            userMapping[msg.sender].assetInfo.hashRate = userMapping[msg.sender]
                .assetInfo
                .hashRate
                .add(invHr);
            userMapping[msg.sender].assetInfo.oxfBurnAmtSum = userMapping[
                msg.sender
            ].assetInfo.oxfBurnAmtSum.add(_amount);
            userMapping[msg.sender].assetInfo.depositAmt = userMapping[
                msg.sender
            ].assetInfo.depositAmt.add(depositAmt);
            userMapping[msg.sender].investInfo.invesAmtMapping[2] = depositAmt;
            userMapping[msg.sender].investInfo.invesTimeMapping[2] = now;

            userMapping[msg.sender].assetInfo.hashRateRight = 10;
            oxfBurnAmtSum = oxfBurnAmtSum.add(_amount);
            invHr2 = invHr2.add(invHr);
        } else if (_invType == 3) {
            //oxf ??????
            require(oxfDepositAmtSum < 6100000 * 1e18, "this type is close");
            require(
                userMapping[msg.sender].investInfo.invesTimeMapping[3] == 0,
                "have not close"
            );

            oxfToken.safeTransferFrom(
                address(msg.sender),
                address(this),
                _amount
            );
            invHr = _amount.mul(oxfPrice).div(10);
            depositAmt = _amount.mul(oxfPrice);
            if (userMapping[msg.sender].investInfo.invesAmtMapping[3] > 0) {
                require(
                    userMapping[msg.sender].investInfo.invesAmtMapping[3] <=
                        depositAmt,
                    "need more than last"
                );
            }

            userMapping[msg.sender].assetInfo.hashRate = userMapping[msg.sender]
                .assetInfo
                .hashRate
                .add(invHr);
            userMapping[msg.sender].assetInfo.oxfAmtDeposit = userMapping[
                msg.sender
            ].assetInfo.oxfAmtDeposit.add(_amount);
            userMapping[msg.sender].assetInfo.depositAmt = userMapping[
                msg.sender
            ].assetInfo.depositAmt.add(depositAmt);
            userMapping[msg.sender].investInfo.invesAmtMapping[3] = depositAmt;
            userMapping[msg.sender].investInfo.invesTimeMapping[3] = now;

            userMapping[msg.sender].assetInfo.hashRateRight = 10;
            oxfDepositAmtSum = oxfDepositAmtSum.add(_amount);
            invHr3 = invHr3.add(invHr);
        }

        //????????????
        rewardParent(userMapping[msg.sender].pAddr, depositAmt, 1);

        emit Deposit(msg.sender, _amount);
    }

    //????????????
    function rewardParent(
        address _pAddr,
        uint256 _depositAmt,
        uint8 _deep
    ) private {
        if (_deep > 10) {
            return;
        }

        if (_deep == 1) {
            //????????????
            userMapping[_pAddr].rewardStat.tuiAmtSum = userMapping[_pAddr]
                .rewardStat
                .tuiAmtSum
                .add(_depositAmt);
            userMapping[_pAddr].rewardStat.tuiCnt = userMapping[_pAddr]
                .rewardStat
                .tuiCnt
                .add(1);
        }

        if (
            userMapping[_pAddr].rewardStat.tuiCnt >= 1 &&
            userMapping[_pAddr].rewardStat.tuiCnt < 3
        ) {
            userMapping[_pAddr].ulevel = 1;
        } else if (
            userMapping[_pAddr].rewardStat.tuiCnt >= 3 &&
            userMapping[_pAddr].rewardStat.tuiCnt < 6
        ) {
            userMapping[_pAddr].ulevel = 2;
        } else if (
            userMapping[_pAddr].rewardStat.tuiCnt >= 6 &&
            userMapping[_pAddr].rewardStat.tuiCnt < 10
        ) {
            userMapping[_pAddr].ulevel = 3;
        } else if (
            userMapping[_pAddr].rewardStat.tuiCnt >= 10 &&
            userMapping[_pAddr].rewardStat.tuiCnt < 20
        ) {
            userMapping[_pAddr].ulevel = 4;
        } else if (userMapping[_pAddr].rewardStat.tuiCnt >= 20) {
            userMapping[_pAddr].ulevel = 5;
        }
        //?????????
        userMapping[_pAddr].rewardStat.teamAmtSum = userMapping[_pAddr]
            .rewardStat
            .teamAmtSum
            .add(_depositAmt);
        userMapping[_pAddr].rewardStat.teamCnt = userMapping[_pAddr]
            .rewardStat
            .teamCnt
            .add(1);
        if (userMapping[_pAddr].rewardStat.teamCnt > 50000) {
            if (!inArray(_pAddr, addressCorList)) {
                addressCorList.push(_pAddr); //???????????????
            }
        }

        //??????????????????
        if (
            userMapping[_pAddr].rewardStat.teamAmtSum >= 100000 * 1e18 &&
            userMapping[_pAddr].rewardStat.teamAmtSum < 1000000 * 1e18
        ) {
            userMapping[_pAddr].assetInfo.oxf0AmtFrezz = userMapping[_pAddr]
                .assetInfo
                .oxf0AmtFrezz
                .add(_depositAmt.div(20).div(oxfPrice));
        } else if (
            userMapping[_pAddr].rewardStat.teamAmtSum >= 1000000 * 1e18 &&
            userMapping[_pAddr].rewardStat.teamAmtSum < 5000000 * 1e18
        ) {
            userMapping[_pAddr].assetInfo.oxf0AmtFrezz = userMapping[_pAddr]
                .assetInfo
                .oxf0AmtFrezz
                .add(_depositAmt.div(33).div(oxfPrice));
        } else if (
            userMapping[_pAddr].rewardStat.teamAmtSum >= 5000000 * 1e18 &&
            userMapping[_pAddr].rewardStat.teamAmtSum < 10000000 * 1e18
        ) {
            userMapping[_pAddr].assetInfo.oxf0AmtFrezz = userMapping[_pAddr]
                .assetInfo
                .oxf0AmtFrezz
                .add(_depositAmt.div(50).div(oxfPrice));
        } else if (
            userMapping[_pAddr].rewardStat.teamAmtSum >= 10000000 * 1e18 &&
            userMapping[_pAddr].rewardStat.teamAmtSum < 30000000 * 1e18
        ) {
            userMapping[_pAddr].assetInfo.oxf0AmtFrezz = userMapping[_pAddr]
                .assetInfo
                .oxf0AmtFrezz
                .add(_depositAmt.div(100).div(oxfPrice));
        } else if (
            userMapping[_pAddr].rewardStat.teamAmtSum >= 30000000 * 1e18
        ) {
            userMapping[_pAddr].assetInfo.oxf0AmtFrezz = userMapping[_pAddr]
                .assetInfo
                .oxf0AmtFrezz
                .add(_depositAmt.div(200).div(oxfPrice));
        }

        //????????????
        _deep++;
        rewardParent(userMapping[_pAddr].pAddr, _depositAmt, _deep);
    }

    //??????
    function harvest() public nonReentrant {
        require(userMapping[msg.sender].regTime > 0, "have you participated?");
        require(userMapping[msg.sender].status > 0, "ban user"); //?????????????????????
        require(userMapping[msg.sender].assetInfo.depositAmt > 0, "deposit 0"); //?????????0
        require(
            now.sub(userMapping[msg.sender].lastRlsTime) > 2 minutes,
            "less than 2  minutes"
        );

        uint256 oxf1rlsAmt = 0;
        uint256 oxf0rlsAmt = 0;
        uint256 caldays = now.sub(userMapping[msg.sender].lastWithdTime).div(
            2 minutes
        );

        uint256 nowOxf0Per = userMapping[msg.sender].assetInfo.oxf0AmtFrezz.div(
            50
        ); //???2%
        uint256 nowOxf1Per = userMapping[msg.sender].assetInfo.depositAmt.div(
            100
        ); //1%
        //???????????????
        if (userMapping[msg.sender].assetInfo.hashRateRight < 100) {
            uint256 innerdays = (100 -
                userMapping[msg.sender].assetInfo.hashRateRight).div(10);
            // n(a1+an)/2
            if (caldays > innerdays) {
                uint256 diffdaysfit = nowOxf1Per
                    .mul(
                        innerdays.mul(
                            userMapping[msg.sender].assetInfo.hashRateRight.add(
                                100
                            )
                        )
                    )
                    .div(200); // y=p*n(a1+an)/200
                oxf1rlsAmt = nowOxf1Per.mul(caldays.sub(innerdays)).add(
                    diffdaysfit
                );
                userMapping[msg.sender].assetInfo.hashRateRight = 100;
            } else {
                uint256 hrrate = userMapping[msg.sender]
                    .assetInfo
                    .hashRateRight;
                oxf1rlsAmt = nowOxf1Per
                    .mul(caldays.mul(hrrate.add(caldays.mul(10)).add(hrrate)))
                    .div(200); //y =p*(n*(a1+an))/200
                userMapping[msg.sender].assetInfo.hashRateRight += caldays.mul(
                    10
                );
            }
        } else {
            //??????????????????
            oxf1rlsAmt = nowOxf1Per.mul(caldays);
        }
        uint256 rlsallAmt = 0;
        bool isOut = false;
        //????????????2?????????
        if (
            userMapping[msg.sender].rewardStat.rlsAmt.add(oxf1rlsAmt) >=
            userMapping[msg.sender].assetInfo.depositAmt.mul(2)
        ) {
            oxf1rlsAmt = userMapping[msg.sender]
                .rewardStat
                .rlsAmt
                .add(oxf1rlsAmt)
                .sub(userMapping[msg.sender].assetInfo.depositAmt.mul(2));
            resetInvestAsset(msg.sender);
            isOut = true;
        }

        userMapping[msg.sender].assetInfo.oxf1AmtFree += oxf1rlsAmt.div(
            oxfPrice
        ); //??????
        rlsallAmt = oxf1rlsAmt;

        if (isOut == false && nowOxf0Per > 0) {
            //?????????????????? 2%
            oxf0rlsAmt = nowOxf0Per.mul(caldays);
            //?????????????????????????????????
            if (
                userMapping[msg.sender].assetInfo.oxf0AmtFree.mul(oxfPrice).add(
                    oxf0rlsAmt
                ) > userMapping[msg.sender].assetInfo.depositAmt
            ) {
                oxf0rlsAmt = userMapping[msg.sender].assetInfo.depositAmt;
            }
            if (oxf0rlsAmt > userMapping[msg.sender].assetInfo.oxf0AmtFrezz) {
                oxf0rlsAmt = userMapping[msg.sender].assetInfo.oxf0AmtFrezz;
            }

            rlsallAmt = oxf1rlsAmt.add(oxf0rlsAmt);
            //2????????? ?????? ??????????????????????????????????????????
            if (
                userMapping[msg.sender].rewardStat.rlsAmt.add(rlsallAmt) >=
                userMapping[msg.sender].assetInfo.depositAmt.mul(2)
            ) {
                uint256 diff2o1 = userMapping[msg.sender]
                    .rewardStat
                    .rlsAmt
                    .add(rlsallAmt)
                    .sub(userMapping[msg.sender].assetInfo.depositAmt.mul(2));
                if (oxf0rlsAmt > diff2o1) {
                    oxf0rlsAmt = oxf0rlsAmt.sub(diff2o1);
                }
                if (rlsallAmt > diff2o1) {
                    rlsallAmt = rlsallAmt.sub(diff2o1);
                }

                resetInvestAsset(msg.sender); //?????????
                isOut = true;
            } else {
                userMapping[msg.sender].assetInfo.oxf0AmtFree += oxf0rlsAmt.div(
                    oxfPrice
                ); //??????
                if (
                    oxf0rlsAmt > userMapping[msg.sender].assetInfo.oxf0AmtFrezz
                ) {
                    userMapping[msg.sender]
                        .assetInfo
                        .oxf0AmtFrezz -= userMapping[msg.sender]
                        .assetInfo
                        .oxf0AmtFrezz
                        .sub(oxf0rlsAmt);
                }
                userMapping[msg.sender].rewardStat.rlsAmt += rlsallAmt; //????????????
            }
        }
        userMapping[msg.sender].rewardStat.rlsAmtSum += rlsallAmt; //????????????
        userMapping[msg.sender].lastRlsTime = now;

        if (isOut == false) {
            resetInvestMaping(msg.sender);
        }

        //30????????????????????????10%
        uint256 spanday = now.sub(userMapping[msg.sender].lastWithdTime).div(
            2 minutes
        );
        if (spanday > 30) {
            if (spanday.sub(30) > 9) {
                userMapping[msg.sender].assetInfo.hashRateRight = 10;
            } else {
                userMapping[msg.sender].assetInfo.hashRateRight =
                    100 -
                    (spanday.sub(30)).mul(10);
            }
        }

        oxfRlsAmtSum = oxfRlsAmtSum.add(rlsallAmt);
        //???????????? ?????????????????????
        rwdSharor(userMapping[msg.sender].pAddr, oxf1rlsAmt, 1);

        emit Harvest(msg.sender, oxf1rlsAmt, oxf0rlsAmt); //???????????????
    }

    //??????
    function resetInvestMaping(address _Addr) private {
        if (
            userMapping[_Addr].investInfo.invesTimeMapping[0] > 0 &&
            now.sub(userMapping[_Addr].investInfo.invesTimeMapping[0]).div(
                2 minutes
            ) >=
            200
        ) {
            userMapping[_Addr].investInfo.invesTimeMapping[0] = 0;
        }
        if (
            userMapping[_Addr].investInfo.invesTimeMapping[1] > 0 &&
            now.sub(userMapping[_Addr].investInfo.invesTimeMapping[1]).div(
                2 minutes
            ) >=
            200
        ) {
            userMapping[_Addr].investInfo.invesTimeMapping[1] = 0;
        }
        if (
            userMapping[_Addr].investInfo.invesTimeMapping[2] > 0 &&
            now.sub(userMapping[_Addr].investInfo.invesTimeMapping[2]).div(
                2 minutes
            ) >=
            200
        ) {
            userMapping[_Addr].investInfo.invesTimeMapping[2] = 0;
        }
        if (
            userMapping[_Addr].investInfo.invesTimeMapping[3] > 0 &&
            now.sub(userMapping[_Addr].investInfo.invesTimeMapping[3]).div(
                2 minutes
            ) >=
            200
        ) {
            userMapping[_Addr].investInfo.invesTimeMapping[3] = 0;
        }
    }

    //???????????? 2???
    function resetInvestAsset(address _Addr) private {
        //????????????
        userMapping[_Addr].assetInfo.depositAmt = 0;
        userMapping[_Addr].rewardStat.rlsAmt = 0;
        userMapping[_Addr].assetInfo.oxf0AmtFrezz = 0; //??????
        userMapping[_Addr].investInfo.invesTimeMapping[0] = 0;
        userMapping[_Addr].investInfo.invesTimeMapping[1] = 0;
        userMapping[_Addr].investInfo.invesTimeMapping[2] = 0;
        userMapping[_Addr].investInfo.invesTimeMapping[3] = 0;
        userMapping[_Addr].lastOutTime = now;
        emit OutLog(_Addr, userMapping[_Addr].assetInfo.depositAmt); //????????????
        //????????????
        if (userMapping[userMapping[_Addr].pAddr].rewardStat.tuiCnt >= 1) {
            userMapping[userMapping[_Addr].pAddr].rewardStat.tuiCnt -= 1;
        }
    }

    //???????????????
    function rwdSharor(
        address _pAddr,
        uint256 _thisRls,
        uint8 _deep
    ) private {
        if (_deep > 10) {
            return;
        }
        if (userMapping[_pAddr].rewardStat.tuiCnt >= 1 && _deep == 1) {
            userMapping[_pAddr].assetInfo.oxf0AmtFrezz = userMapping[_pAddr]
                .assetInfo
                .oxf0AmtFrezz
                .add(_thisRls.mul(100).div(333)); //30%
        }
        if (userMapping[_pAddr].rewardStat.tuiCnt >= 3 && _deep == 2) {
            userMapping[_pAddr].assetInfo.oxf0AmtFrezz = userMapping[_pAddr]
                .assetInfo
                .oxf0AmtFrezz
                .add(_thisRls.div(10)); //10%
        }
        if (userMapping[_pAddr].rewardStat.tuiCnt >= 6 && _deep == 3) {
            userMapping[_pAddr].assetInfo.oxf0AmtFrezz = userMapping[_pAddr]
                .assetInfo
                .oxf0AmtFrezz
                .add(_thisRls.div(20)); //5%
        }
        if (userMapping[_pAddr].rewardStat.tuiCnt >= 10 && _deep == 4) {
            userMapping[_pAddr].assetInfo.oxf0AmtFrezz = userMapping[_pAddr]
                .assetInfo
                .oxf0AmtFrezz
                .add(_thisRls.div(50)); //2%
        }
        if (userMapping[_pAddr].rewardStat.tuiCnt >= 20 && _deep >= 5) {
            userMapping[_pAddr].assetInfo.oxf0AmtFrezz = userMapping[_pAddr]
                .assetInfo
                .oxf0AmtFrezz
                .add(_thisRls.div(100)); //1%
        }
        _deep++;
        rwdSharor(userMapping[_pAddr].pAddr, _thisRls, _deep);
    }

    //????????????
    function withd1() public nonReentrant {
        require(
            now.sub(userMapping[msg.sender].lastRlsTime) < 2 minutes ||
                userMapping[msg.sender].assetInfo.depositAmt == 0,
            "rls first"
        );
        uint256 withdAmt = userMapping[msg.sender].assetInfo.oxf1AmtFree;
        require(withdAmt > 1, "need > 1");

        userMapping[msg.sender].assetInfo.oxf1AmtFree = 0;
        //????????????????????????
        userMapping[msg.sender].assetInfo.hashRateRight = 10;
        withd(withdAmt);
    }

    //????????????
    function withd0() public nonReentrant {
        require(
            now.sub(userMapping[msg.sender].lastRlsTime) < 2 minutes ||
                userMapping[msg.sender].assetInfo.depositAmt == 0,
            "rls first"
        );
        uint256 withdAmt = userMapping[msg.sender].assetInfo.oxf0AmtFree;
        require(withdAmt > 1, "need > 1");

        userMapping[msg.sender].assetInfo.oxf0AmtFree = 0;
        withd(withdAmt);
    }

    //??????
    function withd(uint256 withdAmt) private {
        uint256 thisFee = withdAmt.div(10); // 10%
        //???????????????
        txFee = txFee.add(thisFee);
        txFeeSum = txFeeSum.add(thisFee);

        withdAmt = withdAmt.sub(thisFee);

        require(withdAmt < oxfToken.balanceOf(address(this)), "not enough ord");
        oxfToken.safeTransfer(address(msg.sender), withdAmt);
        userMapping[msg.sender].lastWithdTime = now;
        userMapping[msg.sender].assetInfo.oxfAmtWithdSum = userMapping[
            msg.sender
        ].assetInfo.oxfAmtWithdSum.add(withdAmt);

        //????????????????????? ?????????
        rwdLeader(userMapping[msg.sender].pAddr, thisFee.mul(oxfPrice), 1);
        //???????????????
        if (addressCorList.length > 0) {
            for (uint256 i = 0; i < addressCorList.length; i++) {
                userMapping[addressCorList[i]]
                    .assetInfo
                    .oxf0AmtFrezz = userMapping[addressCorList[i]]
                    .assetInfo
                    .oxf0AmtFrezz
                    .add(thisFee.div(100)); //1%
            }
        }
    }

    //???????????????
    function wthdFee(address raddr, uint256 _oxfAmt) public onlyAdmin {
        require(_oxfAmt <= txFee, "not enough txFee");
        require(
            _oxfAmt < oxfToken.balanceOf(address(this)),
            "not enough token"
        );
        txFee = txFee.sub(_oxfAmt);
        oxfToken.safeTransfer(raddr, _oxfAmt);

        emit WthdFee(msg.sender, _oxfAmt);
    }

    //?????????????????????
    function rwdLeader(
        address _pAddr,
        uint256 _thisFee,
        uint8 _deep
    ) private {
        if (_deep > 10) {
            return;
        }
        if (
            userMapping[_pAddr].rewardStat.teamCnt > 500 &&
            userMapping[_pAddr].rewardStat.teamCnt <= 1000
        ) {
            userMapping[_pAddr].assetInfo.oxf0AmtFrezz = userMapping[_pAddr]
                .assetInfo
                .oxf0AmtFrezz
                .add(_thisFee.mul(100).div(3333)); //3%
        } else if (
            userMapping[_pAddr].rewardStat.teamCnt > 1000 &&
            userMapping[_pAddr].rewardStat.teamCnt <= 3000
        ) {
            userMapping[_pAddr].assetInfo.oxf0AmtFrezz = userMapping[_pAddr]
                .assetInfo
                .oxf0AmtFrezz
                .add(_thisFee.mul(100).div(2857)); //3.5%
        } else if (
            userMapping[_pAddr].rewardStat.teamCnt > 3000 &&
            userMapping[_pAddr].rewardStat.teamCnt <= 10000
        ) {
            userMapping[_pAddr].assetInfo.oxf0AmtFrezz = userMapping[_pAddr]
                .assetInfo
                .oxf0AmtFrezz
                .add(_thisFee.mul(100).div(2500)); //4%
        } else if (
            userMapping[_pAddr].rewardStat.teamCnt > 10000 &&
            userMapping[_pAddr].rewardStat.teamCnt <= 50000
        ) {
            userMapping[_pAddr].assetInfo.oxf0AmtFrezz = userMapping[_pAddr]
                .assetInfo
                .oxf0AmtFrezz
                .add(_thisFee.mul(100).div(2222)); //4.5%
        }

        _deep++;
        rwdLeader(userMapping[_pAddr].pAddr, _thisFee, _deep);
    }

    //???????????????
    function nodeReword(address[] calldata top51) public onlyAdmin {
        //7?????????
        require(now.sub(lastNodeRewardTime) < 14 minutes, "less 1 weeks");
        require(top51.length > 51, "more than 51");

        uint256 rewardFeePer = txFee.div(20).div(51).mul(oxfPrice); // 5%?????????
        txFee = txFee.sub(txFee.div(20)); //???????????? 5%

        for (uint256 i = 0; i < top51.length; i++) {
            userMapping[top51[i]].assetInfo.oxf0AmtFrezz = userMapping[top51[i]]
                .assetInfo
                .oxf0AmtFrezz
                .add(rewardFeePer);
            emit NodeReward(top51[i], rewardFeePer);
        }
    }

    //?????? oxf ???????????? ???????????? / ??????ord???oxf ????????????????????????
    function finalWithdraw(
        address raddr,
        uint256 _ordAmt,
        uint256 _oxfAmt,
        uint256 _usdtAmt
    ) public onlyAdmin {
        require(_ordAmt < ordToken.balanceOf(address(this)), "not enough ord");
        require(_oxfAmt < oxfToken.balanceOf(address(this)), "not enough oxf");
        require(
            _usdtAmt < usdtToken.balanceOf(address(this)),
            "not enough usdt"
        );
        if (_ordAmt > 0) {
            ordToken.safeTransfer(raddr, _ordAmt);
        }
        if (_oxfAmt > 0) {
            oxfToken.safeTransfer(raddr, _oxfAmt);
        }
        if (_usdtAmt > 0) {
            usdtToken.safeTransfer(raddr, _usdtAmt);
        }
    }

    //????????????
    function pool() public view returns (uint256[15] memory data) {
        data[0] = invHr0; //ord ??????
        data[1] = invHr1; //?????? ??????
        data[2] = invHr2; //oxf ?????? ??????
        data[3] = invHr3; //oxf ?????? ??????

        data[4] = ordBurnAmtSum; //ord????????????
        data[5] = oxfBurnAmtSum; //oxf????????????
        data[6] = oxfDepositAmtSum; //???????????? oxf
        data[7] = oxfRlsAmtSum; //???????????? oxf
        data[8] = usdtAmtSum; //??????USDT
        data[9] = uid.sub(100000); //????????????

        data[10] = ordPrice; //ord ??????
        data[11] = oxfPrice; //oxf ??????
        data[12] = lastNodeRewardTime; //??????
        data[13] = txFeeSum; //???????????????????????????
        data[14] = txFee; //?????????,?????????
    }

    //????????????
    function useri(address addr)
        public
        view
        returns (uint256[33] memory user, address pAddr)
    {
        require(
            msg.sender == adminAddress || msg.sender == addr,
            "Permission denied for view user's privacy"
        );

        //oxf ??????
        user[0] = userMapping[addr].assetInfo.oxf0AmtFree; // ???????????????
        user[1] = userMapping[addr].assetInfo.oxf0AmtFrezz; // ????????????
        user[2] = userMapping[addr].assetInfo.oxf1AmtFree; // ???????????????
        user[3] = userMapping[addr].assetInfo.oxfAmtDeposit; // ????????????
        user[4] = userMapping[addr].assetInfo.oxfAmtWithdSum; // ????????????
        user[5] = userMapping[addr].assetInfo.depositAmt; // ???????????? ????????? usdt

        //????????????
        user[6] = userMapping[addr].assetInfo.hashRate; //  ????????????
        user[7] = userMapping[addr].assetInfo.hashRateRight; //  ????????????
        user[8] = userMapping[addr].assetInfo.hashRateReward; //  ????????????

        //?????????
        user[9] = userMapping[addr].assetInfo.oxfBurnAmtSum; // ????????????
        user[10] = userMapping[addr].assetInfo.ordBurnAmtSum; // ord burn
        user[11] = userMapping[addr].assetInfo.usdtBurnAmtSum; //How many usdt the user has provided.

        //??????
        user[12] = userMapping[addr].rewardStat.tuiRwdAmt; //tuijian reward
        user[13] = userMapping[addr].rewardStat.teamRwdAmt; //team reward
        user[14] = userMapping[addr].rewardStat.leaderRwdAmt; //leader reward

        user[15] = userMapping[addr].rewardStat.tuiRwdSum;
        user[16] = userMapping[addr].rewardStat.teamRwdAmtSum; //????????????
        user[17] = userMapping[addr].rewardStat.leaderRwdAmtSum; //????????????
        user[18] = userMapping[addr].rewardStat.rlsAmt; //release all

        //??????
        user[19] = userMapping[addr].rewardStat.tuiCnt; //????????????
        user[20] = userMapping[addr].rewardStat.tuiAmtSum; //?????????????????????
        user[21] = userMapping[addr].rewardStat.teamCnt; //??????????????????10???,??????
        user[22] = userMapping[addr].rewardStat.teamAmtSum; //??????????????????10???,??????

        //??????
        user[23] = userMapping[addr].lastRlsTime; //??????????????????
        user[24] = userMapping[addr].lastWithdTime; //????????????
        user[25] = userMapping[addr].lastOutTime; //??????????????????
        user[26] = userMapping[addr].lastAirdropTime; //??????????????????
        user[27] = userMapping[addr].regTime; //????????????

        //??????
        user[28] = userMapping[addr].ulevel; //?????????v1,v2,v3,v4,v5
        user[29] = userMapping[addr].ivsCnt; //????????????
        user[30] = userMapping[addr].status; // ????????????
        user[31] = userMapping[addr].uid; // ??????ID
        user[32] = userMapping[addr].rewardStat.rlsAmtSum; // ??????????????????

        pAddr = userMapping[addr].pAddr;
    }

    //??????????????????
    function devset(
        address addr,
        uint256 tuiCnt,
        uint256 teamCnt,
        uint256 teamAmtSum
    ) public onlyAdmin {
        userMapping[addr].rewardStat.tuiCnt = tuiCnt; //???????????????
        userMapping[addr].rewardStat.teamCnt = teamCnt; //????????????
        userMapping[addr].rewardStat.teamAmtSum = teamAmtSum; //????????????
    }

    //????????????
    function devset(address addr, uint256 status) public onlyAdmin {
        userMapping[addr].status = status; //????????????
    }
}