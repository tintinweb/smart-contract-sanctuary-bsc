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
    }

    Category[] categories;

    Product[] products;

    mapping(address => Order[]) orders;

    constructor (address _usersContract) {
        usersContract = IUsers(_usersContract);
    }

    function createCategory(string memory category_name) public returns (bool) {

        require(
            usersContract.checkActivation(msg.sender) == true,
            "You are not activated or joined as member"
        );

        for (uint i = 0; i < categories.length; i++) {
            require(
                keccak256(abi.encodePacked(categories[i].name)) != keccak256(abi.encodePacked(category_name)),
                "Already exist with the name."
            );
        }
        
        categories.push(Category(category_name, msg.sender));

        return true;
    }

    function createProduct(string memory product_name, string memory imgUrl, uint categoryIndex) public returns (bool) {

        require(
            usersContract.checkActivation(msg.sender) == true,
            "You are not activated or joined as member"
        );

        require(
            categoryIndex < categories.length,
            "Category not exist with the index"
        );

        products.push(Product(product_name, imgUrl, categoryIndex, msg.sender));

        return true;
    }

    function createBuyOrder(uint productIndex, string memory description) public returns (bool) {
        require(
            usersContract.checkActivation(msg.sender) == true,
            "You are not activated or joined as member"
        );

        require(
            productIndex < products.length,
            "Product not exist with the index"
        );

        orders[msg.sender].push(Order(productIndex, description));

        return true;
    }

    function getAllCategories() public view returns (Category[] memory) {
        return categories;
    }

    function getCategoryByIndex(uint index) public view returns (Category memory) {
        require(
            index < categories.length,
            "Category not exist with the index"
        );

        return categories[index];
    }

    function getAllProducts() public view returns (Product[] memory) {
        return products;
    }

    function getProductByIndex(uint index) public view returns (Product memory) {
        require(
            index < products.length,
            "Category not exist with the index"
        );

        return products[index];
    }

    function getUserOrders(address addr) public view returns (Order[] memory) {
        return orders[addr];
    }

    function getUserOrderByIndex(address addr, uint index) public view returns (Order memory) {
        require(
            index < orders[addr].length,
            "Order not exist with the index"
        );

        return orders[addr][index];
    }
}