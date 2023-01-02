// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.11;

import "./ITokenBundle.sol";

/**
 *  The thirdweb `Pack` contract is a lootbox mechanism. An account can bundle up arbitrary ERC20, ERC721 and ERC1155 tokens into
 *  a set of packs. A pack can then be opened in return for a selection of the tokens in the pack. The selection of tokens distributed
 *  on opening a pack depends on the relative supply of all tokens in the packs.
 */

interface IPack is ITokenBundle {
    /**
     *  @notice All info relevant to packs.
     *
     *  @param perUnitAmounts           Mapping from a UID -> to the per-unit amount of that asset i.e. `Token` at that index.
     *  @param openStartTimestamp       The timestamp after which packs can be opened.
     *  @param amountDistributedPerOpen The number of reward units distributed per open.
     */
    struct PackInfo {
        uint256[] perUnitAmounts;
        uint128 openStartTimestamp;
        uint128 amountDistributedPerOpen;
    }

    /// @notice Emitted when a set of packs is created.
    event PackCreated(uint256 indexed packId, address recipient, uint256 totalPacksCreated);

    /// @notice Emitted when more packs are minted for a packId.
    event PackUpdated(uint256 indexed packId, address recipient, uint256 totalPacksCreated);

    /// @notice Emitted when a pack is opened.
    event PackOpened(
        uint256 indexed packId,
        address indexed opener,
        uint256 numOfPacksOpened,
        Token[] rewardUnitsDistributed
    );

    /**
     *  @notice Creates a pack with the stated contents.
     *
     *  @param contents                 The reward units to pack in the packs.
     *  @param numOfRewardUnits         The number of reward units to create, for each asset specified in `contents`.
     *  @param packUri                  The (metadata) URI assigned to the packs created.
     *  @param openStartTimestamp       The timestamp after which packs can be opened.
     *  @param amountDistributedPerOpen The number of reward units distributed per open.
     *  @param recipient                The recipient of the packs created.
     *
     *  @return packId The unique identifer of the created set of packs.
     *  @return packTotalSupply The total number of packs created.
     */
    function createPack(
        Token[] calldata contents,
        uint256[] calldata numOfRewardUnits,
        string calldata packUri,
        uint128 openStartTimestamp,
        uint128 amountDistributedPerOpen,
        address recipient
    ) external payable returns (uint256 packId, uint256 packTotalSupply);

    /**
     *  @notice Lets a pack owner open a pack and receive the pack's reward unit.
     *
     *  @param packId       The identifier of the pack to open.
     *  @param amountToOpen The number of packs to open at once.
     */
    function openPack(uint256 packId, uint256 amountToOpen) external returns (Token[] memory);
}

// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

/**
 *  Group together arbitrary ERC20, ERC721 and ERC1155 tokens into a single bundle.
 *
 *  The `Token` struct is a generic type that can describe any ERC20, ERC721 or ERC1155 token.
 *  The `Bundle` struct is a data structure to track a group/bundle of multiple assets i.e. ERC20,
 *  ERC721 and ERC1155 tokens, each described as a `Token`.
 *
 *  Expressing tokens as the `Token` type, and grouping them as a `Bundle` allows for writing generic
 *  logic to handle any ERC20, ERC721 or ERC1155 tokens.
 */

interface ITokenBundle {
    /// @notice The type of assets that can be wrapped.
    enum TokenType {
        ERC20,
        ERC721,
        ERC1155
    }

    /**
     *  @notice A generic interface to describe any ERC20, ERC721 or ERC1155 token.
     *
     *  @param assetContract The contract address of the asset.
     *  @param tokenType     The token type (ERC20 / ERC721 / ERC1155) of the asset.
     *  @param tokenId       The token Id of the asset, if the asset is an ERC721 / ERC1155 NFT.
     *  @param totalAmount   The amount of the asset, if the asset is an ERC20 / ERC1155 fungible token.
     */
    struct Token {
        address assetContract;
        TokenType tokenType;
        uint256 tokenId;
        uint256 totalAmount;
    }

    /**
     *  @notice An internal data structure to track a group / bundle of multiple assets i.e. `Token`s.
     *
     *  @param count    The total number of assets i.e. `Token` in a bundle.
     *  @param uri      The (metadata) URI assigned to the bundle created
     *  @param tokens   Mapping from a UID -> to a unique asset i.e. `Token` in the bundle.
     */
    struct BundleInfo {
        uint256 count;
        string uri;
        mapping(uint256 => Token) tokens;
    }
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "./ITokenBundle.sol";
import "./IPack.sol";

contract NFTPackMinter {
    address public nftPackAddress;
    address public tokenAddress;
    address public editionAddress;

    constructor(
        address _nftPackAddress,
        address _tokenAddress,
        address _editionAddress
    ) {
        require(_nftPackAddress != address(0), "Invalid nft pack address");
        require(_tokenAddress != address(0), "Invalid token address");
        require(_editionAddress != address(0), "Invalid edition address");

        nftPackAddress = _nftPackAddress;
        tokenAddress = _tokenAddress;
        editionAddress = _editionAddress;
    }

    function mintPack() public {
        ITokenBundle.Token memory _erc20tokenForPack = ITokenBundle.Token({
            assetContract: tokenAddress,
            tokenType: ITokenBundle.TokenType.ERC20,
            tokenId: 0,
            totalAmount: 100
        });

        ITokenBundle.Token memory _erc1155tokenData1 = ITokenBundle.Token({
            assetContract: editionAddress,
            tokenType: ITokenBundle.TokenType.ERC1155,
            tokenId: 2,
            totalAmount: 100
        });

        ITokenBundle.Token memory _erc1155tokenData2 = ITokenBundle.Token({
            assetContract: editionAddress,
            tokenType: ITokenBundle.TokenType.ERC1155,
            tokenId: 3,
            totalAmount: 5
        });

        ITokenBundle.Token[] memory contents = new ITokenBundle.Token[](3);
        contents[0] = _erc20tokenForPack;
        contents[1] = _erc1155tokenData1;
        contents[2] = _erc1155tokenData2;

        uint256[] memory rewards;
        rewards[0] = 100;
        rewards[1] = 100;
        rewards[2] = 5;
        IPack(nftPackAddress).createPack(
            contents,
            rewards,
            "",
            uint128(block.timestamp),
            1,
            msg.sender
        );
    }
}