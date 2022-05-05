// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "./interfaces/IPool.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

/// @title Pool
/// @notice This Smart Contract provides the sale of tokens that will be unlocking until a certain date
/// @dev This Smart Contract provides the sale of tokens that will be unlocking until a certain date
contract Pool is IPool, Ownable {
    using SafeERC20 for IERC20;
    using Math for uint256;

    /// @notice Store amounts of deposits that were paid from recipients
    /// @dev Store amounts of deposits that were paid from recipients
    /// @return Deposit amount that was paid from recipient
    mapping(address => uint256) public override deposited;
    
    /// @notice Store amounts of specific deposit allocations that were allowed for some recipients
    /// @dev Store amounts of specific deposit allocations that were allowed for some recipients
    /// @return Amount of specific allocation for recipient
    mapping(address => uint256) public override rewardsPaid;

    /// @notice Store amounts of specific deposit allocations that were allowed for some recipients
    /// @dev Store amounts of specific deposit allocations that were allowed for some recipients
    /// @return Amount of specific allocation for recipient
    mapping(address => uint256) public override specificAllocation;
    
    /// @notice Store specific vesting data for some recipients
    /// @dev Store specific vesting data for some recipients
    /// return The value of the structure variable VestingInfo (period duration,
    /// count period of vesting, cliff duration, unlock intervals) for recipient
    mapping(address => VestingInfo) public specificVesting;

    /// @notice Store decimals of reward token
    /// @dev Store number of reward token decimals
    /// @return Number of reward token decimals
    uint8 public rewardTokenDecimals;
    
    /// @notice Store decimals of staked token
    /// @dev Store number of staked token decimals
    /// @return Number of staked token decimals
    uint8 public stakedTokenDecimals;
    
    /// @notice Store bool whether the vesting is completed
    /// @dev Store bool whether the vesting is completed
    /// @return Bool whether the vesting is completed
    bool public isCompleted;

    /// @notice Store reward token
    /// @dev Store instance of reward ERC20 token
    IERC20 internal _rewardToken;

    /// @notice Store deposit token
    /// @dev Store instance of deposit ERC20 token
    IERC20 internal _depositToken;

    /// @notice Store initial unlock percentage
    /// @dev Store percentage that will be already unlocked after sale
    uint256 internal _initialPercentage;

    /// @notice Store general allowed minimum allocation to deposit
    /// @dev Store general allowed minimum allocation to deposit
    uint256 internal _minAllocation;

    /// @notice Store general allowed maximum allocation to deposit
    /// @dev Store general allowed maximum allocation to deposit
    uint256 internal _maxAllocation;

    /// @notice Store type of vesting
    /// @dev Store type of vesting that can be swap, linear or interval vesting
    VestingType internal _vestingType;

    /// @notice Store data of vesting
    /// @dev Store period duration, count period of vesting, cliff duration, unlock intervals)
    VestingInfo internal _vestingInfo;

    /// @notice Store the name of vesting
    /// @dev Store the name of vesting
    string internal _name;

    /// @notice Store the total reward supply
    /// @dev Store the total amount of reward tokens
    uint256 internal _totalSupply;

    /// @notice Store the token price
    /// @dev Store the price of one reward token
    uint256 internal _tokenPrice;

    /// @notice Store total deposit amount
    /// @dev Store total amount of deposits that were paid from recipients
    uint256 internal _totalDeposited;

    /// @notice Store start date of sale
    /// @dev Store timestamp value of date when sale will be started
    uint256 internal _startDate;

    /// @notice Store end date of sale
    /// @dev Store timestamp value of date when sale will be ended
    uint256 internal _endDate;

    /// @notice Store constant of percentage 100
    /// @dev Store value of 100 ethers
    uint256 internal constant _MAX_INITIAL_PERCENTAGE = 1e20;
    
    /// @notice Initialization
    /// @dev Initialize contract, grand roles for the deployer
    /// @param name_ The name of vesting
    /// @param rewardToken_ The address of reward token
    /// @param depositToken_ The address of deposit token
    /// @param initialUnlockPercentage_ Percentage in ETH that will be already unlocked after sale
    /// @param minAllocation_ General allowed minimum allocation to deposit
    /// @param maxAllocation_ General allowed maximum allocation to deposit
    /// @param vestingType_ Type of vesting that can be swap, linear or interval vesting
    constructor(
        string memory name_,
        address rewardToken_,
        address depositToken_,
        uint256 initialUnlockPercentage_,
        uint256 minAllocation_,
        uint256 maxAllocation_,
        VestingType vestingType_
    ) {
        require(
            rewardToken_ != address(0) && depositToken_ != address(0),
            "Incorrect token address"
        );
        require(
            minAllocation_ <= maxAllocation_ && maxAllocation_ != 0,
            "Incorrect allocation"
        );
        require(
            initialUnlockPercentage_ <= _MAX_INITIAL_PERCENTAGE,
            "Incorrect initial percentage"
        );

        _initialPercentage = initialUnlockPercentage_;
        _minAllocation = minAllocation_;
        _maxAllocation = maxAllocation_;
        _name = name_;
        _vestingType = vestingType_;
        _rewardToken = IERC20(rewardToken_);
        _depositToken = IERC20(depositToken_);
        rewardTokenDecimals = IERC20Metadata(rewardToken_).decimals();
        stakedTokenDecimals = IERC20Metadata(depositToken_).decimals();
    }

    /// @notice Initialize token
    /// @dev Initialize price and transfered amount of reward tokens
    /// @param tokenPrice_ The price of reward token
    /// @param totalSupply_ The total amount of reward tokens that will be on sale
    function initializeToken(uint256 tokenPrice_, uint256 totalSupply_)
        external
        virtual
        override
        onlyOwner
    {
        require(_tokenPrice == 0, "It was initialized before");
        require(totalSupply_ > 0 && tokenPrice_ > 0, "Incorrect amount");

        _tokenPrice = tokenPrice_;
        _totalSupply = totalSupply_;

        _rewardToken.safeTransferFrom(
            _msgSender(),
            address(this),
            totalSupply_
        );
    }

    /// @notice Increase total amount of reward token
    /// @dev Increase total supply of reward token by the amount
    /// @param amount_ Amount of reward tokens that will be added to total supply
    function increaseTotalSupply(uint256 amount_)
        external
        virtual
        override
        onlyOwner
    {
        _totalSupply += amount_;
        _rewardToken.safeTransferFrom(_msgSender(), address(this), amount_);
        emit IncreaseTotalSupply(amount_);
    }

    /// @notice Initialize dates of sale
    /// @dev Set timestamp values of date when sale will be started and ended
    /// @param startDate_ Start date of sale
    /// @param endDate_ End date of sale
    function setTimePoint(uint256 startDate_, uint256 endDate_)
        external
        virtual
        override
        onlyOwner
    {
        require(
            startDate_ < endDate_ && block.timestamp < startDate_,
            "Incorrect dates"
        );
        _startDate = startDate_;
        _endDate = endDate_;
        emit SetTimePoint(startDate_, endDate_);
    }

    /// @notice Initialize specific allocations for some recipients
    /// @dev Set specific allocation that will be a higher priority than general allocation
    /// @param addrs_ Address array of recipients
    /// @param amount_ Amount array of allocations for each recipient
    function setSpecificAllocation(
        address[] calldata addrs_,
        uint256[] calldata amount_
    ) external virtual override onlyOwner {
        require(addrs_.length == amount_.length, "Different array size");

        for (uint256 index = 0; index < addrs_.length; index++) {
            specificAllocation[addrs_[index]] = amount_[index];
        }
        emit SetSpecificAllocation(addrs_, amount_);
    }

    /// @notice Initialize general vesting
    /// @dev Set vesting parameters for each recipient
    /// @param periodDuration_ Each period's duration for linear vesting
    /// @param countPeriodOfVesting_ Number of periods for linear vesting
    /// @param cliffDuration_ Period duration after sale during which no rewards are given for linear vesting
    /// @param intervals_ An array of structures that stores both the date and amount of unlocking for interval vesting
    function setVesting(
        uint256 periodDuration_,
        uint256 countPeriodOfVesting_,
        uint256 cliffDuration_,
        Interval[] calldata intervals_
    ) external virtual override onlyOwner {
        VestingInfo storage info = _vestingInfo;
        _setVesting(
            info,
            periodDuration_,
            countPeriodOfVesting_,
            cliffDuration_,
            intervals_
        );
    }

    /// @notice Initialize specific vesting for the recipient
    /// @dev Set specific vesting that will be a higher priority than general vesting
    /// @param addr_ Address of recipient that will have specific vesting
    /// @param periodDuration_ Each period's duration for linear vesting
    /// @param countPeriodOfVesting_ Number of periods for linear vesting
    /// @param cliffDuration_ Period duration after sale during which no rewards are given for linear vesting
    /// @param intervals_ An array of structures that stores both the date and amount of unlocking for interval vesting
    function setSpecificVesting(
        address addr_,
        uint256 periodDuration_,
        uint256 countPeriodOfVesting_,
        uint256 cliffDuration_,
        Interval[] calldata intervals_
    ) external virtual override onlyOwner {
        VestingInfo storage info = specificVesting[addr_];
        require(
            !(info.countPeriodOfVesting > 0 || info.unlockIntervals.length > 0),
            "It was initialized before"
        );
        _setVesting(
            info,
            periodDuration_,
            countPeriodOfVesting_,
            cliffDuration_,
            intervals_
        );
    }

    /// @notice Increase deposit amount of some recipients
    /// @dev Add deposit amounts to some recipients' deposit amounts
    /// @param addrArr_ Address array of recipients
    /// @param amountArr_ Amount array of deposits for each recipient
    function addDepositAmount(
        address[] calldata addrArr_,
        uint256[] calldata amountArr_
    ) external virtual override onlyOwner {
        require(addrArr_.length == amountArr_.length, "Incorrect array length");
        require(!_isVestingStarted(), "Sale is closed");

        uint256 remainingAllocation = _totalSupply -
            convertToToken(_totalDeposited);

        for (uint256 index = 0; index < addrArr_.length; index++) {
            uint256 convertAmount = convertToToken(amountArr_[index]);
            require(
                convertAmount <= remainingAllocation,
                "Not enough allocation"
            );

            remainingAllocation -= convertAmount;
            deposited[addrArr_[index]] += amountArr_[index];
            _totalDeposited += amountArr_[index];
        }
        emit Deposits(addrArr_, amountArr_);
    }

    /// @notice Complete the vesting and transfer all funds and unsold rewards to vesting owner
    /// @dev Complete the vesting and transfer all funds and unsold rewards to vesting owner
    function completeVesting() external virtual override onlyOwner {
        require(_isVestingStarted(), "Vesting cannot be started");
        require(!isCompleted, "Completing was called before");
        isCompleted = true;

        uint256 soldToken = convertToToken(_totalDeposited);

        if (soldToken < _totalSupply)
            _rewardToken.safeTransfer(_msgSender(), _totalSupply - soldToken);

        uint256 balance = _depositToken.balanceOf(address(this));
        _depositToken.safeTransfer(_msgSender(), balance);
    }

    /// @notice Deposit some amount of deposit token
    /// @dev Transfer amount of deposit token signing the transaction
    /// @param amount_ The amount of deposit to be made
    function deposit(uint256 amount_) external virtual override {
        require(_isSale(), "Sale is closed");
        require(_isValidAmount(amount_), "Invalid amount");

        deposited[_msgSender()] += amount_;
        _totalDeposited += amount_;

        uint256 transferAmount = _convertToCorrectDecimals(
            amount_,
            rewardTokenDecimals,
            stakedTokenDecimals
        );
        _depositToken.safeTransferFrom(
            _msgSender(),
            address(this),
            transferAmount
        );

        if (VestingType.SWAP == _vestingType) {
            uint256 tokenAmount = convertToToken(amount_);
            rewardsPaid[_msgSender()] += tokenAmount;
            _rewardToken.safeTransfer(_msgSender(), tokenAmount);
            emit Harvest(_msgSender(), tokenAmount);
        }

        emit Deposit(_msgSender(), amount_);
    }

    /// @notice Harvest rewards for the recipient
    /// @dev Harvest rewards to specified recipient address
    /// @param _addr The address of recipient
    function harvestFor(address _addr) external virtual override {
        _harvest(_addr, 0);
    }

    /// @notice Harvest rewards for sender
    /// @dev Harvest rewards to sender address
    function harvest() external virtual override {
        _harvest(_msgSender(), 0);
    }

    /// @notice Harvest rewards for the sender with interval index
    /// @dev Harvest rewards to the sender address with interval index
    /// @param intervalIndex The index of interval that is already unlocked
    function harvestInterval(uint256 intervalIndex) external virtual override {
        _harvest(_msgSender(), intervalIndex);
    }

    /// @notice Get an available deposit range
    /// @dev Get available amounts to deposit for addresses with general and specific allocations
    /// @param addr_ The address of recipient
    /// @return minAvailAllocation Allowed minimum allocation to deposit
    /// @return maxAvailAllocation Allowed maximum allocation to deposit
    function getAvailAmountToDeposit(address addr_)
        external
        view
        virtual
        override
        returns (uint256 minAvailAllocation, uint256 maxAvailAllocation)
    {
        uint256 totalCurrency = convertToCurrency(_totalSupply);

        if (totalCurrency <= _totalDeposited) {
            return (0, 0);
        }

        uint256 depositedAmount = deposited[addr_];

        uint256 remaining = totalCurrency - _totalDeposited;

        uint256 maxAllocation = specificAllocation[addr_] > 0
            ? specificAllocation[addr_]
            : _maxAllocation;
        maxAvailAllocation = depositedAmount < maxAllocation
            ? Math.min(maxAllocation - depositedAmount, remaining)
            : 0;
        minAvailAllocation = depositedAmount == 0 ? _minAllocation : 0;
    }

    /// @notice Get general data
    /// @dev Get general variables of contract that were setted during initialization
    /// @return name The name of vesting
    /// @return stakedToken The address of deposit token
    /// @return rewardToken The address of reward token
    /// @return minAllocation General allowed minimum allocation to deposit
    /// @return maxAllocation General allowed maximum allocation to deposit
    /// @return totalSupply The total amount of reward tokens
    /// @return totalDeposited Total deposit amount
    /// @return tokenPrice The price of one reward token
    /// @return initialUnlockPercentage Percentage in ETH that will be already unlocked after sale
    /// @return vestingType Type of vesting that can be swap, linear or interval vesting
    function getInfo()
        external
        view
        virtual
        override
        returns (
            string memory name,
            address stakedToken,
            address rewardToken,
            uint256 minAllocation,
            uint256 maxAllocation,
            uint256 totalSupply,
            uint256 totalDeposited,
            uint256 tokenPrice,
            uint256 initialUnlockPercentage,
            VestingType vestingType
        )
    {
        return (
            _name,
            address(_depositToken),
            address(_rewardToken),
            _minAllocation,
            _maxAllocation,
            _totalSupply,
            _totalDeposited,
            _tokenPrice,
            _initialPercentage,
            _vestingType
        );
    }

    /// @notice Get dates of sale
    /// @dev Get timestamp values of date when sale will be started and ended
    /// @return startDate Start date of sale
    /// @return endDate End date of sale
    function getTimePoint()
        external
        view
        virtual
        override
        returns (
            uint256 startDate,
            uint256 endDate
        )
    {
        return (_startDate, _endDate);
    }

    /// @notice Get vesting data
    /// @dev Get variables of contract that stored info about unlocking reward dates
    /// @return periodDuration Each period's duration for linear vesting
    /// @return countPeriodOfVesting Number of periods for linear vesting
    /// @return intervals An array of structures that stores both the date and amount of unlocking for interval vesting
    function getVestingInfo()
        external
        view
        virtual
        override
        returns (
            uint256 periodDuration,
            uint256 countPeriodOfVesting,
            Interval[] memory intervals
        )
    {
        VestingInfo memory info = _vestingInfo;
        uint256 size = info.unlockIntervals.length;
        intervals = new Interval[](size);

        for (uint256 i = 0; i < size; i++) {
            intervals[i] = info.unlockIntervals[i];
        }
        periodDuration = info.periodDuration;
        countPeriodOfVesting = info.countPeriodOfVesting;
    }

    /// @notice Get balance information to the recipient
    /// @dev Get recipient's data about locked/unlocked amounts of rewards token at the moment
    /// @param addr_ The address of recipient
    /// @return lockedBalance Amount of reward tokens that have not unlocked yet
    /// @return unlockedBalance Amount of reward tokens that recipient can withdraw right now
    function getBalanceInfo(address addr_)
        external
        view
        virtual
        override
        returns (uint256 lockedBalance, uint256 unlockedBalance)
    {
        uint256 tokenBalance = convertToToken(deposited[addr_]);

        if (!_isVestingStarted()) {
            return (tokenBalance, 0);
        }

        uint256 unlock = _calculateUnlock(addr_, 0);
        return (tokenBalance - unlock - rewardsPaid[addr_], unlock);
    }

    /// @notice Convert some amount of deposit tokens to reward tokens amount
    /// @dev Convert some amount of deposit tokens to reward tokens amount
    /// @param amount_ The amount of deposit tokens
    /// @return Amount of reward tokens
    function convertToToken(uint256 amount_)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return (amount_ * 10**rewardTokenDecimals) / _tokenPrice;
    }

    /// @notice Convert some amount of reward tokens to deposit tokens amount
    /// @dev Convert some amount of reward tokens to deposit tokens amount
    /// @param amount_ The amount of reward tokens
    /// @return Amount of deposit tokens
    function convertToCurrency(uint256 amount_)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return (amount_ * _tokenPrice) / 10**rewardTokenDecimals;
    }

    /// @notice Initialize vesting data
    /// @dev Set vesting parameters for recipients
    /// @param info Default vesting values
    /// @param periodDuration_ Each period's duration for linear vesting
    /// @param countPeriodOfVesting_ Number of periods for linear vesting
    /// @param cliffDuration_ Period duration after sale during which no rewards are given for linear vesting
    /// @param _intervals An array of structures that stores both the date and amount of unlocking for interval vesting
    function _setVesting(
        VestingInfo storage info,
        uint256 periodDuration_,
        uint256 countPeriodOfVesting_,
        uint256 cliffDuration_,
        Interval[] calldata _intervals
    ) internal virtual {
        if (VestingType.LINEAR_VESTING == _vestingType) {
            require(
                countPeriodOfVesting_ > 0 && periodDuration_ > 0,
                "Incorrect linear vesting setup"
            );
            info.periodDuration = periodDuration_;
            info.countPeriodOfVesting = countPeriodOfVesting_;
            info.cliffDuration = cliffDuration_;
        } else {
            delete info.unlockIntervals;
            uint256 lastUnlockingPart = _initialPercentage;
            uint256 lastIntervalStartingTimestamp = _endDate;
            for (uint256 i = 0; i < _intervals.length; i++) {
                uint256 percent = _intervals[i].percentage;
                require(
                    percent > lastUnlockingPart &&
                        percent <= _MAX_INITIAL_PERCENTAGE,
                    "Invalid interval unlocking part"
                );
                require(
                    _intervals[i].timestamp > lastIntervalStartingTimestamp,
                    "Invalid interval starting timestamp"
                );
                lastUnlockingPart = percent;
                info.unlockIntervals.push(_intervals[i]);
            }
            require(
                lastUnlockingPart == _MAX_INITIAL_PERCENTAGE,
                "Invalid interval unlocking part"
            );
        }
    }

    /// @notice Harvest rewards for the recipient with interval index
    /// @dev Harvest rewards to the recipient address with interval index
    /// @param _addr The address of recipient
    /// @param intervalIndex The index of interval that is already unlocked
    function _harvest(address _addr, uint256 intervalIndex) internal virtual {
        require(_isVestingStarted(), "Vesting can't be started");

        uint256 amountToTransfer = _calculateUnlock(_addr, intervalIndex);

        require(amountToTransfer > 0, "Amount is zero");

        rewardsPaid[_addr] += amountToTransfer;

        _rewardToken.safeTransfer(_addr, amountToTransfer);

        emit Harvest(_addr, amountToTransfer);
    }

    /// @notice Compute unlocking amount of reward tokens to recipient
    /// @dev Compute unlocking amount of reward tokens to recipient for interval or linear vesting
    /// @param addr_ The address of recipient
    /// @param intervalIndex_ The index of interval that is already unlocked
    /// @return Unlocked amount of reward tokens
    function _calculateUnlock(address addr_, uint256 intervalIndex_)
        internal
        view
        virtual
        returns (uint256)
    {
        uint256 tokenAmount = convertToToken(deposited[addr_]);
        uint256 oldRewards = rewardsPaid[addr_];

        VestingInfo memory info = specificVesting[addr_].periodDuration > 0 ||
            specificVesting[addr_].unlockIntervals.length > 0
            ? specificVesting[addr_]
            : _vestingInfo;

        if (VestingType.LINEAR_VESTING == _vestingType) {
            tokenAmount = _calculateLinearUnlock(info, tokenAmount);
        } else if (VestingType.INTERVAL_VESTING == _vestingType) {
            tokenAmount = _calculateIntervalUnlock(
                info.unlockIntervals,
                tokenAmount,
                intervalIndex_
            );
        }
        return tokenAmount > oldRewards ? tokenAmount - oldRewards : 0;
    }
    
    /// @notice Compute unlocking amount of reward tokens to recipient for linear vesting
    /// @dev Compute unlocking amount of reward tokens to recipient for linear vesting
    /// @param info Vesting data (general or specific)
    /// @param tokenAmount Available reward token amount
    /// @return Unlocked amount of reward tokens
    function _calculateLinearUnlock(
        VestingInfo memory info,
        uint256 tokenAmount
    ) internal view virtual returns (uint256) {
        if (block.timestamp > _endDate + info.cliffDuration) {
            uint256 initialUnlockAmount = (tokenAmount * _initialPercentage) /
                _MAX_INITIAL_PERCENTAGE;
            uint256 passePeriod = Math.min(
                (block.timestamp - _endDate - info.cliffDuration) /
                    info.periodDuration,
                info.countPeriodOfVesting
            );
            return
                (((tokenAmount - initialUnlockAmount) * passePeriod) /
                    info.countPeriodOfVesting) + initialUnlockAmount;
        } else {
            return 0;
        }
    }

    /// @notice Compute unlocking amount of reward tokens to recipient for interval vesting
    /// @dev Compute unlocking amount of reward tokens to recipient for interval vesting
    /// @param intervals An array of structures that stores both the date and amount of unlocking for interval vesting
    /// @param tokenAmount Available reward token amount
    /// @param intervalIndex The index of interval that is already unlocked
    /// @return Unlocked amount of reward tokens
    function _calculateIntervalUnlock(
        Interval[] memory intervals,
        uint256 tokenAmount,
        uint256 intervalIndex
    ) internal view virtual returns (uint256) {
        uint256 unlockPercentage = _initialPercentage;
        if (intervalIndex > 0) {
            require(
                intervals[intervalIndex].timestamp < block.timestamp,
                "Incorrect interval index"
            );
            unlockPercentage = intervals[intervalIndex].percentage;
        } else {
            for (uint256 i = 0; i < intervals.length; i++) {
                if (block.timestamp > intervals[i].timestamp) {
                    unlockPercentage = intervals[i].percentage;
                } else {
                    break;
                }
            }
        }

        return (tokenAmount * unlockPercentage) / _MAX_INITIAL_PERCENTAGE;
    }

    /// @notice Define if vesting is started
    /// @dev Define if current date will be greater than end date of sale
    /// @return Bool whether vesting is started
    function _isVestingStarted() internal view returns (bool) {
        return block.timestamp > _endDate && _endDate != 0;
    }

    /// @notice Define if sale is started
    /// @dev Define if current date will be greater than start date of sale and less than end date
    /// @return Bool whether sale is started
    function _isSale() internal view returns (bool) {
        return block.timestamp >= _startDate && block.timestamp < _endDate;
    }

    /// @notice Define if amount to deposit is validate
    /// @dev Define if deposit amount is in allocation range and not greater than remaining amount
    /// @return Bool whether amount is valid
    function _isValidAmount(uint256 amount_) internal view returns (bool) {
        uint256 maxAllocation = specificAllocation[_msgSender()] > 0
            ? specificAllocation[_msgSender()]
            : _maxAllocation;
        uint256 depositAmount = deposited[_msgSender()];
        uint256 remainingAmount = Math.min(
            maxAllocation - depositAmount,
            convertToCurrency(_totalSupply) - _totalDeposited
        );
        return
            (amount_ < _minAllocation && depositAmount == 0) ||
                (amount_ > maxAllocation || amount_ > remainingAmount)
                ? false
                : true;
    }

    /// @notice Change decimals of some amount
    /// @dev Multiply or divide some amount by difference of decimals
    /// @param amount_ The amount that should change its decimals
    /// @param fromDecimals_ Decimals before convering
    /// @param toDecimals_ Decimals after convering
    /// @return Modified amount
    function _convertToCorrectDecimals(
        uint256 amount_,
        uint256 fromDecimals_,
        uint256 toDecimals_
    ) internal pure returns (uint256) {
        if (fromDecimals_ < toDecimals_) {
            amount_ = amount_ * (10**(toDecimals_ - fromDecimals_));
        } else if (fromDecimals_ > toDecimals_) {
            amount_ = amount_ / (10**(fromDecimals_ - toDecimals_));
        }
        return amount_;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

/// @title IPool
/// @notice There is an interface for Pool Smart Contract that provides the sale of tokens
/// that will be unlocking until a certain date
/// @dev There are provided all events and function prototypes for Pool SC
interface IPool {
    /// @notice Types' enumeration of vesting
    /// @dev Types' enumeration of vesting
    enum VestingType {
        SWAP,
        LINEAR_VESTING,
        INTERVAL_VESTING
    }

    /// @notice Structured data type for variables that store information about intervals of interval vesting
    /// @dev Structured data type for variables that store information about intervals of interval vesting
    struct Interval {
        uint256 timestamp;
        uint256 percentage;
    }

    /// @notice Structured data type for variables that store information about vesting
    /// @dev Structured data type for variables that store information about vesting
    struct VestingInfo {
        uint256 periodDuration;
        uint256 countPeriodOfVesting;
        uint256 cliffDuration;
        Interval[] unlockIntervals;
    }

    /// @notice Emit when recipient gets unlocked reward tokens
    /// @dev Emit when specified recipient (harvestFor(address of recipient)) or
    /// sender (msg.sender from harvest()) gets unlocked reward tokens
    /// @param sender The address of recipient who got his rewards
    /// @param amount The amount of transfered rewards
    event Harvest(address indexed sender, uint256 amount);

    /// @notice Emit when recipient deposits his fund on sale
    /// @dev Emit when sender deposit his fund successfully
    /// @param sender The address of recipient who deposited
    /// @param amount The amount of transfered fund
    event Deposit(address indexed sender, uint256 amount);
    
    /// @notice Emit when owner increases deposit amount of some recipients
    /// @dev Emit when owner adds deposit amounts to some recipients' deposit amounts
    /// @param senders Address array of recipients
    /// @param amounts Amount array of deposits for each recipient
    event Deposits(address[] indexed senders, uint256[] amounts);
    
    /// @notice Emit when owner initializes specific allocations for some recipients
    /// @dev Emit when owner sets specific allocation that will be a higher priority than general allocation
    /// @param users Address array of recipients
    /// @param allocation Amount array of allocations for each recipient
    event SetSpecificAllocation(address[] users, uint256[] allocation);
    
    /// @notice Emit when owner increases total amount of reward token
    /// @dev Emit when owner increases total supply of reward token by the amount
    /// @param amount Amount of reward tokens that will be added to total supply
    event IncreaseTotalSupply(uint256 amount);

    /// @notice Emit when owner initializes dates of sale
    /// @dev Emit when owner sets timestamp values of date when sale will be started and ended
    /// @param startDate Start date of sale
    /// @param endDate End date of sale
    event SetTimePoint(uint256 startDate, uint256 endDate);

    /// @notice Initialize token
    /// @dev Initialize price and transfered amount of reward tokens
    /// @param tokenPrice_ The price of reward token
    /// @param totalSupply_ The total amount of reward tokens that will be on sale
    function initializeToken(uint256 tokenPrice_, uint256 totalSupply_)
        external;

    /// @notice Increase total amount of reward token
    /// @dev Increase total supply of reward token by the amount
    /// @param amount_ Amount of reward tokens that will be added to total supply
    function increaseTotalSupply(uint256 amount_) external;

    /// @notice Initialize dates of sale
    /// @dev Set timestamp values of date when sale will be started and ended
    /// @param startDate_ Start date of sale
    /// @param endDate_ End date of sale
    function setTimePoint(uint256 startDate_, uint256 endDate_) external;

    /// @notice Initialize specific allocations for some recipients
    /// @dev Set specific allocation that will be a higher priority than general allocation
    /// @param addrs_ Address array of recipients
    /// @param amount_ Amount array of allocations for each recipient
    function setSpecificAllocation(
        address[] calldata addrs_,
        uint256[] calldata amount_
    ) external;

    /// @notice Initialize specific vesting for the recipient
    /// @dev Set specific vesting that will be a higher priority than general vesting
    /// @param addr_ Address of recipient that will have specific vesting
    /// @param periodDuration_ Each period's duration for linear vesting
    /// @param countPeriodOfVesting_ Number of periods for linear vesting
    /// @param cliffPeriod_ Period duration after sale during which no rewards are given for linear vesting
    /// @param intervals_ An array of structures that stores both the date and amount of unlocking for interval vesting
    function setSpecificVesting(
        address addr_,
        uint256 periodDuration_,
        uint256 countPeriodOfVesting_,
        uint256 cliffPeriod_,
        Interval[] calldata intervals_
    ) external;

    /// @notice Initialize general vesting
    /// @dev Set vesting parameters for each recipient
    /// @param periodDuration_ Each period's duration for linear vesting
    /// @param countPeriodOfVesting_ Number of periods for linear vesting
    /// @param cliffPeriod_ Period duration after sale during which no rewards are given for linear vesting
    /// @param intervals_ An array of structures that stores both the date and amount of unlocking for interval vesting
    function setVesting(
        uint256 periodDuration_,
        uint256 countPeriodOfVesting_,
        uint256 cliffPeriod_,
        Interval[] calldata intervals_
    ) external;

    /// @notice Increase deposit amount of some recipients
    /// @dev Add deposit amounts to some recipients' deposit amounts
    /// @param addrArr_ Address array of recipients
    /// @param amountArr_ Amount array of deposits for each recipient
    function addDepositAmount(
        address[] calldata addrArr_,
        uint256[] calldata amountArr_
    ) external;

    /// @notice Complete the vesting and transfer all funds and unsold rewards to vesting owner
    /// @dev Complete the vesting and transfer all funds and unsold rewards to vesting owner
    function completeVesting() external;

    /// @notice Deposit some amount of deposit token
    /// @dev Transfer amount of deposit token signing the transaction
    /// @param amount_ The amount of deposit to be made
    function deposit(
        uint256 amount_
    ) external;

    /// @notice Harvest rewards for the recipient
    /// @dev Harvest rewards to specified recipient address
    /// @param addr_ The address of recipient
    function harvestFor(address addr_) external;

    /// @notice Harvest rewards for sender
    /// @dev Harvest rewards to sender address
    function harvest() external;

    /// @notice Harvest rewards for the sender with interval index
    /// @dev Harvest rewards to the sender address with interval index
    /// @param intervalIndex The index of interval that is already unlocked
    function harvestInterval(uint256 intervalIndex) external;

    /// @notice Get an available deposit range
    /// @dev Get available amounts to deposit for addresses with general and specific allocations
    /// @param addr_ The address of recipient
    /// @return minAvailAllocation Allowed minimum allocation to deposit
    /// @return maxAvailAllocation Allowed maximum allocation to deposit
    function getAvailAmountToDeposit(address addr_)
        external
        view
        returns (uint256 minAvailAllocation, uint256 maxAvailAllocation);

    /// @notice Get general data
    /// @dev Get general variables of contract that were setted during initialization
    /// @return name The name of vesting
    /// @return stakedToken The address of deposit token
    /// @return rewardToken The address of reward token
    /// @return minAllocation General allowed minimum allocation to deposit
    /// @return maxAllocation General allowed maximum allocation to deposit
    /// @return totalSupply The total amount of reward tokens
    /// @return totalDeposited Total deposit amount
    /// @return tokenPrice The price of one reward token
    /// @return initialUnlockPercentage Percentage in ETH that will be already unlocked after sale
    /// @return vestingType Type of vesting that can be swap, linear or interval vesting
    function getInfo()
        external
        view
        returns (
            string memory name,
            address stakedToken,
            address rewardToken,
            uint256 minAllocation,
            uint256 maxAllocation,
            uint256 totalSupply,
            uint256 totalDeposited,
            uint256 tokenPrice,
            uint256 initialUnlockPercentage,
            VestingType vestingType
        );

    /// @notice Get vesting data
    /// @dev Get variables of contract that stored info about unlocking reward dates
    /// @return periodDuration Each period's duration for linear vesting
    /// @return countPeriodOfVesting Number of periods for linear vesting
    /// @return intervals An array of structures that stores both the date and amount of unlocking for interval vesting
    function getVestingInfo()
        external
        view
        returns (
            uint256 periodDuration,
            uint256 countPeriodOfVesting,
            Interval[] memory intervals
        );

    /// @notice Get balance information to the recipient
    /// @dev Get recipient's data about locked/unlocked amounts of rewards token at the moment
    /// @param addr_ The address of recipient
    /// @return lockedBalance Amount of reward tokens that have not unlocked yet
    /// @return unlockedBalance Amount of reward tokens that recipient can withdraw right now
    function getBalanceInfo(address addr_)
        external
        view
        returns (uint256 lockedBalance, uint256 unlockedBalance);

    /// @notice Convert some amount of deposit tokens to reward tokens amount
    /// @dev Convert some amount of deposit tokens to reward tokens amount
    /// @param amount_ The amount of deposit tokens
    /// @return Amount of reward tokens
    function convertToToken(uint256 amount_) external view returns (uint256);

    /// @notice Convert some amount of reward tokens to deposit tokens amount
    /// @dev Convert some amount of reward tokens to deposit tokens amount
    /// @param amount_ The amount of reward tokens
    /// @return Amount of deposit tokens
    function convertToCurrency(uint256 amount_) external view returns (uint256);

    /// @notice Get dates of sale
    /// @dev Get timestamp values of date when sale will be started and ended
    /// @return startDate Start date of sale
    /// @return endDate End date of sale
    function getTimePoint()
        external
        view
        returns (uint256 startDate, uint256 endDate);

    /// @notice Get amounts of deposits that were paid from recipients
    /// @dev Get amounts of deposits that were paid from recipients
    /// @return Deposit amount that was paid from recipient
    function deposited(address) external view returns (uint256);

    /// @notice Get amounts of reward tokens that were paid to recipients
    /// @dev Get amounts of reward tokens that were paid to recipients
    /// @return Reward amount that was paid to recipient
    function rewardsPaid(address) external view returns (uint256);

    /// @notice Get amounts of specific deposit allocations that were allowed for some recipients
    /// @dev Get amounts of specific deposit allocations that were allowed for some recipients
    /// @return Amount of specific allocation for recipient
    function specificAllocation(address) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a / b + (a % b == 0 ? 0 : 1);
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
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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