/**
 *Submitted for verification at BscScan.com on 2022-05-12
*/

// SPDX-License-Identifier: MIT

// MFET - Multi Functional Environmental Token
// We are Developing New Generation Projects and Funding These Projects with Green Blockchain.

// A Sustainable World
// MFET is an ecosystem that supports sustainable projects, provides mentoring to companies in carbon footprint studies,
// provides consultancy on environmental and climate studies, and makes decisions without being dependent on an authority
// with the community it has created, thanks to the blockchain.

// MFET - Farm Contract

// Mens et Manus
pragma solidity ^0.8.0;

interface IBEP20 {
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
    function allowance(address owner, address spender)
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
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
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
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
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

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
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

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
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
        uint256 newAllowance = token.allowance(address(this), spender) + value;
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
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(
                oldAllowance >= value,
                "SafeBEP20: decreased allowance below zero"
            );
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(
                token,
                abi.encodeWithSelector(
                    token.approve.selector,
                    spender,
                    newAllowance
                )
            );
        }
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
                "SafeBEP20: ERC20 operation did not succeed"
            );
        }
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

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

interface IStaking {
    function getDepositedAmount(address user) external view returns (uint256);
}

contract MFETFarm is Ownable, ReentrancyGuard, IStaking {
    using SafeBEP20 for IBEP20;

    struct UserInfo {
        uint256 amount;
        uint256 rewardDebt;
        uint256 pendingRewards;
        uint256 lastClaim;
    }

    struct PoolInfo {
        uint256 allocPoint;
        uint256 lastRewardBlock;
        uint256 accTokenPerShare;
        uint256 depositedAmount;
        uint256 rewardsAmount;
        uint256 lockupDuration;
    }

    IBEP20 public token;
    uint256 public tokenPerBlock = 1 ether; // 1 token
    address public feeAddress = 0xA1793F680903f2a1D1B775d47E54C409ed02e648;

    PoolInfo[] public poolInfo;
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    uint256 public constant totalAllocPoint = 1000;

    uint256 public emergencyWithdrawFee = 250; // 25%

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event Claim(address indexed user, uint256 indexed pid, uint256 amount);
    event RewardPerBlockChanged(uint256 reward);
    event TokenAddressSet(address token);
    event FarmStarted(uint256 pid, uint256 startBlock);
    event PoolAdded(uint256 pid, uint256 allocPoint, uint256 lockupDuration);

    modifier validatePoolByPid(uint256 _pid) {
        require(_pid < poolInfo.length, "MFET : pool does not exist");
        _;
    }

    modifier onlyEOA() {
        require(tx.origin == _msgSender(), "MFET : should be EOA");
        _;
    }

    function setTokenPerBlock(uint256 _tokenPerBlock) external onlyOwner {
        require(
            _tokenPerBlock > 0,
            "MFET : token per block should be greater than 0!"
        );
        tokenPerBlock = _tokenPerBlock;

        emit RewardPerBlockChanged(_tokenPerBlock);
    }

    function setEmergencyWithdrawFee(uint256 _emergencyWithdrawFee)
        external
        onlyOwner
    {
        require(_emergencyWithdrawFee < 1000, "MFET : fee can't be over 99%");
        require(_emergencyWithdrawFee > 0, "MFET : fee can't be 0");

        emergencyWithdrawFee = _emergencyWithdrawFee;
    }

    function setFeeAddress(address _feeAddress) external onlyOwner {
        feeAddress = _feeAddress;
    }

    function pendingRewards(uint256 pid, address _user)
        external
        view
        validatePoolByPid(pid)
        returns (uint256)
    {
        require(_user != address(0), "MFET : invalid user address");
        require(
            poolInfo[pid].lastRewardBlock > 0,
            "MFET : staking not yet started"
        );
        PoolInfo storage pool = poolInfo[pid];
        UserInfo storage user = userInfo[pid][_user];
        uint256 accTokenPerShare = pool.accTokenPerShare;
        uint256 depositedAmount = pool.depositedAmount;
        if (block.number > pool.lastRewardBlock && depositedAmount != 0) {
            uint256 multiplier = block.number - (pool.lastRewardBlock);
            uint256 tokenReward = (multiplier *
                (tokenPerBlock) *
                (pool.allocPoint)) / (totalAllocPoint);
            accTokenPerShare =
                accTokenPerShare +
                ((tokenReward * (1e12)) / (depositedAmount));
        }
        return
            (user.amount * (accTokenPerShare)) /
            (1e12) -
            (user.rewardDebt) +
            (user.pendingRewards);
    }

    function deposit(uint256 pid, uint256 amount)
        external
        validatePoolByPid(pid)
        onlyEOA
    {
        PoolInfo storage pool = poolInfo[pid];
        UserInfo storage user = userInfo[pid][_msgSender()];
        _updatePool(pid);
        if (user.amount > 0) {
            uint256 pending = (user.amount * (pool.accTokenPerShare)) /
                (1e12) -
                (user.rewardDebt);
            if (pending > 0) {
                user.pendingRewards = user.pendingRewards + (pending);
            }
        }
        if (amount > 0) {
            token.safeTransferFrom(
                address(_msgSender()),
                address(this),
                amount
            );
            user.amount = user.amount + (amount);
            pool.depositedAmount = pool.depositedAmount + (amount);
        }
        user.rewardDebt = (user.amount * (pool.accTokenPerShare)) / (1e12);
        user.lastClaim = block.timestamp;
        emit Deposit(_msgSender(), pid, amount);
    }

    function withdraw(
        uint256 pid,
        uint256 amount,
        bool _withdrawRewards
    ) external validatePoolByPid(pid) nonReentrant onlyEOA {
        PoolInfo storage pool = poolInfo[pid];
        UserInfo storage user = userInfo[pid][_msgSender()];
        require(
            block.timestamp > user.lastClaim + pool.lockupDuration,
            "MFET : you cannot withdraw yet!"
        );
        require(
            user.amount >= amount,
            "MFET : you cannot withdraw more than you have!"
        );
        _updatePool(pid);
        uint256 pending = (user.amount * (pool.accTokenPerShare)) /
            (1e12) -
            (user.rewardDebt);
        if (pending > 0) {
            user.pendingRewards = user.pendingRewards + (pending);

            if (_withdrawRewards) {
                user.pendingRewards = 0;
                token.safeTransfer(_msgSender(), user.pendingRewards);
                emit Claim(_msgSender(), pid, user.pendingRewards);
            }
        }
        if (amount > 0) {
            user.amount = user.amount - (amount);
            pool.depositedAmount = pool.depositedAmount - (amount);
            token.safeTransfer(address(_msgSender()), amount);
        }
        user.rewardDebt = (user.amount * (pool.accTokenPerShare)) / (1e12);
        user.lastClaim = block.timestamp;
        emit Withdraw(_msgSender(), pid, amount);
    }

    function emergencyWithdraw(uint256 pid, uint256 amount)
        external
        validatePoolByPid(pid)
        nonReentrant
        onlyEOA
    {
        PoolInfo storage pool = poolInfo[pid];
        UserInfo storage user = userInfo[pid][_msgSender()];

        require(
            user.amount >= amount,
            "MFET : you can not withdraw more than you have!"
        );
        _updatePool(pid);

        user.pendingRewards = 0;
        if (amount > 0) {
            uint256 feeAmount = (amount * (emergencyWithdrawFee)) / 1000; // extract fee
            uint256 amountToTransfer = amount - feeAmount;

            user.amount = user.amount - (amount);
            pool.depositedAmount = pool.depositedAmount - (amount);

            token.safeTransfer(address(_msgSender()), amountToTransfer);
            token.safeTransfer(feeAddress, feeAmount);
        }
        user.rewardDebt = (user.amount * (pool.accTokenPerShare)) / (1e12);
        user.lastClaim = block.timestamp;
        emit Withdraw(_msgSender(), pid, amount);
    }

    function claim(uint256 pid)
        external
        validatePoolByPid(pid)
        nonReentrant
        onlyEOA
    {
        PoolInfo storage pool = poolInfo[pid];
        UserInfo storage user = userInfo[pid][_msgSender()];
        _updatePool(pid);
        uint256 pending = (user.amount * (pool.accTokenPerShare)) /
            (1e12) -
            (user.rewardDebt);
        if (pending > 0 || user.pendingRewards > 0) {
            user.pendingRewards = user.pendingRewards + (pending);
            uint256 claimedAmount = safeTokenTransfer(
                _msgSender(),
                user.pendingRewards,
                pid
            );
            user.pendingRewards = user.pendingRewards - (claimedAmount);
            user.lastClaim = block.timestamp;
            pool.rewardsAmount = pool.rewardsAmount - (claimedAmount);
            emit Claim(_msgSender(), pid, claimedAmount);
        }
        user.rewardDebt = (user.amount * (pool.accTokenPerShare)) / (1e12);
    }

    function safeTokenTransfer(
        address to,
        uint256 amount,
        uint256 pid
    ) internal returns (uint256) {
        PoolInfo memory pool = poolInfo[pid];
        if (amount > pool.rewardsAmount) {
            token.safeTransfer(to, pool.rewardsAmount);
            return pool.rewardsAmount;
        } else {
            token.safeTransfer(to, amount);
            return amount;
        }
    }

    function getDepositedAmount(address user)
        external
        view
        override
        returns (uint256)
    {
        uint256 amount = 0;
        for (uint256 index = 0; index < poolInfo.length; index++) {
            amount = amount + userInfo[index][user].amount;
        }
        return amount;
    }

    function RecoverBEP20(IBEP20 _token, uint256 amount) external onlyOwner {
        _token.safeTransfer(_msgSender(), amount);
    }

    function setToken(IBEP20 _token, uint256 poolDays) external onlyOwner {
        require(address(token) == address(0), "MFET : token already set!");
        require(address(_token) != address(0), "MFET : invalid Token Address");

        token = IBEP20(_token);

        emit TokenAddressSet(address(token));

        _addPool(1000, poolDays);
    }

    function startFarming(uint256 _startBlock) external onlyOwner {
        require(
            poolInfo[0].lastRewardBlock == 0,
            "MFET : staking already started"
        );
        poolInfo[0].lastRewardBlock = _startBlock;
        emit FarmStarted(0, _startBlock);
    }

    function _addPool(uint256 _allocPoint, uint256 _lockupDuration) internal {
        uint256 pid = poolInfo.length;
        poolInfo.push(
            PoolInfo({
                allocPoint: _allocPoint,
                lastRewardBlock: 0,
                accTokenPerShare: 0,
                depositedAmount: 0,
                rewardsAmount: 0,
                lockupDuration: _lockupDuration * 1 days
            })
        );
        emit PoolAdded(pid, _allocPoint, _lockupDuration);
    }

    function _updatePool(uint256 pid) internal validatePoolByPid(pid) {
        require(
            poolInfo[pid].lastRewardBlock > 0,
            "MFET : staking not yet started"
        );
        PoolInfo storage pool = poolInfo[pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        uint256 depositedAmount = pool.depositedAmount;
        if (pool.depositedAmount == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        uint256 multiplier = block.number - (pool.lastRewardBlock);
        uint256 tokenReward = (multiplier *
            (tokenPerBlock) *
            (pool.allocPoint)) / (totalAllocPoint);
        pool.rewardsAmount = pool.rewardsAmount + (tokenReward);
        pool.accTokenPerShare =
            pool.accTokenPerShare +
            ((tokenReward * (1e12)) / (depositedAmount));
        pool.lastRewardBlock = block.number;
    }
}