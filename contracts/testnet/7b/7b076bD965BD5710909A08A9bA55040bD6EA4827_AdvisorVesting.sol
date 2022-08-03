// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import '../token/BEP20/IBEP20.sol';

contract AdvisorVesting is ReentrancyGuard, Ownable {

    enum Status {
        Pending,
        Claimable,
        Claimed
    }

    struct VestingSetting {
        uint tgeTimestamp;
        uint tokenPercentUnlockOnTge;
        uint cliffInSeconds;
        uint periodDuration;
        uint numberOfEmmissions;
        uint totalSupply;
    }

    struct Vest {
        uint amount;
        uint amountClaimed;
    }

    Vest[] vests;

    // State Variables
    IBEP20 token;
    VestingSetting settings;
    uint allocated;

    address[] advisorsAddresses;

    mapping(address => bool) isadvisor;
    mapping(address => uint) advisorsAllocation;
    mapping(address => mapping(uint => mapping(uint => bool))) isClaimed;
    mapping(address => mapping(uint => mapping(uint => uint))) dateRealeased;
    mapping(address => uint) totalAmountClaimed;
    mapping(address => uint) customTimeStart;

    mapping(uint => address) vestToBeneficiary;
    mapping(address => uint) beneficiaryVestedCount;

    constructor(VestingSetting memory _settings, IBEP20 _token) 
    {
        token = _token;

        settings = _settings;
    }

    // Getters
    function vestsByOwner(address _beneficiary) external view returns (uint[] memory) {
        uint[] memory result = new uint[](beneficiaryVestedCount[_beneficiary]);
        uint counter = 0;
        for (uint i = 0; i < vests.length; i++) {
            if (vestToBeneficiary[i] == _beneficiary) {
                result[counter] = i;
                counter++;
            }
        }
        return result;
    }

    function getVestByIndex(uint _index) public view returns (
        uint totalAmountVested,
        uint amountClaimed,
        uint startDate,
        uint maturity
    ) {
        Vest storage vest = vests[_index];
        return (
            vest.amount,
            vest.amountClaimed,
            settings.tgeTimestamp,
            maturityDate(vestToBeneficiary[_index])
        );
    }

    function advisors() public view returns (address[] memory) {
        return advisorsAddresses;
    }

    function schedule(address _beneficiary, uint _index, uint _period) public view returns (
        uint date,
        uint amount,
        uint dateClaimed,
        Status status
    ) {
        date = settings.tgeTimestamp == 0 ? 0 : _periodToDate(_beneficiary, _period);
        amount = _amountByPeriod(_index, _period);
        dateClaimed = dateRealeased[_beneficiary][_index][_period];
        if (isClaimed[_beneficiary][_index][_period] == true) {
            status = Status.Claimed;
        } else {
            if (settings.tgeTimestamp == 0){
                status = Status.Pending;
            } else {
                if (_periodToDate(_beneficiary, _period) > block.timestamp) {
                status = Status.Pending;
                } else if (_periodToDate(_beneficiary, _period) <= block.timestamp) {
                    status = Status.Claimable;
                }
            }
        }
    }

    function maturityDate(address _advisor) public view returns (uint) {
        return _periodToDate(_advisor, settings.numberOfEmmissions);
    }

    function getAllocated() public view returns (uint) {
        return allocated;
    }

    function getAdvisorAllocation(address _advisor) public view returns (uint) {
        return advisorsAllocation[_advisor];
    }

    function getVestingInfo(address _advisor) public view returns (
        uint totalAmountVested,
        uint amountClaimed,
        uint startDate,
        uint maturity
    ) {
        return (
            advisorsAllocation[_advisor],
            totalAmountClaimed[_advisor],
            customTimeStart[_advisor] == 0 ? settings.tgeTimestamp : customTimeStart[_advisor],
            maturityDate(_advisor)
        );
    }

    function getTotalSupply() public view returns (uint) {
        return settings.totalSupply;
    }

    function periodToDate(address _advisor, uint _period) external view returns (uint date) {
        date = _periodToDate(_advisor, _period);
    }

    function getSettings() external view returns (VestingSetting memory) {
        return settings;
    }

    function setTge(uint _timestamp) external onlyOwner {
        settings.tgeTimestamp = _timestamp;
    }
    
    function increaseTotalSupply(uint _amount) external nonReentrant onlyOwner {
        require(token.transferFrom(owner(), address(this), _amount), 'Token transfer is required');
        settings.totalSupply += _amount;
    }

    function setAdvisorAndAllocation(address _advisor, uint _amount) external onlyOwner {
        require(_amount + allocated <= settings.totalSupply, 'Token is fully allocated');
        require(_advisor != address(0), "wallet is the zero address");
        require(_amount > 0, 'amount cannot be zero');
        if (settings.tgeTimestamp > 0) {
            customTimeStart[_advisor] = block.timestamp;
        }
        isadvisor[_advisor] = true;
        allocated += _amount;
        advisorsAllocation[_advisor] += _amount;
        advisorsAddresses.push(_advisor);

        Vest memory newVest;
        newVest.amount = _amount;
        vests.push(newVest);
        uint index = vests.length - 1;
        vestToBeneficiary[index] = _advisor;
        beneficiaryVestedCount[_advisor]++;
    }

    function release(uint _index, uint _period) external nonReentrant {
        require(settings.tgeTimestamp != 0, 'Cannot release tge not set');
        require(_period >= 1 && _period <= settings.numberOfEmmissions, 'Invalid period');
        require(_periodToDate(msg.sender, _period) <= block.timestamp, 'Cannot release now');
        require(isadvisor[msg.sender], 'Caller is not advisor');
        require(isClaimed[msg.sender][_index][_period] == false, 'Claimed Already');
        uint amount = _amountByPeriod(_index, _period);
        token.transfer(msg.sender, amount);
        isClaimed[msg.sender][_index][_period] = true;
        dateRealeased[msg.sender][_index][_period] = block.timestamp;
        Vest storage vest = vests[_index];
        vest.amountClaimed += amount;
        totalAmountClaimed[msg.sender] += amount;
    }

    function withdraw() external returns(uint amount) {
        require(settings.totalSupply > allocated, 'Token is fully allocated you cannnot withraw');
        amount = settings.totalSupply - allocated;
        token.transfer(owner(), amount);
    }

    function _getCurrentPeriod() private view returns (uint256 currentPeriod) {
        uint256 timePassed = (block.timestamp - (settings.tgeTimestamp + settings.cliffInSeconds)) / 60;
        currentPeriod = timePassed / 30 days;
    }

    function _periodToDate(address _advisor, uint _period) private view returns (uint date) {
        if (customTimeStart[_advisor] != 0) {
            date = customTimeStart[_advisor] + settings.cliffInSeconds + (settings.periodDuration * (_period - 1));
        } else {
            date = settings.tgeTimestamp + settings.cliffInSeconds + (settings.periodDuration * (_period - 1));
        }
    }

    //Calculate amount based on period
    function _amountByPeriod(uint _index, uint _period) internal view returns (uint tokenAmount) {
        Vest storage vest = vests[_index];
        if (_period == 1) {
            tokenAmount = (vest.amount / 100) * settings.tokenPercentUnlockOnTge;
        } else {
            tokenAmount = (vest.amount - ((vest.amount / 100) * settings.tokenPercentUnlockOnTge)) / (settings.numberOfEmmissions - 1);
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

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
    function allowance(address _owner, address spender) external view returns (uint256);

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
    constructor () {
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

pragma solidity ^0.8.0;

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

    constructor () {
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

pragma solidity ^0.8.0;

/*
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
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}