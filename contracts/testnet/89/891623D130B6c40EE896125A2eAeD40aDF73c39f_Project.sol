//SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Context.sol";

contract Project is Context, Ownable {
    uint256 public latestId;

    struct Project {
        uint256 id;
        bool isSingle;
        bool isRaise;
        address token;
        address curator;
        uint256 saleStart;
        uint256 saleEnd;
        uint256 distributionStart;
    }

    mapping(uint256 => Project) private projects;

    modifier projectExists(uint256 projectId) {
        require(projectId == projects[projectId].id, "project not exists");
        _;
    }

    modifier onlyCurator(uint256 projectId) {
        require(_msgSender() == projects[projectId].curator, "caller is not the curator project");
        _;
    }

    event Create(Project project);
    event SetCurator(uint256 indexed projectId, address newCurator);
    event SetSaleTime(uint256 indexed projectId, uint256 startTime, uint256 endTime);
    event SetSaleType(uint256 indexed projectId, bool isRaise);
    event SetDistributionStart(uint256 indexed projectId, uint256 startTime);

    function createProject(address _token, bool _isSingle, bool _isRaise, uint256 _saleStart, uint256 _saleEnd, uint256 _distributionStart) external onlyOwner {
        require(_token != address(0), "token is the zero address");
        require(_saleStart > block.timestamp, "invalid start sale");
        require(_saleEnd >= _saleStart, "invalid end sale");
        require(_distributionStart >= _saleEnd, "invalid start distribution");

        latestId++;
        Project storage project   = projects[latestId];
        project.id                = latestId;
        project.token             = _token;
        project.isSingle          = _isSingle;
        project.isRaise           = _isRaise;
        project.curator           = owner();
        project.saleStart         = _saleStart;
        project.saleEnd           = _saleEnd;
        project.distributionStart = _distributionStart;

        emit Create(project);
    }

    function getProject(uint256 _id) external view returns (Project memory) {
        return projects[_id];
    }

    function setCurator(uint256 _projectId, address _newCurator) external projectExists(_projectId) onlyCurator(_projectId) {
        require(_newCurator != address(0), "new curator is the zero address");
        projects[_projectId].curator = _newCurator;
        emit SetCurator(_projectId, _newCurator);
    }

    function setSaleTime(uint256 _projectId, uint256 _startTime, uint256 _endTime) external projectExists(_projectId) onlyCurator(_projectId) {
        Project storage project = projects[_projectId];
        require(block.timestamp < project.saleStart, "sale live");
        require(_endTime >= _startTime, "invalid end time");

        project.saleStart = _startTime;
        project.saleEnd   = _endTime;
        emit SetSaleTime(_projectId, _startTime, _endTime);
    }

    function setDistributionStart(uint256 _projectId, uint256 _startTime) external projectExists(_projectId) onlyCurator(_projectId) {
        Project storage project = projects[_projectId];
        require(_startTime >= project.saleEnd, "invalid start time");

        project.distributionStart = _startTime;
        emit SetDistributionStart(_projectId, _startTime);
    }

    function setSaleType(uint256 _projectId, bool _isRaise) external projectExists(_projectId) onlyCurator(_projectId) {
        Project storage project = projects[_projectId];
        require(block.timestamp < project.saleStart, "sale live");
        project.isRaise = _isRaise;
        emit SetSaleType(_projectId, _isRaise);
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