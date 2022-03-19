// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "./ERC721Metadata.sol";
import "./Counters.sol";
import "./IERC2981.sol";

contract Lunicorns_3D is ERC721Metadata, IERC2981 {
    using Counters for Counters.Counter;

    // Max supply of NFTs
    uint256 public constant MAX_NFT_SUPPLY = 10_000;
    uint256 public constant NFT_ALLOCATED = 5_000;

    uint256 public MAX_NFT_IN_PURCHASE = 20;

    // Mint price is 0.1 BNB
    uint256 public MINT_PRICE = 0.1 ether;

    // Pending count
    uint256 public pendingCount = MAX_NFT_SUPPLY - NFT_ALLOCATED;


    // Start time for main drop
    uint256 public startTime = 0;

    uint256 public adminTax = 90;
    uint256 public reflectionTax = 10;
    uint256 public royaltiesTax = 2;

    // Total reflection balance
    uint256 public reflectionBalance;
    uint256 public totalDividend;
    mapping(uint256 => uint256) public lastDividendAt;

    // Minters
    mapping(uint256 => address) public minters;

    //Tax-Free Users
    mapping(address => uint256) public freeNft;

    // Total supply of NFTs
    uint256 public _totalSupply = NFT_ALLOCATED;

    // Pending Ids
    uint256[5001] private _pendingIds;

    IERC721Enumerable public lunicornsV1Contract;

    uint256 private priceTreshold1 = 7500;
    uint256 private priceTreshold2 = 9500;

    uint256 public priceStep1 = 0.1 ether;
    uint256 public priceStep2 = 0.2 ether;
    uint256 public priceStep3 = 0.3 ether;

    // Admin wallet
    address private devWallet;

    modifier periodStarted() {
        require(block.timestamp >= startTime && startTime != 0, "Period not started");
        _;
    }

    constructor(
        string memory _baseURI,
        address _devWallet,
        string memory _name,
        string memory _symbol,
        address _lunicornsV1Address
    ) ERC721Metadata(_name, _symbol, _baseURI) {
        devWallet = _devWallet;
        lunicornsV1Contract = IERC721Enumerable(_lunicornsV1Address);
    }

    function setStartTime(uint256 _startTime) external onlyOwner {
        require(_startTime > 0, "invalid _startTime");
        // require(_startTime > block.timestamp, "old start time");
        startTime = _startTime;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function purchase(uint256 numberOfNfts) external payable periodStarted {
        require(pendingCount > 0, "All minted");
        require(numberOfNfts > 0, "numberOfNfts cannot be 0");
        require(numberOfNfts <= MAX_NFT_IN_PURCHASE, "You may not buy more than MAX_NFT_IN_PURCHASE NFTs at once");
        require(totalSupply() + (numberOfNfts) <= MAX_NFT_SUPPLY,"sale already ended");
        require(_calculatePrice(numberOfNfts) == msg.value, "invalid ether value");
        freeNft[msg.sender] -= numberOfNfts - _calculateNftToBePayed(numberOfNfts);

        for (uint i = 0; i < numberOfNfts; i++) {
            _randomMint(msg.sender);
            _splitBalance(msg.value / numberOfNfts);
        }
    }

    function _calculatePrice(uint256 numberOfNfts) internal view returns (uint256) {
        return MINT_PRICE *  _calculateNftToBePayed(numberOfNfts);
    }

    function _calculateNftToBePayed(uint256 numberOfNfts) internal view returns (uint256) {
        uint256 payableNfts = 0;
        if (numberOfNfts > freeNft[msg.sender]) {
            payableNfts = numberOfNfts - freeNft[msg.sender];
        }

        return payableNfts;
    }

    function claimRewards() public {
        uint count = balanceOf(msg.sender);
        uint256 balance = 0;
        for (uint i = 0; i < count; i++) {
            uint tokenId = tokenOfOwnerByIndex(msg.sender, i);
            balance += getReflectionBalance(tokenId);
            lastDividendAt[tokenId] = totalDividend;
        }
        payable(msg.sender).transfer(balance);
    }

    function getReflectionBalances() public view returns (uint256) {
        uint count = balanceOf(msg.sender);
        uint256 total = 0;
        for (uint i = 0; i < count; i++) {
            uint tokenId = tokenOfOwnerByIndex(msg.sender, i);
            total += getReflectionBalance(tokenId);
        }
        return total;
    }

    function getMintedCounts() public view returns (uint256) {
        uint256 count = 0;
        for (uint i = 1; i <= MAX_NFT_SUPPLY; i++) {
            if (minters[i] == msg.sender) {
                count += 1;
            }
        }
        return count;
    }

    function claimReward(uint256 tokenId) public {
        require(
            ownerOf(tokenId) == _msgSender() || getApproved(tokenId) == _msgSender(),
            "Only owner or approved can claim rewards"
        );

        uint256 balance = getReflectionBalance(tokenId);
        payable(ownerOf(tokenId)).transfer(balance);
        lastDividendAt[tokenId] = totalDividend;
    }

    function getReflectionBalance(uint256 tokenId) public view returns (uint256) {
        return totalDividend - lastDividendAt[tokenId];
    }

    function _splitBalance(uint256 amount) internal {
        uint256 reflectionShare = (amount * reflectionTax) / 100;
        uint256 adminShare = (amount * adminTax) / 100;
        _reflectDividend(reflectionShare);
        payable(devWallet).transfer(adminShare);
    }

    function _reflectDividend(uint256 amount) internal {
        reflectionBalance = reflectionBalance + amount;
        totalDividend = totalDividend + (amount / totalSupply());
    }

    function _randomMint(address _to) internal returns (uint256) {
        require(totalSupply() < MAX_NFT_SUPPLY, "max supply reached");
        uint256 tokenId = _chooseTokenId();
        _totalSupply += 1;
        return _mintToken(_to, tokenId);
    }

    function _mintToken(address _to, uint256 _tokenId) internal returns (uint256) {
        minters[_tokenId] = _to;
        lastDividendAt[_tokenId] = totalDividend;
        _mint(_to, _tokenId);

        return _tokenId;
    }

    function _chooseTokenId() internal virtual returns (uint256) {
        uint256 index = (_getRandom() % pendingCount) + 1;
        return _popPendingAtIndex(index) + NFT_ALLOCATED;
    }

    function getPendingIndexById(
        uint256 tokenId,
        uint256 startIndex,
        uint256 totalCount
    ) external view returns (uint256) {
        for (uint256 i = 0; i < totalCount; i++) {
            uint256 pendingTokenId = _getPendingAtIndex(i + startIndex);
            if (pendingTokenId == tokenId) {
                return i + startIndex;
            }
        }
        revert("NFTInitialSeller: invalid token id(pending index)");
    }

    function _getPendingAtIndex(uint256 _index) internal view returns (uint256) {
        return _pendingIds[_index] + _index;
    }

    function _popPendingAtIndex(uint256 _index) internal returns (uint256) {
        uint256 tokenId = _getPendingAtIndex(_index);
        if (_index != pendingCount) {
            uint256 lastPendingId = _getPendingAtIndex(pendingCount);
            _pendingIds[_index] = lastPendingId - _index;
        }
        pendingCount--;
        return tokenId;
    }

    function _getRandom() internal view returns (uint256) {
        return
        uint256(
            keccak256(
                abi.encodePacked(block.difficulty, block.timestamp, pendingCount)
            )
        );
    }

    function setPrices(uint256 _price1, uint256 _price2, uint256 _price3) external onlyOwner {
        priceStep1 = _price1;
        priceStep2 = _price2;
        priceStep3 = _price3;
    }

    function getCurrentPrice() public view returns (uint256) {
        uint256 price = priceStep1;

        if (totalSupply() > priceTreshold2) {
            price = priceStep3;
        } else if (totalSupply() > priceTreshold1) {
            price = priceStep2;
        }

        return price;
    }

    function setMintPrice(uint256 value) external onlyOwner{
        MINT_PRICE = value;
    }

    function setFreeNft(address user, uint256 value) external onlyOwner{
        freeNft[user] = value;
    }

    function setTaxes(uint256 _adminTax, uint256 _reflectionTax) external onlyOwner{
        require(_adminTax + _reflectionTax == 100, "Total tax must be 100%");
        adminTax = _adminTax;
        reflectionTax = _reflectionTax;
    }

    function setMaxNFTInPurchase(uint256 _max) external onlyOwner {
        MAX_NFT_IN_PURCHASE = _max;
    }

    function getReedemableList() external view returns (uint256 [] memory) {
        uint256 balance = lunicornsV1Contract.balanceOf(msg.sender);
        uint256[] memory result = new uint256[](balance);
        uint256 redeemableCount;
        for (uint256 i = 0; i < result.length; i++) {
            uint256 _tokenId = lunicornsV1Contract.tokenOfOwnerByIndex(msg.sender, i);
            if(minters[_tokenId] == address(0) ) {
                result[redeemableCount] = _tokenId;
                redeemableCount++;
            }
        }

        uint[] memory redeemable = new uint[](redeemableCount);
        for (uint256 i = 0; i < redeemable.length; i++) {
            redeemable[i] = result[i];
        }
        return redeemable;
    }

    function redeem(uint256 _tokenId) public periodStarted {
        require(_tokenId <= 5000, "Only first 5000 nft can be redeemed");
        require(minters[_tokenId] == address(0), "Nft already redeemed");

        address ownerLunicornsV1 = lunicornsV1Contract.ownerOf(_tokenId);
        require(ownerLunicornsV1 == msg.sender, "Lunicorns v1 nft not owned");

        _mintToken(msg.sender, _tokenId);
    }

    function redeemBatch(uint256[] memory _tokenIds) external periodStarted {
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            redeem(_tokenIds[i]);
        }
    }

    // Emergency functions
    function rescueBNB() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    // Emergency functions
    function setRoyaltyFee(uint256 _fee) external onlyOwner {
        require(_fee > 0, "Royalty fee must be more then 0");
        require(_fee < 100, "Royalty fee must be less then 100");
        royaltiesTax = _fee;
    }

    function royaltyInfo( uint256 , uint256 _salePrice ) external view override returns ( address receiver, uint256 royaltyAmount ) {
        return (devWallet, _salePrice * royaltiesTax / 100 );
    }
}