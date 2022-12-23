/**
 *Submitted for verification at BscScan.com on 2022-12-22
*/

pragma solidity >=0.8.0;
// SPDX-License-Identifier: MIT

contract SupplyChain {

    
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


/*********************************************** Products ***********************************************/


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
    uint256 private productCounter = 0;
   
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
        productCounter++;
        

        ProductDetails[Name].name = Name;
        ListOfProducts.push(ProductInfo(productCounter,  Name, BatchID, OrganizationID, Country, Region, City, TestDate, ProductionDate, Ingredients , ImgUrl));
        ProductsName.push(Name);
        emit ProductAdded (productCounter, Name,
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
        uint256 counter =0;
        ProductInfo[] memory elements = new ProductInfo[](ListOfProducts.length);
      for (uint i = 0; i < ListOfProducts.length; i++) {

          if (equal((ProductDetails[NAME].name) , (NAME)) ) {
              counter++;
            elements[counter-1] = ListOfProducts[i];
      } 
    
      } 
      return (elements);
  } 

    function FilterProductsByBatchID(string memory BATCHID) public view returns (ProductInfo[] memory){
        uint256 counter =0;
        ProductInfo[] memory elements = new ProductInfo[](ListOfProducts.length);
      for (uint i = 0; i < ListOfProducts.length; i++) {

          if (equal((PrdBatchID[BATCHID].batchid) , (BATCHID)) ) {
              counter++;
            elements[counter-1] = ListOfProducts[i];
      } 
    
      } 
      return (elements);
  }

    function getProductsCount() public view returns(uint count){
        require(
            AdminsDetails[msg.sender].role == roles.admin,
            "Only admin can call this function"
        );
        return ListOfProducts.length;
    }

    function getProductsListByName() public view returns(string[] memory){
        return ProductsName;
    }

    function getArrayProducts() public view returns(ProductInfo[] memory) {
        return ListOfProducts;
    }

    function getProductsUID(uint256 _productId) public view returns (uint256){
        
        for(uint256 i =0; i<ListOfProducts.length; i++){
            if(ListOfProducts[i].uid == _productId){
                 return ListOfProducts[i].uid;

            }
        } 

        return 0; 
    }



/*********************************************** Ingredients *********************************************/

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
        uint256 counter =0;
      for (uint i = 0; i < ListOfIngredients.length; i++) {

          if (equal((IngredientDetails[NAME].name) , (NAME)) ) {
              counter++;
            elements[counter-1] = ListOfIngredients[i];
      } 
    
      } 
      return (elements);
    }

    function FliterIngredientsByBatchID(string memory BATCHID) public view returns (IngredientInfo[] memory){
        IngredientInfo[] memory elements = new IngredientInfo[](ListOfIngredients.length);
        uint256 counter =0;
      for (uint i = 0; i < ListOfIngredients.length; i++) {

          if (equal((IngBatchID[BATCHID].batchid) , (BATCHID)) ) {
              counter++;
            elements[counter-1] = ListOfIngredients[i];
      } 
    
      } 
      return (elements);
    }


    event IngredientAdded(uint256 Uid,
        string indexed Name, string indexed BatchID, address  indexed OrganizationID, string  Location , uint256  LotNumber
    );
    uint256 private IngredientCoounter = 0;

    function  AddIngredient(
        string memory Name, string memory BatchID, address OrganizationID, string memory Location ,  uint256 LotNumber
        ) public {
        require(
            AdminsDetails[msg.sender].role == roles.admin,
            "Only admin can call this function"
        );
        IngredientCoounter++;

        IngredientDetails[Name].name= Name;
        ListOfIngredients.push(IngredientInfo(IngredientCoounter, Name, BatchID, OrganizationID, Location, LotNumber));
        IngredientsName.push(Name);

        emit IngredientAdded (IngredientCoounter, Name,
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
        return ListOfIngredients.length;
    }

    function getIngredientsUID(uint256 _ingredientId) public view returns (uint256){
     
     for(uint256 i =0; i<ListOfIngredients.length; i++){
            if(ListOfIngredients[i].uid == _ingredientId){
                 return ListOfIngredients[i].uid;

            }
        } 

        return 0; 
    }

/*******************************************************certificates******************************************************************/

    struct ProductCertificates{
        uint256 UID;
        uint256 P_ID;
        string CertificateName;
        string URL; 
    }

    ProductCertificates[] private ListofPrdCertificates;
        uint256  ProductCertificatesCounter = 0;
    

    function AddProductCertificates(uint256 _productId, string[] memory _CertificateName, string[] memory _URL) public {
        require(
            AdminsDetails[msg.sender].role == roles.admin,
            "Only admin can call this function"
        );
        require(
            _CertificateName.length == _URL.length, 
            "Number of _CertificateName must match the number of _URLS"
        );

        uint256 pid = getProductsUID(_productId);

        for(uint256 i=0; i<_CertificateName.length; i++){
            
            ProductCertificatesCounter++;
            ProductCertificates memory _PC = ProductCertificates(ProductCertificatesCounter, pid, _CertificateName[i], _URL[i]);
            ListofPrdCertificates.push(_PC);


        }

    } 


    
    function getProductCertificatesByP_ID(uint256 P_id) public view returns (ProductCertificates[] memory){

         ProductCertificates[] memory elements = new ProductCertificates[](ListofPrdCertificates.length);
         uint256 counter =0;
      for (uint i = 0; i < ListofPrdCertificates.length; i++) {

          if (P_id == ListofPrdCertificates[i].P_ID ) {
              counter++;
            elements[counter-1] = ListofPrdCertificates[i];
      } 
    
      } 
      return (elements);

    }

    function getArrayProductsCertificate() public view returns ( ProductCertificates[] memory) {
        return ListofPrdCertificates;
    }


    struct IngredientCertificates{
        uint256 UID;
        uint256 I_ID;
        string CertificateName;
        string URL;
    }



    IngredientCertificates[] private ListofIngCertificate;    
    uint256 IngredientCertificatesCounter = 0;

    function AddIngredientCertificates(uint256 _ingId, string[] memory _CertificateName, string[] memory _URL) public {
        require(
            AdminsDetails[msg.sender].role == roles.admin,
            "Only admin can call this function"
        );
        require(
            _CertificateName.length == _URL.length, 
            "Number of _CertificateName must match the number of _URLS"
        );

        uint256 iid = getIngredientsUID(_ingId);
        for(uint256 i=0; i<_CertificateName.length; i++){
            IngredientCertificatesCounter++;
            IngredientCertificates memory _IC = IngredientCertificates(IngredientCertificatesCounter, iid,  _CertificateName[i], _URL[i]);
            ListofIngCertificate.push(_IC); 


        }



    } 

    function getIngredientCertificatesByI_ID(uint256 I_id) public view returns (IngredientCertificates[] memory){

         IngredientCertificates[] memory elements = new IngredientCertificates[](ListofIngCertificate.length);
         uint256 counter =0;
      for (uint i = 0; i < ListofIngCertificate.length; i++) {

          if (I_id == ListofIngCertificate[i].I_ID ) {
              counter++;
            elements[counter-1] = ListofIngCertificate[i];
      } 
    
      } 
      return (elements);

    }


    function getArrayIngredientsCertificate() public view returns (IngredientCertificates[] memory) {
        return ListofIngCertificate;
    }
 
}