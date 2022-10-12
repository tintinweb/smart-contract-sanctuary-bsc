//SPDX-License-Identifier: Business Source License 1.1

pragma solidity ^0.8.9;

library LibERC4907 {
    bytes32 internal constant DIAMOND_STORAGE_POSITION =
        keccak256("diamond.standard.erc4907.rental");

    struct ERC4907Storage {
        mapping(uint256 => address) users;
        mapping(uint256 => uint64) expires;
    }

    function erc4907Storage()
        internal
        pure
        returns (ERC4907Storage storage ds)
    {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            ds.slot := position
        }
    }

    function userOf(uint256 tokenId) internal view returns (address) {
        return erc4907Storage().users[tokenId];
    }

    function userExpires(uint256 tokenId) internal view returns (uint64) {
        return erc4907Storage().expires[tokenId];
    }

    function setUser(
        uint256 tokenId,
        address user,
        uint64 expires
    ) external {
        ERC4907Storage storage s = erc4907Storage();
        s.expires[tokenId] = expires;
        s.users[tokenId] = user;
    }
}