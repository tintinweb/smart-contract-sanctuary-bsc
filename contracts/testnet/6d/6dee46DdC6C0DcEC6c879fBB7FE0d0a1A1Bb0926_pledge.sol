/**
 *Submitted for verification at BscScan.com on 2022-07-03
*/

/**
 *Submitted for verification at BscScan.com on 2022-04-01
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
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


    function mint(address _to, uint256 _amount) external;

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
 * @dev ????????? Solidity ??????????????????????????????????????????
 *
 * Solidity ????????????????????????????????????
 * ???????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????
 * ???SafeMath???????????????????????????????????????????????????????????????
 *
 * ?????????????????????????????????????????????????????????????????????????????????????????????????????????
 */
library SafeMath {
    /**
     * @dev ????????????????????????????????????????????????????????????
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
     * @dev ????????????????????????????????????????????? (unsigned integer modulo),
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
 * @dev ??????????????????????????????
 */
library Address {
    /**
     * @dev ?????? `account` ????????????????????? true???
     *
     * [IMPORTANT]
     * ====
     * ????????????????????? false ???????????????????????? (EOA) ?????????????????????????????????
     *
     * ???????????????????????????????????????`isContract` ????????? false???
     *
     *  - ????????????
     *  - ????????????
     *  - ????????????????????????
     *  - ?????????????????????????????????
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {codehash := extcodehash(account)}
        return (codehash != accountHash && codehash != 0x0);
    }

    /**
     * @dev ?????? Solidity ??? `transfer`?????? `amount` wei ????????? `recipient`???
     * ????????????????????? gas ??????????????????????????????
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
     * @dev ????????????
     * ?????????????????? {IERC20-approve} ??????????????????????????????????????????????????????
     *
     * ???????????????????????? {safeIncreaseAllowance} ??? {safeDecreaseAllowance}???
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
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
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
    constructor ()   {
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




contract pledge is Ownable {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    event Recharge(address token_, address from, uint256 amount_);
    event Send(address token_, address from, uint256 amount_);

    address public _ETH;
    address public _ADA;
    address public _USDT;

    uint public overTime;
    uint public time_span;

    uint public eth1_per_reward=2222;
    uint public eth2_per_reward=2222;
    uint public eth3_per_reward=2222;
    uint public eth4_per_reward=2739;
    uint public eth_invite_reward=2739;
    uint public eth_invite2_reward=2739;

    uint256 public eth1_balance_all;
    uint256 public eth2_balance_all;
    uint256 public eth3_balance_all;
    uint256 public eth4_balance_all;
    uint256 public ada1_balance_all;
    uint256 public ada2_balance_all;
    uint256 public ada3_balance_all;
    uint256 public ada4_balance_all;

    struct Pl {
        uint timeStart;
        uint256 amount;
        uint256 reward_all;
        uint256 reward_pending;
        uint256 time_last_reward;
    }

    struct User {
        uint256 amount_eth;
        uint256 amount_ada;
        uint256 amount_invite_eth;
        uint256 amount_invite2_eth;
        Pl eth1;
        Pl eth2;
        Pl eth3;
        Pl eth4;
        Pl ada1;
        Pl ada2;
        Pl ada3;
        Pl ada4;
    }

    mapping(address=>uint256) public balance;
    mapping(address => User) public userInfo;
    mapping(address=>address) public inviteMap;
    mapping(address=>uint256) public invite_eth1;
    mapping(address=>uint256) public invite_eth2;
    mapping(address=>uint256) public invite_eth3;
    mapping(address=>uint256) public invite_eth4;
    mapping(address=>uint256) public invite2_eth1;
    mapping(address=>uint256) public invite2_eth2;
    mapping(address=>uint256) public invite2_eth3;
    mapping(address=>uint256) public invite2_eth4;

    mapping(address=>uint256) public invite_num;


    constructor( address ETH_, address ADA_, address USDT_, uint time_span_)  {
        //??????id
        uint256 _chainId;
        assembly {
            //????????????id
            _chainId := chainid()
        }
        //???id == 56 ???56???????????????
        require(_chainId == 97, "Invalid Network" );
        _ETH = ETH_;
        _ADA = ADA_;
        _USDT = USDT_;
        time_span = time_span_;
    }


    //??????time_span(????????????86400)
    function setTimeSpan(uint time_span_) public onlyOwner{
        time_span = time_span_;
    }

    //??????overTime
    function setOverTime(uint time_) public onlyOwner{
        overTime = time_;
    }

    //?????????????????????
    function setPerReward(uint eth1_per_reward_,uint eth2_per_reward_,uint eth3_per_reward_,uint eth4_per_reward_,uint eth_invite_reward_,uint eth_invite2_reward_) public onlyOwner{
        eth1_per_reward = eth1_per_reward_;
        eth2_per_reward = eth2_per_reward_;
        eth3_per_reward = eth3_per_reward_;
        eth4_per_reward = eth4_per_reward_;
        eth_invite_reward = eth_invite_reward_;
        eth_invite2_reward = eth_invite2_reward_;
    }

    //??????eth
    function pledgeETH(uint256 amount_,uint256 type_,uint256 price,address inviter) public {
        //??????eth?????????
        require(block.timestamp<overTime,"pledge is over time");
        _recharge(_ETH,msg.sender,amount_);
        if (inviteMap[msg.sender]== address(0) ){
            if (balance[msg.sender]>100*(10**18)){
                inviteMap[msg.sender] = inviter;
                invite_num[inviter] = invite_num[inviter].add(1);
            }
            
        }
        User storage user = userInfo[msg.sender];
        uint256 usdt_amount_ = amount_.mul(price);
        user.amount_eth = user.amount_eth.add(usdt_amount_);
        if(type_==1){
            user.eth1.amount = user.eth1.amount.add(usdt_amount_);
            user.eth1.timeStart = block.timestamp;
            eth1_balance_all = eth1_balance_all.add(usdt_amount_);
            invite_eth1[inviteMap[msg.sender]] = invite_eth1[inviter].add(usdt_amount_);
            invite_eth1[inviteMap[inviteMap[msg.sender]]] = invite_eth1[inviter].add(usdt_amount_);
        }
        if(type_==2){
            user.eth2.amount = user.eth2.amount.add(usdt_amount_);
            user.eth2.timeStart = block.timestamp;
            eth2_balance_all = eth2_balance_all.add(usdt_amount_);
            invite_eth2[inviteMap[msg.sender]] = invite_eth2[inviter].add(usdt_amount_);
            invite_eth2[inviteMap[inviteMap[msg.sender]]] = invite_eth2[inviter].add(usdt_amount_);
        }
        if(type_==3){
            user.eth3.amount = user.eth3.amount.add(usdt_amount_);
            user.eth3.timeStart = block.timestamp;
            eth3_balance_all = eth3_balance_all.add(usdt_amount_);
            invite_eth3[inviteMap[msg.sender]] = invite_eth3[inviter].add(usdt_amount_);
            invite_eth3[inviteMap[inviteMap[msg.sender]]] = invite_eth3[inviter].add(usdt_amount_);
        }
        if(type_==4){
            user.eth4.amount = user.eth4.amount.add(usdt_amount_);
            user.eth4.timeStart = block.timestamp;
            eth4_balance_all = eth4_balance_all.add(usdt_amount_);
            invite_eth4[inviteMap[msg.sender]] = invite_eth4[inviter].add(usdt_amount_);
            invite_eth4[inviteMap[inviteMap[msg.sender]]] = invite_eth4[inviter].add(usdt_amount_);
        }
    }


    //??????eth
    function redeemETH(uint256 usdt_amount_,uint type_) public{
        User storage user = userInfo[msg.sender];
        if(type_==1){
            require(block.timestamp>user.eth1.timeStart+time_span.mul(90) || block.timestamp>overTime,"time is not allow redeem");
            require(user.eth1.amount>=usdt_amount_,"amount is not enough to redeem");
            _refund(_USDT, msg.sender, usdt_amount_);
            user.amount_eth = user.amount_eth.sub(usdt_amount_);
            user.eth1.amount = user.eth1.amount.sub(usdt_amount_);
            user.eth1.timeStart = block.timestamp;
            eth1_balance_all = eth1_balance_all.sub(usdt_amount_);
            invite_eth1[inviteMap[msg.sender]] = invite_eth1[inviteMap[msg.sender]].sub(usdt_amount_);
            invite_eth1[inviteMap[inviteMap[msg.sender]]] = invite_eth1[inviteMap[inviteMap[msg.sender]]].sub(usdt_amount_);
        }
        if(type_==2){
            require(block.timestamp>user.eth2.timeStart+time_span.mul(180) || block.timestamp>overTime,"time is not allow redeem");
            require(user.eth2.amount>=usdt_amount_,"amount is not enough to redeem");
            user.eth2.amount = user.eth2.amount.sub(usdt_amount_);
            user.eth2.timeStart = block.timestamp;
            eth2_balance_all = eth2_balance_all.sub(usdt_amount_);
            invite_eth2[inviteMap[msg.sender]] = invite_eth2[inviteMap[msg.sender]].sub(usdt_amount_);
            invite_eth2[inviteMap[inviteMap[msg.sender]]] = invite_eth2[inviteMap[inviteMap[msg.sender]]].sub(usdt_amount_);
        }
        if(type_==3){
            require(block.timestamp>user.eth3.timeStart+time_span.mul(270) || block.timestamp>overTime,"time is not allow redeem");
            require(user.eth3.amount>=usdt_amount_,"amount is not enough to redeem");
            user.eth3.amount = user.eth3.amount.sub(usdt_amount_);
            user.eth3.timeStart = block.timestamp;
            eth3_balance_all = eth3_balance_all.sub(usdt_amount_);
            invite_eth3[inviteMap[msg.sender]] = invite_eth3[inviteMap[msg.sender]].sub(usdt_amount_);
            invite_eth3[inviteMap[inviteMap[msg.sender]]] = invite_eth3[inviteMap[inviteMap[msg.sender]]].sub(usdt_amount_);
        }
        if(type_==4){
            require(block.timestamp>user.eth4.timeStart+time_span.mul(365) || block.timestamp>overTime,"time is not allow redeem");
            require(user.eth4.amount>=usdt_amount_,"amount is not enough to redeem");
            user.eth4.amount = user.eth4.amount.sub(usdt_amount_);
            user.eth4.timeStart = block.timestamp;
            eth4_balance_all = eth4_balance_all.sub(usdt_amount_);
            invite_eth4[inviteMap[msg.sender]] = invite_eth4[inviteMap[msg.sender]].sub(usdt_amount_);
            invite_eth4[inviteMap[inviteMap[msg.sender]]] = invite_eth4[inviteMap[inviteMap[msg.sender]]].sub(usdt_amount_);
        }
    }

    //????????????
    function seeMyRewardETH() public view returns(uint256,uint256,uint256,uint256,uint256){
        User storage user = userInfo[msg.sender];
        uint256 amt = 0;
        uint256 amt1 =0;
        uint256 amt2 =0;
        uint256 amt3 =0;
        uint256 amt4 =0;
        uint256 amt_invite_1 =0;
        uint256 amt_invite_2 = 0;
        
        if(invite_eth1[msg.sender]>0){
            uint time_last = block.timestamp;
            if(time_last>overTime){
                time_last = overTime;
            }
            uint time_pend = time_last.sub(user.eth1.time_last_reward).div(time_span); // ??????????????????
            amt_invite_1 = user.amount_invite_eth.mul(eth_invite_reward).div(1000000).mul(time_pend); // ???????????????amount    
        }
        if(invite_eth2[msg.sender]>0){
            uint time_last = block.timestamp;
            if(time_last>overTime){
                time_last = overTime;
            }
            uint256 v = eth_invite2_reward; //?????????????????????
            if (invite_num[msg.sender]>=6){//???????????????
                v = eth_invite2_reward.mul(2);
            }
            uint time_pend = time_last.sub(user.eth1.time_last_reward).div(time_span); // ??????????????????
            amt_invite_2 = user.amount_invite_eth.mul(v); // ???????????????amount    
            amt_invite_2 = amt_invite_2.div(1000000).mul(time_pend);
        }
        //??????????????????
        if(user.eth1.amount>0){
            //????????????
            uint time_last = block.timestamp;
            if(time_last>user.eth1.timeStart+time_span.mul(90)){
                time_last = user.eth1.timeStart+time_span.mul(90);
            }
            if(time_last>overTime){
                time_last = overTime;
            }
            uint time_pend = time_last.sub(user.eth1.time_last_reward).div(time_span); // ??????????????????
            amt1 = user.eth1.amount.mul(eth1_per_reward).div(100000).mul(time_pend); // ???????????????amount
            amt = amt.add(amt1);
        }
        if(user.eth2.amount>0){
            //????????????
            uint time_last = block.timestamp;
            if(time_last>user.eth2.timeStart+time_span.mul(180)){
                time_last = user.eth2.timeStart+time_span.mul(180);
            }
            if(time_last>overTime){
                time_last = overTime;
            }

            uint time_pend = time_last.sub(user.eth2.time_last_reward).div(time_span); // ??????????????????
            amt2 = user.eth2.amount.mul(eth2_per_reward).div(100000).mul(time_pend); // ???????????????amount
            amt = amt.add(amt2);
        }
        if(user.eth3.amount>0){
            //????????????
            uint time_last = block.timestamp;
            if(time_last>user.eth3.timeStart+time_span.mul(270)){
                time_last = user.eth3.timeStart+time_span.mul(270);
            }
            if(time_last>overTime){
                time_last = overTime;
            }

            uint time_pend = time_last.sub(user.eth3.time_last_reward).div(time_span); // ??????????????????
            amt3 = user.eth3.amount.mul(eth3_per_reward).div(100000).mul(time_pend); // ???????????????amount
            amt = amt.add(amt3);
        }
        if(user.eth4.amount>0){
            //????????????
            uint time_last = block.timestamp;
            if(time_last>user.eth4.timeStart+time_span.mul(365)){
                time_last = user.eth4.timeStart+time_span.mul(365);
            }
            if(time_last>overTime){
                time_last = overTime;
            }

            uint time_pend = time_last.sub(user.eth4.time_last_reward).div(time_span); // ??????????????????
            amt4 = user.eth4.amount.mul(eth4_per_reward).div(100000).mul(time_pend); // ???????????????amount
            amt = amt.add(amt4);
        }
        return (amt,amt1,amt2,amt3,amt4);
    }

    // ????????????
    function takeMyRewardETH() public {
        User storage user = userInfo[msg.sender];
        uint256 amt = 0; 
        uint256 amt1= 0;
        uint256 amt2= 0;
        uint256 amt3= 0;
        uint256 amt4= 0;
        (amt,amt1,amt2,amt3,amt4) = seeMyRewardETH();
        // ??????????????????
        user.eth1.reward_all = user.eth1.reward_all.add(amt1);
        user.eth2.reward_all = user.eth2.reward_all.add(amt2);
        user.eth3.reward_all = user.eth3.reward_all.add(amt3);
        user.eth4.reward_all = user.eth4.reward_all.add(amt4);
        // ????????????????????????
        user.eth1.time_last_reward = block.timestamp;
        user.eth2.time_last_reward = block.timestamp;
        user.eth3.time_last_reward = block.timestamp;
        user.eth4.time_last_reward = block.timestamp;
        _refund(_USDT, msg.sender, amt);
    }



    //?????? ????????????
    function _recharge(address token_, address from_, uint256 amount_) internal {
        //???????????? > ????????????
        require(IERC20(token_).balanceOf(from_)>=amount_,"token is not enough");
        IERC20(token_).transferFrom(from_, address(this), amount_);
        // ???????????? ?????????????????? ???????????? ??????
        emit Recharge(token_, from_, amount_);
    }

    //????????????
    function _refund(address token_, address account_, uint256 amount_) internal {
        //token_ ????????????
        //account_ ????????????
        //amount_ ????????????
        require(IERC20(token_).balanceOf(address(this)) >= amount_ , "Invalid Amount");
        IERC20(token_).transfer(account_, amount_);
        //???????????? ???????????? ???????????? ????????????
        emit Send(token_, account_, amount_);
    }

    
    function withdrawToken(address token_, address account_, uint256 amount_) public onlyOwner {
        //????????????????????? >= ????????????
        require(IERC20(token_).balanceOf(address(this)) >= amount_ , "Invalid Amount");
        //???????????? -> ????????????
        IERC20(token_).transfer(account_, amount_);
    }
}