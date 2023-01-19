// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

/*
  ______                     ______                                 
 /      \                   /      \                                
|  ▓▓▓▓▓▓\ ______   ______ |  ▓▓▓▓▓▓\__   __   __  ______   ______  
| ▓▓__| ▓▓/      \ /      \| ▓▓___\▓▓  \ |  \ |  \|      \ /      \ 
| ▓▓    ▓▓  ▓▓▓▓▓▓\  ▓▓▓▓▓▓\\▓▓    \| ▓▓ | ▓▓ | ▓▓ \▓▓▓▓▓▓\  ▓▓▓▓▓▓\
| ▓▓▓▓▓▓▓▓ ▓▓  | ▓▓ ▓▓    ▓▓_\▓▓▓▓▓▓\ ▓▓ | ▓▓ | ▓▓/      ▓▓ ▓▓  | ▓▓
| ▓▓  | ▓▓ ▓▓__/ ▓▓ ▓▓▓▓▓▓▓▓  \__| ▓▓ ▓▓_/ ▓▓_/ ▓▓  ▓▓▓▓▓▓▓ ▓▓__/ ▓▓
| ▓▓  | ▓▓ ▓▓    ▓▓\▓▓     \\▓▓    ▓▓\▓▓   ▓▓   ▓▓\▓▓    ▓▓ ▓▓    ▓▓
 \▓▓   \▓▓ ▓▓▓▓▓▓▓  \▓▓▓▓▓▓▓ \▓▓▓▓▓▓  \▓▓▓▓▓\▓▓▓▓  \▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓ 
         | ▓▓                                             | ▓▓      
         | ▓▓                                             | ▓▓      
          \▓▓                                              \▓▓         
 * App:             https://ApeSwap.finance
 * Medium:          https://ape-swap.medium.com
 * Twitter:         https://twitter.com/ape_swap
 * Telegram:        https://t.me/ape_swap
 * Announcements:   https://t.me/ape_swap_news
 * Reddit:          https://reddit.com/r/ApeSwap
 * Instagram:       https://instagram.com/ApeSwap.finance
 * GitHub:          https://github.com/ApeSwapFinance
 */

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@ape.swap/contracts/contracts/v0.8/access/ContractWhitelist.sol";
import "./interfaces/IMasterApeV2.sol";
import "./interfaces/IOwnable.sol";
import "./interfaces/IRewarderV2.sol";

/// @title Admin MasterApeV2 proxy contract used to add features to MasterApeV2 admin functions
/// @dev This contract does NOT handle changing the dev address of the MasterApeV2 because that can only be done
///  by the dev address itself
/// @notice Admin functions are separated into onlyOwner and onlyFarmAdmin to separate concerns
contract MasterApeAdminV2 is Ownable, ContractWhitelist {
    struct FixedPercentFarmInfo {
        uint256 pid;
        uint256 allocationPercent;
        bool isActive;
    }

    /// @notice Farm admin can manage master ape farms and fixed percent farms
    address public farmAdmin;
    /// @notice MasterApeV2 Address
    IMasterApeV2 public immutable masterApeV2;
    /// @notice Address which is eligible to accept ownership of the MasterApeV2. Set by the current owner.
    address public pendingMasterApeV2Owner;
    /// @notice Array of MasterApeV2 pids that are active fixed percent farms
    uint256[] public fixedPercentFarmPids;
    /// @notice mapping of MasterApeV2 pids to FixedPercentFarmInfo
    mapping(uint256 => FixedPercentFarmInfo) public getFixedPercentFarmFromPid;
    /// @notice The percentages are divided by 10000
    uint256 public constant PERCENTAGE_PRECISION = 1e4;
    /// @notice Approaching max fixed farm percentage makes the fixed farm allocations go to infinity
    uint256 public constant MAX_FIXED_FARM_PERCENTAGE_BUFFER = PERCENTAGE_PRECISION / 10; // 10% Buffer
    /// @notice Percentage available to additional fixed percent farms
    uint256 public constant MAX_FIXED_FARM_PERCENTAGE = PERCENTAGE_PRECISION - MAX_FIXED_FARM_PERCENTAGE_BUFFER;
    /// @notice Total allocation percentage for fixed percent farms
    uint256 public totalFixedPercentFarmPercentage = 0;

    event SetPendingMasterApeV2Owner(address pendingMasterApeOV2wner);
    event AddFarm(IERC20 indexed lpToken, uint256 allocation, uint16 depositFeeBP, IRewarderV2 indexed rewarder);
    event SetFarm(uint256 indexed pid, uint256 allocation, uint16 depositFeeBP, IRewarderV2 indexed rewarder);
    event SyncFixedPercentFarm(uint256 indexed pid, uint256 allocation);
    event AddFixedPercentFarm(uint256 indexed pid, uint256 allocationPercentage);
    event SetFixedPercentFarm(uint256 indexed pid, uint256 previousAllocationPercentage, uint256 allocationPercentage);
    event TransferredFarmAdmin(address indexed previousFarmAdmin, address indexed newFarmAdmin);
    event SweepWithdraw(address indexed to, IERC20 indexed token, uint256 amount);

    modifier onlyFarmAdmin() {
        require(msg.sender == farmAdmin, "must be called by farm admin");
        _;
    }

    constructor(IMasterApeV2 _masterApeV2, address _farmAdmin) {
        masterApeV2 = _masterApeV2;
        farmAdmin = _farmAdmin;
    }

    /** External Functions  */

    /// @notice Set an address as the pending admin of the MasterApeV2. The address must accept to take ownership.
    /// @param _pendingMasterApeV2Owner Address to set as the pending owner of the MasterApeV2.
    function setPendingMasterApeV2Owner(address _pendingMasterApeV2Owner) external onlyOwner {
        pendingMasterApeV2Owner = _pendingMasterApeV2Owner;
        emit SetPendingMasterApeV2Owner(pendingMasterApeV2Owner);
    }

    /// @notice The pendingMasterApeOwner takes ownership through this call
    /// @dev Transferring MasterApeV2 ownership away from this contract renders this contract useless.
    function acceptMasterApeV2Ownership() external {
        require(msg.sender == pendingMasterApeV2Owner, "not pending owner");
        IOwnable(address(masterApeV2)).transferOwnership(pendingMasterApeV2Owner);
        pendingMasterApeV2Owner = address(0);
    }

    /// @notice Set an address as the pending admin of the MasterApeV1. The address must accept to take ownership.
    /// @param _pendingMasterApeV1Owner Address to set as the pending owner of the MasterApeV2.
    function setPendingMasterApeV1Owner(address _pendingMasterApeV1Owner) external onlyOwner {
        masterApeV2.setPendingMasterApeV1Owner(_pendingMasterApeV1Owner);
    }

    /// @notice Helper function to update MasterApeV2 pools in batches
    /// @dev The MasterApeV2 massUpdatePools function uses a for loop which in the future
    ///  could reach the block gas limit making it in-callable.
    /// @param pids Array of MasterApeV2 pids to update
    function batchUpdateMasterApePools(uint256[] calldata pids) external {
        for (uint256 pidIndex = 0; pidIndex < pids.length; pidIndex++) {
            masterApeV2.updatePool(pids[pidIndex]);
        }
    }

    /// @notice An external function to update MAv2 Emission rate.
    /// @param _bananaPerSecond how many BANANAs to mint per second
    /// @param _withUpdate flag to call massUpdatePool before update
    function updateEmissionRate(uint256 _bananaPerSecond, bool _withUpdate) external onlyOwner {
        masterApeV2.updateEmissionRate(_bananaPerSecond, _withUpdate);
    }

    /// @notice An external function to update the BANANA hard cap.
    /// @param _hardCap new BANANA hard cap
    function updateHardCap(uint256 _hardCap) external onlyOwner {
        masterApeV2.updateHardCap(_hardCap);
    }

    /// @notice enables smart contract whitelist on MAv2.
    function setWhitelistEnabled(bool _enabled) external override onlyOwner {
        masterApeV2.setWhitelistEnabled(_enabled);
    }

    /// @notice An external function to sweep accidental ERC20 transfers to this contract.
    ///   Tokens are sent to owner
    /// @param _tokens Array of ERC20 addresses to sweep
    /// @param _to Address to send tokens to
    function sweepTokens(IERC20[] calldata _tokens, address _to) external onlyOwner {
        for (uint256 index = 0; index < _tokens.length; index++) {
            IERC20 token = _tokens[index];
            uint256 balance = token.balanceOf(address(this));
            token.transfer(_to, balance);
            emit SweepWithdraw(_to, token, balance);
        }
    }

    /// @notice Transfer the farmAdmin to a new address
    /// @param _newFarmAdmin Address of new farmAdmin
    function transferFarmAdminOwnership(address _newFarmAdmin) external onlyFarmAdmin {
        require(_newFarmAdmin != address(0), "cannot transfer farm admin to address(0)");
        address previousFarmAdmin = farmAdmin;
        farmAdmin = _newFarmAdmin;
        emit TransferredFarmAdmin(previousFarmAdmin, farmAdmin);
    }

    /// @notice Update pool allocations based on fixed percentage farm percentages
    function syncFixedPercentFarms() external onlyFarmAdmin {
        require(getNumberOfFixedPercentFarms() > 0, "no fixed farms added");
        _syncFixedPercentFarms();
    }

    /// @notice Add a batch of farms to the MasterApeV2 contract
    /// @dev syncs fixed percentage farms after update
    /// @param _allocPoints Array of allocation points to set each address
    /// @param _stakeTokens Array of stake tokens
    /// @param _depositFeesBP Array of deposit fee basis points
    /// @param _rewarders Array of rewarders can be address(0) for no rewarder
    /// @param _withMassPoolUpdate Mass update pools before update
    /// @param _syncFixedPercentageFarms Sync fixed percentage farm allocations
    function addMasterApeFarms(
        uint256[] calldata _allocPoints,
        IERC20[] calldata _stakeTokens,
        uint16[] calldata _depositFeesBP,
        IRewarderV2[] calldata _rewarders,
        bool _withMassPoolUpdate,
        bool _syncFixedPercentageFarms
    ) external onlyFarmAdmin {
        require(
            _allocPoints.length == _stakeTokens.length &&
                _allocPoints.length == _depositFeesBP.length &&
                _allocPoints.length == _rewarders.length,
            "array length mismatch"
        );

        if (_withMassPoolUpdate) {
            masterApeV2.massUpdatePools();
        }

        for (uint256 index = 0; index < _allocPoints.length; index++) {
            masterApeV2.add(_allocPoints[index], _stakeTokens[index], false, _depositFeesBP[index], _rewarders[index]);
            emit AddFarm(_stakeTokens[index], _allocPoints[index], _depositFeesBP[index], _rewarders[index]);
        }

        if (_syncFixedPercentageFarms) {
            _syncFixedPercentFarms();
        }
    }

    /// @notice Set a batch of farms to the MasterApeV2 contract
    /// @dev syncs fixed percentage farms after update
    /// @param _pids Array of MasterApeV2 pool ids to update
    /// @param _allocPoints Array of allocation points to set each pid
    /// @param _depositFeesBP Array of deposit fees for each pid. Pass an empty array to leave the same value.
    /// @param _rewarders Array of rewarders to set for each pid. Pass an empty array to leave the same value.
    /// @param _withMassPoolUpdate Mass update pools before update
    /// @param _syncFixedPercentageFarms Sync fixed percentage farm allocations
    function setMasterApeFarms(
        uint256[] calldata _pids,
        uint256[] calldata _allocPoints,
        uint16[] calldata _depositFeesBP,
        IRewarderV2[] calldata _rewarders,
        bool _withMassPoolUpdate,
        bool _syncFixedPercentageFarms
    ) external onlyFarmAdmin {
        require(_pids.length == _allocPoints.length, "allocPoints length mismatch");
        // Check Deposit fees
        uint256 depositFeesLength = _depositFeesBP.length;
        if(_pids.length != depositFeesLength) {
            require(depositFeesLength == 0, "depositFeesBP length mismatch");
        }
        // Check rewarder addresses
        uint256 rewarderLength = _rewarders.length;
        if(_pids.length != rewarderLength) {
            require(rewarderLength == 0, "rewarder length mismatch");
        }

        if (_withMassPoolUpdate) {
            masterApeV2.massUpdatePools();
        }

        uint256 pidIndexes = masterApeV2.poolLength();
        for (uint256 index = 0; index < _pids.length; index++) {
            uint256 currentPid = _pids[index];
            require(currentPid < pidIndexes, "pid is out of bounds of MasterApeV2");
            uint256 currentAllocPoint = _allocPoints[index];
            // If no fees or rewarders are passed then this pulls the current from MasterApeV2
            uint16 currentDepositFeeBP;
            IRewarderV2 currentRewarder;
            if(depositFeesLength == 0 || rewarderLength == 0) {
                // If no length was passed then fill in these values from MasterApeV2
                ( , , currentRewarder, , , , currentDepositFeeBP) = masterApeV2.getPoolInfo(currentPid);
            } 
            // Update the deposit fee if passed
            if(depositFeesLength != 0) {
                currentDepositFeeBP = _depositFeesBP[index];
            }
            // Update the rewarder if passed
            if(rewarderLength != 0) {
                currentRewarder = _rewarders[index];
            }

            // Set all pids with no mass update
            masterApeV2.set(currentPid, currentAllocPoint, false, currentDepositFeeBP, currentRewarder);
            emit SetFarm(currentPid, currentAllocPoint, currentDepositFeeBP, currentRewarder);
        }

        if (_syncFixedPercentageFarms) {
            _syncFixedPercentFarms();
        }
    }

    /// @notice Add a new fixed percentage farm allocation
    /// @dev Must be a new MasterApeV2 pid and below the max fixed percentage
    /// @param _pid MasterApeV2 pid to create a fixed percentage farm for
    /// @param _allocPercentage Percentage based in PERCENTAGE_PRECISION
    /// @param _withMassPoolUpdate Mass update pools before update
    /// @param _syncFixedPercentageFarms Sync fixed percentage farm allocations
    function addFixedPercentFarmAllocation(
        uint256 _pid,
        uint256 _allocPercentage,
        bool _withMassPoolUpdate,
        bool _syncFixedPercentageFarms
    ) external onlyFarmAdmin {
        require(_pid < masterApeV2.poolLength(), "pid is out of bounds of MasterApeV2");
        require(!getFixedPercentFarmFromPid[_pid].isActive, "fixed percent farm already added");
        uint256 newTotalFixedPercentage = totalFixedPercentFarmPercentage + _allocPercentage;
        require(newTotalFixedPercentage <= MAX_FIXED_FARM_PERCENTAGE, "allocation out of bounds");

        totalFixedPercentFarmPercentage = newTotalFixedPercentage;
        getFixedPercentFarmFromPid[_pid] = FixedPercentFarmInfo(_pid, _allocPercentage, true);
        fixedPercentFarmPids.push(_pid);
        emit AddFixedPercentFarm(_pid, _allocPercentage);

        if (_withMassPoolUpdate) {
            masterApeV2.massUpdatePools();
        }

        if (_syncFixedPercentageFarms) {
            _syncFixedPercentFarms();
        }
    }

    /// @notice Update/disable a new fixed percentage farm allocation
    /// @dev If the farm allocation is 0, then the fixed farm will be disabled, but the allocation will be unchanged.
    /// @param _pid MasterApeV2 pid linked to fixed percentage farm to update
    /// @param _allocPercentage Percentage based in PERCENTAGE_PRECISION
    /// @param _withMassPoolUpdate Mass update pools before update
    /// @param _syncFixedPercentageFarms Sync fixed percentage farm allocations
    function setFixedPercentFarmAllocation(
        uint256 _pid,
        uint256 _allocPercentage,
        bool _withMassPoolUpdate,
        bool _syncFixedPercentageFarms
    ) external onlyFarmAdmin {
        FixedPercentFarmInfo storage fixedPercentFarm = getFixedPercentFarmFromPid[_pid];
        require(fixedPercentFarm.isActive, "not a valid farm pid");
        uint256 newTotalFixedPercentFarmPercentage = 
            (_allocPercentage + totalFixedPercentFarmPercentage) - fixedPercentFarm.allocationPercent;
        require(newTotalFixedPercentFarmPercentage <= MAX_FIXED_FARM_PERCENTAGE, "new allocation out of bounds");

        totalFixedPercentFarmPercentage = newTotalFixedPercentFarmPercentage;
        uint256 previousAllocation = fixedPercentFarm.allocationPercent;
        fixedPercentFarm.allocationPercent = _allocPercentage;

        if (_allocPercentage == 0) {
            // Disable fixed percentage farm and MasterApeV2 allocation
            fixedPercentFarm.isActive = false;
            // Remove fixed percent farm from pid array
            for (uint256 index = 0; index < fixedPercentFarmPids.length; index++) {
                if (fixedPercentFarmPids[index] == _pid) {
                    _removeFromArray(index, fixedPercentFarmPids);
                    break;
                }
            }
            // NOTE: The MasterApeV2 pool allocation is left unchanged to not disable a fixed farm
            //  in case the creation was an accident.
        }
        emit SetFixedPercentFarm(_pid, previousAllocation, _allocPercentage);

        if (_withMassPoolUpdate) {
            masterApeV2.massUpdatePools();
        }

        if (_syncFixedPercentageFarms) {
            _syncFixedPercentFarms();
        }
    }

    /// @notice Obtain detailed allocation information regarding a MasterApeV2 pool
    /// @param pid MasterApeV2 pid to pull detailed information from
    /// @return lpToken Address of the stake token for this pool
    /// @return poolAllocationPoint Allocation points for this pool
    /// @return totalAllocationPoints Total allocation points across all pools
    /// @return poolAllocationPercentMantissa Percentage of pool allocation points to total multiplied by 1e18
    /// @return poolBananaPerSecond Amount of BANANA given to the pool per second
    /// @return poolBananaPerDay Amount of BANANA given to the pool per day
    /// @return poolBananaPerMonth Amount of BANANA given to the pool per month
    function getDetailedPoolInfo(uint256 pid)
        external
        view
        returns (
            address lpToken,
            uint256 poolAllocationPoint,
            uint256 totalAllocationPoints,
            uint256 poolAllocationPercentMantissa,
            uint256 poolBananaPerSecond,
            uint256 poolBananaPerDay,
            uint256 poolBananaPerMonth,
            uint16 depositFeeBP,
            IRewarderV2 rewarder
        )
    {
        uint256 bananaPerSecond = masterApeV2.bananaPerSecond();
        (lpToken, poolAllocationPoint, rewarder, , , , depositFeeBP) = masterApeV2.getPoolInfo(pid);
        totalAllocationPoints = masterApeV2.totalAllocPoint();
        poolAllocationPercentMantissa = (poolAllocationPoint * 1e18) / totalAllocationPoints;
        poolBananaPerSecond = (bananaPerSecond * poolAllocationPercentMantissa) / 1e18;
        // Assumes a 3 second block time
        poolBananaPerDay = poolBananaPerSecond * 1 days;
        poolBananaPerMonth = poolBananaPerDay * 30;
    }

    /** Public Functions  */

    /// @notice Get the number of registered fixed percentage farms
    /// @return Number of active fixed percentage farms
    function getNumberOfFixedPercentFarms() public view returns (uint256) {
        return fixedPercentFarmPids.length;
    }

    /** Internal Functions  */

    /// @notice Enable or disable a contract address on the whitelist
    /// @param _address Address to update on whitelist
    /// @param _enabled Set if the whitelist is enabled or disabled
    function _setContractWhitelist(address _address, bool _enabled) internal override {
        masterApeV2.setContractWhitelist(_address, _enabled);
    }

    /** Private Functions  */

    /// @notice Run through fixed percentage farm allocations and set MasterApeV2 allocations to match the percentage.
    /// @dev The MasterApeV2 contract manages the BANANA pool percentage on its own
    /// which is accounted for in the calculations below.
    function _syncFixedPercentFarms() private {
        uint256 numberOfFixedPercentFarms = getNumberOfFixedPercentFarms();
        if (numberOfFixedPercentFarms == 0) {
            return;
        }
        uint256 masterApeV2TotalAllocation = masterApeV2.totalAllocPoint();
        uint256 currentTotalFixedPercentFarmAllocation = 0;
        // Calculate the total allocation points of the fixed percent farms
        for (uint256 index = 0; index < numberOfFixedPercentFarms; index++) {
            (, uint256 fixedPercentFarmAllocation, , , , , ) = masterApeV2.getPoolInfo(fixedPercentFarmPids[index]);
            currentTotalFixedPercentFarmAllocation += fixedPercentFarmAllocation;
        }
        // Calculate alloted allocations
        uint256 nonPercentageBasedAllocation = masterApeV2TotalAllocation - currentTotalFixedPercentFarmAllocation;
        uint256 percentageIncrease = (PERCENTAGE_PRECISION * PERCENTAGE_PRECISION) / 
            (PERCENTAGE_PRECISION - totalFixedPercentFarmPercentage);
        uint256 finalAllocation = (nonPercentageBasedAllocation * percentageIncrease) / PERCENTAGE_PRECISION;
        uint256 allotedFixedPercentFarmAllocation = finalAllocation - nonPercentageBasedAllocation;
        // Update fixed percentage farm allocations
        for (uint256 index = 0; index < numberOfFixedPercentFarms; index++) {
            FixedPercentFarmInfo memory fixedPercentFarm = getFixedPercentFarmFromPid[fixedPercentFarmPids[index]];
            uint256 newFixedPercentFarmAllocation = 
                (allotedFixedPercentFarmAllocation * fixedPercentFarm.allocationPercent) / totalFixedPercentFarmPercentage;
            (, , IRewarderV2 rewarder, , , , uint16 depositFeeBP) = masterApeV2.getPoolInfo(fixedPercentFarmPids[index]);
            masterApeV2.set(
                fixedPercentFarm.pid,
                newFixedPercentFarmAllocation,
                false,
                depositFeeBP,
                rewarder
            );
            emit SyncFixedPercentFarm(fixedPercentFarm.pid, newFixedPercentFarmAllocation);
        }
    }

    /// @notice Remove an index from an array by copying the last element to the index
    /// and then removing the last element.
    function _removeFromArray(uint256 index, uint256[] storage array) private {
        require(index < array.length, "Incorrect index");
        array[index] = array[array.length - 1];
        array.pop();
    }
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

/*
  ______                     ______                                 
 /      \                   /      \                                
|  ▓▓▓▓▓▓\ ______   ______ |  ▓▓▓▓▓▓\__   __   __  ______   ______  
| ▓▓__| ▓▓/      \ /      \| ▓▓___\▓▓  \ |  \ |  \|      \ /      \ 
| ▓▓    ▓▓  ▓▓▓▓▓▓\  ▓▓▓▓▓▓\\▓▓    \| ▓▓ | ▓▓ | ▓▓ \▓▓▓▓▓▓\  ▓▓▓▓▓▓\
| ▓▓▓▓▓▓▓▓ ▓▓  | ▓▓ ▓▓    ▓▓_\▓▓▓▓▓▓\ ▓▓ | ▓▓ | ▓▓/      ▓▓ ▓▓  | ▓▓
| ▓▓  | ▓▓ ▓▓__/ ▓▓ ▓▓▓▓▓▓▓▓  \__| ▓▓ ▓▓_/ ▓▓_/ ▓▓  ▓▓▓▓▓▓▓ ▓▓__/ ▓▓
| ▓▓  | ▓▓ ▓▓    ▓▓\▓▓     \\▓▓    ▓▓\▓▓   ▓▓   ▓▓\▓▓    ▓▓ ▓▓    ▓▓
 \▓▓   \▓▓ ▓▓▓▓▓▓▓  \▓▓▓▓▓▓▓ \▓▓▓▓▓▓  \▓▓▓▓▓\▓▓▓▓  \▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓ 
         | ▓▓                                             | ▓▓      
         | ▓▓                                             | ▓▓      
          \▓▓                                              \▓▓         
 * App:             https://ApeSwap.finance
 * Medium:          https://ape-swap.medium.com
 * Twitter:         https://twitter.com/ape_swap
 * Telegram:        https://t.me/ape_swap
 * Announcements:   https://t.me/ape_swap_news
 * Reddit:          https://reddit.com/r/ApeSwap
 * Instagram:       https://instagram.com/ApeSwap.finance
 * GitHub:          https://github.com/ApeSwapFinance
 */

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IRewarderV2 {
    /// @dev even if not all parameters are currently used in this implementation they help future proofing it
    function onReward(
        uint256 _pid,
        address _user,
        address _to,
        uint256 _pending,
        uint256 _stakedAmount,
        uint256 _lpSupply
    ) external;

    /// @dev passing stakedAmount here helps future proofing the interface
    function pendingTokens(
        uint256 pid,
        address user,
        uint256 amount
    ) external view returns (IERC20[] memory, uint256[] memory);
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

/*
  ______                     ______                                 
 /      \                   /      \                                
|  ▓▓▓▓▓▓\ ______   ______ |  ▓▓▓▓▓▓\__   __   __  ______   ______  
| ▓▓__| ▓▓/      \ /      \| ▓▓___\▓▓  \ |  \ |  \|      \ /      \ 
| ▓▓    ▓▓  ▓▓▓▓▓▓\  ▓▓▓▓▓▓\\▓▓    \| ▓▓ | ▓▓ | ▓▓ \▓▓▓▓▓▓\  ▓▓▓▓▓▓\
| ▓▓▓▓▓▓▓▓ ▓▓  | ▓▓ ▓▓    ▓▓_\▓▓▓▓▓▓\ ▓▓ | ▓▓ | ▓▓/      ▓▓ ▓▓  | ▓▓
| ▓▓  | ▓▓ ▓▓__/ ▓▓ ▓▓▓▓▓▓▓▓  \__| ▓▓ ▓▓_/ ▓▓_/ ▓▓  ▓▓▓▓▓▓▓ ▓▓__/ ▓▓
| ▓▓  | ▓▓ ▓▓    ▓▓\▓▓     \\▓▓    ▓▓\▓▓   ▓▓   ▓▓\▓▓    ▓▓ ▓▓    ▓▓
 \▓▓   \▓▓ ▓▓▓▓▓▓▓  \▓▓▓▓▓▓▓ \▓▓▓▓▓▓  \▓▓▓▓▓\▓▓▓▓  \▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓ 
         | ▓▓                                             | ▓▓      
         | ▓▓                                             | ▓▓      
          \▓▓                                              \▓▓         
 * App:             https://ApeSwap.finance
 * Medium:          https://ape-swap.medium.com
 * Twitter:         https://twitter.com/ape_swap
 * Telegram:        https://t.me/ape_swap
 * Announcements:   https://t.me/ape_swap_news
 * Reddit:          https://reddit.com/r/ApeSwap
 * Instagram:       https://instagram.com/ApeSwap.finance
 * GitHub:          https://github.com/ApeSwapFinance
 */


interface IOwnable {
    function transferOwnership(address newOwner) external; // from Ownable.sol
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

/*
  ______                     ______                                 
 /      \                   /      \                                
|  ▓▓▓▓▓▓\ ______   ______ |  ▓▓▓▓▓▓\__   __   __  ______   ______  
| ▓▓__| ▓▓/      \ /      \| ▓▓___\▓▓  \ |  \ |  \|      \ /      \ 
| ▓▓    ▓▓  ▓▓▓▓▓▓\  ▓▓▓▓▓▓\\▓▓    \| ▓▓ | ▓▓ | ▓▓ \▓▓▓▓▓▓\  ▓▓▓▓▓▓\
| ▓▓▓▓▓▓▓▓ ▓▓  | ▓▓ ▓▓    ▓▓_\▓▓▓▓▓▓\ ▓▓ | ▓▓ | ▓▓/      ▓▓ ▓▓  | ▓▓
| ▓▓  | ▓▓ ▓▓__/ ▓▓ ▓▓▓▓▓▓▓▓  \__| ▓▓ ▓▓_/ ▓▓_/ ▓▓  ▓▓▓▓▓▓▓ ▓▓__/ ▓▓
| ▓▓  | ▓▓ ▓▓    ▓▓\▓▓     \\▓▓    ▓▓\▓▓   ▓▓   ▓▓\▓▓    ▓▓ ▓▓    ▓▓
 \▓▓   \▓▓ ▓▓▓▓▓▓▓  \▓▓▓▓▓▓▓ \▓▓▓▓▓▓  \▓▓▓▓▓\▓▓▓▓  \▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓ 
         | ▓▓                                             | ▓▓      
         | ▓▓                                             | ▓▓      
          \▓▓                                              \▓▓         
 * App:             https://ApeSwap.finance
 * Medium:          https://ape-swap.medium.com
 * Twitter:         https://twitter.com/ape_swap
 * Telegram:        https://t.me/ape_swap
 * Announcements:   https://t.me/ape_swap_news
 * Reddit:          https://reddit.com/r/ApeSwap
 * Instagram:       https://instagram.com/ApeSwap.finance
 * GitHub:          https://github.com/ApeSwapFinance
 */

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@ape.swap/contracts/contracts/v0.8/interfaces/IContractWhitelist.sol";
import "./IRewarderV2.sol";


interface IMasterApeV2 is IContractWhitelist {
    function updateEmissionRate(uint256 _bananaPerSecond, bool _withUpdate) external; // onlyOwner

    function updateHardCap(uint256 _hardCap) external; // onlyOwner

    function setFeeAddress(address _feeAddress) external; // onlyOwner

    function add(
        uint256 _allocPoint,
        IERC20 _stakeToken,
        bool _withUpdate,
        uint16 _depositFeeBP,
        IRewarderV2 _rewarder
    ) external; // onlyOwner

    function set(
        uint256 _pid,
        uint256 _allocPoint,
        bool _withUpdate,
        uint16 _depositFeeBP,
        IRewarderV2 _rewarder
    ) external; // onlyOwner

    function massUpdatePools() external;

    function updatePool(uint256 _pid) external; // validatePool(_pid);

    function depositTo(
        uint256 _pid,
        uint256 _amount,
        address _to
    ) external; // validatePool(_pid);

    function deposit(uint256 _pid, uint256 _amount) external; // validatePool(_pid);

    function withdraw(uint256 _pid, uint256 _amount) external; // validatePool(_pid);

    function withdrawTo(
        uint256 _pid,
        uint256 _amount,
        address _to
    ) external; // validatePool(_pid);

    function emergencyWithdraw(uint256 _pid) external;

    function setPendingMasterApeV1Owner(address _pendingMasterApeV1Owner) external;

    function acceptMasterApeV1Ownership() external;

    function bananaPerSecond() external view returns (uint256);

    function poolLength() external view returns (uint256);

    function totalAllocPoint() external view returns (uint256);

    function getMultiplier(uint256 _from, uint256 _to) external view returns (uint256);

    function pendingBanana(uint256 _pid, address _user) external view returns (uint256);

    function userInfo(uint256, address)
        external
        view
        returns (uint256 amount, uint256 rewardDebt);

    function getPoolInfo(uint256 _pid)
        external
        view
        returns (
            address lpToken,
            uint256 allocPoint,
            IRewarderV2 rewarder,
            uint256 lastRewardBlock,
            uint256 accBananaPerShare,
            uint256 totalStaked,
            uint16 depositFeeBP
        );
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/structs/EnumerableSet.sol)
// This file was procedurally generated from scripts/generate/templates/EnumerableSet.js.

pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 *
 * [WARNING]
 * ====
 * Trying to delete such a structure from storage will likely result in data corruption, rendering the structure
 * unusable.
 * See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
 *
 * In order to clean an EnumerableSet, you can either remove all elements one by one or create a fresh instance using an
 * array of EnumerableSet.
 * ====
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastValue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastValue;
                // Update the index for the moved value
                set._indexes[lastValue] = valueIndex; // Replace lastValue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        bytes32[] memory store = _values(set._inner);
        bytes32[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }
}

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

/*
  ______                     ______                                 
 /      \                   /      \                                
|  ▓▓▓▓▓▓\ ______   ______ |  ▓▓▓▓▓▓\__   __   __  ______   ______  
| ▓▓__| ▓▓/      \ /      \| ▓▓___\▓▓  \ |  \ |  \|      \ /      \ 
| ▓▓    ▓▓  ▓▓▓▓▓▓\  ▓▓▓▓▓▓\\▓▓    \| ▓▓ | ▓▓ | ▓▓ \▓▓▓▓▓▓\  ▓▓▓▓▓▓\
| ▓▓▓▓▓▓▓▓ ▓▓  | ▓▓ ▓▓    ▓▓_\▓▓▓▓▓▓\ ▓▓ | ▓▓ | ▓▓/      ▓▓ ▓▓  | ▓▓
| ▓▓  | ▓▓ ▓▓__/ ▓▓ ▓▓▓▓▓▓▓▓  \__| ▓▓ ▓▓_/ ▓▓_/ ▓▓  ▓▓▓▓▓▓▓ ▓▓__/ ▓▓
| ▓▓  | ▓▓ ▓▓    ▓▓\▓▓     \\▓▓    ▓▓\▓▓   ▓▓   ▓▓\▓▓    ▓▓ ▓▓    ▓▓
 \▓▓   \▓▓ ▓▓▓▓▓▓▓  \▓▓▓▓▓▓▓ \▓▓▓▓▓▓  \▓▓▓▓▓\▓▓▓▓  \▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓ 
         | ▓▓                                             | ▓▓      
         | ▓▓                                             | ▓▓      
          \▓▓                                              \▓▓         
 * App:             https://ApeSwap.finance
 * Medium:          https://ape-swap.medium.com
 * Twitter:         https://twitter.com/ape_swap
 * Telegram:        https://t.me/ape_swap
 * Announcements:   https://t.me/ape_swap_news
 * Discord:         https://discord.com/ApeSwap
 * Reddit:          https://reddit.com/r/ApeSwap
 * Instagram:       https://instagram.com/ApeSwap.finance
 * GitHub:          https://github.com/ApeSwapFinance
 */

interface IContractWhitelist {
    function getWhitelistLength() external returns (uint256);

    function getWhitelistAtIndex(uint256 _index) external returns (address);

    function isWhitelisted(address _address) external returns (bool);

    function setWhitelistEnabled(bool _enabled) external;

    function setContractWhitelist(address _address, bool _enabled) external;

    function setBatchContractWhitelist(address[] memory _addresses, bool[] memory _enabled) external;
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

/*
  ______                     ______                                 
 /      \                   /      \                                
|  ▓▓▓▓▓▓\ ______   ______ |  ▓▓▓▓▓▓\__   __   __  ______   ______  
| ▓▓__| ▓▓/      \ /      \| ▓▓___\▓▓  \ |  \ |  \|      \ /      \ 
| ▓▓    ▓▓  ▓▓▓▓▓▓\  ▓▓▓▓▓▓\\▓▓    \| ▓▓ | ▓▓ | ▓▓ \▓▓▓▓▓▓\  ▓▓▓▓▓▓\
| ▓▓▓▓▓▓▓▓ ▓▓  | ▓▓ ▓▓    ▓▓_\▓▓▓▓▓▓\ ▓▓ | ▓▓ | ▓▓/      ▓▓ ▓▓  | ▓▓
| ▓▓  | ▓▓ ▓▓__/ ▓▓ ▓▓▓▓▓▓▓▓  \__| ▓▓ ▓▓_/ ▓▓_/ ▓▓  ▓▓▓▓▓▓▓ ▓▓__/ ▓▓
| ▓▓  | ▓▓ ▓▓    ▓▓\▓▓     \\▓▓    ▓▓\▓▓   ▓▓   ▓▓\▓▓    ▓▓ ▓▓    ▓▓
 \▓▓   \▓▓ ▓▓▓▓▓▓▓  \▓▓▓▓▓▓▓ \▓▓▓▓▓▓  \▓▓▓▓▓\▓▓▓▓  \▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓ 
         | ▓▓                                             | ▓▓      
         | ▓▓                                             | ▓▓      
          \▓▓                                              \▓▓         
 * App:             https://ApeSwap.finance
 * Medium:          https://ape-swap.medium.com
 * Twitter:         https://twitter.com/ape_swap
 * Telegram:        https://t.me/ape_swap
 * Announcements:   https://t.me/ape_swap_news
 * Discord:         https://discord.com/ApeSwap
 * Reddit:          https://reddit.com/r/ApeSwap
 * Instagram:       https://instagram.com/ApeSwap.finance
 * GitHub:          https://github.com/ApeSwapFinance
 */

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "../interfaces/IContractWhitelist.sol";

abstract contract ContractWhitelist is IContractWhitelist, Ownable {
    using EnumerableSet for EnumerableSet.AddressSet;

    EnumerableSet.AddressSet private contractWhitelistSet;
    /// @notice marks if a contract whitelist is enabled.
    bool public whitelistEnabled;

    event UpdateWhitelistStatus(bool whitelistEnabled);
    event UpdateContractWhitelist(address indexed whitelistAddress, bool whitelistEnabled);

    /// @dev checks if whitelist is enabled and if contract is whitelisted
    modifier checkEOAorWhitelist() {
        // If whitelist is enabled and sender is not EOA
        if (whitelistEnabled && msg.sender != tx.origin) {
            require(isWhitelisted(msg.sender), "checkWhitelist: not in whitelist");
        }
        _;
    }

    /// @notice Get the number of addresses on the whitelist
    function getWhitelistLength() external view virtual override returns (uint256) {
        return contractWhitelistSet.length();
    }

    /// @notice Find the address on the whitelist of the provided index
    /// @param _index Index to query
    function getWhitelistAtIndex(uint256 _index) external view virtual override returns (address) {
        return contractWhitelistSet.at(_index);
    }

    /// @notice Check if an address is whitelisted
    /// @param _address Address to query
    function isWhitelisted(address _address) public view virtual override returns (bool) {
        return contractWhitelistSet.contains(_address);
    }

    /// @notice enables smart contract whitelist
    function setWhitelistEnabled(bool _enabled) external virtual override onlyOwner {
        whitelistEnabled = _enabled;
        emit UpdateWhitelistStatus(whitelistEnabled);
    }

    /// @notice Enable or disable a contract address on the whitelist
    /// @param _address Address to update on whitelist
    /// @param _enabled Set if the whitelist is enabled or disabled
    function setContractWhitelist(address _address, bool _enabled) external override onlyOwner {
        _setContractWhitelist(_address, _enabled);
    }

    /// @notice Enable or disable contract addresses on the whitelist
    /// @param _addresses Addressed to update on whitelist
    /// @param _enabled Set if the whitelist is enabled or disabled for each address passed
    function setBatchContractWhitelist(address[] calldata _addresses, bool[] calldata _enabled) external override onlyOwner {
        require(_addresses.length == _enabled.length, "array mismatch");
        for (uint256 i = 0; i < _addresses.length; i++) {
            _setContractWhitelist(_addresses[i], _enabled[i]);
        }
    }

    /// @notice Enable or disable a contract address on the whitelist
    /// @param _address Address to update on whitelist
    /// @param _enabled Set if the whitelist is enabled or disabled
    function _setContractWhitelist(address _address, bool _enabled) internal virtual {
        if(_enabled) {
            require(contractWhitelistSet.add(_address), "address already enabled");
        } else {
            require(contractWhitelistSet.remove(_address), "address already disabled");
        }
        emit UpdateContractWhitelist(_address, _enabled);
    }
}