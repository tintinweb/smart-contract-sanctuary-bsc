// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

contract Registration {
    mapping(address => string) private registeredAddresses;

    function compareStrings(string memory a, string memory b)
        private
        pure
        returns (bool)
    {
        return (keccak256(abi.encodePacked((a))) ==
            keccak256(abi.encodePacked((b))));
    }

    function registerAddress(string calldata id) public returns (bool) {
        require(
            compareStrings(registeredAddresses[msg.sender], ""),
            "Address is already registered."
        );
        registeredAddresses[msg.sender] = id;
        return true;
    }

    function getRegistrationStatus(address _address)
        public
        view
        returns (string memory)
    {
        return registeredAddresses[_address];
    }
}