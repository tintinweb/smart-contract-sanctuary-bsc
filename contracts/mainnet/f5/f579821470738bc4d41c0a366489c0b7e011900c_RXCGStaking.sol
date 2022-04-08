// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;
import "./IBEP20.sol";
import "./Pausable.sol";
import "./SafeBEP20.sol";

contract RXCGStaking is Pausable {
    using SafeBEP20 for IBEP20;

    modifier onlyAdmin() {
        require(_admins[_msgSender()], "Requires Admin");
        _;
    }
	
	/*///////////////////////////////////////////////////////////////
                    Global STATE
    //////////////////////////////////////////////////////////////*/

    IBEP20 private _token;
    mapping(address => StakingParams) private _staking;
    address[] private _stakingLookup;
    StakingOption[] private _allowedOptions;
    mapping(address => bool) private _admins;
    uint private _totalValueLocked;
    uint private _totalValueLockedAllTime;
    uint private _totalRewardsPayed;
    uint private _totalForPayout;
    uint private _maxStakingAmount = 1000000;
    uint private _minStakingAmount = 10;

    /**
     * @dev The contract constructor needs an address `tokenAddress` for the IBEP20 _token on which staking is conducted. 
     */
    constructor(address tokenAddress) {
        require(tokenAddress != address(0), "Wrong address");
        _token = IBEP20(tokenAddress);
        _admins[_msgSender()] = true;
        _init();
    }

    /*///////////////////////////////////////////////////////////////
                    DATA STRUCTURES 
    //////////////////////////////////////////////////////////////*/
	
    /**
     * @dev `StakingOption`  Represent allowed configurations for the staking platform.
     */
    struct StakingOption {
        uint duration; //in days
        uint apy; //in percentage 1.23% => 123, 12.34% => 1234, 123.45% => 12345
        uint penalty; //in percentage 1.23% => 123, 12.34% => 1234, 123.45% => 12345
        bool allowed;
    }

    /**
     * @dev `StakingPrams` Represents one instance of staking conducted on the platform.
     */
    struct StakingParams {
        uint created;
        uint duration; //in days
        uint apy; //in percentage 1.23% => 123, 12.34% => 1234, 123.45% => 12345
        uint penalty; //in percentage 1.23% => 123, 12.34% => 1234, 123.45% => 12345
        uint baseAmount;
        bool claimed;
        bool blocked;
    }

    /**
     * @dev `StakingParamsView` Represents view of one StakingParams, mainly used in frontend. 
     */
    struct StakingParamsView {
        address addr;
        uint created;
        uint expire;
        uint amountWithIntrest;
        uint amountWithPenalty;
        uint apy; //in percentage 1.23% => 123, 12.34% => 1234, 123.45% => 12345
        uint baseAmount;
    }

	/*///////////////////////////////////////////////////////////////
                    PUBLIC FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    
	/**
     * @dev Creates user stake by creating `StakingParams`.
     * `StakingParams` is created based on selected `StakingOption` and `amount`.
     * StakingOption is selected by `stakingOptionId` parameter. 
     * Returns `StakingParamView`.
     * Emits `Staked` event. 
     */
    function deposit(uint stakingOptionId, uint amount) external whenNotPaused returns(StakingParamsView memory) {
        checkDepositRequirements(_msgSender(), stakingOptionId, amount);
        StakingOption memory options = _allowedOptions[stakingOptionId];
        _staking[_msgSender()]=StakingParams(block.timestamp, options.duration, options.apy, options.penalty, amount, false, false);
        StakingParamsView memory stakingParamsView=viewStake(_msgSender());
        _stakingLookup.push(_msgSender());
        _increaseTotalValueLocked(amount,stakingParamsView.amountWithIntrest);
        emit Staked(_msgSender(), amount, stakingParamsView.expire, stakingParamsView.amountWithIntrest);
        _token.safeTransferFrom(_msgSender(), address(this), amount);
        return stakingParamsView;
    }
	
	/**
     * @dev Allows sender to withdraw staking if it has expired. 
     * Returns `bool`, which indicates the success of withdrawal. 
     * Emits `Claimed` event. 
     */
    function claim() external whenNotPaused returns(bool) {
        require(canWithdraw(_msgSender()), "Premature withdrawal");
        StakingParams memory stakingParams=_staking[_msgSender()];
        uint amount = calculateWithInterest(stakingParams.baseAmount,stakingParams.apy,stakingParams.duration);
        _decreaseTotalValueLocked(stakingParams.baseAmount, amount,false);
        _withdrawal(amount);
        return true;
    }

    /**
     * @dev Allows sender to withdraw staking before it has expired.
     * A penalty is applied. 
     * Returns bool, which indicates the success of withdrawal. 
     * Emits `Claimed` and `ClaimedWithPenalty` events. 
     */
    function claimWithPenalty() external whenNotPaused returns(bool) {
        require(stakeExists(_msgSender()), "Not found");
        StakingParams memory stakingParams=_staking[_msgSender()];
        require(!stakingParams.blocked, "Suspended");
        uint expiration = getDateFrom(stakingParams.created,stakingParams.duration);
        require(expiration >= block.timestamp, "Already expired");
        uint amount = calculateWithPenalty(stakingParams.baseAmount,stakingParams.penalty);
        uint amountWithInterest=calculateWithInterest(stakingParams.baseAmount,stakingParams.apy,stakingParams.duration);
        _decreaseTotalValueLocked(stakingParams.baseAmount,amountWithInterest,true);
        emit ClaimedWithPenalty(_msgSender(), stakingParams.baseAmount, expiration, block.timestamp, stakingParams.baseAmount - amount);
        _withdrawal(amount);
        return true;
    }

    /*///////////////////////////////////////////////////////////////
                    VIEWERS
    //////////////////////////////////////////////////////////////*/
	
    /**
     * @dev Checks does sender meet requirements to deposit `amount` with StakingOption selected by `stakingOptionId`.
     */
    function checkDepositRequirements(address addr, uint stakingOptionId, uint amount) public view {
        require(_minStakingAmount <= amount && amount <= _maxStakingAmount, "Invalid amount");
        require(!stakeExists(addr), "Stake exists");
        require(stakingOptionId < _allowedOptions.length, "Wrong index");
        require(_allowedOptions[stakingOptionId].allowed, "Invalid option");
        require(_token.allowance(addr, address(this)) >= amount, "Approve first");
    }

    /**
     * @dev Creates `StakingParamView` based on `StakingParams`, stored in the contract for address `addr`.
     */
    function viewStake(address addr) public view returns(StakingParamsView memory) {
        require(stakeExists(addr), "Not found");
        StakingParams memory stakingParams=_staking[addr];
        return StakingParamsView(addr, stakingParams.created, getDateFrom(stakingParams.created, stakingParams.duration), calculateWithInterest(stakingParams.baseAmount,stakingParams.apy,stakingParams.duration), calculateWithPenalty(stakingParams.baseAmount,stakingParams.penalty), stakingParams.apy,stakingParams.baseAmount);
    }

    /**
     * @dev Checks can `addr` withdraw tokens. 
     * Returns bool which indicates is `addr` allowed to withdrawal tokens without penalty.
     * Function checks is addr temporally suspended, is stake claimed and is stake expired 
     */
    function canWithdraw(address addr) public view returns(bool) {
        require(stakeExists(addr), "Not found");
        require(!_staking[addr].blocked, "Suspended");
        uint expiration = getDateFrom(_staking[addr].created, _staking[addr].duration);
        return expiration <= block.timestamp;
    }

	/**
     * @dev Checks does sender have already staked tokens in the contract for address `addr`.
     */
    function stakeExists(address addr) public view returns(bool) {
        return _staking[addr].created > 0 && !_staking[addr].claimed;
    }
	
    /**
     * @dev Returns upcoming withdrawals which expire in the `daysFromNow` number of days. 
     * Returns array of StakingParamView, 
     * the sum of all amounts which can be paid in the upcoming period, 
     * and the timestamp when first staking will expire.  
     */
    function getUpcomingWithdrawals(uint daysFromNow) view external returns(StakingParamsView[] memory, uint, uint) {
        uint endTime = getDateFrom(block.timestamp, daysFromNow);
        StakingParamsView[] memory upcoming = new StakingParamsView[](_stakingLookup.length);
        uint firstUpcoming = getDateFrom(block.timestamp, daysFromNow + 1);
        uint j = 0;
        uint sum = 0;
        for (uint i = 0; i < _stakingLookup.length; i++) {
            if (!_staking[_stakingLookup[i]].claimed) {
                StakingParamsView memory stakingParamsView = viewStake(_stakingLookup[i]);
                if (stakingParamsView.expire <= endTime) {
                    upcoming[j++] = stakingParamsView;
                    sum += stakingParamsView.amountWithIntrest;
                    if (stakingParamsView.expire < firstUpcoming) {
                        firstUpcoming = stakingParamsView.expire;
                    }
                }
            }
        }
        StakingParamsView[] memory upcomingReturn = new StakingParamsView[](j);
        for (uint i = 0; i < j; i++) {
            upcomingReturn[i] = upcoming[i];
        }
        if(upcomingReturn.length==0){
            firstUpcoming=0;
        }
        return (upcomingReturn, sum, firstUpcoming);
    }

    /**
     * @dev Returns `array` of StakingParamViews withdrawals which are not claimed. 
     * Returns array of StakingParamView. 
     */
    function getAllActiveWithdrawals() view external returns(StakingParamsView[] memory) {
        StakingParamsView[] memory upcoming = new StakingParamsView[](_stakingLookup.length);
        for (uint i = 0; i < _stakingLookup.length; i++) {
            upcoming[i] = viewStake(_stakingLookup[i]);
        }
        return upcoming;
    }

    /**
     * @dev Returns array of all allowed `StakingOptions`
     */
    function getAllowedOptions() external view returns(StakingOption[] memory) {
        return _allowedOptions;
    }

    /**
     * @dev Returns StakingOption which is selected by `id`    
     */
    function getAllowedOption(uint id) external view returns(StakingOption memory) {
        return _allowedOptions[id];
    }

    /**
     * @dev Returns amount increased for interest which can be paid to address `addr`.
     */
    function calculateWithInterestForAddress(address addr) external view returns(uint) {
        require(stakeExists(addr), "Not found");
        return calculateWithInterest(_staking[addr].apy, _staking[addr].duration, _staking[addr].baseAmount);
    }

    /**
     * @dev Returns amount `amount` increased for interest, which can be paid for the number of days `duration` with APY `apy`.
     * APY must be written in the following format:
     * 12.34 % APY must be written as apy=1234.
     * The last two digits are decimals after floating-point.
     */
    function calculateWithInterest(uint amount,uint apy, uint duration) public pure returns(uint) {
        return amount * (100000 + 1000 * apy * duration / 36525) / 100000;
    }

    /**
     * @dev Returns amount decreased for penalty which can be paid to address `addr`.
     */
    function calculateWithPenaltyForAddress(address addr) external view returns(uint) {
        require(stakeExists(addr), "Not found");
        return calculateWithPenalty(_staking[addr].baseAmount, _staking[addr].penalty);
    }

    /**
     * @dev Returns amount `amount` decreased for penalty in % `penaltyPercentage`.
     * `penaltyPercentage` must be written in fallowing format:
     * 12.34 % penalty must be written as penaltyPercentage=1234.
     * The last two digits are decimals after floating-point.
     */
    function calculateWithPenalty(uint amount, uint penaltyPercentage) public pure returns(uint) {
        return amount * (100000 - penaltyPercentage * 10) / 100000;
    }

    /**
     * @dev Returns total value locked
     */
    function getTotalValueLocked() external view returns(uint) {
        return _totalValueLocked;
    }

    /**
     * @dev Returns `_totalValueLocked` incresad for interest.
     */
    function getTotalForPayout() external view returns(uint) {
        return _totalForPayout;
    }

    /**
     * @dev Returns sum of all _token which had been locked since contract deployment. 
     */
    function getTotalValueLockedAllTime() external view returns(uint) {
        return _totalValueLockedAllTime;
    }

    /**
     * @dev Returns sum of all rewards which had been payed since contract deployment.    
     */
    function getTotalRewardsPayed() external view returns(uint) {
        return _totalRewardsPayed;
    }

    /**
     * @dev Getter for minimal allowed staking amount.    
     */
    function getMinStakingAmount() external view returns(uint) {
        return _minStakingAmount;
    }

    /**
     * @dev Getter for maximal allowed staking amount
     */
    function getMaxStakingAmount() external view returns(uint) {
        return _maxStakingAmount;
    }

    /**
     * @dev Utility function. Allows adding of `durationInDay` to `start` timestamp.
     */
    function getDateFrom(uint start, uint durationInDay) public pure returns(uint) {
        return start + durationInDay * 1 days;
    }

    /**
     * @dev Returns `_token` address.
     */
    function getTokenAddress() external view returns(address){
        return address(_token);
    }
	
	/*///////////////////////////////////////////////////////////////
                    OWNER'S AND ADMIN'S FUNCTIONS
    //////////////////////////////////////////////////////////////*/
	
	/**
     * @dev Allows owner to cancel staking for address `addr`. 
     * Base amount which was deposited will be returned to `addr`
     */
    function cancelStaking(address addr) external onlyOwner returns(bool) {
        require(stakeExists(addr), "Not found");
        if (_staking[addr].created == 0) {
            return false;
        }
        _staking[addr].claimed = true;
        if (_staking[addr].baseAmount > 0) {
            uint amountWithInterest=calculateWithInterest(_staking[addr].baseAmount,_staking[addr].apy,_staking[addr].duration);
            _decreaseTotalValueLocked(_staking[addr].baseAmount,amountWithInterest,false);
            _token.safeTransfer(addr, _staking[addr].baseAmount);
        }
        return true;
    }
	
	/**
     * @dev Extract mistakenly sent tokens to the contract.
     */
    function extractMistakenlySentTokens(address tokenAddress) external onlyOwner {
        if (tokenAddress == address(0)) {
            payable(owner()).transfer(address(this).balance);
            return;
        }
        IBEP20 bep20Token = IBEP20(tokenAddress);
        uint balance = bep20Token.balanceOf(address(this));
        emit ExtractedTokens(tokenAddress, owner(), balance);
        _token.safeTransfer(owner(), balance);
    }
	
	/**
     * @dev Allows an administrator to add new administrator address `addr`.
     * Returns bool which indicates success of operation. 
     * Sender must be administrator.
     * `addr` can't be address(0)
     */
    function addAdmin(address addr) external onlyAdmin returns(bool) {
        require(addr != address(0));
        _admins[addr] = true;
        return true;
    }

    /**
     * @dev   Allows an administrator to remove an existing administrator identified by address `addr`. 
     * Administrators can’t remove `owner` from the list of administrators.
     * Sender must be administrator.
     * Returns bool, which indicates the success of the operation. 
     */
    function removeAdmin(address addr) external onlyAdmin returns(bool) {
        require(addr != owner() || _msgSender() == owner(), "Not allowed");
        _admins[addr] = false;
        return true;
    }

	/**
     * @dev Sets minimal and maximal allowed staking amounts. Sender must be administrator.
     */
    function setStakingLimits(uint min, uint max) external onlyAdmin{
        require(max < type(uint).max,"Wrong value");
        require(min < max, "Max must be larger then a min");
        _minStakingAmount = min;
        _maxStakingAmount = max;
    }
    	
	/**
     * @dev Adds new or update existing `StakingOption` selected by `id`.
     * Returns index of staking option.   
     * Sender must be administrator.
     */
    function updateAllowedOptions(uint id, StakingOption memory option) external onlyAdmin returns(uint) {
        require(option.apy > 0);
        if (id > _allowedOptions.length - 1) {
            _allowedOptions.push(option);
            return _allowedOptions.length - 1;
        } else {
            _allowedOptions[id] = option;
            return id;
        }
    }
	
	/**
     * @dev Removes existing StakingOption selected by `id`.
     * Sender must be administrator.
     */
    function removeAllowedOptions(uint id) external onlyAdmin {
        require(id < _allowedOptions.length, "Wrong index");
        StakingOption[] memory readingOptions = _allowedOptions;
        delete _allowedOptions;
        for (uint i = 0; i < readingOptions.length; i++) {
            if (i != id) {
                _allowedOptions.push(readingOptions[i]);
            }
        }
    }
	
    /**
     * @dev Swapes all existing StakingOptions by StakingOption array named `options`.
     * Sender must be administrator.
     */
    function swapAllAllowedOptions(StakingOption[] memory options) external onlyAdmin{
        require(options.length>0,"Array can't be empty");
        delete _allowedOptions;
        for (uint i = 0; i < options.length; i++) {
            _allowedOptions.push(options[i]);
        }
    }
	
	/**
     * @dev Allows administrator to suspend `addr` from withdrawl.
     */
    function blockUnstake(address addr) external onlyAdmin {
        _staking[addr].blocked = true;
    }

    /**
     * @dev Allows an administrator to unsuspend `addr` from _withdrawal.
     */
    function unblockUnstake(address addr) external onlyAdmin {
        _staking[addr].blocked = false;
    }
	
	/*///////////////////////////////////////////////////////////////
                    INTERNAL  HELPERS
    //////////////////////////////////////////////////////////////*/

    function _init() internal {
        _allowedOptions.push(StakingOption(0, 300, 0, true));
        _allowedOptions.push(StakingOption(1, 1000, 500, true));
        _allowedOptions.push(StakingOption(14, 2000, 1000, true));
    }
	
    /**
     * @dev Send _withdrawal request to `_token`.
     * Emits `Claimed` event
     */
    function _withdrawal(uint amount) private {
        uint balance = _token.balanceOf(address(this));
        require(balance >= amount, "Balance too low");
        _staking[_msgSender()].claimed = true;
        _removeFromLookup(_msgSender());
        StakingParams memory stakingParams=_staking[_msgSender()];
        emit Claimed(_msgSender(), stakingParams.baseAmount, getDateFrom(stakingParams.created, stakingParams.duration), amount);
        _token.safeTransfer(_msgSender(), amount);
    }
	
	/**
     * @dev Removes address `addr` from `_stakingLookup`. 
     * Base amount which was deposited will be returned to `addr`
     */
    function _removeFromLookup(address addr) private {
        address[] memory readingParams = _stakingLookup;
        delete _stakingLookup;
        for (uint i = 0; i < readingParams.length; i++) {
            if (readingParams[i] != addr) {
                _stakingLookup.push(readingParams[i]);
            }
        }
    }
	
	/**
     * @dev Utility function.
     * Increase multiple auxiliary variables used to store total value locked and other information.
     */
    function _increaseTotalValueLocked(uint amount, uint amountWithInterest) internal {
        _totalValueLocked += amount;
        _totalForPayout += amountWithInterest;
        _totalValueLockedAllTime += amount;
    }

    /**
     * @dev Utility function.
     * Decrease multiple auxiliary variables used to store total value locked and other information.
     */
    function _decreaseTotalValueLocked(uint amount, uint amountWithInterest,bool withPenalty) internal {
        _totalValueLocked -= amount;
        _totalForPayout -= amountWithInterest;
        if (!withPenalty) {
            _totalRewardsPayed += amountWithInterest - amount;
        }
    }
	
    /*///////////////////////////////////////////////////////////////
                     EVENTS
    //////////////////////////////////////////////////////////////*/
	
    /**
     * @dev It is emitted when deposits `value` to contract.
     */
    event Staked(address indexed addr, uint value, uint expire, uint claimableAmount);

    /**
     * @dev It is emitted when the user claims a stake from the contract.
     */
    event Claimed(address indexed addr, uint value, uint expire, uint claimed);

    /**
     * @dev It is emitted when the user claims stake from the contract with penalty paid.
     */
    event ClaimedWithPenalty(address indexed, uint value, uint expire, uint claimedDate, uint penalty);

    /**
     * @dev It is emitted when mistakenly sent _token are extracted.
     */
    event ExtractedTokens(address _token, address _owner, uint _amount);
    
}