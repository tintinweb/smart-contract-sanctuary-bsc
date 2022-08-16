// SPDX-License-Identifier: MIT

pragma solidity ^0.6.6;
pragma experimental ABIEncoderV2;

import "../interfaces/ISigVerify.sol";

contract SigVerifyQlf is ISigVerify {
    function verify (address _signer, bytes32 _messageHash, bytes calldata _sig) external override pure returns(bool) {
        return recover(_messageHash, _sig) == _signer;
    }

    function recover(bytes32 _ethSignedMessageHash, bytes memory _sig) public pure returns(address) {
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
}

pragma solidity >=0.6.2;

interface ISigVerify {

    function verify (address _signer, bytes32 _messageHash, bytes calldata _sig) external pure returns(bool);
}