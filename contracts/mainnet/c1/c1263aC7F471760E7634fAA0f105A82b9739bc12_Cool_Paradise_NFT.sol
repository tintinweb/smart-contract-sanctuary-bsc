// SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

import "./ERC721.sol";
import "./ERC721Enumerable.sol";
import "./Ownable.sol";
import "./ReentrancyGuard.sol";
import "./Strings.sol";

contract Cool_Paradise_NFT is ERC721, ERC721Enumerable, Ownable, ReentrancyGuard {
    using Strings for uint256;

    uint256 public PRICE = 0.5 ether;
    uint256 public WL_PRICE = 0 ether;

    uint256 public MAX_SUPPLY = 5000;
    uint256 public LAUNCH_MAX_SUPPLY = 3500;
    uint256 public MAX_WL = 500;

    uint256 public LAUNCH_SUPPLY;
    address public LAUNCHPAD;
    
    uint256 public MAX_MINT = 20;
    uint256 public MAX_MINT_WL = 10;

    string private BASE_URI = 'https://cool-paradise.space/collection/';

    bool public IS_SALE_ACTIVE = true;
    bool public REVEAL_STATUS = true;

    uint256 public mint_owner = 500;
    uint256 public mint_owner_supply = 0;
    uint256 public mint_wl_supply = 0;

    mapping(address => uint256) _allowListClaimed;

    modifier onlyLaunchpad() {
        require(LAUNCHPAD != address(0), "launchpad address must set");
        require(msg.sender == LAUNCHPAD, "must call by launchpad");
    _;
    }

    constructor(address launchpad) ERC721("Cool_Paradise_NFT", "COOL") {
        LAUNCHPAD = launchpad;
    }
    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }
    
    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return BASE_URI;
    }

    function setPrice(uint256 customPrice) external onlyOwner {
        PRICE = customPrice;
    }

    function setBaseURI(string memory customBaseURI_) external onlyOwner {
        BASE_URI = customBaseURI_;
    }

    function setMaxMintPerTx(uint256 maxMintPerTx) external onlyOwner {
        MAX_MINT = maxMintPerTx;
    }

    function setSaleActive(bool saleIsActive) external onlyOwner {
        IS_SALE_ACTIVE = saleIsActive;
    }

    function setMintOwner(uint256 MintOwner) external onlyOwner {
        mint_owner = MintOwner;
    }

    function setRevealStatus(bool revealStatus) external onlyOwner {
        REVEAL_STATUS = revealStatus;
    }

    function allowListClaimedBy(address owner) external view returns (uint256){
        require(owner != address(0), "Zero address not on Allow List");
        
        return _allowListClaimed[owner];
    }    

    modifier mintCompliance(uint256 _mintAmount) {
        require(_mintAmount > 0 && _mintAmount <= MAX_MINT, "Invalid mint amount!");
        require(totalSupply() + _mintAmount <= MAX_SUPPLY, "Max supply exceeded!");
        _;
    }

    function mint(uint256 _mintAmount) public payable mintCompliance(_mintAmount) {
        require(IS_SALE_ACTIVE, "Sale is not active!");
        uint256 price = PRICE * _mintAmount;
        require(msg.value >= price, "Insufficient funds!");
        for (uint i=0; i < _mintAmount; i++){
            _safeMint(msg.sender, ERC721Enumerable.totalSupply() + 1);
        }
        
    }

    function mintTo(address to, uint size) external onlyLaunchpad {
        require(to != address(0), "can't mint to empty address");
        require(size > 0, "size must greater than zero");
        require(LAUNCH_SUPPLY + size <= LAUNCH_MAX_SUPPLY, "max supply reached");

        for (uint256 i=1; i <= size; i++) {
            _mint(to, ERC721Enumerable.totalSupply() + i);
            LAUNCH_SUPPLY++;
        }
    }

    function mintWL(uint256 _mintAmount) public payable mintCompliance(_mintAmount) {
        require(IS_SALE_ACTIVE, "Sale is not active!");
        require(_allowListClaimed[msg.sender] + _mintAmount <= MAX_MINT_WL, "Exceeds supply of presale you can mint.");
        require(mint_wl_supply + _mintAmount < MAX_WL, "Whitelist mint limited.");
        for (uint i=0; i < _mintAmount; i++){
            _safeMint(msg.sender, ERC721Enumerable.totalSupply() + 1);
        }
        _allowListClaimed[msg.sender] += _mintAmount;
        mint_wl_supply += _mintAmount;
    }

    function mintOwner(address _to, uint256 _mintAmount) public onlyOwner {
        require(mint_owner_supply + _mintAmount <= mint_owner, "Max owner supply exceeded!");
        for (uint i=0; i < _mintAmount; i++){
            _safeMint(_to, ERC721Enumerable.totalSupply() + 1);
        }
        mint_owner_supply += _mintAmount;
    }

    function withdraw() public onlyOwner {
        uint balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }
    
    function getMaxLaunchpadSupply() view public returns (uint256) {
        return LAUNCH_MAX_SUPPLY;
    }

    function getLaunchpadSupply() view public returns (uint256) {
        return LAUNCH_SUPPLY;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory) 
    {
        require(_exists(tokenId), "Non-existent token!");
        if(REVEAL_STATUS) {
            string memory baseURI = BASE_URI;
            return string(abi.encodePacked(baseURI, Strings.toString(tokenId), ".json"));
        } else {
            return 'https://ipfs.io/ipfs/QmQzyd6tf5dD6fvA6BtMYZZp2KM43jVegnXVdSmhwcwsBy';
        }
    }
}