// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC721URIStorage.sol";
import "./Counters.sol";
import "./Ownable.sol";
import "./IERC20.sol";

contract GameItem is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    address public tokenAddress;
    address public usdtAddress;
    address public ownerWallet;
    IERC20 ECR20;

    mapping(string => uint256) public pricing;
    mapping(string => uint256) public quantity;
    mapping(string => bool) public infinity;

    event setECR20AddressEvent(address _ecr20addr);
    event setPricingItemEvent(
        string itemname,
        uint256 price,
        uint256 quan,
        bool infinity
    );
    event setdelPricingItemEvent(string itemname);
    event buyItemEvent(
        address _player,
        uint256 tokenId,
        uint256 amount,
        string itemname,
        string uri
    );
    event mintItemEvent(address _player, uint256 tokenId);
    event setCanSellEvent(uint256 tokenId);
    event setCantSellEvent(uint256 tokenId);

    constructor() ERC721("Knight Of Emperor NFT", "KOEn") {
        tokenAddress = address(this);
        ownerWallet = _msgSender();
        _setOwner(_msgSender());
    }

    // set ECR20Address
    function setECR20Address(address _ecr20addr)
        external
        onlyOwner(_msgSender())
        returns (bool)
    {
        require(_ecr20addr != address(0), "can't address zero");
        usdtAddress = _ecr20addr;
        ECR20 = IERC20(_ecr20addr);
        emit setECR20AddressEvent(_ecr20addr);
        return true;
    }

    //add Item for sell
    function addItemSell(
        string memory itemname,
        uint256 price,
        uint256 quan
    ) external onlyOwner(_msgSender()) {
        pricing[itemname] = price;
        quantity[itemname] = quan;
        if (quan == 0) {
            infinity[itemname] = true;
        } else {
            infinity[itemname] = false;
        }
        emit setPricingItemEvent(
            itemname,
            pricing[itemname],
            quantity[itemname],
            infinity[itemname]
        );
    }

    //del Item on sell
    function delItemSell(string memory itemname)
        external
        onlyOwner(_msgSender())
    {
        pricing[itemname] = 1000000;
        quantity[itemname] = 0;
        infinity[itemname] = false;
        emit setdelPricingItemEvent(itemname);
    }

    //Buy Item
    function buyItem(string memory itemname, string memory tokenURI)
        external
        returns (uint256)
    {
        if (abi.encodePacked(pricing[itemname]).length == 0) {
            require(false, "The Item don't have price yet.");
        }
        if (abi.encodePacked(quantity[itemname]).length == 0) {
            require(false, "The Item does not register yet.");
        }
        if (!infinity[itemname]) {
            require(quantity[itemname] > 0, "The item sold out.");
        }

        uint256 amount = pricing[itemname];
        ECR20.transferFrom(
            _msgSender(),
            ownerWallet,
            amount * (10**ECR20.decimals())
        );
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        if (!infinity[itemname]) {
            quantity[itemname]--;
        }
        _mint(_msgSender(), newItemId);
        _setTokenURI(newItemId, tokenURI);
        emit buyItemEvent(_msgSender(), newItemId, amount, itemname , tokenURI);
        return newItemId;
    }

    // mint item and send to player  (drop or craft)
    function mintItem(string memory tokenURI, address _player)
        external
        onlyOwner(_msgSender())
        returns (uint256)
    {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _mint(_player, newItemId);
        _setTokenURI(newItemId, tokenURI);
        emit mintItemEvent(_player, newItemId);
        return newItemId;
    }

    // when item in NFT inventory then can sell
    function setCanSell(uint256 itemId)
        external
        onlyOwner(_msgSender())
        returns (bool)
    {
        _setCanSell(itemId);
        emit setCanSellEvent(itemId);
        return true;
    }

    // when item in normal inventory then can't sell
    function setCantSell(uint256 itemId)
        external
        onlyOwner(_msgSender())
        returns (bool)
    {
        _setCantSell(itemId);
        emit setCantSellEvent(itemId);
        return false;
    }
}