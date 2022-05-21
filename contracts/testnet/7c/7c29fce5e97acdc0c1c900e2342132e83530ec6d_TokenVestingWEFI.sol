/**
 *Submitted for verification at BscScan.com on 2022-05-21
*/

// SPDX-License-Identifier: MIT
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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

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
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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

    constructor() {
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
}

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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
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

/**
 * @title TokenVesting
 */
contract TokenVestingWEFI is Ownable, ReentrancyGuard {
    struct VestingSchedule {
        bool initialized;
        address beneficiary;
        uint256 cliff;
        uint256 start;
        uint256 duration;
        uint256 slicePeriodSeconds;
        uint256 amountTotal;
        uint256 released;
    }

    IERC20 private immutable _token;

    bytes32[] private vestingSchedulesIds;
    mapping(bytes32 => VestingSchedule) private vestingSchedules;
    uint256 private vestingSchedulesTotalAmount;
    mapping(address => uint256) private holdersVestingCount;

    address authorizedContractAddress = msg.sender;
    mapping(address => uint256) private _balances;

    event Released(address beneficiary, uint256 amount);
    event VestingScheduleCreated(
        address beneficiary,
        uint256 cliff,
        uint256 start,
        uint256 duration,
        uint256 slicePeriodSeconds,
        uint256 amount
    );

    modifier onlyIfVestingScheduleExists(bytes32 vestingScheduleId) {
        require(
            vestingSchedules[vestingScheduleId].initialized == true,
            "TokenVestingWEFI: INVALID Vesting Schedule ID! no vesting schedule exists for that ID"
        );
        _;
    }

    modifier onlyIfBeneficiaryExists(address beneficiary) {
        require(
            holdersVestingCount[beneficiary] > 0,
            "TokenVestingWEFI: INVALID Beneficiary Address! no vesting schedule exists for that beneficiary"
        );
        _;
    }

    modifier onlyOwnerOrAuthorizedContract() {
        require(
            _msgSender() == owner(),
            "TokenVestingWEFI: caller is not the owner"
        );
        require(
            _msgSender() == authorizedContractAddress,
            "TokenVestingWEFI: caller is not the authorized contract"
        );
        _;
    }

    constructor(address token_) {
        require(token_ != address(0x0));
        _token = IERC20(token_);
    }

    function getVestingSchedulesCountByBeneficiary(address _beneficiary)
        public
        view
        returns (uint256)
    {
        return holdersVestingCount[_beneficiary];
    }

    function getVestingIdAtIndex(uint256 index)
        external
        view
        returns (bytes32)
    {
        require(
            index < getVestingSchedulesCount(),
            "TokenVestingWEFI: index out of bounds"
        );
        return vestingSchedulesIds[index];
    }

    function getVestingScheduleByBeneficiaryAndIndex(
        address beneficiary,
        uint256 index
    ) external view returns (VestingSchedule memory) {
        require(
            holdersVestingCount[beneficiary] > 0,
            "TokenVestingWEFI: INVALID Beneficiary Address! no vesting schedule exists for that beneficiary"
        );
        require(
            index < holdersVestingCount[beneficiary],
            "TokenVestingWEFI: INVALID Vesting Schedule Index! no vesting schedule exists at this index for that beneficiary"
        );
        return
            getVestingSchedule(
                computeVestingScheduleIdForAddressAndIndex(beneficiary, index)
            );
    }

    function computeVestingScheduleIdForAddressAndIndex(
        address holder,
        uint256 index
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(holder, index));
    }

    function getVestingSchedule(bytes32 vestingScheduleId)
        public
        view
        returns (VestingSchedule memory)
    {
        VestingSchedule storage vestingSchedule = vestingSchedules[
            vestingScheduleId
        ];
        require(
            vestingSchedule.initialized == true,
            "TokenVestingWEFI: INVALID Vesting Schedule ID! no vesting schedule exists for that id"
        );
        return vestingSchedules[vestingScheduleId];
    }

    function getVestingSchedulesTotalAmount() external view returns (uint256) {
        return vestingSchedulesTotalAmount;
    }

    function getToken() external view returns (address) {
        return address(_token);
    }

    function createVestingSchedule(
        address _beneficiary,
        uint256 _start,
        uint256 _cliff,
        uint256 _duration,
        uint256 _slicePeriodSeconds,
        uint256 _amount
    ) public onlyOwnerOrAuthorizedContract {
        require(
            this.getWithdrawableAmount() >= _amount,
            "TokenVestingWEFI: cannot create vesting schedule because not sufficient tokens"
        );
        require(_duration > 0, "TokenVestingWEFI: duration must be > 0");
        require(_amount > 0, "TokenVestingWEFI: amount must be > 0");
        require(
            _slicePeriodSeconds >= 1,
            "TokenVestingWEFI: slicePeriodSeconds must be >= 1"
        );
        bytes32 vestingScheduleId = this.computeNextVestingScheduleIdForHolder(
            _beneficiary
        );
        uint256 cliff = _start + _cliff;
        vestingSchedules[vestingScheduleId] = VestingSchedule(
            true,
            _beneficiary,
            cliff,
            _start,
            _duration,
            _slicePeriodSeconds,
            _amount,
            0
        );
        _balances[_beneficiary] = _balances[_beneficiary] + _amount;
        vestingSchedulesTotalAmount = vestingSchedulesTotalAmount + _amount;
        vestingSchedulesIds.push(vestingScheduleId);
        uint256 currentVestingCount = holdersVestingCount[_beneficiary];
        holdersVestingCount[_beneficiary] = currentVestingCount + 1;
    }

    function getWithdrawableAmount() public view returns (uint256) {
        return _token.balanceOf(address(this)) - vestingSchedulesTotalAmount;
    }

    function computeNextVestingScheduleIdForHolder(address holder)
        public
        view
        returns (bytes32)
    {
        return
            computeVestingScheduleIdForAddressAndIndex(
                holder,
                holdersVestingCount[holder]
            );
    }

    function _computeReleasableAmount(VestingSchedule memory vestingSchedule)
        internal
        view
        returns (uint256)
    {
        uint256 currentTime = getCurrentTime();
        if (currentTime < vestingSchedule.cliff) {
            return 0;
        } else if (
            currentTime >= vestingSchedule.start + vestingSchedule.duration
        ) {
            return vestingSchedule.amountTotal - vestingSchedule.released;
        } else {
            uint256 timeFromStart = currentTime - (vestingSchedule.start);
            uint256 secondsPerSlice = vestingSchedule.slicePeriodSeconds;
            uint256 vestedSlicePeriods = timeFromStart / secondsPerSlice;
            uint256 vestedSeconds = vestedSlicePeriods * secondsPerSlice;
            uint256 vestedAmount = (vestingSchedule.amountTotal *
                vestedSeconds) / vestingSchedule.duration;
            vestedAmount = vestedAmount - vestingSchedule.released;

            return vestedAmount;
        }
    }

    function releaseFromAllVestings(address beneficiary)
        public
        onlyOwner
        nonReentrant
        onlyIfBeneficiaryExists(beneficiary)
    {
        uint256 vestingSchedulesCountByBeneficiary = getVestingSchedulesCountByBeneficiary(
                beneficiary
            );

        VestingSchedule storage vestingSchedule;
        uint256 i = 0;
        do {
            vestingSchedule = vestingSchedules[
                computeVestingScheduleIdForAddressAndIndex(beneficiary, i)
            ];
            uint256 vestedAmount = _computeReleasableAmount(vestingSchedule);
            vestingSchedule.released = vestingSchedule.released + vestedAmount;
            address payable beneficiaryPayable = payable(
                vestingSchedule.beneficiary
            );
            vestingSchedulesTotalAmount =
                vestingSchedulesTotalAmount -
                vestedAmount;
            _balances[beneficiaryPayable] =
                _balances[beneficiaryPayable] -
                vestedAmount;

            _token.transfer(beneficiaryPayable, vestedAmount);
            emit Released(beneficiaryPayable, vestedAmount);
            i++;
        } while (i < vestingSchedulesCountByBeneficiary);
    }

    function claimFromAllVestings()
        public
        nonReentrant
        onlyIfBeneficiaryExists(msg.sender)
    {
        address beneficiary = _msgSender();
        uint256 vestingSchedulesCountByBeneficiary = getVestingSchedulesCountByBeneficiary(
                beneficiary
            );

        VestingSchedule storage vestingSchedule;
        uint256 i = 0;
        do {
            vestingSchedule = vestingSchedules[
                computeVestingScheduleIdForAddressAndIndex(beneficiary, i)
            ];
            uint256 vestedAmount = _computeReleasableAmount(vestingSchedule);
            vestingSchedule.released = vestingSchedule.released + vestedAmount;
            address payable beneficiaryPayable = payable(
                vestingSchedule.beneficiary
            );
            vestingSchedulesTotalAmount =
                vestingSchedulesTotalAmount -
                vestedAmount;
            _balances[beneficiaryPayable] =
                _balances[beneficiaryPayable] -
                vestedAmount;

            _token.transfer(beneficiaryPayable, vestedAmount);
            emit Released(beneficiaryPayable, vestedAmount);
            i++;
        } while (i < vestingSchedulesCountByBeneficiary);
    }

    function withdrawExtraTokens(uint256 amount) public nonReentrant onlyOwner {
        require(
            this.getWithdrawableAmount() >= amount,
            "TokenVestingWEFI: not enough withdrawable funds"
        );
        _token.transfer(owner(), amount);
    }

    function getVestingSchedulesCount() public view returns (uint256) {
        return vestingSchedulesIds.length;
    }

    function computeReleasableAmount(bytes32 vestingScheduleId)
        public
        view
        onlyIfVestingScheduleExists(vestingScheduleId)
        returns (uint256)
    {
        VestingSchedule storage vestingSchedule = vestingSchedules[
            vestingScheduleId
        ];
        return _computeReleasableAmount(vestingSchedule);
    }

    function getLastVestingScheduleForBeneficiary(address beneficiary)
        public
        view
        returns (VestingSchedule memory)
    {
        require(
            holdersVestingCount[beneficiary] > 0,
            "TokenVestingWEFI: INVALID Beneficiary Address! no vesting schedule exists for that beneficiary"
        );
        return
            vestingSchedules[
                computeVestingScheduleIdForAddressAndIndex(
                    beneficiary,
                    holdersVestingCount[beneficiary] - 1
                )
            ];
    }

    function getCurrentTime() public view virtual returns (uint256) {
        return block.timestamp;
    }

    function symbol() public pure returns (string memory) {
        return "VWEFI";
    }

    function decimals() public pure returns (uint8) {
        return 18;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function changeAuthorizedContractAddress(address newContractAddress)
        external
        onlyOwner
        returns (bool)
    {
        authorizedContractAddress = newContractAddress;
        return true;
    }

    receive() external payable {}

    fallback() external payable {}
}