// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

interface IMoonpets {
    function getAttributesOnPet(uint256 _petId) external view returns (int256[] memory);
}

library MoonpetsVerifier {

    address public constant Moonpets = 0xE32aE22Ec60E21980247B4bDAA16E9AEa265F919;

    function verifyMoonpetHasAttributes(uint256 tokenId, int256[] calldata attributeIds) public view {
        int256[] memory _attributeIds = IMoonpets(Moonpets).getAttributesOnPet(tokenId);
        require(_attributeIds.length == attributeIds.length, "Attributes changed");
        for (uint256 i = 0; i < _attributeIds.length; ++i) {
            require(_attributeIds[i] == attributeIds[i], "Attributes changed");
        }
    }

}