//SPDX-License-Identifier: Business Source License 1.1

pragma solidity ^0.8.9;

import "../interfaces/IERC721ApprovableFacet.sol";
import {AppStorage} from "../AppStorage.sol";
import {LibMeta} from "../../../../libraries/diamond/LibMeta.sol";

contract ERC721ApprovableFacet is IERC721ApprovableFacet {
    AppStorage internal s;

    function _ownerOf(uint256 tokenId_) internal view returns (address) {
        address owner = s.owners[tokenId_];
        require(owner != address(0), "ERC721: invalid token ID");
        return owner;
    }

    function _approve(address to, uint256 tokenId) internal {
        s.tokenApprovals[tokenId] = to;
        emit Approval(_ownerOf(tokenId), to, tokenId);
    }

    function _isApprovedForAll(address owner, address operator)
        internal
        view
        returns (bool)
    {
        return s.operatorApprovals[owner][operator];
    }

    function approve(address to_, uint256 tokenId_) public override {
        address sender = LibMeta.msgSender();
        address owner = _ownerOf(tokenId_);
        // solhint-disable-next-line reason-string
        require(to_ != owner, "ERC721: approval to current owner");
        // solhint-disable-next-line reason-string
        require(
            sender == owner || _isApprovedForAll(owner, sender),
            "ERC721: approve caller is not token owner nor approved for all"
        );

        _approve(to_, tokenId_);
    }

    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC721: approve to caller");
        s.operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    function setApprovalForAll(address operator, bool approved)
        public
        override
    {
        address sender = LibMeta.msgSender();
        _setApprovalForAll(sender, operator, approved);
    }
}

//SPDX-License-Identifier: Business Source License 1.1
pragma solidity ^0.8.9;

interface IERC721ApprovableFacet {
    event Approval(
        address indexed owner,
        address indexed approved,
        uint256 indexed tokenId
    );

    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

    function setApprovalForAll(address operator, bool approved) external;

    function approve(address to_, uint256 tokenId_) external;

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