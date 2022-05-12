pragma solidity ^0.8.0;
//SPDX-License-Identifier: MIT

import "./ERC721.sol";
import "./Ownable.sol";



contract MoonWalkSneaker is ERC721, Ownable {

  address customToken;
  bool allowAllTrades = false;
  bool _shouldSendToMarketing = true;
  using Strings for uint256;
  uint256 public currentSupply = 0;
  address payable public marketingAddress =
        payable(0xF6E9f0315C8e9146C1b6232585a2987bF4D506FC);
  
  string public baseURI = "";

  uint256 id = 1;

  uint256 customTokenDecimals = 10**9;

  uint256 public priceInWEI = 1000000000000000000 wei;

  uint256 public priceInCustomToken = 5 * 10**5 * customTokenDecimals;

  mapping(uint => bool) public blackList;

  constructor() 
    ERC721("MoonWalk Sneaker", "Sneaker")
    {
      customToken = 0xc81A47EA0fDDFb6B72099bd4b7F041e710DAe8aA;
    }

  function _baseURI() internal view virtual override returns (string memory) {
    return baseURI;
  }

  function safeTransferFrom(address from, address to, uint256 tokenId) public override{
      safeTransferFrom(from, to, tokenId, "");
  }

      function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public virtual override {
      require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
      if(allowAllTrades){
        _safeTransfer(from, to, tokenId, data);
      }
      else{
      require(blackList[id] != false, "Token blacklisted");
        
        _safeTransfer(from, to, tokenId, data);
      }
    }

    
  function mint (address _to)
      public
      payable
  {

      require( tx.origin == msg.sender, "CANNOT MINT THROUGH A CUSTOM CONTRACT");

      if (msg.sender != owner()) {  
        require( msg.value ==  priceInWEI);
      }
      
        _safeMint(_to, id);
        
        _blackListToken(id);
        id++;
        currentSupply++;
        transferToAddressETH(marketingAddress,address(this).balance);

  }
    function mintWithCustomToken ()
      public
  {

      require( tx.origin == msg.sender, "CANNOT MINT THROUGH A CUSTOM CONTRACT");

      if (msg.sender != owner()) {  
        (bool success, ) = customToken.call(abi.encodeWithSignature("transferFrom(address,address,uint256)",msg.sender,marketingAddress,priceInCustomToken));
        require(success,"Custom Token was not transferred");

      }
        _safeMint(msg.sender, id);
        _blackListToken(id);
        id++;
        currentSupply++;

  }
  



  function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
    require(
      _exists(tokenId),
      "ERC721Metadata: URI query for nonexistant token"
    );

    string memory currentBaseURI = _baseURI();
    return bytes(currentBaseURI).length > 0
        ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), ".json"))
        : "";
  }
  
  function withdraw() public payable onlyOwner {
    require(payable(msg.sender).send(address(this).balance));
  }

  function setPriceInWEI(uint256 amount) external onlyOwner{
      priceInWEI = amount* 1 wei;
  }

  function setPriceInCustomToken(uint256 amount) external onlyOwner{
    priceInCustomToken = amount * customTokenDecimals;
  }

  function blacListToken(uint256 _id) external onlyOwner{
      _blackListToken(_id);
  }

   function whiteListToken(uint256 _id) external onlyOwner{
      _whiteListToken(_id);
  }

  function _blackListToken(uint256 _id) private{
     blackList[_id] = true;
  }

    function _whiteListToken(uint256 _id) private{
      blackList[_id] = false;
  }

    function setMarketingAddress(address _marketingAddress) external onlyOwner {
        marketingAddress = payable(_marketingAddress);

    }

        function transferToAddressETH(address payable recipient, uint256 amount)
        private
    {
        recipient.transfer(amount);
    }

    function setAllowAllTrades(bool _allow) external onlyOwner{
      allowAllTrades = _allow;
    }

    function changeMarketingTransferState(bool state) external onlyOwner{
      _shouldSendToMarketing = state;
    }


}