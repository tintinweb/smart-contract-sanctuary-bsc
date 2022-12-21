// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "./ICollections.sol";

contract Collections is Ownable,Pausable,ICollections {
    mapping (address => uint256) public Collection_ID;
    mapping (uint256 => address) public ID_Collection;
    mapping (uint256 => uint256) public Max_id_Collection;

    mapping (uint256 => bool) public NFTW_Col;
    mapping (uint256 => bool) public NFTA_Col;
    mapping (uint256 => bool) public NFTWA_Col;

    uint256 TotalNFTWA;
    uint256 TotalNFTW;
    uint256 TotalNFTA;
 
    function ADD_Collection_NFTWA(uint256 ID, address Collection_address,uint256 Max_world) public onlyOwner {
        require(Collection_ID[Collection_address]==0);
        require(ID_Collection[ID]==address(0x0));
          Collection_ID[Collection_address]=ID;
          ID_Collection[ID]=Collection_address;
          Max_id_Collection[ID]=Max_world;
          TotalNFTWA=TotalNFTWA+Max_world;
            NFTWA_Col[ID] = true;
    }

    function ADD_Collection_NFTW (uint256 ID, address Collection_address,uint256 Max_world) public onlyOwner {
        require(Collection_ID[Collection_address]==0);
        require(ID_Collection[ID]==address(0x0));
          Collection_ID[Collection_address]=ID;
          ID_Collection[ID]=Collection_address;
          Max_id_Collection[ID]=Max_world;
          TotalNFTW=TotalNFTW+Max_world;
          NFTW_Col[ID]=true;
    }

    function ADD_Collection_NFTA (uint256 ID, address Collection_address,uint256 Max_world) public onlyOwner {
        require(Collection_ID[Collection_address]==0);
        require(ID_Collection[ID]==address(0x0));
          Collection_ID[Collection_address]=ID;
          ID_Collection[ID]=Collection_address;
          Max_id_Collection[ID]=Max_world;
          TotalNFTW=TotalNFTW+Max_world;
          TotalNFTA=TotalNFTA+Max_world;
          NFTA_Col[ID]=true;
    }

    function Get_NFTA () public virtual override view returns (uint256){
        return TotalNFTA;
    }
    function Get_NFTW () public virtual override view returns (uint256){
        return TotalNFTW;
    }
    function Get_NFTWA () public virtual override view returns (uint256){
        return TotalNFTWA;
    }

    function Get_NFTW_Col (uint256 ID_Collection_) public virtual override view returns (bool){
        return NFTW_Col[ID_Collection_];
    }
    function Get_NFTWA_Col (uint256 ID_Collection_) public virtual override view returns (bool){
        return NFTWA_Col[ID_Collection_];
    }
    function Get_NFTA_Col (uint256 ID_Collection_) public virtual override view returns (bool){
        return NFTA_Col[ID_Collection_];
    }


    function GetCollection_ID(address adr) public virtual override view returns (uint256) {
        return Collection_ID[adr];
    } 

    function GetID_Collection(uint256 ID) public virtual override view returns (address) {
        return ID_Collection[ID];
    }

    function Get_Max_id_Collection(uint256 ID) public virtual override view returns (uint256) {
        return Max_id_Collection[ID];
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface ICollections {
    function GetCollection_ID(address adr) external view returns (uint256);
    function GetID_Collection(uint256 ID) external view returns (address);
    function Get_Max_id_Collection(uint256 ID) external view returns (uint256);

    function Get_NFTA () external view returns (uint256);
    function Get_NFTW () external view returns (uint256);
    function Get_NFTWA () external view returns (uint256);

    function Get_NFTW_Col (uint256 ID_Collection_) external view returns (bool);
    function Get_NFTWA_Col (uint256 ID_Collection_) external view returns (bool);
    function Get_NFTA_Col (uint256 ID_Collection_) external view returns (bool);
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
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

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
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
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
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
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