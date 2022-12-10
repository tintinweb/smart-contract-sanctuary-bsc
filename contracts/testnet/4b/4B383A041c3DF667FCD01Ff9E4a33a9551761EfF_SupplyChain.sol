/**
 *Submitted for verification at BscScan.com on 2022-12-09
*/

pragma solidity >=0.8.0;
// SPDX-License-Identifier: MIT

/********************************************************* Product *************************************/

    contract Product {

           
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

        function getProductInfo () public view returns(
            string memory Name, 
            string memory BatchID, 
            address OrganizationID, 
            string memory Country, 
            string memory Region, 
            string memory City, 
            uint256 TestDate, 
            uint256 ProductionDate, 
            string memory Ingredients
        ) {
            return(
            name,
            batchID,
            organizationID,
            country,
            region,
            city,
            testDate,
            productionDate,
            ingredients
            );
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
    address private _previousOwner;
    /// @dev Validate Owner
    modifier onlyOwner() {
        require(
            msg.sender == Owner,
            "Only owner can call this function."
        );
        _;
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

     /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(Owner, address(0));
        Owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(Owner, newOwner);
        Owner = newOwner;
    }

    enum roles {
        norole,
        admin,
        revoke
    }

    event AdminRegister(address indexed EthAddress, string  Name);
    event AdminRoleRevoked(address indexed EthAddress, string Name, uint Role);
    event AdminRoleRessigne(address indexed EthAddress, string  Name, uint Role);

    /// @notice
    /// @dev Register New Admin by Owner
    /// @param EthAddress Ethereum Network Address of Admin
    /// @param Name Admin name
    /// @param Location Admin Location
    /// @param Role Admin Role
    function AddAdmin(
        address EthAddress,
        string memory Name,
        string memory Location,
        uint Role
        ) public
        onlyOwner
        {
        require(AdminsDetails[EthAddress].role == roles.norole, "Admin Already registered");
        AdminsDetails[EthAddress].name = Name;
        AdminsDetails[EthAddress].location = Location;
        AdminsDetails[EthAddress].ethAddress = EthAddress;
        AdminsDetails[EthAddress].role = roles(Role);
        Admins.push(EthAddress);
        emit AdminRegister(EthAddress, Name);
    }
    /// @notice
    /// @dev Revoke Admins role
    /// @param AdminAddress Admin Ethereum Network Address
    function revokeRole(address AdminAddress) public onlyOwner {
        require(AdminsDetails[AdminAddress].role != roles.norole, "Admin not registered");
        emit AdminRoleRevoked(AdminAddress, AdminsDetails[AdminAddress].name,uint(AdminsDetails[AdminAddress].role));
        AdminsDetails[AdminAddress].role = roles(2);
    }
    /// @notice
    /// @dev Reassigne new role to Admin
    /// @param AdminAddress Admin Ethereum Network Address
    /// @param Role Role to assigne
    function reassigneRole(address AdminAddress, uint Role) public onlyOwner {
        require(AdminsDetails[AdminAddress].role != roles.norole, "Admin not registered");
        AdminsDetails[AdminAddress].role = roles(Role);
        emit AdminRoleRessigne(AdminAddress, AdminsDetails[AdminAddress].name,uint(AdminsDetails[AdminAddress].role));
    }

    function isAdmin() public view virtual returns (bool) {
        return AdminsDetails[msg.sender].role == roles(1);
    } 
 
/********************************************** Admin Section **********************************************/
    struct AdminInfo {
        string name;
        string location;
        address ethAddress;
        roles role;
    }

    /// @notice
    mapping(address => AdminInfo) AdminsDetails;
    /// @notice 
    address[] Admins;

    function getAdminInfo(address Admin) public view returns(
        string memory name,
        string memory location,
        address ethAddress,
        roles role
        ) {
        return (
            AdminsDetails[Admin].name,
            AdminsDetails[Admin].location,
            AdminsDetails[Admin].ethAddress,
            AdminsDetails[Admin].role);
    }

    function getAdminCount() public view returns(uint count){
        return Admins.length;
    }

    function getAdminbyIndex(uint index) public view returns(
        string memory name,
        string memory location,
        address ethAddress,
        roles role
        ) {
        return getAdminInfo(Admins[index]);
    }


/*********************************************** Products ***********************************************/

    mapping(address => address[]) public ProductsList;
    event ProductAdded(
        string indexed Name, string indexed BatchID, address  indexed OrganizationID, string  Country , string  Region , string  City, uint256  TestDate, uint256  ProductionDate, string  Ingredients
    );

    function  AddProduct(
        string memory Name, string memory BatchID, address OrganizationID, string memory Country , string memory Region , string memory City, uint256 TestDate, uint256 ProductionDate, string memory Ingredients
        ) public {
        require(
            AdminsDetails[msg.sender].role == roles.admin,
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
            AdminsDetails[msg.sender].role == roles.admin,
            "Only admin can call this function"
        );
        return ProductsList[msg.sender].length;
    }

    /***function getProductsIDByIndex(uint index) public view returns(address BatchID){
        require(
            AdminsDetails[msg.sender].role == roles.admin,
            "Only admin can call this function"
        );
        return ProductsList[msg.sender][index];
    }
    ***/

    



/*********************************************** Ingredients *********************************************/
    mapping(address => address[]) public IngredientsList;

    struct IngredientInfo {
        string name;
        string batchid;
        address organizationid;
        string location;
        uint256 lotNumber;
    }

    mapping(string => IngredientInfo) IngredientDetails;
    IngredientInfo[] private  ListOfIngredients;
    string[] private IngredientsName;
   
    function getIngredientInfo(string memory item) public view returns(
        string memory name,
        string memory batchid,
        address organizationid,
        string memory location,
        uint256 lotNumber
        ) {
        return (
            IngredientDetails[item].name,
            IngredientDetails[item].batchid,
            IngredientDetails[item].organizationid,
            IngredientDetails[item].location,
            IngredientDetails[item].lotNumber );
            }

    event IngredientAdded(
        string indexed Name, string indexed BatchID, address  indexed OrganizationID, string  Location , uint256  LotNumber
    );

    function  AddIngredient(
        string memory Name, string memory BatchID, address OrganizationID, string memory Location ,  uint256 LotNumber
        ) public {
        require(
            AdminsDetails[msg.sender].role == roles.admin,
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

        IngredientDetails[Name].name= Name;
        IngredientDetails[Name].batchid = BatchID;
        IngredientDetails[Name].organizationid = OrganizationID;
        IngredientDetails[Name].location = Location;
        IngredientDetails[Name].lotNumber = LotNumber;
        ListOfIngredients.push(IngredientInfo(Name, BatchID, OrganizationID, Location, LotNumber));
        IngredientsName.push(Name);





        emit IngredientAdded (Name,
        BatchID,
        OrganizationID,
        Location,
        LotNumber
        );


    }

    function getIngredientsListByName() public view returns(string[] memory){
        return IngredientsName;
    }

    function getArrayIngredients() public view returns(IngredientInfo[] memory) {
        return ListOfIngredients;
    }

    function getIngredientsCount() public view returns(uint count){
        require(
            AdminsDetails[msg.sender].role == roles.admin,
            "Only admin can call this function"
        );
        return IngredientsList[msg.sender].length;
    }

/***
    function getIngredientsIDByIndex(uint index) public view returns(address BatchID){
        require(
            AdminsDetails[msg.sender].role == roles.admin,
            "Only admin can call this function"
        );
        return IngredientsList[msg.sender][index];
    }
    *****/


    

 
 }