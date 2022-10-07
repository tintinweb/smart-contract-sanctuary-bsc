// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../interfaces/IERC4907.sol";
import "../libraries/LibERC4907.sol";
import {LibMeta} from "../../../../libraries/diamond/LibMeta.sol";
import {AppStorage} from "../AppStorage.sol";

// TODO: initialize 4907 interfaceID
contract ERC4907Facet is IERC4907Facet {
    AppStorage internal s;

    function setUser(
        uint256 tokenId,
        address user,
        uint64 expires
    ) external {
        if (LibMeta.msgSender() != s.owners[tokenId]) {
            revert OnlyOwnerCanSetUser();
        }

        LibERC4907.setUser(tokenId, user, expires);
        emit UpdateUser(tokenId, user, expires);
    }

    function userOf(uint256 tokenId) external view returns (address) {
        return LibERC4907.userOf(tokenId);
    }

    function userExpires(uint256 tokenId) external view returns (uint256) {
        return LibERC4907.userExpires(tokenId);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IERC4907Facet {
    error OnlyOwnerCanSetUser();
    event UpdateUser(
        uint256 indexed tokenId,
        address indexed user,
        uint64 expires
    );

    function setUser(
        uint256 tokenId,
        address user,
        uint64 expires
    ) external;

    function userOf(uint256 tokenId) external view returns (address);

    function userExpires(uint256 tokenId) external view returns (uint256);
}

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

//SPDX-License-Identifier: Business Source License 1.1
pragma solidity ^0.8.9;

struct AppStorage {
    bool initialized;
    // Token name
    string name;
    // Token symbol
    string symbol;
    // Mapping from token ID to owner address
    mapping(uint256 => address) owners;
    // Mapping owner address to token count
    mapping(address => uint256) balances;
    // Mapping from token ID to approved address
    mapping(uint256 => address) tokenApprovals;
    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) operatorApprovals;
}