/**
 *Submitted for verification at BscScan.com on 2022-04-12
*/

// SPDX-License-Identifier: MIT

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
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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

    function isExcluded(address account) external view returns (bool);

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

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

    function toHexString(uint256 value, uint256 length)
        internal
        pure
        returns (string memory)
    {
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

    function tryRecover(bytes32 hash, bytes memory signature)
        internal
        pure
        returns (address, RecoverError)
    {
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

    function recover(bytes32 hash, bytes memory signature)
        internal
        pure
        returns (address)
    {
        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {
        bytes32 s = vs &
            bytes32(
                0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
            );
        uint8 v = uint8((uint256(vs) >> 255) + 27);
        return tryRecover(hash, v, r, s);
    }

    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {
        if (
            uint256(s) >
            0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0
        ) {
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

    function toEthSignedMessageHash(bytes32 hash)
        internal
        pure
        returns (bytes32)
    {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return
            keccak256(
                abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)
            );
    }

    function toEthSignedMessageHash(bytes memory s)
        internal
        pure
        returns (bytes32)
    {
        return
            keccak256(
                abi.encodePacked(
                    "\x19Ethereum Signed Message:\n",
                    Strings.toString(s.length),
                    s
                )
            );
    }

    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash)
        internal
        pure
        returns (bytes32)
    {
        return
            keccak256(
                abi.encodePacked("\x19\x01", domainSeparator, structHash)
            );
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor() {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

library SafeERC20 {
    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        require(token.transfer(to, value), "SafeERC20 Transfer Failed");
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        require(
            token.transferFrom(from, to, value),
            "SafeERC20 TransferFrom failed"
        );
    }
}

//Need to handle adding and removing of signers using enumeration - Done
// Need to handle pausing using OpenZepplin maybe. - Done

contract Bridge is Pausable {
    using SafeERC20 for IERC20;

    address public admin;
    address public owner;
    uint256 public userId;
    address[] public signers;
    uint256 public totalLocked;
    IERC20 public ERC20Interface;
    uint256 public minSignsRequired;

    mapping(address => bool) public signerKey;
    mapping(address => uint256) public position;
    mapping(address => uint256) public userNonce;
    mapping(address => uint256) public userClaimable;

    event Lock(
        address indexed user,
        uint256 amount,
        uint256 timestamp,
        bytes32 indexed Id
    );
    event Unlock(
        address indexed user,
        uint256 amount,
        uint256 timestamp,
        bytes32 indexed Id
    );
    event OwnerChanged(
        address previousOwner,
        address newOwner,
        uint256 timestamp
    );

    constructor(
        address _token,
        address _owner,
        address[] memory _signers,
        uint256 _minSignRequired,
        address _admin
    ) {
        require(_token != address(0), "Zero token address");
        require(_admin != address(0), "Zero admin address");
        require(_owner != address(0), "Zero owner address");
        ERC20Interface = IERC20(_token);
        owner = _owner;
        admin = _admin;
        for (uint256 i; i < _signers.length; i++) {
            // require(_signers[i] != address(0), "Zero signer address");
            // signers.push(_signers[i]);
            // position[_signers[i]] = signers.length;
            // signerKey[_signers[i]] = true;
            addSigner(_signers[i]);
        }
        require(
            _minSignRequired <= _signers.length,
            "Invalid min signs required"
        );
        minSignsRequired = _minSignRequired;
    }

    function changeOwner(address newOwner) external {
        require(msg.sender == admin, "Not the admin");
        address prevOwner = owner;
        owner = newOwner;
        emit OwnerChanged(prevOwner, owner, block.timestamp);
    }

    function changeSignerStatus(address _signer, bool status) external {
        require(msg.sender == admin, "Not the admin");
        require(position[_signer] > 0, "Signer not found");
        signerKey[_signer] = status;
    }

    function pause() external {
        require(msg.sender == admin, "Not the admin");
        _pause();
    }

    function unPause() external {
        require(msg.sender == admin, "Not the admin");
        _unpause();
    }

    function addSigner(address _signer) public {
        require(msg.sender == admin, "Not the admin");
        require(_signer != address(0), "Zero signer address");
        signers.push(_signer);
        position[_signer] = signers.length;
        signerKey[_signer] = true;
    }

    function changeMinSignsRequired(uint256 _minSignRequired) external {
        require(msg.sender == admin, "Not the admin");
        require(
            _minSignRequired <= signers.length,
            "Invalid min signs required"
        );
        minSignsRequired = _minSignRequired;
    }

    function lock(uint256 amount) external whenNotPaused returns (bool) {
        totalLocked += amount;
        userNonce[msg.sender]++;
        ERC20Interface.safeTransferFrom(msg.sender, address(this), amount);
        emit Lock(
            msg.sender,
            amount,
            block.timestamp,
            keccak256(
                abi.encodePacked(
                    msg.sender,
                    amount,
                    block.timestamp,
                    userNonce[msg.sender]
                )
            )
        );
        return true;
    }

    function unlock(
        address user,
        uint256 amount,
        bytes32 _id,
        bytes[] memory signatures
    ) external whenNotPaused returns (bool) {
        require(msg.sender == owner, "Not the owner");
        require(
            amount <= ERC20Interface.balanceOf(address(this)),
            "Not enough tokens on the bridge"
        );
        require(
            signaturesValid(signatures, _id),
            "Signature Verification Failed"
        );
        userClaimable[user] += amount;
        totalLocked -= amount;
        // ERC20Interface.safeTransfer(user, amount);
        emit Unlock(user, amount, block.timestamp, _id);
        return true;
    }

    function claimTokens() external returns (bool) {
        uint256 amount = userClaimable[msg.sender];
        require(amount > 0, "No tokens available for claiming");
        require(
            amount <= ERC20Interface.balanceOf(address(this)),
            "Not enough tokens in the contract"
        );
        delete userClaimable[msg.sender];
        ERC20Interface.safeTransfer(msg.sender, amount);
        return true;
    }

    function signaturesValid(bytes[] memory signatures, bytes32 _id)
        public
        view
        returns (bool)
    {
        require(signatures.length > 0, "Zero signatures length");
        uint256 minSignsChecked;
        for (uint256 i; i < signatures.length; i++) {
            if (minSignsChecked == minSignsRequired) {
                break;
            } else {
                (address signer, ) = ECDSA.tryRecover(
                    (ECDSA.toEthSignedMessageHash(_id)),
                    signatures[i]
                );
                if (signerKey[signer]) minSignsChecked++;
            }
        }
        return (minSignsChecked == minSignsRequired) ? true : false;
    }
}