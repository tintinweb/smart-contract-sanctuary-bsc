// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
 
import "./nf-token-metadata.sol";
import "./ownable.sol";
import "./counters.sol";

 
contract newNFT is NFTokenMetadata, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    mapping (uint256 => string) private _uris;

  constructor() {
    nftName = "BSCX4 NFT";
    nftSymbol = "BSCX4";
  }
 
  function mint(address _to, string calldata _uri) external onlyOwner {    
    uint256 tokenId = _tokenIdCounter.current();
    _tokenIdCounter.increment();
    super._mint(_to, tokenId);
    super._setTokenUri(tokenId, _uri);
  }

  function mintTokenId(address _to, uint256 _tokenId, string calldata _uri) external onlyOwner {
    super._mint(_to, _tokenId);
    super._setTokenUri(_tokenId, _uri);
  }
 
  function mintMul(address[] memory _to, string calldata _uri) external onlyOwner {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        for (uint256 _idx = 0; _idx < _to.length; _idx++) {
            super._mint(_to[_idx], tokenId);
            super._setTokenUri(tokenId, _uri);
        }
  }

  function mintMulV2() external onlyOwner {
      uint256 tokenId = _tokenIdCounter.current();
      _tokenIdCounter.increment();
      _mint(msg.sender, 0);
      _mint(msg.sender, 1);
      _mint(msg.sender, 2);
      _mint(msg.sender, 3);
      _mint(msg.sender, 4);
      _mint(msg.sender, 5);
      _mint(msg.sender, 6);
      _mint(msg.sender, 7);
      _mint(msg.sender, 8);
      _mint(msg.sender, 9);
      _mint(msg.sender, 10);
  }

  function mintMulV3() external onlyOwner {
      // uint256 tokenId = _tokenIdCounter.current();
      // _tokenIdCounter.increment();
      // _mint(msg.sender, 0);
      address owner = msg.sender;
      for (uint256 _idx = 0; _idx < 10; _idx++) {
          _mint(owner, _idx);
      }
  }

  function mintMulV4() public returns (bool) {
      address owner = msg.sender;
      
      for (uint256 _idx = 0; _idx < 10; _idx++) {
          _mint(owner, _idx);
      }
      return true;
  }
}