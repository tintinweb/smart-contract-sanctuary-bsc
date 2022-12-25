/**
 *Submitted for verification at BscScan.com on 2022-12-24
*/

// this contract is copied from
// https://github.com/enricobottazzi/ZK-SBT/blob/29bb0d8886c54850994a03750d46b9d059450cba/contracts/PrivateSoulMinter.sol

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

// Credit to @Miguel Piedrafita for the SoulBound Token contract skeleton

/// @title SoulBound Token Minter
/// @author Snake
/// @notice Barebones contract to mint Private Soulbound Token
contract SBTMint {
  /// @notice Thrown when trying to transfer a Soulbound token
  error Soulbound();

  /// @notice Emitted when minting a Soulbound Token
  /// @param from Who the token comes from. Will always be address(0)
  /// @param to The token recipient
  /// @param id The ID of the minted token
  event Transfer(address indexed from, address indexed to, uint256 indexed id);

  /// @notice The symbol for the token
  string public constant symbol = "SSS";

  /// @notice The name for the token
  string public constant name = "Snake Token";

  /// @notice The owner of this contract (set to the deployer)
  address public immutable owner = msg.sender;

  /// @notice Get the metadata URI for a certain tokenID
  mapping(uint256 => string) public tokenURI;

  /// @notice Get the hash of the claim metadata for a certain tokenID
  mapping(uint256 => bytes32) public claimSignatureHash;

  /// @notice Get the owner of a certain tokenID
  mapping(uint256 => address) public ownerOf;

  /// @notice Get how many SoulMinter Token a certain user owns
  mapping(address => uint256) public balanceOf;

  // this is for easy demo
  // this could be better and efficient in prod
  mapping(uint256 => address) public issuers;
  mapping(address => uint256) public souls;

  /// @dev Counter for the next tokenID, defaults to 1 for better gas on first mint
  uint256 internal nextTokenId = 1;

  constructor() payable {}

  /// @notice This function was disabled to make the token Soulbound. Calling it will revert
  function approve(address, uint256) public virtual {
    revert Soulbound();
  }

  /// @notice This function was disabled to make the token Soulbound. Calling it will revert
  function isApprovedForAll(address, address) public pure {
    revert Soulbound();
  }

  /// @notice This function was disabled to make the token Soulbound. Calling it will revert
  function getApproved(uint256) public pure {
    revert Soulbound();
  }

  /// @notice This function was disabled to make the token Soulbound. Calling it will revert
  function setApprovalForAll(address, bool) public virtual {
    revert Soulbound();
  }

  /// @notice This function was disabled to make the token Soulbound. Calling it will revert
  function transferFrom(address, address, uint256) public virtual {
    revert Soulbound();
  }

  /// @notice This function was disabled to make the token Soulbound. Calling it will revert
  function safeTransferFrom(address, address, uint256) public virtual {
    revert Soulbound();
  }

  /// @notice This function was disabled to make the token Soulbound. Calling it will revert
  function safeTransferFrom(address, address, uint256, bytes calldata) public virtual {
    revert Soulbound();
  }

  function supportsInterface(bytes4 interfaceId) public pure returns (bool) {
    return
      interfaceId == 0x01ffc9a7 || // ERC165 Interface ID for ERC165
      interfaceId == 0x80ac58cd || // ERC165 Interface ID for ERC721
      interfaceId == 0x5b5e139f; // ERC165 Interface ID for ERC721Metadata
  }

  /// @notice Mint a new Soulbound Token to `to`
  /// @param to The recipient of the Token
  /// @param metaURI The URL to the token metadata
  function mint(address to, string calldata metaURI, bytes32 claimHashMetadata) public payable {
    require(balanceOf[to] < 1, "You can only have one token associated to your soul");

    unchecked {
      balanceOf[to]++;
    }

    ownerOf[nextTokenId] = to;
    tokenURI[nextTokenId] = metaURI;
    claimSignatureHash[nextTokenId] = claimHashMetadata;

    souls[to] = nextTokenId;

    emit Transfer(address(0), to, nextTokenId++);
  }
}