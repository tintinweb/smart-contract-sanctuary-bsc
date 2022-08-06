/**
 *Submitted for verification at BscScan.com on 2022-08-05
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

contract Shop {
    address private owner;
    uint constant DURATION = 3 days;
    uint constant FEE = 10;

    struct Product {
        address payable seller;
        string name;
        uint price;
        uint startAt;
        uint endsAt;
        uint datePurchase;
        bool stoppedSold;
    }

    Product[] public products;

    event ProductCreated(uint index, string itemName, uint price, uint startAt, uint endsAt, bool stopped);
    event ProductSold(uint index, string itemName, address buyer, uint startAt, uint soldEnd);

    constructor() {
        owner = msg.sender;
    }

    function getBalanceContract() external view returns(uint) {
        return address(this).balance;
    }

    function checkedSoldProduct(uint index) public view returns(bool)  {
        Product memory cProduct = products[index];
        return cProduct.stoppedSold;
    }

    function createProduct(string memory _name, uint _price) external {
        Product memory newProduct = Product({
            seller: payable(msg.sender),
            name: _name,
            price: _price,
            startAt: block.timestamp,
            datePurchase: 0,
            endsAt: block.timestamp + DURATION,
            stoppedSold: false
        });

        products.push(newProduct);
        emit ProductCreated(products.length - 1, _name, _price, block.timestamp, block.timestamp + DURATION, false);
    }

    function buyProduct(uint index) external payable {
        Product storage cProduct = products[index];
        require(cProduct.seller != msg.sender, "It is forbidden to buy your goods");
        require(!cProduct.stoppedSold, "Sold stopped!");
        require(block.timestamp < cProduct.endsAt, "Sold ended!");
        require(msg.value >= cProduct.price, "The price is less than the value of the goods");
        cProduct.stoppedSold = true;
        cProduct.datePurchase = block.timestamp;
        cProduct.seller.transfer(
            cProduct.price - ((cProduct.price * FEE) / 100)
        );
        _transferFee((cProduct.price * FEE) / 100);
        emit ProductSold(index, cProduct.name, msg.sender, cProduct.startAt, block.timestamp);
    }

    function _transferFee(uint _amount) private {
        address payable _to = payable(owner);
        _to.transfer(_amount);
    }
}