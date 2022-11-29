/**
 *Submitted for verification at BscScan.com on 2022-11-29
*/

pragma solidity >=0.8.0;
// SPDX-License-Identifier: MIT



/********************************************************* Product *************************************/

    contract Product {

        
        address Owner;

        
        string name;
        string batchID;
        address organizationID;
        string  country;
        string  region;
        string city;
        uint256 testDate;
        uint256 productionDate;
        string ingredients;
        


        constructor(
            string memory Name, 
            string memory BatchID, 
            address OrganizationID, 
            string memory Country, 
            string memory Region, 
            string memory City, 
            uint256 TestDate, 
            uint256 ProductionDate, 
            string memory Ingredients
        
        )  {
            name = Name;
            batchID = BatchID;
            organizationID = OrganizationID;
            country = Country;
            region = Region;
            city = City;
            testDate = TestDate;
            productionDate = ProductionDate;
            ingredients = Ingredients;
            
        }

    }

/********************************************************** Ingredients ********************************/

    contract Ingredient {

        string name;
        string batchID;
        address organizationID;
        string  location;
        uint256  lotNumber;


        constructor(
            string memory Name, 
            string memory BatchID, 
            address OrganizationID, 
            string memory Location, 
            uint256 LotNumber
        
        )  {
            name = Name;
            batchID = BatchID;
            organizationID = OrganizationID;
            location = Location;
            lotNumber = LotNumber;
            
        }

    }


contract SupplyChain {

    /// @notice
    address public Owner;

    constructor ()  {
        Owner = msg.sender;
    }
/********************************************** Owner Section *********************************************/
    /// @dev Validate Owner
    modifier onlyOwner() {
        require(
            msg.sender == Owner,
            "Only owner can call this function."
        );
        _;
    }

    enum roles {
        norole,
        admin,
        revoke
    }

    event UserRegister(address indexed EthAddress, string  Name);
    event UserRoleRevoked(address indexed EthAddress, string Name, uint Role);
    event UserRoleRessigne(address indexed EthAddress, string  Name, uint Role);

    /// @notice
    /// @dev Register New user by Owner
    /// @param EthAddress Ethereum Network Address of User
    /// @param Name User name
    /// @param Location User Location
    /// @param Role User Role
    function registerUser(
        address EthAddress,
        string memory Name,
        string memory Location,
        uint Role
        ) public
        onlyOwner
        {
        require(UsersDetails[EthAddress].role == roles.norole, "User Already registered");
        UsersDetails[EthAddress].name = Name;
        UsersDetails[EthAddress].location = Location;
        UsersDetails[EthAddress].ethAddress = EthAddress;
        UsersDetails[EthAddress].role = roles(Role);
        users.push(EthAddress);
        emit UserRegister(EthAddress, Name);
    }
    /// @notice
    /// @dev Revoke users role
    /// @param userAddress User Ethereum Network Address
    function revokeRole(address userAddress) public onlyOwner {
        require(UsersDetails[userAddress].role != roles.norole, "User not registered");
        emit UserRoleRevoked(userAddress, UsersDetails[userAddress].name,uint(UsersDetails[userAddress].role));
        UsersDetails[userAddress].role = roles(2);
    }
    /// @notice
    /// @dev Reassigne new role to User
    /// @param userAddress User Ethereum Network Address
    /// @param Role Role to assigne
    function reassigneRole(address userAddress, uint Role) public onlyOwner {
        require(UsersDetails[userAddress].role != roles.norole, "User not registered");
        UsersDetails[userAddress].role = roles(Role);
        emit UserRoleRessigne(userAddress, UsersDetails[userAddress].name,uint(UsersDetails[userAddress].role));
    }
 
/********************************************** User Section **********************************************/
    struct UserInfo {
        string name;
        string location;
        address ethAddress;
        roles role;
    }

    /// @notice
    mapping(address => UserInfo) UsersDetails;
    /// @notice
    address[] users;

    function getUserInfo(address User) public view returns(
        string memory name,
        string memory location,
        address ethAddress,
        roles role
        ) {
        return (
            UsersDetails[User].name,
            UsersDetails[User].location,
            UsersDetails[User].ethAddress,
            UsersDetails[User].role);
    }

    function getUsersCount() public view returns(uint count){
        return users.length;
    }

    function getUserbyIndex(uint index) public view returns(
        string memory name,
        string memory location,
        address ethAddress,
        roles role
        ) {
        return getUserInfo(users[index]);
    }


/*********************************************** Products ***********************************************/

    mapping(address => address[]) ProductsList;
    event ProductAdded(
        string indexed Name, string indexed BatchID, address  indexed OrganizationID, string  Country , string  Region , string  City, uint256  TestDate, uint256  ProductionDate, string  Ingredients
    );

    function  AddProduct(
        string memory Name, string memory BatchID, address OrganizationID, string memory Country , string memory Region , string memory City, uint256 TestDate, uint256 ProductionDate, string memory Ingredients
        ) public {
        require(
            UsersDetails[msg.sender].role == roles.admin,
            "Only admin can call this function"
        );

        Product newProduct = new Product(
        Name,
        BatchID,
        OrganizationID,
        Country,
        Region,
        City,
        TestDate,
        ProductionDate,
        Ingredients
        );

        ProductsList[msg.sender].push(address(newProduct));

        emit ProductAdded (Name,
        BatchID,
        OrganizationID,
        Country,
        Region,
        City,
        TestDate,
        ProductionDate,
        Ingredients);


    }

    function getProductsCount() public view returns(uint count){
        require(
            UsersDetails[msg.sender].role == roles.admin,
            "Only admin can call this function"
        );
        return ProductsList[msg.sender].length;
    }

    function getProductsIDByIndex(uint index) public view returns(address BatchID){
        require(
            UsersDetails[msg.sender].role == roles.admin,
            "Only admin can call this function"
        );
        return ProductsList[msg.sender][index];
    }



/*********************************************** Ingredients *********************************************/
    mapping(address => address[]) IngredientsList;

    struct IngredientInfo {
        string name;
        string batchid;
        address organizationid;
        string location;
    }

    mapping(string => IngredientInfo) IngredientDetails;
   
    function getIngredientInfo(string memory name) public view returns(
        string memory batchid,
        string memory location,
        address organizationid
        ) {
        return (
            IngredientDetails[name].batchid,
            IngredientDetails[name].location,
            IngredientDetails[name].organizationid );
            }

    event IngredientAdded(
        string indexed Name, string indexed BatchID, address  indexed OrganizationID, string  Location , uint256  LotNumber
    );

    function  AddIngredient(
        string memory Name, string memory BatchID, address OrganizationID, string memory Location ,  uint256 LotNumber
        ) public {
        require(
            UsersDetails[msg.sender].role == roles.admin,
            "Only admin can call this function"
        );

        Ingredient newIngredient = new Ingredient(
        Name,
        BatchID,
        OrganizationID,
        Location,
        LotNumber
        );

        IngredientsList[msg.sender].push(address(newIngredient));

        emit IngredientAdded (Name,
        BatchID,
        OrganizationID,
        Location,
        LotNumber
        );


    }

    function getIngredientsCount() public view returns(uint count){
        require(
            UsersDetails[msg.sender].role == roles.admin,
            "Only admin can call this function"
        );
        return IngredientsList[msg.sender].length;
    }

    function getIngredientsIDByIndex(uint index) public view returns(address BatchID){
        require(
            UsersDetails[msg.sender].role == roles.admin,
            "Only admin can call this function"
        );
        return IngredientsList[msg.sender][index];
    }

    

 
 }