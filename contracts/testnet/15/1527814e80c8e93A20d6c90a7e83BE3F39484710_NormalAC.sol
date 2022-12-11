// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./IFileStorage.sol";

/**
 *  @title  Dev Access Control Contract
 *
 *  @author Stephen Sang
 *
 *  @notice This smart contract is contract to control metadata access of files
 */
contract NormalAC is Ownable, ReentrancyGuard {
    /**
     * @notice storage of metadata.
     */
    IFileStorage public fileStorage;

    event SetFileStorage(address indexed newFileStorage);
    event CreateFile(uint256 indexed _fileID);
    event UpdateFile(uint256 indexed _fileID);
    event DeleteFile(uint256 indexed _fileID);
    event AddAuthorizedUser(uint256 indexed _fileID, address indexed _user);
    event RemoveAuthorizedUser(uint256 indexed _fileID, address indexed _user);

    event SaveOnEvent(bytes _fileType, bytes _fileName, bytes _fileLink, address[] _whiteList, bytes _privateMetadata);
    modifier onlyCreator(uint256 _fileID, address creator) {
        require(fileStorage.readMetadata(_fileID).privateCreator == creator, "Ownable: Invalid creator");
        _;
    }

    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Set new storage contract address
     * @param _newFileStorage storage address
     */
    function setFileStorage(IFileStorage _newFileStorage) external onlyOwner {
        fileStorage = _newFileStorage;

        emit SetFileStorage(address(_newFileStorage));
    }

    function saveOnEvent(
        bytes memory _fileType,
        bytes memory _fileName,
        bytes memory _fileLink,
        address[] memory _whiteList,
        bytes memory _privateMetadata
    ) external nonReentrant {
        emit SaveOnEvent(_fileType, _fileName, _fileLink, _whiteList, _privateMetadata);
    }

    /**
     * @dev Create new File
     * @param _fileType type of file uploaded
     * @param _fileName name of file uploaded
     * @param _fileLink IPFS link
     * @param _whiteList array of authorized address
     * @param _privateMetadata extra private metadata
     */
    function createFile(
        bytes memory _fileType,
        bytes memory _fileName,
        bytes memory _fileLink,
        address[] memory _whiteList,
        bytes memory _privateMetadata
    ) external nonReentrant {
        uint256 fileID = fileStorage.createMetadata(
            _fileType,
            _fileName,
            _fileLink,
            _whiteList,
            _privateMetadata,
            _msgSender()
        );

        emit CreateFile(fileID);
    }

    /**
     * @dev Get File from file ID
     * @param _fileID ID of file uploaded
     */
    function getFile(uint256 _fileID) external view returns (IFileStorage.File memory) {
        require(fileStorage.verify(_fileID, _msgSender()), "Error: UnAuthorized Users");
        return fileStorage.readMetadata(_fileID);
    }

    /**
     * @dev Update File from file ID
     * @param _fileID ID of file uploaded
     * @param _file struct of file
     */
    function updateFile(uint256 _fileID, IFileStorage.File memory _file) external onlyCreator(_fileID, _msgSender()) {
        require(_file.privateCreator == _msgSender(), "Error: Field not allow to change");
        require(_fileID == _file.id, "Error: Can not update file ID");
        fileStorage.updateMetadata(_fileID, _file);

        emit UpdateFile(_fileID);
    }

    /**
     * @dev Delete File from file ID
     * @param _fileID ID of file uploaded
     */
    function deleteFile(uint256 _fileID) external onlyCreator(_fileID, _msgSender()) {
        fileStorage.deleteMetadata(_fileID, _msgSender());

        emit DeleteFile(_fileID);
    }

    /**
     * @dev Add Authorized User
     * @param _fileID file ID
     * @param _user address of user
     */
    function addAuthorizedUser(uint256 _fileID, address _user) external onlyCreator(_fileID, _msgSender()) {
        fileStorage.addAuthorizedUser(_fileID, _user);

        emit AddAuthorizedUser(_fileID, _user);
    }

    /**
     * @dev  Remove Authorized User
     * @param _fileID file ID
     * @param _user address of user
     */
    function removeAuthorizedUser(uint256 _fileID, address _user) external onlyCreator(_fileID, _msgSender()) {
        fileStorage.removeAuthorizedUser(_fileID, _user);

        emit RemoveAuthorizedUser(_fileID, _user);
    }

    /**
     * @dev  Get all Files of caller
     */
    function getMyFiles() external view returns (IFileStorage.File[] memory) {
        return fileStorage.getMyFiles(_msgSender());
    }

    /**
     * @dev  Get all Files of caller
     */
    function getAuthorizedUsersOf(
        uint256 _fileID
    ) external view onlyCreator(_fileID, _msgSender()) returns (address[] memory) {
        return fileStorage.getAuthorizedUsersOf(_fileID);
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
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

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

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

interface IFileStorage {
    struct File {
        uint256 id;
        bytes fileType;
        bytes fileName;
        bytes fileLink;
        bytes privateMetadata;
        address privateCreator;
    }

    function createMetadata(
        bytes memory _fileType,
        bytes memory _fileName,
        bytes memory _fileLink,
        address[] memory _whiteList,
        bytes memory _privateMetadata,
        address _privateCreator
    ) external returns (uint256);

    function readMetadata(uint256 _fileID) external view returns (File memory);

    function updateMetadata(uint256 _fileID, File memory _newFile) external;

    function deleteMetadata(uint256 _fileID, address _user) external;

    function addAuthorizedUser(uint256 _fileID, address _user) external;

    function removeAuthorizedUser(uint256 _fileID, address _user) external;

    function verify(uint256 _fileID, address _caller) external view returns (bool);

    function getMyFiles(address _caller) external view returns (File[] memory);

    function getAuthorizedUsersOf(uint256 _fileID) external view returns (address[] memory);

    function getCurrentId() external view returns (uint256);
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