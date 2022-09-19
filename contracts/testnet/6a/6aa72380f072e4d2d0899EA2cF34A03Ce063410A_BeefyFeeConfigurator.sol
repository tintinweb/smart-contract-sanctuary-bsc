// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin-4/contracts/access/Ownable.sol";

contract BeefyFeeConfigurator is Ownable {

    struct FeeCategory {
        uint256 total;      // total fee charged on each harvest
        uint256 beefy;      // split of total fee going to beefy fee batcher
        uint256 call;       // split of total fee going to harvest caller
        uint256 strategist;     // split of total fee going to developer of the strategy
        string label;       // description of the type of fee category
        bool active;        // on/off switch for fee category
    }

    address public keeper;
    uint256 public totalLimit;
    uint256 constant DIVISOR = 1 ether;

    mapping(address => uint256) public stratFeeId;
    mapping(uint256 => FeeCategory) internal feeCategory;

    event SetStratFeeId(address indexed strategy, uint256 indexed id);
    event SetFeeCategory(
        uint256 indexed id,
        uint256 total,
        uint256 beefy,
        uint256 call,
        uint256 strategist,
        string label,
        bool active
    );
    event Pause(uint256 indexed id);
    event Unpause(uint256 indexed id);
    event SetKeeper(address indexed keeper);

    constructor(
        address _keeper,
        uint256 _totalLimit
    ) {
        keeper = _keeper;
        totalLimit = _totalLimit;
    }

    // checks that caller is either owner or keeper
    modifier onlyManager() {
        require(msg.sender == owner() || msg.sender == keeper, "!manager");
        _;
    }

    // fetch fees for a strategy
    function getFees(address _strategy) external view returns (FeeCategory memory) {
        return getFeeCategory(stratFeeId[_strategy], false);
    }

    // fetch fees for a strategy, _adjust option to view fees as % of total harvest instead of % of total fee
    function getFees(address _strategy, bool _adjust) external view returns (FeeCategory memory) {
        return getFeeCategory(stratFeeId[_strategy], _adjust);
    }

    // fetch fee category for an id if active, otherwise return default category
    // _adjust == true: view fees as % of total harvest instead of % of total fee
    function getFeeCategory(uint256 _id, bool _adjust) public view returns (FeeCategory memory fees) {
        uint256 id = feeCategory[_id].active ? _id : 0;
        fees = feeCategory[id];
        if (_adjust) {
            uint256 _totalFee = fees.total;
            fees.beefy = fees.beefy * _totalFee / DIVISOR;
            fees.call = fees.call * _totalFee / DIVISOR;
            fees.strategist = fees.strategist * _totalFee / DIVISOR;
        }
    }

    // set a fee category id for a strategy that calls this function directly
    function setStratFeeId(uint256 _feeId) external {
        _setStratFeeId(msg.sender, _feeId);
    }

    // set a fee category id for a strategy by a manager
    function setStratFeeId(address _strategy, uint256 _feeId) external onlyManager {
        _setStratFeeId(_strategy, _feeId);
    }

    // set fee category ids for multiple strategies at once by a manager
    function setStratFeeId(address[] memory _strategies, uint256[] memory _feeIds) external onlyManager {
        uint256 stratLength = _strategies.length;
        for (uint256 i = 0; i < stratLength; i++) {
            _setStratFeeId(_strategies[i], _feeIds[i]);
        }
    }

    // internally set a fee category id for a strategy
    function _setStratFeeId(address _strategy, uint256 _feeId) internal {
        stratFeeId[_strategy] = _feeId;
        emit SetStratFeeId(_strategy, _feeId);
    }

    // set values for a fee category using the relative split for call and strategist
    // i.e. call = 0.01 ether == 1% of total fee
    // _adjust == true: input call and strat fee as % of total harvest
    function setFeeCategory(
        uint256 _id,
        uint256 _total,
        uint256 _call,
        uint256 _strategist,
        string memory _label,
        bool _active,
        bool _adjust
    ) external onlyOwner {
        require(_total <= totalLimit, ">totalLimit");
        if (_adjust) {
            _call = _call * DIVISOR / _total;
            _strategist = _strategist * DIVISOR / _total;
        }
        uint256 beefy = DIVISOR - _call - _strategist;

        FeeCategory memory category = FeeCategory(_total, beefy, _call, _strategist, _label, _active);
        feeCategory[_id] = category;
        emit SetFeeCategory(_id, _total, beefy, _call, _strategist, _label, _active);
    }

    // deactivate a fee category making all strategies with this fee id revert to default fees
    function pause(uint256 _id) external onlyManager {
        feeCategory[_id].active = false;
        emit Pause(_id);
    }

    // reactivate a fee category
    function unpause(uint256 _id) external onlyManager {
        feeCategory[_id].active = true;
        emit Unpause(_id);
    }

    // change keeper
    function setKeeper(address _keeper) external onlyManager {
        keeper = _keeper;
        emit SetKeeper(_keeper);
    }
}

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