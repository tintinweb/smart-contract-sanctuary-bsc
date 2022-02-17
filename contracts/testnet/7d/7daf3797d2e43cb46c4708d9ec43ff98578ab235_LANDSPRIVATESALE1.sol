/**
 *Submitted for verification at BscScan.com on 2022-02-16
*/

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

// Add Release event
// Change name for count set of tokens
// CHANGE TIMINGS FOR CLIFF AND DURATION (TO DEPLOY MAIN-NET CONTRACT)
// Non-reentrant feature in release

pragma solidity ^0.8.4;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

library Address {
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

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

        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return verifyCallResult(success, returndata, errorMessage);
    }

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

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

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

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract LANDSPRIVATESALE1 is Ownable {
    using Address for address;

    // address of the ERC20 token
    IERC20 private immutable _token;
    IERC20 private immutable _BUSD;

    struct VestingSchedule {
        bool initialized;
        // beneficiary of tokens after they are released
        address beneficiary;
        // total amount of tokens to be released at the end of the vesting
        uint256 amountTotal;
        // start time of the vesting period
        uint256 startTime;
        // cliff period in seconds
        uint256 cliff;
        // duration of the vesting period in seconds
        uint256 duration;
        // duration of a slice period for the vesting in seconds
        uint256 slicePeriodSeconds;
        // amount of tokens released
        uint256 released;
    }
    uint256 private constant TGEPercentage = 125;
    uint256 private constant BUSDAmount = 25;
    uint256 private constant BUSDDecimal = 100;
    uint256 private constant _decimals = 10**18;

    bytes32[] private vestingSchedulesIds;
    mapping(bytes32 => VestingSchedule) private vestingSchedules;
    mapping(address => uint256) private investorCount;
    uint256 private vestingSchedulesTotalAmount;

    event VestingScheduleDone(
        address beneficiaryAddress,
        bytes32 vestingScheduleId,
        uint256 index,
        uint256 amount,
        uint256 startTime,
        uint256 startOfVestingPeriod,
        uint256 durationOfVesting
    );
    event BUSDBalanceTransferToOwner(address owner, uint256 amount);
    event LANDSLeftoverBalanceWithdraw(address owner, uint256 amount);

    constructor(address token, address BUSD) {
        require(
            token != address(0x0) || BUSD != address(0x0),
            "Address Cannot be Zero Address"
        );
        _token = IERC20(token);
        _BUSD = IERC20(BUSD);
    }

    function vesting(uint256 tokenAmount) public {
        require(
            tokenAmount >= 10000,
            "Total Number have to be More Than or Equal to 10,000 LANDS Token!"
        );
        require(
            tokenAmount <= 20000,
            "Total Number have to be Less Than or Equal to 20,000 LANDS Token!"
        );
        require(
            this.getVestingSchedulesCountByBeneficiary(_msgSender()) < 2,
            "Maximum Purchase Limit Reached From This Address!"
        );
        uint256 amount_ = tokenAmount * _decimals;
        uint256 totalBUSDAmount = (BUSDAmount * amount_) / BUSDDecimal;
        require(
            _BUSD.balanceOf(_msgSender()) >= totalBUSDAmount,
            "Insufficient BUSD Balance, Add Funds to Start Vesting!"
        );
        require(
            amount_ <= this.getWithdrawableAmount(),
            "TokenVesting: Cannot Create Vesting Schedule! Insufficient Tokens"
        );
        _BUSD.transferFrom(_msgSender(), address(this), totalBUSDAmount);
        _BUSD.approve(address(this), totalBUSDAmount);

        address beneficiary_ = _msgSender();
        uint256 startTime_ = block.timestamp;
        uint256 cliff_ = startTime_ + 2000; // Cliff => 1 month (2629743)
        uint256 duration_ = startTime_ + 4000; // Total Vesting Duration => 11 months (28927173)
        uint256 slicePeriodSeconds_ = duration_ - cliff_; // SlicePeriodSeconds => 10 months (duration-cliff)

        bytes32 vestingScheduleId = this.computeNextVestingScheduleIdForHolder(
            beneficiary_
        );

        vestingSchedules[vestingScheduleId] = VestingSchedule(
            true, // Invested
            beneficiary_, // Address of the Invester
            amount_, // Total amount of tokens that are to be alloted
            startTime_, // StartTime
            cliff_, // Cliff => 6 months
            duration_, // Total Vesting Duration => 1 year
            slicePeriodSeconds_, //slicePeriodSeconds
            0 //released
        );

        emit VestingScheduleDone(
            beneficiary_,
            vestingScheduleId,
            investorCount[beneficiary_],
            amount_,
            startTime_,
            cliff_,
            duration_
        );

        vestingSchedulesTotalAmount += amount_;
        vestingSchedulesIds.push(vestingScheduleId);
        uint256 currentVestingCount = investorCount[beneficiary_];
        investorCount[beneficiary_] = currentVestingCount + 1;
    }

    function getVestingSchedulesCountByBeneficiary(address _beneficiary)
        external
        view
        returns (uint256)
    {
        return investorCount[_beneficiary];
    }

    function FEGetVestingSchedulesCount() external view returns (uint256) {
        return vestingSchedulesIds.length;
    }

    function FEGetVestingSchedule(bytes32 vestingScheduleId)
        public
        view
        returns (VestingSchedule memory)
    {
        return vestingSchedules[vestingScheduleId];
    }

    function FEComputeReleasableAmount(bytes32 vestingScheduleId)
        public
        view
        returns (uint256)
    {
        VestingSchedule storage vestingSchedule = vestingSchedules[
            vestingScheduleId
        ];
        return _computeReleasableAmount(vestingSchedule);
    }

    function FEGetVestingScheduleByAddressAndIndex(
        address holder,
        uint256 index
    ) external view returns (VestingSchedule memory) {
        return
            FEGetVestingSchedule(
                this.computeVestingScheduleIdForAddressAndIndex(holder, index)
            );
    }

    function FEGetAllAmounts(address holder)
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        uint256 count = this.getVestingSchedulesCountByBeneficiary(holder);
        uint256 totalAmount;
        uint256 totalReleasedAmount;
        uint256 totalAmountLeft;
        uint256 computeReleasableAmount;
        for (uint256 i = 0; i < count; i++) {
            VestingSchedule memory vestingSchedule = this
                .FEGetVestingScheduleByAddressAndIndex(holder, i);

            totalAmount = totalAmount + vestingSchedule.amountTotal;
            totalReleasedAmount =
                totalReleasedAmount +
                vestingSchedule.released;
            computeReleasableAmount =
                computeReleasableAmount +
                _computeReleasableAmount(vestingSchedule);
        }
        totalAmountLeft = totalAmount - totalReleasedAmount;
        return (totalAmount, totalReleasedAmount, totalAmountLeft, computeReleasableAmount);
    }

    function release(
        bytes32 vestingScheduleId // nonReentrant
    ) public {
        VestingSchedule storage vestingSchedule = vestingSchedules[
            vestingScheduleId
        ];

        uint256 amount = _computeReleasableAmount(vestingSchedule);

        require(
            msg.sender == vestingSchedule.beneficiary || msg.sender == owner(),
            "TokenVesting: only beneficiary or owner can release vested tokens to beneficiary address."
        );
        uint256 vestedAmount = _computeReleasableAmount(vestingSchedule);
        require(
            vestedAmount >= amount,
            "TokenVesting: cannot release tokens, not enough vested tokens"
        );
        vestingSchedule.released = vestingSchedule.released + amount;
        address beneficiaryPayable = vestingSchedule.beneficiary;
        vestingSchedulesTotalAmount = vestingSchedulesTotalAmount - amount;
        _token.transfer(beneficiaryPayable, amount);
        _token.approve(beneficiaryPayable, amount);
    }

    function _computeReleasableAmount(VestingSchedule memory vestingSchedule)
        internal
        view
        returns (uint256)
    {
        uint256 currentTime = getCurrentTime();
        if ((currentTime < vestingSchedule.cliff)) {
            uint256 TGEAmount = (vestingSchedule.amountTotal * TGEPercentage) /
                1000;
            TGEAmount = TGEAmount - vestingSchedule.released;
            return TGEAmount;
        } else if (currentTime >= vestingSchedule.duration) {
            return vestingSchedule.amountTotal - vestingSchedule.released;
        } else {
            uint256 timeAfterCliffEnd = currentTime - vestingSchedule.cliff;
            uint256 vestedAmount = (vestingSchedule.amountTotal *
                timeAfterCliffEnd) / vestingSchedule.slicePeriodSeconds;
            vestedAmount = vestedAmount - vestingSchedule.released;
            return vestedAmount;
        }
    }

    function computeNextVestingScheduleIdForHolder(address holder)
        external
        view
        returns (bytes32)
    {
        return
            this.computeVestingScheduleIdForAddressAndIndex(
                holder,
                investorCount[holder]
            );
    }

    function computeVestingScheduleIdForAddressAndIndex(
        address holder,
        uint256 index
    ) external pure returns (bytes32) {
        return keccak256(abi.encodePacked(holder, index));
    }

    function withdrawBUSD() external onlyOwner {
        uint256 BUSDBalance_ = this.BUSDBalance();
        _BUSD.transfer(owner(), BUSDBalance_);
        _BUSD.approve(owner(), BUSDBalance_);

        emit BUSDBalanceTransferToOwner(owner(), BUSDBalance_);
    }

    function withdrawLeftOverLANDS() external onlyOwner {
        uint256 LANDSBalance_ = this.getWithdrawableAmount();
        _token.transfer(owner(), LANDSBalance_);
        _token.approve(owner(), LANDSBalance_);

        emit LANDSLeftoverBalanceWithdraw(owner(), LANDSBalance_);
    }

    function getWithdrawableAmount() external view returns (uint256) {
        return this.LANDSBalance() - this.FEGetVestingSchedulesTotalAmount();
    }

    function FEGetVestingSchedulesTotalAmount()
        external
        view
        returns (uint256)
    {
        return vestingSchedulesTotalAmount;
    }

    function LANDSBalance() external view returns (uint256) {
        return _token.balanceOf(address(this));
    }

    function BUSDBalance() external view returns (uint256) {
        return _BUSD.balanceOf(address(this));
    }

    function getToken() external view returns (address) {
        return address(_token);
    }

    function getCurrentTime() internal view virtual returns (uint256) {
        return block.timestamp;
    }
}