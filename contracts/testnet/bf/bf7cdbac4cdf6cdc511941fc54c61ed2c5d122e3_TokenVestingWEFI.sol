/**
 *Submitted for verification at BscScan.com on 2022-09-28
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

contract TokenVestingWEFI is IERC20, Context, ReentrancyGuard {
    IERC20 public immutable tokenAddress;
    struct VestingSchedule {bool initialized; address beneficiary; uint256 cliff; uint256 start; uint256 duration; uint256 slicePeriodSeconds; uint256 amountTotal; uint256 released;}

    bytes32[] private _vestingSchedulesIds;
    uint256 private _vestingSchedulesTotalAmount;
    mapping(address => uint256) private _holdersVestingCount;
    mapping(bytes32 => VestingSchedule) private _vestingSchedules;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    event TokensReleased(address beneficiary, uint256 amount);
    event VestingScheduleCreated(address beneficiary, uint256 cliff, uint256 start, uint256 duration, uint256 slicePeriodSeconds, uint256 amount);

    modifier onlyIfBeneficiaryExists(address beneficiary) {
        require(_holdersVestingCount[beneficiary] > 0, "TokenVestingWEFI: INVALID Beneficiary Address! no vesting schedule exists for that beneficiary");
        _;
    }

    constructor(address _tokenAddress) {
        require(_tokenAddress != address(0x0));
        tokenAddress = IERC20(_tokenAddress);
    }

    function name() external pure returns (string memory) {
        return "Vested WEFI";
    }

    function symbol() external pure returns (string memory) {
        return "V-WEFI";
    }

    function decimals() external pure returns (uint8) {
        return 18;
    }

    function totalSupply() external view returns (uint256) {
        return _vestingSchedulesTotalAmount;
    }

    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    function getCurrentTime() public view returns (uint256) {
        return block.timestamp;
    }

    function approve(address spender, uint256 amount) external returns (bool)
    {
        _approve(_msgSender(), spender, amount);

        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "TokenVestingWEFI: approve from the zero address");
        require(spender != address(0), "TokenVestingWEFI: approve to the zero address");

        _allowances[owner][spender] = amount;
        
        emit Approval(owner, spender, amount);
    }

    function allowance(address owner, address spender) public view returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
        require(allowance(sender, _msgSender()) >= amount, "TokenVestingWEFI: insufficient allowance");

        _approve(sender, _msgSender(), (_allowances[sender][_msgSender()] - amount));
        _transfer(sender, recipient, amount);

        return true;
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);

        return true;
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "TokenVestingWEFI: transfer from the zero address");
        require(to != address(0), "TokenVestingWEFI: transfer to the zero address");
        require(_balances[from] >= amount, "TokenVestingWEFI: transfer amount exceeds balance");

        _balances[from] -= amount;
        uint256 transferAmount = amount;
        
        uint256 newCliff;
        uint256 newDuration;
        uint256 newStart;
        VestingSchedule storage vestingSchedule;

        for (uint256 i = 0; i < getVestingSchedulesCountByBeneficiary(from); i++) {
            vestingSchedule = _vestingSchedules[computeVestingScheduleIdForAddressAndIndex(from, i)];
            (newCliff, newStart, newDuration) = _generateCSD(vestingSchedule.cliff, vestingSchedule.start, vestingSchedule.duration);
            uint256 remainingAmount = vestingSchedule.amountTotal - vestingSchedule.released;

            if (transferAmount <= remainingAmount) { // single VS of sender is enough for transfer amount
                vestingSchedule.amountTotal -= transferAmount;
                vestingSchedule.released = 0;
                vestingSchedule.cliff = newStart + newCliff;
                vestingSchedule.start = newStart;
                vestingSchedule.duration = newDuration;
                _vestingSchedulesTotalAmount -= transferAmount;
                
                _createVestingSchedule(to, newStart, newCliff, newDuration, vestingSchedule.slicePeriodSeconds, transferAmount);

                break;
            } 
            else { // single VS is not enough for transfer amount, hence multiple VS of sender will be used
                if (remainingAmount == 0) { continue; }

                vestingSchedule.amountTotal = 0;
                vestingSchedule.released = 0;
                _vestingSchedulesTotalAmount -= remainingAmount;
                transferAmount -= remainingAmount;

                _createVestingSchedule(to, newStart, newCliff, newDuration, vestingSchedule.slicePeriodSeconds, remainingAmount);
            }
        }

        emit Transfer(from, to, amount);
    }

    function _generateCSD(uint256 _cliff, uint256 _start, uint256 _duration) private view returns (uint256, uint256, uint256)
    {
        uint256 newCliff;
        uint256 newStart;
        uint256 newDuration;

        uint256 oldCliff = _cliff - _start;

        uint256 passedCliff = 0;
        uint256 passedDuration = 0;

        if (getCurrentTime() < _start) { // vesting not started yet hence all same
            newCliff = oldCliff;
            newDuration = _duration;
        } else { // vesting started, hence 3 cases | between start and cliff | between cliff and duration end | even duration has also been passed
            if (getCurrentTime() < _cliff) { // cliff has not yet been passed | between start and cliff
                newCliff = _cliff - getCurrentTime();
                newDuration = _duration;
                passedCliff = oldCliff - newCliff;
                passedDuration = 0;
            } 
            else { // cliff has been passed
                newCliff = 0;
                passedCliff = oldCliff;
                passedDuration = getCurrentTime() - _cliff;

                if (passedDuration < _duration) { // duration has not yet been passed | between cliff and duration end
                    newDuration = _duration - passedDuration;
                }
                else { // even duration has also been passed
                    newDuration = 1;
                }
            }
        }
        newStart = _start + passedCliff + passedDuration;

        return (newCliff, newStart, newDuration);
    }

    function getVestingIdAtIndex(uint256 index) external view returns (bytes32)
    {
        require(index < getVestingSchedulesCount(), "TokenVestingWEFI: index out of bounds");

        return _vestingSchedulesIds[index];
    }

    function getVestingSchedulesCountByBeneficiary(address _beneficiary) public view returns (uint256)
    {
        return _holdersVestingCount[_beneficiary];
    }

    function getVestingScheduleByBeneficiaryAndIndex(address beneficiary, uint256 index) external view onlyIfBeneficiaryExists(beneficiary) returns (VestingSchedule memory) {
        require(index < _holdersVestingCount[beneficiary], "TokenVestingWEFI: INVALID Vesting Schedule Index! no vesting schedule exists at this index for that beneficiary");

        return getVestingSchedule(computeVestingScheduleIdForAddressAndIndex(beneficiary, index));
    }

    function computeVestingScheduleIdForAddressAndIndex(address holder, uint256 index) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(holder, index));
    }

    function getVestingSchedule(bytes32 vestingScheduleId) public view returns (VestingSchedule memory)
    {
        VestingSchedule storage vestingSchedule = _vestingSchedules[vestingScheduleId];
        require(vestingSchedule.initialized == true, "TokenVestingWEFI: INVALID Vesting Schedule ID! no vesting schedule exists for that id");

        return vestingSchedule;
    }

    function createVestingSchedule(address _beneficiary, uint256 _start, uint256 _cliff, uint256 _duration, uint256 _slicePeriodSeconds, uint256 _amount) external returns (bool) {
        require(tokenAddress.transferFrom(_msgSender(), address(this), _amount), "TokenVestingWEFI: token WEFI transferFrom not succeeded");
        _createVestingSchedule(_beneficiary, _start, _cliff, _duration, _slicePeriodSeconds, _amount);

        return true;
    }

    function _createVestingSchedule(address _beneficiary, uint256 _start, uint256 _cliff, uint256 _duration, uint256 _slicePeriodSeconds, uint256 _amount) private {
        require(_duration > 0, "TokenVestingWEFI: duration must be > 0");
        require(_amount > 0, "TokenVestingWEFI: amount must be > 0");
        require(_slicePeriodSeconds >= 1, "TokenVestingWEFI: slicePeriodSeconds must be >= 1");

        bytes32 vestingScheduleId = computeNextVestingScheduleIdForHolder(_beneficiary);
        uint256 cliff = _start + _cliff;
        _vestingSchedules[vestingScheduleId] = VestingSchedule(true, _beneficiary, cliff, _start, _duration, _slicePeriodSeconds, _amount, 0);
        _balances[_beneficiary] += _amount;
        _vestingSchedulesTotalAmount += _amount;
        _vestingSchedulesIds.push(vestingScheduleId);
        _holdersVestingCount[_beneficiary]++;
    }

    function computeNextVestingScheduleIdForHolder(address holder) private view returns (bytes32)
    {
        return computeVestingScheduleIdForAddressAndIndex(holder, _holdersVestingCount[holder]);
    }

    function _computeReleasableAmount(VestingSchedule memory vestingSchedule) private view returns (uint256)
    {
        uint256 currentTime = getCurrentTime();
        if (currentTime < vestingSchedule.cliff) {
            return 0;
        }
        else if (currentTime >= vestingSchedule.cliff + vestingSchedule.duration)
        {
            return (vestingSchedule.amountTotal - vestingSchedule.released);
        }
        else
        {
            uint256 timeFromStart = currentTime - (vestingSchedule.cliff);
            uint256 secondsPerSlice = vestingSchedule.slicePeriodSeconds;
            uint256 releaseableSlicePeriods = timeFromStart / secondsPerSlice;
            uint256 releaseableSeconds = releaseableSlicePeriods * secondsPerSlice;
            uint256 releaseableAmount = (vestingSchedule.amountTotal * releaseableSeconds) / vestingSchedule.duration; // 100
            releaseableAmount -= vestingSchedule.released; // = 100-1000

            return releaseableAmount;
        }
    }

    function claimFromAllVestings() external nonReentrant onlyIfBeneficiaryExists(msg.sender) returns (bool)
    {
        address beneficiary = _msgSender();
        uint256 vestingSchedulesCountByBeneficiary = getVestingSchedulesCountByBeneficiary(beneficiary);

        VestingSchedule storage vestingSchedule;
        uint256 totalReleaseableAmount = 0;
        uint256 i = 0;
        do {
            vestingSchedule = _vestingSchedules[computeVestingScheduleIdForAddressAndIndex(beneficiary, i)];
            uint256 releaseableAmount = _computeReleasableAmount(vestingSchedule);
            vestingSchedule.released += releaseableAmount;

            totalReleaseableAmount += releaseableAmount;
            i++;
        } while (i < vestingSchedulesCountByBeneficiary);

        _vestingSchedulesTotalAmount -= totalReleaseableAmount;
        _balances[beneficiary] -= totalReleaseableAmount;
        require(tokenAddress.transfer(beneficiary, totalReleaseableAmount), "TokenVestingWEFI: token WEFI rewards transfer to beneficiary not succeeded");

        emit TokensReleased(beneficiary, totalReleaseableAmount);
        return true;
    }

    function getVestingSchedulesCount() public view returns (uint256) {
        return _vestingSchedulesIds.length;
    }

    function getLastVestingScheduleForBeneficiary(address beneficiary) external view onlyIfBeneficiaryExists(beneficiary) returns (VestingSchedule memory)
    {
        return _vestingSchedules[computeVestingScheduleIdForAddressAndIndex(beneficiary, _holdersVestingCount[beneficiary] - 1)];
    }

    function computeReleasableAmountForBeneficiary(address beneficiary) external view onlyIfBeneficiaryExists(beneficiary) returns(uint256) {
        uint256 vestingSchedulesCountByBeneficiary = getVestingSchedulesCountByBeneficiary(beneficiary);

        VestingSchedule memory vestingSchedule;
        uint256 totalReleaseableAmount = 0;
        uint256 i = 0;
        do {
            vestingSchedule = _vestingSchedules[computeVestingScheduleIdForAddressAndIndex(beneficiary, i)];
            uint256 releaseableAmount = _computeReleasableAmount(vestingSchedule);

            totalReleaseableAmount += releaseableAmount;
            i++;
        } while (i < vestingSchedulesCountByBeneficiary);

        return totalReleaseableAmount;
    }
}