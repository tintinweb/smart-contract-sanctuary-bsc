//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";

contract FIFAResource is Ownable {

    uint64 private _regionIndex;
    uint64 private _worldCupIndex;

    mapping(uint64 => string) public regionAlpha3;
    mapping(uint64 => string) public worldCupYear;

    mapping(string => bool) public regionAlpha3Check;
    mapping(string => bool) public worldCupYearCheck;

    constructor() {}

    function getRegionCount() public view returns(uint64){
        return _regionIndex;
    }

    function getWorldCupCount() public view returns(uint64){
        return _worldCupIndex;
    }

    function getRegion(uint64 regionIndex) public view returns(string memory){
        return regionAlpha3[regionIndex];
    }

    function getWorldCup(uint64 worldCupIndex) public view returns(string memory){
        return worldCupYear[worldCupIndex];
    }

    function addRegion(string memory _regionAlpha3) public onlyOwner returns(uint64){
        require(!regionAlpha3Check[_regionAlpha3],"exist");
        uint64 index = _regionIndex;
        regionAlpha3[index] = _regionAlpha3;
        regionAlpha3Check[_regionAlpha3] = true;
        _regionIndex++;
        return index;
    }

    function modifyRegion(uint64 index, string memory _regionAlpha3) public onlyOwner returns(uint64){
        require(!regionAlpha3Check[_regionAlpha3],"exist");
        delete(regionAlpha3Check[regionAlpha3[index]]);
        regionAlpha3[index] = _regionAlpha3;
        regionAlpha3Check[_regionAlpha3] = true;
        return index;
    }

    function addWorldCup(string memory _worldCupYear) public onlyOwner returns(uint64){
        require(!worldCupYearCheck[_worldCupYear],"exist");
        uint64 index = _worldCupIndex;
        worldCupYear[index] = _worldCupYear;
        worldCupYearCheck[_worldCupYear] = true;
        _worldCupIndex++;
        return index;
    }

    function modifyWorldCup(uint64 index, string memory _worldCupYear) public onlyOwner returns(uint64){
        require(!worldCupYearCheck[_worldCupYear],"exist");
        delete(worldCupYearCheck[worldCupYear[index]]);
        worldCupYear[index] = _worldCupYear;
        worldCupYearCheck[_worldCupYear] = true;
        return index;
    }

    function addRegionBatch(string[] memory _regionAlpha3) public onlyOwner {
        for(uint i=0;i<_regionAlpha3.length;i++){
            if(regionAlpha3Check[_regionAlpha3[i]]){
                continue;
            }
            uint64 index = _regionIndex;
            regionAlpha3[index] = _regionAlpha3[i];
            regionAlpha3Check[_regionAlpha3[i]] = true;
            _regionIndex++;
        }
    }

    function addWorldCupBatch(string[] memory _worldCupYear) public onlyOwner {
        for(uint i=0;i<_worldCupYear.length;i++){
            if(worldCupYearCheck[_worldCupYear[i]]){
                continue;
            }
            uint64 index = _worldCupIndex;
            worldCupYear[index] = _worldCupYear[i];
            worldCupYearCheck[_worldCupYear[i]] = true;
            _worldCupIndex++;
        }
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