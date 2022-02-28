// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

interface IMGNLAND {
    function _lockLand(uint256 _tokenId, address _sender) external;

    function _unlockLand(uint256 _tokenId, address _sender) external;
}

interface IMGNToken {
    function mint(address to, uint256 amount) external;
}

contract MGNStake is Pausable, Ownable {
    struct sStake {
        address wallet;
        uint256 stakeID;
        uint256 Month;
        uint256 Roi;
        uint256 timestamp;
        bool isLocked;
        uint256 expiration;
        uint256 benefits;
    }

    mapping(address => mapping(uint256 => sStake)) public mStake;
    mapping(address => uint256[]) mStakeId;
    mapping(uint256 => uint256[]) public mTokenId;

    event staked(
        uint256 stakeId,
        address owner,
        uint256 amount,
        uint256 _month,
        uint256 _roi
    );

    uint8[3] month = [6, 9, 12];
    uint256 extra = 0.0003 ether;
    address landAddress;
    address mgnAddress;
    mapping(uint256 => uint256) roi;
    uint256 pricePerLand = 100;

    uint8 StakeID = 0;
    IMGNToken mgntoken;
    IMGNLAND land;
    uint256 stakeAmount = 0;
    using Counters for Counters.Counter;
    Counters.Counter private _stakeIdCounter;

    constructor(address _landAddress, address _mgnAddress) {
        land = IMGNLAND(_landAddress);
        mgntoken = IMGNToken(_mgnAddress);
        uint64[3] memory _roi = [0.05 ether, 0.12 ether, 0.22 ether];
        for (uint256 i = 0; i < month.length; i++) {
            roi[month[i]] = _roi[i];
        }
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function stakeLand(uint256[] memory _tokenId, uint256 _month)
        public
        whenNotPaused
    {
        require(
            _month == month[0] || _month == month[1] || _month == month[2],
            "The month value doesn't match"
        );
        require(_month != 0, "The month value != 0");
        require(_tokenId.length > 0, "You didn't put any land for staking");
        for (uint256 i = 0; i < _tokenId.length; i++) {
            land._lockLand(_tokenId[i], msg.sender); // lock lands
        }
        uint256 stakeId = _stakeIdCounter.current();
        uint256 _benefits = getBenefits(_tokenId.length, roi[_month]);
        mTokenId[stakeId] = _tokenId;
        mStakeId[msg.sender].push(stakeId);
        mStake[msg.sender][stakeId] = sStake(
            msg.sender,
            stakeId,
            _month,
            roi[_month],
            block.timestamp,
            true,
            (block.timestamp + _month * 1 seconds),
            _benefits
        );

        _stakeIdCounter.increment();
        emit staked(stakeId, msg.sender, _tokenId.length, _month, roi[_month]);
    }

    function getBenefits(uint256 _amount, uint256 _roi)
        private
        view
        returns (uint256)
    {
        uint256 _benefits;
        uint256 _totalPrice = _amount * pricePerLand;
        _benefits = (_totalPrice * _roi);

        if (_amount >= 2) {
            _benefits = _benefits + (_totalPrice * extra);
        } else if (_amount > 100) {
            _benefits = _benefits + (100 * pricePerLand * extra);
        }
        return _benefits;
    }

    function unstakeLand(uint256 _stakeId) public whenNotPaused {
        require(
            mStake[msg.sender][_stakeId].isLocked == true,
            "The land must be locked"
        );
        require(
            block.timestamp >= mStake[msg.sender][_stakeId].expiration,
            "The land haven't reached the due"
        );

        if (_stakeId == mStake[msg.sender][_stakeId].stakeID) {
            mgntoken.mint(msg.sender, mStake[msg.sender][_stakeId].benefits);
            delete mStake[msg.sender][_stakeId];

            for (uint256 i = 0; i < mTokenId[_stakeId].length; i++) {
                land._unlockLand(mTokenId[_stakeId][i], msg.sender); // unlock lands
            }
        }

        delete mTokenId[_stakeId];
    }

    function getStakeByOwner(address _owner)
        public
        view
        returns (sStake[] memory)
    {
        uint256[] memory _stakeId = mStakeId[_owner];
        sStake[] memory _stakeItem = new sStake[](_stakeId.length);

        for (uint256 i = 0; i < _stakeId.length; i++) {
            _stakeItem[i] = (mStake[_owner][_stakeId[i]]);
        }
        return _stakeItem;
    }

    function setPricePerLand(uint256 _price) public whenNotPaused onlyOwner {
        require(_price > 0, "Price amount is not valid");
        pricePerLand = _price;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
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