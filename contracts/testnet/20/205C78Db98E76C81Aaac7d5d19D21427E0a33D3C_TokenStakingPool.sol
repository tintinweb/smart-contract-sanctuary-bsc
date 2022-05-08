/**
 *Submitted for verification at BscScan.com on 2022-05-07
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-06
*/

// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.0;

//import "hardhat/console.sol";


/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256); 

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256); 

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool); 

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function mint(address account, uint256 amount) external returns (bool);
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

        (bool success,) = recipient.call{value : amount}("");
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

        (bool success, bytes memory returndata) = target.call{value : value}(data);
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


/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20Upgradeable {
    using AddressUpgradeable for address; 

    function safeMint(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.mint.selector, to, value));
    }

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
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
        IERC20Upgradeable token,
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
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
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
    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {
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
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, because in other contexts the
        // contract may have been reentered.
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

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

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} modifier, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}

abstract contract ContextUpgradeable is Initializable {

    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }

    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

abstract contract OwnableUpgradeable is ContextUpgradeable { 
    address private _owner;
    address private _approver;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner); 
    event ApprovershipTransferred(address indexed previousApprover, address indexed newApprover); 

    function __Ownable_init() internal {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal {
        _transferOwnership(_msgSender());
        _transferApprovership(_msgSender());
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
     * @dev Returns the address of the current approver.
     */
    function approver() public view virtual returns (address) {
        return _approver;
    }

    /**
     * @dev Throws if called by any account other than the approver.
     */
    modifier onlyApprover() { 
        require(owner() == _msgSender() || approver() == _msgSender() , "Ownable: caller is not the owner or approver");
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

    function renounceApprovership() public virtual onlyApprover {
        _transferApprovership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function transferApprovership(address newApprover) public virtual onlyApprover {
        require(newApprover != address(0), "Ownable: new approver is the zero address");
        _transferApprovership(newApprover);
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

    function _transferApprovership(address newApprover) internal virtual {
        address oldApprover = _approver;
        _approver = newApprover;
        emit ApprovershipTransferred(oldApprover, newApprover);
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

contract Util {

    /*
     * @dev 转换位
     * @param price 价格
     * @param decimals 代币的精度
     */
    function toWei(uint256 price, uint decimals) public pure returns (uint256){
        uint256 amount = price * (10 ** uint256(decimals));
        return amount;
    }

    /*
     * @dev 回退位
     * @param price 价格
     * @param decimals 代币的精度
     */
    function backWei(uint256 price, uint decimals) public pure returns (uint256){
        uint256 amount = price / (10 ** uint256(decimals));
        return amount;
    }

    /*
     * @dev 浮点类型除法 a/b
     * @param a 被除数
     * @param b 除数
     * @param decimals 精度
     */
    function mathDivisionToFloat(uint256 a, uint256 b,uint decimals) public pure returns (uint256){
        uint256 aPlus = a * (10 ** uint256(decimals));
        uint256 amount = aPlus/b;
        return amount;
    }

}

contract Wrapper is Util, OwnableUpgradeable{

    uint256 private _limitMultiple = 3;

    address[] private _accounts;
    uint256 private _accountNum = 0;

    uint256 private _totalSupply;
    uint256 private _totalIn; 
    uint256 private _totalMint;
    uint256 private _totalReward;

    mapping(address => uint256) private _balances;
    mapping(address => uint256) private _inBalances;
    mapping(address => uint256) private _rewardBalances;
    mapping(address => uint256) private _mintBalances;

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function totalIn() public view returns (uint256) { 
        return _totalIn;
    }

    function totalMint() public view returns (uint256) {
        return _totalMint;
    }

    function totalReward() public view returns (uint256) {
        return _totalReward;
    }

    function balanceOf(address account) public view returns (uint256) { 
        return _balances[account]; 
    }

    function inBalancesOf(address account) public view returns (uint256) { 
        return _inBalances[account]; 
    }

    function rewardBalancesOf(address account) public view returns (uint256) { 
        return _rewardBalances[account]; 
    }

    function mintBalancesOf(address account) public view returns (uint256) { 
        return _mintBalances[account]; 
    } 

    function limit(address account) public view returns (uint256) { 
        return ( _balances[account] - _rewardBalances[account] - _mintBalances[account] ) * _limitMultiple - _rewardBalances[account];
    }

    function stake(uint256 amount) public virtual { 
        _inBalances[msg.sender] = _inBalances[msg.sender] + amount; 
        _totalIn = _totalIn + amount;
        addBalance(msg.sender,amount);   
    }

    function mint(address account,uint256 amount) public onlyApprover virtual{ 
        _mintBalances[account] += amount; 
        _totalMint = _totalMint + amount;
        addBalance(account,amount);
    }

    /**
    *   @dev 奖励voola兑换算力
    */
    function reward(address account,uint amount) internal virtual{
        require(amount <= limit(account) ,"TokenStakingPool: beyond the limit");
        _totalReward = _totalReward + amount;
        _rewardBalances[account] += amount; 
        addBalance(account,amount);   
    } 

    /**
    *   @dev 添加算力
    */
    function addBalance(address account,uint amount) private { 
        _totalSupply = _totalSupply + amount;
        if(_balances[account] < 1){ 
            _accounts.push(account); 
            _accountNum = _accountNum + 1; 
        }
        _balances[account] = _balances[account] + amount; 
    }

    /*
     * @dev  查询 | 所有人调用 | 获取所有地址及算力 
     */
    function getAllAccountBalance() public onlyApprover view returns (address[] memory,uint256[] memory){ 
        uint256[] memory balances = new uint256[](_accountNum);
        for(uint i = 0;i<_accountNum ; i++){
            balances[i] = _balances[_accounts[i]]; 
        }
        return (_accounts,balances);
    }

}

abstract contract PancakePair{
    function getReserves() external virtual view returns (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast);
}

abstract contract VOOLA{
    function getParentsBySize(address user,uint size) public virtual view returns(address[] memory);
}

contract TokenStakingPool is Wrapper { 
    using SafeERC20Upgradeable for IERC20Upgradeable;

    PancakePair private pancakePair;

    IERC20Upgradeable public stakeOutToken;
    IERC20Upgradeable public stakeInToken;

    uint256 public totalOutput = 210000e8; //总产出
    uint256 public oneDay = 86400; //日产出

    uint256 public starttime = 2310886017; //开始产出事件
    uint256 public periodFinish = 0;
    uint256 public rewardRate = 0; 
    uint256 public lastUpdateTime = 2310886017; 
    uint256 public rewardPerTokenStored;
    mapping(address => uint256) public userRewardPerTokenPaid; 
    mapping(address => uint256) public rewards;
    mapping(address => uint256) public rewardSums;

    mapping(address => uint256) public surplusInviteReward; //剩余奖励未兑换voola
    mapping(address => uint256) public totalInviteReward; //总奖励voola

    mapping(address => uint256) public stakeIn; //质押代币 
    uint256 public totalStakeIn; //总质押代币

    VOOLA private voola;
    uint[] public rewardMultiple; 

    event RewardAdded(uint256 reward);
    event Staked(address indexed user, uint256 amount);
    event Mint(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward, uint time);
    event UpdateStartTime(uint time);

    constructor() {
        __Ownable_init();
    }

    function init(
        address outToken_, 
        address inToken_,
        uint256 starttime_, // 开始时间
        uint256 dayOut_,    // 每日产出
        uint256 totalAmount_,   // VOOLA总产量 
        address pancakePairAddress,
        uint[] memory _rewardMultiple
    )  public onlyOwner {        
        oneDay = 86400;
        totalOutput = totalAmount_;
        stakeOutToken = IERC20Upgradeable(outToken_);
        stakeInToken = IERC20Upgradeable(inToken_);
        pancakePair = PancakePair(pancakePairAddress);
        starttime = starttime_;
        lastUpdateTime = starttime;
        voola = VOOLA(inToken_);
        rewardMultiple = _rewardMultiple;
        periodFinish = starttime_ + totalAmount_ * oneDay / dayOut_; 
        rewardRate = dayOut_ * 1e18 / oneDay;
    }

    modifier checkStart() {
        require(block.timestamp >= starttime, "not start");
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

    function setStartTime(uint time) external onlyOwner returns(bool){
        require(starttime > block.timestamp,"reward is started");
        require(time < periodFinish, "the start time cannot be greater than the end time" );
        
        if (starttime != time && time > 0 ){ 
            starttime = time;
            lastUpdateTime = starttime;
            emit UpdateStartTime(time); 
            return true; 
        }
        return false;

    }

    function lastTimeRewardApplicable() public view returns (uint256) {
        uint curTime = block.timestamp;
        if (starttime > curTime){
            return starttime;
        }
        if (periodFinish > curTime) {
            return block.timestamp;
        }

        return periodFinish;
    }

    function rewardPerToken() public view returns (uint256) {
        if (totalSupply() == 0) {
            return rewardPerTokenStored; 
        }
        //        uint tmp = (lastTimeRewardApplicable() - lastUpdateTime) * rewardRate * 1e18;
        uint tmp = (lastTimeRewardApplicable() - lastUpdateTime) * rewardRate; 

        return rewardPerTokenStored + tmp / totalSupply();
    } 

    function earned(address account) public view returns (uint256) { 
        return rewards[account] + balanceOf(account) * (rewardPerToken() - userRewardPerTokenPaid[account]) / 1e18;
    }

    function stake(uint256 amount) 
    public
    override
    updateReward(msg.sender){ 
        require(amount > 0, ' Cannot stake 0'); 
        uint price = queryVoola2UsdtPrice();
        uint num = Util.backWei( price * amount, 18); 
        super.stake(num);
        totalStakeIn = totalStakeIn + amount;
        stakeIn[msg.sender] =  stakeIn[msg.sender] + amount;
        stakeInToken.safeTransferFrom(msg.sender, address(this), amount); 
        inviteReward(amount);
        emit Staked(msg.sender, amount); 
    }

    function mint(address account,uint256 amount) 
    public
    onlyApprover
    override
    updateReward(msg.sender){
        require(amount > 0, ' Cannot mint 0');
        super.mint(account,amount);
        emit Mint(account, amount); 
    }

    function inviteReward(uint amount) private { 
      address[] memory parents = voola.getParentsBySize(msg.sender,rewardMultiple.length); 
      for(uint i = 0; i < parents.length; i++){
          uint256 _inviteReward = amount * rewardMultiple[i] / 100; 
          surplusInviteReward[parents[i]] = surplusInviteReward[parents[i]] + _inviteReward;
          totalInviteReward[parents[i]] = totalInviteReward[parents[i]] + _inviteReward;
      }
    }

    function differentialReward(address targer,uint amount) public onlyApprover { 
        surplusInviteReward[targer] = surplusInviteReward[targer] + amount;
        totalInviteReward[targer] = totalInviteReward[targer] + amount;
    }

    function rewardExchange(uint amount) public { 
        require(surplusInviteReward[_msgSender()] >= amount,"TokenStaking: The remaining reward Voola is insufficient");
        uint price = queryVoola2UsdtPrice(); 
        uint num = Util.backWei( price * amount, 18); 
        super.reward(_msgSender(),num);
        surplusInviteReward[_msgSender()] = surplusInviteReward[_msgSender()] - amount;
    }

    function getReward() public updateReward(msg.sender) checkStart { 
        uint256 reward = earned(msg.sender);
        if (reward > 0) {
            rewards[msg.sender] = 0; 
            stakeOutToken.safeMint(msg.sender, reward);            
            rewardSums[msg.sender] += reward;
            emit RewardPaid(msg.sender, reward,lastTimeRewardApplicable());
        }
    }

    /*
     * @dev  查询 | 所有人调用 | 获取1个voola等值的usdt数量
     */
    function queryVoola2UsdtPrice() public view returns (uint256){ 
        uint112 usdtSum;//LP池中,usdt总和
        uint112 voolaSum;//LP池中,voola总和
        uint32 lastTime;//最后一次交易时间
        (usdtSum,voolaSum,lastTime) = pancakePair.getReserves(); 

        uint256 voolaToUsdtPrice = Util.mathDivisionToFloat(usdtSum,voolaSum,18);
        return voolaToUsdtPrice;
    }

    function updateRewardMultiple(uint[] memory _rewardMultiple) public {
        rewardMultiple = _rewardMultiple; 
    }

    function queryRewardMultiple() public view returns (uint[] memory){
        return rewardMultiple;
    }

    function querySurplusInviteReward(address target) public view returns (uint){
        return surplusInviteReward[target];
    }

    function queryTotalInviteReward(address target) public view returns (uint){
        return totalInviteReward[target];
    }

    function queryTotalStakeIn() public view returns (uint){
        return totalStakeIn;
    }

    function queryStakeIn(address target) public view returns (uint){
        return stakeIn[target];
    }
    
}