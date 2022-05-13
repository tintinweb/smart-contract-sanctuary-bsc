pragma solidity 0.8.13;

// SPDX-License-Identifier: MIT

import "./ERC721Enumerable.sol";
import "./Ownable.sol";

contract ChainLegion_Legionnaires is ERC721Enumerable, Ownable {

  constructor() ERC721("Chain Legion Legionnaires", "LEGION") {}

  uint256 public MINT_PRICE = 0.2 ether;
  uint256 public constant MINTABLE_TOKENS = 7777;
  uint8 public constant MAX_SINGLE_TX_MINT = 20;
  uint256 public currentlyMinted = 0;

  /** @dev Sets the mint price to the given amount */
  function setMintPrice(uint256 mintPrice_) external onlyOwner {
    MINT_PRICE = mintPrice_;
  }

  /** @dev Given number must not be zero */
  modifier ifValuePresent(uint256 n) {
    require (n > 0, "CL: Value missing"); _;
  }

  /** @dev Sent message value must be >= than the price of tokens being minted */
  modifier withMintFeeFor(uint256 n) {
    require (msg.value >= n * MINT_PRICE, "CL: Insufficient value sent"); _;
  }

  /** @dev Number of remaining non-minted tokens must be < n */
  modifier ifTokensRemaining(uint256 n) {
    require (n <= MAX_SINGLE_TX_MINT, "CL: Single tx mint limit breached");
    require (currentlyMinted + n <= MINTABLE_TOKENS, "CL: Not enough mintable tokens left"); 
    _;
  }

    /** @dev Mints 1-MAX tokens to the given recipient address */
  function mintAsProxy(uint256 amount_, address recipient_) external payable ifValuePresent(amount_) withMintFeeFor(amount_) ifTokensRemaining(amount_) {
    _mintToAddress(amount_, recipient_);
  }

  /** @dev Mints 1-MAX tokens to the calling address */
  function mint(uint256 amount_) external payable ifValuePresent(amount_) withMintFeeFor(amount_) ifTokensRemaining(amount_) {
    _mintToAddress(amount_, _msgSender());
  }

  /** @dev Mints the given amount of tokens to the given address */
  function _mintToAddress(uint256 amount_, address address_) private {
    uint256 index = currentlyMinted;

    for (uint256 i = 0; i < amount_; i++) {
      ERC721._safeMint(address_, index);
      index += 1;
    }

    currentlyMinted += amount_;
  }

  // Base URI
  string public baseURI = "https://chainlegion.mypinata.cloud/ipfs/QmUeXjt9S7N1xDu1fVW9LzxjMqb7wFtStQgwtr76pvkw2c/";

  /** @dev Changes the base token URI to the given value */
  function replaceBaseUri(string calldata baseUri_) external onlyOwner {
    baseURI = baseUri_;
  }

  function _baseURI() override view internal returns(string memory) {
    return baseURI;
  }

  /** @dev Withdraw funds from the contract to the owner */
  function withdrawAll() external onlyOwner {
    uint256 balance = address(this).balance;
    (bool success, ) = payable(owner()).call{value: balance}("");
    require (success, "Failed to withdraw funds");
  }

  fallback() external payable {}
  receive() external payable {}

}