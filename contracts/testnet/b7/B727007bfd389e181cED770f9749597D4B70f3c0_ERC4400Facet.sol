//SPDX-License-Identifier: Business Source License 1.1
pragma solidity ^0.8.9;

import "../interfaces/IERC4400Facet.sol";
import "../libraries/LibERC4400.sol";
import "../../../../libraries/diamond/LibMeta.sol";
import "../AppStorage.sol";

contract ERC4400Facet is IERC4400Facet {
    AppStorage internal s;

    function consumerOf(uint256 _tokenId)
        external
        view
        override
        returns (address)
    {
        return LibERC4400.consumerOf(_tokenId);
    }

    function changeConsumer(address _consumer, uint256 _tokenId)
        external
        override
    {
        address sender = LibMeta.msgSender();
        if (sender != s.owners[_tokenId]) {
            revert OnlyTokenOwnerAccess();
        }

        LibERC4400.changeConsumer(_consumer, _tokenId);
        emit ConsumerChanged(sender, _consumer, _tokenId);
    }
}

//SPDX-License-Identifier: Business Source License 1.1

pragma solidity ^0.8.9;

interface IERC4400Facet {
    event ConsumerChanged(
        address indexed owner,
        address indexed consumer,
        uint256 indexed tokenId
    );

    error OnlyTokenOwnerAccess();

    function consumerOf(uint256 _tokenId) external view returns (address);

    function changeConsumer(address _consumer, uint256 _tokenId) external;
}

//SPDX-License-Identifier: Business Source License 1.1

pragma solidity ^0.8.9;

library LibERC4400 {
    bytes32 internal constant DIAMOND_STORAGE_POSITION =
        keccak256("diamond.standard.erc4400.consumable");

    struct ERC4440Storage {
        mapping(uint256 => address) consumers;
    }

    function erc4400Storage()
        internal
        pure
        returns (ERC4440Storage storage ds)
    {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            ds.slot := position
        }
    }

    function consumerOf(uint256 _tokenId) internal view returns (address) {
        return erc4400Storage().consumers[_tokenId];
    }

    function changeConsumer(address _consumer, uint256 _tokenId) internal {
        erc4400Storage().consumers[_tokenId] = _consumer;
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