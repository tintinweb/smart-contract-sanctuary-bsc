// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import "./IFOInitializable.sol";

/**
 * @title IFODeployer
 */
contract IFODeployer is Ownable {
    using SafeERC20 for IERC20;

    uint256 public constant MAX_BUFFER_TIME_INTERVAL = 7 * 86400; // 1 week

    event AdminTokenRecovery(address indexed tokenRecovered, uint256 amount);
    event NewIFOContract(address indexed ifoAddress);

    /**
     * @notice Constructor
     */
    constructor() public {
        //
    }

    /**
     * @notice It deploy the IFO contract and initializes the contract.
     * @param _offeringToken: the token that is offered for the IFO
     * @param _startTime: the start timestamp for the IFO
     * @param _endTime: the end timestamp for the IFO
     * @param _adminAddress: the admin address for handling tokens
     */
    function deployIFO(
        address _offeringToken,
        uint256 _startTime,
        uint256 _endTime,
        address _adminAddress,
        address _votingEscrowAddress,
        address _burnAddress,
        address _receiverAddress
    ) external onlyOwner {
        require(IERC20(_offeringToken).totalSupply() >= 0);
        require(_endTime < (block.timestamp + MAX_BUFFER_TIME_INTERVAL), "Operations: EndTime too far");
        require(_startTime < _endTime, "Operations: StartTime must be inferior to endTime");
        require(_startTime > block.timestamp, "Operations: StartTime must be greater than current timestamp");

        bytes memory bytecode = type(IFOInitializable).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(_offeringToken, _startTime, _endTime));
        address ifoAddress;

        assembly {
            ifoAddress := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }

        IFOInitializable(ifoAddress).initialize(
            _offeringToken,
            _startTime,
            _endTime,
            MAX_BUFFER_TIME_INTERVAL,
            _adminAddress,
            _votingEscrowAddress,
            _burnAddress,
            _receiverAddress
        );

        emit NewIFOContract(ifoAddress);
    }

    /**
     * @notice It allows the admin to recover wrong tokens sent to the contract
     * @param _tokenAddress: the address of the token to withdraw
     * @dev This function is only callable by admin.
     */
    function recoverWrongTokens(address _tokenAddress) external onlyOwner {
        uint256 balanceToRecover = IERC20(_tokenAddress).balanceOf(address(this));
        require(balanceToRecover > 0, "Operations: Balance must be > 0");
        IERC20(_tokenAddress).safeTransfer(address(msg.sender), balanceToRecover);

        emit AdminTokenRecovery(_tokenAddress, balanceToRecover);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

import "../interfaces/ICronaIFO.sol";
import "../interfaces/ICronaSwapPair.sol";
import "../interfaces/IVotingEscrow.sol";

/**
 * @title IFOInitializable
 */

contract IFOInitializable is ICronaIFO, ReentrancyGuard, Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // The offering token
    IERC20 public override offeringToken;

    // Max time interval (for sanity checks)
    uint256 public MAX_BUFFER_TIME_INTERVAL;

    // Number of pools
    uint8 public constant NUMBER_POOLS = 2;

    // MULTIPLIER
    uint8 public constant VE_RATE = 10;

    uint256 constant public PERCENTAGE_FACTOR = 10000;

    // The address of the smart chef factory
    address public immutable IFO_FACTORY;

    // VotingEscrow contract
    address public votingEscrowAddress;

    // Whether it is initialized
    bool public isInitialized;

    // Allow claim
    bool public allowClaim;

    // The block timestamp when IFO starts
    uint256 public startTime;

    // The block timestamp when IFO ends
    uint256 public endTime;

    // The campaignId for the IFO
    uint256 public campaignId;

    // Total tokens distributed across the pools
    uint256 public totalTokensOffered;

    // Total amount of raising token withdrew
    uint256[NUMBER_POOLS] public totalWithdrawRaisingAmount;

    // The address burns raisingToken
    address public burnAddress;

    // The address receive remaining raisingToken after burning, like PostIFOLauncher
    address public receiverAddress;

    // Total amount of tax(raising token) withdrew
    uint256[NUMBER_POOLS] public totalWithdrawTaxAmount;

    // The address receive tax
    address public taxCollector;

    // Array of PoolCharacteristics of size NUMBER_POOLS
    PoolCharacteristics[NUMBER_POOLS] private _poolInformation;

    // It maps the address to pool id to UserInfo
    mapping(address => mapping(uint8 => UserInfo)) private _userInfo;

    // Struct that contains each pool characteristics
    struct PoolCharacteristics {
        IERC20 raisingToken; // The raising token
        uint256 raisingAmountPool; // amount of tokens raised for the pool (in raising tokens)
        uint256 offeringAmountPool; // amount of tokens offered for the pool (in offeringTokens)
        uint256 limitPerUserInRaisingToken; // limit of tokens per user (if 0, it is ignored)
        uint256 initialReleasePercentage; // percentage releases immediately when ifo ends(if 10000, it is 100%)
        uint256 burnPercentage; // The percentag of raisingToken to burn,multiply by PERCENTAGE_FACTOR (100 means 0.01)
        uint256 vestingEndTime; // block timestamp when 100% of tokens have been released
        bool hasTax; // tax on the overflow (if any, it works with _calculateTaxOverflow)
        uint256 totalAmountPool; // total amount pool deposited (in raising tokens)
        uint256 sumTaxesOverflow; // total taxes collected (starts at 0, increases with each harvest if overflow)
    }

    // Struct that contains each user information for both pools
    struct UserInfo {
        uint256 amountPool; // How many tokens the user has provided for pool
        uint256 offeringTokensClaimed; // How many tokens has been claimed by user
        uint256 lastTimeHarvested; // The time when user claimed recently
        bool hasHarvestedInitial; // If initial is claimed
        bool refunded; // If the user is refunded
    }

    // Admin withdraw events
    event AdminWithdraw(uint256[] amountRaisingTokens, uint256 amountOfferingToken);

    // Admin recovers token
    event AdminTokenRecovery(address tokenAddress, uint256 amountTokens);

    // Deposit event
    event Deposit(address indexed user, uint8 indexed pid, uint256 amount);

    // Harvest event
    event Harvest(address indexed user, uint8 indexed pid, uint256 offeringAmount, uint256 excessAmount);

    // Event for new start & end timestamp
    event NewStartAndEndTimes(uint256 startTime, uint256 endTime);

    // Event with campaignId for IFO
    event CampaignIdSet(uint256 campaignId);

    // Event when parameters are set for one of the pools
    event PoolParametersSet(uint8 pid, uint256 offeringAmountPool, uint256 raisingAmountPool);

    // Modifier to prevent contracts to participate
    modifier notContract() {
        require(!_isContract(msg.sender), "contract not allowed");
        require(msg.sender == tx.origin, "proxy contract not allowed");
        _;
    }

    /**
     * @notice Constructor
     */
    constructor() public {
        IFO_FACTORY = msg.sender;
    }

    /**
     * @notice It initializes the contract
     * @dev It can only be called once.
     * @param _offeringToken: the token that is offered for the IFO
     * @param _startTime: the start timestamp for the IFO
     * @param _endTime: the end timestamp for the IFO
     * @param _adminAddress: the admin address for handling tokens
     * @param _votingEscrowAddress: the address of the VotingEscrow
     */
    function initialize(
        address _offeringToken,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _maxBufferTimeInterval,
        address _adminAddress,
        address _votingEscrowAddress,
        address _burnAddress,
        address _receiverAddress
    ) public {
        require(!isInitialized, "Operations: Already initialized");
        require(msg.sender == IFO_FACTORY, "Operations: Not factory");
        require(_receiverAddress != address(0), "Operations: Zero address");

        // Make this contract initialized
        isInitialized = true;

        // init not allow claim
        allowClaim = false; 

        offeringToken = IERC20(_offeringToken);
        votingEscrowAddress = _votingEscrowAddress;
        startTime = _startTime;
        endTime = _endTime;
        MAX_BUFFER_TIME_INTERVAL = _maxBufferTimeInterval;

        burnAddress = _burnAddress;
        receiverAddress = _receiverAddress;

        // Transfer ownership to admin
        transferOwnership(_adminAddress);
    }

    /**
     * @notice It allows users to deposit raising tokens to pool
     * @param _amount: the number of raising token used (18 decimals)
     * @param _pid: pool id
     */
    function depositPool(uint256 _amount, uint8 _pid) external override nonReentrant notContract {
        // Checks whether the pool id is valid
        require(_pid < NUMBER_POOLS, "Deposit: Non valid pool id");

        // Checks that pool was set
        require(
            _poolInformation[_pid].offeringAmountPool > 0 && _poolInformation[_pid].raisingAmountPool > 0,
            "Deposit: Pool not set"
        );

        // Checks whether the block timestamp is not too early
        require(block.timestamp > startTime, "Deposit: Too early");

        // Checks whether the block timestamp is not too late
        require(block.timestamp < endTime, "Deposit: Too late");

        // Checks that the amount deposited is not inferior to 0
        require(_amount > 0, "Deposit: Amount must be > 0");

        // Verify tokens were deposited properly
        require(offeringToken.balanceOf(address(this)) >= totalTokensOffered, "Deposit: Tokens not deposited properly");

        // amount of veCrona from votingEscrow, only for base sale
        if (votingEscrowAddress != address(0) && _pid == 0) {
            uint256 veDecimal = IVotingEscrow(votingEscrowAddress).decimals();
            uint256 raisingDecimal = IVotingEscrow(address(_poolInformation[_pid].raisingToken)).decimals();
            require(veDecimal >= raisingDecimal, "Wrong decimal");

            uint256 ifoCredit = IVotingEscrow(votingEscrowAddress).balanceOf(msg.sender, startTime) * VE_RATE;
            require(_userInfo[msg.sender][_pid].amountPool.add(_amount).mul(10 ** (veDecimal - raisingDecimal)) <= ifoCredit, "Not enough veCrona");
        }

        // Transfers funds to this contract
        _poolInformation[_pid].raisingToken.safeTransferFrom(address(msg.sender), address(this), _amount);

        // Update the user status
        _userInfo[msg.sender][_pid].amountPool = _userInfo[msg.sender][_pid].amountPool.add(_amount);

        // Check if the pool has a limit per user
        if (_poolInformation[_pid].limitPerUserInRaisingToken > 0) {
            // Checks whether the limit has been reached
            require(
                _userInfo[msg.sender][_pid].amountPool <= _poolInformation[_pid].limitPerUserInRaisingToken,
                "Deposit: New amount above user limit"
            );
        }

        // Updates the totalAmount for pool
        _poolInformation[_pid].totalAmountPool = _poolInformation[_pid].totalAmountPool.add(_amount);

        emit Deposit(msg.sender, _pid, _amount);
    }

    /**
     * @notice It allows users to harvest from pool
     * @param _pid: pool id
     */
    function harvestPool(uint8 _pid) external override nonReentrant notContract {
        // Checks whether it is allow to harvest
        require(allowClaim, "Harvest: not allow claim");

        // Checks whether pool id is valid
        require(_pid < NUMBER_POOLS, "Harvest: Non valid pool id");

        UserInfo storage currentUserInfo = _userInfo[msg.sender][_pid];

        // Checks whether the user has participated
        require(currentUserInfo.amountPool > 0, "Harvest: Did not participate");

        // Checks whether the user has already harvested in the same block
        require(currentUserInfo.lastTimeHarvested < block.timestamp, "Harvest: Already harvest in the same block");

        // Initialize the variables for offering, refunding user amounts, and tax amount
        (
        uint256 raisingTokenRefund,
        uint256 userTaxOverflow,
        uint256 offeringTokenTotalHarvest,,,
        ) = userTokenStatus(msg.sender, _pid);

        // Updates the harvest time
        currentUserInfo.lastTimeHarvested = block.timestamp;
        currentUserInfo.hasHarvestedInitial = true;

        // Settle refund
        if (!currentUserInfo.refunded) {
            currentUserInfo.refunded = true;
            if (raisingTokenRefund > 0) {
                _poolInformation[_pid].raisingToken.safeTransfer(msg.sender, raisingTokenRefund);
            }
            // Increment the sumTaxesOverflow
            if (userTaxOverflow > 0) {
                _poolInformation[_pid].sumTaxesOverflow = _poolInformation[_pid].sumTaxesOverflow.add(userTaxOverflow);
            }
        }

        // Final check to verify the user has not gotten more tokens that originally allocated
        (uint256 offeringTokenAmount,,) = _calculateOfferingAndRefundingAmountsPool(msg.sender, _pid);
        uint256 offeringAllocationLeft = offeringTokenAmount - currentUserInfo.offeringTokensClaimed;
        uint256 allocatedTokens = offeringAllocationLeft >= offeringTokenTotalHarvest ? offeringTokenTotalHarvest : offeringAllocationLeft;
        if (allocatedTokens > 0) {
            currentUserInfo.offeringTokensClaimed += allocatedTokens;
            offeringToken.safeTransfer(msg.sender, allocatedTokens);
        }

        emit Harvest(msg.sender, _pid, allocatedTokens, raisingTokenRefund);
    }

    /**
     * @notice It allows the admin to withdraw funds
     * @param _raisingAmounts: the number array of raising token to withdraw
     * @param _offeringAmount: the number of offering amount to withdraw
     * @dev This function is only callable by admin.
     */
    function finalWithdraw(uint256[] memory _raisingAmounts, uint256 _offeringAmount) external override onlyOwner {
        require(_raisingAmounts.length == NUMBER_POOLS, "Operations: Wrong length");
      
        for (uint i; i < NUMBER_POOLS; i++) {
            if(_raisingAmounts[i] > 0) {
                PoolCharacteristics memory poolInfo = _poolInformation[i];
                require(_raisingAmounts[i] <= poolInfo.raisingToken.balanceOf(address(this)), "Operations: Not enough raising tokens");

                totalWithdrawRaisingAmount[i] = totalWithdrawRaisingAmount[i].add(_raisingAmounts[i]);
                require(totalWithdrawRaisingAmount[i] <= poolInfo.raisingAmountPool, "Operations: Maximum allowance exceeds");

                uint burnAmount = 0;
                if (poolInfo.burnPercentage != 0) {
                    burnAmount = _raisingAmounts[i].mul(poolInfo.burnPercentage).div(PERCENTAGE_FACTOR);
                    poolInfo.raisingToken.safeTransfer(burnAddress, burnAmount);
                }
                poolInfo.raisingToken.safeTransfer(receiverAddress, _raisingAmounts[i].sub(burnAmount));
            }
        }

        if (_offeringAmount > 0) {
            require(_offeringAmount <= offeringToken.balanceOf(address(this)), "Operations: Not enough offering tokens");
            offeringToken.safeTransfer(address(msg.sender), _offeringAmount);
        }

        emit AdminWithdraw(_raisingAmounts, _offeringAmount);
    }

    /**
     * @notice It allows the admin or collector to withdraw tax
     * @dev This function is only callable by admin or collector.
     */
    function taxWithdraw() external {
        require(taxCollector != address(0), "Operations: Wrong tax collector");
        require(owner() == msg.sender || taxCollector == msg.sender, "Operations: Permission denied");

        for (uint i; i < NUMBER_POOLS; i++) {
            uint256 sumTaxesOverflow = _poolInformation[i].sumTaxesOverflow;
            _poolInformation[i].raisingToken.safeTransfer(taxCollector, sumTaxesOverflow.sub(totalWithdrawTaxAmount[i]));
            totalWithdrawTaxAmount[i] = sumTaxesOverflow;
        }
    }

    /**
     * @notice It allows the admin to recover wrong tokens sent to the contract
     * @param _tokenAddress: the address of the token to withdraw (18 decimals)
     * @param _tokenAmount: the number of token amount to withdraw
     * @dev This function is only callable by admin.
     */
    function recoverWrongTokens(address _tokenAddress, uint256 _tokenAmount) external onlyOwner {
        require(_tokenAddress != address(offeringToken), "Recover: Cannot be offering token");
        for (uint i; i < NUMBER_POOLS; i++) {
            require(_tokenAddress != address(_poolInformation[i].raisingToken), "Recover: Cannot be raising token");
        }

        IERC20(_tokenAddress).safeTransfer(address(msg.sender), _tokenAmount);

        emit AdminTokenRecovery(_tokenAddress, _tokenAmount);
    }

    /**
     * @notice It sets parameters for pool
     * @param _raisingToken: the raising token used
     * @param _offeringAmountPool: offering amount (in tokens)
     * @param _raisingAmountPool: raising amount (in raising tokens)
     * @param _limitPerUserInRaisingToken: limit per user (in raising tokens)
     * @param _initialReleasePercentage: initial release percentage (if 10000, it is 100%)
     * @param _vestingEndTime: vesting end time
     * @param _hasTax: if the pool has a tax
     * @param _pid: pool id
     * @dev This function is only callable by admin.
     */
    function setPool(
        address _raisingToken,
        uint256 _offeringAmountPool,
        uint256 _raisingAmountPool,
        uint256 _limitPerUserInRaisingToken,
        uint256 _initialReleasePercentage,
        uint256 _burnPercentage,
        uint256 _vestingEndTime,
        bool _hasTax,
        uint8 _pid
    ) external override onlyOwner {
        require(IERC20(_raisingToken).totalSupply() >= 0);
        require(_raisingToken != address(offeringToken), "Operations: Tokens must be be different");
        require(block.timestamp < startTime, "Operations: IFO has started");
        require(_initialReleasePercentage <= PERCENTAGE_FACTOR, "Operations: Wrong initial percentage");
        require(_burnPercentage <= PERCENTAGE_FACTOR, "Operations: Wrong percentage");
        require(_vestingEndTime >= endTime, "Operations: Vesting ends too early");
        require(_pid < NUMBER_POOLS, "Operations: Pool does not exist");

        if (_vestingEndTime == endTime) {
            require(_initialReleasePercentage == PERCENTAGE_FACTOR, "Operations:Initial percentage should be equal to PERCENTAGE_FACTOR");
        }

        _poolInformation[_pid].raisingToken = IERC20(_raisingToken);
        _poolInformation[_pid].offeringAmountPool = _offeringAmountPool;
        _poolInformation[_pid].raisingAmountPool = _raisingAmountPool;
        _poolInformation[_pid].limitPerUserInRaisingToken = _limitPerUserInRaisingToken;
        _poolInformation[_pid].initialReleasePercentage = _initialReleasePercentage;
        _poolInformation[_pid].burnPercentage = _burnPercentage;
        _poolInformation[_pid].vestingEndTime = _vestingEndTime;
        _poolInformation[_pid].hasTax = _hasTax;

        uint256 tokensDistributedAcrossPools;

        for (uint8 i = 0; i < NUMBER_POOLS; i++) {
            tokensDistributedAcrossPools = tokensDistributedAcrossPools.add(_poolInformation[i].offeringAmountPool);
        }

        // Update totalTokensOffered
        totalTokensOffered = tokensDistributedAcrossPools;

        emit PoolParametersSet(_pid, _offeringAmountPool, _raisingAmountPool);
    }

    /**
     * @notice It updates campaignId for the IFO.
     * @param _campaignId: the campaignId for the IFO
     * @dev This function is only callable by admin.
     */
    function updateCampaignId(uint256 _campaignId) external override onlyOwner {
        require(block.timestamp < endTime, "Operations: IFO has ended");
        campaignId = _campaignId;

        emit CampaignIdSet(campaignId);
    }

    /**
     * @notice It allows the admin to update start and end timestamp
     * @param _startTime: the new start timestamp
     * @param _endTime: the new end timestamp
     * @dev This function is only callable by admin.
     */
    function updateStartAndEndTimes(uint256 _startTime, uint256 _endTime) external onlyOwner {
        require(_endTime < (block.timestamp + MAX_BUFFER_TIME_INTERVAL), "Operations: EndTime too far");
        require(block.timestamp < startTime, "Operations: IFO has started");
        require(_startTime < _endTime, "Operations: New startTime must be less than new endTime");
        require(block.timestamp < _startTime, "Operations: New startTime must be greater than current timestamp");

        startTime = _startTime;
        endTime = _endTime;

        emit NewStartAndEndTimes(_startTime, _endTime);
    }

    /**
    * @notice It allows the admin to set
    * @param _allow: claim status
    * @dev This function is only callable by admin.
    */
    function setAllowClaim(bool _allow) external onlyOwner {
        allowClaim = _allow;
    }

    /**
    * @notice It allows the admin to update tax collector
    * @param _taxCollector: the new tax collector
    * @dev This function is only callable by admin.
    */
    function setTaxCollector(address _taxCollector) external onlyOwner {
        taxCollector = _taxCollector;
    }

    /**
     * @notice It returns the pool information
     * @param _pid: poolId
     * @return raisingAmountPool: amount of raising tokens raised (in raising tokens)
     * @return offeringAmountPool: amount of tokens offered for the pool (in offeringTokens)
     * @return limitPerUserInRaisingToken: limit of tokens per user (if 0, it is ignored)
     * @return hasTax: tax on the overflow (if any, it works with _calculateTaxOverflow)
     * @return totalAmountPool: total amount pool deposited (in raising tokens)
     * @return sumTaxesOverflow: total taxes collected (starts at 0, increases with each harvest if overflow)
     */
    function viewPoolInformation(uint256 _pid)
    external
    view
    override
    returns (
        IERC20,
        uint256,
        uint256,
        uint256,
        uint256,
        uint256,
        uint256,
        bool,
        uint256,
        uint256
    )
    {
        PoolCharacteristics memory poolInfo = _poolInformation[_pid];
        return (
        poolInfo.raisingToken,
        poolInfo.raisingAmountPool,
        poolInfo.offeringAmountPool,
        poolInfo.limitPerUserInRaisingToken,
        poolInfo.initialReleasePercentage,
        poolInfo.burnPercentage,
        poolInfo.vestingEndTime,
        poolInfo.hasTax,
        poolInfo.totalAmountPool,
        poolInfo.sumTaxesOverflow
        );
    }

    /**
     * @notice It returns the tax overflow rate calculated for a pool
     * @dev 100,000,000,000 means 0.1 (10%) / 1 means 0.0000000000001 (0.0000001%) / 1,000,000,000,000 means 1 (100%)
     * @param _pid: poolId
     * @return It returns the tax percentage
     */
    function viewPoolTaxRateOverflow(uint256 _pid) external view override returns (uint256) {
        if (!_poolInformation[_pid].hasTax) {
            return 0;
        } else {
            return
            _calculateTaxOverflow(_poolInformation[_pid].totalAmountPool, _poolInformation[_pid].raisingAmountPool);
        }
    }

    /**
     * @notice External view function to see user allocations for both pools
     * @param _user: user address
     * @param _pids[]: array of pids
     * @return
     */
    function viewUserAllocationPools(address _user, uint8[] calldata _pids)
    external
    view
    override
    returns (uint256[] memory)
    {
        uint256[] memory allocationPools = new uint256[](_pids.length);
        for (uint8 i = 0; i < _pids.length; i++) {
            allocationPools[i] = _getUserAllocationPool(_user, _pids[i]);
        }
        return allocationPools;
    }

    /**
     * @notice External view function to see user information
     * @param _user: user address
     * @param _pids[]: array of pids
     */
    function viewUserInfo(address _user, uint8[] calldata _pids)
    external
    view
    override
    returns (uint256[] memory, uint256[] memory, uint256[] memory, bool[] memory, bool[] memory)
    {
        uint256[] memory amountPools = new uint256[](_pids.length);
        uint256[] memory offeringTokensClaimedPools = new uint256[](_pids.length);
        uint256[] memory lastTimeHarvestedPools = new uint256[](_pids.length);
        bool[] memory hasHarvestedInitialPools = new bool[](_pids.length);
        bool[] memory refundedPools = new bool[](_pids.length);

        for (uint8 i = 0; i < NUMBER_POOLS; i++) {
            amountPools[i] = _userInfo[_user][i].amountPool;
            offeringTokensClaimedPools[i] = _userInfo[_user][i].offeringTokensClaimed;
            lastTimeHarvestedPools[i] = _userInfo[_user][i].lastTimeHarvested;
            hasHarvestedInitialPools[i] = _userInfo[_user][i].hasHarvestedInitial;
            refundedPools[i] = _userInfo[_user][i].refunded;
        }
        return (amountPools, offeringTokensClaimedPools, lastTimeHarvestedPools, hasHarvestedInitialPools, refundedPools);
    }

    /**
     * @notice External view function to see user offering and refunding amounts for both pools
     * @param _user: user address
     * @param _pids: array of pids
     */
    function viewUserOfferingAndRefundingAmountsForPools(address _user, uint8[] calldata _pids)
    external
    view
    override
    returns (uint256[3][] memory)
    {
        uint256[3][] memory amountPools = new uint256[3][](_pids.length);

        for (uint8 i = 0; i < _pids.length; i++) {
            uint256 userOfferingAmountPool;
            uint256 userRefundingAmountPool;
            uint256 userTaxAmountPool;

            if (_poolInformation[_pids[i]].raisingAmountPool > 0) {
                (
                userOfferingAmountPool,
                userRefundingAmountPool,
                userTaxAmountPool
                ) = _calculateOfferingAndRefundingAmountsPool(_user, _pids[i]);
            }

            amountPools[i] = [userOfferingAmountPool, userRefundingAmountPool, userTaxAmountPool];
        }
        return amountPools;
    }

    /**
    * @notice Get the amount of tokens a user is eligible to receive based on current state.
    * @param _user: address of user to obtain token status
    * @param _pid: pool id to obtain token status
    * raisingTokenRefund:Amount of raising tokens available to refund
    * userTaxOverflow: Amount of tax
    * offeringTokenTotalHarvest: Total amount of offering tokens that can be harvested (initial + vested)
    * offeringTokenInitialHarvest: Amount of initial harvest offering tokens that can be collected
    * offeringTokenVestedHarvest: Amount offering tokens that can be harvested from the vesting portion of tokens
    * offeringTokensVesting: Amount of offering tokens that are still vested
    */
    function userTokenStatus(address _user, uint8 _pid) public view returns (
        uint256 raisingTokenRefund,
        uint256 userTaxOverflow,
        uint256 offeringTokenTotalHarvest,
        uint256 offeringTokenInitialHarvest,
        uint256 offeringTokenVestedHarvest,
        uint256 offeringTokensVesting
    ){
        uint256 currentTime = block.timestamp;
        if (currentTime < endTime) {
            return (0, 0, 0, 0, 0, 0);
        }

        UserInfo memory currentUserInfo = _userInfo[_user][_pid];
        PoolCharacteristics memory currentPoolInfo = _poolInformation[_pid];

        // Initialize the variables for offering, refunding user amounts
        (uint256 offeringTokenAmount, uint256 refundingTokenAmount, uint256 taxAmount) = _calculateOfferingAndRefundingAmountsPool(_user, _pid);
        uint256 offeringTokenInitialAmount = offeringTokenAmount * currentPoolInfo.initialReleasePercentage / PERCENTAGE_FACTOR;
        uint256 offeringTokenVestedAmount = offeringTokenAmount - offeringTokenInitialAmount;

        // Setup refund amount
        raisingTokenRefund = 0;
        userTaxOverflow = 0;
        if (!currentUserInfo.refunded) {
            raisingTokenRefund = refundingTokenAmount;
            userTaxOverflow = taxAmount;
        }

        // Setup initial harvest amount
        offeringTokenInitialHarvest = 0;
        if (!currentUserInfo.hasHarvestedInitial) {
            offeringTokenInitialHarvest = offeringTokenInitialAmount;
        }

        // Setup harvestable vested token amount
        offeringTokenVestedHarvest = 0;
        offeringTokensVesting = 0;
        // exclude initial
        uint256 offeringTokenUnclaimed = offeringTokenAmount.sub(offeringTokenInitialHarvest).sub(currentUserInfo.offeringTokensClaimed);
        if (currentTime >= currentPoolInfo.vestingEndTime) {
            offeringTokenVestedHarvest = offeringTokenUnclaimed;
        } else {
            uint256 unlockEndTime = currentTime;
            // endTime is the earliest time to harvest
            uint256 lastHarvestTime = currentUserInfo.lastTimeHarvested < endTime ? endTime : currentUserInfo.lastTimeHarvested;
            if (unlockEndTime > lastHarvestTime) {
                uint256 totalVestingTime = currentPoolInfo.vestingEndTime - endTime;
                uint256 unlockTime = unlockEndTime - lastHarvestTime;
                offeringTokenVestedHarvest = (offeringTokenVestedAmount * unlockTime) / totalVestingTime;
            }
            offeringTokensVesting = offeringTokenUnclaimed.sub(offeringTokenVestedHarvest);
        }
        offeringTokenTotalHarvest = offeringTokenInitialHarvest + offeringTokenVestedHarvest;
    }

    /**
     * @notice It calculates the tax overflow given the raisingAmountPool and the totalAmountPool.
     * @dev 100,000,000,000 means 0.1 (10%) / 1 means 0.0000000000001 (0.0000001%) / 1,000,000,000,000 means 1 (100%)
     * @return It returns the tax percentage
     */
    function _calculateTaxOverflow(uint256 _totalAmountPool, uint256 _raisingAmountPool)
    internal
    pure
    returns (uint256)
    {
        uint256 ratioOverflow = _totalAmountPool.div(_raisingAmountPool);

        if (ratioOverflow >= 1500) {
            return 500000000;
            // 0.05%
        } else if (ratioOverflow >= 1000) {
            return 1000000000;
            // 0.1%
        } else if (ratioOverflow >= 500) {
            return 2000000000;
            // 0.2%
        } else if (ratioOverflow >= 250) {
            return 2500000000;
            // 0.25%
        } else if (ratioOverflow >= 100) {
            return 3000000000;
            // 0.3%
        } else if (ratioOverflow >= 50) {
            return 5000000000;
            // 0.5%
        } else {
            return 10000000000;
            // 1%
        }
    }

    /**
     * @notice It calculates the offering amount for a user and the number of raising tokens to transfer back.
     * @param _user: user address
     * @param _pid: pool id
     * @return {uint256, uint256, uint256} It returns the offering amount, the refunding amount (in raising tokens),
     * and the tax (if any, else 0)
     */
    function _calculateOfferingAndRefundingAmountsPool(address _user, uint8 _pid)
    internal
    view
    returns (
        uint256,
        uint256,
        uint256
    )
    {
        uint256 userOfferingAmount;
        uint256 userRefundingAmount;
        uint256 taxAmount;

        if (_poolInformation[_pid].totalAmountPool > _poolInformation[_pid].raisingAmountPool) {
            // Calculate allocation for the user
            uint256 allocation = _getUserAllocationPool(_user, _pid);

            // Calculate the offering amount for the user based on the offeringAmount for the pool
            userOfferingAmount = _poolInformation[_pid].offeringAmountPool.mul(allocation).div(1e12);

            // Calculate the payAmount
            uint256 payAmount = _poolInformation[_pid].raisingAmountPool.mul(allocation).div(1e12);

            // Calculate the pre-tax refunding amount
            userRefundingAmount = _userInfo[_user][_pid].amountPool.sub(payAmount);

            // Retrieve the tax rate
            if (_poolInformation[_pid].hasTax) {
                uint256 taxOverflow = _calculateTaxOverflow(
                    _poolInformation[_pid].totalAmountPool,
                    _poolInformation[_pid].raisingAmountPool
                );

                // Calculate the final taxAmount
                taxAmount = userRefundingAmount.mul(taxOverflow).div(1e12);

                // Adjust the refunding amount
                userRefundingAmount = userRefundingAmount.sub(taxAmount);
            }
        } else {
            userRefundingAmount = 0;
            taxAmount = 0;
            // _userInfo[_user] / (raisingAmount / offeringAmount)
            userOfferingAmount = _userInfo[_user][_pid].amountPool.mul(_poolInformation[_pid].offeringAmountPool).div(
                _poolInformation[_pid].raisingAmountPool
            );
        }
        return (userOfferingAmount, userRefundingAmount, taxAmount);
    }

    /**
     * @notice It returns the user allocation for pool
     * @dev 100,000,000,000 means 0.1 (10%) / 1 means 0.0000000000001 (0.0000001%) / 1,000,000,000,000 means 1 (100%)
     * @param _user: user address
     * @param _pid: pool id
     * @return it returns the user's share of pool
     */
    function _getUserAllocationPool(address _user, uint8 _pid) internal view returns (uint256) {
        if (_poolInformation[_pid].totalAmountPool > 0) {
            return _userInfo[_user][_pid].amountPool.mul(1e18).div(_poolInformation[_pid].totalAmountPool.mul(1e6));
        } else {
            return 0;
        }
    }

    /**
     * @notice Check if an address is a contract
     */
    function _isContract(address _addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(_addr)
        }
        return size > 0;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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
    constructor () internal {
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
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
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
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
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
        require(b <= a, "SafeMath: subtraction overflow");
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
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
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
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
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
        require(b > 0, "SafeMath: modulo by zero");
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
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
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
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "./IERC20.sol";
import "../../math/SafeMath.sol";
import "../../utils/Address.sol";

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
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
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
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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

    constructor () internal {
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

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/** @title ICronaIFO.
 * @notice It is an interface for CronaIFOV2.sol
 */
interface ICronaIFO {
    /**
    * @notice It returns the offering token
    */
    function offeringToken() external view returns (IERC20);

    /**
     * @notice It allows users to deposit LP tokens to pool
     * @param _amount: the number of LP token used (18 decimals)
     * @param _pid: poolId
     */
    function depositPool(uint256 _amount, uint8 _pid) external;

    /**
     * @notice It allows users to harvest from pool
     * @param _pid: poolId
     */
    function harvestPool(uint8 _pid) external;

    /**
     * @notice It allows the admin to withdraw funds
     * @param _lpAmount: the number of LP token to withdraw (18 decimals)
     * @param _offerAmount: the number of offering amount to withdraw
     * @dev This function is only callable by admin.
     */
    function finalWithdraw(uint256[] memory _lpAmount, uint256 _offerAmount) external;

    /**
     * @notice It sets parameters for pool
     * @param _offeringAmountPool: offering amount (in tokens)
     * @param _raisingAmountPool: raising amount (in LP tokens)
     * @param _limitPerUserInRaisingToken: limit per user (in LP tokens)
     * @param _initialReleasePercentage: initial release percentage (if 10000, it is 100%)
     * @param _vestingEndTime: vesting end time
     * @param _hasTax: if the pool has a tax
     * @param _pid: poolId
     * @dev This function is only callable by admin.
     */
    function setPool(
        address _raisingToken,
        uint256 _offeringAmountPool,
        uint256 _raisingAmountPool,
        uint256 _limitPerUserInRaisingToken,
        uint256 _initialReleasePercentage,
        uint256 _burnPercentage,
        uint256 _vestingEndTime,
        bool _hasTax,
        uint8 _pid
    ) external;

    /**
     * @notice It updates campaignId for the IFO.
     * @param _campaignId: the campaignId for the IFO
     * @dev This function is only callable by admin.
     */
    function updateCampaignId(
        uint256 _campaignId
    ) external;

    /**
     * @notice It returns the pool information
     * @param _pid: poolId
     */
    function viewPoolInformation(uint256 _pid)
    external
    view
    returns (
        IERC20,
        uint256,
        uint256,
        uint256,
        uint256,
        uint256,
        uint256,
        bool,
        uint256,
        uint256
    );

    /**
     * @notice It returns the tax overflow rate calculated for a pool
     * @dev 100,000 means 0.1(10%)/ 1 means 0.000001(0.0001%)/ 1,000,000 means 1(100%)
     * @param _pid: poolId
     * @return It returns the tax percentage
     */
    function viewPoolTaxRateOverflow(uint256 _pid) external view returns (uint256);

    /**
     * @notice External view function to see user information
     * @param _user: user address
     * @param _pids[]: array of pids
     */
    function viewUserInfo(address _user, uint8[] calldata _pids)
    external
    view
    returns (uint256[] memory, uint256[] memory, uint256[] memory, bool[] memory, bool[] memory);

    /**
     * @notice External view function to see user allocations for both pools
     * @param _user: user address
     * @param _pids[]: array of pids
     */
    function viewUserAllocationPools(address _user, uint8[] calldata _pids) external view returns (uint256[] memory);

    /**
     * @notice External view function to see user offering and refunding amounts for both pools
     * @param _user: user address
     * @param _pids: array of pids
     */
    function viewUserOfferingAndRefundingAmountsForPools(address _user, uint8[] calldata _pids)
    external
    view
    returns (uint256[3][] memory);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

interface ICronaSwapPair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
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
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);
    function pairFee() external view returns (uint32);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
    function setPairFee(uint32) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^ 0.6.12;

interface IVotingEscrow {
    function balanceOf(address addr, uint256 _t) external view returns (uint256);

    function decimals() external view returns (uint8);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2 <0.8.0;

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
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
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

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
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
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
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
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
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
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
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
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
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