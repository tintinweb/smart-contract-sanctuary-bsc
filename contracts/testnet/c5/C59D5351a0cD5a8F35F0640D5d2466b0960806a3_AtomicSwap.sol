//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

contract AtomicSwap {
    mapping(address => string) key;
    mapping(address => string) miniHash;
    mapping(string => mapping(address => bool)) withdrawable;

    function getMessageHash(
        address _to,
        uint256 _amount,
        string memory _nonce,
        uint256 _deadline
    ) public pure returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(_to, _amount, _nonce, _deadline)
            );
    }

    function getEthSignedMessageHash(bytes32 _messageHash)
        public
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

    function depositWithHash(
        address _signer,
        address _to,
        uint256 _amount,
        string memory _nonce,
        uint256 _deadline,
        bytes memory signature
    ) public payable {
        bytes32 messageHash = getMessageHash(
            _to,
            _amount,
            _nonce,
            _deadline
        );
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);
        require(msg.value == _amount, "Invalid value");
        require(recoverSigner(ethSignedMessageHash, signature) == _signer);
        key[_to] = _nonce;
        withdrawable[_nonce][_to] = false;
    }

    function verifyWithHash(
        address _signer,
        address _to,
        uint256 _amount,
        string memory _miniHash,
        uint256 _deadline,
        bytes memory signature
    ) public {
        bytes32 messageHash = getMessageHash(
            _to,
            _amount,
            _miniHash,
            _deadline
        );
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);
        require(recoverSigner(ethSignedMessageHash, signature) == _signer);
        miniHash[_to] = _miniHash;
    }

    function getMiniHash (
        address _signer,
        address _to,
        uint256 _amount,
        uint256 _deadline,
        bytes memory signature
    ) public view returns (string memory) {
        bytes32 messageHash = getMessageHash(
            _to,
            _amount,
            miniHash[msg.sender],
            _deadline
        );
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);
        require(recoverSigner(ethSignedMessageHash, signature) == _signer);
        require(block.timestamp < _deadline);
        return miniHash[msg.sender];
    }

    function setWithdrawable(
        address _signer,
        address _to,
        uint256 _amount,
        uint256 _deadline,
        bytes memory signature,
        string memory _nonce
    ) public {
        bytes32 messageHash = getMessageHash(
            _to,
            _amount,
            miniHash[msg.sender],
            _deadline
        );
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);
        require(recoverSigner(ethSignedMessageHash, signature) == _signer);
        require(block.timestamp < _deadline);
        withdrawable[_nonce][_signer] = true;
    }

    function withdrawWithHash(
        address _signer,
        address _to,
        uint256 _amount,
        uint256 _deadline,
        bytes memory signature
    ) public payable {
        bytes32 messageHash = getMessageHash(
            _to,
            _amount,
            key[msg.sender],
            _deadline
        );
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);
        require(recoverSigner(ethSignedMessageHash, signature) == _signer);
        require(block.timestamp < _deadline);
        payable(msg.sender).transfer(_amount);
    }

    function recoverSigner(
        bytes32 _ethSignedMessageHash,
        bytes memory _signature
    ) public pure returns (address) {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);

        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    function splitSignature(bytes memory sig)
        public
        pure
        returns (
            bytes32 r,
            bytes32 s,
            uint8 v
        )
    {
        require(sig.length == 65, "invalid signature length");

        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
    }
}