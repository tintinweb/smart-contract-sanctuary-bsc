// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

import "./Strings.sol";

import "./Ownable.sol";
import "./ERC721Enumerable.sol";

contract Orange is ERC721Enumerable, Ownable {
  using Strings for uint256;

  uint256 public cost = 0.2 ether;
  uint256 public maxSupply = 9999;
  uint256 public maxMintAmount = 10;
  bool public paused = true;
  string baseURI;
  string public baseExtension = ".json";

  constructor(
    string memory _name,
    string memory _symbol,
    string memory _initBaseURI
  ) ERC721(_name, _symbol) {
    setBaseURI(_initBaseURI);
  }

  function _baseURI() internal view virtual override returns (string memory) {
    return baseURI;
  }

  function mint(uint256 _mintAmount) public payable {
    uint256 supply = totalSupply();
    require(!paused, "Sale is paused");
    require(_mintAmount > 0, "Mint at least 1");
    require(_mintAmount <= maxMintAmount, "Max per transaction: 10");
    require(supply + _mintAmount <= maxSupply, "Not enough token supply");
    require(msg.value >= cost * _mintAmount, "Invalid ether amount");

    for (uint256 i = 1; i <= _mintAmount; i++) {
      _safeMint(msg.sender, supply + i);
    }
  }

  function sendAirdrops(address[] memory _wallets) public onlyOwner {
    uint256 supply = totalSupply();
    require(supply + _wallets.length <= maxSupply, "Not enough token supply");

    for (uint256 i = 0; i < _wallets.length; i++) {
      _safeMint(_wallets[i], supply + i);
    }
  }

  function walletOfOwner(address _owner)
    public
    view
    returns (uint256[] memory)
  {
    uint256 ownerTokenCount = balanceOf(_owner);
    uint256[] memory tokenIds = new uint256[](ownerTokenCount);
    for (uint256 i; i < ownerTokenCount; i++) {
      tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
    }
    return tokenIds;
  }

  function tokenURI(uint256 tokenId)
    public
    view
    virtual
    override
    returns (string memory)
  {
    require(
      _exists(tokenId),
      "ERC721Metadata: URI query for nonexistent token"
    );

    string memory currentBaseURI = _baseURI();
    return bytes(currentBaseURI).length > 0
        ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), baseExtension))
        : "";
  }
  
  function setCost(uint256 _newCost) public onlyOwner {
    cost = _newCost;
  }

  function setMaxMintAmount(uint256 _newmaxMintAmount) public onlyOwner {
    maxMintAmount = _newmaxMintAmount;
  }
  
  function setBaseURI(string memory _newBaseURI) public onlyOwner {
    baseURI = _newBaseURI;
  }

  function setBaseExtension(string memory _newBaseExtension) public onlyOwner {
    baseExtension = _newBaseExtension;
  }

  function setPublicSalePaused(bool _state) public onlyOwner {
    paused = _state;
  }

  function withdraw() public onlyOwner {
    uint _balance = address(this).balance;
    payable(0x2C32284d93D218E0514f983E4c8F61D6cfA95e3b).transfer(_balance * 48 / 100);// marketing wallet
    payable(0x5F6100dF1EC9bdFf4721Af8c85D388DD7F663ed2).transfer(_balance * 29 / 100); // dev wallet
    payable(0x429109C7739F47E41A96Cd85b4991962bec33504).transfer(address(this).balance); // staking wallet
  }

}