/**
 *Submitted for verification at BscScan.com on 2022-02-11
*/

//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

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
abstract contract Ownable {
    address private _owner;
    address private _newOwner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function newOwner() public view virtual returns (address) {
        return _newOwner;
    }

    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address transferOwner) public onlyOwner {
        require(transferOwner != newOwner());
        _newOwner = transferOwner;
    }

    function acceptOwnership() virtual public {
        require(msg.sender == newOwner(), "Ownable: caller is not the new owner");
        emit OwnershipTransferred(_owner, _newOwner);
        _owner = _newOwner;
        _newOwner = address(0);
    }
}

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

pragma solidity ^0.8.0;

library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }
    function safeTransfer(address token, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }
    function safeTransferFrom(address token, address from, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }
    function safeTransferBNB(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: BNB_TRANSFER_FAILED');
    }
}

pragma solidity ^0.8.0;

abstract contract RescueManager is Ownable {

    event Rescue(address indexed receiver, uint amount);
    event RescueToken(address indexed receiver, address indexed token, uint amount);

    function rescueBNB(address payable _to, uint256 _amount) external onlyOwner {
        require(_to != address(0), "RescueManager: Cannot rescue to 0x0");
        require(_amount > 0, "RescueManager: Cannot rescue 0");

        _to.transfer(_amount);
        emit Rescue(_to, _amount);
    }

    function rescue(address _to, address _token, uint256 _amount) external onlyOwner {
        require(_to != address(0), "RescueManager: Cannot rescue to 0x0");
        require(_amount > 0, "RescueManager: Cannot rescue 0");
        require(Address.isContract(_token), "RescueManager: _token is not a contract");

        TransferHelper.safeTransfer(_token, _to, _amount);
        emit RescueToken(_to, _token, _amount);
    }
}

pragma solidity ^0.8.0;

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {BEP1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To initialize the implementation contract, you can either invoke the
 * initializer manually, or you can include a constructor to automatically mark it as initialized when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * custom:oz-upgrades-unsafe-allow constructor
 * constructor() initializer {}
 * ```
 * ====
 */
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
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

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
}

pragma solidity ^0.8.0;

contract ReentrancyGuard {
    /// @dev counter to allow mutex lock with only one SSTORE operation
    uint256 private _guardCounter;

    constructor () {
        // The counter starts at one to prevent changing it from zero to a non-zero
        // value, which is a more expensive operation.
        _guardCounter = 1;
    }

    modifier nonReentrant() {
        _guardCounter += 1;
        uint256 localCounter = _guardCounter;
        _;
        require(localCounter == _guardCounter, "ReentrancyGuard: reentrant call");
    }
}

pragma solidity ^0.8.9;

abstract contract FarmingInfoStruct {
    struct FarmingInfo {
        address StakingToken;
        uint Amount;
        uint Pool;
        uint Rate;
        uint CurrentPoolSize;
        uint LockPeriod;
        uint StartTimestamp;
        uint LastClaimRewardTimestamp;
        uint WithdrawTimestamp;
    }
}

pragma solidity ^0.8.9;

abstract contract FarmingPoolStruct {
    struct FarmingPool {
        address StakingToken;
        uint MinRate;
        uint MaxRate;
        uint CurrentPoolSize;
        uint MaxPoolSize;
        uint LockPeriod;
    }
}

pragma solidity ^0.8.9;

abstract contract FarmingObjects is
    FarmingInfoStruct,
    FarmingPoolStruct
{}

pragma solidity ^0.8.9;

contract FarmingStorage is Initializable, ReentrancyGuard, RescueManager, FarmingObjects {
    address internal _implementationAddress;
    uint public version;

    mapping(uint => FarmingPool) public pools;

    mapping(address => uint) public nonces;
    mapping(address => mapping(uint => FarmingInfo)) public farmingInfo;
}

pragma solidity ^0.8.9;

contract Farming is FarmingStorage {
    
    event Stake(address indexed user, uint nonce, uint indexed stakeAmount, uint indexed rate, uint stakeTimestamp);
    event Withdraw(address indexed user, uint nonce, uint indexed withdrawAmount, uint withdrawTimestamp);
    event ClaimReward(address indexed user, uint nonce, uint indexed reward, uint claimRewardTimestamp);
    event UpdatePoolProperties(address indexed stakingToken, uint indexed poolId, uint minRate, uint maxRate, uint maxPoolSize, uint lockPeriod);

    function famingPool(uint id) external view returns (FarmingPool memory) {
        return pools[id];
    }

    function getCurrentPoolRate(uint id) public view returns (uint) {
        FarmingPool memory farmingPool = pools[id];

        if(farmingPool.CurrentPoolSize > farmingPool.MaxPoolSize) {
            return farmingPool.MaxRate;
        } else {
            return farmingPool.MaxRate - (farmingPool.MaxRate * farmingPool.CurrentPoolSize / farmingPool.MaxPoolSize);
        }
    }

    function earned(address user, uint nonce) public view returns (uint) {
        FarmingInfo memory info = farmingInfo[user][nonce];
        require(info.Amount != 0, "Farming: Stake amount is equal to 0");
        require(info.WithdrawTimestamp == 0, "Farming: Stake already withdrawn");
        
        return _earned(info);
    }

    function totalEarned(address user) public view returns (uint) {
        uint total;

        for (uint256 i = 0; i < nonces[user]; i++) {
            FarmingInfo memory info = farmingInfo[user][i];

            if(info.WithdrawTimestamp == 0) {
                total += _earned(info);
            }
        }

        return total;
    }

    function stake(uint amount, uint pool) external nonReentrant {
        _stake(amount, pool);
    }

    function withdrawAndClaimReward(uint nonce) external nonReentrant {
        _claimReward(nonce); 
        _withdraw(nonce);
    }   

    function claimReward(uint nonce) external nonReentrant {
        _claimReward(nonce);
    }

    function claimTotalReward() external nonReentrant {
        for (uint256 i = 0; i < nonces[msg.sender]; i++) {
            FarmingInfo memory info = farmingInfo[msg.sender][i];

            if(info.WithdrawTimestamp == 0) {
                _claimReward(i);
            }
        }
    }

    function updatePoolProperties(address stakingToken, uint poolId, uint minRate, uint maxRate, uint maxPoolSize, uint lockPeriod) external onlyOwner {
        require(Address.isContract(stakingToken), "stakingToken is not a contract");

        pools[poolId].StakingToken = stakingToken;
        pools[poolId].MinRate = minRate;
        pools[poolId].MaxRate = maxRate;
        pools[poolId].MaxPoolSize = maxPoolSize;
        pools[poolId].LockPeriod = lockPeriod;
        emit UpdatePoolProperties(stakingToken, poolId, minRate, maxRate, maxPoolSize, lockPeriod);
    }

    function _stake(uint amount, uint poolId) internal {
        require(amount > 0, "Farming: Stake amount is equal to 0");
        FarmingPool memory farmingPool = pools[poolId];
        require(farmingPool.MinRate != 0, "Farming: pool does not exists");


        uint stakeNonce = nonces[msg.sender]++;
        uint rate = getCurrentPoolRate(poolId);

        FarmingInfo memory info = FarmingInfo(farmingPool.StakingToken, amount, poolId, rate, farmingPool.CurrentPoolSize, farmingPool.LockPeriod, block.timestamp, 0, 0);
        farmingInfo[msg.sender][stakeNonce] = info;

        TransferHelper.safeTransferFrom(farmingPool.StakingToken, msg.sender, address(this), amount);
        pools[poolId].CurrentPoolSize += amount;

        emit Stake(msg.sender, stakeNonce, amount, rate, block.timestamp);
    } 

    function _withdraw(uint nonce) internal {
        FarmingInfo memory info = farmingInfo[msg.sender][nonce];
        require(info.Amount != 0, "Farming: Stake amount is equal to 0");
        require(info.WithdrawTimestamp == 0, "Farming: Stake already withdrawn");
        require(info.StartTimestamp + info.LockPeriod < block.timestamp, "Farming: Stake is locked");

        farmingInfo[msg.sender][nonce].WithdrawTimestamp = block.timestamp;
        pools[info.Pool].CurrentPoolSize -= info.Amount;

        TransferHelper.safeTransfer(pools[info.Pool].StakingToken, msg.sender, info.Amount);
        emit Withdraw(msg.sender, nonce, info.Amount, block.timestamp);
    }

    function _claimReward(uint nonce) internal {
        FarmingInfo memory info = farmingInfo[msg.sender][nonce];
        require(info.Amount != 0, "Farming: Stake amount is equal to 0");
        require(info.WithdrawTimestamp == 0, "Farming: Stake already withdrawn");

        uint reward = earned(msg.sender, nonce);
        farmingInfo[msg.sender][nonce].LastClaimRewardTimestamp = block.timestamp;

        TransferHelper.safeTransfer(pools[info.Pool].StakingToken, msg.sender, reward);
        emit ClaimReward(msg.sender, nonce, reward, block.timestamp);
    }

    function _earned(FarmingInfo memory info) internal view returns (uint) {
        uint endPeriod = info.LastClaimRewardTimestamp != 0 ? info.LastClaimRewardTimestamp : info.StartTimestamp;
        return info.Amount * info.Rate * (block.timestamp - endPeriod) / info.LockPeriod;
    }
}