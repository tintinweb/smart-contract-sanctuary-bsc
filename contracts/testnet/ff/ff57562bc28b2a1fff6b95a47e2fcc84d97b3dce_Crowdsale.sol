/**
 *Submitted for verification at BscScan.com on 2022-07-29
*/

// File: Address.sol


// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
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

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
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
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
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
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
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
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
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
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

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
// File: IERC20.sol



pragma solidity 0.8.4;

interface IERC20 {
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
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);
}
// File: SafeERC20.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;



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
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
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
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}
// File: ReentrancyGuard.sol



pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
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

    constructor() {
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
// File: Context.sol



pragma solidity ^0.8.0;

/*
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
// File: Ownable.sol



pragma solidity ^0.8.0;


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
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
// File: Crowdsale.sol



pragma solidity 0.8.4;





contract Crowdsale is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    enum CrowdsaleStatus { NoStart, Crowdsaling, DistInterest, CrowdsaleEnd }
    enum FundType { NoneFund, InterestFund, RefundFund, ProjectBailFund }
    enum PoolType {ProjectBailPool, InterestPool, CrowdsalePool, RefundPool, FeePool }
    
    struct InvestInfo {
        uint256 amount;   //投资数量
        uint256 investTime;  //投资时间
        uint256 interestDistAmt;  //已派发利息数量
        uint256 interestDistCnt;  //已派发利息次数
        uint8 interestType; //派息方式
        uint256 interestIndex;
        address userAddr;  //用户地址
        bool bRefund;  //是否已退款
        uint256 frpInterestWithdrawAmt;  //已领取募资期利息数量
        uint256 refundTime; //退款时间
    }
    
    struct CrowdsaleInfo_i {
        uint256[9] amountsInfo; //0 : 目标总量; 1 : 投资总量; 2 : 已派发利息数量; 3 : NoUsed; 4 : 参与用户数量
                                //5 : 初始派息资金池数量; 6 : 募资期延迟计息天数; 7 : 募资期退款天数限制; 8 : 募资期退款年化利率
        uint256[5] poolAmount; //0 : 项目保证金余额; 1 : 派息资金池余额; 2 : 筹款资金池余额; 3 : 退款资金池余额; 4 : 项目手续费资金池
        CrowdsaleStatus status;  //项目状态：0 - 未开始；1 - 众筹中; 2 - 派息中；3 - 项目结束
        uint256[5] timeInfo;  // 0 - 项目开始时间； 1 - 项目结束时间； 2 - 项目派息时间；3 - 项目最小周期；4 - 项目最大周期
        uint256[2] investLimit;
        address[3] addrInfo; //0 : 代币地址; 1 : 项目方地址; 2 : 担保方地址
        InterestInfo[] interestInfos;
        bool[2] bFlags; //0 : bValid; 1 : bVouch
        InvestInfo[] invests;
        uint256 interestDelayDays;
        uint256 refundAmount;
        uint256 refundUserCnt;
    }
    
    struct CrowdsaleInfo {
        uint256 interestDistributed;
        uint256 investAmount;
        uint256 projectBailPool;
        uint256 interestPool;
        uint256 crowdsalePool;
        uint256 refundPool;
        uint256 feePool;
        uint8 status;
        uint256 investorNumber;
        uint256 refundAmount;
        uint256 refundUserCnt;
    }
	
    struct InterestInfo{
        uint8 interestType;  //派息方式
        uint256 interestValue; //派息对应的利率
        uint256 feeType;  //手续费类型
        uint256 feeValue;  //手续费数量
        uint256 minFeeValue; //最小手续费数量
        uint256 investLValue;  //投资额度下限
        uint256 investHValue;  //投资额度上限
    }
    
    struct TempInfo {
        uint256 interest;
        uint256 fee;
        uint256 itAmount;
        uint256 interestPaid;
        uint256 periods;
        uint256 leftSecs;
        uint256[8] itAmounts;
        uint256[8] amounts;
        uint256[8] timestamps;
        uint256[8] fees;
    }
    
    struct RefundLimitInfo {
        address token;
        uint256 limit;
    }
    
    struct TokenInfo{
        address tokenAddr;
        uint256 amount;
    }
    
    struct LimitInfo {
        uint256 amount;
        bool valid;
    }
    
    struct UsrInterestInfo{
        uint256 investIdx;
        uint256 takenAmount;
        uint256 leftAmount;
    } 
    
    address[] public crowdsaleTokenAddrs;
    address[] private refundLimitTokenAddrs;
    uint256 private dailyRefundUserCnt;
    uint256[8] private interestPeriods = [0, 1 days, 7 days, 30 days, 90 days, 182 days, 365 days, 730 days];
    address constant ZERO_ADDRESS = 0x0000000000000000000000000000000000000000;
    mapping(address => uint256[]) private totalPoolAmountMap;
    mapping(string => CrowdsaleInfo_i) public crowdsaleInfoMap;
    mapping(address => bool) private executorList;
    mapping(string => mapping(address => uint256[])) public userInvestIdxMap;
    mapping(string => mapping(address => bool)) private projectRefundMap;
    mapping(uint256 => uint256) private dailyRefundCntMap;
    mapping(address => LimitInfo) private dailyRefundFundLimitMap;
    mapping(address => mapping(address => mapping(uint256 => uint256))) private dailyRefundAmountMap;

    event Invest(address user, string projectId, uint256 amount, uint8 interestType,uint256 crowdsalePool, uint256 investorNumber, uint256 investIdx);
    event InjectFunds(address user, string projectId, FundType ftype, uint256 amount, uint256 pool);
    event NewCrowdsale(string projectId, uint256 beginTime, uint256 endTime,  uint256 crowdsaleAmount, 
        uint256 prjBailAmount, uint256 minInvest, uint256 maxInvest, address tokenAddr, address prjAddr);
    event EndCrowdsale(string projectId, uint8 status,uint256 feePool, uint256 interestPool, uint256 crowdsalePool, uint256 toFeePool, uint256 toInterestPool, uint256 toBailPool, uint256 toProjectAddr);
    event DistributeInterest(string projectId, address user, uint256 amount, uint256 fee, uint256 interestPool, uint256 feePool, uint256 timestamp,uint8 interestType,uint256 investAmount);
    event Refund(string projectId, address user, uint256 amount, uint256 refundPool, uint256 timestamp);
    event WithdrawFee(address tokenAddr, address toAddr,uint256 feeAmount);
    event TransferProjectBail(string projectId, address tokenAddr, uint256 refundFee, uint256 feePool, uint256 returnAmount, address toAddr);
    event RefundInterestPool(string projectId, address tokenAddr, address toAddr, uint256 amount);
    event AddExecutor(address _newExecutor);
    event DelExecutor(address _oldExecutor);
    //event SetDailyRefundLimit(uint256 limit);
    //event SetDailyRefundFundLimit(address token, uint256 limit);
    event WithdrawInterest(string projectId, address user, uint256 investIdx, uint256 amount);

    constructor(){
    }
    
    modifier onlyExecutor {
        require(executorList[msg.sender],"O");
        _;
    }
    
    function receiveToken_i(CrowdsaleInfo_i storage csInfo, uint256 amount) private {
        if(csInfo.addrInfo[0] == ZERO_ADDRESS){
            require(msg.value >= amount, "V");
        }else{
            IERC20 token = IERC20(csInfo.addrInfo[0]);
            uint256 amountBefore = token.balanceOf(address(this));
            token.safeTransferFrom(
                msg.sender,
                address(this),
                amount
            );
            uint256 amountAfter = token.balanceOf(address(this));
            require(amountAfter >= (amountBefore+amount), "F");
        }
    }
    
    function invest(string memory projectId, uint256 amount, uint8 interestType) public payable nonReentrant {
        CrowdsaleInfo_i storage csInfo = crowdsaleInfoMap[projectId];
        InvestInfo memory investInfo;
        require(csInfo.amountsInfo[0] > 0 && csInfo.poolAmount[uint8(PoolType.CrowdsalePool)] < csInfo.amountsInfo[0], "A");
        //require(csInfo.amountsInfo[0] > 0 && (amount + csInfo.amountsInfo[1]) <= csInfo.amountsInfo[0], "TA");
        require(uint8(csInfo.status) <= 1, "S");
        require(block.timestamp >= csInfo.timeInfo[0] && block.timestamp <= csInfo.timeInfo[1], "T");
        require(amount >= csInfo.investLimit[0] && amount <= csInfo.investLimit[1], "I");
        uint256 i;
        uint256 totalAmount = amount;
        uint256[] storage investList = userInvestIdxMap[projectId][msg.sender];
        for(i = 0; i < investList.length;i++){
            uint256 idx = investList[i];
            InvestInfo storage ivInfo = csInfo.invests[idx];
            if(ivInfo.interestType == interestType && !ivInfo.bRefund){
                totalAmount += ivInfo.amount;
            }
        }
        for(i = 0;i < csInfo.interestInfos.length; i++){
            if(interestType == csInfo.interestInfos[i].interestType && 
                totalAmount >= csInfo.interestInfos[i].investLValue &&
                totalAmount < csInfo.interestInfos[i].investHValue){
                break;
            }
        }
        require(i < csInfo.interestInfos.length, "N");
        investInfo.interestIndex = i;
        for(i = 0; i < investList.length;i++){
            uint256 idx = investList[i];
            InvestInfo storage ivInfo = csInfo.invests[idx];
            if(ivInfo.interestType == interestType && !ivInfo.bRefund){
                ivInfo.interestIndex = investInfo.interestIndex;
            }
        }
        receiveToken_i(csInfo,amount);
        if(csInfo.status == CrowdsaleStatus.NoStart){
            csInfo.status  = CrowdsaleStatus.Crowdsaling;
        }
        investInfo.amount = amount;
        investInfo.investTime = block.timestamp;
        investInfo.interestType = interestType;
        investInfo.userAddr = msg.sender;
        investInfo.interestDistAmt = 0;
        investInfo.interestDistCnt = 0;
        investInfo.bRefund = false;
        if(investList.length == 0){
            csInfo.amountsInfo[4] += 1;
        }
        csInfo.amountsInfo[1] += amount;
        modifyPoolAmount_i(csInfo,PoolType.CrowdsalePool,amount,true);
        csInfo.invests.push(investInfo);
        investList.push(csInfo.invests.length-1);
        emit Invest(msg.sender, projectId, amount, interestType, csInfo.poolAmount[uint8(PoolType.CrowdsalePool)], csInfo.amountsInfo[4], csInfo.invests.length-1);
    }
    
    function injectFunds(string memory projectId, IERC20 tokenAddr, FundType[] memory ftype, uint256[] memory amount) public payable nonReentrant {
        uint256 poolValue = 0;
        uint256 totalAmount = 0;
        CrowdsaleInfo_i storage csInfo = crowdsaleInfoMap[projectId];
        if(!csInfo.bFlags[0]){
            csInfo.bFlags[0] = true;
            csInfo.addrInfo[0] = address(tokenAddr);
        }
        for(uint256 i = 0; i < ftype.length; i++){
            totalAmount += amount[i];
            if(csInfo.addrInfo[1] == ZERO_ADDRESS){
                csInfo.addrInfo[1] = msg.sender;
            }
            if(totalPoolAmountMap[csInfo.addrInfo[0]].length == 0){
                for(uint256 j = 0;j < 6; j++){
                    totalPoolAmountMap[csInfo.addrInfo[0]].push(0);
                }
                crowdsaleTokenAddrs.push(csInfo.addrInfo[0]);
            }
            if(ftype[i] == FundType.InterestFund){
                modifyPoolAmount_i(csInfo,PoolType.InterestPool,amount[i],true);
                poolValue = csInfo.poolAmount[uint8(PoolType.InterestPool)];
            }else if(ftype[i] == FundType.RefundFund){
                modifyPoolAmount_i(csInfo,PoolType.RefundPool,amount[i],true);
                poolValue = csInfo.poolAmount[uint8(PoolType.RefundPool)];
            }else if(ftype[i] == FundType.ProjectBailFund){
                modifyPoolAmount_i(csInfo,PoolType.ProjectBailPool,amount[i],true);
                poolValue = csInfo.poolAmount[uint8(PoolType.ProjectBailPool)];
            }else{
                require(false,"I");
            }
            emit InjectFunds(msg.sender, projectId, ftype[i], amount[i], poolValue);
        }
        receiveToken_i(csInfo, totalAmount);
    }
    
    function newCrowdsale(string memory projectId, uint256[] memory timeInfo, uint256[] memory amounts, uint256[] memory investLimit, 
        InterestInfo[] memory interestInfos, address[] memory addrInfo) public onlyExecutor nonReentrant{
        CrowdsaleInfo_i storage csInfo = crowdsaleInfoMap[projectId];
        //require(interestInfos.length > 0 && csInfo.interestInfos.length == 0, "C");
        if(!csInfo.bFlags[0]){
            csInfo.bFlags[0] = true;
            csInfo.addrInfo[0] = addrInfo[0];
        }else{
            require(csInfo.addrInfo[0] == addrInfo[0], "A");
        }
        require(csInfo.poolAmount[uint8(PoolType.ProjectBailPool)] >= amounts[1], "N");
        require(csInfo.poolAmount[uint8(PoolType.InterestPool)] >= amounts[2], "I");
        csInfo.bFlags[1] = true;
        csInfo.addrInfo[1] = addrInfo[1];
        csInfo.addrInfo[2] = addrInfo[2];
        csInfo.timeInfo[0] = timeInfo[0];
        csInfo.timeInfo[1] = timeInfo[1];
        csInfo.timeInfo[3] = timeInfo[2];
        csInfo.timeInfo[4] = timeInfo[3];
        csInfo.amountsInfo[0] = amounts[0];
        csInfo.amountsInfo[5] = amounts[2];
        csInfo.amountsInfo[6] = amounts[3];
        csInfo.amountsInfo[7] = amounts[4];
        csInfo.amountsInfo[8] = amounts[5];
        csInfo.investLimit[0] = investLimit[0];
        csInfo.investLimit[1] = investLimit[1];
        for(uint256 i = 0;i < interestInfos.length; i++){
            /*
            require(interestInfos[i].interestType >= 1 && interestInfos[i].interestType <= 7, "T");
            require(interestInfos[i].feeType >= 1 && interestInfos[i].feeType <= 2, "F");
            require(interestInfos[i].investLValue < interestInfos[i].investHValue, "V");
            */
            //require(interestInfos[i].interestValue < 10000, "IIV");
            csInfo.interestInfos.push(interestInfos[i]);
        }
        if(totalPoolAmountMap[csInfo.addrInfo[0]].length == 0){
            for(uint256 i = 0;i < 6; i++){
                totalPoolAmountMap[csInfo.addrInfo[0]].push(0);
            }
            crowdsaleTokenAddrs.push(csInfo.addrInfo[0]);
        }
        emit NewCrowdsale(projectId, timeInfo[0], timeInfo[1], amounts[0],amounts[1], investLimit[0], investLimit[1], addrInfo[0], addrInfo[1]);
    }
    
    function transferToken(address tokenAddr, address toAddr, uint256 amount) private {
        require(toAddr.code.length == 0, "E");
        if(tokenAddr == ZERO_ADDRESS){
            payable(toAddr).transfer(amount);
        }else{
            IERC20 token = IERC20(tokenAddr);
            token.safeTransfer(toAddr, amount);
        }
    }
    
    function endCrowdsale(string memory projectId, uint256[] memory ratios, uint8 status, uint256 interestDelayDays) public onlyExecutor nonReentrant{
        CrowdsaleInfo_i storage csInfo = crowdsaleInfoMap[projectId];
        uint256 value1 = 0;
        uint256 value2 = 0;
        uint256 value3 = 0;
        uint256 left = 0;
		uint256 crowdsaleAmount = csInfo.poolAmount[uint8(PoolType.CrowdsalePool)];
        if(status == 1) { //Crowdsale succ
            require(uint8(csInfo.status) <= 1, "I");
            //require((ratios[0] + ratios[1]) < 10000, "R");
            csInfo.status = CrowdsaleStatus.DistInterest;
            csInfo.interestDelayDays = interestDelayDays;
            value1 = csInfo.amountsInfo[0] * ratios[0] / 10000;
            modifyPoolAmount_i(csInfo,PoolType.FeePool,value1,true);
            value2 = csInfo.amountsInfo[0] * ratios[1] / 10000;
            modifyPoolAmount_i(csInfo,PoolType.InterestPool,value2,true);
            if(csInfo.addrInfo[2] != ZERO_ADDRESS){
                value3 = csInfo.amountsInfo[0] * ratios[2] / 10000;
                transferToken(csInfo.addrInfo[0],csInfo.addrInfo[2],value3);
                totalPoolAmountMap[csInfo.addrInfo[0]][5] += value3;
            }
            //require(csInfo.amountsInfo[1] >= (value1 + value2 + value3), "O");
            left = crowdsaleAmount - (value1 + value2 + value3);
            transferToken(csInfo.addrInfo[0],csInfo.addrInfo[1],left);
            
        }else if(status == 2){ //Crowdsale fail
            require(uint8(csInfo.status) <= 2, "I");
            modifyPoolAmount_i(csInfo,PoolType.RefundPool,crowdsaleAmount,true);
            csInfo.status = CrowdsaleStatus.CrowdsaleEnd;
        }
        csInfo.timeInfo[2] = block.timestamp - block.timestamp % 86400;
        modifyPoolAmount_i(csInfo,PoolType.CrowdsalePool,crowdsaleAmount,false);
        emit EndCrowdsale(projectId, status,csInfo.poolAmount[uint8(PoolType.FeePool)], csInfo.poolAmount[uint8(PoolType.InterestPool)], csInfo.poolAmount[uint8(PoolType.CrowdsalePool)], value1, value2, value3, left);
    }
    
    function calcInterestPeriods(uint256 startTime, uint256 maxPeriod, uint8 interestType) private view returns (uint256,uint256){
        uint256 ts = startTime + maxPeriod * 86400;
        ts = (block.timestamp > ts) ? ts : block.timestamp;
        uint256 diffTime = (ts - startTime);
        return (diffTime / interestPeriods[interestType], diffTime % interestPeriods[interestType]);
    }
    
    function distributeInterest(string memory projectId, address[] memory users) public onlyExecutor nonReentrant {
        distributeInterest_i(projectId,users,true);
    }
    
    function modifyPoolAmount_i(CrowdsaleInfo_i storage csInfo, PoolType pt, uint256 amount, bool bAdd) private {
        if(bAdd){
            csInfo.poolAmount[uint8(pt)] += amount;
            totalPoolAmountMap[csInfo.addrInfo[0]][uint8(pt)] += amount;
        }else{
            csInfo.poolAmount[uint8(pt)] -= amount;
            totalPoolAmountMap[csInfo.addrInfo[0]][uint8(pt)] -= amount;
        }
    }
    
    function distributeInterest_i(string memory projectId, address[] memory users, bool bDelay) private {
        CrowdsaleInfo_i storage csInfo = crowdsaleInfoMap[projectId];
        //require(csInfo.timeInfo[2] > 0, "C");
        if(csInfo.timeInfo[2] == 0) return;
        if(bDelay){
            require(block.timestamp >= (csInfo.timeInfo[2] + csInfo.interestDelayDays * 86400), "I");
            //require(block.timestamp <= (csInfo.timeInfo[2] + csInfo.timeInfo[4] * 86400), "MP");
        }
        TempInfo memory tmpInfo;
        for(uint256 i = 0;i < users.length; i++){
            for(uint256 k = 1; k < 8; k++){
                tmpInfo.amounts[k] = 0;
                tmpInfo.itAmounts[k] = 0;
                tmpInfo.fees[k] = 0;
                //tmpInfo.timestamps[k] = 0;
            }
            uint256[] storage investIdxs = userInvestIdxMap[projectId][users[i]];
            for(uint256 j = 0; j < investIdxs.length; j++){
                InvestInfo storage ivInfo = csInfo.invests[investIdxs[j]];
                if(ivInfo.bRefund) continue;
                (tmpInfo.periods, tmpInfo.leftSecs) = calcInterestPeriods(csInfo.timeInfo[2],csInfo.timeInfo[4],ivInfo.interestType);
                if(!bDelay && (tmpInfo.leftSecs / 86400) > 0){
                    tmpInfo.periods += 1;
                }
                if(tmpInfo.periods <= ivInfo.interestDistCnt){
                    continue;
                }
                InterestInfo storage itInfo = csInfo.interestInfos[ivInfo.interestIndex];
                uint256 distCnt = tmpInfo.periods - ivInfo.interestDistCnt;
                tmpInfo.amounts[ivInfo.interestType] += ivInfo.amount;
                for(uint256 k = 0; k < distCnt; k++){
                    tmpInfo.fee = 0;
                    tmpInfo.interest = ivInfo.amount * itInfo.interestValue / 10000;
                    tmpInfo.interest = tmpInfo.interest * interestPeriods[ivInfo.interestType] / (365 days);
                    if(!bDelay && (tmpInfo.leftSecs / 86400) > 0 && k == (distCnt-1)){
                        tmpInfo.interest = tmpInfo.interest * (tmpInfo.leftSecs / 86400) * 86400 / interestPeriods[ivInfo.interestType];
                    }
                    if(itInfo.feeType == 1){
                        tmpInfo.fee = itInfo.feeValue;
                    }else{
                        tmpInfo.fee = tmpInfo.interest * itInfo.feeValue / 10000;
                        if(tmpInfo.fee < itInfo.minFeeValue){
                            tmpInfo.fee = itInfo.minFeeValue;
                        }
                    }
                    if(tmpInfo.fee > tmpInfo.interest){
                        tmpInfo.fee = tmpInfo.interest;
                    }
                    tmpInfo.itAmount = tmpInfo.interest - tmpInfo.fee;
                    tmpInfo.interestPaid = 0;
                    require(csInfo.poolAmount[uint8(PoolType.InterestPool)] >= tmpInfo.interest,"J");
                    tmpInfo.interestPaid = tmpInfo.interest;
                    if(tmpInfo.interestPaid > 0){
                        modifyPoolAmount_i(csInfo,PoolType.InterestPool,tmpInfo.interestPaid,false);
                    }
                    ivInfo.interestDistCnt += 1;
                    tmpInfo.timestamps[ivInfo.interestType] = csInfo.timeInfo[2] + ivInfo.interestDistCnt * interestPeriods[ivInfo.interestType];
                    ivInfo.interestDistAmt += tmpInfo.itAmount;
                    modifyPoolAmount_i(csInfo,PoolType.FeePool,tmpInfo.fee,true);
                    csInfo.amountsInfo[2] += tmpInfo.interest;
                    
                    tmpInfo.fees[ivInfo.interestType] += tmpInfo.fee;
                    tmpInfo.itAmounts[ivInfo.interestType] += tmpInfo.itAmount;
                }
            }
            for(uint8 k = 1;k < 8; k++){
                if(tmpInfo.itAmounts[k] == 0) continue;
                transferToken(csInfo.addrInfo[0],users[i],tmpInfo.itAmounts[k]);
                emit DistributeInterest(projectId, users[i], tmpInfo.itAmounts[k], tmpInfo.fees[k], csInfo.poolAmount[uint8(PoolType.InterestPool)], 
                    csInfo.poolAmount[uint8(PoolType.FeePool)], tmpInfo.timestamps[k],k,tmpInfo.amounts[k]);
            }
        }
    }
    
    function checkDailyRefundUserCnt(uint256 cnt) private view {
        if(dailyRefundUserCnt > 0){
            uint256 day = block.timestamp / 86400;
            require((dailyRefundCntMap[day]+cnt) <= dailyRefundUserCnt, "U");
        }
    }
    
    function addDailyRefundUserCnt(uint256 cnt) private{
        uint256 day = block.timestamp / 86400;
        dailyRefundCntMap[day] += cnt;
    }
    
    function checkDailyRefundAmount(address token, address user, uint256 amount) private view {
        if(dailyRefundFundLimitMap[token].amount > 0){
            uint256 day = block.timestamp / 86400;
            require((dailyRefundAmountMap[token][user][day]+amount) <= dailyRefundFundLimitMap[token].amount, "EAL");
        }
    }
    
    function addDailyRefundAmount(address token, address user, uint256 amount) private {
        uint256 day = block.timestamp / 86400;
        dailyRefundAmountMap[token][user][day] += amount;
    }
    
    function refundFromUser(string memory projectId) public nonReentrant {
        address[] memory users = new address[](1);
        users[0] = msg.sender;
        refund_i(projectId,users,false);
    }
    
    /*
    function refund(string memory projectId, address[] memory users) onlyExecutor public nonReentrant {
        refund_i(projectId, users, true);
    }
    */
    
    function refund_i(string memory projectId, address[] memory users, bool bOperator) private {
        CrowdsaleInfo_i storage csInfo = crowdsaleInfoMap[projectId];
		bool limit = true;
		if(csInfo.status == CrowdsaleStatus.CrowdsaleEnd || block.timestamp >= (csInfo.timeInfo[2] + csInfo.timeInfo[4] * 86400)){
			limit = false;
		}
        if(!bOperator){
            checkDailyRefundUserCnt(users.length);
			if(csInfo.amountsInfo[5] == 0){
				require(csInfo.timeInfo[2] != 0, "R");
			}
			if(limit){
				require(csInfo.status != CrowdsaleStatus.DistInterest, "U");
			}
        }
        //csInfo.status  = CrowdsaleStatus.CrowdsaleEnd;
        distributeInterest_i(projectId,users,false);
        for(uint256 i = 0;i < users.length; i++){
            uint256[] storage investIdxs = userInvestIdxMap[projectId][users[i]];
            uint256 refundAmt = 0;
            for(uint256 j = 0; j < investIdxs.length; j++){
                InvestInfo storage ivInfo = csInfo.invests[investIdxs[j]];
                if(ivInfo.bRefund){
                    continue;
                }
                if(!bOperator && limit){
                    require((block.timestamp - ivInfo.investTime) / 86400 >= csInfo.amountsInfo[7], "L");
                }
                if(csInfo.timeInfo[2] == 0){
                    require(csInfo.poolAmount[uint8(PoolType.CrowdsalePool)] >= ivInfo.amount, "Y");
                    modifyPoolAmount_i(csInfo,PoolType.CrowdsalePool,ivInfo.amount,false);
                }else{
                    require(csInfo.poolAmount[uint8(PoolType.RefundPool)] >= ivInfo.amount, "R");
                    modifyPoolAmount_i(csInfo,PoolType.RefundPool,ivInfo.amount,false);
                }
                ivInfo.bRefund = true;
                ivInfo.refundTime = block.timestamp;
                //transferToken(csInfo.addrInfo[0],users[i],ivInfo.amount);
                refundAmt += ivInfo.amount;
                csInfo.refundAmount += ivInfo.amount;
                if(!projectRefundMap[projectId][users[i]]){
                    csInfo.refundUserCnt += 1;
                    projectRefundMap[projectId][users[i]] = true;
                }
            }
            if(refundAmt > 0){
                if(!bOperator){
                    checkDailyRefundAmount(csInfo.addrInfo[0], users[i], refundAmt);
                }
                addDailyRefundAmount(csInfo.addrInfo[0], users[i], refundAmt);
                addDailyRefundUserCnt(1);
                transferToken(csInfo.addrInfo[0],users[i],refundAmt);
                emit Refund(projectId, users[i], refundAmt, csInfo.poolAmount[uint8(PoolType.RefundPool)], block.timestamp);
            }
        }
    }
    
    function getCrowdsaleInfo(string memory projectId) public view returns (CrowdsaleInfo memory info){
        CrowdsaleInfo_i storage csInfo = crowdsaleInfoMap[projectId];
        info.interestDistributed = csInfo.amountsInfo[2];
        info.investAmount = csInfo.amountsInfo[1];
        info.projectBailPool = csInfo.poolAmount[uint8(PoolType.ProjectBailPool)];
        info.interestPool = csInfo.poolAmount[uint8(PoolType.InterestPool)];
        info.crowdsalePool = csInfo.poolAmount[uint8(PoolType.CrowdsalePool)];
        info.refundPool = csInfo.poolAmount[uint8(PoolType.RefundPool)];
        info.feePool = csInfo.poolAmount[uint8(PoolType.FeePool)];
        info.refundAmount = csInfo.refundAmount;
        info.refundUserCnt = csInfo.refundUserCnt;
        info.status = uint8(csInfo.status);
        info.investorNumber = csInfo.amountsInfo[4];
    }
    
    function setDailyRefundLimit(uint256 limit) public onlyExecutor nonReentrant {
        dailyRefundUserCnt = limit;
        //emit SetDailyRefundLimit(limit);
    }
    
    function getDailyRefundLimit() public view returns(uint256 limit, uint256 left){
        limit = dailyRefundUserCnt;
        uint256 day = block.timestamp / 86400;
        if(limit > dailyRefundCntMap[day]){
            left = limit - dailyRefundCntMap[day];
        }else{
            left = 0;
        }
    }
    
    function setDailyRefundFundLimit(address[] memory tokens, uint256[] memory limits) public onlyExecutor nonReentrant{
        require(tokens.length == limits.length, "L");
        for(uint256 i = 0;i < tokens.length; i++){
            LimitInfo storage lmtInfo = dailyRefundFundLimitMap[tokens[i]];
            if(!lmtInfo.valid){
                lmtInfo.valid = true;
                refundLimitTokenAddrs.push(tokens[i]);
            }
            lmtInfo.amount = limits[i];
            //emit SetDailyRefundFundLimit(tokens[i],limits[i]);
        }
    }
    
    function getDailyRefundFundLimit() public view returns (RefundLimitInfo[] memory limitInfos){
        uint256 cnt = refundLimitTokenAddrs.length;
        if(cnt > 0){
            limitInfos = new RefundLimitInfo[](cnt);
            for(uint256 i = 0; i < cnt; i++){
                limitInfos[i].token = refundLimitTokenAddrs[i];
                limitInfos[i].limit = dailyRefundFundLimitMap[refundLimitTokenAddrs[i]].amount;
            }
        }
    }
    
    function withdrawFee(address toAddr) public onlyExecutor nonReentrant {
        for(uint256 i = 0;i < crowdsaleTokenAddrs.length; i++){
            uint256 amount = totalPoolAmountMap[crowdsaleTokenAddrs[i]][4];
            if(amount == 0) continue;
            totalPoolAmountMap[crowdsaleTokenAddrs[i]][4] = 0;
            transferToken(crowdsaleTokenAddrs[i],toAddr,amount);
            emit WithdrawFee(crowdsaleTokenAddrs[i], toAddr, amount);
        }
    }
    
    function transferProjectBail(string memory projectId, uint256 refundFee) public onlyExecutor nonReentrant {
        CrowdsaleInfo_i storage csInfo = crowdsaleInfoMap[projectId];
        require(csInfo.poolAmount[uint8(PoolType.ProjectBailPool)] >= refundFee, "A");
        modifyPoolAmount_i(csInfo,PoolType.FeePool,refundFee,true);
        uint256 returnAmount = csInfo.poolAmount[uint8(PoolType.ProjectBailPool)] - refundFee;
        transferToken(csInfo.addrInfo[0],csInfo.addrInfo[1],returnAmount);
        modifyPoolAmount_i(csInfo,PoolType.ProjectBailPool,csInfo.poolAmount[uint8(PoolType.ProjectBailPool)],false);
        emit TransferProjectBail(projectId, csInfo.addrInfo[0], refundFee, csInfo.poolAmount[uint8(PoolType.FeePool)], returnAmount, csInfo.addrInfo[1]);
    }
    
    function refundInterestPool(string memory projectId) public onlyExecutor nonReentrant {
        CrowdsaleInfo_i storage csInfo = crowdsaleInfoMap[projectId];
        uint256 amount = csInfo.poolAmount[uint8(PoolType.InterestPool)];
        modifyPoolAmount_i(csInfo,PoolType.InterestPool,amount,false);
        transferToken(csInfo.addrInfo[0],csInfo.addrInfo[1],amount);
        emit RefundInterestPool(projectId, csInfo.addrInfo[0], csInfo.addrInfo[1], amount);
    }
    
    /*
    function getTokenInfo() public view returns(TokenInfo memory info){
    }
	
    function queryInterestInfo(string memory projectId, uint256 interestType) public view returns(InterestInfo memory info){
    }
    
    function getRefundLimitInfo() public view returns(RefundLimitInfo memory info){
    }
    
    function getUsrInterestInfo() public view returns(UsrInterestInfo memory info){
    }
    */
    
    function addExecutor(address _newExecutor) public onlyOwner {
        executorList[_newExecutor] = true;
        emit AddExecutor(_newExecutor);
    }
    
    function delExecutor(address _oldExecutor) public onlyOwner {
        executorList[_oldExecutor] = false;
        emit DelExecutor(_oldExecutor);
    }
    
    function getPoolSnapshot() public view returns (TokenInfo[] memory projectBails, TokenInfo[] memory interests, TokenInfo[] memory crowdsales, TokenInfo[] memory refunds, TokenInfo[] memory fees, TokenInfo[] memory bailFees) {
        uint256 cnt = crowdsaleTokenAddrs.length;
        address tokenAddr;
        if(cnt > 0){
            projectBails = new TokenInfo[](cnt);
            interests = new TokenInfo[](cnt);
            crowdsales = new TokenInfo[](cnt);
            refunds = new TokenInfo[](cnt);
            fees = new TokenInfo[](cnt);
            bailFees = new TokenInfo[](cnt);
            for(uint256 i = 0;i < cnt; i++){
                tokenAddr = crowdsaleTokenAddrs[i];
                projectBails[i].tokenAddr = tokenAddr;
                uint256[] storage tpAmounts = totalPoolAmountMap[tokenAddr];
                projectBails[i].amount = tpAmounts[0];
                interests[i].tokenAddr = tokenAddr;
                interests[i].amount = tpAmounts[1];
                crowdsales[i].tokenAddr = tokenAddr;
                crowdsales[i].amount = tpAmounts[2];
                refunds[i].tokenAddr = tokenAddr;
                refunds[i].amount = tpAmounts[3];
                fees[i].tokenAddr = tokenAddr;
                fees[i].amount = tpAmounts[4];
                bailFees[i].tokenAddr = tokenAddr;
                bailFees[i].amount = tpAmounts[5];
            }
        }
    }
    
    function calcInterest_i(CrowdsaleInfo_i storage csInfo, InvestInfo storage ivInfo) private view returns(uint256){
        uint256 endTime = ivInfo.refundTime;
        if(csInfo.timeInfo[2] > 0){
            if(endTime > 0){
                endTime = endTime > csInfo.timeInfo[2] ? csInfo.timeInfo[2] : endTime;
            }else{
                endTime = csInfo.timeInfo[2];
            }
        }
        if(endTime == 0){
            endTime = block.timestamp;
        }
        uint256 interest = 0;
        uint256 investTime = ivInfo.investTime - ivInfo.investTime % 86400;
        if(endTime <= investTime) return 0;
        uint256 tdays = (endTime - investTime);
        interest = ivInfo.amount * csInfo.amountsInfo[8] / 10000;
        interest = interest * tdays / (365 days);
        return interest;
    }
    
    function queryInterest(string memory projectId, address user) public view returns (UsrInterestInfo[] memory infos){
        CrowdsaleInfo_i storage csInfo = crowdsaleInfoMap[projectId];
        uint256 cnt = userInvestIdxMap[projectId][user].length;
        if(cnt > 0){
            infos = new UsrInterestInfo[](cnt);
            for(uint256 i = 0;i < cnt; i++){
                infos[i].investIdx = userInvestIdxMap[projectId][user][i];
                InvestInfo storage ivInfo = csInfo.invests[infos[i].investIdx];
                infos[i].takenAmount = ivInfo.frpInterestWithdrawAmt;
                infos[i].leftAmount = calcInterest_i(csInfo, ivInfo) - infos[i].takenAmount;
            }
        }
    }
    
    function withdrawInterest(string memory projectId, uint256[] memory investIdxs, uint256[] memory amounts) public {
        uint256 totalAmount = 0;
        CrowdsaleInfo_i storage csInfo = crowdsaleInfoMap[projectId];
        for(uint256 i = 0;i < investIdxs.length; i++){
            InvestInfo storage ivInfo = csInfo.invests[investIdxs[i]];
            require(ivInfo.userAddr == msg.sender, "U");
            uint256 investTime = ivInfo.investTime - ivInfo.investTime % 86400;
            uint256 tdays = (block.timestamp - investTime) / 86400;
            require(tdays >= csInfo.amountsInfo[6], "R");
            uint256 lAmount = calcInterest_i(csInfo, ivInfo) - ivInfo.frpInterestWithdrawAmt;
            if(amounts[i] > 0 && amounts[i] < lAmount){
                lAmount = amounts[i];
            }
            ivInfo.frpInterestWithdrawAmt += lAmount;
            totalAmount += lAmount;
            emit WithdrawInterest(projectId, msg.sender, investIdxs[i], lAmount);
        }
        if(totalAmount > 0){
            modifyPoolAmount_i(csInfo,PoolType.InterestPool,totalAmount,false);
            transferToken(csInfo.addrInfo[0],msg.sender,totalAmount);
        }
    }
}