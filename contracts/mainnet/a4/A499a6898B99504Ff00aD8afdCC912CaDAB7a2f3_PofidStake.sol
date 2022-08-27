pragma solidity 0.8.4;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract PofidStake {

    event StakeEvent(address, uint, uint, uint);
    event WithDrawEvent(uint, address, uint);
    event ShareReward(address, uint, uint);

    struct User {
        address parent;
        uint stakeAmount;
        uint profitAmount;
        uint withDrawId;

        uint selfCount;
        uint buildCount;
        address leftAddress;
        address rightAddress;
        address buildAddress;

        uint totalAmount;
    }

    struct UserInfo {
        User user;

        uint totalBuildCount;
        uint totalAmount1;
        uint totalAmount2;
    }

    mapping(address => User) public users;

    address public singer;
    address public stakeToken;
    address public marketAddress;
    address public manager;

    uint public stakeAmount = 5e19;

    constructor(address _token, address _singer, address _market, address _manager) {
        stakeToken = _token;
        singer = _singer;
        marketAddress = _market;
        manager = _manager;
    }

    function setSinger(address _singer) public {
        require(marketAddress == msg.sender, "No permission");
        singer = _singer;
    }

    function changeMarket(address _maketAddress) public {
        require(marketAddress == msg.sender, "No permission");
        marketAddress = _maketAddress;
    }

    function setStakeAmount(uint _stakeAmount) public {
        require(marketAddress == msg.sender, "No permission");
        stakeAmount = _stakeAmount;
    }

    function userInfo(address _user) public view returns(UserInfo memory info) {
        User storage user = users[_user];
        info.user = user;
        if(user.buildCount > 0) {
            info.totalBuildCount = user.buildCount ;
            info.totalAmount1 = user.totalAmount;
            info.totalAmount2 = users[user.buildAddress].totalAmount
                             + users[user.buildAddress].stakeAmount;
        }

        if(user.buildAddress != address(0)) {
            info.totalBuildCount += users[user.buildAddress].buildCount + 1;
        }
    }

    function childs(address _user) public view returns(address[2] memory list1, address[4]memory list2, address[8] memory list3) {
        list1 = [users[_user].leftAddress, users[_user].rightAddress];
        for(uint i = 0; i < list1.length; i++) {
            list2[i*2] = users[list1[i]].leftAddress;
            list2[i*2+1] = users[list1[i]].rightAddress;
        }

        for(uint i = 0; i < list2.length; i++) {
            list3[i*2] = users[list2[i]].leftAddress;
            list3[i*2+1] = users[list2[i]].rightAddress;
        }
    }

    function withDraw(uint id, uint amount, bytes calldata sign) public {
        User storage self = users[msg.sender];
        require(self.withDrawId < id, "WithDraw: id error");
        require(verifySinger(id, msg.sender, amount, sign), "WithDraw: singer error");
        require(users[msg.sender].stakeAmount * 2 >= self.profitAmount + amount, "WithDraw: overflow");

        self.profitAmount += amount;
        self.withDrawId = id;

        safeTransfer(stakeToken, msg.sender, amount, false);
        emit WithDrawEvent(id, msg.sender, amount);
    }

    function stake(address _inviterAddr) public {
        require(users[msg.sender].parent == address(0), "has staked");
        safeTransferFrom(stakeToken, msg.sender, address(this), stakeAmount);
        
        User storage self = users[msg.sender];
        self.stakeAmount = stakeAmount;
        
        uint value;
        if(msg.sender == manager) {
            self.parent = address(1);
            value = stakeAmount;
        } else {
            require(users[_inviterAddr].parent != address(0), "inviter error");
            User storage inviter = users[_inviterAddr];

            users[_inviterAddr].selfCount += 1;
           
            (bool insert) = buildChilds(_inviterAddr, msg.sender);
            if(insert) {
                uint count = buildUp(msg.sender, 0, stakeAmount);
                value = (stakeAmount - stakeAmount * count / 5);
            } else {
                uint heigth;
                if(inviter.buildAddress == address(0)) {
                    self.parent = _inviterAddr;
                    inviter.buildAddress = msg.sender;
                } else {
                    heigth = buildDown(inviter.buildAddress, msg.sender, stakeAmount);
                }
                
                safeTransfer(stakeToken, _inviterAddr, stakeAmount / 5, true);
                if(heigth > 3) {
                    heigth = 3;
                }
                value = (stakeAmount - stakeAmount * (heigth + 1) / 5);
            }
        } 

        safeTransfer(stakeToken, marketAddress, value / 5, false);
        emit StakeEvent(msg.sender, value - value / 5, stakeAmount, block.timestamp);
    }

    function buildChilds(address _parent, address _user) internal returns(bool) {
        uint index;
        uint lastIndex;
        address[] memory queue = new address[](7);
        queue[index] = _parent;
        while(index < 7) {
            User storage parent = users[queue[index]];
            if(parent.leftAddress == address(0)) {
                users[_user].parent = queue[index];
                parent.leftAddress = _user;
                return true;
            } else if(parent.rightAddress == address(0)) {
                users[_user].parent = queue[index];
                parent.rightAddress = _user;
                return true;
            } else if(lastIndex < 6){
                queue[++lastIndex] = parent.leftAddress;
                queue[++lastIndex] = parent.rightAddress;
            }
            index += 1;
        }
        return false;
    }

    function buildUp(address _user, uint height, uint value) internal returns(uint count) {
        if(_user == address(1) || _user == address(0)) {
            return 0;
        }

        User storage user = users[_user];
        if(user.parent != address(1) && user.parent != address(0)) {
            User storage parent = users[user.parent];
            if(_user != parent.buildAddress) {
                parent.buildCount += 1;
                parent.totalAmount += value;
                count = buildUp(user.parent, height + 1, value);
                if(height < 3) {
                    safeTransfer(stakeToken, user.parent, stakeAmount / 5, true);
                    count += 1;
                }
            } else {
                safeTransfer(stakeToken, user.parent, stakeAmount / 5, true);
                count = 1;
            }
        }
    }

    function buildDown(address _parent, address user, uint value) internal returns(uint) {
        User storage parent = users[_parent];
        parent.buildCount += 1;
        parent.totalAmount += value;

        if(parent.leftAddress == address(0)) {
            users[user].parent = _parent;
            parent.leftAddress = user;
            safeTransfer(stakeToken, _parent, stakeAmount / 5, true);
            return 1;
        } else if (parent.rightAddress == address(0)) {
            users[user].parent = _parent;
            parent.rightAddress = user;
            safeTransfer(stakeToken, _parent, stakeAmount / 5, true);
            return 1;
        } else {

            uint heigth;
            if(users[parent.leftAddress].buildCount <= users[parent.rightAddress].buildCount) {
                heigth = buildDown(parent.leftAddress, user, value);
            } else {
                heigth = buildDown(parent.rightAddress, user, value);
            }

            if(heigth <= 3) {
                safeTransfer(stakeToken, _parent, stakeAmount / 5, true);
            }
            return heigth + 1;
        }
    }

    function verifySinger(uint id, address account, uint amount, bytes memory sign) private view returns(bool) {
        bytes32 hash = keccak256(abi.encodePacked(id, account, amount));
        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        bytes32 prefixedHashMessage = keccak256(abi.encodePacked(prefix, hash));
        return singer == ECDSA.recover(prefixedHashMessage, sign);
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value,
        bool isReward
    ) internal {
        if(isReward) {
            emit ShareReward(to, value, block.timestamp);
        }
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::safeTransfer: transfer failed'
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::transferFrom: transferFrom failed'
        );
    }

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/cryptography/ECDSA.sol)

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
        bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        uint8 v = uint8((uint256(vs) >> 255) + 27);
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