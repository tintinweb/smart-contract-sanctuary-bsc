/**
 *Submitted for verification at BscScan.com on 2022-07-20
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

    constructor (address _usersContract) {
        usersContract = IUsers(_usersContract);
    }

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



    //// here variables 
    struct VotingOption {
        string option;
        uint votedCount;
    }

    struct VotingMaterial {
        address creator;
        string name;
        uint optionCount;
        uint[] options;
    }

    VotingMaterial[] voting_materials;
    VotingOption[] voting_options;
    mapping(address => uint[]) user_votings;



    //// buy & sell from here
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

    function getUserCategories(address addr) public view returns (Category[] memory) {
        Category[] memory _categories;

        for (uint i = 0; i < categories.length; i++) {
            if (categories[i].creator == addr) {
                _categories[i] = categories[i];
            }
        }


        return _categories;
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
    //// end of buy & sell


    //// evoting from here
    function createVotingMaterial(string memory name, string[] memory options) public returns (bool) {
        require(
            usersContract.checkActivation(msg.sender) == true,
            "You are not activated or joined as member"
        );

        VotingMaterial memory vMaterial = VotingMaterial(msg.sender, name, options.length, new uint[](0));
        voting_materials.push(vMaterial);

        uint optionsCount = voting_options.length;
        for (uint i = 0; i < options.length; i++) {
            voting_options.push(VotingOption(options[i], 0));
            voting_materials[voting_materials.length - 1].options.push(optionsCount + i);
        }


        return true;
    }

    function voteMaterial(uint materialId, uint optionId) public returns (bool) {
        require(
            materialId < voting_materials.length,
            "There isn't the index's voting material"
        );

        require(
            optionId < voting_materials[materialId].optionCount,
            "There isn't the index's option for the voting material"
        );

        require(
            usersContract.checkActivation(msg.sender) == true,
            "You are not activated or joined as member"
        );


        bool alreadyVoted = false;
        for (uint i=0; i < user_votings[msg.sender].length; i++) {
            if (user_votings[msg.sender][i] == materialId) {
                alreadyVoted = true;
            }
        }

        require(
            alreadyVoted == false,
            "You already voted to this voting material"
        );

        uint oId = voting_materials[materialId].options[optionId];
        voting_options[oId].votedCount ++;
        user_votings[msg.sender].push(materialId);

        return true;
    }

    function getTotalVotingMaterials() public view returns (uint) {
        return voting_materials.length;
    }

    function getTotalVotingOptions() public view returns (uint) {
        return voting_options.length;
    }

    function getAllVotingMaterials() public view returns (VotingMaterial[] memory) {
        return voting_materials;
    }

    function getAllVotingOptions() public view returns (VotingOption[] memory) {
        return voting_options;
    }

    function getVotingMaterialByIndex(uint index) public view returns (VotingMaterial memory) {
        require(
            index < voting_materials.length,
            "There isn't voting material with the index"
        );

        return voting_materials[index];
    }

    function getVotingOptionByIndex(uint index) public view returns (VotingOption memory) {
        require(
            index < voting_options.length,
            "There isn't voting option with the index"
        );

        return voting_options[index];
    }
    /// end of evoting

    function getUserVotings(address addr) public view returns (uint [] memory) {
        return user_votings[addr];
    }

}