pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract DogeBean {
    using ECDSA for bytes32;
    // 12.5 days for miners to double
    // after this period, rewards do NOT accumulate anymore though!
    uint256 private constant BONES_REQ_PER_MINER = 1_080_000;
    uint256 private constant INITIAL_MARKET_BONES = 108_000_000_000;
    uint256 public constant START_TIME = 1650046800;

    uint256 private constant PSN = 10000;
    uint256 private constant PSNH = 5000;

    uint256 private constant getDevFeeVal = 325;
    uint256 private constant getMarketingFeeVal = 175;

    uint256 private marketBones = INITIAL_MARKET_BONES;

    uint256 public uniqueUsers;

    address public immutable owner;
    address payable private devFeeReceiver;
    address payable private immutable marketingFeeReceiver;
    address public signerAddress;

    mapping(address => uint256) private academyMiners;
    mapping(address => uint256) private claimedBones;
    mapping(address => uint256) private lastBuildSkeletons;
    mapping(address => bool) private hasParticipated;

    mapping(address => address) private referrals;

    error OnlyOwner(address);
    error NonZeroMarketBones(uint256);
    error FeeTooLow();
    error NotStarted(uint256);

    modifier hasStarted() {
        if (block.timestamp < START_TIME) revert NotStarted(block.timestamp);
        _;
    }
    modifier onlyOwner() {
        if (msg.sender != owner) revert OnlyOwner(msg.sender);
        _;
    }

    ///@dev buildskeletons some intitial native coin deposit here
    constructor(
        address _devFeeReceiver,
        address _marketingFeeReceiver,
        address _signerAddress
    ) payable {
        owner = msg.sender;
        devFeeReceiver = payable(_devFeeReceiver);
        marketingFeeReceiver = payable(_marketingFeeReceiver);
        signerAddress = _signerAddress;
    }

    function changeDevFeeReceiver(address newReceiver) external onlyOwner {
        devFeeReceiver = payable(newReceiver);
    }

    ///@dev should market bones be 0 we can resest to initial state and also (re-)fund the contract again if needed
    function init() external payable onlyOwner {
        if (marketBones > 0) revert NonZeroMarketBones(marketBones);
    }

    function fund() external payable {}

    // buy token from the contract
    function collectBones(
        address ref,
        bytes32 r,
        bytes32 s,
        uint8 v
    ) public payable hasStarted {
        require(
            keccak256(abi.encodePacked(msg.sender, msg.value)).toEthSignedMessageHash().recover(v, r, s) ==
                signerAddress,
            "collectBones:Invalid signarure"
        );

        uint256 bonesBought = calculateBonesBuy(msg.value, address(this).balance - msg.value);

        uint256 devFee = getDevFee(bonesBought);
        uint256 marketingFee = getMarketingFee(bonesBought);

        if (marketingFee == 0) revert FeeTooLow();

        bonesBought = bonesBought - devFee - marketingFee;

        devFeeReceiver.transfer(getDevFee(msg.value));
        marketingFeeReceiver.transfer(getMarketingFee(msg.value));

        claimedBones[msg.sender] += bonesBought;

        if (!hasParticipated[msg.sender]) {
            hasParticipated[msg.sender] = true;
            uniqueUsers++;
        }

        buildSkeletons(ref);
    }

    ///@dev handles referrals
    function buildSkeletons(address ref) public hasStarted {
        if (ref == msg.sender) ref = address(0);

        if (referrals[msg.sender] == address(0) && referrals[msg.sender] != msg.sender) {
            referrals[msg.sender] = ref;
            if (!hasParticipated[ref]) {
                hasParticipated[ref] = true;
                uniqueUsers++;
            }
        }

        uint256 bonesUsed = getMyBones(msg.sender);
        uint256 myBonesRewards = getBonesSinceLastBuildSkeletons(msg.sender);
        claimedBones[msg.sender] += myBonesRewards;

        uint256 newMiners = claimedBones[msg.sender] / BONES_REQ_PER_MINER;
        claimedBones[msg.sender] -= (BONES_REQ_PER_MINER * newMiners);
        academyMiners[msg.sender] += newMiners;
        lastBuildSkeletons[msg.sender] = block.timestamp;

        // send referral bones
        claimedBones[referrals[msg.sender]] += (bonesUsed / 8);

        // boost market to nerf miners hoarding
        marketBones += (bonesUsed / 5);
    }

    // sells token to the contract
    function eat() external hasStarted {
        uint256 ownedBones = getMyBones(msg.sender);
        uint256 boneValue = calculateBonesSell(ownedBones);

        uint256 devFee = getDevFee(boneValue);
        uint256 marketingFee = getMarketingFee(boneValue);

        if (academyMiners[msg.sender] == 0) uniqueUsers--;
        claimedBones[msg.sender] = 0;
        lastBuildSkeletons[msg.sender] = block.timestamp;
        marketBones += ownedBones;

        devFeeReceiver.transfer(devFee);
        marketingFeeReceiver.transfer(marketingFee);

        payable(msg.sender).transfer(boneValue - devFee - marketingFee);
    }

    // ################################## view functions ########################################

    function boneRewards(address adr) external view returns (uint256) {
        return calculateBonesSell(getMyBones(adr));
    }

    function calculateBonesSell(uint256 bones) public view returns (uint256) {
        return calculateTrade(bones, marketBones, address(this).balance);
    }

    function calculateBonesBuy(uint256 eth, uint256 contractBalance) public view returns (uint256) {
        return calculateTrade(eth, contractBalance, marketBones);
    }

    function getBalance()
        external
        view
        returns (
            uint256 beansBalance,
            uint256 userBalance,
            uint256 myMiners
        )
    {
        beansBalance = address(this).balance;
        userBalance = msg.sender.balance;
        myMiners = academyMiners[msg.sender];
    }

    function getMyBones(address adr) public view returns (uint256) {
        return claimedBones[adr] + getBonesSinceLastBuildSkeletons(adr);
    }

    function getBonesSinceLastBuildSkeletons(address adr) public view returns (uint256) {
        // 1 bone per second per miner
        return min(BONES_REQ_PER_MINER, block.timestamp - lastBuildSkeletons[adr]) * academyMiners[adr];
    }

    // private ones

    function calculateTrade(
        //            sell                   buy
        uint256 rt, //bones                // eth
        uint256 rs, //marketBones           // address(this).balance -msg.value
        uint256 bs // address(this).balance  //marketBones
    ) private pure returns (uint256) {
        return (PSN * bs) / (PSNH + (((rs * PSN) + (rt * PSNH)) / rt));
    }

    function getDevFee(uint256 amount) private pure returns (uint256) {
        return (amount * getDevFeeVal) / 10000;
    }

    function getMarketingFee(uint256 amount) private pure returns (uint256) {
        return (amount * getMarketingFeeVal) / 10000;
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (utils/cryptography/ECDSA.sol)

pragma solidity ^0.8.0;

import "../Strings.sol";

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV
    }

    function _throwError(RecoverError error) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        } else if (error == RecoverError.InvalidSignatureV) {
            revert("ECDSA: invalid signature 'v' value");
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature` or error string. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {
        // Check the signature length
        // - case 65: r,s,v signature (standard)
        // - case 64: r,vs signature (cf https://eips.ethereum.org/EIPS/eip-2098) _Available since v4.1._
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return tryRecover(hash, r, vs);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {
        bytes32 s;
        uint8 v;
        assembly {
            s := and(vs, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
            v := add(shr(255, vs), 27)
        }
        return tryRecover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     *
     * _Available since v4.2._
     */
    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
     * `r` and `s` signature fields separately.
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }
        if (v != 27 && v != 28) {
            return (address(0), RecoverError.InvalidSignatureV);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from `s`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", Strings.toString(s.length), s));
    }

    /**
     * @dev Returns an Ethereum Signed Typed Data, created from a
     * `domainSeparator` and a `structHash`. This produces hash corresponding
     * to the one signed with the
     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`]
     * JSON-RPC method as part of EIP-712.
     *
     * See {recover}.
     */
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}