// SPDX-License-Identifier: https://multiverseexpert.io/
pragma solidity ^0.8.2;
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IMGNLAND {
    function _lockLand(uint256 tokenId, address sender) external;

    function _unlockLand(uint256 tokenId, address sender) external;
}

interface IMGNToken {
    function mint(address to, uint256 amount) external;
}

contract MGNStake is Pausable, Ownable {
    struct stLand {
        uint256 tokenId;
        address wallet;
        uint256 stakeID;
        uint256 Month;
        uint256 Roi;
        uint256 timestamp;
        bool isLocked;
        uint256 expiration;
        uint256 benefits;
    }

    stLand[] stakes;

    event staked(
        uint8 stakeId,
        address owner,
        uint256 amount,
        uint256 _month,
        uint256 _roi
    );

    uint8[3] month = [6, 9, 12];
    uint256 extra = 0.0003 ether;
    uint256 pricePerLand = 100;
    address landAddress;
    address mgnAddress;
    mapping(uint256 => uint256) roi;

    uint8 StakeID = 0;
    IMGNToken mgntoken;
    IMGNLAND land;
    uint256 stakeAmount = 0;

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
        uint8 stakeId = StakeID++;
        uint256 amount = _tokenId.length;
        for (uint256 i = 0; i < _tokenId.length; i++) {
            land._lockLand(_tokenId[i], msg.sender); // lock lands
            stakes.push(
                stLand({
                    tokenId: _tokenId[i],
                    wallet: payable(msg.sender),
                    stakeID: stakeId,
                    Roi: roi[_month],
                    Month: _month,
                    timestamp: block.timestamp,
                    isLocked: true,
                    expiration: block.timestamp + _month * 1 minutes,
                    benefits: getBenefits(amount, roi[_month])
                })
            );
        }
        emit staked(stakeId, msg.sender, amount, _month, roi[_month]);
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
        uint256 _benefits;

        for (uint256 i = 0; i < stakes.length; i++) {
            if (_stakeId == stakes[i].stakeID) {
                require(stakes[i].isLocked == true, "The land must be locked");
                require(
                    stakes[i].wallet == msg.sender,
                    "The land must be owned by sender"
                );
                require(
                    block.timestamp >= stakes[i].expiration,
                    "The land haven't reached the due"
                );

                land._unlockLand(stakes[i].tokenId, msg.sender); // unlock lands
                _benefits = stakes[i].benefits;
                delete stakes[i];
            } else {
                revert("There is no stake Id you add");
            }
        }
        mgntoken.mint(msg.sender, _benefits);
    }

    function getStakes() public view returns (stLand[] memory) {
        return stakes;
    }

    function getStakeByOwner(address _address)
        public
        view
        returns (stLand[] memory)
    {
        uint256 _amount = getAmountbyOwner(_address);
        stLand[] memory _owned = new stLand[](_amount);

        uint256 index = 0;
        for (uint256 i = 0; i < stakes.length; i++) {
            if (stakes[i].wallet == _address) {
                _owned[index] = stakes[i];
                index++;
            }
        }
        return _owned;
    }

    function getAmountbyOwner(address _address)
        internal
        view
        returns (uint256)
    {
        uint256 _amount = stakeAmount;

        for (uint256 i = 0; i < stakes.length; i++) {
            if (stakes[i].wallet == _address) {
                _amount++;
            }
        }
        return _amount;
    }

    function getStakeByStakeId(uint256 _stakeId)
        public
        view
        returns (stLand[] memory)
    {
        uint256 _amount = getAmountbyStakeId(_stakeId);
        stLand[] memory _staked = new stLand[](_amount);

        uint256 index = 0;
        for (uint256 i = 0; i < stakes.length; i++) {
            if (stakes[i].stakeID == _stakeId) {
                _staked[index] = stakes[i];
                index++;
            }
        }
        return _staked;
    }

    function getAmountbyStakeId(uint256 _satkeId)
        internal
        view
        returns (uint256)
    {
        uint256 _amount = stakeAmount;

        for (uint256 i = 0; i < stakes.length; i++) {
            if (stakes[i].stakeID == _satkeId) {
                _amount++;
            }
        }
        return _amount;
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