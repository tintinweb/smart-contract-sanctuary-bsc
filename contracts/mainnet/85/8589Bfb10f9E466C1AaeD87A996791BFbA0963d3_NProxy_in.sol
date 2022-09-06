/**
 *Submitted for verification at BscScan.com on 2022-09-06
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

// File: NProxy-in.sol


pragma solidity 0.8.16;


interface INDCA_in {
    struct dashboardStruct{
        bool dcaActive;
        uint256 srcTokenAmount;
        uint256 tau;
        uint256 nextDcaTime;
        uint256 lastDcaTimeOk;
        uint256 destTokenEarned;
        uint256 nExRequired;//0 = Unlimited
        uint256 nExCompleted;
        uint averageBuyPrice;
        uint code;
        bool allowanceOK;
        bool balanceOK;
    }

    function createDCA(uint256 _dcaIndex, address _userAddress, uint256 _srcTokenAmount, uint256 _tau, uint256 _nExRequired) external;//restricted
    function closeDCA(uint256 _dcaIndex, address _userAddress) external;//restricted
    function deleteStore(uint256 _dcaIndex, address _userAddress, uint256 _storeId) external;//restricted
    function dashboardUser(uint256 _dcaIndex, address _userAddress) external view returns(dashboardStruct memory);//restricted
    function neonNetStatus() external view returns(bool);
    function isRouterBusy() external view returns(bool);
    function pairListed(uint256 _dcaIndex) external view returns(address srcToken, uint256 srcDecimals, address destToken, uint256 destDecimals);
    function totalDCA() external view returns(uint256);
    function totalUsers(uint256 _dcaIndex) external view returns(uint256);
    function totalNetUsers() external view returns(uint256);
}

interface INHystorian_in {
    struct detailStruct{
        uint256 lastDcaTimeOk;
        uint256 destTokenEarned;
        bool storeOk;
    }
    
    function userHystorianBatch(uint256 _dcaIndex, address _userAddress) external view returns(detailStruct[] memory);//restricted
    function userHystorian(uint256 _dcaIndex, address _userAddress, uint256 _storeId) external view returns(detailStruct memory);//restricted
}

contract NProxy_in is Ownable {
    address private neonDCA;
    address private neonHystorian;

    /*
    * Constructor
    * () will be defined the unit of measure
    * @param _neonDCA address of the NDCA
    * @param _neonHystorian address of the NHystorian
    */
    constructor(address _NDCA, address _NHystorian){
          neonDCA = _NDCA;
          neonHystorian = _NHystorian;
    }
    /* WRITE METHODS*/
    /*
    * @dev Define router address
    * () will be defined the unit of measure
    * @param _account address
    * @requirement diff. 0x00
    */
    function setNDCA(address _account) external onlyOwner {
          require(_account != address(0), "NEON: null address not allowed");
          neonDCA = _account;
    }
    /*
    * @dev Define Hystorian address
    * () will be defined the unit of measure
    * @param _account address
    * @req diff. 0x00
    */
    function setHystorian(address _account) external onlyOwner {
        require(_account != address(0), "NEON: null address not allowed");
        neonHystorian = _account;
    }
    /*
    * @user Create DCA
    * !User must approve amount to this SC in order to create it!
    * () will be defined the unit of measure
    * @param _dcaIndex  pair where will be created the DCA
    * @param _srcTokenAmount amount to be sell every tau
    * @param _tau time for each execution
    * @param _nExRequired number of execution required (0 = unlimited)
    */ 
    function createDCA(uint256 _dcaIndex, uint256 _srcTokenAmount, uint256 _tau, uint256 _nExRequired) external {
        INDCA_in dca = INDCA_in(neonDCA);
        dca.createDCA(_dcaIndex, msg.sender, _srcTokenAmount, _tau, _nExRequired);
    }
    /*
    * @user Delete DCA
    * () will be defined the unit of measure
    * @param _dcaIndex DCA where delete the DCA
    */ 
    function closeDCA(uint256 _dcaIndex) external {
        INDCA_in dca = INDCA_in(neonDCA);
        dca.closeDCA(_dcaIndex, msg.sender);
    }
    /*
    * @user Delete Store from Hystorian
    * () will be defined the unit of measure
    * @param _dcaIndex DCA where is associated the store
    * @param _storeId id of the store to be deleted
    */ 
    function deleteStore(uint256 _dcaIndex, uint256 _storeId) external {
        INDCA_in dca = INDCA_in(neonDCA);
        dca.deleteStore(_dcaIndex, msg.sender, _storeId);
    }
    /* VIEW METHODS*/
    /*
    * @view Network Status
    * () will be defined the unit of measure
    * @return true if network active
    */
    function neonNetStatus() external view returns(bool){
        INDCA_in dca = INDCA_in(neonDCA);
        return dca.neonNetStatus();
    }
    /*
    * @view Router Status
    * () will be defined the unit of measure
    * @return true if router is busy
    */
    function isRouterBusy() external view returns(bool){
        INDCA_in dca = INDCA_in(neonDCA);
        return dca.isRouterBusy();
    }
    /*
    * @view token listed address
    * () will be defined the unit of measure
    * @param _dcaIndex Pair ID
    * @return srcToken address source token
    * @return srcDecimals number of decimals
    * @return destToken address destination token
    * @return destDecimals number of decimals
    */
    function pairListed(uint256 _dcaIndex) external view returns(address srcToken, uint256 srcDecimals, address destToken, uint256 destDecimals){
        INDCA_in dca = INDCA_in(neonDCA);
        (srcToken, srcDecimals, destToken, destDecimals) = dca.pairListed(_dcaIndex);
    }
    /*
    * @view Dashboard info for the user
    * () will be defined the unit of measure
    * @param _dcaIndex DCA where needed information
    * @return dashboardStruct data structure of user info displayed in the Dapp
    */    
    function dashboardUser(uint256 _dcaIndex) external view returns(INDCA_in.dashboardStruct memory){
        INDCA_in dca = INDCA_in(neonDCA);
        INDCA_in.dashboardStruct memory data = dca.dashboardUser(_dcaIndex, msg.sender);
        return data;
    }
    /*
    * @view Total DCAs
    * () will be defined the unit of measure
    * @return uint256 total listed DCAs
    */
    function totalDCA() external view returns(uint256){
        INDCA_in dca = INDCA_in(neonDCA);
        return dca.totalDCA();
    }
    /*
    * @view Total users into specific DCA
    * () will be defined the unit of measure
    * @param _dcaIndex DCA number
    * @return uint256 number of total users into the DCA
    */
    function totalUsers(uint256 _dcaIndex) external view returns(uint256){
        INDCA_in dca = INDCA_in(neonDCA);
        return dca.totalUsers(_dcaIndex);
    }
    /*
    * @view Total Protocol Users
    * () will be defined the unit of measure
    * @return uint256 number of total users into the protocol
    */
    function totalNetUsers() external view returns(uint256){
        INDCA_in dca = INDCA_in(neonDCA);
        return dca.totalNetUsers();
    }
    /*
    * @view Hystorian All info for the user (Struct)
    * () will be defined the unit of measure
    * @param _dcaIndex pair where has been associated the store
    * @return detailStruct user informations
    */
    function userHystorianBatch(uint256 _dcaIndex) external view returns(INHystorian_in.detailStruct[] memory){
        INHystorian_in dca = INHystorian_in(neonHystorian);
        return dca.userHystorianBatch(_dcaIndex, msg.sender);
    }
    /*
    * @view Hystorian info for the user (Single Struct)
    * () will be defined the unit of measure
    * @param _dcaIndex pair where has been associated the store
    * @return detailStruct user informations
    */
    function userHystorian(uint256 _dcaIndex, uint256 _storeId) external view returns(INHystorian_in.detailStruct memory){
        INHystorian_in dca = INHystorian_in(neonHystorian);
        return dca.userHystorian(_dcaIndex, msg.sender, _storeId);
    }
}