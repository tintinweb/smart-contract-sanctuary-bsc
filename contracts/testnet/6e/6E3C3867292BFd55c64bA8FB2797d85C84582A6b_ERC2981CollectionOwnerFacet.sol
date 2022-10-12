//SPDX-License-Identifier: Business Source License 1.1

pragma solidity ^0.8.9;

import "../interfaces/IERC2981Facet.sol";
import "../../../../interfaces/IInitializableFacet.sol";
import "../libraries/LibERC2981.sol";

contract ERC2981CollectionOwnerFacet is IERC2981Facet, IInitializableFacet {
    function initialize(bytes calldata initBytes) external payable {
        (
            address defaultReceiver,
            uint96 royaltyFraction,
            uint96 feeDenominator
        ) = abi.decode(initBytes, (address, uint96, uint96));

        LibERC2981.setDenominator(feeDenominator);
        LibERC2981.setDefaultRoyalty(defaultReceiver, royaltyFraction);
    }

    function cleanUp() external payable {
        LibERC2981.deleteDefaultRoyalty();
    }

    function encode(
        address defaultReceiver,
        uint96 royaltyFraction,
        uint96 feeDenominator
    ) external pure returns (bytes memory) {
        return abi.encode(defaultReceiver, royaltyFraction, feeDenominator);
    }

    function royaltyInfo(uint256 tokenId, uint256 salePrice)
        external
        view
        returns (address receiver, uint256 royaltyAmount)
    {
        return LibERC2981.royaltyInfo(tokenId, salePrice);
    }
}

//SPDX-License-Identifier: Business Source License 1.1

pragma solidity ^0.8.9;

interface IERC2981Facet {
    function royaltyInfo(uint256 tokenId, uint256 salePrice)
        external
        view
        returns (address receiver, uint256 royaltyAmount);
}

//SPDX-License-Identifier: Business Source License 1.1

pragma solidity ^0.8.9;

interface IInitializableFacet {
    function initialize(bytes calldata) external payable;

    function cleanUp() external payable;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

library LibERC2981 {
    error RoyaltyFeeWillExceedSalePrice();
    error InvalidReceriver();

    bytes32 internal constant DIAMOND_STORAGE_POSITION =
        keccak256("diamond.standard.erc2981.royalty");

    struct RoyaltyInfo {
        address receiver;
        uint96 royaltyFraction;
    }

    struct ERC2981Storage {
        uint96 feeDenominator;
        RoyaltyInfo defaultRoyaltyInfo;
        mapping(uint256 => RoyaltyInfo) tokenRoyaltyInfo;
    }

    function erc2981Storage()
        internal
        pure
        returns (ERC2981Storage storage ds)
    {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            ds.slot := position
        }
    }

    function royaltyInfo(uint256 _tokenId, uint256 _salePrice)
        public
        view
        returns (address, uint256)
    {
        ERC2981Storage storage s = erc2981Storage();
        RoyaltyInfo memory royalty = s.tokenRoyaltyInfo[_tokenId];

        if (royalty.receiver == address(0)) {
            royalty = s.defaultRoyaltyInfo;
        }

        uint256 royaltyAmount = (_salePrice * royalty.royaltyFraction) /
            feeDenominator();

        return (royalty.receiver, royaltyAmount);
    }

    function feeDenominator() internal view returns (uint96) {
        return erc2981Storage().feeDenominator;
    }

    function defaultRoyaltyInfo() internal view returns (RoyaltyInfo memory) {
        return erc2981Storage().defaultRoyaltyInfo;
    }

    function setDenominator(uint96 _feeDenominator) internal {
        erc2981Storage().feeDenominator = _feeDenominator;
    }

    function setDefaultRoyalty(address receiver, uint96 feeNumerator) internal {
        if (feeNumerator > feeDenominator()) {
            revert RoyaltyFeeWillExceedSalePrice();
        }

        if (receiver == address(0)) {
            revert InvalidReceriver();
        }

        erc2981Storage().defaultRoyaltyInfo = RoyaltyInfo(
            receiver,
            feeNumerator
        );
    }

    function setTokenRoyalty(
        uint256 tokenId,
        address receiver,
        uint96 feeNumerator
    ) internal {
        if (feeNumerator > feeDenominator()) {
            revert RoyaltyFeeWillExceedSalePrice();
        }

        if (receiver == address(0)) {
            revert InvalidReceriver();
        }

        erc2981Storage().tokenRoyaltyInfo[tokenId] = RoyaltyInfo(
            receiver,
            feeNumerator
        );
    }

    function deleteDefaultRoyalty() internal {
        delete erc2981Storage().defaultRoyaltyInfo;
    }

    function resetTokenRoyalty(uint256 tokenId) internal {
        delete erc2981Storage().tokenRoyaltyInfo[tokenId];
    }
}