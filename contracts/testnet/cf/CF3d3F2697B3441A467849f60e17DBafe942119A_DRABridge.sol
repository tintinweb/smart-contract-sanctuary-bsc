// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "./IERC20.sol";
import "./SafeERC20.sol";
import "./Ownable.sol";
import "./Address.sol";
import "./Context.sol";
import "./SafeMath.sol";


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
contract ReentrancyGuard {
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

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
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

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
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
        // Check the signature length
        if (signature.length != 65) {
            revert("ECDSA: invalid signature length");
        }

        // Divide the signature in r, s and v variables
        bytes32 r;
        bytes32 s;
        uint8 v;

        // ecrecover takes the signature parameters, and the only way to get them
        // currently is to use assembly.
        // solhint-disable-next-line no-inline-assembly
        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (281): 0 < s < secp256k1n ÷ 2 + 1, and for v in (282): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            revert("ECDSA: invalid signature 's' value");
        }

        if (v != 27 && v != 28) {
            revert("ECDSA: invalid signature 'v' value");
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        require(signer != address(0), "ECDSA: invalid signature");

        return signer;
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * replicates the behavior of the
     * https://github.com/ethereum/wiki/wiki/JSON-RPC#eth_sign[`eth_sign`]
     * JSON-RPC method.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}


contract DRABridge is Context, Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct Order {
        uint256 orderId;
        address account;
        address tokenAddress;
        uint256 amounts;
        uint256 salt;
    }

    address private _tokenAddress;
    IERC20 public DRA;
    address private _validator;
    bool public isPaused;
    // account => amounts
    mapping(address => uint256) private _depositAmounts;
    // account => amounts
    mapping(address => uint256) private _withdrawAmounts;
    // orderId => valid or not
    mapping(uint256 => bool) private _isOrderIdUsed;

    event DepositDRA(address indexed account, uint256 amounts, uint256 timestamp);
    event WithDrawDRA(address indexed account, uint256 orderId, uint256 amounts, uint256 timestamp);


    constructor (address draAddress, address validator) public {
        _tokenAddress = draAddress;
        DRA = IERC20(_tokenAddress);
        _validator = validator;
        isPaused = true;   // initialize as false state
    }

    function changePauseState(bool newState) external onlyOwner {
        isPaused = newState;
    }

    function changeValidator(address newValidator) external onlyOwner {
        _validator = newValidator;
    }

    function withdrawERC20Token(address token, address to, uint256 amounts) external onlyOwner {
        require(amounts <= IERC20(token).balanceOf(address(this)), "amounts can not greater than balance");
        IERC20(token).safeTransfer(to, amounts);
    }

    function isOrderIdValid(uint256 orderId) public view returns (bool) {
        return _isOrderIdUsed[orderId] ? false : true;
    }

    function checkDepositAmounts(address account) external view returns (uint256) {
        return _depositAmounts[account];
    }

    function checkWithdrawAmounts(address account) external view returns (uint256) {
        return _withdrawAmounts[account];
    }

    // DRA approve first
    function depositDRA(uint256 amounts) public nonReentrant {
        require(amounts > 0, "can not deposit 0 amounts");

        _depositAmounts[_msgSender()] = _depositAmounts[_msgSender()].add(amounts);
        DRA.safeTransferFrom(_msgSender(), address(this), amounts);

        emit DepositDRA(_msgSender(), amounts, block.timestamp);
    }

    function withdrawDRA(Order memory order, bytes memory signature) public nonReentrant {
        require(!isPaused, "withdraw function is paused now, try later");
        require(isOrderIdValid(order.orderId), "this orderId is not valid");
        require(order.amounts > 0, "can not withdraw 0 amounts");
        require(order.tokenAddress == _tokenAddress, "not DRA address");
        require(order.account == _msgSender(), "account is not matched");
        bytes32 orderHash = keccak256(abi.encodePacked(order.orderId, order.account, order.tokenAddress, order.amounts, order.salt));
        require(isSignatureValid(signature, orderHash, _validator), "signature error");

        _withdrawAmounts[_msgSender()] = _withdrawAmounts[_msgSender()].add(order.amounts);
        _isOrderIdUsed[order.orderId] = true;

        DRA.safeTransfer(_msgSender(), order.amounts);

        emit WithDrawDRA(_msgSender(), order.orderId, order.amounts, block.timestamp);
    }

    function isSignatureValid(bytes memory signature, bytes32 hashCode, address signer) public pure returns (bool) {
        address recoveredSigner = ECDSA.recover(hashCode, signature);
        return signer == recoveredSigner;
    }

}