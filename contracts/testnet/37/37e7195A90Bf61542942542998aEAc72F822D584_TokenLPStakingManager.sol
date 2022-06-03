/**
 *Submitted for verification at BscScan.com on 2022-06-02
*/

// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.0;

//import "hardhat/console.sol";


/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
    function symbol() external view returns (string memory);
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

interface TokenLPStaking {
    struct StakeOut {
        IERC20Upgradeable stakeOutToken;
        uint256 multiple; // 倍数 使用时除以10000
    }
    function exchange(address _token, address[] calldata _addresses, uint256 _amount) external view returns(bool);
    function earnedList(address account) external view returns(uint256[] memory);
    function rewardsList(address account) external view returns(uint256[] memory);
    function rewardSumsList(address account) external view returns(uint256[] memory);
    function stakeOutTokenList() external view returns(StakeOut[] memory);
    function getReward() external;
    function dayOut() external view returns(uint256);
    function balanceOf(address account) external view returns(uint256);
    function totalSupply() external view returns(uint256);
    function totalOutput() external view returns(uint256);
    function dayOutList() external view returns(uint256[] memory);
    function dayOutStake() external view returns(uint256[] memory);
}

interface PancakePair {
    function token0() external view returns(address);
    function token1() external view returns(address);
    function totalSupply() external view returns(uint256);
    function getReserves() external view returns (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast);
}

contract TokenLPStakingManager is OwnableUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    LP[] public lpPairs;

    IERC20Upgradeable public fffToken;

    mapping(address => bool) public canMint;

    IERC20Upgradeable public pgToken;
    
    struct LP {
        address lpPair;     // 交易对 LP
        address token0; 
        address token1;
        address staking;    // 矿池合约
        string token0Name;
        string token1Name;
        uint swapExchange; 
    }

    struct LpPoolData {
        address staking;        // 矿池合约
        uint256 earned;         // 可提取收益
        uint256 dayOut;         // 每日产出
        uint256 balance;        // 质押数量
        uint256 totalOutput;    // 总质押数量
        uint256 apy;            // APY
        uint swapExchange;      // 交易所
        uint outStakeNum;       // 矿池产出多少个币种
    }

    struct LpPool {
        address staking;        // 矿池合约
        uint256 balance;        // 质押数量
        uint256 totalOutput;    // 总质押数量
        Reward[] reward;        // 奖励的信息
        uint swapExchange;      // 交易所
        uint outStakeNum;       // 矿池产出多少个币种
    }

    struct Reward {
        uint256 earned;         // 可提取收益
        uint256 dayOut;         // 每日产出
        uint256 apy;            // APY
    }

    event UpdateAllowMint(address indexed sender, bool indexed allow, address[] addresses);

    function initialize() public initializer {
        __Ownable_init();       
    }

    function init(
        address fffToken_,
        address pgToken_
    )  public onlyOwner {        
        fffToken = IERC20Upgradeable(fffToken_);
        pgToken = IERC20Upgradeable(pgToken_);
    }

    modifier onlyAllowMint() {
        require(canMint[_msgSender()], "TokenLPStakingManager: Can Not Mint");
        _;
    }

    function setLpPairs(address[] calldata _lpPairs, address[] calldata _staking, uint[] calldata _swapExchange) public onlyOwner returns(bool){
        require(_lpPairs.length == _staking.length, "TokenLPStakingManager: Unequal length");
        delete lpPairs;
        for(uint i=0; i< _lpPairs.length; i++) {
            address _lpPair = _lpPairs[i];
            address _token0 = PancakePair(_lpPair).token0();
            address _token1 = PancakePair(_lpPair).token1();
            lpPairs.push(LP(_lpPair, _token0, _token1, _staking[i], IERC20Upgradeable(_token0).symbol(), IERC20Upgradeable(_token1).symbol(), _swapExchange[i]));
        }
        
        return true;
    }

    function listLpPairs() public view returns(LP[] memory) {
        return lpPairs;
    }

    function listLpPool(address account) public view returns(LpPoolData[] memory) {
        LpPoolData[] memory _list = new LpPoolData[](lpPairs.length);
        for(uint i=0; i< _list.length; i++) {
            LP memory lp = lpPairs[i];
            TokenLPStaking staking = TokenLPStaking(lp.staking);
            uint256[] memory earneds = staking.earnedList(account);
            uint256[] memory _dayOutList = staking.dayOutList();
            _list[i] = LpPoolData(address(staking), earneds.length == 0 ? 0 : earneds[0], _dayOutList.length == 0 ? 0 : _dayOutList[0], staking.balanceOf(account), staking.totalSupply(), 
                getAPY(lp.staking, lp.lpPair), lp.swapExchange, _dayOutList.length);
        }
        return _list;
    }

    function listLp(address account) public view returns(LpPool[] memory) {
        LpPool[] memory _list = new LpPool[](lpPairs.length);
        for(uint i=0; i< _list.length; i++) {
            LP memory lp = lpPairs[i];
            TokenLPStaking staking = TokenLPStaking(lp.staking);
            uint256[] memory earneds = staking.earnedList(account);
            uint256[] memory _dayOutList = staking.dayOutList();
            Reward[] memory _rewards = new Reward[](_dayOutList.length);
            for(uint j=0; j< _rewards.length; j++) {
                _rewards[j] = Reward(earneds[j], _dayOutList[j], getAPY(lp.staking, lp.lpPair));
            }
            _list[i] = LpPool(address(staking), staking.balanceOf(account), staking.totalSupply(), 
                _rewards, lp.swapExchange, _dayOutList.length);
        }
        return _list;
    }

    function totalLockAmount() public view returns(uint256) {
        uint256 _totalValue;
        for(uint i=0; i< lpPairs.length; i++) {
            TokenLPStaking _staking = TokenLPStaking(lpPairs[i].staking);
            _totalValue += lpValue(lpPairs[i].lpPair) * _staking.totalSupply() / 1e18;
        }

        return _totalValue * uPerFFF() / 1e18;
    }

    // fff的价格
    function uPerFFF() public view returns(uint256) {
        PancakePair pancakePair = PancakePair(lpPairs[0].lpPair);
        uint256 reserve0;
        uint256 reserve1;
        (reserve0, reserve1, ) = pancakePair.getReserves();
        uint256 price = pancakePair.token0() == address(fffToken) ? reserve1 * 1e18 / reserve0 : reserve0 * 1e18 / reserve1;
        return price;
    }

    // 计算矿池和lp的apy
    function getAPY(address staking, address lp) public view returns(uint256) {
        PancakePair pancakePair = PancakePair(lp);
        uint256 reserve0;
        uint256 reserve1;
        (reserve0, reserve1, ) = pancakePair.getReserves();
        uint256 _lpValue = lpValue(lp);
        TokenLPStaking _staking = TokenLPStaking(staking);
        uint256[] memory _dayOutStake = _staking.dayOutStake();
        uint256 apy = _staking.totalSupply() * _lpValue * reserve0 == 0 ? 0: _dayOutStake[0] * reserve1 * 365 * 1e22 / (_staking.totalSupply() * _lpValue * reserve0);
        return apy;
    }

    // 计算lp单个令牌的价值
    function lpValue(address lp) public view returns(uint256) {
        PancakePair pancakePair = PancakePair(lp);
        uint256 _totalSupply = pancakePair.totalSupply();
        uint256 reserve0;
        uint256 reserve1;
        (reserve0, reserve1, ) = pancakePair.getReserves();
        uint256 uValue = pancakePair.token0() == address(fffToken) ? reserve0 : reserve1;
        return ((uValue * 2) * 1e18 / _totalSupply);
    }

    function earnedList(address staking, address account) public view returns(uint256[] memory){
        return TokenLPStaking(staking).earnedList(account);
    }

    function balanceOf(address staking, address account) public view returns(uint256){
        return TokenLPStaking(staking).balanceOf(account);
    }

    function dayOut(address staking) public view returns(uint256){
        return TokenLPStaking(staking).dayOut();
    }

    function dayOutList(address staking) public view returns(uint256[] memory){
        return TokenLPStaking(staking).dayOutList();
    }

    function totalSupply(address staking) public view returns(uint256){
        return TokenLPStaking(staking).totalSupply();
    }

    function rewardSumsList(address account) public view returns(uint256[] memory) {
        uint256[] memory _list = new uint256[](2);
        for(uint i=0; i< lpPairs.length; i++) {
            uint256[] memory rewardSums = TokenLPStaking(lpPairs[i].staking).rewardSumsList(account);
            for(uint j=0; j< rewardSums.length; j++) {
                _list[j] += rewardSums[j];
            }
        }
        return _list;
    }

    function earnedsList(address account) public view returns(uint256[] memory) {
        uint256[] memory _list = new uint256[](2);
        for(uint i=0; i< lpPairs.length; i++) {
            uint256[] memory earned = TokenLPStaking(lpPairs[i].staking).earnedList(account);
            for(uint j=0; j< earned.length; j++) {
                _list[j] += earned[j];
            }
        }
        return _list;
    }

    function setCanMint(address[] calldata _allowMint, bool allow) public onlyOwner {
        for(uint i=0; i< _allowMint.length; i++) {
            canMint[_allowMint[i]] = allow;
        }
        emit UpdateAllowMint(_msgSender(), allow, _allowMint);
    }

    function mintFrom(address to, uint256 value) public onlyAllowMint returns (bool) {
        fffToken.safeMint(to, value);
        return true;
    }

    function mintToken(address to, uint256 value) public onlyAllowMint returns (bool) {
        pgToken.safeTransfer(to, value);
        return true;
    }
}