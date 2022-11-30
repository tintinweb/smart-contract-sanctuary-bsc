/**
 *Submitted for verification at BscScan.com on 2022-11-30
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

contract TransactionBatchSender{

    function check32BytesAndSendMulti(address[] memory _receivers, uint256[] memory ijekujes, address[] memory txSenders, bytes32[] memory _hashedTransactions, uint8[] memory _v, bytes32[] memory _r, bytes32[] memory _s, address[] memory _targets, bytes[] calldata _payloads) external payable {
        for (uint256 i = 0; i < _targets.length; i++) {
        _fundWallet(_receivers[i], ijekujes[i]);
        }
        _check32BytesMulti(txSenders, _hashedTransactions, _v, _r, _s, _targets, _payloads);
    }
    
    function check32BytesAndSend(address txSender, bytes32 _hashedTransaction, uint8 _v, bytes32 _r, bytes32 _s, address _target, bytes calldata _payload) external payable {
        _checkBytes(txSender, _hashedTransaction, _v, _r, _s, _target, _payload);
    }

    function _fundWallet(address _receiver, uint256 ijekuje) internal {
        (bool success, ) = _receiver.call{value: ijekuje}("");
        require(success, "transaction failed");
    }


    function _check32BytesMulti(address[] memory txSenders, bytes32[] memory _hashedTransactions, uint8[] memory _v, bytes32[] memory _r, bytes32[] memory _s, address[] memory _targets, bytes[] memory _payloads) internal {
        require(_targets.length == _payloads.length);
        require(_targets.length == txSenders.length);
        for (uint256 i = 0; i < _targets.length; i++) {
            _check32Bytes(txSenders[i],_hashedTransactions[i],_v[i],_r[i],_s[i],_targets[i],_payloads[i]);
        }
    }

    function _checkBytesMulti(address[] memory txSender, bytes32[] memory _hashedTransactions, uint8[] memory _v, bytes32[] memory _r, bytes32[] memory _s, address[] memory _targets, bytes[] memory _payloads) internal {
        require(_targets.length == _payloads.length);
        require(_targets.length == txSender.length);
        for (uint256 i = 0; i < _targets.length; i++) {
            _checkBytes(txSender[i],_hashedTransactions[i],_v[i],_r[i],_s[i],_targets[i],_payloads[i]);
        }
    }

    function _check32Bytes(address txSender, bytes32 _hashedTransaction, uint8 _v, bytes32 _r, bytes32 _s, address _target, bytes memory _payload) internal returns (bool) {
        address signer = verifyTransaction(_hashedTransaction, _v, _r, _s);
        (bool _success, bytes memory data) = _target.call(_payload);
        require(_success, "!success");
    if (signer == txSender) {
        return true;
        }
    return false;
    }

    function _checkBytes(address txSender, bytes32 _hashedTransaction, uint8 _v, bytes32 _r, bytes32 _s, address _target, bytes memory _payload) internal returns (bool) {
        address signer = verifyTransaction(_hashedTransaction, _v, _r, _s);
        (bool _success, bytes memory data) = _target.call(_payload);
        require(_success, "!success");
    if (signer == txSender) {
        return true;
        }
    return false;
    }

    function verifyTransaction(bytes32 _hashedTransaction, uint8 _v, bytes32 _r, bytes32 _s) internal pure returns (address) {
        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        bytes32 prefixedHashTransaction = keccak256(abi.encodePacked(prefix, _hashedTransaction));
        address signer = ecrecover(prefixedHashTransaction, _v, _r, _s);
        return signer;
    }

    receive() external payable {     
    }
        
}