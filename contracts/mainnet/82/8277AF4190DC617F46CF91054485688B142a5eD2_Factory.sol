/**
 *Submitted for verification at BscScan.com on 2022-12-10
*/

// Sources flattened with hardhat v2.12.2 https://hardhat.org

// File contracts/interfaces/FactoryType.sol

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface FactoryType {
    // INTERNAL TYPE TO DESCRIBE EACH BATCH INFO
    struct BatchInfo {
        uint256 batchId;
        uint256 count;
        uint256 unlockTime;
        bool claimed;
    }
}

// File @openzeppelin/contracts/utils/[email protected]

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

// File @openzeppelin/contracts/access/[email protected]

// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
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

// File contracts/protocols/Factory.sol

pragma solidity 0.8.17;

contract Factory is Ownable, FactoryType {
    string public constant PROXY_FUNCTION = "callXEN(bytes)";
    string public constant XEN_MINT_FUNCTION = "claimRank(uint256)";
    string public constant XEN_CLAIM_FUNCTION =
        "claimMintRewardAndShare(address,uint256)";

    /// The percentage of the XEN token returned to user
    uint256 public constant SHARE_PCT = 100;
    uint256 public constant SECONDS_IN_DAY = 3600 * 24;

    address public xen;
    address public automation;
    address public minterTemplate;

    /// Proxy contract bytecode hash which is used to compute proxy address
    bytes32 public bytecodeHash;

    /// user address => batch count
    mapping(address => uint256) public userBtachId;

    /// user address => batch index => batch info
    mapping(address => mapping(uint256 => BatchInfo)) private batchInfo;

    /**
     * @dev Initialize the Factory contract
     */
    function initialize(
        address _xen,
        address _minterTemplate,
        address _automation
    ) external {
        xen = _xen;
        minterTemplate = _minterTemplate;
        automation = _automation;
        bytecodeHash = keccak256(
            abi.encodePacked(
                bytes.concat(
                    bytes20(0x3D602d80600A3D3981F3363d3d373d3D3D363d73),
                    bytes20(_minterTemplate),
                    bytes15(0x5af43d82803e903d91602b57fd5bf3)
                )
            )
        );
    }

    /**
     * @dev Set address of automation contract
     */
    function setAutomation(address newAutomation) external onlyOwner {
        automation = newAutomation;
        emit SetAutomation(newAutomation);
    }

    /**
     * @dev Create multiple contracts to batch mint XEN token
     */
    function mintBatch(
        address receiver,
        uint256 term,
        uint256 count
    ) external returns (uint256 batchId) {
        require(
            msg.sender == tx.origin || msg.sender == automation,
            "firbidden"
        );

        batchId = ++userBtachId[receiver];
        batchInfo[receiver][batchId] = BatchInfo(
            batchId,
            count,
            block.timestamp + term * SECONDS_IN_DAY,
            false
        );

        bytes memory bytecode = bytes.concat(
            bytes20(0x3D602d80600A3D3981F3363d3d373d3D3D363d73),
            bytes20(minterTemplate),
            bytes15(0x5af43d82803e903d91602b57fd5bf3)
        );
        bytes memory data = abi.encodeWithSignature(
            PROXY_FUNCTION,
            abi.encodeWithSignature(XEN_MINT_FUNCTION, term)
        );

        uint256 i;
        while (i < count) {
            unchecked {
                ++i;
            }

            bytes32 salt = keccak256(abi.encodePacked(receiver, batchId, i));

            assembly {
                let minter := create2(
                    0,
                    add(bytecode, 32),
                    mload(bytecode),
                    salt
                )
                let success := call(
                    gas(),
                    minter,
                    0,
                    add(data, 0x20),
                    mload(data),
                    0,
                    0
                )
            }
        }

        emit BatchMint(receiver, term, count, batchId);
    }

    /**
     * @dev Call multiple contracts created for receiver to batch claim XEN
     */
    function claimBatch(address receiver, uint256 batchId) external {
        require(
            msg.sender == tx.origin || msg.sender == automation,
            "firbidden"
        );

        require(batchId <= userBtachId[receiver], "invalid batch id");

        BatchInfo memory info = batchInfo[receiver][batchId];
        require(block.timestamp >= info.unlockTime, "time is not reach");
        require(!info.claimed, "claimed");

        info.claimed = true;
        batchInfo[receiver][batchId] = info;

        bytes memory proxy_data = abi.encodeWithSignature(
            PROXY_FUNCTION,
            abi.encodeWithSignature(XEN_CLAIM_FUNCTION, receiver, SHARE_PCT)
        );

        uint256 i;
        while (i < info.count) {
            unchecked {
                ++i;
            }
            bytes32 salt = keccak256(abi.encodePacked(receiver, batchId, i));
            address minter = address(
                uint160(
                    uint(
                        keccak256(
                            abi.encodePacked(
                                hex"ff",
                                address(this),
                                salt,
                                bytecodeHash
                            )
                        )
                    )
                )
            );
            assembly {
                let success := call(
                    gas(),
                    minter,
                    0,
                    add(proxy_data, 0x20),
                    mload(proxy_data),
                    0,
                    0
                )
            }
        }

        emit BatchClaim(receiver, batchId);
    }

    /**
     * @notice get user batch info with specific batch id
     */
    function getBatchInfo(address receiver, uint256 batchId)
        external
        view
        returns (BatchInfo memory)
    {
        return batchInfo[receiver][batchId];
    }

    // ==================== Events ====================
    event SetAutomation(address automation);
    event BatchMint(
        address indexed receiver,
        uint256 term,
        uint256 count,
        uint256 batchId
    );
    event BatchClaim(address indexed receiver, uint256 batchId);
}