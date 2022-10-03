//SPDX-License-Identifier: Business Source License 1.1
pragma solidity ^0.8.9;

import {LibMeta} from "../../../../libraries/diamond/LibMeta.sol";

library LibERC5058 {
    bytes32 internal constant DIAMOND_STORAGE_POSITION =
        keccak256("diamond.standard.erc5058.lock");

    struct ERC5058Storage {
        mapping(uint256 => address) lockers;
        mapping(uint256 => address) lockApprovals;
        mapping(uint256 => uint256) expiration;
        mapping(address => mapping(address => bool)) lockOperatorApprovals;
    }

    function erc5058Storage()
        internal
        pure
        returns (ERC5058Storage storage ds)
    {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            ds.slot := position
        }
    }

    function lockerOf(uint256 tokenId) internal view returns (address) {
        return erc5058Storage().lockers[tokenId];
    }

    function lock(
        uint256 tokenId,
        uint256 expired,
        address locker
    ) internal {
        ERC5058Storage storage ds = erc5058Storage();
        ds.expiration[tokenId] = expired;
        ds.lockers[tokenId] = locker;
    }

    function unlock(uint256 tokenId) internal {
        ERC5058Storage storage ds = erc5058Storage();
        delete ds.lockers[tokenId];
        delete ds.expiration[tokenId];
    }

    function lockApprove(address to, uint256 tokenId) internal {
        erc5058Storage().lockApprovals[tokenId] = to;
    }

    function setLockApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal {
        erc5058Storage().lockOperatorApprovals[owner][operator] = approved;
    }

    function getLockApproved(uint256 tokenId)
        internal
        view
        returns (address operator)
    {
        return erc5058Storage().lockApprovals[tokenId];
    }

    function isLockApprovedForAll(address owner, address operator)
        internal
        view
        returns (bool)
    {
        return erc5058Storage().lockOperatorApprovals[owner][operator];
    }

    function isLocked(uint256 tokenId) external view returns (bool) {
        // solhint-disable-next-line not-rely-on-time
        return erc5058Storage().expiration[tokenId] >= block.timestamp;
    }

    function lockExpiredTime(uint256 tokenId) external view returns (uint256) {
        return erc5058Storage().expiration[tokenId];
    }
}

//SPDX-License-Identifier: Business Source License 1.1

pragma solidity ^0.8.9;

library LibMeta {
    function msgSender() internal view returns (address sender_) {
        if (msg.sender == address(this)) {
            bytes memory array = msg.data;
            uint256 index = msg.data.length;
            // solhint-disable-next-line no-inline-assembly
            assembly {
                // Load the 32 bytes word from memory with the address on the lower 20 bytes, and mask those.
                sender_ := and(
                    mload(add(array, index)),
                    0xffffffffffffffffffffffffffffffffffffffff
                )
            }
        } else {
            sender_ = msg.sender;
        }
    }
}