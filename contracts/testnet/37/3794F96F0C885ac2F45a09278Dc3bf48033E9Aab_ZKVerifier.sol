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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

interface IZKCircuitVerifier {
    function verifyProof(
        uint256[2] memory a,
        uint256[2][2] memory b,
        uint256[2] memory c,
        uint256[] memory input
    ) external view returns (bool);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

interface IZKSBT {
    //Circuit 生成的Proof
    struct ZkProof {
        uint256[2] a;
        uint256[2][2] b;
        uint256[2] c;
        uint256[] inputs;
    }

    /*
     *   提交ZKProof保存到链上，并为owner mint SBT，如果还没有SBT的话。
     *   proofType：证明的类型，可自定义
     *   commitment：issuer颁发的Credential，加密后的内容
     *   R,S,V：issuer的签名
     *   verifyProof：验证证明
     *   return SBT id
     */
    function commitZkProof(
        string calldata proofType,
        bytes32 commitment,
        bytes32 r,
        bytes32 s,
        uint8 v,
        address owner,
        ZkProof calldata verifyProof
    ) external returns (uint256);

    /*
     * 查询ZKProof
     * proofType：证明的类型，可自定义
     * owner：持有proof的地址
     * return zkProof,zkProof = abi.encode(a,b,c,inputs)
     */
    function getProof(string calldata proofType, address owner)
        external
        view
        returns (bytes memory);

    /*
     * 查询owner的SBT id
     * return SBT id
     */
    function tokenOfOwner(address owner) external view returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IZKCircuitVerifier.sol";
import "./interfaces/IZKSBT.sol";

contract ZKVerifier is Ownable {
    mapping(string => address) public tokens;
    mapping(string => address) public verifiers;

    function setZkVerifier(
        string memory circuitType,
        address token,
        address zkVerifier
    ) external onlyOwner {
        tokens[circuitType] = token;
        verifiers[circuitType] = zkVerifier;
    }

    function verifier(
        string memory circuitType,
        string memory proofType,
        bytes32 msgHash,
        bytes32 r,
        bytes32 s,
        uint8 v
    ) external view returns (bool) {
        address circuitAddress = verifiers[circuitType];
        require(
            tokens[circuitType] != address(0) && circuitAddress != address(0),
            "not set verifier"
        );
        address owner = ecrecover(msgHash, v, r, s);

        bytes memory proof = IZKSBT(tokens[circuitType]).getProof(
            proofType,
            owner
        );
        require(proof.length > 0, "SBT not set proof");
        (
            uint256[2] memory a,
            uint256[2][2] memory b,
            uint256[2] memory c,
            uint256[] memory input
        ) = abi.decode(
                proof,
                (uint256[2], uint256[2][2], uint256[2], uint256[])
            );
        return IZKCircuitVerifier(circuitAddress).verifyProof(a, b, c, input);
    }
}