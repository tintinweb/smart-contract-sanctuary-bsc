/**
 *Submitted for verification at BscScan.com on 2022-06-01
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

abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

interface FFFExchange {
    function exchange(address contractAddress, address toAddress, uint256 amountToWei) external returns(bool);
    function fff2ffftRatio() external view returns(uint256);
}

interface TokenLPStakingManager {
    function mintFrom(address to, uint256 value) external returns (bool);
    function mintToken(address to, uint256 value) external returns (bool);
}

contract TokenWrapper {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    IERC20Upgradeable public stakeInToken;

    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;


    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function stake(uint256 amount) public virtual {
        _totalSupply = _totalSupply + amount;
        _balances[msg.sender] += amount;
        stakeInToken.safeTransferFrom(msg.sender, address(this), amount);
    }

    function withdraw(uint256 amount) public virtual {
        _totalSupply = _totalSupply - amount;
        _balances[msg.sender] -= amount;
        stakeInToken.safeTransfer(msg.sender, amount);
    }
}


contract TokenLPStaking is TokenWrapper, OwnableUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;
    StakeOut[] public stakeOutTokenList;
    
    struct StakeOut {
        IERC20Upgradeable stakeOutToken;
        uint256 multiple; // 倍数 使用时除以10000
    }

    //
    uint256 public totalOutput = 210000e8;
    uint256 public oneDay = 86400;
    

    uint256 public starttime = 2310886017;
    uint256 public periodFinish = 0;
    uint256 public rewardRate = 0;
    uint256 public lastUpdateTime = 2310886017;
    uint256 public rewardPerTokenStored;
    bool public canWithdraw;
    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;
    mapping(address => uint256) public rewardSums;
    uint256 public dayOut;

    TokenLPStakingManager public lpManager; // LP管理合约
    FFFExchange public fffExchange; // 兑换合约
    IERC20Upgradeable public fffToken; // 需要兑换成ffft的合约

    event RewardAdded(uint256 reward);
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);
    event RewardPaid(address indexed user, address indexed token, uint256 reward);
    event UpdateDayOut(uint256 dayOut);
    event UpdateWithdrawStatus(bool oldStatus, bool newStatus);
    event UpdateStartTime(uint time);

    function initialize() public initializer {
        canWithdraw =false;
        starttime = 2310886017;
        lastUpdateTime = 2310886017;
        __Ownable_init();       
    }

    function init(
        address fffExchange_, 
        address lpManager_,
        address inToken_,
        address fffToken_,
        uint256 starttime_, // 开始时间
        uint256 dayOut_,    // 每日产出
        uint256 totalAmount_    // FFF总产量
    )  public onlyOwner {        
        oneDay = 86400;
        totalOutput = totalAmount_;
        // stakeOutToken = IERC20Upgradeable(outToken_);
        stakeInToken = IERC20Upgradeable(inToken_);
        lpManager = TokenLPStakingManager(lpManager_);
        fffToken = IERC20Upgradeable(fffToken_);
        fffExchange = FFFExchange(fffExchange_);
        starttime = starttime_;
        lastUpdateTime = starttime;

        dayOut = dayOut_;
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

    function setCanWithdraw(bool _enable) external onlyOwner {
        emit UpdateWithdrawStatus(canWithdraw, _enable);
        canWithdraw = _enable;
    }

    function setFFFToken(address _token) external onlyOwner {
        fffToken = IERC20Upgradeable(_token);
    }

    function setFFFExchange(address _token) external onlyOwner {
        fffExchange = FFFExchange(_token);
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

    function setDayOut(uint256 dayOut_) external onlyOwner returns(bool){
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();

        dayOut = dayOut_;
        rewardRate = dayOut_ * 1e18 / oneDay;
        if (dayOut_ > 0){
            periodFinish = starttime + totalOutput * oneDay / dayOut_;
        }
        emit UpdateDayOut(dayOut_);
        return true;
    }

    // 设置产出Token列表
    function setStakeOutTokenList(address[] calldata _token, uint256[] calldata _multiple) public onlyOwner returns(bool){
        require(_token.length == _multiple.length, "TokenLPStaking: Unequal length");
        delete stakeOutTokenList;
        for(uint i=0; i< _token.length; i++) {
            stakeOutTokenList.push(StakeOut(IERC20Upgradeable(_token[i]), _multiple[i]));
        }
        
        return true;
    }

    function listStakeOutToken() public view returns(StakeOut[] memory) {
        return stakeOutTokenList;
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

    function earnedList(address account) public view returns(uint256[] memory) {
        return compute(earned(account));
    }

    function rewardsList(address account) public view returns(uint256[] memory) {
        return compute(rewards[account]);
    }

    function rewardSumsList(address account) public view returns(uint256[] memory) {
        return compute(rewardSums[account]);
    }

    function compute(uint256 amount) public view returns(uint256[] memory) {
        uint256[] memory _list = new uint256[](stakeOutTokenList.length);
        for(uint i=0; i< stakeOutTokenList.length; i++) {
            if (address(stakeOutTokenList[i].stakeOutToken) == address(fffToken)) {
                _list[i] = amount * fffExchange.fff2ffftRatio() * stakeOutTokenList[i].multiple / 1e4;
                continue;
            }
            _list[i] = amount * stakeOutTokenList[i].multiple / 1e4;
        }
        return _list;
    }

    function stake(uint256 amount)
    public
    override
    updateReward(msg.sender){
        require(amount > 0, ' Cannot stake 0');
        super.stake(amount);
        emit Staked(msg.sender, amount);
    }

    function withdraw(uint256 amount)
    public
    override
    updateReward(msg.sender)
    
    {
        require(canWithdraw, "inactive");
        require(amount > 0, ' Cannot withdraw 0');
        super.withdraw(amount);
        emit Withdrawn(msg.sender, amount);
    }

    function exit() external {
        withdraw(balanceOf(msg.sender));
        getReward();
    }

    function getReward() public updateReward(msg.sender) checkStart {
        uint256 reward = earned(msg.sender);
        if (reward > 0) {
            rewards[msg.sender] = 0;
            require(stakeOutTokenList.length > 0, "Stake Out Token 0");
            for(uint i=0; i< stakeOutTokenList.length; i++) {
                IERC20Upgradeable stakeOut = stakeOutTokenList[i].stakeOutToken;
                uint256 outRewards = reward * stakeOutTokenList[i].multiple / 1e4;
                if (address(stakeOutTokenList[i].stakeOutToken) == address(fffToken)) {
                    exchange(msg.sender, outRewards);
                    continue;
                }
                mintFromLPManager(msg.sender, outRewards);
                emit RewardPaid(msg.sender, address(stakeOut), outRewards);
            }
            rewardSums[msg.sender] += reward;
            emit RewardPaid(msg.sender, reward);
        }
    }

    // 兑换FFF到某个地址
    function exchange(address toAddress, uint256 _amount) internal returns(bool) {
        lpManager.mintFrom(address(this), _amount);     // 先挖到合约
        fffToken.approve(address(fffExchange), _amount);  // 授权
        fffExchange.exchange(address(fffToken), toAddress, _amount); // 再兑换
        return true;
    }

    // 从管理合约挖出来
    function mintFromLPManager(address toAddress, uint256 _amount) internal returns(bool) {
        lpManager.mintToken(toAddress, _amount);
        return true;
    }

    // 提取fff
    function extractTokens(address outAddress, uint amountToWei) public onlyOwner {
        fffToken.safeTransfer(outAddress, amountToWei);
    }

    
}