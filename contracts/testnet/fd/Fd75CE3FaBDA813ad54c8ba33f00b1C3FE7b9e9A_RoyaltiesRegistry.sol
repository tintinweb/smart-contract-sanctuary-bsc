// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
pragma abicoder v2;

import "./IRoyaltiesProvider.sol";
import "./LibRoyaltiesV2.sol";
import "./impl/RoyaltiesV2Impl.sol";
import "./LibRoyalties2981.sol";
import "./IERC2981.sol";
import "@openzeppelin/contracts-upgradeable/utils/introspection/IERC165Upgradeable.sol";

contract RoyaltiesRegistry is IRoyaltiesProvider {

	mapping(bytes32 => RoyaltiesSetting) public royaltiesByTokenAndTokenId;
	mapping(address => RoyaltiesSetting) public royaltiesByToken;

	function getRoyalties(address token, uint tokenId) external view override returns (LibPart.Part[] memory) {
		RoyaltiesSetting memory royaltiesSetting = royaltiesByTokenAndTokenId[keccak256(abi.encode(token, tokenId))];
		if (royaltiesSetting.initialized) {
			return royaltiesSetting.royalties;
		}
		royaltiesSetting = royaltiesByToken[token];
		if (royaltiesSetting.initialized) {
			return royaltiesSetting.royalties;
		} else if (IERC165Upgradeable(token).supportsInterface(LibRoyalties2981._INTERFACE_ID_ROYALTIES)) {
			IERC2981 v2981 = IERC2981(token);
			try v2981.royaltyInfo(tokenId, LibRoyalties2981._WEIGHT_VALUE) returns (address receiver, uint256 royaltyAmount) {
				return LibRoyalties2981.calculateRoyalties(receiver, royaltyAmount);
			} catch {}
		}
		return royaltiesSetting.royalties;
	}

	function setRoyaltiesCacheByTokenAndTokenId(address token, uint tokenId, LibPart.Part[] memory royalties) external override {
		uint sumRoyalties = 0;
		bytes32 key = keccak256(abi.encode(token, tokenId));
		for (uint i = 0; i < royalties.length; i++) {
			require(royalties[i].account != address(0x0), "RoyaltiesByTokenAndTokenId recipient should be present");
			require(royalties[i].value != 0, "Fee value for RoyaltiesByTokenAndTokenId should be > 0");
			royaltiesByTokenAndTokenId[key].royalties.push(royalties[i]);
			sumRoyalties += royalties[i].value;
		}
		require(sumRoyalties < 10000, "Set by token and tokenId royalties sum more, than 100%");
		royaltiesByTokenAndTokenId[key].initialized = true;
	}

	uint256[46] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
pragma abicoder v2;

import "./LibPart.sol";

interface IRoyaltiesProvider {
  struct RoyaltiesSetting {
    bool initialized;
    LibPart.Part[] royalties;
  }

  function getRoyalties(address token, uint256 tokenId)
    external
    returns (LibPart.Part[] memory);

  function setRoyaltiesCacheByTokenAndTokenId(
    address token,
    uint256 tokenId,
    LibPart.Part[] memory royalties
  ) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

library LibRoyaltiesV2 {
    /*
     * bytes4(keccak256('getRaribleV2Royalties(uint256)')) == 0xcad96cca
     */
    bytes4 constant _INTERFACE_ID_ROYALTIES = 0xcad96cca;
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

import "./LibPart.sol";

library LibRoyalties2981 {
  /*
   * https://eips.ethereum.org/EIPS/eip-2981: bytes4 private constant _INTERFACE_ID_ERC2981 = 0x2a55205a;
   */
  bytes4 constant _INTERFACE_ID_ROYALTIES = 0x2a55205a;
  uint96 constant _WEIGHT_VALUE = 1000000;

  /*Method for converting amount to percent and forming LibPart*/
  function calculateRoyalties(address to, uint256 amount)
    internal
    pure
    returns (LibPart.Part[] memory)
  {
    LibPart.Part[] memory result;
    if (amount == 0) {
      return result;
    }
    uint256 percent = ((amount * 100) / _WEIGHT_VALUE) * 100;
    require(percent < 10000, "Royalties 2981, than 100%");
    result = new LibPart.Part[](1);
    result[0].account = payable(to);
    result[0].value = uint96(percent);
    return result;
  }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "./LibPart.sol";
///
/// @dev Interface for the NFT Royalty Standard
///
//interface IERC2981 is IERC165 {
interface IERC2981 {
    /// ERC165 bytes to add to interface array - set in parent contract
    /// implementing this standard
    ///
    /// bytes4(keccak256("royaltyInfo(uint256,uint256)")) == 0x2a55205a
    /// bytes4 private constant _INTERFACE_ID_ERC2981 = 0x2a55205a;
    /// _registerInterface(_INTERFACE_ID_ERC2981);

    /// @notice Called with the sale price to determine how much royalty
    //          is owed and to whom.
    /// @param _tokenId - the NFT asset queried for royalty information
    /// @param _salePrice - the sale price of the NFT asset specified by _tokenId
    /// @return receiver - address of who should be sent the royalty payment
    /// @return royaltyAmount - the royalty payment amount for _salePrice
    function royaltyInfo(
        uint256 _tokenId,
        uint256 _salePrice
    ) external view returns (
        address receiver,
        uint256 royaltyAmount
    );
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165Upgradeable {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
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