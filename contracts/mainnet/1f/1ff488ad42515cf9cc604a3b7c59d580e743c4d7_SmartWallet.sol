//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "ReentrancyGuard.sol";

contract SmartWallet is ReentrancyGuard {
    uint256 public nonce;
    address public owner;

    event CallEvent(
        uint256 _nonce,
        bytes _returnData
    );

    constructor(address _owner) {
        owner = _owner;
    }

    receive() external payable {}

    function call(
        address[] memory _logicContractAddress,
        bytes[] memory _payload,
        uint256[] memory _value,
        uint256 _timeout,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) public nonReentrant {
        require(_timeout > block.number, "Transaction timed out");
        bytes32 hash = keccak256(abi.encode(address(this), nonce, _logicContractAddress, _payload, _value, _timeout));
        require(verifySig(owner, hash, _v, _r, _s), "Incorrect sig");

        for (uint8 i = 0; i < _logicContractAddress.length; i++) {
            nonce++;
            bytes memory returnData = functionCallWithValue(_logicContractAddress[i], _payload[i], _value[i]);
            emit CallEvent(nonce - 1, returnData);
        }
    }

    function verifySig(
        address _signer,
        bytes32 _theHash,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) private pure returns (bool) {
        return _signer == ecrecover(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _theHash)), _v, _r, _s);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert();
            }
        }
    }
}