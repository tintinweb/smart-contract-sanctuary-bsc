/**
 *Submitted for verification at BscScan.com on 2022-11-07
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;
/**
 * @dev Standard math utilities missing in the Solidity language.
 */
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
        if (returndata.length > 0) { // Return data is optional
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
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
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

contract MasterChef is Ownable
{
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    event TokenAdded(uint256 pId,address tokenAddress,uint256 tokenWeight);
    event TokenAddedMulti(uint256[] pId,address[] tokenAddress,uint256[] tokenWeight);
    event PoolAdded(uint256 pId,address lpAddress);
    event TokenPerBlock(address tokenAddress,uint256 amount);
    event TokenWeightUpdate(uint256 pId,uint256 tokenIndex,uint256 tokenWeight);
    event TokenWeightUpdateMulti(uint256[] pId,uint256[] tokenIndex,uint256[] tokenWeight);
    event Deposited(uint256 pId,uint256 amount,address user);
    event Withdrawed(uint256 pId,uint256 amount,address user);

    // Info of each user.
    struct UserInfo {
        uint256 amount;     // How many LP tokens the user has provided.
    }

    struct TokenInfo{
        IERC20 token;
        address tokenAddress;
        uint256 poolWeight;//权重
        uint256 lastUpdateBlock;
        uint256 rewardPerTokenStored;
        mapping(address => uint256) userRewardPerTokenPaid;
        mapping(address => uint256) rewards;
    }

    // Info of each pool.
    struct PoolInfo {
        IERC20 lpToken;
        uint256 totalSupply;
        TokenInfo[] tokenInfos;
        bool isAdd;
    }
    mapping (uint256 => PoolInfo) public poolInfo;
    uint256 public poolInfoSize;

    mapping (uint256 => mapping (address => UserInfo)) public userInfo;
    mapping (address => uint256) public allTokenWeight; //所有token总权重和
    mapping (address => uint256) public allTokenPerBlock; //所有token的总产出每个区块

    bool public safeWithdraw = false;

    //设置是否开启安全提取
    function setSafeWithdraw(bool _start) public onlyOwner{
        safeWithdraw = _start;
    }

    //获取某个用户在某个池子里的质押余额
    function getBalanceOf(uint256 _pId,address _user) public view returns(uint256){
        return userInfo[_pId][_user].amount;
    }

    //判断池子是否存在
    function hasPoolExist(uint256 pId) public view returns(bool){
        return poolInfo[pId].isAdd;
    }

    //设置每种token的一个区块总产出
    function setTokenPerBlock(address _tokenAddress,uint256 _amount) public onlyOwner{
        updateAllPool(address(0));
        allTokenPerBlock[_tokenAddress] = _amount;
        emit TokenPerBlock(_tokenAddress,_amount);
    }

    //添加池子
    function addPool(uint256 _pId,address _lpAddress,address _tokenAddress,uint256 _poolWeight) public onlyOwner{
        require(!hasPoolExist(_pId),'Pool has Exist');
        updateAllPool(address(0));
        poolInfoSize = poolInfoSize.add(1);
        poolInfo[_pId].isAdd = true;
        poolInfo[_pId].lpToken = IERC20(_lpAddress);
        TokenInfo memory t;
        t.token = IERC20(_tokenAddress);
        t.tokenAddress = _tokenAddress;
        t.poolWeight = _poolWeight;
        poolInfo[_pId].tokenInfos.push(t);
        allTokenWeight[_tokenAddress] = allTokenWeight[_tokenAddress].add(_poolWeight);
        emit PoolAdded(_pId,_lpAddress);
        emit TokenAdded(_pId,_tokenAddress,_poolWeight);
    }

    //为池子添加token
    function addTokenInPool(uint256 _pId,address _tokenAddress,uint256 _poolWeight) public onlyOwner{
        require(hasPoolExist(_pId),'Pool not Exist');
        updateAllPool(address(0));
        TokenInfo memory t;
        t.token = IERC20(_tokenAddress);
        t.tokenAddress = _tokenAddress;
        t.poolWeight = _poolWeight;
        t.lastUpdateBlock = block.number;
        poolInfo[_pId].tokenInfos.push(t);
        allTokenWeight[_tokenAddress] = allTokenWeight[_tokenAddress].add(_poolWeight);
        emit TokenAdded(_pId,_tokenAddress,_poolWeight);
    }

    function addTokenInPoolMulti(uint256[] memory _pIds,address[] memory _tokenAddresss,uint256[] memory _poolWeights) public onlyOwner{
        require(_pIds.length == _tokenAddresss.length,'error length');
        require(_pIds.length == _poolWeights.length,'error length');
        updateAllPool(address(0));
        for(uint256 i=0;i<_pIds.length;i++){
            uint256 _pId = _pIds[i];
            address _tokenAddress = _tokenAddresss[i];
            uint256 _poolWeight = _poolWeights[i];
            if(hasPoolExist(_pId)){
                TokenInfo memory t;
                t.token = IERC20(_tokenAddress);
                t.tokenAddress = _tokenAddress;
                t.poolWeight = _poolWeight;
                t.lastUpdateBlock = block.number;
                poolInfo[_pId].tokenInfos.push(t);
                allTokenWeight[_tokenAddress] = allTokenWeight[_tokenAddress].add(_poolWeight);
            }
        }
        emit TokenAddedMulti(_pIds,_tokenAddresss,_poolWeights);
    }

    //更改某个池子里的token权重
    function setTokenInPool(uint256 _pId,uint256 _tokenIndex,uint256 _poolWeight) public onlyOwner{
        updateAllPool(address(0));
        uint256 prevAllocPoint = poolInfo[_pId].tokenInfos[_tokenIndex].poolWeight;
        address tokenAddress = poolInfo[_pId].tokenInfos[_tokenIndex].tokenAddress;
        poolInfo[_pId].tokenInfos[_tokenIndex].poolWeight = _poolWeight;
        if (prevAllocPoint != _poolWeight) {
            allTokenWeight[tokenAddress] = allTokenWeight[tokenAddress].sub(prevAllocPoint).add(_poolWeight);
        }
        emit TokenWeightUpdate(_pId,_tokenIndex,_poolWeight);
    }

    //批量更改池子权重
    function setTokenInPoolMulti(uint256[] memory _pIds,uint256[] memory _tokenIndexs,uint256[] memory _poolWeights) public onlyOwner{
        require(_pIds.length == _tokenIndexs.length,'error length');
        require(_pIds.length == _poolWeights.length,'error length');
        updateAllPool(address(0));
        for(uint256 i=0;i<_pIds.length;i++){
            uint256 _pId = _pIds[i];
            uint256 _tokenIndex = _tokenIndexs[i];
            uint256 _poolWeight = _poolWeights[i];
            uint256 prevAllocPoint = poolInfo[_pId].tokenInfos[_tokenIndex].poolWeight;
            address tokenAddress = poolInfo[_pId].tokenInfos[_tokenIndex].tokenAddress;
            poolInfo[_pId].tokenInfos[_tokenIndex].poolWeight = _poolWeight;
            if (prevAllocPoint != _poolWeight) {
                allTokenWeight[tokenAddress] = allTokenWeight[tokenAddress].sub(prevAllocPoint).add(_poolWeight);
            }
        }
        emit TokenWeightUpdateMulti(_pIds,_tokenIndexs,_poolWeights);
    }

    function deposit(uint256 _pId,uint256 _amount) public{
        require(hasPoolExist(_pId),'Pool not Exist');
        if(poolInfo[_pId].tokenInfos.length > 0){
            updatePoolAllToken(_pId,msg.sender);
            poolInfo[_pId].totalSupply = poolInfo[_pId].totalSupply.add(_amount);
            userInfo[_pId][msg.sender].amount = userInfo[_pId][msg.sender].amount.add(_amount);
            poolInfo[_pId].lpToken.safeTransferFrom(msg.sender, address(this), _amount);
            emit Deposited(_pId,_amount,msg.sender);
        }
    }

    function withdraw(uint256 _pId,uint256 _amount) public{
        require(hasPoolExist(_pId),'Pool not Exist');
        require(userInfo[_pId][msg.sender].amount >= _amount,'Amount over');
        updatePoolAllToken(_pId,msg.sender);
        poolInfo[_pId].lpToken.safeTransfer(msg.sender, _amount);
        poolInfo[_pId].totalSupply = poolInfo[_pId].totalSupply.sub(_amount);
        userInfo[_pId][msg.sender].amount = userInfo[_pId][msg.sender].amount.sub(_amount);
        emit Withdrawed(_pId,_amount,msg.sender);
    }

    //安全提取自己质押的token，紧急情况
    function withdrawSafe(uint256 _pId) public{
        require(hasPoolExist(_pId),'Pool not Exist');
        if(safeWithdraw){
            userInfo[_pId][msg.sender].amount = 0;
            for(uint256 k=0;k<poolInfo[_pId].tokenInfos.length;k++){
                poolInfo[_pId].tokenInfos[k].rewards[msg.sender] = 0;
            }
            poolInfo[_pId].lpToken.safeTransfer(msg.sender, userInfo[_pId][msg.sender].amount);
        }
    }

    function getReward(uint256 _pId) public{
        require(hasPoolExist(_pId),'Pool not Exist');
        if(poolInfo[_pId].tokenInfos.length > 0){
            updatePoolAllToken(_pId,msg.sender);
            for(uint256 k=0;k<poolInfo[_pId].tokenInfos.length;k++){
                uint256 reward = earned(_pId,k,msg.sender);
                if(reward > 0){
                    poolInfo[_pId].tokenInfos[k].rewards[msg.sender] = 0;
                    poolInfo[_pId].tokenInfos[k].token.safeTransfer(msg.sender, reward);
                }
            }
        }
    }

    function getRewardSingle(uint256 _pId,uint256 _tokenIndex) public{
        require(hasPoolExist(_pId),'Pool not Exist');
        updatePoolAllToken(_pId,msg.sender);
        uint256 reward = earned(_pId,_tokenIndex,msg.sender);
        if(reward > 0){
            poolInfo[_pId].tokenInfos[_tokenIndex].rewards[msg.sender] = 0;
            poolInfo[_pId].tokenInfos[_tokenIndex].token.safeTransfer(msg.sender, reward);
        }
    }

    function earned(uint256 _pid,uint256 _tokenIndex,address _user) public view returns (uint256) {
        uint256 rpt = rewardPerToken(_pid,_tokenIndex);
        uint256 x = rpt.sub(poolInfo[_pid].tokenInfos[_tokenIndex].userRewardPerTokenPaid[_user]);
        return
        userInfo[_pid][_user].amount
        .mul(x)
        .div(1e18)
        .add(poolInfo[_pid].tokenInfos[_tokenIndex].rewards[_user]);
    }

    function earnedAll(uint256 _pid,address _user) public view returns (uint256[] memory) {
        uint256[] memory a;
        if(poolInfo[_pid].tokenInfos.length > 0){
            a =new uint[](poolInfo[_pid].tokenInfos.length);
            for(uint256 i=0;i<poolInfo[_pid].tokenInfos.length;i++){
                uint256 rpt = rewardPerToken(_pid,i);
                uint256 x = rpt.sub(poolInfo[_pid].tokenInfos[i].userRewardPerTokenPaid[_user]);
                uint256 result = userInfo[_pid][_user].amount
                .mul(x)
                .div(1e18)
                .add(poolInfo[_pid].tokenInfos[i].rewards[_user]);
                a[i] = result;
            }
            return a;
        }
        return a;
    }

    function updateAllPool(address _user) public{
        for(uint256 j=0;j<poolInfoSize;j++){
            updatePoolAllToken(j,_user);
        }
    }

    //跟新某个池子里所有数据
    function updatePoolAllToken(uint256 _pId,address _user) public{
        if(poolInfo[_pId].tokenInfos.length != 0){
            for(uint256 i=0;i<poolInfo[_pId].tokenInfos.length;i++){
                poolInfo[_pId].tokenInfos[i].rewardPerTokenStored = rewardPerToken(_pId,i);
                poolInfo[_pId].tokenInfos[i].lastUpdateBlock = block.number;
                if (_user != address(0)) {
                    poolInfo[_pId].tokenInfos[i].rewards[_user] = earned(_pId,i,_user);
                    poolInfo[_pId].tokenInfos[i].userRewardPerTokenPaid[_user] = poolInfo[_pId].tokenInfos[i].rewardPerTokenStored;
                }
            }
        }
    }

    function rewardPerToken(uint256 _pId,uint256 _tokenIndex) public view returns (uint256) {
        if (poolInfo[_pId].totalSupply == 0) {
            return poolInfo[_pId].tokenInfos[_tokenIndex].rewardPerTokenStored;
        }
        return
        poolInfo[_pId].tokenInfos[_tokenIndex].rewardPerTokenStored.add(
            block.number
            .sub(poolInfo[_pId].tokenInfos[_tokenIndex].lastUpdateBlock)
            .mul(getTokenRate(_pId,_tokenIndex))
            .mul(1e18)
            .div(poolInfo[_pId].totalSupply)
        );
    }

    function getTokenRate(uint256 _pId,uint256 _tokenIndex) public view returns (uint256){
        TokenInfo memory t =  poolInfo[_pId].tokenInfos[_tokenIndex];
        return t.poolWeight.mul(allTokenPerBlock[t.tokenAddress]).div(allTokenWeight[t.tokenAddress]);
    }

}