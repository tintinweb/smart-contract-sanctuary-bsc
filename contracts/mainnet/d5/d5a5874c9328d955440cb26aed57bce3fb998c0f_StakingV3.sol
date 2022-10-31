/**
 *Submitted for verification at BscScan.com on 2022-10-31
*/

// SPDX-License-Identifier: BUSL-1.1
// File: @openzeppelin/contracts/utils/Context.sol

// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
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

// File: @openzeppelin/contracts/access/Ownable.sol

// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

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

// File: @openzeppelin/contracts/utils/Address.sol

// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)

pragma solidity ^0.8.0;

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
        assembly {
            size := extcodesize(account)
        }
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

// File: @openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol

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

// File: contracts/Staking/IStakingV3.sol

pragma solidity =0.8.6;

abstract contract IStakingV3 {

    function userInfo(uint256 pid, address addr)
    public virtual view returns (uint256, uint256, uint256, uint256, uint256);

    function poolInfo(uint256 pid)
    public virtual view returns (uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256);

    function maxPid() public virtual view returns (uint256);

    function totalPoolShare() public virtual view returns (uint256);

    function token() public virtual view returns (address);

    function tokenPerBlock() public virtual view returns (uint256);

    function pendingRewards(uint256 pid, address addr, address asset) external virtual view returns (uint256);

    function deposit(uint256 pid, uint256 amount) external virtual;

    function deposit(uint256 pid, address addr, uint256 amount) external virtual;

    function withdraw(uint256 pid, uint256 amount) external virtual;

    function claim(uint256 pid) external virtual;

    function claim(uint256 pid, address asset) external virtual;
}

// File: contracts/Staking/StakingV3Dealer.sol

pragma solidity =0.8.6;

/**
 * @title Token Staking
 * @dev BEP20 compatible token.
 */
contract StakingV3Dealer is Ownable {
    using SafeERC20 for IERC20;

    struct UserInfo {
        uint256 rewardDebt;
        uint256 pendingRewards;
    }

    struct PoolInfo {
        uint256 poolShare;
        uint256 lastBlock;
        uint256 tokenPerShare;
        uint256 tokenRewarded;
        uint256 realTokenPerShare;
        uint256 realTokenReceived;
        uint256 realTokenRewarded;
    }

    IERC20 public token;
    IStakingV3 public parent;

    uint256 public tokenPerBlock;
    uint256 public tokenParentPrecision;
    uint256 public startBlock;
    uint256 public closeBlock;
    
    uint256 public maxPid;

    PoolInfo[] public poolInfo;
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;

    event WithdrawnReward(address indexed user, uint256 indexed pid, address indexed token, uint256 amount);
    event WithdrawnRemain(address indexed user, uint256 indexed pid, address indexed token, uint256 amount);
    event TokenAddressChanged(address indexed token);
    event TokenRewardsChanged(address indexed token, uint256 amount);

    event ParentChanged(address indexed addr);
    event StartBlockChanged(uint256 block);
    event CloseBlockChanged(uint256 block);

    constructor(address _parent, IERC20 _token) {
        setParent(_parent);
        setTokenAddress(_token);
        for (uint i=0; i<parent.maxPid(); i++) addPool(i);
        tokenParentPrecision = parent.tokenPerBlock();
    }

    function setParent(address _parent) public onlyOwner {
        require(_parent != address(0), "Staking: parent address needs to be different than zero!");
        parent = IStakingV3(_parent);
        emit ParentChanged(address(parent));
    }

    function setTokenAddress(IERC20 _token) public onlyOwner {
        require(address(_token) != address(0), "Staking: token address needs to be different than zero!");
        require(address(token) == address(0), "Staking: tokens already set!");
        token = _token;
        emit TokenAddressChanged(address(token));
    }

    function setTokenPerBlock(uint256 _tokenPerBlock, uint256 _startBlock, uint256 _closeBlock) public virtual onlyOwner {
        if (_startBlock != startBlock) setStartBlock(_startBlock);
        if (_closeBlock != closeBlock) setCloseBlock(_closeBlock);
        setTokenPerBlock(_tokenPerBlock);
    }

    function setTokenPerBlock(uint256 _tokenPerBlock) public virtual onlyOwner {
        require(startBlock != 0, "Staking: cannot set reward before setting start block");
        for (uint i=0; i<maxPid; i++) updatePool(i);
        tokenPerBlock = _tokenPerBlock;
        emit TokenRewardsChanged(address(token), _tokenPerBlock);
    }

    function setStartBlock(uint256 _startBlock) public virtual onlyOwner {
        require(startBlock == 0 || startBlock > block.number, "Staking: start block already set");
        require(_startBlock > 0, "Staking: start block needs to be higher than zero!");
        startBlock = _startBlock;
        emit StartBlockChanged(_startBlock);
    }

    function setCloseBlock(uint256 _closeBlock) public virtual onlyOwner {
        require(startBlock != 0, "Staking: start block needs to be set first");
        require(closeBlock == 0 || closeBlock > block.number, "Staking: close block already set");
        require(_closeBlock == 0 || _closeBlock > startBlock, "Staking: close block needs to be higher than start one!");
        closeBlock = _closeBlock;
        emit CloseBlockChanged(_closeBlock);
    }

    function withdrawRemaining(address addr) external virtual onlyOwner {
        if (startBlock == 0 || closeBlock == 0 || block.number <= closeBlock) {
            return;
        }
        for (uint i=0; i<maxPid; i++) {
            updatePool(i);
        }

        uint256 allTokenRewarded = 0;
        uint256 allTokenReceived = 0;

        for (uint i=0; i<maxPid; i++) {
            allTokenRewarded = allTokenRewarded + poolInfo[i].realTokenRewarded;
            allTokenReceived = allTokenReceived + poolInfo[i].realTokenReceived;
        }

        uint256 unlockedAmount = 0;
        uint256 possibleAmount = token.balanceOf(address(parent));
        uint256 reservedAmount = allTokenRewarded - allTokenReceived;

        if (address(token) == address(parent.token())) {
            for (uint i=0; i<maxPid; i++) {
                ( ,,, uint256 tokenRealStaked,,,, ) = parent.poolInfo(i);
                reservedAmount = reservedAmount + tokenRealStaked;
            }
        }

        if (possibleAmount > reservedAmount) {
            unlockedAmount = possibleAmount - reservedAmount;
        }
        if (unlockedAmount > 0) {
            token.safeTransferFrom(address(parent), addr, unlockedAmount);
            emit WithdrawnRemain(addr, 0, address(token), unlockedAmount);
        }
    }

    function pendingRewards(uint256 pid, address addr) external virtual view returns (uint256) {
        if (pid >= maxPid || startBlock == 0 || block.number < startBlock) {
            return 0;
        }

        PoolInfo storage pool = poolInfo[pid];
        UserInfo storage user = userInfo[pid][addr];
        ( uint256 amount,,,, ) = parent.userInfo(pid, addr);

        uint256 lastMintedBlock = pool.lastBlock;
        if (lastMintedBlock == 0) {
            lastMintedBlock = startBlock;
        }
        uint256 lastBlock = getLastRewardBlock();
        if (lastBlock == 0) {
            return 0;
        }
        ( uint256 poolShare,, uint256 tokenPerShare, uint256 tokenRealStaked,,,, ) = parent.poolInfo(pid);
        
        uint256 realTokenPerShare = pool.realTokenPerShare;
        if (lastBlock > lastMintedBlock && tokenRealStaked != 0) {
            uint256 multiplier = lastBlock - lastMintedBlock;
            uint256 tokenAward = multiplier * parent.tokenPerBlock() * poolShare / parent.totalPoolShare();
            tokenPerShare = tokenAward * 1e12 / tokenRealStaked;
            realTokenPerShare = realTokenPerShare + (tokenPerShare * tokenPerBlock);
        }
        return amount * realTokenPerShare / 1e12 / tokenParentPrecision - user.rewardDebt + user.pendingRewards;
    }

    function update(uint256 pid, address user, uint256 amount) external virtual onlyOwner {
        if (pid >= maxPid || startBlock == 0 || block.number < startBlock) {
            return;
        }
        updatePool(pid);
        updatePendingReward(pid, user);
        updateRealizeReward(pid, user, amount);
    }

    function claim(uint256 pid, address addr) external virtual onlyOwner returns (uint256) {
        if (pid >= maxPid || startBlock == 0 || block.number < startBlock) {
            return 0;
        }

        PoolInfo storage pool = poolInfo[pid];
        UserInfo storage user = userInfo[pid][addr];

        updatePool(pid);
        updatePendingReward(pid, addr);

        uint256 claimedAmount = 0;
        if (user.pendingRewards > 0) {
            claimedAmount = transferPendingRewards(pid, addr, user.pendingRewards);
            emit WithdrawnReward(addr, pid, address(token), claimedAmount);
            user.pendingRewards = user.pendingRewards - claimedAmount;
            pool.realTokenReceived = pool.realTokenReceived + claimedAmount;
        }

        updateRealizeReward(pid, addr);

        return claimedAmount;
    }

    function addPool(uint256 pid) internal {
        require(maxPid < 10, "Staking: Cannot add more than 10 pools!");

        ( uint256 poolShare,, uint256 tokenPerShare,,, uint256 tokenRewarded,, ) = parent.poolInfo(pid);

        poolInfo.push(PoolInfo({
            poolShare: poolShare,
            lastBlock: 0,
            tokenPerShare: tokenPerShare,
            tokenRewarded: tokenRewarded,
            realTokenPerShare: 0,
            realTokenReceived: 0,
            realTokenRewarded: 0
        }));
        maxPid++;
    }

    function updatePool(uint256 pid) internal {
        if (pid >= maxPid) {
            return;
        }
        if (startBlock == 0 || block.number < startBlock) {
            return;
        }
        PoolInfo storage pool = poolInfo[pid];
        if (pool.lastBlock == 0) {
            pool.lastBlock = startBlock;
        }
        uint256 lastRewardBlock = getLastRewardBlock();
        if (lastRewardBlock <= pool.lastBlock) {
            return;
        }
        ( , uint256 lastBlock, uint256 supTokenPerShare, uint256 tokenRealStaked,, uint256 supTokenRewarded,, ) = parent.poolInfo(pid);

        if (tokenRealStaked == 0) {
            return;
        }

        uint256 multiplier = lastRewardBlock - pool.lastBlock;
        uint256 divisor = lastBlock - pool.lastBlock;

        uint256 tokenRewarded = supTokenRewarded - pool.tokenRewarded;
        uint256 tokenPerShare = supTokenPerShare - pool.tokenPerShare;
        if (multiplier != divisor) {
            tokenRewarded = tokenRewarded * multiplier / divisor;
            tokenPerShare = tokenPerShare * multiplier / divisor;
        }
        pool.tokenRewarded = pool.tokenRewarded + tokenRewarded;
        pool.tokenPerShare = pool.tokenPerShare + tokenPerShare;

        pool.realTokenRewarded = pool.realTokenRewarded + (tokenRewarded * tokenPerBlock / tokenParentPrecision);
        pool.realTokenPerShare = pool.realTokenPerShare + (tokenPerShare * tokenPerBlock);
        pool.lastBlock = lastRewardBlock;
    }

    function updatePendingReward(uint256 pid, address addr) internal {
        if (pid >= maxPid) {
            return;
        }
        PoolInfo storage pool = poolInfo[pid];
        UserInfo storage user = userInfo[pid][addr];
        ( uint256 amount,,,, ) = parent.userInfo(pid, addr);

        uint256 reward;
        reward = amount * pool.realTokenPerShare / 1e12 / tokenParentPrecision - user.rewardDebt;
        if (reward > 0) {
            user.pendingRewards = user.pendingRewards + reward;
            user.rewardDebt = user.rewardDebt + reward;
        }
    }

    function updateRealizeReward(uint256 pid, address addr) internal {
        if (pid >= maxPid) {
            return;
        }
        ( uint256 amount,,,, ) = parent.userInfo(pid, addr);
        return updateRealizeReward(pid, addr, amount);
    }

    function updateRealizeReward(uint256 pid, address addr, uint256 amount) internal {
        if (pid >= maxPid) {
            return;
        }
        PoolInfo storage pool = poolInfo[pid];
        UserInfo storage user = userInfo[pid][addr];

        uint256 reward;
        reward = amount * pool.realTokenPerShare / 1e12 / tokenParentPrecision;
        user.rewardDebt = reward;
    }

    function transferPendingRewards(uint256 pid, address to, uint256 amount) internal returns (uint256) {
        if (pid >= maxPid) {
            return 0;
        }
        if (amount == 0) {
            return 0;
        }
        uint256 tokenAmount = token.balanceOf(address(parent));
        if (tokenAmount != 0 && address(token) == address(parent.token())) {
            for (uint i=0; i<maxPid && tokenAmount > 0; i++) {
                ( ,,, uint256 tokenRealStaked,,,, ) = parent.poolInfo(i);
                tokenAmount = (tokenRealStaked >= tokenAmount) ? 0 : tokenAmount - tokenRealStaked;
            }
        }
        if (tokenAmount == 0) {
            return 0;
        }
        if (tokenAmount > amount) {
            tokenAmount = amount;
        }
        token.safeTransferFrom(address(parent), to, tokenAmount);
        return tokenAmount;
    }

    function getLastRewardBlock() internal view returns (uint256) {
        if (startBlock == 0) return 0;
        if (closeBlock != 0 && closeBlock < block.number) return closeBlock;
        return block.number;
    }
}

// File: contracts/Staking/IStakingDelegate.sol

pragma solidity =0.8.6;

abstract contract IStakingDelegate {
    function balanceChanged(address user, uint256 amount) external virtual;
}

// File: contracts/Staking/StakingV3.sol

pragma solidity =0.8.6;

/**
 * @title Token Staking
 * @dev BEP20 compatible token.
 */
contract StakingV3 is Ownable {
    using SafeERC20 for IERC20;

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant MAINTAINER_ROLE = keccak256("MAINTAINER_ROLE");

    struct UserInfo {
        uint256 amount;
        uint256 rewardDebt; // backwards compatibility
        uint256 pendingRewards; // backwards compatibility
        uint256 lockedTimestamp;
        uint256 lockupTimestamp;
    }

    struct PoolInfo {
        uint256 poolShare;
        uint256 lastBlock;
        uint256 tokenPerShare;
        uint256 tokenRealStaked;
        uint256 tokenReceived;
        uint256 tokenRewarded;
        uint256 tokenTotalLimit;
        uint256 lockupTimerange;
    }

    IERC20 public token;

    uint256 public tokenPerBlock; // backwards compatibility
    uint256 public startBlock;
    uint256 public closeBlock;
    uint256 public totalPoolShare;
    uint256 public maxPid;
    uint256 private constant MAX = ~uint256(0);

    PoolInfo[] public poolInfo;
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    mapping(address => address) public dealerInfo;
    address[] public dealers;
    address[] public delistedDealers;

    IStakingDelegate public delegate;

    event PoolAdded(uint256 share, uint256 timer, uint256 limit);
    event Deposited(address indexed user, uint256 indexed pid, address indexed token, uint256 amount);
    event Withdrawn(address indexed user, uint256 indexed pid, address indexed token, uint256 amount);
    event WithdrawnReward(address indexed user, uint256 indexed pid, address indexed token, uint256 amount);
    event WithdrawnRemain(address indexed user, uint256 indexed pid, address indexed token, uint256 amount);
    event TokenDealerChanged(address indexed token, address indexed dealer);
    event TokenAddressChanged(address indexed token);
    event DelegateAddressChanged(address indexed addr);

    event StartBlockChanged(uint256 block);
    event CloseBlockChanged(uint256 block);

    constructor(uint256[] memory poolShare, uint256[] memory poolTimer, uint256[] memory poolLimit) {
        require(poolShare.length == poolTimer.length, "Staking: Invalid constructor parameters set!");
        require(poolTimer.length == poolLimit.length, "Staking: Invalid constructor parameters set!");

        for (uint i=0; i<poolShare.length; i++) {
            addPool(poolShare[i], poolTimer[i], poolLimit[i]);
        }
        tokenPerBlock = 1e18; // in this interface tokenPerBlock serves purpose as a precision gadget
    }

    function setTokenAddress(IERC20 _token) public onlyOwner {
        require(address(_token) != address(0), "Staking: token address needs to be different than zero!");
        require(address(token) == address(0), "Staking: tokens already set!");
        token = _token;
        emit TokenAddressChanged(address(token));
    }

    function setTokenPerBlock(IERC20 _token, uint256 _tokenPerBlock) public onlyOwner {
        require(startBlock != 0, "Staking: cannot add reward before setting start block");
        require(address(_token) != address(0), "Staking: token address needs to be different than zero!");

        address addr = dealerInfo[address(_token)];
        if (addr != address(0)) {
            StakingV3Dealer dealer = StakingV3Dealer(addr);
            uint256 _closeBlock = dealer.closeBlock();
            if (_closeBlock == 0 || block.number <= _closeBlock) {
                for (uint i=0; i<maxPid; i++) updatePool(i);
                _token.approve(address(dealer), MAX);
                dealer.setTokenPerBlock(_tokenPerBlock, dealer.startBlock(), dealer.closeBlock());
                return;
            }
        }

        setTokenPerBlock(_token, _tokenPerBlock, 0);
    }

    function setTokenPerBlock(IERC20 _token, uint256 _tokenPerBlock, uint256 _blockRange) public onlyOwner {
        require(startBlock != 0, "Staking: cannot add reward before setting start block");
        require(address(_token) != address(0), "Staking: token address needs to be different than zero!");

        address addr = dealerInfo[address(_token)];
        uint256 _startBlock = block.number > startBlock ? block.number : startBlock;
        uint256 _closeBlock = _blockRange == 0 ? 0 : _startBlock + _blockRange;

        if (addr != address(0)) {
            _startBlock = StakingV3Dealer(addr).startBlock();
        }

        setTokenPerBlock(_token, _tokenPerBlock, _startBlock, _closeBlock);
    }

    function setTokenPerBlock(IERC20 _token, uint256 _tokenPerBlock, uint256 _startBlock, uint256 _closeBlock) public onlyOwner {
        require(startBlock != 0, "Staking: cannot add reward before setting start block");
        require(_startBlock >= startBlock, "Staking: token start block needs to be different than zero!");
        require(_closeBlock > _startBlock || _closeBlock == 0, "Staking: token close block needs to be higher than start block!");
        require(address(_token) != address(0), "Staking: token address needs to be different than zero!");

        for (uint i=0; i<maxPid; i++) {
            updatePool(i);
        }

        address addr = dealerInfo[address(_token)];
        StakingV3Dealer dealer;

        if (addr != address(0)) {
            dealer = StakingV3Dealer(addr);
            uint256 _prevStartBlock = dealer.startBlock();
            uint256 _prevCloseBlock = dealer.closeBlock();

            if (_prevCloseBlock == 0 || block.number <= _prevCloseBlock) {
                require(_startBlock == _prevStartBlock || block.number < _prevStartBlock,
                    "Staking: token start block cannot be changed");
                _token.approve(address(dealer), MAX);
                dealer.setTokenPerBlock(_tokenPerBlock, _startBlock, _closeBlock);
                return;
            }

            if (_prevCloseBlock != 0 && _prevCloseBlock < _startBlock) {
                addr = address(0);
            }
        }

        if (addr == address(0)) {
            updateDealers();
            require(dealers.length < 20, "Staking: limit of actively distributed tokens reached");

            dealer = new StakingV3Dealer(address(this), _token);
            _token.approve(address(dealer), MAX);
            dealer.setTokenPerBlock(_tokenPerBlock, _startBlock, _closeBlock);

            dealerInfo[address(_token)] = address(dealer);
            dealers.push(address(_token));
            emit TokenDealerChanged(address(_token), address(dealer));
            return;
        }

        revert("Staking: invalid configuration provided");
    }

    function setStartBlock(uint256 _startBlock) public onlyOwner {
        require(startBlock == 0 || startBlock > block.number, "Staking: start block already set");
        require(_startBlock > 0, "Staking: start block needs to be higher than zero!");
        startBlock = _startBlock;

        StakingV3Dealer dealer;
        for (uint i=0; i<dealers.length; i++) {
            dealer = StakingV3Dealer(dealerInfo[dealers[i]]);
            if (dealer.startBlock() == 0 || dealer.startBlock() < startBlock) dealer.setStartBlock(startBlock);
        }
        emit StartBlockChanged(startBlock);
    }

    function setCloseBlock(uint256 _closeBlock) public onlyOwner {
        require(startBlock != 0, "Staking: start block needs to be set first");
        require(closeBlock == 0 || closeBlock > block.number, "Staking: close block already set");
        require(_closeBlock > startBlock, "Staking: close block needs to be higher than start one!");
        closeBlock = _closeBlock;

        StakingV3Dealer dealer;
        for (uint i=0; i<dealers.length; i++) {
            dealer = StakingV3Dealer(dealerInfo[dealers[i]]);
            if (dealer.closeBlock() == 0 || dealer.closeBlock() > closeBlock) dealer.setCloseBlock(closeBlock);
        }
        emit CloseBlockChanged(closeBlock);
    }

    function setDelegateAddress(IStakingDelegate _delegate) public onlyOwner {
        require(address(_delegate) != address(0), "Staking: delegate address needs to be different than zero!");
        delegate = _delegate;
        emit DelegateAddressChanged(address(delegate));
    }

    function withdrawRemaining() public onlyOwner {
        for (uint i=0; i<dealers.length; i++) withdrawRemaining(dealers[i]);
    }

    function withdrawRemaining(address asset) public onlyOwner {
        require(startBlock != 0, "Staking: start block needs to be set first");
        require(closeBlock != 0, "Staking: close block needs to be set first");
        require(block.number > closeBlock, "Staking: withdrawal of remaining funds not ready yet");

        for (uint i=0; i<maxPid; i++) {
            updatePool(i);
        }
        getDealer(asset).withdrawRemaining(owner());
    }

    function pendingRewards(uint256 pid, address addr, address asset) external view returns (uint256) {
        require(pid < maxPid, "Staking: invalid pool ID provided");
        require(startBlock > 0 && block.number >= startBlock, "Staking: not started yet");
        return getDealer(asset).pendingRewards(pid, addr);
    }

    function deposit(uint256 pid, uint256 amount) external {
        return _deposit(pid, msg.sender, msg.sender, amount);
    }

    function deposit(uint256 pid, address addr, uint256 amount) external {
        return _deposit(pid, msg.sender, addr, amount);
    }

    function _deposit(uint256 pid, address from, address addr, uint256 amount) internal {
        // amount eq to zero is allowed
        require(pid < maxPid, "Staking: invalid pool ID provided");
        require(startBlock > 0 && block.number >= startBlock, "Staking: not started yet");
        require(closeBlock == 0 || block.number <= closeBlock,
            "Staking: staking has ended, please withdraw remaining tokens");
        require(from == addr || from == owner(), "Staking: you are unable to deposit funds for this user");

        PoolInfo storage pool = poolInfo[pid];
        UserInfo storage user = userInfo[pid][addr];

        require(pool.tokenTotalLimit == 0 || pool.tokenTotalLimit >= pool.tokenRealStaked + amount,
            "Staking: you cannot deposit over the limit!");

        updatePool(pid);

        for (uint i=0; i<dealers.length; i++) getDealer(dealers[i]).update(pid, addr, user.amount + amount);

        if (amount > 0) {
            user.amount = user.amount + amount;
            pool.tokenRealStaked = pool.tokenRealStaked + amount;
            token.safeTransferFrom(address(from), address(this), amount);
        }
        user.lockedTimestamp = block.timestamp + pool.lockupTimerange;
        user.lockupTimestamp = block.timestamp;
        emit Deposited(addr, pid, address(token), amount);

        if (address(delegate) != address(0)) {
            delegate.balanceChanged(addr, user.amount);
        }
    }

    function withdraw(uint256 pid, uint256 amount) external { // keep this method for backward compatibility
        _withdraw(pid, msg.sender, msg.sender, amount);
    }

    function _withdraw(uint256 pid, address from, address addr, uint256 amount) internal {
        // amount eq to zero is allowed
        require(pid < maxPid, "Staking: invalid pool ID provided");
        require(startBlock > 0 && block.number >= startBlock, "Staking: not started yet");

        PoolInfo storage pool = poolInfo[pid];
        UserInfo storage user = userInfo[pid][from];

        require((addr == address(this)) || (block.timestamp >= user.lockedTimestamp)
            || (closeBlock > 0 && closeBlock <= block.number), "Staking: you cannot withdraw yet!");
        require(user.amount >= amount, "Staking: you cannot withdraw more than you have!");

        updatePool(pid);

        for (uint i=0; i<dealers.length; i++) getDealer(dealers[i]).update(pid, from, user.amount - amount);

        if (amount > 0) {
            user.amount = user.amount - amount;
            pool.tokenRealStaked = pool.tokenRealStaked - amount;
            if (addr != address(this)) token.safeTransfer(address(addr), amount);
        }
        user.lockedTimestamp = 0;
        user.lockupTimestamp = 0;
        emit Withdrawn(from, pid, address(token), amount);

        if (address(delegate) != address(0)) {
            delegate.balanceChanged(from, user.amount);
        }
    }

    function claim(uint256 pid) public {
        for (uint i=0; i<dealers.length; i++) claim(pid, dealers[i]);
    }

    function claim(uint256 pid, address asset) public {
        claimFromDealer(pid, address(getDealer(asset)));
    }

    function claimFromDealer(uint256 pid, address addr) public {
        require(pid < maxPid, "Staking: invalid pool ID provided");
        require(startBlock > 0 && block.number >= startBlock, "Staking: not started yet");
        updatePool(pid);
        StakingV3Dealer(addr).claim(pid, msg.sender);
    }

    function addPool(uint256 _poolShare, uint256 _lockupTimerange, uint256 _tokenTotalLimit) internal {
        require(_poolShare > 0, "Staking: Pool share needs to be higher than zero!");
        require(maxPid < 10, "Staking: Cannot add more than 10 pools!");

        poolInfo.push(PoolInfo({
            poolShare: _poolShare,
            lastBlock: 0,
            tokenPerShare: 0,
            tokenRealStaked: 0,
            tokenReceived: 0,
            tokenRewarded: 0,
            tokenTotalLimit: _tokenTotalLimit,
            lockupTimerange: _lockupTimerange
        }));
        totalPoolShare = totalPoolShare + _poolShare;
        maxPid = maxPid + 1;

        emit PoolAdded(_poolShare, _lockupTimerange, _tokenTotalLimit);
    }

    function updatePool(uint256 pid) internal {
        if (pid >= maxPid) {
            return;
        }
        if (startBlock == 0 || block.number < startBlock) {
            return;
        }
        PoolInfo storage pool = poolInfo[pid];
        if (pool.lastBlock == 0) {
            pool.lastBlock = startBlock;
        }
        uint256 lastBlock = getLastRewardBlock();
        if (lastBlock <= pool.lastBlock) {
            return;
        }
        uint256 poolTokenRealStaked = pool.tokenRealStaked;
        if (poolTokenRealStaked == 0) {
            return;
        }
        uint256 multiplier = lastBlock - pool.lastBlock;
        uint256 tokenAward = multiplier * tokenPerBlock * pool.poolShare / totalPoolShare;
        pool.tokenRewarded = pool.tokenRewarded + tokenAward;
        pool.tokenPerShare = pool.tokenPerShare + (tokenAward * 1e12 / poolTokenRealStaked);
        pool.lastBlock = lastBlock;
    }

    function updateDealers() public {
        require(msg.sender == address(this) || msg.sender == owner(),
            "Staking: this method can only be called internally or by owner");
        address[] memory _newDealers = new address[](dealers.length);
        uint256 _size;
        address _addr;
        for (uint i=0; i<dealers.length; i++) {
            _addr = dealerInfo[dealers[i]];
            uint256 _closeBlock = StakingV3Dealer(_addr).closeBlock();
            if (_closeBlock != 0 && _closeBlock < block.number) {
                delistedDealers.push(_addr);
            } else {
                _newDealers[_size++] = dealers[i];
            }
        }
        delete dealers;
        for (uint i=0; i<_size; i++) {
            dealers.push(_newDealers[i]);
        }
    }

    function getLastRewardBlock() internal view returns (uint256) {
        if (startBlock == 0) return 0;
        if (closeBlock == 0) return block.number;
        return (closeBlock < block.number) ? closeBlock : block.number;
    }

    function getDealer(address asset) internal view returns (StakingV3Dealer) {
        address addr = dealerInfo[asset];
        require(addr != address(0), "Staking: dealer for this token does not exist");
        return StakingV3Dealer(addr);
    }
}