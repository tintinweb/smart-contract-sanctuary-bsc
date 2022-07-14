/**
 *Submitted for verification at BscScan.com on 2022-07-14
*/

pragma solidity >=0.7.0 <0.9.0;

struct Member {
    address addr;
    string name;
    bool activated;  // if true, that person already voted
    uint index;
}

interface IUsers {
    function getMemberByIndex(uint index) external returns (Member memory);

    function getMemberByAddress(address addr) external returns (Member memory);

    function checkActivation(address addr) external returns (bool);

}

contract Module1  {

    IUsers public usersContract;

    //// here variables for buy & sell
    struct Product {
        string name;
        string imgUrl;
        uint category;
        address creator;
    }

    struct Category {
        string name;
        address creator;
    }

    struct Order {
        uint productIndex;
        string description;
        address creator;
    }

    mapping(uint => Category) categories;
    uint totalCategories = 0;

    mapping(uint => Product) products;
    uint totalProducts = 0;

    mapping(uint => Order) orders;
    uint totalOrders = 0;

    constructor (address _usersContract) {
        usersContract = IUsers(_usersContract);
    }

    function createCategory(string memory category_name) public returns (bool) {

        require(
            usersContract.checkActivation(msg.sender) == true,
            "You are not activated or joined as member"
        );

        for (uint i = 0; i < totalCategories; i++) {
            require(
                keccak256(abi.encodePacked(categories[i].name)) != keccak256(abi.encodePacked(category_name)),
                "Already exist with the name."
            );
        }
        
        categories[totalCategories] = Category(category_name, msg.sender);

        totalCategories ++;

        return true;
    }

    function createProduct(string memory product_name, string memory imgUrl, uint categoryIndex) public returns (bool) {

        require(
            usersContract.checkActivation(msg.sender) == true,
            "You are not activated or joined as member"
        );

        require(
            categoryIndex < totalCategories,
            "Category not exist with the index"
        );

        products[totalProducts] = Product(product_name, imgUrl, categoryIndex, msg.sender);

        totalProducts ++;


        return true;
    }

    function createBuyOrder(uint productIndex, string memory description) public returns (bool) {
        require(
            usersContract.checkActivation(msg.sender) == true,
            "You are not activated or joined as member"
        );

        require(
            productIndex < totalProducts,
            "Product not exist with the index"
        );

        orders[totalOrders] = Order(productIndex, description, msg.sender);

        totalOrders ++;

        return true;
    }
}