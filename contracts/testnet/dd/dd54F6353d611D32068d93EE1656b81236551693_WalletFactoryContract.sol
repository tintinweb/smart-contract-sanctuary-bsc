// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (proxy/Clones.sol)

pragma solidity ^0.8.0;

/**
 * @dev https://eips.ethereum.org/EIPS/eip-1167[EIP 1167] is a standard for
 * deploying minimal proxy contracts, also known as "clones".
 *
 * > To simply and cheaply clone contract functionality in an immutable way, this standard specifies
 * > a minimal bytecode implementation that delegates all calls to a known, fixed address.
 *
 * The library includes functions to deploy a proxy using either `create` (traditional deployment) or `create2`
 * (salted deterministic deployment). It also includes functions to predict the addresses of clones deployed using the
 * deterministic method.
 *
 * _Available since v3.4._
 */
library Clones {
    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create opcode, which should never revert.
     */
    function clone(address implementation) internal returns (address instance) {
        /// @solidity memory-safe-assembly
        assembly {
            // Cleans the upper 96 bits of the `implementation` word, then packs the first 3 bytes
            // of the `implementation` address with the bytecode before the address.
            mstore(0x00, or(shr(0xe8, shl(0x60, implementation)), 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000))
            // Packs the remaining 17 bytes of `implementation` with the bytecode after the address.
            mstore(0x20, or(shl(0x78, implementation), 0x5af43d82803e903d91602b57fd5bf3))
            instance := create(0, 0x09, 0x37)
        }
        require(instance != address(0), "ERC1167: create failed");
    }

    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create2 opcode and a `salt` to deterministically deploy
     * the clone. Using the same `implementation` and `salt` multiple time will revert, since
     * the clones cannot be deployed twice at the same address.
     */
    function cloneDeterministic(address implementation, bytes32 salt) internal returns (address instance) {
        /// @solidity memory-safe-assembly
        assembly {
            // Cleans the upper 96 bits of the `implementation` word, then packs the first 3 bytes
            // of the `implementation` address with the bytecode before the address.
            mstore(0x00, or(shr(0xe8, shl(0x60, implementation)), 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000))
            // Packs the remaining 17 bytes of `implementation` with the bytecode after the address.
            mstore(0x20, or(shl(0x78, implementation), 0x5af43d82803e903d91602b57fd5bf3))
            instance := create2(0, 0x09, 0x37, salt)
        }
        require(instance != address(0), "ERC1167: create2 failed");
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(
        address implementation,
        bytes32 salt,
        address deployer
    ) internal pure returns (address predicted) {
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40)
            mstore(add(ptr, 0x38), deployer)
            mstore(add(ptr, 0x24), 0x5af43d82803e903d91602b57fd5bf3ff)
            mstore(add(ptr, 0x14), implementation)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73)
            mstore(add(ptr, 0x58), salt)
            mstore(add(ptr, 0x78), keccak256(add(ptr, 0x0c), 0x37))
            predicted := keccak256(add(ptr, 0x43), 0x55)
        }
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(address implementation, bytes32 salt)
        internal
        view
        returns (address predicted)
    {
        return predictDeterministicAddress(implementation, salt, address(this));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Create2.sol)

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
    ) internal returns (address addr) {
        require(address(this).balance >= amount, "Create2: insufficient balance");
        require(bytecode.length != 0, "Create2: bytecode length is zero");
        /// @solidity memory-safe-assembly
        assembly {
            addr := create2(amount, add(bytecode, 0x20), mload(bytecode), salt)
        }
        require(addr != address(0), "Create2: Failed on deploy");
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
    ) internal pure returns (address addr) {
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40) // Get free memory pointer

            // |                   | ↓ ptr ...  ↓ ptr + 0x0B (start) ...  ↓ ptr + 0x20 ...  ↓ ptr + 0x40 ...   |
            // |-------------------|---------------------------------------------------------------------------|
            // | bytecodeHash      |                                                        CCCCCCCCCCCCC...CC |
            // | salt              |                                      BBBBBBBBBBBBB...BB                   |
            // | deployer          | 000000...0000AAAAAAAAAAAAAAAAAAA...AA                                     |
            // | 0xFF              |            FF                                                             |
            // |-------------------|---------------------------------------------------------------------------|
            // | memory            | 000000...00FFAAAAAAAAAAAAAAAAAAA...AABBBBBBBBBBBBB...BBCCCCCCCCCCCCC...CC |
            // | keccak(start, 85) |            ↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑ |

            mstore(add(ptr, 0x40), bytecodeHash)
            mstore(add(ptr, 0x20), salt)
            mstore(ptr, deployer) // Right-aligned with 12 preceding garbage bytes
            let start := add(ptr, 0x0b) // The hashed data starts at the final garbage byte which we will set to 0xff
            mstore8(start, 0xff)
            addr := keccak256(start, 85)
        }
    }
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.12;

/* solhint-disable avoid-low-level-calls */
/* solhint-disable no-inline-assembly */
/* solhint-disable reason-string */

import {BatchUserOperation, UserOperation} from "./UserOperation.sol";
/**
 * Basic wallet interface.
 * This contract provides the basic interface wallet logic
 */
interface BaseWallet {

    /**
     * used to get the version
     */
    function version() external view returns (uint256);

    /**
     * used to set the owner in initialization
     */
    function initialize(address anOwner) external;

    /**
     * return the account nonce, prevent replay attack.
     */
    function nonce() external view returns (uint256);

    /**
     * return the account owner.
     */
    function owner() external view returns (address);

    /**
     * validate the signature is valid for this message.
     * @param userOp validate the userOp.signature field
    */
    function validateUserOp(UserOperation calldata userOp, bytes calldata signature)
    external view returns (bool isValid);

    /**
     * validate the signature is valid for this message.
     * @param batchUserOp validate the batchUserOp.signature field
    */
    function validateBatchUserOp(BatchUserOperation calldata batchUserOp, bytes calldata signature)
    external view returns (bool isValid);

    function execute(UserOperation calldata userOp, bytes calldata signature) external;

    function executeBatch(BatchUserOperation calldata batchUserOp, bytes calldata signature) external;
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.12;

/* solhint-disable no-inline-assembly */

    /**
     * User Operation struct
     * @param sender the sender account of this request
     * @param nonce unique value the sender uses to verify it is not a replay.
     * @param targetSmartContractAddress target sc's address to call function upon
     * @param targetSmartContractData target sc's data used in the call function 
     * @param targetAndFeeChainId the id of the chain the TX is being executed on.
     * @param feeTokenAddress the token's address used to pay TX's fee in
     * @param txValue if native asset is being transferred 
     * @param maxGasCostToken the highest amount of the fee in assoc. token used in gas payment.
     * @param maxGasCostETH the highest amount of the fee in ETH.
     * @param platformFeeInToken the platform fee acquired for the gasless service.
     * @param lastValidBlock the deadline, the TX can be executed before.
     * @param feeMaster the address which receives the fee 
     * @param signature the signature of the User Operations body
     */

    struct UserOperation {
        address sender;
        uint256 nonce;
        address targetSmartContractAddress;
        bytes targetSmartContractData;
        uint256 targetAndFeeChainId; // TODO: refactor to chainId?
        address feeTokenAddress;
        uint txValue;
        uint maxGasCostToken;
        uint maxGasCostETH;
        uint platformFeeInToken;
        uint lastValidBlock;
        address feeMaster;
    }

    struct BatchUserOperation {
        address sender;
        uint256 nonce;
        address[] targetSmartContractAddresses; 
        bytes[] targetSmartContractDatas;
        uint256 targetAndFeeChainId;
        address feeTokenAddress;
        uint[] txValues;
        uint maxGasCostToken;
        uint maxGasCostETH;
        uint platformFeeInToken;
        uint lastValidBlock;
        address feeMaster;
    }

library UserOperationLib {

    function getSender(UserOperation calldata userOp) internal pure returns (address) {
        address data;
        //read sender from userOp, which is first userOp member (saves 800 gas...)
        assembly {data := calldataload(userOp)}
        return address(uint160(data));
    }

//    function pack(UserOperation calldata userOp) internal pure returns (bytes memory ret) {
//        //lighter signature scheme. must match UserOp.ts#packUserOp
//        bytes calldata sig = userOp.signature;
//        // copy directly the userOp from calldata up to (but not including) the signature.
//        // this encoding depends on the ABI encoding of calldata, but is much lighter to copy
//        // than referencing each field separately.
//        assembly {
//            let ofs := userOp
//            // 32 shouldn't be subtracted, let len := sub(sub(sig.offset, ofs))
//            let len := sub(sub(sig.offset, ofs), 32)
//            ret := mload(0x40)
//            mstore(0x40, add(ret, add(len, 32)))
//            mstore(ret, len)
//            calldatacopy(add(ret, 32), ofs, len)
//        }
//    }
//
//    function hash(UserOperation calldata userOp) internal pure returns (bytes32) {
//        return keccak256(pack(userOp));
//    }

}

library BatchUserOperationLib {
    
    // address is a 20-byte field, uint160bit => 160/(8 bit/byte) = 20 byte.
    function getSender(BatchUserOperation calldata batchUserOp) internal pure returns (address) {
        address data;
        //read sender from userOp, which is first userOp member (saves 800 gas...)
        assembly {data := calldataload(batchUserOp)}
        return address(uint160(data));
    }
    
//    function batchPack(BatchUserOperation calldata batchUserOp) internal pure returns (bytes memory ret) {
//        //lighter signature scheme. must match batchUserOp.ts#packBatchUserOp
//        address[] calldata targetSmartContractAddresses = batchUserOp.targetSmartContractAddresses;
//        bytes[] calldata targetSmartContractDatas = batchUserOp.targetSmartContractDatas;
//        uint[] calldata txValues = batchUserOp.txValues;
//        bytes calldata aggregatedSignature = batchUserOp.aggregatedSignature;
//        // copy directly the batchUserOp from calldata up to (but not including) the signature.
//        // this encoding depends on the ABI encoding of calldata, but is much lighter to copy
//        // than referencing each field separately.
//        assembly {
//
//            /* copy sender and nonce */
//            let first_part_ofs := batchUserOp
//            let len_sender_nonce := add(sub(targetSmartContractAddresses.offset, first_part_ofs),32)
//            ret := mload(0x40)
//            let freePointer := add(ret, len_sender_nonce)
//            //mstore(ret, len_sender_nonce) // the 32 added above for length
//            calldatacopy(ret, first_part_ofs, len_sender_nonce) // copy sender, nonce into storage
//
//            // record targetSmartContractAddresses array in memory: length + content
//            mstore(freePointer, targetSmartContractAddresses.length)
//            freePointer := add(freePointer, 32)
//            calldatacopy(freePointer, add(calldataload(targetSmartContractAddresses.offset), 32), targetSmartContractAddresses.length)
//            freePointer := add(freePointer, targetSmartContractAddresses.length)
//
//            // record targetSmartContractDatas array in memory: length + content
//            mstore(freePointer, targetSmartContractDatas.length)
//            freePointer := add(freePointer, 32)
//            calldatacopy(freePointer, add(calldataload(targetSmartContractDatas.offset), 32), targetSmartContractDatas.length)
//            freePointer := add(freePointer, targetSmartContractDatas.length)
//
//            // copy targetAndFeeChainId and feeTokenAddress.
//            let len_targetAndFeeChainId_feeTokenAddress := sub(sub(txValues.offset, targetSmartContractDatas.offset),32)
//            calldatacopy(freePointer, add(targetSmartContractDatas.offset, 32), len_targetAndFeeChainId_feeTokenAddress)
//            freePointer := add(freePointer, len_targetAndFeeChainId_feeTokenAddress)
//
//            // record txValues array in memory: length + content
//            mstore(freePointer, txValues.length)
//            freePointer := add(freePointer, 32)
//            calldatacopy(freePointer, add(calldataload(txValues.offset), 32), txValues.length)
//            freePointer := add(freePointer, txValues.length)
//
//            // copy maxGasCostToken til(not including) aggregatedSignature.
//            let len_maxGasCostToken_til_aggregatedSignature := sub(sub(aggregatedSignature.offset, txValues.offset),32)
//            calldatacopy(freePointer, add(txValues.offset, 32), len_maxGasCostToken_til_aggregatedSignature)
//            freePointer := add(freePointer, len_maxGasCostToken_til_aggregatedSignature)
//        }
//    }

//    function batchHash(BatchUserOperation calldata batchUserOp) internal pure returns (bytes32){
//        return keccak256(batchPack(batchUserOp));
//    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/utils/Create2.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "./Wallet/BaseWallet.sol";
import "./Wallet/UserOperation.sol";

contract WalletFactoryContract {
    /// Libraries ///
    using UserOperationLib for UserOperation;
    using BatchUserOperationLib for BatchUserOperation;

    /// Storage ///
    // address of the wallet logic contract
    address immutable public walletLogicAddress;
    // used as a salt in conjunction with the EOA to build the salt for create2
    uint256 constant public factorySalt = 1;

    constructor(address _walletLogicAddress){
        require(_walletLogicAddress != address(0));
        walletLogicAddress = _walletLogicAddress;
    }

    /// Errors ///
    error WalletContractDoesExist(address eoa, address associatedWalletContract);

    /// Events ///
    event WalletContractGenerated(address indexed eoa, address indexed walletContract);

    function getOrDeployWalletContract(address eoa) public returns (address){
        address predictedWalletAddress = predictWalletAddress(eoa);
        if (predictedWalletAddress.code.length > 0) {
            return predictedWalletAddress;
        }
        // walletContract doesn't exist, so let's deploy it
        address eoaAssociatedWalletContract = deployWallet(eoa);
        emit WalletContractGenerated(eoa, eoaAssociatedWalletContract);
        return eoaAssociatedWalletContract;
    }

    /// this is just for debugging purposes
    function predictWalletAddressDebug(address deployer, address owner, uint salt) public view returns (address) {
        bytes32 customSalt = keccak256(abi.encodePacked(owner, salt));
        return Clones.predictDeterministicAddress(walletLogicAddress, customSalt, deployer);
    }

    function predictWalletAddress(address owner) public view returns (address) {
        bytes32 customSalt = getCustomSalt(owner);
        return Clones.predictDeterministicAddress(walletLogicAddress, customSalt, address(this));
    }

    function doesWalletExist(address owner) public view returns (bool){
        return predictWalletAddress(owner).code.length > 0;
    }

    function deployWallet(address owner) internal returns (address ret) {
        ret = Clones.cloneDeterministic(walletLogicAddress, getCustomSalt(owner));
        // set the owner right after deployment.
        BaseWallet(ret).initialize(owner);
    }

    function getCustomSalt(address owner) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(owner, factorySalt));
    }

    /**
    * helper function to
    */
    function routeUserOperation(UserOperation calldata userOp, bytes calldata signature) external {
        address assocWalletContract = getOrDeployWalletContract(userOp.getSender());
        BaseWallet(assocWalletContract).execute(userOp, signature);
    }

    function routeBatchUserOperation(BatchUserOperation calldata batchUserOp, bytes calldata signature) external {
        address assocWalletContract = getOrDeployWalletContract(batchUserOp.getSender());
        BaseWallet(assocWalletContract).executeBatch(batchUserOp, signature);
    }

    function routeUserOperationList(UserOperation[] calldata userOpList, bytes[] calldata signatureList) external {
        address tmpEOA;
        address assocWalletContract;
        UserOperation calldata userOp;
        for (uint i = 0; i < userOpList.length;) {
            userOp = userOpList[i];
            tmpEOA = userOp.getSender();
            assocWalletContract = getOrDeployWalletContract(tmpEOA);
            try BaseWallet(assocWalletContract).execute(userOp,signatureList[i]){}catch{}
        unchecked{i++;}
        }
    }

    function routeBatchUserOperationList(BatchUserOperation[] calldata userOpList, bytes[] calldata signatureList) external {
        address tmpEOA;
        address assocWalletContract;
        BatchUserOperation calldata userOp;
        for (uint i = 0; i < userOpList.length;) {
            userOp = userOpList[i];
            tmpEOA = userOp.getSender();
            assocWalletContract = getOrDeployWalletContract(tmpEOA);
            try BaseWallet(assocWalletContract).executeBatch(userOp, signatureList[i]){}catch{}
        unchecked{i++;}
        }
    }
}