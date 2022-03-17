// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./PIN721.sol";
import "./IERC20.sol";
import "./SafeERC20.sol";

contract PINMarketplace is Ownable {
    using SafeERC20 for IERC20;
    PIN721 private token;
    address internal paymentCurrency;

    struct ItemForSale {
        uint256 id;
        uint256 tokenId;
        address payable seller;
        uint256 price;
        bool isSold;
    }

    ItemForSale[] public itemsForSale;
    mapping(uint256 => bool) public activeItems; // tokenId => active?

    event itemAddedForSale(uint256 id, uint256 tokenId, uint256 price);
    event itemSold(uint256 id, address buyer, uint256 price);

    constructor(PIN721 _token, address _paymentCurrency) {
        token = _token;
        paymentCurrency = _paymentCurrency; // Address currency for transaction
    }

    modifier OnlyItemOwner(uint256 tokenId) {
        require(
            token.ownerOf(tokenId) == msg.sender,
            "Sender does not own the item"
        );
        _;
    }

    modifier HasTransferApproval(uint256 tokenId) {
        require(
            token.getApproved(tokenId) == address(this),
            "Market is not approved"
        );
        _;
    }

    modifier ItemExists(uint256 id) {
        require(
            id < itemsForSale.length && itemsForSale[id].id == id,
            "Could not find item"
        );
        _;
    }

    modifier IsForSale(uint256 id) {
        require(!itemsForSale[id].isSold, "Item is already sold");
        _;
    }

    function putItemForSale(uint256 tokenId, uint256 price)
        external
        OnlyItemOwner(tokenId)
        HasTransferApproval(tokenId)
        returns (uint256)
    {
        require(!activeItems[tokenId], "Item is already up for sale");

        uint256 newItemId = itemsForSale.length;
        itemsForSale.push(
            ItemForSale({
                id: newItemId,
                tokenId: tokenId,
                seller: payable(msg.sender),
                price: price,
                isSold: false
            })
        );
        activeItems[tokenId] = true;

        assert(itemsForSale[newItemId].id == newItemId);
        emit itemAddedForSale(newItemId, tokenId, price);
        return newItemId;
    }

    function buyItem(uint256 id)
        external
        payable
        ItemExists(id)
        IsForSale(id)
        HasTransferApproval(itemsForSale[id].tokenId)
    {
        require(
            IERC20(paymentCurrency).balanceOf(msg.sender) >=
                itemsForSale[id].price,
            "INSUFFICIENT_BALANCE"
        );
        require(msg.sender != itemsForSale[id].seller);
        // require(msg.value >= itemsForSale[id].price, "Not enough funds sent");

        itemsForSale[id].isSold = true;
        activeItems[itemsForSale[id].tokenId] = false;
        token.safeTransferFrom(
            itemsForSale[id].seller,
            msg.sender,
            itemsForSale[id].tokenId
        );
        IERC20(paymentCurrency).safeTransferFrom(
            msg.sender,
            itemsForSale[id].seller,
            itemsForSale[id].price
        );
        // itemsForSale[id].seller.transfer(msg.value);

        emit itemSold(id, msg.sender, itemsForSale[id].price);
    }

    function totalItemsForSale() external view returns (uint256) {
        return itemsForSale.length;
    }

    function setPaymentCurrency(address _paymentCurrency) external {
      require(msg.sender == owner(), "PINMarketplace_INVALID_OWNER");
      paymentCurrency = _paymentCurrency;
    }
}

//TODO:
// - don't support bidding
// - the user can't withdraw the item