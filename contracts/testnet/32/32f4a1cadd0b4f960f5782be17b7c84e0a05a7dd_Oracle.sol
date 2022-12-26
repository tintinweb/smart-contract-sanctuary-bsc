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

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

interface ICore {
    enum ConditionState {
        CREATED,
        RESOLVED,
        CANCELED,
        PAUSED
    }

    struct Bet {
        uint256 conditionId;
        uint256 amount;
        uint256 outcome;
        uint256 createdAt;
        uint256 odds;
        bool payed;
    }

    struct Condition {
        uint256[] funds;
        uint256[] payouts;
        uint256[] totalNetBets;
        uint256 reinforcement;
        uint256 margin;
        bytes32 ipfsHash;
        uint256[] outcomes; // unique outcomes for the condition
        uint256 scopeId;
        uint256 conditionTypeId;
        uint256 outcomeWin;
        uint256 timestamp; // after this time user cant put bet on condition
        ConditionState state;
    }

    function getLastConditionId() external view returns (uint256);

    function getCondition(
        uint256 _conditionId
    ) external view returns (Condition memory);

    function getLockedPayout() external view returns (uint256);

    function createCondition(
        uint256 _oracleConditionId,
        uint256 _scopeId,
        uint256 _conditionTypeId,
        uint256[] memory _odds,
        uint256[] memory _outcomes,
        uint256 _timestamp,
        bytes32 _ipfsHash,
        uint256 _reinforcement,
        uint256 _margin
    ) external;

    function resolveCondition(
        uint256 _conditionId,
        uint256 _outcomeWin
    ) external;

    function cancelByOracle(uint256 _oracleCondId) external;

    function shiftByOracle(
        uint256 _oracleCondId,
        uint256 _newTimestamp
    ) external;

    function viewPayout(uint256 _tokenId) external view returns (bool, uint256);

    function resolvePayout(uint256 _tokenId) external returns (bool, uint256);

    function setLp(address _lp) external;

    /**
     * @notice LP: Register new bet in the core.
     * @param  _conditionId the match or game ID
     * @param  _tokenId Sport Book bet token ID
     * @param  _amount amount of tokens to bet
     * @param  _outcome ID of predicted outcome
     * @param  _minOdds minimum allowed bet odds
     * @return _betting odds
     * @return _funds funds of condition
     */
    function putBet(
        uint256 _conditionId,
        uint256 _tokenId,
        uint256 _amount,
        uint256 _outcome,
        uint256 _minOdds
    ) external returns (uint256, uint256[] memory);

    function getBetInfo(
        uint256 _betId
    )
        external
        view
        returns (uint256 _amount, uint256 _odds, uint256 _createdAt);

    function isOracle(address _oracle) external view returns (bool);
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "openzeppelin/access/Ownable.sol";
import "../interfaces/ICore.sol";

contract Oracle is Ownable {
    // struct Condition {
    //     uint128 scopeId;
    //     uint256[] odds;
    //     uint256[] outcomes;
    //     uint256 timestamp;
    //     bytes32 ipfsHash;
    // }

    // uint256 constant PRECISION = 1e9;
    uint256 public lastOracleConditionId;
    ICore public core;
    mapping(uint256 => uint256) public conditions; // mapping oracleConditionId - conditionId
    mapping(address => bool) public isReporter;
    address[] public reporters;

    modifier onlyReporter() {
        require(isReporter[msg.sender], "Oracle:unauthorized");
        _;
    }

    /* ========== VIEW FUNCTIONS ============== */
    function getCondition(
        uint256 _oracleId
    ) public view returns (ICore.Condition memory) {
        uint256 conditionId = conditions[_oracleId];
        return core.getCondition(conditionId);
    }

    /* ========== EXTERNAL FUNCTIONS ========== */

    constructor(address _core) {
        require(_core != address(0), "Oracle::contructor:: core invalid");
        core = ICore(_core);
    }

    function listCondition(
        uint128 _scopeId,
        uint128 _conditionTypeId,
        uint256[] calldata _odds,
        uint256[] calldata _outcomes,
        uint256 _timestamp,
        bytes32 _ipfsHash,
        uint256 _reinforcement,
        uint256 _margin
    ) external onlyReporter {
        lastOracleConditionId++;
        core.createCondition(
            lastOracleConditionId,
            _scopeId,
            _conditionTypeId,
            _odds,
            _outcomes,
            _timestamp,
            _ipfsHash,
            _reinforcement,
            _margin
        );
        uint256 conditionId = core.getLastConditionId();
        conditions[lastOracleConditionId] = conditionId;
        emit ConditionListed(
            lastOracleConditionId,
            _scopeId,
            _odds,
            _outcomes,
            _timestamp,
            _ipfsHash,
            _reinforcement,
            _margin
        );
    }

    function resolveCondition(
        uint256 _oracleCondId,
        uint256 _outcomeWin
    ) external onlyReporter {
        core.resolveCondition(_oracleCondId, _outcomeWin);
        emit ConditionResolved(_oracleCondId, _outcomeWin);
    }

    function cancelCondition(uint256 _oracleCondId) external onlyReporter {
        core.cancelByOracle(_oracleCondId);
        emit ConditionCanceled(_oracleCondId);
    }

    function shiftByOracle(
        uint256 _oracleCondId,
        uint256 _newTimestamp
    ) external onlyReporter {
        core.shiftByOracle(_oracleCondId, _newTimestamp);
        emit ConditionShifted(_oracleCondId, _newTimestamp);
    }

    function changeCore(address _addr) external onlyOwner {
        core = ICore(_addr);
        emit CoreChanged(_addr);
    }

    /* ========== RESTRICTIVE FUNCTIONS ========== */

    function addReporter(address reporter) external onlyOwner {
        require(!isReporter[reporter], "Oracle:reporterAlreadyAdded");
        isReporter[reporter] = true;
        reporters.push(reporter);
        emit ReporterAdded(reporter);
    }

    function removeReporter(address reporter) external onlyOwner {
        require(reporter != address(0), "Oracle:invalidAddress");
        require(isReporter[reporter], "Oracle:reporterNotExists");
        isReporter[reporter] = false;
        for (uint256 i = 0; i < reporters.length; i++) {
            if (reporters[i] == reporter) {
                reporters[i] = reporters[reporters.length - 1];
                break;
            }
        }
        reporters.pop();
        emit ReporterRemoved(reporter);
    }

    // =========== Events ===========
    event ConditionListed(
        uint256 conditionId,
        uint128 scopeId,
        uint256[] odds,
        uint256[] outcomes,
        uint256 timestamp,
        bytes32 ipfsHash,
        uint256 reinforcement,
        uint256 margin
    );
    event CoreChanged(address);
    event ReporterAdded(address);
    event ReporterRemoved(address);
    event ConditionResolved(
        uint256 indexed oracleConditionId,
        uint256 outcomeWin
    );

    event ConditionCanceled(uint256 indexed oracleConditionId);

    event ConditionShifted(uint256 oracleCondId, uint256 newTimestamp);
}