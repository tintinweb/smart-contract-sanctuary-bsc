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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Create2.sol)

pragma solidity ^0.8.0;

/**
 * @dev Helper to make usage of the `CREATE2` EVM opcode easier and safer.
 * `CREATE2` can be used to compute in advance the address where a smart
 * contract will be deployed, which allows for interesting new mechanisms known
 * as 'counterfactual interactions'.
 *
 * See the https://eips.ethereum.org/EIPS/eip-1014#motivation[EIP] for more
 * information.
 */
library Create2 {
    /**
     * @dev Deploys a contract using `CREATE2`. The address where the contract
     * will be deployed can be known in advance via {computeAddress}.
     *
     * The bytecode for a contract can be obtained from Solidity with
     * `type(contractName).creationCode`.
     *
     * Requirements:
     *
     * - `bytecode` must not be empty.
     * - `salt` must have not been used for `bytecode` already.
     * - the factory must have a balance of at least `amount`.
     * - if `amount` is non-zero, `bytecode` must have a `payable` constructor.
     */
    function deploy(
        uint256 amount,
        bytes32 salt,
        bytes memory bytecode
    ) internal returns (address) {
        address addr;
        require(address(this).balance >= amount, "Create2: insufficient balance");
        require(bytecode.length != 0, "Create2: bytecode length is zero");
        assembly {
            addr := create2(amount, add(bytecode, 0x20), mload(bytecode), salt)
        }
        require(addr != address(0), "Create2: Failed on deploy");
        return addr;
    }

    /**
     * @dev Returns the address where a contract will be stored if deployed via {deploy}. Any change in the
     * `bytecodeHash` or `salt` will result in a new destination address.
     */
    function computeAddress(bytes32 salt, bytes32 bytecodeHash) internal view returns (address) {
        return computeAddress(salt, bytecodeHash, address(this));
    }

    /**
     * @dev Returns the address where a contract will be stored if deployed via {deploy} from a contract located at
     * `deployer`. If `deployer` is this contract's address, returns the same value as {computeAddress}.
     */
    function computeAddress(
        bytes32 salt,
        bytes32 bytecodeHash,
        address deployer
    ) internal pure returns (address) {
        bytes32 _data = keccak256(abi.encodePacked(bytes1(0xff), deployer, salt, bytecodeHash));
        return address(uint160(uint256(_data)));
    }
}

pragma solidity ^0.8.0;

interface IFactory {
    function createProject(uint _projectId, address _operator, address _userLevel, address _launchpad) external returns(address);
    function createINO(
        uint _projectId,
        address _operator,
        address _userLevel,
        address _launchpad
    ) external returns(address);
}

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Create2.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../interfaces/IFactory.sol";

contract LaunchpadFactory is Ownable {

    mapping(uint => address) public projects;
    mapping(uint => address) public nftProjects;
    mapping(address => bool) public operators;
    address public projectFactory;
    address public inoFactory;

    modifier onlyOperator() {
        require(operators[msg.sender], "IdoFactory: only operator");
        _;
    }
    event ProjectCreated(uint indexed projectId, address indexed contractAddress);
    event ProjectNFTCreated(uint indexed projectId, address indexed contractAddress);
    event ChangeOperator(address indexed _newOperator, bool indexed _status);

    constructor() {
        operators[msg.sender] = true;
    }

    function setFactory(address _projectFactory, address _inoFactory) external onlyOwner {
        require(address(_projectFactory)  != address(0), "IdoFactory: input zero _projectFactory");
        require(address(_inoFactory)  != address(0), "IdoFactory: input zero _ticketFactory");
        projectFactory = _projectFactory;
        inoFactory = _inoFactory;
    }

    function setOperator(address _newOperator, bool _status) external onlyOwner {
        require(_newOperator != address(0), "IdoFactory: input zero");
        operators[_newOperator] = _status;
        emit ChangeOperator(_newOperator, _status);
    }

    function createProject(uint _projectId, address _operator, address _userLevel) external onlyOperator {
        require(_operator != address(0), "!zero");
        require(projects[_projectId] == address(0), "Duplicate project id");
        address _projectAddress = IFactory(projectFactory).createProject(_projectId, _operator, _userLevel, address(this));
        projects[_projectId] = _projectAddress;
        emit ProjectCreated(_projectId, _projectAddress);
    }

    function createINO(
        uint _projectId,
        address _userLevel,
        address _operator
    ) external onlyOperator {
        require(_operator != address(0), "!zero");
        require(nftProjects[_projectId] == address(0), "Already deployed nftproject with id");
        address inoAddress = IFactory(inoFactory).createINO(_projectId, _operator, _userLevel, address(this));
        nftProjects[_projectId] = inoAddress;
        emit ProjectNFTCreated(_projectId, inoAddress);
    }

    receive() external payable {
        revert("Nothing send to here");
    }
}