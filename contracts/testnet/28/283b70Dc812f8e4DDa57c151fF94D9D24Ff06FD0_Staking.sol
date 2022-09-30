// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/IScheduler.sol";
import "./mixins/cryptography.sol";
import "./interfaces/ISwap.sol";

contract Staking is SignatureControl {
    IERC20 PENX;
    IERC20 PXLT;
    IERC20 USDC;
    ISwap router;
    IScheduler scheduler;
    bool isPaused = true;

    // uint256 secondsInDay = 86400;
    uint256 secondsInDay = 60;

    // mapping(address => mapping(uint256 => bool)) usedNonces;

    // mapping(address => uint256) public stakedSet;
    // mapping(address => uint256) public penxAccrued;
    uint256 public withdrawFee = 500;

    uint256 accumulatedSetFee;

    address[] workerArray;
    mapping(address => WorkerInfo) public workerAddressToInfo;
    struct WorkerInfo {
        uint256 stakedSet;
        uint256 accruedPENX;
        uint256 stakingStart;
    }

    uint256 coefficient = 11000;

    event Withdraw(
        address account,
        uint256 PENX,
        uint256 PXLT,
        uint256 swappedFor,
        bool hasFee
    );

    modifier isNotPaused() {
        require(!isPaused);
        _;
    }

    // modifier isValidNonce(uint256 _nonce) {
    //     require(usedNonces[msg.sender][_nonce] != true, "Used nonce");
    //     _;
    // }

    // modifier isValidWithdraw(
    //     bytes memory signature,
    //     uint256 PENXAmount,
    //     uint256 PXLTAmount,
    //     uint256 nonce,
    //     uint256 timestamp
    // ) {
    //     address signer = getSigner(
    //         signature,
    //         PENXAmount,
    //         PXLTAmount,
    //         nonce,
    //         timestamp
    //     );
    //     require(scheduler.isOperator(signer), "Mint not verified by operator");
    //     require(!usedNonces[msg.sender][nonce], "Used nonce");
    //     require(block.timestamp <= timestamp, "Outdated signed message");
    //     _;
    // }

    constructor(
        IERC20 _PENX,
        IERC20 _PXLT,
        IERC20 _USDC,
        IScheduler _scheduler,
        ISwap _router
    ) {
        PENX = _PENX;
        PXLT = _PXLT;
        USDC = _USDC;
        scheduler = _scheduler;
        router = _router;
    }

    // function addSchedules(address[] memory workers, uint256[] memory amounts)
    //     public
    // {
    //     require(scheduler.isOperator(msg.sender), "Caller is not an operator");
    //     require(workers.length == amounts.length, "Incorrect arrays provided");
    //     uint256 totalAmount;
    //     for (uint256 i = 0; i < workers.length; ) {
    //         stakedSet[workers[i]] += amounts[i];
    //         totalAmount += amounts[i];
    //         unchecked {
    //             i++;
    //         }
    //     }
    //     PXLT.transferFrom(msg.sender, address(this), totalAmount);
    // }

    function addWorker(address worker, uint256 setAmount)
        internal
        returns (bool isNew)
    {
        WorkerInfo storage info = workerAddressToInfo[worker];
        info.stakedSet += setAmount;
        if (info.stakingStart == 0) {
            info.stakingStart = block.timestamp;
            isNew = true;
        }
    }

    function addSchedules(address[] memory workers, uint256[] memory amounts)
        public
    {
        require(scheduler.isOperator(msg.sender), "Caller is not an operator");
        require(workers.length == amounts.length, "Incorrect arrays length");
        uint256 totalAmount;
        for (uint256 i = 0; i < workers.length; ) {
            if (addWorker(workers[i], amounts[i])) {
                workerArray.push(workers[i]);
            }
            unchecked {
                i++;
            }
        }
        PXLT.transferFrom(msg.sender, address(this), totalAmount);
    }

    function increaseStakes() public {
        require(scheduler.isOperator(msg.sender), "Caller is not an operator");
        for (uint256 i = 0; i < workerArray.length; ) {
            WorkerInfo storage info = workerAddressToInfo[workerArray[i]];
            if (
                info.stakedSet > 0 &&
                scheduler.getWorkerRetirementDate(workerArray[i]) >=
                block.timestamp
            ) {
                uint256 totalSupply = PXLT.totalSupply();
                updateWorkerStake(info, totalSupply);
            }
            unchecked {
                i++;
            }
        }
    }

    function updateWorkerStake(WorkerInfo storage info, uint256 totalSupply)
        internal
    {
        uint256 secondsPassed = block.timestamp - info.stakingStart;
        uint256 leftoverSeconds = secondsPassed % secondsInDay;
        uint256 daysPassedSinceDeposit = (secondsPassed - leftoverSeconds) /
            secondsInDay;
        uint256 PENXtoAdd = (((info.stakedSet * sqrt(daysPassedSinceDeposit)) /
            totalSupply /
            1e18) * coefficient) / 10000;
        info.accruedPENX += PENXtoAdd;
    }

    function sqrt(uint256 x) internal pure returns (uint256 y) {
        uint256 z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }

    function withdrawPension() public {
        WorkerInfo storage info = workerAddressToInfo[msg.sender];
        require(info.stakedSet > 0, "Nothing to collect");

        bool hasFee;
        if (scheduler.getWorkerRetirementDate(msg.sender) < block.timestamp) {
            hasFee = true;
        }

        if (hasFee) {
            uint256 setFee = (info.stakedSet / 10000) * withdrawFee;
            uint256 penxFee = (info.accruedPENX / 10000) * withdrawFee;
            info.stakedSet -= setFee;
            accumulatedSetFee += setFee;
            info.accruedPENX -= penxFee;
        }

        address[] memory path = new address[](2);
        path[0] = address(PXLT);
        path[1] = address(USDC);
        uint256[] memory amounts = router.swapExactTokensForTokens(
            info.stakedSet,
            1,
            path,
            msg.sender,
            block.timestamp
        );
        PENX.transfer(address(this), info.accruedPENX);
        emit Withdraw(
            msg.sender,
            info.accruedPENX,
            info.stakedSet,
            amounts[1],
            hasFee
        );
        delete workerAddressToInfo[msg.sender];
    }

    // function withdrawPension(
    //     bytes memory signature,
    //     uint256 PENXAmount,
    //     uint256 PXLTAmount,
    //     uint256 nonce,
    //     uint256 timestamp
    // )
    //     public
    //     isValidWithdraw(signature, PENXAmount, PXLTAmount, nonce, timestamp)
    // {
    //     usedNonces[msg.sender][nonce] = true;
    //     bool hasFee;
    //     if (scheduler.getWorkerRetirementDate(msg.sender) < block.timestamp) {
    //         hasFee = true;
    //     }
    //     if (hasFee) {
    //         uint256 setFee = (PXLTAmount / 10000) * withdrawFee;
    //         uint256 penxFee = (PENXAmount / 10000) * withdrawFee;
    //         stakedSet[msg.sender] -= setFee;
    //         PENXAmount -= penxFee;
    //         accumulatedSetFee += setFee;
    //     }
    //     address[] memory path = new address[](2);
    //     path[0] = address(PXLT);
    //     path[1] = address(USDC);
    //     uint256[] memory amounts = router.swapExactTokensForTokens(
    //         stakedSet[msg.sender],
    //         1,
    //         path,
    //         msg.sender,
    //         block.timestamp
    //     );
    //     PENX.transfer(address(this), PENXAmount);

    //     emit Withdraw(msg.sender, PENXAmount, PXLTAmount, amounts[1], hasFee);
    // }

    function withdrawAccumulatedFee() public {
        require(scheduler.isAdmin(msg.sender), "Restricted method");
        PXLT.transferFrom(address(this), msg.sender, accumulatedSetFee);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IScheduler {

    function isOperator(address account) external view returns (bool);

    function isAdmin(address account) external view returns(bool);

    function getWorkerRetirementDate(address worker) external view returns(uint256);

}

// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract SignatureControl {

    function _toEthSignedMessage(bytes memory message)
        internal
        pure
        returns (bytes32)
    {
        return
            keccak256(
                abi.encodePacked(
                    "\x19Ethereum Signed Message:\n",
                    Strings.toString(message.length),
                    message
                )
            );
    }

    function _toAsciiString(address x) internal pure returns (string memory) {
        bytes memory s = new bytes(42);
        s[0] = "0";
        s[1] = "x";
        for (uint256 i = 0; i < 20; i++) {
            bytes1 b = bytes1(uint8(uint256(uint160(x)) / (2**(8 * (19 - i)))));
            bytes1 hi = bytes1(uint8(b) / 16);
            bytes1 lo = bytes1(uint8(b) - 16 * uint8(hi));
            s[2 * i + 2] = _char(hi);
            s[2 * i + 3] = _char(lo);
        }
        return string(s);
    }

    function _char(bytes1 b) private pure returns (bytes1 c) {
        if (uint8(b) < 10) return bytes1(uint8(b) + 0x30);
        else return bytes1(uint8(b) + 0x57);
    }

    function getSigner(
        bytes memory signature,
        uint256 penXAmount,
        uint256 setTokenAmount,
        uint256 nonce,
        uint256 timestamp
    ) internal view returns (address) {
        bytes memory data = abi.encodePacked(
            _toAsciiString(msg.sender),
            " is authorized to withdraw ",
            Strings.toString(penXAmount),
            " PenX and ",
            Strings.toString(setTokenAmount),
            " set token with nonce",
            Strings.toString(nonce),
            " before ",
            Strings.toString(timestamp)
        );
        bytes32 hash = _toEthSignedMessage(data);
        address signer = ECDSA.recover(hash, signature);
        return signer;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface ISwap {
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function factory() external pure returns (address);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/cryptography/ECDSA.sol)

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
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

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