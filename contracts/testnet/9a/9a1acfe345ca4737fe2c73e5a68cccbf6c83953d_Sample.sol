/**
 *Submitted for verification at BscScan.com on 2022-05-22
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Sample {
    function inputBool(bool ok) external payable {}
    function inputUint(uint amount) external payable {}
    function inputUint8(uint8 amount) external payable {}

    function inputAddrUint(address to, uint amount) external payable {}

    function inputBytes(bytes calldata sig) external payable {}
    function inputStrings(string calldata s1, string calldata s2) external payable {}

    function inputUintArray(uint256[] calldata tokenIds) external {}
    function inputFixedUintArray(uint32[4] calldata tokenIds) external {}
    function inputAddrUintArray(address _token, uint256[] calldata tokenIds) external {}

    function inputUintStrings(
        uint256 _initialAmount,
        string memory _tokenName,
        uint8 _decimalUnits,
        string memory _tokenSymbol
    ) public {}

    function inputComplex(
        address _renter,
        uint[] memory _resources, 
        uint[] memory _amounts,
        uint _digsToClose,
        bytes memory _prefix,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) public {}
}

interface ISample {
}