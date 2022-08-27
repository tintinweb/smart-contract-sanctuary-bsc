// SPDX-License-Identifier: MIT

pragma solidity ^0.6.6;
pragma experimental ABIEncoderV2;

import "./interfaces/ISigVerify.sol";

contract SigVerifyQlf is ISigVerify {

    function verify (
        address _signer, 
        address _sender,
        uint256[] calldata _data,
        address _verifier,
        bytes calldata _sig
    ) external override pure returns(bool) {
        bytes32 _messageHash = messageHashing(
            keccak256(
                abi.encodePacked(
                    _sender,
                    _data[0],
                    _data[1],
                    _data[2],
                    _verifier
                )
            )
        );

        require(_signer != address(0), "Invalid signer");
        return recover(_messageHash, _sig) == _signer;
    }

    function recover(bytes32 _ethSignedMessageHash, bytes memory _sig) private pure returns(address) {
        (bytes32 r, bytes32 s, uint8 v) = _split(_sig);

        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    function _split (bytes memory _sig) internal pure returns(bytes32 r, bytes32 s, uint8 v) {
        require(_sig.length == 65, "Invalid signature length");

        assembly {
            r := mload(add(_sig, 32))
            s := mload(add(_sig, 64))
            v := byte(0, mload(add(_sig, 96)))
        }
    }

    function messageHashing(bytes32 _messageHash) private pure returns(bytes32) {
        return keccak256(abi.encodePacked(
            "\x19Ethereum Signed Message:\n32",
            _messageHash
        ));
    }

    function getMessageHash(
        address _sender,
        uint256 _boxId,
        uint256 _quantity,
        uint256 _receiptId,
        address _verifier
    ) public pure returns(bytes32) {
        return keccak256(abi.encodePacked(
            _sender,
            _boxId,
            _quantity,
            _receiptId,
            _verifier
        ));
    }
}

pragma solidity >=0.6.2;

interface ISigVerify {

    function verify (
        address _signer, 
        address _sender,
        uint256[] calldata _data,
        address _verifier,
        bytes calldata _sig
    ) external pure returns(bool);
}