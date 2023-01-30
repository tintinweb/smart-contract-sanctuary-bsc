/**
 *Submitted for verification at BscScan.com on 2023-01-30
*/

/**
 *Submitted for verification at BscScan.com on 2023-01-16
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

IERC20 constant W3C = IERC20(0x2fa6ee42BacF983F050210A1ca42f88686327FC9);

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

abstract contract Owned {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event OwnerUpdated(address indexed user, address indexed newOwner);

    /*//////////////////////////////////////////////////////////////
                            OWNERSHIP STORAGE
    //////////////////////////////////////////////////////////////*/

    address public owner;

    modifier onlyOwner() virtual {
        require(msg.sender == owner, "UNAUTHORIZED");

        _;
    }

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor() {
        owner = msg.sender;
        emit OwnerUpdated(address(0), msg.sender);
    }

    /*//////////////////////////////////////////////////////////////
                             OWNERSHIP LOGIC
    //////////////////////////////////////////////////////////////*/

    function setOwner(address newOwner) public virtual onlyOwner {
        owner = newOwner;
        emit OwnerUpdated(msg.sender, newOwner);
    }
}

contract VerifySignature {
    function getMessageHash(
        uint256 amount,
        address to,
        uint256 _nonce
    ) private pure returns (bytes32) {
        return keccak256(abi.encodePacked(amount, to, _nonce));
    }

    function getEthSignedMessageHash(bytes32 _messageHash)
        private
        pure
        returns (bytes32)
    {
        return
            keccak256(
                abi.encodePacked(
                    "\x19Ethereum Signed Message:\n32",
                    _messageHash
                )
            );
    }

    function verify(
        address _signer,
        uint256 amount,
        address to,
        uint256 _nonce,
        bytes memory signature
    ) internal pure returns (bool) {
        bytes32 messageHash = getMessageHash(amount, to, _nonce);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);

        return recoverSigner(ethSignedMessageHash, signature) == _signer;
    }

    function recoverSigner(
        bytes32 _ethSignedMessageHash,
        bytes memory _signature
    ) private pure returns (address) {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);
        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    function splitSignature(bytes memory sig)
        private
        pure
        returns (
            bytes32 r,
            bytes32 s,
            uint8 v
        )
    {
        require(sig.length == 65, "invalid signature length");
        assembly {
            // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
            // second 32 bytes
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }
    }
}

contract Vault is Owned, VerifySignature {
    struct UserWithdraw {
        uint256 amount;
        uint256 lastRewardTime;
    }
    mapping(address => UserWithdraw) public record;
    mapping(address => uint256) public userNonce;

    address public signer = 0x90496B1504bDF0b90792c9960707070fB6B34dC3;

    function withdraw(
        uint256 amount,
        address to,
        uint256 nonce,
        bytes memory signature
    ) external {
        require(nonce > userNonce[to], "nonce");
        require(
            verify(signer, amount, to, nonce, signature),
            "signature not match"
        );

        record[to] = UserWithdraw({
            amount: amount + record[to].amount,
            lastRewardTime: block.timestamp
        });
        userNonce[to] = nonce + 1;
        W3C.transfer(to, amount);
    }

    function setSigner(address _signer) external onlyOwner {
        signer = _signer;
    }
}