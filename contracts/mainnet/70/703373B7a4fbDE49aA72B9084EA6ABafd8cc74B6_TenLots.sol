// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "./IcTToken.sol";
import "./ITenFarm.sol";
import "./IPancakePair.sol";

contract TenLots is
    Initializable,
    OwnableUpgradeable,
    PausableUpgradeable,
    ReentrancyGuardUpgradeable
{
    using SafeMathUpgradeable for uint256;
    using SafeERC20Upgradeable for IERC20Upgradeable;
    using AddressUpgradeable for address;

    struct UserInfo {
        uint256 balance;
        uint256 timestamp;
        uint256 level;
        uint256 claimTimeStamp;
        uint256 pendingFee;
        uint256 rewardDebt;
    }

    struct Levels {
        uint256 sharePercent;
        uint256 minBalance;
        uint256 maxBalance;
        uint256 userCount;
        uint256 maxAllowedUser;
    }

    Levels[] public levels;

    struct VestingPeriods {
        uint256 minVestingPeriod;
        uint256 maxVestingPeriod;
        uint256 rewardAllocation;
    }

    VestingPeriods[] public vestingPeriods;

    uint8 public singleStakingVault;
    uint256 public coolDownPeriod;
    uint256[] public pID;
    uint256 public totalStaked;
    uint256 public totalPenalties;
    uint256 public precisionMultiplier;

    bool public cTTokenSet;

    address public _supplier;
    address public tenfi;
    address public cTToken;
    address public BUSD;
    address public tenFarm;
    address public tenFinance;
    address[] public LP;
    address[] public registeredUsers;

    mapping(address => UserInfo) public enterStakingStats;
    mapping(address => bool) public userEntered;
    mapping(address => uint256) public index;
    mapping(uint256 => uint256) public accRewardPerLot;
    mapping(address => uint256) public userPenalty;
    mapping(address => bool) public userAllowed;

    event StakingEntered(address indexed user, uint256 indexed timestamp);
    event RewardClaim(address indexed user, uint256 indexed reward);

    modifier onlySupplier() {
        require(_supplier == _msgSender(), "TenLots : caller != supplier");
        _;
    }

    /**
     * @notice Function to initialize the TenLots contract via hardhat proxy plugin script.
     * @dev It sets the owner to the deployer of the proxy contract.
     * @dev It sets the pausable state to false.
     * @param _singleStakingVault The pid of the vault to be used for staking.
     * @param _coolDownPeriod The cool down period withdrawing from the farm.
     * @param _precisionMultiplier The precision multiplier for certain calculations (1e40).
     * @param _tenfi The address of the TenFi token.
     * @param _BUSD The address of the BUSD token.
     * @param _tenFarm The address of the TenFarm contract.
     * @param _tenFinance The address of the TenFinance contract.
     */
    function initialize(
        uint8 _singleStakingVault,
        uint256 _coolDownPeriod,
        uint256 _precisionMultiplier,
        address _tenfi,
        address _BUSD,
        address _tenFarm,
        address _tenFinance
    ) external initializer {
        __Ownable_init();
        __Pausable_init();
        singleStakingVault = _singleStakingVault;
        coolDownPeriod = _coolDownPeriod;
        precisionMultiplier = _precisionMultiplier;
        tenfi = _tenfi;
        BUSD = _BUSD;
        tenFarm = _tenFarm;
        tenFinance = _tenFinance;
    }

    /**
     * @notice Function to let the eligible user to enter into staking.
     * @dev It checks for the staked balance in the respective vaults
     * and also the supplied balance in the lending platform.
     */
    function enterStaking() external whenNotPaused nonReentrant {
        require(!userEntered[msg.sender], "TenLots : One TenLot per user");

        uint256 _balance = getBalance(msg.sender);

        for (uint8 i = 0; i < levels.length; ++i) {
            require(
                levels[i].userCount <= levels[i].maxAllowedUser,
                "Error: maxAllowedUser limit reached"
            );
            uint256 balance_ = _balance.div(precisionMultiplier);
            if (
                balance_ >= levels[i].minBalance &&
                balance_ < levels[i].maxBalance
            ) {
                enterStakingStats[msg.sender] = UserInfo({
                    balance: balance_,
                    timestamp: block.timestamp,
                    level: i,
                    claimTimeStamp: 0,
                    pendingFee: 0,
                    rewardDebt: accRewardPerLot[i]
                });
                totalStaked += balance_;
                levels[i].userCount++;
                userEntered[msg.sender] = true;
                registeredUsers.push(msg.sender);
                index[msg.sender] = registeredUsers.length - 1;
                break;
            }
        }
        emit StakingEntered(msg.sender, block.timestamp);
    }

    /**
     * @notice Function to claim the user's rewards based on the vesting period.
     */
    function claim() external payable whenNotPaused {
        require(userAllowed[msg.sender], "TenLots : User not allowed");
        require(
            msg.value >= enterStakingStats[msg.sender].pendingFee,
            "TenLots : claim fees"
        );

        uint256 vestedPeriod = block.timestamp.sub(
            enterStakingStats[msg.sender].timestamp
        );

        for (uint8 i = 0; i < vestingPeriods.length; ++i) {
            if (
                (vestedPeriod >= vestingPeriods[i].minVestingPeriod &&
                    vestedPeriod < vestingPeriods[i].maxVestingPeriod)
            ) {
                uint256 userReward = userRewardPerLot(msg.sender);
                uint256 userActualShare = userReward
                    .mul(vestingPeriods[i].rewardAllocation)
                    .div(1000);
                uint256 TenfinanceShare = userReward.sub(userActualShare);

                levels[enterStakingStats[msg.sender].level].userCount--;
                userEntered[msg.sender] = false;

                totalStaked -= enterStakingStats[msg.sender].balance;

                IERC20Upgradeable(BUSD).safeTransfer(
                    msg.sender,
                    userActualShare
                );
                IERC20Upgradeable(BUSD).safeTransfer(
                    tenFinance,
                    TenfinanceShare
                );
                AddressUpgradeable.sendValue(payable(owner()), msg.value);
                uint256 pos = index[msg.sender];
                registeredUsers[pos] = registeredUsers[
                    registeredUsers.length - 1
                ];
                registeredUsers.pop();
                delete (index[msg.sender]);
                delete (enterStakingStats[msg.sender]);

                emit RewardClaim(msg.sender, userActualShare);
                break;
            } else if (
                vestedPeriod >
                vestingPeriods[vestingPeriods.length.sub(1)].maxVestingPeriod
            ) {
                uint256 userReward = userRewardPerLot(msg.sender);
                levels[enterStakingStats[msg.sender].level].userCount--;
                userEntered[msg.sender] = false;

                totalStaked -= enterStakingStats[msg.sender].balance;

                IERC20Upgradeable(BUSD).safeTransfer(msg.sender, userReward);
                uint256 pos = index[msg.sender];
                registeredUsers[pos] = registeredUsers[
                    registeredUsers.length - 1
                ];
                registeredUsers.pop();
                delete (index[msg.sender]);
                delete (enterStakingStats[msg.sender]);

                emit RewardClaim(msg.sender, userReward);
                break;
            }
        }
    }

    /**
     * @notice Function to edit the cool down period.
     */
    function editCoolDownPeriod(uint256 time) external onlyOwner {
        coolDownPeriod = time;
    }

    /**
     * @notice Function to the set/change the supplier of the BUSD token.
     * @dev The address refers to the TransferReward contract.
     */
    function changeSupplier(address supplier) external onlyOwner {
        require(supplier != address(0), "TenLots : zero address");
        _supplier = supplier;
    }

    /**
     * @notice Function to update the accumulated reward per lot for the users.
     */
    function updateAccPerShare(uint256 amount) external onlySupplier {
        IERC20Upgradeable(BUSD).safeTransferFrom(
            msg.sender,
            address(this),
            amount
        );
        for (uint8 i = 0; i < levels.length; ++i) {
            if (levels[i].userCount > 0) {
                accRewardPerLot[i] += amount
                    .mul(levels[i].sharePercent)
                    .div(levels[i].userCount)
                    .div(1000);
            }
        }
    }

    /**
     * @notice Function to add the details of each vesting period.
     * @param _minVestingPeriod - The minimum vesting period.
     * @param _maxVestingPeriod - The maximum vesting period.
     * @param _rewardAllocation - The percentage of the reward to be returned to the user.
     */
    function addVestingPeriod(
        uint256 _minVestingPeriod,
        uint256 _maxVestingPeriod,
        uint256 _rewardAllocation
    ) external onlyOwner {
        vestingPeriods.push(
            VestingPeriods({
                minVestingPeriod: _minVestingPeriod,
                maxVestingPeriod: _maxVestingPeriod,
                rewardAllocation: _rewardAllocation
            })
        );
    }

    /**
     * @notice Function to edit the details of each vesting period.
     * @param _index - The index of the vesting period in the vestingPeriods array.
     * @param _minVestingPeriod - The minimum vesting period.
     * @param _maxVestingPeriod - The maximum vesting period.
     * @param _rewardAllocation - The percentage of the reward to be returned to the user.
     */
    function editVestingPeriod(
        uint256 _index,
        uint256 _minVestingPeriod,
        uint256 _maxVestingPeriod,
        uint256 _rewardAllocation
    ) external onlyOwner {
        vestingPeriods[_index].minVestingPeriod = _minVestingPeriod;
        vestingPeriods[_index].maxVestingPeriod = _maxVestingPeriod;
        vestingPeriods[_index].rewardAllocation = _rewardAllocation;
    }

    /**
     * @notice Function to add the details of each TenLots level.
     * @param _minBalance - The minimum balance required to enter the level.
     * @param _maxBalance - The maximum balance required to enter the level.
     * @param _percentage - The percentage of the reward to be returned to the user.
     * @param _maxAllowedUser - The maximum number of users allowed to enter the level.
     */
    function addLevel(
        uint256 _minBalance,
        uint256 _maxBalance,
        uint256 _percentage,
        uint256 _maxAllowedUser
    ) external onlyOwner {
        levels.push(
            Levels({
                sharePercent: _percentage,
                minBalance: _minBalance,
                maxBalance: _maxBalance,
                userCount: 0,
                maxAllowedUser: _maxAllowedUser
            })
        );
    }

    /**
     * @notice Function to edit the details of each TenLots level.
     * @param _index - The index of the level in the levels array.
     * @param _percentage - The percentage of the reward to be returned to the user.
     * @param _maxAllowedUser - The maximum number of users allowed to enter the level.
     * @param _maxBalance - The maximum balance required to enter the level.
     * @param _minBalance - The minimum balance required to enter the level.
     */
    function editLevel(
        uint256 _index,
        uint256 _percentage,
        uint256 _maxAllowedUser,
        uint256 _maxBalance,
        uint256 _minBalance
    ) external onlyOwner {
        levels[_index].sharePercent = _percentage;
        levels[_index].maxAllowedUser = _maxAllowedUser;
        levels[_index].maxBalance = _maxBalance;
        levels[_index].minBalance = _minBalance;
    }

    /**
     * @notice Function to add the pool ids and the corresponding LP token addresses.
     * @param _pID - The pool id array.
     * @param lp - The LP token address array.
     */
    function addVault(uint256[] calldata _pID, address[] calldata lp)
        external
        onlyOwner
    {
        for (uint8 i = 0; i < _pID.length; ++i) {
            require(_pID.length == lp.length, "TenLots : _pID != lp");
            require(lp[i] != address(0), "TenLots : zero address lp");
            pID.push(_pID[i]);
            LP.push(lp[i]);
        }
    }

    /**
     * @notice Function to edit the user's rewards claiming timestamp.
     * @dev This function will automatically be trigerred, from the backend, whenever
     * the user withdraws from the farm.
     */
    function editUserClaimTimeStamp(
        address user,
        bool penalty,
        uint256 amount
    ) external onlyOwner {
        require(userEntered[user], "TenLots: staking !entered");
        require(
            block.timestamp.sub(enterStakingStats[user].claimTimeStamp) >=
                coolDownPeriod,
            "TenLots: Claim cooldown"
        );
        if (!penalty) {
            enterStakingStats[user].claimTimeStamp = block.timestamp;
            enterStakingStats[user].pendingFee += 716338000000000;
            userAllowed[user] = true;
        } else {
            totalPenalties += amount;
            userEntered[user] = false;
            levels[enterStakingStats[user].level].userCount--;
            totalStaked -= enterStakingStats[user].balance;
            uint256 pos = index[user];
            registeredUsers[pos] = registeredUsers[registeredUsers.length - 1];
            registeredUsers.pop();

            delete (index[user]);
            delete (enterStakingStats[user]);
        }
    }

    /**
     * @notice Function to remove the pool ids and the corresponding LP token addresses.
     * @param _pID - The pool id array.
     * @param lp - The LP token address array.
     */
    function removeLP(uint256[] calldata _pID, address[] calldata lp)
        external
        onlyOwner
    {
        require(_pID.length == lp.length, "TenLots : _pID != lp");
        uint256 temp1;
        address temp2;
        for (uint8 j = 0; j < _pID.length; ++j) {
            for (uint8 i = 0; i < pID.length; ++i) {
                if (pID[i] == _pID[j]) {
                    temp1 = pID[i];
                    temp2 = lp[i];
                    pID[i] = pID[pID.length - 1];
                    LP[i] = LP[LP.length - 1];
                    pID[pID.length - 1] = temp1;
                    LP[LP.length - 1] = temp2;
                    break;
                }
            }
            pID.pop();
            LP.pop();
        }
    }

    function transferPenalty() external onlyOwner {
        uint256 fundsTransferred = totalPenalties;
        totalPenalties = 0;
        IERC20Upgradeable(BUSD).safeTransfer(tenFinance, fundsTransferred);
    }

    /**
     * @notice Function to set the total reward amounts to be distributed for each lot.
     */
    function setAccRewardPerLot(uint256[] calldata values) external onlyOwner {
        require(values.length == levels.length, "TenLots : values != levels");

        for (uint i = 0; i < levels.length; ++i) {
            accRewardPerLot[i] = values[i];
        }
    }

    /**
     * @notice Function to enter the user's details in the contract.
     * @dev This function migrates the user's data from the old contract to the new contract.
     */
    function enterUserIntoStaking(
        address[] calldata users,
        UserInfo[] calldata data
    ) external onlyOwner {
        for (uint256 i = 0; i < users.length; ++i) {
            enterStakingStats[users[i]] = data[i];
            totalStaked += data[i].balance;
            levels[data[i].level].userCount++;
            userEntered[users[i]] = true;
            registeredUsers.push(users[i]);
            index[users[i]] = registeredUsers.length - 1;
        }
    }

    /**
     * @notice Function to set the TToken address from the TenLend protocol.
     * @dev This function also sets the tTokenSet to true, which enables the cTToken balance
     * to be calculated for the user during the enterStaking function .
     */
    function setTToken(address _TToken) external onlyOwner {
        require(_TToken != address(0), "TenLots : zero address");
        cTToken = _TToken;
        cTTokenSet = true;
    }

    /**
     * @notice Function to trigger the state of the tTokenSet.
     * @dev This function should be used if wrong address is set for TToken.
     */
    function toggleTTokenState(bool _state) external onlyOwner {
        cTTokenSet = _state;
    }

    /**
     * @notice Function to retrieve the Tenfi balance of the @param _user
     */

    function getBalance(address _user) public returns (uint256) {
        uint256 _balance = 0;
        for (uint8 i = 0; i < pID.length; ++i) {
            uint256 stakedWantTokens = TenFarm(tenFarm)
                .stakedWantTokens(pID[i], _user)
                .mul(precisionMultiplier);
            address token0 = IPancakePair(LP[i]).token0();
            address token1 = IPancakePair(LP[i]).token1();

            if (token0 == tenfi) {
                (uint256 reserve0, , ) = IPancakePair(LP[i]).getReserves();
                uint256 totalSupply = IPancakePair(LP[i]).totalSupply();
                _balance +=
                    (reserve0.mul(stakedWantTokens.div(totalSupply))) *
                    2;
            } else if (token1 == tenfi) {
                (, uint256 reserve1, ) = IPancakePair(LP[i]).getReserves();
                uint256 totalSupply = IPancakePair(LP[i]).totalSupply();
                _balance +=
                    (reserve1.mul(stakedWantTokens.div(totalSupply))) *
                    2;
            }
        }

        _balance += TenFarm(tenFarm)
            .stakedWantTokens(singleStakingVault, _user)
            .mul(precisionMultiplier);

        if (cTTokenSet) {
            _balance += IcTToken(cTToken).balanceOfUnderlying(_user).mul(
                precisionMultiplier
            );
        }

        return _balance;
    }

    /**
     * @notice Function to calculate the reward of the user.
     */
    function userRewardPerLot(address user) public view returns (uint256) {
        require(userEntered[user], "TenLots: staking !entered");
        uint256 _level = enterStakingStats[user].level;
        uint256 _rewardPerLot = accRewardPerLot[_level]
            .mul(precisionMultiplier)
            .sub((enterStakingStats[user].rewardDebt).mul(precisionMultiplier));

        return _rewardPerLot.div(precisionMultiplier);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
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
 * /// @custom:oz-upgrades-unsafe-allow constructor
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ReentrancyGuardUpgradeable is Initializable {
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

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    function __Pausable_init() internal onlyInitializing {
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal onlyInitializing {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMathUpgradeable {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

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
        return a + b;
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
        return a - b;
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
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
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
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
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
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20Upgradeable.sol";
import "../../../utils/AddressUpgradeable.sol";

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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IcTToken {
    function balanceOfUnderlying(address owner) external returns (uint);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface TenFarm {
    function userInfo() external view returns (uint256);

    function deposit(uint256 _pid, uint256 _wantAmount) external;

    function withdraw(uint256 _pid, uint256 _amountIn) external;

    function stakedWantTokens(uint256 _pid, address _user)
        external
        view
        returns (uint256);

    function pendingTENFI(uint256 _pid, address _user)
        external
        view
        returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IPancakePair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function allowance(address owner, address spender)
        external
        view
        returns (uint);

    function approve(address spender, uint value) external returns (bool);

    function transfer(address to, uint value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint);

    function permit(
        address owner,
        address spender,
        uint value,
        uint deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(
        address indexed sender,
        uint amount0,
        uint amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint);

    function price1CumulativeLast() external view returns (uint);

    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);

    function burn(address to) external returns (uint amount0, uint amount1);

    function swap(
        uint amount0Out,
        uint amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

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