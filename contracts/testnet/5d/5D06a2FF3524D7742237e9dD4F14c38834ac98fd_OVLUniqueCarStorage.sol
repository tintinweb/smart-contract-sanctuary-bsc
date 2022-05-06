// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract OVLUniqueCarStorage is Ownable {
    // mapping for combination can claim
    mapping(uint256 => bool) private combinations;
    // mapping for combinationHash - price
    mapping(uint256 => uint256) private carPrices;

    // mapping for carId - total of reward
    mapping(uint256 => uint256) private totalCarCombination;
    uint256 public TOTAL_COMBINATION_COUNT;

    
    function addCombination(
        uint256[] calldata _combinations,
        uint256[] calldata _prices
    ) public onlyOwner returns (bool) {
        require(_combinations.length == _prices.length, "bad request");
        uint256 count = 0;
        for (uint256 i = 0; i < _combinations.length; i++) {
            uint256 _hash = _combinations[i];
            if (!combinations[_hash]) {
                // TODO: validate combination hash
                (, , uint256 _body, ) = decodeCombinationHash(_hash);
                uint256 _carId = getCarId(_body);
                totalCarCombination[_carId]++;
                combinations[_hash] = true;
                carPrices[_hash] = _prices[i];
                TOTAL_COMBINATION_COUNT++;
            }
            count++;
        }
        return count == _combinations.length;
    }

    function removeCombination(uint256[] calldata _combinations)
        public
        onlyOwner
    {
        for (uint256 i = 0; i < _combinations.length; i++) {
            uint256 _hash = _combinations[i];
            if (combinations[_hash]) {
                (, , uint256 _body, ) = decodeCombinationHash(_hash);
                uint256 _carId = getCarId(_body);
                totalCarCombination[_carId]--;

                TOTAL_COMBINATION_COUNT--;
            }
            combinations[_hash] = false;
        }
    }

    function getTotalCombination() public view returns (uint256) {
        return TOTAL_COMBINATION_COUNT;
    }

    function getTotalCarCombination(uint256 _carId)
        public
        view
        returns (uint256)
    {
        return totalCarCombination[_carId];
    }

    function getCarPrice(uint256 _combinationHash)
        public
        view
        returns (uint256)
    {
        return carPrices[_combinationHash];
    }

    //
    function checkCombination(uint256 _combinationHash)
        public
        view
        returns (bool)
    {
        return combinations[_combinationHash];
    }

    /**
     * Get part type by assetId
     * Examples:
     * 1000001 => 10 => Engine
     * 1100001 => 11 => Wheel
     * 1200001 => 12 => Body
     * 1300001 => 13 => Rear
     */
    function getPartType(uint256 _assetId) public pure returns (uint256) {
        return (_assetId - (_assetId % 100000)) / 100000;
    }

    /**
     * Get car name by assetId (Body/Rear)
     * Examples:
     * 1000001 => 00 => ALL
     * 1210001 => 100 => Rhino
     * 1210101 => 101 => Bullfrog
     * 1310202 => 102 => Turbo
     * ...etc
     */
    function getCarId(uint256 _assetId) public pure returns (uint256) {
        return ((_assetId - (_assetId % 10)) % 100000) / 100;
    }

    /**
     * Encode assetIds (4 parts) into one uint256
     * Example:
     *
     */
    function encodeCombinationHash(
        uint256 _engine,
        uint256 _wheel,
        uint256 _body,
        uint256 _rear
    ) public pure returns (uint256) {
        uint256 value;
        value |= _engine; // engine
        value |= (_wheel << 31); // wheel
        value |= (_body << 63); // body
        value |= (_rear << 94); // rear

        return value;
    }

    /**
     * Decode a uint256 back to assetIds (4 parts)
     * Example:
     *
     */
    function decodeCombinationHash(uint256 _combinationHash)
        public
        pure
        returns (
            uint256, // engine
            uint256, // wheel
            uint256, // body
            uint256 // rear
        )
    {
        return (
            (_combinationHash) & ((1 << 31) - 1),
            (_combinationHash >> 31) & ((1 << 31) - 1),
            (_combinationHash >> 63) & ((1 << 31) - 1),
            (_combinationHash >> 94) & ((1 << 31) - 1)
        );
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