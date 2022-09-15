/**
 *Submitted for verification at BscScan.com on 2022-09-15
*/

// SPDX-License-Identifier: MIT
// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: contracts/kyc.sol


pragma solidity ^0.8.4;


/// @title An KYC Contract for string KYC records .
/// @author Mayuresh Khemnar
/// @notice This contract is used for storing KYC records, and access this data with permission only
/// @custom:security-contact [email protected]
contract KYCContract is Ownable {
    
    /**
     * @property documentPackageHash - hash of the customer's document package
     * @property password - string password of customer acceount
     * @property userWalletAddress -user Wallet Address
     **/
    struct Customer {
        string documentPackageHash;
        string password;
        address userWalletAddress;
    }

    /**
     * @dev all Customers
     * username=>Customer Data
     **/
    mapping(string=>Customer) allCustomers;

    /**
     * @property password - string password of customer acceount
     * @property userWalletAddress -user Wallet Address
     **/
    struct Merchant{
        string password;
        address userWalletAddress;   
    }

    /**
     * @dev all Merchants 
     * username=>Merchant Data
     **/
    mapping(string=>Merchant) allMerchants;

    /**
     * @property toUsername - customer name 
     * @property timestamp -timestamp at the time request send
     * @property info -access information i.e. why 
     * @property status -status at the time request send
     * status value 1=rquested, 2= approved, -1= rejected
     **/
    struct Request{
        uint256 timestamp;
        string documentsAllowed;
        string info;
        uint256 openTime;
        uint256 closeTime;
        int8 status;
    }
    
    /**
     * @dev all Merchants Requests 
     * Merchants=>Customer=>Request Data
     **/
    mapping(string=>mapping(string=>Request)) allRequestsData;

    /**
     * @dev For customers 
     * to get all request send for them
     * customer username=>array of merchants names
     **/
    mapping(string=>string[]) allCustomersRequest;
    /**
     * @dev For customers 
     * to check request send for them already present
     * customer username=>merchant name=>true/false
     **/
    mapping(string=>mapping(string=>bool)) allCustomersRequestPresent;

    /**
     * @dev For Merchants 
     * to get all request send by them
     * Merchants username=>array of customer names
     **/
    mapping(string=>string[]) allMerchantsRequest;
    /**
     * @dev For Merchants 
     * to check all request send by them already present
     * Merchants username=>customer name=>true/false
     **/
    mapping(string=>mapping(string=>bool)) allMerchantsRequestPresent;

    /**
     * @dev For data access by admin 
     **/
    mapping(string=>mapping(string=>bool)) accessAllowedByAdmin;


    /**
     * @dev For History of data accessed 
     * @property fromUsername - Merchant name 
     * @property fromTimestamp -from timestamp at the time of allowed request
     * @property toTimestamp -to timestamp at the time of close request
     * @property info -access information i.e. why 
     * @property documentsAllowed - hashed value of allowed documents
     **/
     struct History{
        string fromUsername;
        uint256 fromTimestamp;
        uint256 toTimestamp;
        string info;
        string documentsAllowed;
     }

    /**
     * @dev For customers 
     * to get all request for them
     * customer username=>histroy of data access
     **/
    mapping(string=>History[]) accessHistory;

    /**
     * @dev Constants
     **/

    int8 constant REQUEST_SEND=1;
    int8 constant REQUEST_APPROVED=2;
    int8 constant REQUEST_REJECTED=-1;
    int8 constant REQUEST_CLOSED=3; 

    /**************************************************** 
     ********************* Events ***********************
     ****************************************************/
    event CustomerAdded(
        string username,
        string password,
        address userWalletAddress
    );
    
    event Customerupdated(
        string username,
        string documentPackageHash,
        string password,
        address userWalletAddress
    );
    
    event MerchantAdded(
        string username,
        string password,
        address userWalletAddress   
    );

    event RequestAdded(
        string fromUsername,
        string toUsername,
        uint256 timestamp,
        string info,
        int8 status
    );

    event RequestStatusChanged(
        string fromUsername,
        string toUsername,
        uint256 timestamp,
        string documentsAllowed,
        string info,
        int8 status
    );

    /**************************************************** 
     ********************* Modifiers ********************
     ****************************************************/

    modifier customerExist(string memory _username){
        require(bytes(allCustomers[_username].password).length != 0, 
                "Customer is not exist");
        _;
    }
    
    modifier validCustomer(string memory _username){
        require(allCustomers[_username].userWalletAddress==msg.sender, 
                "Customer wallet address is not correct");
        _;
    }

    modifier merchantExist(string memory _username){
        require(bytes(allMerchants[_username].password).length != 0, 
                "Merchant is not exist");
        _;
    }
    
    modifier validMerchants(string memory _username){
        require(allMerchants[_username].userWalletAddress==msg.sender, 
                "Merchant wallet address is not correct");
        _;
    }

    
    function approveRequestByOwner(
        string memory _fromMerchant,
        string memory _toUsername,
        bool status
        ) public merchantExist(_fromMerchant) customerExist(_toUsername) onlyOwner{
            accessAllowedByAdmin[_fromMerchant][_toUsername]=status;
        }

    /**************************************************** 
     ****************** Helper Functions ****************
     ****************************************************/
    //  String compare function
    function compareStrings(string memory a, string memory b) private pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }
    
    // to update closeing time 
    function updateHistoryData(
        string memory _fromMerchant,
        string memory _toUsername
        ) private {

            // find data index
            uint256 index;
            for (uint i = accessHistory[_toUsername].length-1; i >= 0; i--) {
                if(compareStrings(accessHistory[_toUsername][i].fromUsername,_fromMerchant) && accessHistory[_toUsername][i].toTimestamp==0){
                    index=i;
                    break;
                }
            }

            // update toTimestamp
            accessHistory[_toUsername][index].toTimestamp=block.timestamp;

    }

    /**************************************************** 
     ******************* Main Functions *****************
     ****************************************************/
    function createCustomer(
        string memory _username,
        string memory _password
        ) public{
        
        require(bytes(allCustomers[_username].password).length == 0, 
                "Customer is already exist");

        allCustomers[_username].password=_password;
        allCustomers[_username].userWalletAddress=msg.sender;
        
        emit CustomerAdded(
        _username,
        _password,
        msg.sender);
    }

    function updateCustomerData(
        string memory _username,
        string memory _documentPackageHash,
        string memory _password
        ) public customerExist(_username){
        
        allCustomers[_username].documentPackageHash=_documentPackageHash;
        allCustomers[_username].password=_password;
        allCustomers[_username].userWalletAddress=msg.sender;
        
        emit Customerupdated(
        _username,
        _documentPackageHash,
        _password,
        msg.sender);
    }

    function customerLogin(
        string memory _username,
        string memory _password
        ) public view customerExist(_username) validCustomer(_username) returns(bool,address){
        
        require(compareStrings(allCustomers[_username].password,_password),"Password is incorrect!");
        
        return(true,allCustomers[_username].userWalletAddress);
    }
    
    function createMerchant(
        string memory _username,
        string memory _password
        ) public {
        
        require(bytes(allMerchants[_username].password).length == 0, 
                "Merchant is already exist");

        allMerchants[_username].password=_password;
        allMerchants[_username].userWalletAddress=msg.sender;
        
        emit MerchantAdded(
        _username,
        _password,
        msg.sender);
    }

    function merchantLogin(
        string memory _username,
        string memory _password
        ) public view merchantExist(_username) validMerchants(_username) returns(bool,address){
        
        require(compareStrings(allMerchants[_username].password,_password),"Password is incorrect!");
        
        return(true,allMerchants[_username].userWalletAddress);
    }

    function sendAccessRequest(
        string memory _fromMerchant,
        string memory _toUsername,
        string memory _info
        ) public merchantExist(_fromMerchant) validMerchants(_fromMerchant)
        customerExist(_toUsername){

        require(allRequestsData[_fromMerchant][_toUsername].status!=REQUEST_APPROVED
            ,"Request already approved"); 
        require(allRequestsData[_fromMerchant][_toUsername].status!=REQUEST_SEND
            ,"Request already pending"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               );
        

        // added request in merchant request list
        allRequestsData[_fromMerchant][_toUsername].timestamp=block.timestamp;
        allRequestsData[_fromMerchant][_toUsername].info=_info;
        allRequestsData[_fromMerchant][_toUsername].status=REQUEST_SEND;

        // added request in customers view all requests if not already present
        if(!allCustomersRequestPresent[_fromMerchant][_toUsername]){
            allCustomersRequest[_toUsername].push(_fromMerchant);
            allCustomersRequestPresent[_fromMerchant][_toUsername]=true;
        }
        // added request in merchants view all requests if not already present
        if(!allMerchantsRequestPresent[_fromMerchant][_toUsername]){
            allMerchantsRequest[_fromMerchant].push(_toUsername);
            allMerchantsRequestPresent[_fromMerchant][_toUsername]=true;
        }

        emit RequestAdded(
        _fromMerchant,
        _toUsername,
        allRequestsData[_fromMerchant][_toUsername].timestamp,
        _info,
        REQUEST_SEND);
    }

    function getAllMyCustomersRequestsLength(
        string memory _username
        ) public view customerExist(_username) validCustomer(_username) returns(uint256){
            return allCustomersRequest[_username].length;
    }
    
    function  getAllMyCustomersRequestsData(
        string memory _username,
        uint256 i
        ) public view customerExist(_username) validCustomer(_username) returns(string memory){
            return allCustomersRequest[_username][i];
    }

    function getAllMyMerchantsRequestsLength(
        string memory _fromMerchant
        ) public view merchantExist(_fromMerchant) validMerchants(_fromMerchant) returns(uint256){
            return allMerchantsRequest[_fromMerchant].length;
    }
    
    function  getAllMyMerchantsRequestsData(
        string memory _fromMerchant,
        uint256 i
        ) public view merchantExist(_fromMerchant) validMerchants(_fromMerchant) returns(string memory){
            return allMerchantsRequest[_fromMerchant][i];
    }

    function approveRequest(
        string memory _fromMerchant,
        string memory _toUsername,
        string memory _documentsAllowed,
        uint256 _closeTime
        ) public customerExist(_toUsername) validCustomer(_toUsername){
            
        require(allRequestsData[_fromMerchant][_toUsername].status==REQUEST_SEND,"Request Already processed");

        allRequestsData[_fromMerchant][_toUsername].closeTime=_closeTime;
        allRequestsData[_fromMerchant][_toUsername].status=REQUEST_APPROVED;
        allRequestsData[_fromMerchant][_toUsername].documentsAllowed=_documentsAllowed;
        allRequestsData[_fromMerchant][_toUsername].openTime=block.timestamp;

        //add history
        accessHistory[_toUsername].push(
            History(_fromMerchant,
                block.timestamp,
                _closeTime,
                allRequestsData[_fromMerchant][_toUsername].info,
                _documentsAllowed
            )
        ); 

        emit RequestStatusChanged(
            _fromMerchant,
            _toUsername,
            allRequestsData[_fromMerchant][_toUsername].timestamp,
            _documentsAllowed,
            allRequestsData[_fromMerchant][_toUsername].info,
            REQUEST_APPROVED
        );
    }

    function rejectRequest(
        string memory _fromMerchant,
        string memory _toUsername
        ) public customerExist(_toUsername) validCustomer(_toUsername){
            
        require(allRequestsData[_fromMerchant][_toUsername].status==REQUEST_SEND,"Request Already processed");
        
        allRequestsData[_fromMerchant][_toUsername].status=REQUEST_REJECTED;

        emit RequestStatusChanged(
            _fromMerchant,
            _toUsername,
            allRequestsData[_fromMerchant][_toUsername].timestamp,
            allRequestsData[_fromMerchant][_toUsername].documentsAllowed,
            allRequestsData[_fromMerchant][_toUsername].info,
            REQUEST_REJECTED
        );
    }

    function closeAccess(
        string memory _fromMerchant,
        string memory _toUsername
        ) public customerExist(_toUsername) validCustomer(_toUsername){
        
        require(allRequestsData[_fromMerchant][_toUsername].status!=REQUEST_CLOSED,"Request already closed!");
        
        allRequestsData[_fromMerchant][_toUsername].closeTime=block.timestamp;
        allRequestsData[_fromMerchant][_toUsername].status=REQUEST_CLOSED;
        
        // update history
        updateHistoryData(_fromMerchant,_toUsername);

        emit RequestStatusChanged(
            _fromMerchant,
            _toUsername,
            allRequestsData[_fromMerchant][_toUsername].timestamp,
            allRequestsData[_fromMerchant][_toUsername].documentsAllowed,
            allRequestsData[_fromMerchant][_toUsername].info,
            REQUEST_CLOSED
        );
    }

    //get allRequestsData
    // only merchant or customer who is in that request can view
    function getAllRequestsData(
        string memory _fromMerchant,
        string memory _toUsername
        ) public view customerExist(_toUsername) merchantExist(_fromMerchant) returns(Request memory){

            require(allCustomers[_toUsername].userWalletAddress==msg.sender ||
                allMerchants[_fromMerchant].userWalletAddress==msg.sender 
                ,"You can't access this request details");

            return allRequestsData[_fromMerchant][_toUsername];
    }

    //get access History
    function getAllMyAccessHistoryLength(
        string memory _username
        ) public view customerExist(_username) validCustomer(_username) returns(uint256){
            return accessHistory[_username].length;
    }

    function getMyAccessHistoryData(
        string memory _username,
        uint256 i
        ) public view customerExist(_username) validCustomer(_username) returns(History memory){
            return accessHistory[_username][i];
    }

    //update request status
    function checkRequestStatus(
        string memory _fromMerchant,
        string memory _toUsername
        ) public merchantExist(_fromMerchant) validMerchants(_fromMerchant) {
            if(allRequestsData[_fromMerchant][_toUsername].closeTime<block.timestamp){
                allRequestsData[_fromMerchant][_toUsername].status=REQUEST_CLOSED;
                emit RequestStatusChanged(
                    _fromMerchant, 
                    _toUsername, 
                    allRequestsData[_fromMerchant][_toUsername].timestamp, 
                    allRequestsData[_fromMerchant][_toUsername].documentsAllowed, 
                    allRequestsData[_fromMerchant][_toUsername].info, 
                    allRequestsData[_fromMerchant][_toUsername].status);
            }
    }

    //get user Data
    function getUserData(
        string memory _fromMerchant,
        string memory _toUsername
        ) public view merchantExist(_fromMerchant) validMerchants(_fromMerchant) returns(string memory,string memory){

            require(
                (
                    allRequestsData[_fromMerchant][_toUsername].status==REQUEST_APPROVED 
                    && 
                    allRequestsData[_fromMerchant][_toUsername].closeTime>block.timestamp
                )
                || 
                accessAllowedByAdmin[_fromMerchant][_toUsername]
            ,"You don't have access!");
            return (allCustomers[_toUsername].documentPackageHash,allRequestsData[_fromMerchant][_toUsername].documentsAllowed);
    }

    function getMyData(
        string memory _toUsername
        ) public view customerExist(_toUsername) validCustomer(_toUsername) returns(string memory){
            return allCustomers[_toUsername].documentPackageHash;
    }
    
}