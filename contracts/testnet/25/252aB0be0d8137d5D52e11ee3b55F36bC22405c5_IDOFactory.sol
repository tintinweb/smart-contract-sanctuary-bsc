// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
// import "hardhat/console.sol";

import "./IDO.sol";
import "./interfaces/ITier.sol";

/**
 * @title IDOFactory
 * @notice IDOFactoy creates IDOs.
 */
contract IDOFactory is Ownable {
    address feeRecipient;
    uint256 feePercent;

    IDO[] ctrtIDOs;

    address[] operators;

    address tier;
    address point;

    event IDOCreated(
        address indexed idoAddress
    );


    /**
     * @notice Set tier and point address
     * @param _tier: Addres of tier contract
     * @param _point: Address of point contract
     */
    constructor(address _tier, address _point) {
        tier = _tier;
        point = _point;
    }

    modifier inOperators(uint256 _index) {
        require(operators.length > _index, "IDOFactory: operator index is invalid");
        _;
    }

    modifier inIDOs(uint256 _index) {
        require(ctrtIDOs.length > _index, "IDOFactory: IDO index is invalid");
        _;
    }

    modifier onlyOperator() {
        require(isOperator(msg.sender), "IDOFactory: caller is not the operator");
        _;
    }

    /**
     * @notice IDOFactory owner creates a new IDO
     * @param _fundToken: Address of fund token
     * @param _fundAmount: Amount of fund token
     * @param _saleToken: Address of sale token
     * @param _saleAmount: Amount of sale token
     * @return _index: Index of the created IDO
     */
    function createIDO(
        address _fundToken,
        uint256 _fundAmount,
        address _saleToken,
        uint256 _saleAmount
    ) external onlyOperator returns (uint256) {
        require(IERC20(_saleToken).balanceOf(owner()) >= _saleAmount, "IDOFactory: balance of owner is not enough");
        IDO ido = new IDO(_fundToken, _fundAmount, _saleToken, _saleAmount);
        ctrtIDOs.push(ido);
        emit IDOCreated(address(ido));
        return ctrtIDOs.length - 1;
    }

    /**
     * @notice IDOFactory owner sets a fee recipient
     * @param _feeRecipient: Address of fee recipient
     */
    function setFeeRecipient(address _feeRecipient) external onlyOwner {
        require(_feeRecipient != address(0), "IDOFactory: fee recipient must not be address(0)");
        feeRecipient = _feeRecipient;
    }

    /**
     * @notice IDOFactory owner sets a fee percent
     * @param _feePercent: Fee percent
     */
    function setFeePercent(uint256 _feePercent) external onlyOwner {
        require(_feePercent > 0, "IDOFactory: fee percent must be bigger than zero");
        feePercent = _feePercent;
    }

    /**
     * @notice IDOFactory owner finalizes a IDO
     * @param _index: Index of the IDO
     * @param _finalizer: Address of finalizer
     */
    function finalizeIDO(uint256 _index, address _finalizer) external onlyOwner inIDOs(_index) {
        require(feePercent > 0, "IDOFactory: owner didn't set the fee percent");
        require(feeRecipient != address(0), "IDOFactory: owner didn't set the fee recipient");
        ctrtIDOs[_index].finalize(owner(), _finalizer, feePercent, feeRecipient);
    }

    /**
     * @notice IDOFactory owner calls emergencyRefund
     * @param _index: Index of the IDO
     */
    function emergencyRefund(uint256 _index) external onlyOwner inIDOs(_index) {
        ctrtIDOs[_index].emergencyRefund();
    }

    /**
     * @notice IDOFactory owner inserts a operator
     * @param _operator: Address of operator
     * @return _index: Index of the inserted operator
     */
    function insertOperator(address _operator) external onlyOwner returns (uint256) {
        require(!isOperator(_operator), "IDOFactory: you have already inserted the operator");
        operators.push(_operator);
        return operators.length - 1;
    }

    /**
     * @notice IDOFactory owner removes a operator
     * @param _index: Index of the operator
     */
    function removeOperator(uint256 _index) external onlyOwner inOperators(_index) {
        for (uint256 i = _index; i < operators.length - 1; i++) {
            operators[i] = operators[i + 1];
        }
        operators.pop();
    }

    /**
     * @notice Get IDO address
     * @param _index: Index of the IDO to get
     * @return IDO: Address of the IDO to get
     */
    function getIDO(uint256 _index) external view inIDOs(_index) returns (IDO) {
        return ctrtIDOs[_index];
    }

    /**
     * @notice Get user's multiplier
     * @param _funder: Address of funder
     * @return multiplier: Return the user's multiplier
     */
    function getMultiplier(address _funder) public view returns (uint256) {
        return ITier(tier).getMultiplier(point, _funder);
    }

    /**
     * @notice Check if user is an operator
     * @param _addr: Address of user's account
     * @return isOperator: Return true if user is an operator, false otherwise
     */
    function isOperator(address _addr) public view returns (bool) {
        for (uint256 i = 0; i < operators.length; i++) {
            if (operators[i] == _addr) return true;
        }
        return false;
    }
}

// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
// import "hardhat/console.sol";

import "./IDOFactory.sol";

/**
 * @title IDO
 * @notice An Initial DEX Offering, or IDO for short,
 * is a new crowdfunding technique that enables cryptocurrency
 * projects to introduce their native token or coin
 * through decentralized exchanges (DEXs)
 */
contract IDO is Ownable {
    enum State {
        Waiting,
        Success,
        Failure
    }

    // constanst variables
    // from 00:00 - 08:00, only tiers can fund.
    uint256 constant TIER_FUND_TIME = 8 hours;
    // from 08:00 - 16:00, only whitelisted users can fund.
    uint256 constant WHITELISTED_USER_FUND_TIME = 16 hours;
    // from 16:00 - 00:00, any users can fund.
    uint256 constant ANY_USERS_FUND_TIME = 24 hours;
    // this needs to get hours.
    uint256 constant SECONDS_PER_DAY = 1 days;

    // IDO variables
    address public fundToken;
    uint256 public fundAmount;
    uint256 public fundedAmount;
    address public saleToken;
    uint256 public saleAmount;
    uint256 public startTime;
    uint256 public endTime;
    uint256 public claimTime;
    uint256 public tge;
    uint256 public cliffTime;
    uint256 public duration;
    uint256 public periodicity;
    uint256 public baseAmount;
    uint256 public maxAmountPerUser;
    uint256 public perAmount;
    mapping(address => uint256) public whitelistedAmounts;
    mapping(address => uint256) public fundedAmounts;
    mapping(address => uint256) public claimedAmounts;

    State private state = State.Waiting;

    /**
     * @notice IDOFacotry owner creates IDO contract
     * @param _fundToken: Address of fund token
     * @param _fundAmount: Amount of fund token
     * @param _saleToken: Address of sale token
     * @param _saleAmount: Amount of sale token
     */
    constructor(
        address _fundToken,
        uint256 _fundAmount,
        address _saleToken,
        uint256 _saleAmount
    ) {
        require(_fundAmount > 0 && _saleAmount > 0, "IDO: amount must be greater than zero");
        fundToken = _fundToken;
        fundAmount = _fundAmount;
        saleToken = _saleToken;
        saleAmount = _saleAmount;
        perAmount = saleAmount / fundAmount;
    }

    modifier onlyInTime(uint256 from, uint256 to) {
        require(block.timestamp >= from, "IDO: time is not yet");
        require(block.timestamp < to, "IDO: time has already passed");
        _;
    }

    modifier onlyBefore(uint256 beforeTime) {
        require(block.timestamp < beforeTime || beforeTime == 0, "IDO: time is out");
        _;
    }

    modifier onlyFundAmount(uint256 amount) {
        require(fundedAmount + amount <= fundAmount, "IDO: fund amount is greater than the rest");
        _;
    }

    modifier onlyFunder(address funder) {
        require(fundedAmounts[funder] > 0, "IDO: user didn't fund");
        _;
    }

    modifier onlyOperator() {
        require(IDOFactory(owner()).isOperator(msg.sender), "IDO: caller is not operator");
        _;
    }

    /**
     * @notice Operator sets the time to start
     * @param _startTime: timestamp that the sale will start
     */
    function setStartTime(uint256 _startTime) external onlyOperator onlyBefore(startTime) {
        require(_startTime > block.timestamp, "IDO: start time is greater than now");
        startTime = _startTime;
    }

    /**
     * @notice Operator sets the time to end
     * @param _endTime: timestamp that the sale will end
     */
    function setEndTime(uint256 _endTime) external onlyOperator onlyBefore(endTime) {
        require(startTime <= _endTime, "IDO: end time must be greater than start time");
        endTime = _endTime;
    }

    /**
     * @notice Operator sets the time to claim
     * @param _claimTime: timestamp that users can start claiming the saleToken
     */
    function setClaimTime(uint256 _claimTime) external onlyOperator onlyBefore(claimTime) {
        require(endTime < _claimTime, "IDO: claim time must be greater than end time");
        claimTime = _claimTime;
    }

    /**
     * @notice Operator sets factors for vesting saleToken
     * @param _tge: percent to claim till cliffTime
     * @param _cliffTime: timestamp to claim with tge
     * @param _duration: after cliffTime, How long funders can claim
     * @param _periodicity: after cliffTime, How often funders claim
     */
    function setVestInfo(
        uint256 _tge,
        uint256 _cliffTime,
        uint256 _duration,
        uint256 _periodicity
    ) external onlyOperator onlyBefore(cliffTime) {
        require(claimTime < _cliffTime, "IDO: cliff time must be greater than claim time");
        require(_tge < 100, "IDO: tge must be smaller than 100");
        require(_duration % _periodicity == 0, "IDO: duration must be a multiple of periodicity");
        tge = _tge;
        cliffTime = _cliffTime;
        duration = _duration;
        periodicity = _periodicity;
    }

    /**
     * @notice Operator sets the base amount
     * @param _baseAmount: tiers can fund up to “baseAmount * multiplier” during Tier Fund Round
     */
    function setBaseAmount(uint256 _baseAmount) external onlyOperator onlyBefore(startTime) {
        baseAmount = _baseAmount;
    }

    /**
     * @notice Operator sets the max amount per user
     * @param _maxAmountPerUser: investors can fund up to this value during FCFS round
     */
    function setMaxAmountPerUser(uint256 _maxAmountPerUser) external onlyOperator onlyBefore(startTime) {
        maxAmountPerUser = _maxAmountPerUser;
    }

    /**
     * @notice Operator sets the info of sale
     * @param _fundAmount: Amount of fund token
     * @param _saleAmount: Amount of sale token
     */
    function setSaleInfo(uint256 _fundAmount, uint256 _saleAmount) external onlyOperator onlyBefore(startTime) {
        fundAmount = _fundAmount;
        saleAmount = _saleAmount;
    }

    /**
     * @notice Operator sets the whitelisted user
     * @param _funder: Address of funder
     * @param _amount: Amount of the fund token
     */
    function setWhitelistAmount(address _funder, uint256 _amount) external onlyOperator onlyBefore(startTime) {
        whitelistedAmounts[_funder] = _amount;
    }

    /**
     * @notice Operator sets whitelisted users
     * @param _funders: Array of the funder address
     * @param _amounts: Array of the fund token amount
     */
    function setWhitelistAmounts(address[] memory _funders, uint256[] memory _amounts)
        external
        onlyOperator
        onlyBefore(startTime)
    {
        for (uint256 i = 0; i < _funders.length; i++) {
            whitelistedAmounts[_funders[i]] = _amounts[i];
        }
    }

    /**
     * @notice IDOFacotory owner finalizes the IDO
     * @param _idoFactoryOwner: Address of the IDOFactory owner
     * @param _finalizer: Address of user account sending the fund token
     * @param _feePercent: "feePercent" of "totalFunded" will be sent to "feeRecipient" address
     * @param _feeRecipient: "feePercent" of "totalFunded" will be sent to "feeRecipient" address
     */
    function finalize(
        address _idoFactoryOwner,
        address _finalizer,
        uint256 _feePercent,
        address _feeRecipient
    ) external onlyOwner {
        require(block.timestamp > endTime, "IDO: IDO is not ended yet");
        require(state == State.Waiting, "IDO: IDO has already ended");
        if (fundedAmount < (fundAmount * 51) / 100) {
            state = State.Failure;
        } else {
            uint256 _feeAmout = (_feePercent * fundedAmount) / 100;
            state = State.Success;
            // console.log("fee recipient:", feeRecipient, feeAmout);
            IERC20(fundToken).transfer(_feeRecipient, _feeAmout);
            // console.log("finalizer:", finalizer, _fundedAmount - feeAmout);
            IERC20(fundToken).transfer(_finalizer, fundedAmount - _feeAmout);
            IERC20(saleToken).transferFrom(
                _idoFactoryOwner,
                address(this),
                (fundedAmount * saleAmount) / fundAmount
            );
        }
    }

    /**
     * @notice Get a sate of IDO
     * @return state: Return the IDO state
     */
    function getState() external view returns (State) {
        return state;
    }

    /**
     * @notice Users fund
     * @param _funder: Funder address
     * @param _amount: Fund token amount
     */
    function fund(address _funder, uint256 _amount) external onlyInTime(startTime, endTime) onlyFundAmount(_amount) {
        require(state == State.Waiting, "IDO: funder can't fund");
        uint256 nowHours = block.timestamp % SECONDS_PER_DAY;

        if (nowHours < TIER_FUND_TIME) {
            uint256 multiplier = IDOFactory(owner()).getMultiplier(_funder);
            // console.log("tier:", multiplier * _baseAmount, amount);
            require(multiplier * baseAmount >= _amount, "IDO: fund amount is too much");
        } else if (nowHours < WHITELISTED_USER_FUND_TIME) {
            // console.log("whitelisted user:", _whitelistedAmounts[funder], amount);
            require(whitelistedAmounts[_funder] >= _amount, "IDO: fund amount is too much");
        } else {
            // console.log("any user:", _maxAmountPerUser, amount);
            require(maxAmountPerUser >= _amount, "IDO: fund amount is too much");
        }
        fundedAmount += _amount;
        fundedAmounts[_funder] += _amount;

        IERC20(fundToken).transferFrom(_funder, address(this), _amount);
    }

    /**
     * @notice Users claim
     * @param _claimer: Claimer address
     * @param _amount: Claim token amount
     */
    function claim(address _claimer, uint256 _amount) external onlyFunder(_claimer) {
        require(block.timestamp > claimTime, "IDO: claim time is not yet");
        require(state == State.Success, "IDO: state is not success");
        uint256 cnt = duration / periodicity;
        uint256 passTime = block.timestamp < cliffTime ? 0 : block.timestamp - cliffTime + periodicity;
        uint256 maxAmount = (fundedAmounts[_claimer] *
            perAmount *
            (tge + (((100 - tge)) / cnt) * (passTime / periodicity))) / 100;
        // console.log(maxAmount, amount);
        require(maxAmount >= _amount + claimedAmounts[_claimer], "IDO: claim amount is greater than the rest");
        claimedAmounts[_claimer] += _amount;
        IERC20(saleToken).transfer(_claimer, _amount);
    }

    /**
     * @notice Users refund the funded token
     * @param _refunder: Refunder address
     */
    function refund(address _refunder) external onlyFunder(_refunder) {
        require(state == State.Failure, "IDO: state is not failure");
        uint256 amount = fundedAmounts[_refunder];
        fundedAmounts[_refunder] = 0;
        IERC20(fundToken).transfer(_refunder, amount);
    }

    /**
     * @notice IDOFactory owner calls to cancel the IDO
     */
    function emergencyRefund() external onlyOwner onlyBefore(endTime) {
        state = State.Failure;
    }

    function getNowTime() external view returns (uint256) {
        return block.timestamp;
    }
}

// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

interface ITier {
    function getMultiplier(address point, address user) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC20.sol)

pragma solidity ^0.8.0;

import "../token/ERC20/IERC20.sol";

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