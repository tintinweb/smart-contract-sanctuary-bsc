/**
 *Submitted for verification at BscScan.com on 2022-11-17
*/

/*
                                            ......                                        
                                         ............                                     
                                       ............:....                                  
                                    .................:.....                               
                                  ......................:.....                            
                                ........ .................::.....                         
                             ......... .....................::.....                       
                           ........  .........................:::.....                    
                         ........  ........       ...:..........:::.....                  
                      ......... ........            ...::.........::::.....               
                    ........  ........       ....     ...::..........:::.....             
                  ........ ........        ........     ...:::.........::::.....          
               ........  ........       ...       ....     ...:::........:::::....        
             ........  .......       ....           .....    ...::::........::::....      
           .......   .......       ...                ..:...   ...:::::......:::-:...     
          .......   ......       ...                    ..::..   ...::::......:::-:...    
          .......    .....     ...                        ..::.   ..::-:......::--....    
           .......   ......    ...                        ..::.  ...:::.......:-::...     
            .......   ......     ..                      .::......::::.......:-:....      
             ........  ......     ...                   .::......:::.......::-:....       
              ...:..... .......    ...                ..::......:-:.......:-::....        
                ...:.........:...   ....             .::......::::.......:-:....          
                 ...:.........::..   ..:..          .::......:-::......:--:....           
                  ...::.........:...  ..:..       ..::......:-:.......:-::....            
                   ...::.........:...  ..::.     .:::.....::::.......:-:....              
                    ....:.........::..  ..::.. ..::......:-::......::-:....               
                     ....:.........::... ...::::::......:-::......:--:....                
                      ....::........::.......:--:.....::-:.......:-::...                  
                        ...::........:::... ..:......:-::......::-:....                   
                         ...:::.......:::...     ...:-::......:--:....                    
                          ...:::........:::... ...::-::......:-::....                     
                           ....:::.......::::...::-::......::-:....                       
                            ....:::.......::-::::-::......:--:....                        
                              ...:::.......::-:--::......:--:....                         
                               ....:::......::-::......::-::...                           
                                ....:::...............:--::...                            
                                 ....:-:.............:--:....                             
                                  ....:-::.........::--:....                              
                                   ....:--::.....:::-::...                                
                                     ...::-:::::::--::...                                 
                                      ...::--::::--::...                                  
                                       ....:--:---:...                                    
                                         ...::--::...                                     
                                          ....:.....                                      
                                             ....                                         
                                                                                          
                           +%#  -%#    %%%%%#    *%%%#=    *%*  +%+                         
                           +%%= -%#    %%+...   +%#.-%%.   *%%- +%+                         
                           +%%# -%#    %%=      +%# :%%:   *%%# +%+                         
                           +%#%=-%#    %%*--    +%# :%%:   *%#%-+%+                         
                           +%++%+%#    %%###    +%# :%%:   *%=*#+%+                         
                           +%+.%%%#    %%=      +%# :%%:   *%=:%%%+                         
                           +%+ +%%#    %%=      +%# :%%:   *%= *%%+                         
                           +%+  #%#    %%*===   -%%=+%#    *%= .%%+                         
                           -+=  -++    ++++++    -+**+.    ++-  =+=                                                                                                                
*/

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

// File: NHistorian-V2in.sol


pragma solidity 0.8.16;


contract NHistorian_V2in is Ownable {

    struct dataStruct{
        mapping (uint256 => detailStruct) userData;
        uint256 storeID;
        uint256 bufferID;
    }

    struct detailStruct{
        uint256 pairId;
        uint256 closedDcaTime;
        uint256 destTokenEarned;
        uint reason; // (0 = Completed, 1 = User Close DCA, 2 = Insufficient User Approval or Balance)
    }

    mapping (address => dataStruct) private database;

    address private NDCA;
    address private NProxy;

    event Stored(address _owner, uint256 _storeId, uint256 _timestamp);
    event DeletedStore(address _owner, uint256 _storeId, uint256 _timestamp);

     /**
     * @dev Throws if called by any account other than the NDCA.
     */
    modifier onlyNDCA() {
        require(msg.sender == NDCA, "NEON: Only NDCA is allowed");
        _;
    }
    /**
     * @dev Throws if called by any account other than the NDCA.
     */
    modifier onlyProxy() {
        require(msg.sender == NProxy, "NEON: Only Proxy is allowed");
        _;
    }
    /**
     * @dev Throws if called by any account other than the NDCA or Proxy.
     */
    modifier onlyNDCAnProxy() {
        require(msg.sender == NDCA || msg.sender == NProxy, "NEON: Only NDCA & Proxy is allowed");
        _;
    }

    /* WRITE METHODS*/
    /*
    * @dev Define Addresses Settings of the contract
    * () will be defined the unit of measure
    * @param _NDCA address of NDCA contract, if 0x00 will not be modify
    * @param _NProxy address of NDCA contract, if 0x00 will not be modify
    */
    function addressSettings(address _NDCA, address _NProxy) external onlyOwner {
        NDCA = _NDCA != address(0) ? _NDCA : NDCA;
        NProxy = _NProxy != address(0) ? _NProxy : NProxy;
    }
    /*
    * @NDCA Store data
    * () will be defined the unit of measure
    * @param _userAddress address that own the DCA
    * @param _struct data to be stored
    */
    function store(address _userAddress, detailStruct calldata _struct) external onlyNDCA {
        require(_userAddress != address(0), "NEON: null address not allowed");
        dataStruct storage data = database[_userAddress];
        uint256 storeID;
        if(data.bufferID == 0){
            storeID = data.storeID;
            data.storeID += 1;
        }else{
            storeID = data.bufferID - 1;
        }
        data.userData[storeID + 1].pairId = _struct.pairId;
        data.userData[storeID + 1].closedDcaTime = _struct.closedDcaTime > 0 ? _struct.closedDcaTime : block.timestamp;//Manage case of DCA closed without exe
        data.userData[storeID + 1].destTokenEarned = _struct.destTokenEarned;
        data.userData[storeID + 1].reason = _struct.reason;
        //buffer
        if(data.storeID >= 200){
            data.bufferID = data.bufferID >= 200 ? 1 : data.bufferID + 1; 
        }
        emit Stored(_userAddress, storeID, block.timestamp);
     }
    /*
    * @NDCA&Proxy Delete Stored data
    * () will be defined the unit of measure
    * @param _userAddress address that own the store
    * @param _storeId data id to be deleted
    */
    function deleteStore(address _userAddress, uint256 _storeId) external onlyNDCAnProxy {
        require(_userAddress != address(0), "NEON: Address not defined");
        dataStruct storage data = database[_userAddress];
        uint256 storeID = data.storeID;
        require(_storeId <= storeID, "NEON: Store ID out of limit");
        for(uint256 i=_storeId; i<=storeID; i++){
            data.userData[i] = data.userData[i + 1];
        }
        data.storeID -= 1;
        if(_storeId == data.bufferID){
            data.bufferID -= 1;
        }
        emit DeletedStore(_userAddress, _storeId, block.timestamp);
     }
    /* VIEW METHODS*/
    /*
    * @user Check ifall related contract are defined
    * () will be defined the unit of measure
    * @return true if all related contract are defined
    */
    function isSettingsCompleted() external view returns(bool){
        return NDCA != address(0) && NProxy != address(0) ? true : false;
    }
    /*
    * @proxy History info for the user (Array Struct) Batch
    * () will be defined the unit of measure
    * @param _userAddress address that own the store
    * @return detailStruct user informations
    */
    function getHistoryDataBatch(address _userAddress) external onlyProxy view returns(detailStruct[] memory){
        dataStruct storage data = database[_userAddress];
        uint256 storeID = data.storeID;
        detailStruct[] memory dataOut = new detailStruct[](storeID);
        for(uint256 i=1; i<=storeID; i++){
            dataOut[i-1] = data.userData[i];
        }
        return dataOut;
    }
    /*
    * @proxy History info for the user
    * () will be defined the unit of measure
    * @param _userAddress address that own the store
    * @param _storeId data id to get info
    * @return closedDcaTime DCA closed time
    * @return destTokenEarned DCA total token earned
    * @return stored confirmation data correctly stored
    */
    function getHistoryData(address _userAddress, uint256 _storeId) external onlyProxy view returns(uint256 pairId, uint256 closedDcaTime, uint256 destTokenEarned, uint reason){
        dataStruct storage data = database[_userAddress];
        pairId = data.userData[_storeId].pairId;
        closedDcaTime = data.userData[_storeId].closedDcaTime;
        destTokenEarned = data.userData[_storeId].destTokenEarned;
        reason = data.userData[_storeId].reason;
    }
}