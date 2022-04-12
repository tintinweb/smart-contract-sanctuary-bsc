// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC721Enumerable.sol";
import "./Ownable.sol";
import "./PreSaleManager.sol";
import "./PublicSaleManager.sol";
import "./LaunchpadSaleManager.sol";
import "./FundSaleManager.sol";
import "./WhitelistMerkle.sol";

contract Gopher is
    Ownable,
    ERC721Enumerable,
    PreSaleManager,
    PublicSaleManager,
    LaunchpadSaleManager,
    FundSaleManager,
    WhitelistMerkle
{
    using Strings for uint256;

    // string public constant ipfs = "QmVqHFqSgw9kKLDZfcjGs5WGg1dtrQVzagX2kLgMfY2YfX";
    uint256 public constant TOTAL_MAX_QTY = 10000;
    uint256 private constant MAX_QTY_PER_TX = 10;
    string private baseURI = "www.gopher.com";
    address private constant fundAddress =
        0x39015234E8e6e83e61acc7F3A513D798D2A06e4b; // Gopher

    constructor() ERC721("Coder Of Gopher", "COG") {}

    function isCorrectPayment(uint256 price, uint256 _mintQty) private view {
        require(price > 0, "val err");
        require(price * _mintQty == msg.value, "val err");
    }

    function isCorrectMintedQty(uint256 _mintQty) private view {
        require(_mintQty > 0, "qty err");
        require(_mintQty <= MAX_QTY_PER_TX, "limt err");
        require(_mintQty + totalSupply() <= totalMaxSupply(), "qty err");
    }

    function getPrice() private view returns (uint256) {
        if (isPublicSalesActivated()) {
            return getPublicSalesPrice();
        }
        return getPreSalesPrice();
    }

    function totalSupply() public view override returns (uint256) {
        return
            getPreSalesMintedQty() +
            getPublicSalesMintedQty() +
            getLaunchpadSalesMintedQty() +
            getFundMintedQty();
    }

    function totalMaxSupply() public view returns (uint256) {
        return
            getPreSalesMaxQty() +
            getPublicSalesMaxQty() +
            getLaunchpadSalesMaxQty() +
            getFundMaxQty();
    }

    function preSalesMint(uint256 _mintQty, bytes32[] calldata _proof)
        external
        payable
        nonReentrant
        isPreSalesActive
        isValidMerkleProof(_proof)
        isCorrectPreSalesQty(msg.sender, _mintQty)
    {
        isCorrectMintedQty(_mintQty);
        isCorrectPayment(getPrice(), _mintQty);
        require(
            getPreSalesMintedQty() + _mintQty <= getPreSalesMaxQty(),
            "qty err"
        );

        require(tx.origin == msg.sender, "addr err");

        for (uint256 i = 1; i <= _mintQty; i++) {
            _safeMint(msg.sender, totalSupply() + i);
        }
        updatePreSales(msg.sender, _mintQty);
    }

    function publicSalesMint(uint256 _mintQty)
        external
        payable
        nonReentrant
        isPublicSalesActive
        isCorrectPublicSalesQty(msg.sender, _mintQty)
    {
        isCorrectMintedQty(_mintQty);
        isCorrectPayment(getPrice(), _mintQty);
        require(
            getPreSalesMintedQty() + getPublicSalesMintedQty() + _mintQty <=
                getPreSalesMaxQty() + getPublicSalesMaxQty(),
            "qty err"
        );

        require(tx.origin == msg.sender, "addr err");

        for (uint256 i = 1; i <= _mintQty; i++) {
            _safeMint(msg.sender, totalSupply() + i);
        }
        updatePublicSales(msg.sender, _mintQty);
    }

    // lanched mint
    function mintTo(address _to, uint256 _mintQty)
        external
        payable
        onlyLaunchpad
        nonReentrant
        isCorrectLaunchnapQty(_to, _mintQty)
    {
        isCorrectMintedQty(_mintQty);
        isCorrectPayment(getLaunchpadSalesPrice(), _mintQty);
        require(!isLaunchpadSalesActivated(), "state err");
        require(_to != address(0), "addr err");
        for (uint256 i = 1; i <= _mintQty; i++) {
            _safeMint(_to, totalSupply() + i);
        }
        updateLaunchnapSales(_to, _mintQty);
    }

    // fundMint end sale
    function fundMint() public onlyOwner nonReentrant {
        require(getFundMaxMintPerTx() > 0, "fund qty err");

        if (getFundMintedQty() + getFundMaxMintPerTx() <= getFundMaxQty()) {
            for (uint256 i = 1; i <= getFundMaxMintPerTx(); i++) {
                _safeMint(getFundNFTAddress(), totalSupply() + i);
            }
            updateFundMint(getFundMaxMintPerTx());
        } else {
            uint256 canMintQty = 0;
            for (uint256 i = 1; i <= getFundMaxMintPerTx(); i++) {
                if (getFundMintedQty() + canMintQty > getFundMaxQty()) {
                    break;
                }
                canMintQty += 1;
                _safeMint(getFundNFTAddress(), totalSupply() + i);
            }
            updateFundMint(canMintQty);
        }
    }

    //read metadata
    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(tokenId <= totalSupply());
        string memory currentBaseURI = _baseURI();
        return
            bytes(currentBaseURI).length > 0
                ? string(abi.encodePacked(currentBaseURI, tokenId.toString()))
                : ".json";
    }

    function updateSaleMaxQty(
        uint256 _addPreMax,
        uint256 _addPublicMax,
        uint256 _addLaunchpadMax
    ) public onlyOwner {
        require(
            _addPreMax >= 0 && _addPublicMax >= 0 && _addLaunchpadMax >= 0,
            "qty err"
        );
        require(_addPreMax + _addPublicMax + _addLaunchpadMax > 0, "qty err");
        require(
            _addPreMax + _addPublicMax + _addLaunchpadMax + totalMaxSupply() <=
                TOTAL_MAX_QTY,
            "exc max"
        );
        updatePreSaleMaxQty(_addPreMax);
        updatePublicSaleMaxQty(_addPublicMax);
        updateLaunchpadSaleMaxQty(_addLaunchpadMax);
    }

    function updateFundMaxQty(uint256 _addFundMax) public onlyOwner {
        require(_addFundMax > 0, "qty err");
        require(
            _addFundMax + totalMaxSupply() <= TOTAL_MAX_QTY,
            "Exceed max qty"
        );
        _updateFundSaleMaxQty(_addFundMax);
    }

    //write metadata
    function setURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    function withdraw() public onlyOwner nonReentrant {
        uint256 balance = address(this).balance;
        Address.sendValue(payable(fundAddress), balance);
    }
}