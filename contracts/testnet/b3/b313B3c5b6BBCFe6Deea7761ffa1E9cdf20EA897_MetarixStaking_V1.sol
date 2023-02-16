//SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "./OwnableUpgradeable.sol";
import "./Initializable.sol";
import "./UUPSUpgradeable.sol";

interface IToken {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

/**
 * @title Staking Smart Contract
 * @notice On-request smart contract to stake Metarix Token
 * @author Socarde Paul-Constantin, DRIVENlabs Inc.
 */

contract MetarixStaking_V1 is Initializable, OwnableUpgradeable, UUPSUpgradeable {

    /// @dev Tokens for rewards
    uint256 public registeredRewards;

    /// @dev for re-entrancy protection
    uint256 private enter = 1;

    /// @dev Variable to increase/decrease the APR
    uint256 public aprFactor;
    uint256 public aprFactorForUsers;

    /// @dev Fee for emergency withdraw
    uint256 public fee;

    /// @dev Compound period
    uint256 compoundPeriod;

    /// @dev Pause the smart contract
    bool public isPaused;

    /// @dev Analytics
    mapping(uint256 => uint256) public totalStakedByPool;

    /// @dev Link an address to deposit with id
    mapping(address => uint256[]) public userDeposits;

    /// @dev Add increased APR for certain users
    mapping(address => bool) public hasIncreasedApr;

    /// @dev Track last compound date
    mapping(address => uint256) public lastCompoundDate;

    /// @dev Track the staked amount and rewards after the user withdraw
    mapping(uint256 => uint256) public depositToStakedAmount;
    mapping(uint256 => uint256) public depositToReceivedRewards;

    /// @dev Track if a user used emergency withdraw for deposit[index]
    mapping(address => mapping(uint256 => bool)) public usedEmergency;

    /// @dev Metarix Token
    IToken public metarix;

    /// @dev Struct for pools
    struct Pool {
        uint256 id;
        uint256 apr;
        uint256 periodInDays;
        uint256 totalStakers;
        bool enabled;
    }

    /// @dev Struct for users
    struct Deposit {
        uint256 depositId;
        uint256 poolId;
        uint256 amount;
        uint256 compounded;
        uint256 startDate;
        uint256 endDate;
        address owner;
        bool ended;
    }

    /// @dev arrays of pools and deposits
    Pool[] public pools;
    Deposit[] public deposits;


    /// @dev Events
    event TogglePause(bool status);
    event NewAprFactor(uint256 apr);
    event RescueBNB(uint256 amount);
    event NewEmergencyFee(uint256 fee);
    event NewCompoundPeriod(uint256 period);
    event NewAprFactorForUsers(uint256 apr);
    event AddPool(uint256 apr, uint256 period);
    event NewTokenAddress(address indexed token);
    event NewApr(uint256 poolId, uint256 newApr);
    event EnablePool(uint256 poolId, bool status);
    event DisablePool(uint256 poolId, bool status);
    event SetNormalAprFor(address indexed user, bool status);
    event SendTokensBack(address indexed user, uint256 amount);
    event SetIncreasedAprFor(address indexed user, bool status);
    event WithdrawErc20Tokens(address indexed token, uint256 amount);
    event Stake(address indexed user, uint256 poolId, uint256 amount);
    event Unstake(address indexed user, uint256 poolId, uint256 depositId, uint256 amount);
    event Compound(address indexed user, uint256 poolId, uint256 depositId, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 poolId, uint256 depositId, uint256 amount);

    /// @dev Errors
    error CantEnter();
    error ZeroBalance();
    error CantCompound();
    error InvalidOwner();
    error EndedDeposit();
    error PoolDisabled();
    error InvalidPoolId();
    error InvalidAmount();
    error InvalidDeposit();
    error CantUnstakeNow();
    error ContractIsPaused();
    error InvalidOperation();
    error CantStakeThatMuch();
    error InvalidParameters();
    error FailedEthTransfer();
    error NotEnoughAllowance();
    error AddressAlreadyInUse();
    error InvalidErc20Transfer();
    error FailedToGiveAllowance();

    /// @dev Constructor
    constructor() {
        _disableInitializers();
    }

    function initialize() initializer public {
        __Ownable_init();
        __UUPSUpgradeable_init();

        // Change on mainnet
        metarix = IToken(0x6990Dc1F84af5335E757Fc392c3f4A2C5B1A4a68);
        
        // Create pools
        pools.push(Pool(0, 1000, 30, 0, true));
        pools.push(Pool(1, 2000, 180, 0, true));
        pools.push(Pool(2, 3000, 365, 0, true));

        aprFactor = 13; // 0.13%
        aprFactorForUsers = 250; // 2.5%

        fee = 10; // 10%
        compoundPeriod = 1 days; // 1 day

        isPaused = false;
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        onlyOwner
        override
    {}

    /// Modifier
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() internal {
        if(enter != 1) revert CantEnter();
        enter = 2;
    }

    function _nonReentrantAfter() internal {
        enter = 1;
    }

    /// @dev Funciton to stake tokens
    /// @param poolId In which pool the user want to stake
    /// @param amount How many tokens the user want to stake
    function stake(uint256 poolId, uint256 amount) external payable nonReentrant {
        _initActionsStaking(poolId, amount);

        _addDeposit(msg.sender, poolId, amount);

        emit Stake(msg.sender, poolId, amount);
    }
    
    /// @dev Function to unstake
    /// @param depositId From which deposit the user want to unstake
    function unstake(uint256 depositId) external payable nonReentrant {
        _initChecks(depositId);

        Deposit storage myDeposit = deposits[depositId];

        address _depositOwner = myDeposit.owner;
        uint256 _endDate = myDeposit.endDate;

        if(msg.sender != _depositOwner) revert InvalidOwner();
        if(myDeposit.ended == true) revert EndedDeposit();
        if(block.timestamp < _endDate) revert CantUnstakeNow();

        uint256 _amount = myDeposit.amount;
        uint256 _poolId = myDeposit.poolId;

        Pool storage myPool = pools[_poolId];

        if(myPool.enabled == false) revert PoolDisabled();

        myDeposit.amount = 0;
        myDeposit.ended = true;

        // Compute rewards
        uint256 _pending = computePendingRewards(_depositOwner, _poolId, depositId, _amount);
        if(registeredRewards - _pending > 0) {
            registeredRewards -= _pending;
        } else revert ZeroBalance();

        // Send rewards
        uint256 _totalAmount = _amount + _pending;
        
        if(metarix.approve(_depositOwner, _totalAmount) != true) revert FailedToGiveAllowance();
        if(metarix.transfer(_depositOwner, _totalAmount) != true) revert InvalidErc20Transfer();

        // Increase the APR by aprFactor% for each new staker
        myPool.apr += aprFactor;
        --myPool.totalStakers;
        totalStakedByPool[_poolId] -= _amount;

        // Set the data for UI
        depositToStakedAmount[depositId] = _amount;
        depositToReceivedRewards[depositId] = _pending;
        

        emit Unstake(msg.sender, _poolId, depositId, _totalAmount);
    }

    /// @dev Function for emergency withdraw
    function emergencyWithdraw(uint256 depositId) external payable nonReentrant {
        _initChecks(depositId);

        Deposit storage myDeposit = deposits[depositId];

        address _depositOwner = myDeposit.owner;

        if(msg.sender != _depositOwner) revert InvalidOwner();
        if(myDeposit.ended == true) revert EndedDeposit();

        uint256 _amount = myDeposit.amount;
        uint256 _poolId = myDeposit.poolId;

        Pool storage myPool = pools[_poolId];

        if(pools[_poolId].enabled == false) revert PoolDisabled();

        myDeposit.amount = 0;
        myDeposit.ended = true;

        // Substract the fee and send the amount
        uint256 _takenFee = _amount * fee / 100;
        uint256 _totalAmount = _amount  - _takenFee;
        
        if(metarix.approve(_depositOwner, _totalAmount) != true) revert FailedToGiveAllowance();
        if(metarix.transfer(myDeposit.owner, _totalAmount) != true) revert InvalidErc20Transfer();

        // Increase the APR by aprFactor% for each new staker
        myPool.apr += aprFactor;
        --myPool.totalStakers;
        totalStakedByPool[_poolId] -= _totalAmount;

        // Set the data for UI
        depositToStakedAmount[depositId] = _amount;
        depositToReceivedRewards[depositId] = 0;

        // Used emergency withdraw
        usedEmergency[msg.sender][depositId] = true;

        emit EmergencyWithdraw(msg.sender, _poolId, depositId, _totalAmount);
    }

    /// @dev Function to compound the pending rewards
    function compound(uint256 depositId) external payable nonReentrant {
        _initChecks(depositId);
        
        Deposit storage myDeposit = deposits[depositId];
        
        address _depositOwner = myDeposit.owner;
        uint256 _endDate = myDeposit.endDate;

        if(msg.sender != _depositOwner) revert InvalidOwner();
        if(block.timestamp > _endDate) revert CantCompound();
        if(lastCompoundDate[_depositOwner] + compoundPeriod > block.timestamp) revert CantCompound();
        if(myDeposit.ended == true) revert EndedDeposit();

        uint256 _amount = myDeposit.amount;
        uint256 _poolId = myDeposit.poolId;
        
        if(pools[_poolId].enabled == false) revert PoolDisabled();

        lastCompoundDate[_depositOwner] = block.timestamp;

        // Compute rewards
        uint256 _pending = computePendingRewards(_depositOwner, _poolId, depositId, _amount);

        registeredRewards -= _pending;

        // Compound
        myDeposit.amount += _pending;
        myDeposit.compounded += _pending;

        emit Compound(msg.sender, _poolId, depositId, _pending);
    }

    /// @dev Function for owner to migrate users from the old smart contract
    function migrate(address[] calldata users, uint256[] calldata amounts, uint256[] calldata poolIds, bool[] calldata isBoosted) external onlyOwner {
        if(users.length != amounts.length && users.length != poolIds.length) revert InvalidParameters();
        if(users.length > 100) revert InvalidParameters();
        
        uint256 _totalAmount;

        for(uint256 i = 0; i < amounts.length;) {
            unchecked {
                _totalAmount += amounts[i];
                ++i;
            }
        }

        if(metarix.allowance(msg.sender, address(this)) < _totalAmount) revert NotEnoughAllowance();
        if(metarix.transferFrom(msg.sender, address(this), _totalAmount) != true) revert InvalidErc20Transfer();

        for(uint256 i = 0; i < users.length;) {
            _addDeposit(users[i], amounts[i], poolIds[i]);

            if(isBoosted[i] == true) _setAprForUser(users[i], true);

            unchecked {
                ++i;
            }
        }
    }

    /// @dev Function to change the apr factor
    function changeAprFactor(uint256 newFactor) external onlyOwner {
        aprFactor = newFactor;

        emit NewAprFactor(newFactor);
    }

    /// @dev Function to change the apr factor
    function changeAprFactorForUsers(uint256 newFactor) external onlyOwner {
        aprFactorForUsers = newFactor;

        emit NewAprFactorForUsers(newFactor);
    }

    /// @dev Function to change the fee for emergency withdraw
    function changeEmergencyFee(uint256 newFee) external onlyOwner {
        fee = newFee;
    
        emit NewEmergencyFee(newFee);
    }

    /// @dev Function to change the compound period
    function changeCompoundPeriod(uint256 newPeriod) external onlyOwner {
        compoundPeriod = newPeriod * 1 hours;

        emit NewCompoundPeriod(newPeriod * 1 hours);
    }

    /// @dev Function to set user with increased apr
    function setIncreasedAprForUser(address user) external onlyOwner {
            _setAprForUser(user, true);

        emit SetIncreasedAprFor(user, true);
    }

    /// @dev Funciton to set users with increased apr
    function setIncreasedAprForUsers(address[] calldata users) external onlyOwner {
        for(uint256 i=0; i< users.length;) {

            _setAprForUser(users[i], true);

            emit SetIncreasedAprFor(users[i], true);

            unchecked { ++i; }
        }
    }

    /// @dev Function to set user with normal apr again
    function setNormalAprForUser(address user) external onlyOwner {
        _setAprForUser(user, false);

        emit SetNormalAprFor(user, false);
    }

    /// @dev Funciton to set users with normal apr again
    function setNormalAprForUsers(address[] calldata users) external onlyOwner {
        for(uint256 i=0; i< users.length;) {

            _setAprForUser(users[i], true);

            emit SetNormalAprFor(users[i], false);
            unchecked { ++i; }
        }
    }

    /// @dev Function to disable a pool
    function disablePool(uint256 poolId) external onlyOwner {
        pools[poolId].enabled = false;

        emit DisablePool(poolId, false);
    }

    /// @dev Function to disable all pools
    function disableAllPools() external onlyOwner {
        for(uint256 i=0; i< pools.length;) {
            pools[i].enabled = false;

            emit DisablePool(i, false);
            unchecked { ++i; }
        }
    }

    /// @dev Function to enable a pool
    function enablePool(uint256 poolId) external onlyOwner {
        pools[poolId].enabled = true;

        emit EnablePool(poolId, true);
    }

    /// @dev Function to disable all pools
    function enableAllPools() external onlyOwner {
        for(uint256 i=0; i< pools.length;) {
            pools[i].enabled = true;

            emit EnablePool(i, true);
            unchecked { ++i; }
        }
    }

    /// @dev Function to set APR for a specific pool
    function setNewApr(uint256 poolId, uint256 newApr) external onlyOwner {
        pools[poolId].apr = newApr;

        emit NewApr(poolId, newApr);
    }

    /// @dev Function to send the staked tokens back to users
    function sendTokensBack() external onlyOwner {
        for(uint256 i = 0; i < deposits.length;) {
            uint256 _amount = deposits[i].amount;
            address _owner = deposits[i].owner;
            deposits[i].amount = 0;
            if(metarix.transfer(_owner, _amount) != true) revert InvalidErc20Transfer();

            emit SendTokensBack(_owner, _amount);
            unchecked { ++i; }
        }
    }

    /// @dev Funciton to add a new pool
    function addPool(uint256 apr, uint256 period) external onlyOwner {
        uint256 _id = pools.length;
        pools.push(Pool(_id, apr, period, 0, true));

        emit AddPool(apr, period);
    }

    /// @dev Function to register the tokens allocated for rewards
    ///      To be called after tokens set for reward are sent to
    ///      this smart contract
    function registerTokensForRewards() external onlyOwner {
        uint256 _balance = metarix.balanceOf(address(this));
        if(_balance == 0) revert ZeroBalance();
        registeredRewards = _balance;
    }

    /// @dev Pause the smart contract
    function togglePause() external onlyOwner {
        if(isPaused == true) {
            isPaused = false;
        } else {
            isPaused = true;
        }

        emit TogglePause(isPaused);
    }

    /// @dev Change the Metarix address in case of migration
    function changeMetarixAddress(address newToken) external onlyOwner {
        if(newToken == address(metarix)) revert AddressAlreadyInUse();
        metarix = IToken(newToken);

        emit NewTokenAddress(newToken);
    }

    /// @dev Function to withdraw tokens from the smart contract
    ///      If the address == metarix, the owner will withdraw the
    ///      rewards only - the user's funds can't be withdrawn
    function withdrawErc20Tokens(address token) external onlyOwner {
        uint256 _balance;

        if(token == address(metarix)) {
            _balance = registeredRewards;
        } else {
            _balance = IToken(token).balanceOf(address(this));
        }

        if(IToken(token).transfer(owner(), _balance) == false) revert InvalidErc20Transfer();

        emit WithdrawErc20Tokens(token, _balance);
    }

    /// @dev Function to rescue BNB
    function rescueBnb() external onlyOwner {
        uint256 _amount = address(this).balance;

        (bool sent, ) = owner().call{value: _amount}("");
        if(sent == false) revert FailedEthTransfer();

        emit RescueBNB(_amount);
    }

    /// @dev Function to fetch user's deposits
    function fetchUsersDeposit(address user) public view returns(uint256[] memory){
        return userDeposits[user];
    }

    /// @dev Function to fetch deposit details
    function fetchDepositDetails(uint256 depositId) public view returns(Deposit memory, bool){
        return (deposits[depositId], usedEmergency[deposits[depositId].owner][depositId]);
    }

    /// @dev Function to fethc pool details
    function fetchPoolDetails(uint256 poolId) public view returns(Pool memory) {
        return pools[poolId];
    }

    /// @dev Funciton to fetch total staked tokens across all pools
    function fetchAllStakedTokens() public view returns(uint256) {
        uint256 totalStaked;
        for(uint256 i=0; i < pools.length;) {
            totalStaked += totalStakedByPool[i];
            unchecked { ++i; }
        }
        return totalStaked;
    }

    /// @dev Function to fetch the staked amount for each deposit
    function fetchTotalStakedByPool(uint256 depositId) public view returns(uint256) {
           return totalStakedByPool[depositId];
    }

    /// @dev Fetch the length of pools
    function fetchPoolsLength() public view returns(uint256) {
        return pools.length;
    }

    /// @dev Fetch the length of deposits
    function fetchDepositsLength() public view returns(uint256) {
        return deposits.length;
    }

    /// @dev Fetch the staked amount and the received rewards after withdraw
    function getStakedAndRewards(uint256 depositId) public view returns(uint256, uint256) {
        return(depositToStakedAmount[depositId], depositToReceivedRewards[depositId]);
    }

    /// @dev Internal function to add a new deposit
    function _addDeposit(address user, uint256 poolId, uint256 amount) internal {
        Pool storage pool = pools[poolId];

        if(pool.enabled == false) revert PoolDisabled();
        uint256 _period = pool.periodInDays * 1 days;


        Deposit memory newDeposit = Deposit(
        deposits.length,
        poolId, 
        amount,
        0,
        block.timestamp,
        block.timestamp + _period,
        user,
        false);

        userDeposits[user].push(deposits.length);
        deposits.push(newDeposit);

        // Analytics
        unchecked {++pool.totalStakers;}

        totalStakedByPool[poolId] += amount;

        pool.apr -= aprFactor;
    }

    /// @dev Internal function to do the initial checks on staking function
    function _initActionsStaking(uint256 poolId, uint256 amount) internal {
        if(isPaused == true) revert ContractIsPaused();
        if(pools.length == 0) revert InvalidPoolId();
        if(poolId >= pools.length - 1) revert InvalidPoolId();
        if(amount == 0) revert InvalidAmount();
        if(metarix.balanceOf(msg.sender) < amount) revert CantStakeThatMuch();
        if(metarix.allowance(msg.sender, address(this)) < amount) revert NotEnoughAllowance();
        if(metarix.transferFrom(msg.sender, address(this), amount) != true) revert InvalidErc20Transfer();
    }

    /// @dev Internal function to check the smart contract's state
    ///      on the "unstake", "emergencyWithdraw" & "compund" functions
    function _initChecks(uint256 depositId) internal view{
        if(isPaused == true) revert ContractIsPaused();
        if(deposits.length == 0) revert InvalidDeposit();
        if(depositId >= deposits.length - 1) revert InvalidDeposit();
    }

    /// @dev Internal function to set the increased APR for users
    function _setAprForUser(address user, bool isIncreased) internal {
        if(hasIncreasedApr[user] == isIncreased) revert InvalidOperation();
        hasIncreasedApr[user] = isIncreased;
    }

    /// @dev Function to compute pending rewards
    /// @return _pendingRewards Return pending rewards
    function computePendingRewards(address user, uint256 poolId, uint256 depositId, uint256 amount) public view returns(uint256) {
        Pool memory pool = pools[poolId];
        Deposit memory deposit = deposits[depositId];

        uint256 _apr = pool.apr;
        uint256 _period = pool.periodInDays;
        uint256 _compounded = deposit.compounded;

        if(hasIncreasedApr[user] == true) {
            _apr += aprFactorForUsers;
        }

        uint256 _rPerYear = (amount * _apr) / 100;
        uint256 _rPerDay = _rPerYear / 365;
        uint256 _rPerHour = _rPerDay / 24;
        uint256 _rPerMinute = _rPerHour / 60;
        uint256 _rPerSecond = _rPerMinute / 60;
        uint256 _pendingRewards;

        // If deposit not ended
        if(block.timestamp < deposit.endDate) {
            uint256 _delta = block.timestamp - deposit.startDate;
            _pendingRewards = (_delta * _rPerSecond) - _compounded;
        } else if(block.timestamp >= deposit.endDate) { // If deposit ended
            _pendingRewards = _rPerDay * _period;
        }
        return _pendingRewards / 100;
    }
}