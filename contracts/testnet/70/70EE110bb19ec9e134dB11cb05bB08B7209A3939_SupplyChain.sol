/**
 *Submitted for verification at BscScan.com on 2022-12-20
*/

pragma solidity >=0.8.0;
// SPDX-License-Identifier: MIT

/********************************************************* Product *************************************/

    contract Product { 
        uint256 uid;           
        string name;
        string batchID;
        address organizationID;
        string  country;
        string  region;
        string city;
        uint256 testDate;
        uint256 productionDate;
        string[] ingredients;
        string imgUrl;
        


        constructor(
            uint256 Uid,
            string memory Name, 
            string memory BatchID, 
            address OrganizationID, 
            string memory Country, 
            string memory Region, 
            string memory City, 
            uint256 TestDate, 
            uint256 ProductionDate, 
            string[] memory Ingredients,
            string memory ImgUrl
        
        )  {
            uid = Uid;
            name = Name;
            batchID = BatchID;
            organizationID = OrganizationID;
            country = Country;
            region = Region;
            city = City;
            testDate = TestDate;
            productionDate = ProductionDate;
            ingredients = Ingredients;
            imgUrl = ImgUrl;
            
        }

        function getProductInfo () public view returns(
            uint256 Uid,
            string memory Name, 
            string memory BatchID, 
            address OrganizationID, 
            string memory Country, 
            string memory Region, 
            string memory City, 
            uint256 TestDate, 
            uint256 ProductionDate, 
            string[] memory Ingredients,
            string memory ImgUrl
        ) {
            return(
            uid,
            name,
            batchID,
            organizationID,
            country,
            region,
            city,
            testDate,
            productionDate,
            ingredients,
            imgUrl
            );
        }

    }

/********************************************************** Ingredients ********************************/

    contract Ingredient {
        uint256 uid;
        string name;
        string batchID;
        address organizationID;
        string  location;
        uint256  lotNumber;


        constructor(
            uint256 Uid,
            string memory Name, 
            string memory BatchID, 
            address OrganizationID, 
            string memory Location, 
            uint256 LotNumber
        
        )  {
            uid = Uid;
            name = Name;
            batchID = BatchID;
            organizationID = OrganizationID;
            location = Location;
            lotNumber = LotNumber;
            
        }

    }



/*************************************************************SupllyChain**********************************************************************/


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

/**********************************************StingUtils*********************************************/

function compare(string memory _a, string memory _b) public pure returns (int) {
        bytes memory a = bytes(_a);
        bytes memory b = bytes(_b);
        uint minLength = a.length;
        if (b.length < minLength) minLength = b.length;
        //@todo unroll the loop into increments of 32 and do full 32 byte comparisons
        for (uint i = 0; i < minLength; i ++)
            if (a[i] < b[i])
                return -1;
            else if (a[i] > b[i])
                return 1;
        if (a.length < b.length)
            return -1;
        else if (a.length > b.length)
            return 1;
        else
            return 0;
    }
    /// @dev Compares two strings and returns true iff they are equal.
    function equal(string memory _a, string memory _b)public pure returns (bool) {
        return compare(_a, _b) == 0;
    }
    /// @dev Finds the index of the first occurrence of _needle in _haystack
    function indexOf(string memory _haystack, string memory _needle) public pure returns (int)
    {
    	bytes memory h = bytes(_haystack);
    	bytes memory n = bytes(_needle);
    	if(h.length < 1 || n.length < 1 || (n.length > h.length)) 
    		return -1;
    	else if(h.length > (2**128 -1)) // since we have to be able to return -1 (if the char isn't found or input error), this function must return an "int" type with a max length of (2^128 - 1)
    		return -1;									
    	else
    	{
    		uint subindex = 0;
    		for (uint i = 0; i < h.length; i ++)
    		{
    			if (h[i] == n[0]) // found the first char of b
    			{
    				subindex = 1;
    				while(subindex < n.length && (i + subindex) < h.length && h[i + subindex] == n[subindex]) // search until the chars don't match or until we reach the end of a or b
    				{
    					subindex++;
    				}	
    				if(subindex == n.length)
    					return int(i);
    			}
    		}
    		return -1;
    	}	
    }


/*********************************************** Products ***********************************************/

    mapping(address => address[])  ProductsList;

    struct ProductInfo {
        uint256 uid;
        string name;
        string batchid;
        address organizationid;
        string country;
        string region;
        string city;
        uint256 testdate;
        uint256 productiondate;
        string[]ingredients;
        string imgUrl;
    }

    mapping(string => ProductInfo) ProductDetails;
    mapping(string => ProductInfo) PrdBatchID;
    mapping(uint256 => ProductInfo) PrdUID;
    ProductInfo[] private  ListOfProducts;
    string[] private ProductsName;
   
    event ProductAdded(uint256 Uid,
        string indexed Name, string indexed BatchID, address  indexed OrganizationID, string  Country , string  Region , string  City, uint256  TestDate, uint256  ProductionDate, string[]  Ingredients, string ImgUrl
    );

    function  AddProduct(
        string memory Name, string memory BatchID, address OrganizationID, string memory Country , string memory Region , string memory City, uint256 TestDate, uint256 ProductionDate, string[] memory Ingredients, string memory ImgUrl
        ) public {
        require(
            AdminsDetails[msg.sender].role == roles.admin,
            "Only admin can call this function"
        );

        Product newProduct = new Product(
        ListOfProducts.length+1,
        Name,
        BatchID,
        OrganizationID,
        Country,
        Region,
        City,
        TestDate,
        ProductionDate,
        Ingredients,
        ImgUrl
        );

        ProductsList[msg.sender].push(address(newProduct));
        uint256 UID;
        PrdUID[UID].uid = ListOfProducts.length+1;
        PrdUID[UID].imgUrl = ImgUrl;

        ProductDetails[Name].uid = ListOfProducts.length+1;

        ProductDetails[Name].name = Name;
        ProductDetails[Name].batchid = BatchID;
        ProductDetails[Name].organizationid = OrganizationID;
        ProductDetails[Name].country = Country;
        ProductDetails[Name].region = Region;
        ProductDetails[Name].city = City;
        ProductDetails[Name].testdate = TestDate;
        ProductDetails[Name].productiondate = ProductionDate;
        ProductDetails[Name].ingredients = Ingredients;
        ProductDetails[Name].imgUrl = ImgUrl;
        ListOfProducts.push(ProductInfo(ListOfProducts.length+1,  Name, BatchID, OrganizationID, Country, Region, City, TestDate, ProductionDate, Ingredients , ImgUrl));
        ProductsName.push(Name);

        PrdBatchID[BatchID].uid = ListOfProducts.length+1;
        PrdBatchID[BatchID].name = Name;
        PrdBatchID[BatchID].batchid = BatchID;
        PrdBatchID[BatchID].organizationid = OrganizationID;
        PrdBatchID[BatchID].country = Country;
        PrdBatchID[BatchID].region = Region;
        PrdBatchID[BatchID].city = City;
        PrdBatchID[BatchID].testdate = TestDate;
        PrdBatchID[BatchID].productiondate = ProductionDate;
        PrdBatchID[BatchID].ingredients = Ingredients;
        PrdBatchID[BatchID].imgUrl = ImgUrl;

        emit ProductAdded (ListOfProducts.length+1, Name,
        BatchID,
        OrganizationID,
        Country,
        Region,
        City,
        TestDate,
        ProductionDate,
        Ingredients, ImgUrl);


    }

    function FilterProductsByName(string memory NAME) public view returns (ProductInfo[] memory){
        ProductInfo[] memory elements = new ProductInfo[](ListOfProducts.length);
      for (uint i = 0; i < ListOfProducts.length; i++) {

          if (equal((ProductDetails[NAME].name) , (NAME)) ) {
            elements[i] = ListOfProducts[i];
      } 
    
      } 
      return (elements);
  }

    function FilterProductsByBatchID(string memory BATCHID) public view returns (ProductInfo[] memory){
        ProductInfo[] memory elements = new ProductInfo[](ListOfProducts.length);
      for (uint i = 0; i < ListOfProducts.length; i++) {

          if (equal((PrdBatchID[BATCHID].batchid) , (BATCHID)) ) {
            elements[i] = ListOfProducts[i];
      } 
    
      } 
      return (elements);
  }

    function getProductsCount() public view returns(uint count){
        require(
            AdminsDetails[msg.sender].role == roles.admin,
            "Only admin can call this function"
        );
        return ProductsList[msg.sender].length;
    }

    function getProductsListByName() public view returns(string[] memory){
        return ProductsName;
    }

    function getArrayProducts() public view returns(ProductInfo[] memory) {
        return ListOfProducts;
    }

    function getProductsUID(uint256 _productId) public view returns (uint256){
        return PrdUID[_productId].uid;
    }



/*********************************************** Ingredients *********************************************/
    mapping(address => address[])  IngredientsList;

    struct IngredientInfo {
        uint256 uid;
        string name;
        string batchid;
        address organizationid;
        string location;
        uint256 lotNumber;
    }

    mapping(uint256 => IngredientInfo) IngredientsUID;
    mapping(string => IngredientInfo) IngredientDetails;
    mapping(string => IngredientInfo) IngBatchID;
    IngredientInfo[] private  ListOfIngredients;
    string[] private IngredientsName;
   
  
    function FliterIngredientsByName(string memory NAME) public view returns (IngredientInfo[] memory){
        IngredientInfo[] memory elements = new IngredientInfo[](ListOfIngredients.length);
      for (uint i = 0; i < ListOfIngredients.length; i++) {

          if (equal((IngredientDetails[NAME].name) , (NAME)) ) {
            elements[i] = ListOfIngredients[i];
      } 
    
      } 
      return (elements);
    }

    function FliterIngredientsByBatchID(string memory BATCHID) public view returns (IngredientInfo[] memory){
        IngredientInfo[] memory elements = new IngredientInfo[](ListOfIngredients.length);
      for (uint i = 0; i < ListOfIngredients.length; i++) {

          if (equal((IngBatchID[BATCHID].batchid) , (BATCHID)) ) {
            elements[i] = ListOfIngredients[i];
      } 
    
      } 
      return (elements);
    }

    function getIngrendientsName(string memory NAME) public view returns (IngredientInfo[] memory){
        IngredientInfo[] memory elements = new IngredientInfo[](ListOfIngredients.length);
      for (uint i = 0; i < ListOfIngredients.length; i++) {

          if (equal((IngredientDetails[NAME].name) , (NAME)) ) {
            elements[i] = ListOfIngredients[i];
      } 
    
      } 
      return (elements);
    }

    event IngredientAdded(uint256 Uid,
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
        ListOfIngredients.length+1,
        Name,
        BatchID,
        OrganizationID,
        Location,
        LotNumber
        );

        IngredientsList[msg.sender].push(address(newIngredient));
        uint256 UID;
        IngredientsUID[UID].uid = ListOfIngredients.length+1;
        IngredientDetails[Name].uid = ListOfIngredients.length+1;
        IngredientDetails[Name].name= Name;
        IngredientDetails[Name].batchid = BatchID;
        IngredientDetails[Name].organizationid = OrganizationID;
        IngredientDetails[Name].location = Location;
        IngredientDetails[Name].lotNumber = LotNumber;
        ListOfIngredients.push(IngredientInfo(ListOfIngredients.length+1, Name, BatchID, OrganizationID, Location, LotNumber));
        IngredientsName.push(Name);


        IngBatchID[BatchID].uid = ListOfIngredients.length+1;
        IngBatchID[BatchID].name= Name;
        IngBatchID[BatchID].batchid = BatchID;
        IngBatchID[BatchID].organizationid = OrganizationID;
        IngBatchID[BatchID].location = Location;
        IngBatchID[BatchID].lotNumber = LotNumber;




        emit IngredientAdded (ListOfIngredients.length+1, Name,
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

    function getIngredientsUID(uint256 _ingredientId) public view returns (uint256){

        return IngredientsUID[_ingredientId].uid;
    }

/*******************************************************certificates******************************************************************/


    struct ProductCertificates{
        uint256 UID;
        string URL;
    }

    mapping(uint256 => ProductCertificates) public ProductCertificatesList;

    function AddProductCertificates(uint256 _productId, string memory _URL) public {
        require(
            AdminsDetails[msg.sender].role == roles.admin,
            "Only admin can call this function"
        );

        uint256 uid = getProductsUID(_productId);

        ProductCertificatesList[_productId] = ProductCertificates(uid, _URL);


    } 


    struct IngredientCertificates{
        uint256 UID;
        string URL;
    }

    mapping(uint256 => IngredientCertificates) public IngredientCertificatesList;

    function AddIngredientCertificates(uint256 _ingId, string memory _URL) public {
        require(
            AdminsDetails[msg.sender].role == roles.admin,
            "Only admin can call this function"
        );

        uint256 uid = getIngredientsUID(_ingId);

        IngredientCertificatesList[_ingId] = IngredientCertificates(uid, _URL);


    } 

 
}