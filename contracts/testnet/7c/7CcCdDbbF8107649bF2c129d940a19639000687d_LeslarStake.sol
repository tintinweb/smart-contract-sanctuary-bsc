// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./SafeBEP20.sol";

contract LeslarStake {
    using SafeBEP20 for IBEP20;

    struct UserInfo {
        uint256 amount;
        uint256 rewardDebt;
        uint256 pendingReward;
    }

    struct PoolInfo {
        IBEP20 lpToken;            // Address of LP token contract.
        uint256 allocPoint;        // How many allocation points assigned to this pool. Tokens to distribute per block.
        uint256 lastRewardBlock;   // Last block number that reward distribution occurs.
        uint256 accTokenPerShare;  // Accumulated token per share, times 1e12.
        uint256 totalLp;           // Total Token in Pool
    }

    PoolInfo[] public poolInfo;
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    IBEP20 public constant LESLAR = IBEP20(0x638cFaf7932B8d14094AD37D5C46ACd04355c31F);

    address public owner;
    uint256 public tokenPerBlock;
    uint256 public bonusMultiplier = 1;
    uint256 public totalAllocPoint;
    uint256 public startBlock;
    uint256 public totalTokensInPools;
    address[] teamMembers;

    event SetOwner(address oldOwner, address newOwner);
    event SetTeamMembers(address[] oldMembers, address[] newMembers);
    event StartFarming(uint256 timestamp);
    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyRewardWithdraw(uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event UpdatePoolAlloc(uint256 indexed pid, uint256 previous, uint256 newValue);
    event UpdateRewardRate(uint256 previous, uint256 newValue);
    event UpdateMultiplier(uint256 previous, uint256 newValue);

    modifier onlyOwner() {
        require(owner == msg.sender, "Unauthorized caller");
        _;
    }

    modifier onlyTeam() {
        bool isTeamMember;
        for (uint256 i; i < teamMembers.length; i++) {
            if (msg.sender == teamMembers[i]) { isTeamMember = true; break; }
        }
        require(isTeamMember, "Unauthorized caller");
        _;
    }

    constructor() {
        // Set value in the future because start will be triggered manually by calling startFarming().
        startBlock = block.number + 28800 * 365;

        tokenPerBlock = 1 * 10**8;
        owner = msg.sender;
    }

    // Public

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    function getUserAmount(uint256 _pid, address _user) public view returns (uint256) {
        UserInfo storage user = userInfo[_pid][_user];

        return user.amount;
    }

    function remainingRewards() external view returns (uint256) {
        return LESLAR.balanceOf(address(this)) - totalTokensInPools;
    }

    function getMultiplier(uint256 _from, uint256 _to) public view returns (uint256) {
        return (_to - _from) * bonusMultiplier;
    }

    function pendingRewards(uint256 _pid, address _user) external view returns (uint256) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];

        uint256 accTokenPerShare = pool.accTokenPerShare;
        uint256 lpSupply = pool.totalLp;
        uint256 lastRewardBlock = pool.lastRewardBlock;

        if (block.number > lastRewardBlock && lpSupply != 0) {
            uint256 multiplier = getMultiplier(lastRewardBlock, block.number);
            uint256 reward = multiplier * tokenPerBlock * pool.allocPoint / totalAllocPoint;
            accTokenPerShare += reward * 1e12 / lpSupply;
        }

        return user.amount * accTokenPerShare / 1e12 + user.pendingReward - user.rewardDebt;
    }

    function massUpdatePools() public {
        uint256 length = poolInfo.length;

        for (uint256 pid = 0; pid < length; ++pid) {
            PoolInfo storage pool = poolInfo[pid];
            if (block.number <= pool.lastRewardBlock) {
                continue;
            }

            if (pool.totalLp == 0 || pool.allocPoint == 0) {
                pool.lastRewardBlock = block.number;
                continue;
            }

            uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
            uint256 reward = multiplier * tokenPerBlock * pool.allocPoint / totalAllocPoint;

            pool.accTokenPerShare += reward * 1e12 / pool.totalLp;
            pool.lastRewardBlock = block.number;
        }
    }

    function updatePool(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }

        if (pool.totalLp == 0 || pool.allocPoint == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }

        uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
        uint256 reward = multiplier * tokenPerBlock * pool.allocPoint / totalAllocPoint;

        pool.accTokenPerShare += reward * 1e12 / pool.totalLp;
        pool.lastRewardBlock = block.number;
    }

    function deposit(uint256 _pid, uint256 _amount) public {
        require(block.number >= startBlock, "Can not deposit before farm start");

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];

        updatePool(_pid);

        if (user.amount > 0) {
            uint256 pending = user.amount * pool.accTokenPerShare / 1e12 - user.rewardDebt;
            if(pending > 0) {
                user.pendingReward += pending;
                // safeTokenTransfer(msg.sender, pending);
            }
        }

        if (_amount > 0) {
            uint256 beforeDeposit = pool.lpToken.balanceOf(address(this));
            pool.lpToken.safeTransferFrom(address(msg.sender), address(this), _amount);
            uint256 afterDeposit = pool.lpToken.balanceOf(address(this));
            _amount = afterDeposit - beforeDeposit;

            user.amount += _amount;
            pool.totalLp += _amount;

            if (address(pool.lpToken) == address(LESLAR)) {
                totalTokensInPools += _amount;
            }
        }

        user.rewardDebt = user.amount * pool.accTokenPerShare / 1e12;
        emit Deposit(msg.sender, _pid, _amount);
    }

    function withdraw(uint256 _pid, uint256 _amount) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];

        require(user.amount >= _amount, "User amount not enough");
        require(pool.totalLp >= _amount, "Pool total LP not enough");

        updatePool(_pid);

        uint256 pending = user.amount * pool.accTokenPerShare / 1e12  + user.pendingReward - user.rewardDebt;
        if(pending > 0) {
            safeTokenTransfer(msg.sender, pending);
        }

        // if (_amount > 0) {
        //     user.amount -= _amount;
        //     pool.totalLp -= _amount;
        //     if (address(pool.lpToken) == address(LESLAR)) {
        //         totalTokensInPools -= _amount;
        //     }
        //     pool.lpToken.safeTransfer(address(msg.sender), _amount);
        // }
        user.pendingReward = 0;
        user.rewardDebt = user.amount * pool.accTokenPerShare / 1e12;
        emit Withdraw(msg.sender, _pid, _amount);
    }

    function emergencyWithdraw(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];

        uint256 amount = user.amount;
        require(pool.totalLp >= amount, "Pool total LP not enough");

        user.amount = 0;
        user.rewardDebt = 0;
        pool.totalLp -= amount;
        if (address(pool.lpToken) == address(LESLAR)) {
            totalTokensInPools -= amount;
        }
        pool.lpToken.safeTransfer(address(msg.sender), amount);

        emit EmergencyWithdraw(msg.sender, _pid, amount);
    }

    function unstake(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];

        updatePool(_pid);
        uint256 pending = user.amount * pool.accTokenPerShare / 1e12  + user.pendingReward - user.rewardDebt;
        user.pendingReward = pending;
        uint256 amount = user.amount;
        if (amount > 0) {
            user.amount -= amount;
            pool.totalLp -= amount;
            if (address(pool.lpToken) == address(LESLAR)) {
                totalTokensInPools -= amount;
            }
            pool.lpToken.safeTransfer(address(msg.sender), amount);
        }
        user.rewardDebt = user.amount * pool.accTokenPerShare / 1e12;
    }

    // Private

    function safeTokenTransfer(address _to, uint256 _amount) private {
        uint256 balance = LESLAR.balanceOf(address(this));
        if (balance > totalTokensInPools) {
            uint256 rewardBalance = balance - totalTokensInPools;
            if (_amount >= rewardBalance) {
                LESLAR.transfer(_to, rewardBalance);
            } else if (_amount > 0) {
                LESLAR.transfer(_to, _amount);
            }
        }
    }

    // Maintenance

    function emergencyRewardWithdraw() external onlyOwner {
        uint256 rewardAmount = LESLAR.balanceOf(address(this)) - totalTokensInPools;
        LESLAR.transfer(msg.sender, rewardAmount);
        emit EmergencyRewardWithdraw(rewardAmount);
    }

    function setOwner(address newOwner) external onlyOwner {
        emit SetOwner(owner, newOwner);
        owner = newOwner;
    }

    function setTeamMembers(address[] calldata members) external onlyOwner {
        emit SetTeamMembers(teamMembers, members);
        teamMembers = members;
    }

    function startFarming() public onlyOwner {
        require(block.number < startBlock, "Farm started already");

        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            PoolInfo storage pool = poolInfo[pid];
            pool.lastRewardBlock = block.number;
        }

        startBlock = block.number;
        emit StartFarming(startBlock);
    }

    function addPool(uint256 _allocPoint, IBEP20 _lpToken, bool _withUpdate) external onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardBlock = block.number > startBlock ? block.number : startBlock;
        totalAllocPoint += _allocPoint;
        poolInfo.push(
            PoolInfo({
                lpToken: _lpToken,
                allocPoint: _allocPoint,
                lastRewardBlock: lastRewardBlock,
                accTokenPerShare: 0,
                totalLp: 0
            })
        );
    }

    function updatePool(uint256 _pid, uint256 _allocPoint, bool _withUpdate) external onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        totalAllocPoint = totalAllocPoint - poolInfo[_pid].allocPoint + _allocPoint;
        emit UpdatePoolAlloc(_pid, poolInfo[_pid].allocPoint, _allocPoint);
        poolInfo[_pid].allocPoint = _allocPoint;
    }

    function setMultiplier(uint256 _multiplier) external onlyOwner {
        emit UpdateMultiplier(bonusMultiplier, _multiplier);
        bonusMultiplier = _multiplier;
    }

    function updateRewardRate(uint256 _tokenPerBlock) public onlyTeam {
        massUpdatePools();
        emit UpdateRewardRate(tokenPerBlock, _tokenPerBlock);
        tokenPerBlock = _tokenPerBlock;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./Address.sol";
import "./interface/IBEP20.sol";

/**
 * @title SafeBEP20
 * @dev Wrappers around BEP20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeBEP20 for BEP20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeBEP20 {
    using Address for address;

    function safeTransfer(
        IBEP20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IBEP20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {BEP20-approve}, and its usage is discouraged.
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
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeBEP20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeBEP20: decreased allowance below zero");
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
    function _callOptionalReturn(IBEP20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeBEP20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeBEP20: BEP20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IBEP20 {
  function totalSupply() external view returns (uint256);
  function decimals() external view returns (uint8);
  function symbol() external view returns (string memory);
  function name() external view returns (string memory);
  function getOwner() external view returns (address);
  function balanceOf(address account) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function allowance(address _owner, address spender) external view returns (uint256);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}