// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "./Counters.sol";
import "./IERC20.sol";
import "./ERC721Enumerable.sol";

contract PhoenixNFT is ERC721Enumerable  {
    IERC20 private Wallet;
    address cashier;
    address owner;
    bool public transferAllowance;
    uint8 CodeLength;

    struct NFTProducts {
        string name;
        uint256 busdprice;
        uint256 fuel;
        string tokenuri;
        bool available;
    }

    struct NFTData {
        string name;
        uint256 busdprice;
        uint256 fuel;
        string tokenuri;
        string code;
    }

    struct CodeNFT {
        uint256 tokenid;
        bool available;
    }

    // Fire  (1500 BUSD) ( Lifetime NFT Stacking ) 10400 weeks = 72800 days; 
    // Water (1000 BUSD) ( 3 Years ) 156 weeks = 1092 days;
    // Metal (500 BUSD) ( 1,5 Year ) 78 weeks = 546 days;
    // Wood (250 BUSD) ( 1 Year ) 52 weeks = 364 days;
    // Earth (120 BUSD) ( 6 Months ) 26 weeks = 182 days;

    // 0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee   BUSD
    // 0x69a60Aa4fd64B6350B45072D2265633BDd44b6d9   SPA

    uint256[] _productids;
    mapping(uint256 => NFTProducts) _products;
    mapping(uint256 => NFTData) _nfts;
    mapping(string => CodeNFT) _codes;

    using Counters for Counters.Counter;
    Counters.Counter private counterIDs;

    constructor(IERC20 payment_token) ERC721("Phoenix NFT", "PNF") {
        Wallet = IERC20(payment_token); // BUSD
        owner = msg.sender;
        transferAllowance = false;
        CodeLength = 10;
    }

    modifier onlyOwner() {
       CheckOwner();
        _;
    }

    function CheckOwner() internal view virtual {
        require((owner == msg.sender), "ACCESS_DENIED");
    }

    event BuyNFT(address _buyer, uint256 _price);

    function random(uint256 number, uint256 counter) public view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, msg.sender, counter))) % number;
    }

    function CodeGenerator() internal view returns (string memory) {
        bytes memory randomWord = new bytes(CodeLength);
        bytes memory chars = new bytes(26);
        chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
        for (uint256 i = 0; i < CodeLength; i++) {
            uint256 randomNumber = random(26, i);
            randomWord[i] = chars[randomNumber];
        }
        return string(randomWord);
    }

    function BuyItem(uint32 _productid) external payable returns (uint256 tokenID, string memory codenft) {
        require(_products[_productid].available, "Product not found");
        // require(Wallet.transferFrom(msg.sender, cashier, _products[_productid].busdprice), "contract: cannot paid using BUSD");
        require(Wallet.transferFrom(msg.sender, address(this), _products[_productid].busdprice), "Payment BUSD Fail");

        bool codevalid = false;
        while(!codevalid) {
            codenft = CodeGenerator();
            if(!_codes[codenft].available) codevalid = true;
        }

        tokenID = counterIDs.current();
        counterIDs.increment();
        _mint(msg.sender, tokenID);
        _codes[codenft] = CodeNFT(tokenID, true);
        _nfts[tokenID] = NFTData({
                name: _products[_productid].name,
                busdprice: _products[_productid].busdprice,
                fuel: _products[_productid].fuel,
                tokenuri: _products[_productid].tokenuri,
                code: codenft
            });
        
        emit BuyNFT(msg.sender, tokenID);
        return (tokenID, codenft);
    }

    function getTokenDataIDByCode(string memory _code) external view returns (NFTData memory) {
        require(_codes[_code].available, "Code is not found");
        return getTokenData(_codes[_code].tokenid);
    }

    function RescueBusdFund(address addr) external onlyOwner {
        uint256 total = Wallet.balanceOf(address(this));
        Wallet.transferFrom(address(this), addr, total);
    }

    function tokenURI(uint256 tokenID) public view virtual override returns (string memory) {
        require(_exists(tokenID), "ERC721Metadata: URI query for nonexistent token");
        return _nfts[tokenID].tokenuri;
    }

    function transferFrom(address from, address to, uint256 tokenId) public virtual override {
        require(transferAllowance, "Token unable to transfer");
        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721: caller is not token owner or approved");
        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public virtual override {
        require(transferAllowance, "Token unable to transfer");
        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721: caller is not token owner or approved");
        _safeTransfer(from, to, tokenId, "");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public virtual override {
        require(transferAllowance, "Token unable to transfer");
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner or approved");
        _safeTransfer(from, to, tokenId, data);
    }

    function OwnerTokenIds(address addr) public view returns (uint256[] memory) {
        uint256 nftCount = balanceOf(addr);
        uint256[] memory tokenIds = new uint256[](nftCount);
        for (uint256 i; i < nftCount; i++) {
            tokenIds[i] = tokenOfOwnerByIndex(addr, i);
        }
        return tokenIds;
    }

    function ownerOf(uint256 _tokenid) public view virtual override returns (address) {
        address addr = _ownerOf(_tokenid);
        require(addr != address(0), "ERC721: invalid token ID");
        return addr;
    }

    function getTokenData(uint256 _tokenid) public view returns (NFTData memory) {
        require(_exists(_tokenid), "ERC721Metadata: URI query for nonexistent token");
        if(ownerOf(_tokenid) == msg.sender) {
            return _nfts[_tokenid];
        } else {
            NFTData memory result = _nfts[_tokenid];
            result.code = "- forbidden -";
            return result;
        }
    }

    /*---------------------
    ** Owner function
    ---------------------*/
    function setProducts(uint256 id, string memory name, uint256 busdprice, uint256 fuel, string memory ipfs) public onlyOwner {
        if(!_products[id].available) _productids.push(id);
        _products[id] = NFTProducts({
                            name : name,
                            busdprice : busdprice,
                            fuel : fuel,
                            tokenuri : ipfs,
                            available: true
                        });
    }

    function removeProducts(uint256 id) external onlyOwner {
        require(_products[id].available, "Products does not exist.");
        for(uint i = 0; i < _productids.length; i++) {
            if(_productids[i] == id) {
                _productids[i] = _productids[_productids.length - 1];
            }
        }
        _productids.pop();
        delete _products[id];
    }

    function getProductDetails(uint256 index) external view returns (NFTProducts memory) {
        return _products[index];
    }

    function getAllProducts() external view returns (NFTProducts[] memory) {
        NFTProducts[] memory id = new NFTProducts[](_productids.length);
        for (uint i = 0; i < _productids.length; i++) {
            NFTProducts storage product_data = _products[_productids[i]];
            id[i] = product_data;
        }
        return id;
    }

    function getProductIDs() private view returns (uint256[] memory) {
        return _productids;
    }

    // function setCashier(address addr) public onlyOwner {
    //     cashier = addr;
    // }

    // function showCashier() public view onlyOwner returns (address) {
    //     return cashier;
    // }

    function setAllowTransfer(bool value) external onlyOwner {
        transferAllowance = value;
    }
 }