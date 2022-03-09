// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
pragma abicoder v2;

import "./impl/RoyaltiesV2Impl.sol";

contract RoyaltiesV2TestImpl is RoyaltiesV2Impl {
  function saveRoyalties(uint256 id, LibPart.Part[] memory royalties) external {
    _saveRoyalties(id, royalties);
  }

  function updateAccount(
    uint256 id,
    address from,
    address to
  ) external {
    _updateAccount(id, from, to);
  }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
pragma abicoder v2;

import "./AbstractRoyalties.sol";
import "../RoyaltiesV2.sol";

contract RoyaltiesV2Impl is AbstractRoyalties, RoyaltiesV2 {
  function getRaribleV2Royalties(uint256 id)
    external
    view
    override
    returns (LibPart.Part[] memory)
  {
    return royalties[id];
  }

  function _onRoyaltiesSet(uint256 id, LibPart.Part[] memory _royalties)
    internal
    override
  {
    emit RoyaltiesSet(id, _royalties);
  }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../LibPart.sol";

abstract contract AbstractRoyalties {
  mapping(uint256 => LibPart.Part[]) internal royalties;

  function _saveRoyalties(uint256 id, LibPart.Part[] memory _royalties)
    internal
  {
    uint256 totalValue;
    for (uint256 i = 0; i < _royalties.length; i++) {
      require(
        _royalties[i].account != address(0x0),
        "Recipient should be present"
      );
      require(_royalties[i].value != 0, "Royalty value should be positive");
      totalValue += _royalties[i].value;
      royalties[id].push(_royalties[i]);
    }
    require(totalValue < 10000, "Royalty total value should be < 10000");
    _onRoyaltiesSet(id, _royalties);
  }

  function _updateAccount(
    uint256 _id,
    address _from,
    address _to
  ) internal {
    uint256 length = royalties[_id].length;
    for (uint256 i = 0; i < length; i++) {
      if (royalties[_id][i].account == _from) {
        royalties[_id][i].account = payable(address(uint160(_to)));
      }
    }
  }

  function _onRoyaltiesSet(uint256 id, LibPart.Part[] memory _royalties)
    internal
    virtual;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
pragma abicoder v2;

import "./LibPart.sol";

interface RoyaltiesV2 {
  event RoyaltiesSet(uint256 tokenId, LibPart.Part[] royalties);

  function getRaribleV2Royalties(uint256 id)
    external
    view
    returns (LibPart.Part[] memory);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

library LibPart {
    bytes32 public constant TYPE_HASH = keccak256("Part(address account,uint96 value)");

    struct Part {
        address payable account;
        uint96 value;
    }

    function hash(Part memory part) internal pure returns (bytes32) {
        return keccak256(abi.encode(TYPE_HASH, part.account, part.value));
    }
}