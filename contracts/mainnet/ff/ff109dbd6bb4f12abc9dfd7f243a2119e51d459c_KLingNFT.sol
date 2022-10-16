//SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "./ERC721Enumerable.sol";
import "./Ownable.sol";

contract KLingNFT is ERC721Enumerable, Ownable {
    using Strings for uint256;

    address public feeAddress;
    string public baseURI;
    string public baseExtension = ".json";
    uint256 public minPrice = 0.01 ether;
    uint256 public maxPrice = 1 ether;
    uint256 public maxSupply = 19800;

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _initBaseURI
    ) ERC721(_name, _symbol) {
        setBaseURI(_initBaseURI);
        feeAddress = msg.sender;
    }

    // internal
    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    // public
    function mint(address _to, uint256 tokenId) public payable {
        require(tokenId > 0);
        require(tokenId <= maxSupply);
        require(msg.value >= minPrice && msg.value <= maxPrice, "Price out of range");

        payable(feeAddress).transfer(msg.value);
        _safeMint(_to, tokenId);
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
        return
            bytes(currentBaseURI).length > 0
                ? string(
                    abi.encodePacked(
                        currentBaseURI,
                        tokenId.toString(),
                        baseExtension
                    )
                )
                : "";
    }

    //only owner
    function setMinPrice(uint256 _newCost) public onlyOwner {
        minPrice = _newCost;
    }

    function setMaxPrice(uint256 _newCost) public onlyOwner {
        maxPrice = _newCost;
    }

    function setFeeAddress(address _newFeeAddress) public onlyOwner {
        feeAddress = _newFeeAddress;
    }

    function setmaxMintAmount(uint256 _newmaxMintAmount) public onlyOwner {
        maxSupply = _newmaxMintAmount;
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    function setBaseExtension(string memory _newBaseExtension)
        public
        onlyOwner
    {
        baseExtension = _newBaseExtension;
    }

    function withdraw() public payable onlyOwner {
        (bool success, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(success);
    }
}