// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC721URIStorage.sol";
import "./SafeERC20.sol";
import "./IERC20.sol";
import "./Counters.sol";
import "./Strings.sol";
import "./SafeMath.sol";
import "./Ownable.sol";

contract OpusNft is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using Strings for uint256;

    uint256 constant feeDecimals = 4;

    string public baseURI;

    Counters.Counter private _tokenIds;
    Counters.Counter private _auctionIds;


    mapping(uint256 => address) private _authors;
    mapping(uint256 => bool) private _sales;
    mapping(uint256 => uint256) private _price;
    mapping(uint256 => IERC20) private _currencies;
    mapping(uint256 => bool) private _auctions;
    mapping(uint256 => uint256) private _copyrightFees;
    mapping(uint256 => uint256) private _platformFees;
    mapping(uint256 => Auction) private _auctionMap;
    mapping(uint256 => AuctionItem[]) private _auctionLogs;

    struct Auction {
        uint256 auctionId;
        IERC20 currency;
        uint256 minPrice;
        uint256 plusPrice;
        uint256 beginAt;
        uint256 doneAt;
    }

    struct AuctionItem {
        address addr;
        uint256 price;
        uint256 time;
    }


    event MintItem(uint256 tokenId, address author, uint256 price, address token,  uint256 copyrightFee, uint256 _platformFee, string  tokenURI);
    // event SetPlatformFee(uint256 fee);
    event FlipSale(uint256 tokenId, bool sale, uint256 price, address token);
    event Buy(address from, address addr, uint256 tokenId);
    event PublishAuction(uint256 auctionId, address owner, uint256 tokenId, address currency, uint256 minPrice,
        uint256 plusPrice);
    event JoinAuction(uint256 auctionId, uint256 tokenId, address addr, uint256 price);
    event AuctionDone(uint256 auctionId, address from, address addr, uint256 tokenId);

    constructor() ERC721("MyOP", "MyOP") {}

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function setBaseURI(string memory uri) public onlyOwner {
        baseURI = uri;
    }

    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
    function mintItem(address author, uint256 price, address token, uint256 copyrightFee, uint256 _platformFee, string memory tokenURI) public onlyOwner  returns (uint256) {
        require(isContract(token), "token: implementation is not a contract");
        require(copyrightFee>=0 && copyrightFee < 10**feeDecimals/2, "copyrightFee must between 0 and 50");
        require(_platformFee>=0 && copyrightFee < 10**feeDecimals/2, "platformFee must between 0 and 50");
        _tokenIds.increment();

        uint256 newItemId = _tokenIds.current();
        _mint(author, newItemId);
        _setTokenURI(newItemId, tokenURI);
        _authors[newItemId] = author;
        _price[newItemId] = price;
        _currencies[newItemId] = IERC20(token);
        _copyrightFees[newItemId] = copyrightFee;
        _platformFees[newItemId] = _platformFee;

        emit MintItem(newItemId, author, price, token, copyrightFee, _platformFee, tokenURI);
        return newItemId;
    }

    function platformFee(uint256 tokenId) public view returns (uint256) {
        require(_exists(tokenId), "nonexistent token");
        return _platformFees[tokenId];
    }

    // function setPlatformFee(uint256 fee) public onlyOwner nonReentrant {
    //     require(fee>=0 && fee < 10**feeDecimals/2, "fee must between 0 and 50");
    //     _platformFee = fee;
    //     emit SetPlatformFee(fee);
    // }

    function flipSale(uint256 tokenId, bool onSale, uint256 price, address token) public   {
        require(_exists(tokenId), "nonexistent token");
        require(ownerOf(tokenId) == _msgSender() || _msgSender() == owner(), "caller is not the token owner");
        require(_sales[tokenId] != onSale, "status not change");
        require(!_auctions[tokenId], "token is on auction");
        require(isContract(token), "token: implementation is not a contract");

        _sales[tokenId] = onSale;
        if (onSale) {
            _price[tokenId] = price;
            _currencies[tokenId] = IERC20(token);
        }

        emit FlipSale(tokenId, onSale, price, token);
    }

    function feePrice(uint256 tokenId) public view returns(uint256 copyrightFee, uint256 platformFeePrice) {
        copyrightFee = _price[tokenId].mul(_copyrightFees[tokenId]).div(10**feeDecimals);
        platformFeePrice = _price[tokenId].mul(_platformFees[tokenId]).div(10**feeDecimals);
    }


    function priceOf(uint256 tokenId) public view returns (uint256) {
        require(_exists(tokenId), "nonexistent token");
        return _price[tokenId];
    }

    function currencyOf(uint256 tokenId) public view returns(address) {
        require(_exists(tokenId), "nonexistent token");
        return address(_currencies[tokenId]);
    }

    function isOnSale(uint256 tokenId) public view returns(bool) {
        require(_exists(tokenId), "nonexistent token");
        return _sales[tokenId];
    }

    function buy(uint256 tokenId) public  {
        require(_exists(tokenId), "nonexistent token");
        require(_sales[tokenId], "token is not on sale");
        require(!_auctions[tokenId], "token is on auction");
        require(ownerOf(tokenId) != _msgSender(), "the token is already yours");

        (uint256 copyrightFee, uint256 platformFeePrice) = feePrice(tokenId);
        uint256 price = _price[tokenId];

        IERC20 token = _currencies[tokenId];
        token.safeTransferFrom(_msgSender(), address(this), price);

        token.safeTransfer(_authors[tokenId], copyrightFee);
        token.safeTransfer(owner(), platformFeePrice);
        token.safeTransfer(ownerOf(tokenId), price.sub(copyrightFee).sub(platformFeePrice));

        _sales[tokenId] = false;

        address _from = ownerOf(tokenId);
        _transfer(ownerOf(tokenId), _msgSender(), tokenId);
        emit Buy(_from, _msgSender(), tokenId);
    }

    function publishAuction(uint256 tokenId, address currency, uint256 minPrice, uint256 plusPrice) public  returns(uint256 auctionId) {
        require(_exists(tokenId), "nonexistent token");
        require(ownerOf(tokenId) == _msgSender() || _msgSender() == owner(), "caller is not the token owner");
        require(!_sales[tokenId], "token is on sale");
        require(!_auctions[tokenId], "token is on auction");
        require(isContract(currency), "token: implementation is not a contract");

        _auctionIds.increment();
        auctionId = _auctionIds.current();


        _auctionMap[tokenId] = Auction(
            auctionId,
            IERC20(currency),
            minPrice,
            plusPrice,
            block.timestamp,
            0
        );

        _auctions[tokenId] = true;

        emit PublishAuction(auctionId, ownerOf(tokenId), tokenId, currency,  minPrice, plusPrice);
    }

    function joinAuction(uint256 tokenId, uint256 amount) public  {
        require(_exists(tokenId), "nonexistent token");
        require(ownerOf(tokenId) != _msgSender(), "the token is already yours");
        require(_auctions[tokenId], "token is not on auction");

        Auction memory config = _auctionMap[tokenId];
        require(config.doneAt == 0, "auction done");
        require(config.minPrice != 0);
        AuctionItem[] memory logs = _auctionLogs[config.auctionId];

        uint256 minPrice = config.minPrice;
        if (logs.length >  0) {
            uint latestPrice = logs[logs.length-1].price;
            minPrice = latestPrice.add(config.plusPrice);
        }

        require(amount>=minPrice, "price is to low");

        _auctionLogs[config.auctionId].push(AuctionItem(_msgSender(), amount, block.timestamp));
        config.currency.safeTransferFrom(_msgSender(), address(this), amount);

        emit JoinAuction(config.auctionId, tokenId, _msgSender(), amount);

    }

    function completeAuction(uint256 tokenId) public onlyOwner() {
        require(_exists(tokenId), "nonexistent token");
        require(_auctions[tokenId], "token is not on auction");

        Auction memory config = _auctionMap[tokenId];
        require(config.doneAt == 0, "auction done");
        require(config.minPrice != 0);
        require(config.beginAt + 1 days <= block.timestamp, "The auction is not over yet");

        _auctionMap[tokenId].doneAt = block.timestamp;
        _auctions[tokenId] = false;

        AuctionItem[] memory logs = _auctionLogs[config.auctionId];
        address _from = ownerOf(tokenId);
        if (logs.length > 0) {
            for (uint256 i=0; i <= logs.length-1; i++) {
                if (i == logs.length-1) {
                    uint256 copyrightFee = logs[i].price.mul(_copyrightFees[tokenId]).div(10**feeDecimals);
                    uint256 platformFeePrice = logs[i].price.mul(_platformFees[tokenId]).div(10**feeDecimals);

                    config.currency.safeTransfer(owner(), platformFeePrice);
                    config.currency.safeTransfer(_authors[tokenId], copyrightFee);
                    config.currency.safeTransfer(ownerOf(tokenId), logs[i].price.sub(platformFeePrice).sub(copyrightFee));

                    _transfer(_from, logs[i].addr, tokenId);

                    emit AuctionDone(config.auctionId, _from, logs[i].addr, tokenId);
                } else {
                    config.currency.safeTransfer(logs[i].addr, logs[i].price);
                }
            }
        } else {
            emit AuctionDone(config.auctionId, _from, address(0), tokenId);
        }
    }

    function multiBuy(uint256[] calldata tokenIds) public {
        for (uint256 i=0; i<=tokenIds.length-1; i++) {
            buy(tokenIds[i]);
        }
    }
}