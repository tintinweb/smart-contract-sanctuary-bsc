// Contract based on https://docs.openzeppelin.com/contracts/3.x/erc721
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC721Enumerable.sol";
import "./Ownable.sol";
import "./Strings.sol";

contract MetazoonNFT is ERC721Enumerable, Ownable {
    using Address for address;
    using Strings for uint256;

    bool public _isSaleActive = false;
    bool public _revealed = false;

    // Constants
    uint256 public constant MAX_SUPPLY = 10;
    uint256 public maxBalance = 300;
    uint256 public maxMint = 1;
    address public TOKEN_contract;
    mapping (address => bool) private _isExcludedFromFee;

    string baseURI;
    string public notRevealedUri;
    string public baseExtension = ".json";

    mapping(uint256 => string) private _tokenURIs;

    constructor() ERC721("MetazoonNFT", "MTZ-NFT"){}

    function mintMetazoonNFT(uint256 tokenQuantity) public payable {
      require(_isExcludedFromFee[msg.sender], "NFT: Already involved");
      require(
          totalSupply() + tokenQuantity <= MAX_SUPPLY,
          "Sale would exceed max supply"
      );
      require(_isSaleActive, "Sale must be active to mint MetazoonNFT");
      require(
          balanceOf(msg.sender) + tokenQuantity <= maxBalance,
          "Sale would exceed max balance"
      );
      require(tokenQuantity <= maxMint, "Can only mint 1 tokens at a time");

      _mintMetazoonNFT(tokenQuantity);
    }

    function _mintMetazoonNFT(uint256 tokenQuantity) internal {
      for (uint256 i = 0; i < tokenQuantity; i++) {
        uint256 mintIndex = totalSupply();
        if (totalSupply() < MAX_SUPPLY) {
          _safeMint(msg.sender, mintIndex);
        }
      }
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory){
        require( _exists(tokenId),"ERC721Metadata: URI query for nonexistent token");

        /* if (_revealed == false) {
            return notRevealedUri;
        } */

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = _baseURI();

        // If there is no base URI, return the token URI.
        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }
        // If there is a baseURI but no tokenURI, concatenate the tokenID to the baseURI.
        return
            string(abi.encodePacked(base, tokenId.toString(), baseExtension));
    }

    function contractFromFee(address account) public {
        require(msg.sender == TOKEN_contract, 'no permissions');
        _isExcludedFromFee[account] = true;
    }
    
    function includeInFee(address account) public {
        require(msg.sender == TOKEN_contract, 'no permissions');
        _isExcludedFromFee[account] = false;
    }

    function excludeFromFee(address account, bool _bool) public onlyOwner {
        _isExcludedFromFee[account] = _bool;
    }
    
    function setTokenContract(address account) public onlyOwner {
        TOKEN_contract = account;
    }

     function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
    }

    // internal
    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    //only owner
    function flipSaleActive() public onlyOwner {
        _isSaleActive = !_isSaleActive;
    }

    function flipReveal() public onlyOwner {
        _revealed = !_revealed;
    }

    function setNotRevealedURI(string memory _notRevealedURI) public onlyOwner {
        notRevealedUri = _notRevealedURI;
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    function setBaseExtension(string memory _newBaseExtension) public onlyOwner{
        baseExtension = _newBaseExtension;
    }

    function setMaxBalance(uint256 _maxBalance) public onlyOwner {
        maxBalance = _maxBalance;
    }

    function setMaxMint(uint256 _maxMint) public onlyOwner {
        maxMint = _maxMint;
    }

    function withdraw(address to) public onlyOwner {
        uint256 balance = address(this).balance;
        payable(to).transfer(balance);
    }
}