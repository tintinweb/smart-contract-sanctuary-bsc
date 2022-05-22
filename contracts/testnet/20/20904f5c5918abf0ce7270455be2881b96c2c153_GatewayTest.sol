pragma solidity ^0.5.7;

import './IBEP20.sol';

contract GatewayTest {

    address public _admin;

    IBEP20 public token ;

    struct Product {
        string name;
        bool isExist;
        uint price;
    }

    mapping (uint => Product) public products;

    uint public _id = 0;


    constructor() public {
        _admin = msg.sender;
        token  = IBEP20(address(0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee));
    }


    modifier onlyAdmin (){
        require(msg.sender == _admin, "only for owner");
        _;
    }

    function addProduct (string memory _name, uint _price) public onlyAdmin {
        require(_price >= 0, 'price is not valid');

        Product memory product = Product({
            name : _name,
            price : _price,
            isExist : true
        });

        _id++;
        products[_id] = product;
    }

    function buyProduct(uint _productID, string memory data) public {
        require(products[_productID].isExist, 'Product not exists !');
        require(token.balanceOf(msg.sender) >= products[_productID].price, 'Value Incorrect');
        token.transferFrom(msg.sender, _admin , products[_productID].price);
    }

    function getBalance (address wallet) public view returns (uint){
        return token.balanceOf(msg.sender);
    }

}