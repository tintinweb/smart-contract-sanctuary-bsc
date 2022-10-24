/**
 *Submitted for verification at BscScan.com on 2022-10-24
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

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

// File: @openzeppelin/contracts/access/Ownable.sol

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
    address public _owner;

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

// File: @openzeppelin/contracts/math/SafeMath.sol

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

// File: @openzeppelin/contracts/utils/Counters.sol


library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
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
        if (returndata.length > 0) {
            // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// File: @openzeppelin/contracts/utils/Address.sol

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
        // This method relies on extcodesize, which returns 0 for contracts in
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
        return functionCallWithValue(target, data, 0, errorMessage);
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
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
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
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IAdapter {
    
    function sellBase(address to, address pool,uint balance) external returns(uint);

    function sellQuote(address to, address pool,uint balance) external returns(uint);

    function baseToken(address pool) external view returns(address);

    function quoteToken(address pool) external view returns(address);

}

pragma experimental ABIEncoderV2;

contract PersonFactory is  Ownable {
    using SafeERC20 for IERC20;
    using SafeMath for uint;

    event Transfer(address indexed from,address indexed to,uint amount);
    event TakingAmount(address indexed user,uint amount,uint failAmount,uint plateAmount);
    event Withdraw(address indexed user,uint amount);
    event Pay(address indexed user,uint amount,uint level,uint version);
    event WithdrawPlateform(address indexed user,uint amount);
    event WithdrawFail(address indexed user,uint amount);
    
    bytes4 private constant SELECTOR = bytes4(keccak256(bytes('transfer(address,uint256)')));
    
    // uint private splitTime = 1 days;
    uint private splitTime = 1 minutes;

    // uint private pInfoSplite = 1 days + 2 hours;
    uint private pInfoSplite =  1 minutes;

    uint private oneU = 10**18;

    uint private initSumAmount = 1000; 

    uint private createPercent = 30;

    uint private beforePercent = 80;

    uint private baseMin = 10 * oneU;

    uint private baseMax = 5000 * oneU;

    uint private pLevel = 0;

    mapping(uint=>uint) dayMin;

    mapping(uint=>uint) dayMax;
    
    address private usdtAddr = 0x55d398326f99059fF775485246999027B3197955;

    address private plateformAddr ;

    address private swapAdapter;

    address private swapPair;

    mapping (address=>address) public inviters;

    mapping (address=>address[]) public myInvites;

    mapping (address=>PayInfo[]) public userPayInfo;

    mapping(uint=>PInfo) public pInfo;

    mapping(uint=>mapping(uint=>uint)) public pInfoSellAmount;

    mapping (address=>UserInfo) public userInfo;

    address[] private payerFactorys;

    struct UserInfo {
        uint usdtAmount;
        uint takingAmount;
        uint payAmount;
        uint plateAmount;
        uint failBackAmount;
        uint failBack;
        uint failBackPlate;
    }

    struct PInfo {
        uint startTimestamp;
        uint sumAmount;
    }

    struct PayInfo{
        uint pLevel;
        uint version;
        uint amount;
        uint payTimestamp;
    }

    constructor() public {
        
    }

    modifier onlyPayer() {
        bool flag = false;
        for(uint i = 0;i<payerFactorys.length;i++){
            if(msg.sender == payerFactorys[i]){
                flag = true;
            }
        }
        if(_owner == _msgSender()){
            flag = true;
        }
        require(flag, "NOT_PAYER");
        _;
    }

    function getCurrentTimestamp()public view returns (uint){
        return block.timestamp;
    }

    function getVersionStartTimestamp(uint _pLevel,uint _version) public view returns(uint) {
        if(pInfo[_pLevel].startTimestamp==uint(0)){
            return 0;
        }
        uint _startTimestamp = pInfo[_pLevel].startTimestamp;
        if(_startTimestamp==uint(0)){
            return 0;
        }
        return _startTimestamp.add(_version.mul(pInfoSplite));
    }

    function getVersionSumAmount(uint _pLevel,uint _version) public view returns(uint){
        uint _initAmount = pInfo[_pLevel].sumAmount;
        for(uint i = 0 ; i<_version;i++){
            _initAmount = _initAmount.mul(13).div(10);
        }
        return _initAmount.div(oneU).mul(oneU);
    }

    //0. no such pLevel
    //1.pre pay
    //2.paying
    //3.success wait return
    //4.fail
    //5.fail before 3 version
    //6.fail after pre pay return back 
    //7.success and start return
    function getVersionStatus(uint _pLevel,uint _version) public view returns(uint){
        uint _startTimestamp = getVersionStartTimestamp(_pLevel,_version);
        if(_startTimestamp==uint(0)){
            return 0;
        }
        (bool _fail,uint _failVersion) = getFailVersion(_pLevel);
        if(_fail){
            if(_failVersion==_version){
                return 4;
            }
            if(_failVersion<_version){
                return 6;
            }
            if(_failVersion<=3&&_version<_failVersion){
                return 5;
            }
            if(_failVersion>3&&_version<_failVersion&&_version>=_failVersion.sub(3)){
                return 5;
            }
        }
        if(_isStartReturn(_pLevel,_version)){
            return 7;
        }
        if(_isSuccess(_pLevel,_version)){
            return 3;
        }
        if(_isPaying(_pLevel,_version)){
            return 2;
        }
        return 1;
    }
    
    function getFailVersion(uint _pLevel) public view returns(bool,uint){
        uint i = 0;
        while(true){
            uint _startTimestamp = getVersionStartTimestamp(_pLevel,i);
            if(_startTimestamp==uint(0)){
                return (false,0);
            }
            if(block.timestamp<_startTimestamp.add(splitTime)){
                return (false,0);
            }
            uint _versionSumAmount = getVersionSumAmount(_pLevel,i);
            if(_versionSumAmount>pInfoSellAmount[_pLevel][i]){
                return (true,i);
            }
            i++;
        }
    }

    function _isPaying(uint _pLevel,uint _version) private view returns(bool){
        uint _startTimestamp = getVersionStartTimestamp(_pLevel,_version);
        if(_startTimestamp<block.timestamp&&_startTimestamp.add(splitTime)>block.timestamp){
            return true;
        }
        return false;
    }

    function _isStartReturn(uint _pLevel,uint _version) private view returns(bool){
        uint _versionSumAmount = getVersionSumAmount(_pLevel,_version);
        uint _startTimestamp = getVersionStartTimestamp(_pLevel,_version);
        if(_versionSumAmount==pInfoSellAmount[_pLevel][_version]
            &&block.timestamp>_startTimestamp.add(splitTime.mul(10))){
            return true;
        }
        return false;
    }

    function _isSuccess(uint _pLevel,uint _version) private view returns(bool){
        uint _versionSumAmount = getVersionSumAmount(_pLevel,_version);
        uint _startTimestamp = getVersionStartTimestamp(_pLevel,_version);
        if(_versionSumAmount==pInfoSellAmount[_pLevel][_version]
            &&block.timestamp<=_startTimestamp.add(splitTime.mul(10))){
            return true;
        }
        return false;
    }

    function getValidUser(address _user) public view returns (uint){
        uint _validUser = 0;
        for(uint i = 0;i<myInvites[_user].length;i++){
            address cUser = myInvites[_user][i];
            if(userInfo[cUser].payAmount>150*oneU){
                _validUser = _validUser + 1;
            }
            _validUser = _validUser + getValidUser(cUser);
        }
        return _validUser;
    }

    function getValidDirectUser(address _user) public view returns (uint){
        uint _validUser = 0;
        for(uint i = 0;i<myInvites[_user].length;i++){
            address cUser = myInvites[_user][i];
            if(userInfo[cUser].payAmount>150*oneU){
                _validUser = _validUser + 1;
            }
        }
        return _validUser;
    }

    function getUserLevel(address _user) public view returns(uint){
        // if(userInfo[_user].payAmount>=1000000*oneU&&getValidUser(_user)>=400&&getValidDirectUser(_user)>=100){
        //     return 4;
        // }
        // if(userInfo[_user].payAmount>=500000*oneU&&getValidUser(_user)>=300&&getValidDirectUser(_user)>=50){
        //     return 3;
        // }
        // if(userInfo[_user].payAmount>=150000*oneU&&getValidUser(_user)>=200&&getValidDirectUser(_user)>=30){
        //     return 2;
        // }
        // if(userInfo[_user].payAmount>=50000*oneU&&getValidUser(_user)>=100&&getValidDirectUser(_user)>=15){
        //     return 1;
        // }
        if(userInfo[_user].payAmount>=2000*oneU&&getValidUser(_user)>=5&&getValidDirectUser(_user)>=2){
            return 2;
        }
        if(userInfo[_user].payAmount>=1000*oneU&&getValidUser(_user)>=2&&getValidDirectUser(_user)>=1){
            return 1;
        }
        return 0;
    }

    function getUserInfo(address _user) public view returns(uint usdtAmount,uint failBackAmount,uint plateUAmount,
                uint sumBuy){
        uint _rAmount = 0;
        if(getUserIncome(_user)>userInfo[_user].takingAmount){
            _rAmount = getUserIncome(_user).sub(userInfo[_user].takingAmount);
        }
        usdtAmount = userInfo[_user].usdtAmount.add(_rAmount);
        (uint _failBefore,uint _failBeforePlate) = getUserFailBeforeIncome(_user);
        uint _failUp = getUserFailUpIncome(_user);
        uint _failAmount = 0;
        if(_failUp.add(_failBefore).add(getUserFailIncome(_user))>userInfo[_user].failBack){
            _failAmount = _failUp.add(_failBefore).add(getUserFailIncome(_user)).sub(userInfo[_user].failBack);
        }
        failBackAmount = userInfo[_user].failBackAmount.add(_failAmount);
        uint _failPlate = 0;
        if(_failBeforePlate>userInfo[_user].failBackPlate){
            _failPlate = _failBeforePlate.sub(userInfo[_user].failBackPlate);
        }
        plateUAmount =  userInfo[_user].plateAmount.add(_failPlate);
        sumBuy = userInfo[_user].payAmount;
    }

    function getUserInviteInfo(address _user) public view returns (uint directNum,uint inviteNum,
        uint directAmount){
            directNum = getValidDirectUser(_user);
            inviteNum = getValidUser(_user);
            directAmount = getDirectAmount(_user);
    }

    function getUserIncome(address _user) public view returns (uint){
        uint _userBuyIncome = getUserBuyIncome(_user);
        uint _userDirectInviteIncome = getDirectIncome(_user);
        uint _userInDirectInviteIncome = getInDirectIncome(_user);
        uint _userLevelIncome = getUserLevelIncome(_user);
        return _userBuyIncome.add(_userDirectInviteIncome).add(_userInDirectInviteIncome).add(_userLevelIncome);
    }

    function getHarvestPercent(uint _pLevel,uint _version) public view returns (uint){
        if(_pLevel==0){
            return 150;
        }
        uint _maxFailTimestamp = 0;
        for(uint i = 0;i<_pLevel;i++){
            (bool _isFail,uint _failVersion) = getFailVersion(i);
            if(!_isFail){ 
                return 130;
            }
            uint _cTimestamp = getVersionStartTimestamp(i,_failVersion);
            if(_cTimestamp>_maxFailTimestamp){
                _maxFailTimestamp = _cTimestamp;
            }
        }
        uint _timestamp = getVersionStartTimestamp(_pLevel,_version);
        if(_timestamp>_maxFailTimestamp){
            return 150;
        }
        return 130;
    }

    function getUserBuyIncome(address _user) public view returns (uint){
        uint _amount = 0;
        for(uint i = 0 ;i<userPayInfo[_user].length;i++){
            if(getVersionStatus(userPayInfo[_user][i].pLevel,userPayInfo[_user][i].version)==7){
                uint _adding = getAddingPercent(userPayInfo[_user][i].pLevel,
                                                userPayInfo[_user][i].version,
                                                userPayInfo[_user][i].payTimestamp);
                uint _harvestPercent = getHarvestPercent(userPayInfo[_user][i].pLevel,userPayInfo[_user][i].version);
                uint _buyAmount =  userPayInfo[_user][i].amount;                                                
                _amount = _amount.add(_harvestPercent.add(_adding).add(1000).mul(_buyAmount).div(1000));
            }
        }
        return _amount;
    }

    function getUserBuySuccess(address _user) public view returns (uint){
        uint _amount = 0;
        for(uint i = 0;i<userPayInfo[_user].length;i++){
            if(getVersionStatus(userPayInfo[_user][i].pLevel,userPayInfo[_user][i].version)==7){
                _amount = _amount.add(userPayInfo[_user][i].amount);
            }
        }
        return _amount;
    }

    function getLevelSumBeforeVersionFail(uint _pLevel,uint _version) public view returns (uint){
        if(_version<=3){
            return uint(0);
        }
        uint _rAmount = 0;
        for(uint i = 0;i<_version-3;i++){
            _rAmount = _rAmount.add(pInfoSellAmount[_pLevel][i]);
        }
        return _rAmount;
    }

    function getUserFailIncome(address _user) public view returns (uint){
        uint _amount = 0;
        for(uint i = 0 ;i<userPayInfo[_user].length;i++){
            if(getVersionStatus(userPayInfo[_user][i].pLevel,userPayInfo[_user][i].version)==4){
                uint _before = getLevelSumBeforeVersionFail(userPayInfo[_user][i].pLevel,userPayInfo[_user][i].version).mul(2).div(100);
                uint _buyAmount =  userPayInfo[_user][i].amount;
                _amount = _amount.add(_buyAmount)
                    .add(_before.mul(_buyAmount).div(pInfoSellAmount[userPayInfo[_user][i].pLevel][userPayInfo[_user][i].version]));
            }
        }
        return _amount;
    }

    function getUserFailUpIncome(address _user) public view returns (uint){
        uint _amount = 0;
        for(uint i = 0 ;i<userPayInfo[_user].length;i++){
            if(getVersionStatus(userPayInfo[_user][i].pLevel,userPayInfo[_user][i].version)==6){
                uint _buyAmount =  userPayInfo[_user][i].amount;
                _amount = _amount.add(_buyAmount);
            }
        }
        return _amount;
    }

    function getUserFailBeforeIncome(address _user) public view returns (uint,uint){
        uint _amount = 0;
        uint _plate = 0;
        for(uint i = 0 ;i<userPayInfo[_user].length;i++){
            if(getVersionStatus(userPayInfo[_user][i].pLevel,userPayInfo[_user][i].version)==5){
                uint _buyAmount =  userPayInfo[_user][i].amount;
                _amount = _amount.add(_buyAmount.mul(65).div(100));
                _plate = _plate.add(_buyAmount.mul(5).div(100));
            }
        }
        return (_amount,_plate);
    }

    function getUserLevelIncome(address _user) public view returns (uint){
        uint _userLevel = getUserLevel(_user);
        if(_userLevel==0){
            return 0;
        }else{
            uint _inviteAmount = getUserInviteAmount(_user,0,_userLevel);
            uint _inviteAmountSameLevel = getUserInviteAmountSameLevel(_user,0,_userLevel);
            uint _amount = _inviteAmount.mul(_userLevel).div(100).add(_inviteAmountSameLevel.mul(5).div(1000));
            return _amount; 
        }
    }

    function getUserInviteAmount(address _user,uint _amount,uint _level) public view returns (uint){
        uint _rAmount = _amount;
        for(uint i = 0;i<myInvites[_user].length;i++){
            address _cUser = myInvites[_user][i];
            uint _cLevel = getUserLevel(_cUser);
            if(_cLevel<_level){
                _rAmount = _rAmount.add(getUserBuySuccess(_cUser));
            }
            _rAmount = getUserInviteAmount(myInvites[_user][i],_rAmount, _level);
        }
        return _rAmount;
    }

    function getUserInviteAmountSameLevel(address _user,uint _amount,uint _level) public view returns(uint){
        uint _rAmount = _amount;
        for(uint i = 0;i<myInvites[_user].length;i++){
            address _cUser = myInvites[_user][i];
            uint _cLevel = getUserLevel(_cUser);
            if(_cLevel==_level){
                _rAmount = _rAmount.add(getUserBuySuccess(_cUser));
            }
            _rAmount = getUserInviteAmountSameLevel(myInvites[_user][i],_rAmount,_level);
        }
        return _rAmount;
    }

    function getMyInvites(address _owner) public view returns(address[] memory _invites){
        return myInvites[_owner];
    }

    function getMyInvitesNum(address _owner) public view returns(uint _num){
        return myInvites[_owner].length;
    }

    function getMyInvitesLv2Num(address _owner) public view returns(uint _num){
        address[] memory direct = getMyInvites(_owner);
        if(direct.length>0){
            for(uint i = 0;i<direct.length;i++){
                _num = _num + getMyInvitesNum(direct[i]);
            }
        }
    }

    function getMyInvitesLv2(address _owner) public view returns(address[] memory ){
        address[] memory _invites = new address[](getMyInvitesLv2Num(_owner));
        address[] memory _direct = getMyInvites(_owner);
        uint _index = 0;
        for(uint i = 0;i<_direct.length;i++){
            address[] memory _indirect = getMyInvites(_direct[i]);
            for(uint j = 0;j<_indirect.length;j++){
                _invites[_index] = _indirect[j];
                _index = _index + 1;
            }
        }
        return _invites;
    }

    function getDirectIncome(address _user) public view returns (uint){
        return getDirectAmount(_user).mul(2).div(100);
    }

    function getInDirectIncome(address _user) public view returns (uint){
        return getIndirectAmount(_user).div(100);
    }

    function getDirectAmount(address _user) public view returns (uint){
        uint _amount = 0;
        for(uint i = 0;i<myInvites[_user].length;i++){
            _amount = _amount.add(getUserBuySuccess(myInvites[_user][i]));
        }
        return _amount;
    }

    function getIndirectAmount(address _user) public view returns(uint){
        uint _amount = 0;
        for(uint i =0;i<getMyInvitesLv2(_user).length;i++){
            _amount = _amount.add(getUserBuySuccess(getMyInvitesLv2(_user)[i]));
        }
        return _amount;
    }

    function getAddingPercent(uint _pLevel,uint _version,uint _payTimestamp)public view returns (uint){
        uint _createTimestamp = getVersionStartTimestamp(_pLevel,_version);
        if(_payTimestamp>=_createTimestamp){
            return 0;
        }
        uint _p = _createTimestamp.sub(_payTimestamp).div(splitTime).add(1);
        if(_p>9)_p = 9;
        return _p;
    }

    function checkAmount(address _user,uint _amount,uint _pLevel,uint _version) public view returns(bool){
        uint _dayMin = dayMin[_version];
        uint _dayMax = dayMax[_version];
        if(_dayMin==uint(0)){
            _dayMin = baseMin;
        }
        if(getVersionSumAmount(_pLevel,_version).sub(pInfoSellAmount[_pLevel][_version])<=_dayMin){
            _dayMin = 0;
        }

        if(_dayMax==uint(0)){
            _dayMax = baseMax;
        }
        uint _cSellSum = getVersionSumAmount(_pLevel,_version);
        if(getVersionStatus(_pLevel,_version)==1){
            _cSellSum = _cSellSum.mul(80).div(100);
        }
        uint _leftAmount = _cSellSum.sub(pInfoSellAmount[_pLevel][_version]);
        if(_dayMin>_amount||_dayMax<_amount||_leftAmount<_amount) {
            return false;
        }
        PayInfo[] memory _uPayInfo = userPayInfo[_user];
        uint _payed = uint(0);
        for(uint i = 0;i<_uPayInfo.length;i++){
            if(_uPayInfo[i].pLevel ==_pLevel&& _uPayInfo[i].version==_version){
                _payed = _uPayInfo[i].amount.add(_payed);
            }
        }
        if(_dayMax<_amount.add(_payed)) {
            return false;
        }
        return true;
    }

    function addPInfo(uint _timestamp,uint _sumAmount) public onlyOwner{
        pInfo[pLevel].startTimestamp = _timestamp;
        pInfo[pLevel].sumAmount = _sumAmount;
        pLevel = pLevel + 1;
    }

    function addDayMin(uint _day,uint _amount) public onlyOwner{
        dayMin[_day] = _amount;
    }

    function addDayMax(uint _day,uint _amount) public onlyOwner{
        dayMax[_day] = _amount;
    }

    function addPayers(address[] memory _payers) public onlyOwner{
        for(uint i =0;i<_payers.length;i++){
            payerFactorys.push(_payers[i]);
        }
    }

    function setBaseMin(uint _min) public onlyOwner{
        baseMin = _min;
    }

    function setBaseMax(uint _max) public onlyOwner{
        baseMax = _max;
    }

    function setUsdtAddr(address _usdtAddr) public onlyOwner{
        usdtAddr = _usdtAddr;
    }

    function setPlatformAddr(address _platformAddr) public onlyOwner{
        plateformAddr = _platformAddr;
    }

    function setSwapPair(address _swapPair) public onlyOwner{
        swapPair = _swapPair;
    }

    function setSwapAdapter(address _swapAdapter) public onlyOwner{
        swapAdapter = _swapAdapter;
    }

    function pay(address _user,uint _amount,uint _pLevel,uint _version,address _inviter) public onlyPayer{
        _invite(_user,_inviter);
        _pay( _user, _amount, _pLevel,_version);
        userInfo[_user].payAmount = userInfo[_user].payAmount.add(_amount);
    }

    function rePay(uint _amount,uint _pLevel,uint _version) public {
        address _user = msg.sender;
        takingAmount(_user);
        require(userInfo[_user].usdtAmount>=_amount,"balance not enough");
        userInfo[_user].usdtAmount = userInfo[_user].usdtAmount.sub(_amount);
        _pay(_user,_amount,_pLevel,_version);
    }

    function _pay(address _user,uint _amount,uint _pLevel,uint _version) private {
        require (_version>=0,"this issue not exist");
        require(getVersionStatus(_pLevel,_version)==1||getVersionStatus(_pLevel,_version)==2,"current version can not sell.");
        require(checkAmount( _user, _amount,_pLevel, _version),"amount wrong");
        userPayInfo[_user].push(
            PayInfo({
                pLevel:_pLevel,
                version:_version,
                amount:_amount,
                payTimestamp: block.timestamp
            })
        );
        pInfoSellAmount[_pLevel][_version] = pInfoSellAmount[_pLevel][_version].add(_amount);
        emit Pay(_user,_amount, _pLevel, _version);
    }

    function withdraw(uint _amount) public {
        address _user = msg.sender;
        (uint _uAmount,,,) = getUserInfo(_user);
        require(_uAmount>=_amount,"balance not enough");
        takingAmount(_user);
        userInfo[_user].usdtAmount = userInfo[_user].usdtAmount.sub(_amount);
        uint _withdrawAmount = _amount.mul(95).div(100);
        _safeTransfer(usdtAddr,msg.sender,_withdrawAmount);
        // change amount and drop
        uint _rAmount = _swapPlateformCoin(_amount.mul(5).div(100));
        // _safeTransfer( plateformAddr,address(0),_rAmount.div(5));
        emit Withdraw(_user,_amount);
    }

    function withdrawFail() public{
         address _user = msg.sender;
        takingAmount(_user);
        uint _amount = userInfo[_user].failBackAmount;
        userInfo[_user].failBackAmount = 0;
        _safeTransfer(usdtAddr,_user,_amount);
        emit WithdrawFail(_user,_amount);
    }


    function withdrawPlateform() public{
        address _user = msg.sender;
        takingAmount(_user);
        uint _amount = userInfo[_user].plateAmount;
        userInfo[_user].plateAmount = userInfo[_user].plateAmount.sub(_amount);
        uint _plateAmount = _swapPlateformCoin(_amount);
        _safeTransfer(plateformAddr,msg.sender,_plateAmount);
        emit WithdrawPlateform(_user,_amount);
    }

    function _swapPlateformCoin(uint _amount)private returns (uint){
        if(_amount==0){
            return 0;
        }
        address _sellBase = IAdapter(swapAdapter).baseToken(swapPair);
        uint _balanceBefore = IERC20(usdtAddr).balanceOf(swapPair);
        _safeTransfer(usdtAddr,swapPair,_amount);
        uint _rAmount = 0;
        if(_sellBase==usdtAddr){
           _rAmount = IAdapter(swapAdapter).sellBase(address(this),swapPair,_balanceBefore);
        }else{
           _rAmount = IAdapter(swapAdapter).sellQuote(address(this),swapPair,_balanceBefore);
        }
        uint _swapAmount = IERC20(plateformAddr).balanceOf(address(this)).sub(_rAmount);
        return _swapAmount;
    }

    function transferAmount(uint _amount , address _to) public {
        address _user = msg.sender;
        (uint _uAmount,,,) = getUserInfo(_user);
        require(_uAmount>=_amount,"balance not enough");
        takingAmount(_user);
        userInfo[_user].usdtAmount = userInfo[_user].usdtAmount.sub(_amount);
        uint _tranAmount = _amount.mul(975).div(1000);
        userInfo[_to].usdtAmount = _tranAmount;
        emit Transfer(_user,_to,_amount);
    }

    function takingAmount(address _user) public {
        uint _amount = getUserIncome(_user);
        uint _tAmount = userInfo[_user].takingAmount;
        uint _rAmount = 0;
        if(_amount>_tAmount){
            _rAmount = _amount.sub(_tAmount);
            userInfo[_user].takingAmount = _amount;
            userInfo[_user].usdtAmount = userInfo[_user].usdtAmount.add(_rAmount);
        }
        uint _fail = getUserFailIncome(_user);
        (uint _failBefore,uint _failBeforePlate) = getUserFailBeforeIncome(_user);
        uint _failUp = getUserFailUpIncome(_user);
        uint _failSum = _failUp.add(_failBefore).add(_fail);
        uint _failAmount = 0;
        if(_failSum>userInfo[_user].failBack){
            _failAmount = _failSum.sub(userInfo[_user].failBack);
            userInfo[_user].failBack = _failSum;
            userInfo[_user].failBackAmount = userInfo[_user].failBackAmount.add(_failAmount);
        }
        uint _failPlate = 0;
        if(_failBeforePlate>userInfo[_user].failBackPlate){
            _failPlate = _failBeforePlate.sub(userInfo[_user].failBackPlate);
            userInfo[_user].failBackPlate = _failBeforePlate;
            userInfo[_user].plateAmount = userInfo[_user].plateAmount.add(_failPlate);
        }
        emit TakingAmount(_user,_rAmount,_failAmount,_failPlate);
    }
    
    function _invite(address _sender,address _inviter) private {
        if(_inviter!= address(0) && _sender!=_inviter){
            if(inviters[_sender] == address(0)){
                myInvites[_inviter].push(_sender);
                inviters[_sender] = _inviter;
            }
        }
    }
    
    
    function takeAmount(address token,address to,uint256 amount) public onlyOwner returns (bool) {
        _safeTransfer(token,to,amount);
        return true;
    }
    
    function _safeTransfer(address token, address to, uint value) private {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(SELECTOR, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'Swap: TRANSFER_FAILED');
    }
}