// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
 
import "./nf-token-metadata.sol";
import "./ownable.sol";
import "./counters.sol";

 
contract newNFT is NFTokenMetadata, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    uint256 public tokenIdC = 0;
    mapping (uint256 => string) private ms;
    mapping (uint256 => string) private _uris;

  constructor() {
    nftName = "Multis NFT";
    nftSymbol = "MNFT";
  }
 
  function mint(address _to, string calldata _uri) external onlyOwner returns (uint256) {
    _tokenIdCounter.increment();  
    uint256 newItemId = _tokenIdCounter.current();           
    _mint(_to, newItemId);
    _setTokenUri(newItemId, _uri);
    tokenIdC = newItemId;
    return newItemId;
  }

  function mints() external onlyOwner returns (uint256) {
    _tokenIdCounter.increment();
    uint256 newItemId = _tokenIdCounter.current();
    _mint(msg.sender, newItemId);
    tokenIdC = newItemId;
    return newItemId;
  }

  function mintsUris(string[] calldata _uri) external onlyOwner returns (uint256) {
    _tokenIdCounter.increment();
    uint256 newItemId = _tokenIdCounter.current();
    uint256 currentItemIdF = newItemId;
    uint256 curr = currentItemIdF;
    //require(_uri.length <= 0, "_uri required");
      for(uint256 i=0; i < _uri.length; i ++) {
        curr = currentItemIdF + i;
        _mint(msg.sender, curr);
        _setTokenUri(curr, _uri[i]);
        require(newItemId <= currentItemIdF + 1);
        _tokenIdCounter.increment();
      }    
    tokenIdC = curr;
    return newItemId;
  }

  function mintsAddrUris(address[] memory _to, string[] calldata _uri) external onlyOwner returns (uint256) {
    _tokenIdCounter.increment();
    uint256 newItemId = _tokenIdCounter.current();
    uint256 currentItemIdF = newItemId;
    uint256 curr = currentItemIdF;
    // require(_uri.length < _to.length, "_uri required");
      for(uint256 i=0; i < _to.length; i ++) {
        curr = currentItemIdF + i;
        _mint(_to[i], curr);
        _setTokenUri(curr, _uri[i]);
        require(newItemId <= currentItemIdF + 1);
        _tokenIdCounter.increment();
      }    
    tokenIdC = curr;
    return newItemId;
  }

  // function mints10Items() external onlyOwner returns (uint256) {
  //   _tokenIdCounter.increment();
  //   uint256 newItemId = _tokenIdCounter.current();
  //   uint256 currentItemIdF = newItemId;
  //   uint256 curr = currentItemIdF;
  //     for(uint256 i=0; i < 10; i ++) {
  //       curr = currentItemIdF + i;
  //       _mint(msg.sender, curr);
  //       require(newItemId < currentItemIdF + 1);
  //       _tokenIdCounter.increment();
  //     }    
  //   tokenIdC = curr;
  //   return newItemId;
  // }

  function mintsByLimit(uint256 limit) external onlyOwner returns (uint256) {
    _tokenIdCounter.increment();
    uint256 newItemId = _tokenIdCounter.current();
    uint256 currentItemIdF = newItemId;
    uint256 curr = currentItemIdF;
      for(uint256 i=0; i < limit; i ++) {
        curr = currentItemIdF + i;
        _mint(msg.sender, curr);
        require(newItemId < currentItemIdF + 1);
        _tokenIdCounter.increment();
      }    
    tokenIdC = curr;
    return newItemId;
  }

  function showTokenCurrent()
    external
    onlyOwner
    returns (uint256)
  {
    _tokenIdCounter.increment();
    uint256 newItemId = _tokenIdCounter.current();
    return newItemId;
  }

  function mintNFT()
        public onlyOwner
        returns (uint256)
    {
      _tokenIdCounter.increment();
      uint256 newItemId = _tokenIdCounter.current();
      _mint(msg.sender, newItemId);
      tokenIdC = newItemId;
      return newItemId;
    }
function showTokenId()
    external
    view
    returns (uint256)
  {
    uint256 currentItemId = tokenIdC;
    return currentItemId;
  }


  // function checkTokenIdCurr()
  // public
  // returns (uint256)
  // {    
  //   _tokenIdCounter.increment();
  //   uint256 currentItemIdSys = _tokenIdCounter.current();
  //   uint256 currentItemIdF = currentItemIdSys;
  //   uint256 currentItemId = tokenIdC;
  //   require(currentItemId > currentItemIdSys);
  //     currentItemIdSys = currentItemId;

  //   return currentItemIdF;
  // }
}