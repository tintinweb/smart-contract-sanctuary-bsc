pragma solidity ^0.5.7;

import './IBEP20.sol';

contract GatewayTest {

    address public _admin;

    IBEP20 public token ;

    struct Product {
        bool isExist;
        uint price;
    }

    mapping (uint => Product) public products;

    uint public _id = 0;


    constructor() public {
        _admin = msg.sender;
        token  = IBEP20(address(0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7));
    }


    modifier onlyAdmin (){
        require(msg.sender == _admin, "only for owner");
        _;
    }

    function addProduct ( uint _price) public {
        require(_price >= 0, 'price is not valid');

        Product memory product = Product({
            price : _price,
            isExist : true
        });

        _id++;
        products[_id] = product;
    }
    
    function getOnchainId () public view returns (uint256){
        return _id;
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