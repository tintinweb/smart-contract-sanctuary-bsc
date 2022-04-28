// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC721Enumerable.sol";
import "./Ownable.sol";
import "./PreSaleManager.sol";
import "./PublicSaleManager.sol";
import "./LaunchpadSaleManager.sol";
import "./FundSaleManager.sol";
import "./WhitelistMerkle.sol";

contract GOS is
    Ownable,
    ERC721Enumerable,
    PreSaleManager,
    PublicSaleManager,
    LaunchpadSaleManager,
    FundSaleManager,
    WhitelistMerkle
{
    using Strings for uint256;

    uint256 public constant TOTAL_MAX_QTY = 10000;
    uint256 private constant MAX_QTY_PER_TX = 5;
    string private baseURI =
        "https://gameofspecters.mypinata.cloud/ipfs/QmRpTEAe7zFupy2NRipXdnxQCnKcnFDxc74ojTsfAuv7nK/";
    address public fundAddress = 0x875cFDfcF479a80F0C0a3E5013208A1a580FE0C6;

    event SetURI(string indexed _baseURI);
    event Withdraw(uint256 indexed _value);
    event PreSalesMint(address indexed _addr, uint256 indexed _mintQty);
    event PublicSalesMint(address indexed _addr, uint256 indexed _mintQty);
    event MintTo(address indexed _addr, uint256 indexed _mintQty);
    event FundMint(address indexed _addr, uint256 indexed _mintQty);
    event UpdateFundAddress(address indexed _newAddr);

    constructor() ERC721("Game Of Specters", "GOS") {}

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

        require(tx.origin == msg.sender, "addr err");
        for (uint256 i = 1; i <= _mintQty; i++) {
            _safeMint(msg.sender, totalSupply() + 1);
            _updatePreSales(msg.sender, 1);
        }
        emit PreSalesMint(msg.sender, _mintQty);
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
            _safeMint(msg.sender, totalSupply() + 1);
            _updatePublicSales(msg.sender, 1);
        }
        emit PublicSalesMint(msg.sender, _mintQty);
    }

    // lanched mint
    function mintTo(address _to, uint256 _mintQty)
        external
        onlyLaunchpad
        nonReentrant
        isCorrectLaunchnapQty(_to, _mintQty)
    {
        isCorrectMintedQty(_mintQty);
        require(isLaunchpadSalesActivated(), "state err");
        require(_to != address(0), "addr err");
        for (uint256 i = 1; i <= _mintQty; i++) {
            _safeMint(_to, totalSupply() + 1);
            _updateLaunchpadSales(_to, 1);
        }
        emit MintTo(_to, _mintQty);
    }

    // fundMint end sale
    function fundMint() public onlyOwner nonReentrant {
        require(getFundMaxMintPerTx() > 0, "fund qty err");
        uint256 mintQty = 0;
        for (uint256 i = 1; i <= getFundMaxMintPerTx(); i++) {
            if (getFundMintedQty() + 1 > getFundMaxQty()) {
                break;
            }
            _safeMint(getFundNFTAddress(), totalSupply() + 1);
            _updateFundMint(1);
            mintQty += 1;
        }
        emit FundMint(getFundNFTAddress(), mintQty);
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
                ? string(
                    abi.encodePacked(
                        currentBaseURI,
                        tokenId.toString(),
                        ".json"
                    )
                )
                : "";
    }

    function updateSaleMaxQty(
        uint256 _addPreMax,
        uint256 _addPublicMax,
        uint256 _addLaunchpadMax
    ) public onlyOwner {
        require(_addPreMax + _addPublicMax + _addLaunchpadMax > 0, "qty err");
        require(
            _addPreMax + _addPublicMax + _addLaunchpadMax + totalMaxSupply() <=
                TOTAL_MAX_QTY,
            "exc max"
        );

        if (_addPreMax > 0) {
            _updatePreSaleMaxQty(_addPreMax);
        }

        if (_addPublicMax > 0) {
            _updatePublicSaleMaxQty(_addPublicMax);
        }

        if (_addLaunchpadMax > 0) {
            _updateLaunchpadSaleMaxQty(_addLaunchpadMax);
        }
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
        emit SetURI(_newBaseURI);
    }

    function withdraw() public onlyOwner nonReentrant {
        uint256 balance = address(this).balance;
        payable(fundAddress).transfer(balance);
        emit Withdraw(balance);
    }

    function updateFundAddress(address _new) public onlyOwner {
        require(fundAddress != _new, "same addr");
        fundAddress = _new;
        emit UpdateFundAddress(_new);
    }
}