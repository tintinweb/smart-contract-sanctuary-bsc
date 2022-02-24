// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC721Enumerable.sol";
import "./Ownable.sol";

interface Token {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);    

}

contract MainNFT is ERC721Enumerable, Ownable {
  uint256 public mintPrice = 3.0 ether;

  uint256 private reserveAtATime = 50;
  address private tokenAddress = 0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684;
  uint256 private reservedCount = 0;
  uint256 private maxReserveCount = 300;

  string _baseTokenURI;

  bool public isActive = false;
  bool public isAllowListActive = false;
  bool public isClosedMintForever = false;

  uint256 public maximumMintSupply = 30000;
  uint256 public maximumAllowedTokensPerPurchase = 20;
  uint256 public maximumAllowedTokensPerWallet = 20;
  uint256 public allowListMaxMint = 200;
  Token token;


  mapping(address => bool) private _allowList;
  mapping(address => uint256) private _allowListClaimed;

  event AssetMinted(uint256 tokenId, address sender);
  event SaleActivation(bool isActive);

  constructor(string memory baseURI) ERC721("Bit Royal", "BR") {
    token = Token(tokenAddress);
    // token.approve(address(this), uint256(0) - 1);
    setBaseURI(baseURI);
  }

  modifier saleIsOpen {
    require(totalSupply() <= maximumMintSupply, "Sale has ended.");
    _;
  }

  

  function setMaximumAllowedTokens(uint256 _count) public onlyOwner {
    maximumAllowedTokensPerPurchase = _count;
  }

  function setMaximumAllowedTokensPerWallet(uint256 _count) public onlyOwner {
    maximumAllowedTokensPerWallet = _count;
  }

  function setActive(bool val) public onlyOwner {
    isActive = val;
    emit SaleActivation(val);
  }

  function setMaxMintSupply(uint256 maxMintSupply) external  onlyOwner {
    maximumMintSupply = maxMintSupply;
  }

  function setIsAllowListActive(bool _isAllowListActive) external onlyOwner {
    isAllowListActive = _isAllowListActive;
  }

  function setAllowListMaxMint(uint256 maxMint) external  onlyOwner {
    allowListMaxMint = maxMint;
  }

  function addToAllowList(address[] calldata addresses) external onlyOwner {
    for (uint256 i = 0; i < addresses.length; i++) {
      require(addresses[i] != address(0), "Can't add a null address");
      _allowList[addresses[i]] = true;
      _allowListClaimed[addresses[i]] > 0 ? _allowListClaimed[addresses[i]] : 0;
    }
  }

  function checkIfOnAllowList(address addr) external view returns (bool) {
    return _allowList[addr];
  }

  function removeFromAllowList(address[] calldata addresses) external onlyOwner {
    for (uint256 i = 0; i < addresses.length; i++) {
      require(addresses[i] != address(0), "Can't add a null address");
      _allowList[addresses[i]] = false;
    }
  }

  function allowListClaimedBy(address owner) external view returns (uint256){
    require(owner != address(0), 'Zero address not on Allow List');
    return _allowListClaimed[owner];
  }

  function setReserveAtATime(uint256 val) public onlyOwner {
    reserveAtATime = val;
  }

  function setMaxReserve(uint256 val) public onlyOwner {
    maxReserveCount = val;
  }

  function setPrice(uint256 _price) public onlyOwner {
    mintPrice = _price;
  }

  function setBaseURI(string memory baseURI) public onlyOwner {
    _baseTokenURI = baseURI;
  }

  function getMaximumAllowedTokens() public view onlyOwner returns (uint256) {
    return maximumAllowedTokensPerPurchase;
  }

  function getPrice() external view returns (uint256) {
    return mintPrice;
  }

  function getIsClosedMintForever() external view returns (bool) {
    return isClosedMintForever;
  }

  function setIsClosedMintForever() external onlyOwner {
    isClosedMintForever = true;
  }

  function getReserveAtATime() external view returns (uint256) {
    return reserveAtATime;
  }

  function getTotalSupply() external view returns (uint256) {
    return totalSupply();
  }

  function getContractOwner() public view returns (address) {
    return owner();
  }

  function _baseURI() internal view virtual override returns (string memory) {
    return _baseTokenURI;
  }

  function reserveNft() public onlyOwner {
    require(reservedCount <= maxReserveCount, "Max Reserves taken already!");
    uint256 supply = totalSupply();
    uint256 i;

    for (i = 0; i < reserveAtATime; i++) {
      emit AssetMinted(supply + i, msg.sender);
      _safeMint(msg.sender, supply + i);
      reservedCount++;
    }
  }

  function reserveToCustomWallet(address _walletAddress, uint256 _count) public onlyOwner {
    for (uint256 i = 0; i < _count; i++) {
      emit AssetMinted(totalSupply(), _walletAddress);
      _safeMint(_walletAddress, totalSupply());
    }
  }

  function mint(address _to, uint256 _count, uint256 price) public saleIsOpen {
    if (msg.sender != owner()) {
      require(isActive, "Sale is not active currently.");
    }

    require(totalSupply() + _count <= maximumMintSupply, "Total supply exceeded.");
    require(totalSupply() <= maximumMintSupply, "Total supply spent.");
    
    require(!isClosedMintForever, "Mint Closed Forever");

    require(price >= mintPrice * _count, "Insuffient ETH amount sent.");

    token.transferFrom(msg.sender, address(this), price);

    //token.transferFrom(msg.sender, address(this), price);
      
    for (uint256 i = 0; i < _count; i++) {
      emit AssetMinted(totalSupply(), _to);
      _safeMint(_to, totalSupply());
    }
  }

  function batchReserveToMultipleAddresses(uint256 _count, address[] calldata addresses) external onlyOwner {
    uint256 supply = totalSupply();

    require(supply + _count <= maximumMintSupply, "Total supply exceeded.");
    require(supply <= maximumMintSupply, "Total supply spent.");

    for (uint256 i = 0; i < addresses.length; i++) {
      require(addresses[i] != address(0), "Can't add a null address");

      for(uint256 j = 0; j < _count; j++) {
        emit AssetMinted(totalSupply(), addresses[i]);
        _safeMint(addresses[i], totalSupply());
      }
    }
  }

  function preSaleMint(uint256 _count) public payable saleIsOpen {
    require(isAllowListActive, 'Allow List is not active');
    require(_allowList[msg.sender], 'You are not on the Allow List');
    require(totalSupply() < maximumMintSupply, 'All tokens have been minted');
    require(_count <= allowListMaxMint, 'Cannot purchase this many tokens');
    require(_allowListClaimed[msg.sender] + _count <= allowListMaxMint, 'Purchase exceeds max allowed');
    require(msg.value >= mintPrice * _count, 'Insuffient ETH amount sent.');
    require(!isClosedMintForever, 'Mint Closed Forever');

    for (uint256 i = 0; i < _count; i++) {
      _allowListClaimed[msg.sender] += 1;
      emit AssetMinted(totalSupply(), msg.sender);
      _safeMint(msg.sender, totalSupply());
    }
  }

  function walletOfOwner(address _owner) external view returns(uint256[] memory) {
    uint tokenCount = balanceOf(_owner);
    uint256[] memory tokensId = new uint256[](tokenCount);

    for(uint i = 0; i < tokenCount; i++){
      tokensId[i] = tokenOfOwnerByIndex(_owner, i);
    }
    return tokensId;
  }

  function withdraw() external onlyOwner {
    uint balance = token.balanceOf(address(this));
    token.transfer(owner(), balance);
  }
}