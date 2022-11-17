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

// File: tools/interfaces/IProtocol_in.sol

//SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

interface INDCA_V2in {
    /* STRUCT*/
    struct dashboardStruct{
        bool dcaActive;
        uint256 pairId;
        uint256 srcTokenAmount;
        uint256 tau;
        uint256 nextDcaTime;
        uint256 lastDcaTimeOk;
        uint256 destTokenEarned;
        uint256 exeRequired;//0 = Unlimited
        uint256 exeCompleted;
        uint averageBuyPrice;
        uint code;
        uint userError;
        bool allowanceOK;
        bool balanceOK;
    }
    /* WRITE METHODS*/
    function toggleRouter() external;//restricted to Proxy
    function createDCA(uint256 _pairId, address _userAddress, uint256 _srcTokenAmount, uint256 _tau, uint256 _exeRequired, bool _exeNow) external;//restricted to Proxy
    function closeDCA(uint256 _pairId, address _userAddress) external;//restricted to Proxy
    function DCAExecute(uint256 _dcaId) external;//restricted to Proxy
    function DCAResult(uint256 _dcaId, uint256 _destTokenAmount, uint _code, uint _unitaryPrice) external;//restricted to Proxy
    /* VIEW METHODS*/
    function numberDCAs() external view returns(uint256 actives, uint256 totals);//restricted to Proxy
    function neonStatus() external view returns(bool netActive, bool routerBusy);//restricted to Proxy
    function DCAChecks(uint256 _dcaId) external view returns(bool execute, bool allowanceOK, bool balanceOK);//restricted to Proxy
    function DCAInfo(uint256 _dcaId) external view returns(
        address srcToken,
        uint256 srcDecimals,
        address destToken,
        uint256 destDecimals,
        address reciever,
        uint256 typeAMM,
        uint256 srcTokenAmount
    );//restricted to Proxy
    function getDetails(uint256 _pairId, address _userAddress) external view returns(dashboardStruct memory);//restricted to Proxy
}

interface INHistorian_V2in {
    /* STRUCT*/
    struct detailStruct{
        uint256 pairId;
        uint256 closedDcaTime;
        uint256 destTokenEarned;
        uint reason; // (0 = Completed, 1 = User Close DCA, 2 = Insufficient User Approval or Balance)
    }
    /* WRITE METHODS*/
    function store(address _userAddress, detailStruct calldata _struct) external;//restricted to NDCA
    function deleteStore(address _userAddress, uint256 _storeId) external;//restricted to NDCA & Proxy
    /* VIEW METHODS*/
    function getHistoryDataBatch(address _userAddress) external view returns(detailStruct[] memory);//restricted to Proxy
    function getHistoryData(address _userAddress, uint256 _storeId) external view returns(uint256 closedDcaTime, uint256 destTokenEarned, uint reason, bool stored);//restricted to Proxy
}

interface INPairPool_V2in {
    /* VIEW METHODS*/
    function numberListedPairs() external view returns(uint256);
    function pairListed(uint256 _id) external view returns(address srcToken, uint256 srcDecimals, address destToken, uint256  destDecimals, uint typeAMM);
}
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

// File: NProxy-V2in.sol


pragma solidity 0.8.16;






contract NProxy_V2in is Ownable {
    struct resultStruct{
        uint256 dcaId;
        uint256 destTokenAmount;
        uint code;
        uint unitaryPrice;
    }
    
    address private NRouter;
    address private NPairPool;
    address private NHistorian;
    address private NDCA;

    /**
     * @dev Throws if called by any account other than the Router.
     */
    modifier onlyRouter() {
        require(msg.sender == NRouter, "NEON: Only Router is allowed");
        _;
    }
    /*
    * Constructor
    * () will be defined the unit of measure
    * @param _NDCA address of the NDCA
    * @param _NHistorian address of the NHistorian
    * @param _NRouter address of the NRouter
    * @param _NPairPool address of the NPairPool
    */
    constructor(address _NDCA, address _NHistorian, address _NRouter, address _NPairPool){
        NDCA = _NDCA;
        NHistorian = _NHistorian;
        NRouter = _NRouter;
        NPairPool = _NPairPool;
    }
    /* WRITE METHODS*/
    /*
    * @dev Define router address
    * () will be defined the unit of measure
    * @param _NRouter parameter to be modified, if 0 will be ignored
    * @param _NPairPool parameter to be modified, if 0 will be ignored
    * @param _NHistorian parameter to be modified, if 0 will be ignored
    * @param _NDCA parameter to be modified, if 0 will be ignored
    */
    function addressSettings(address _NDCA, address _NHistorian, address _NRouter, address _NPairPool) external onlyOwner {
        NDCA = _NDCA != address(0) ? _NDCA : NDCA;
        NHistorian = _NHistorian != address(0) ? _NHistorian : NHistorian;
        NRouter = _NRouter != address(0) ? _NRouter : NRouter;
        NPairPool = _NPairPool != address(0) ? _NPairPool : NPairPool;
    }
    /* UI*/
    /*
    * @user Create DCA
    * () will be defined the unit of measure
    * @param _pairId pair where will create a DCA
    * @param _srcTokenAmount (wei) amount to be sell every tau with all decimals
    * @param _tau execution frequency
    * @param _exeRequired number of execution required (0 = unlimited)
    * @param _exeNow if true the first execution will be at first router scan (in the day)
    */ 
    function createDCA(uint256 _pairId, uint256 _srcTokenAmount, uint256 _tau, uint256 _exeRequired, bool _exeNow) external {
        INDCA_V2in(NDCA).createDCA(_pairId, msg.sender, _srcTokenAmount, _tau, _exeRequired, _exeNow);
    }
    /*
    * @user Close DCA
    * () will be defined the unit of measure
    * @param _pairId pair where DCA will be closed
    */ 
    function closeDCA(uint256 _pairId) external {
        INDCA_V2in(NDCA).closeDCA(_pairId, msg.sender);
    }
    /*
    * @user Delete Stored data
    * @param _storeId data id to be deleted
    */
    function deleteStore(uint256 _storeId) external {
        INHistorian_V2in(NHistorian).deleteStore(msg.sender, _storeId);
    }
    /* ROUTER*/
    /*
    * @router Toggle Router Status
    * () will be defined the unit of measure
    */
    function toggleRouter() external onlyRouter {
        INDCA_V2in(NDCA).toggleRouter();
    }
    /*
    * @router DCA-in Execute (pre-execution)
    * () will be defined the unit of measure
    * @param _dcaIds array of ids to execute the DCA (e.g. [1, 2, ..x])
    * @return array of bool (true = fund transfered, false = not)
    */ 
    function DCAExecuteBatch(uint256[] calldata _dcaIds) external onlyRouter {
        uint256 length = _dcaIds.length;
        for(uint256 i; i < length; i++){
            INDCA_V2in(NDCA).DCAExecute(_dcaIds[i]);
        }
    }
    /*
    * @router DCA-in Result (post-execution)
    * () will be defined the unit of measure
    * @param array of _data for dcas executed (e.g. [[1, 69, 200, 6],[2, 69, 200, 6]])
    */
    function DCAResultBatch(resultStruct[] calldata _data) external onlyRouter {
        uint256 length = _data.length;
        for(uint256 i; i < length; i++){
            INDCA_V2in(NDCA).DCAResult(_data[i].dcaId, _data[i].destTokenAmount, _data[i].code, _data[i].unitaryPrice);
        }
    }
    /* VIEW METHODS*/
    /*
    * @user Check if all related contract are defined
    * () will be defined the unit of measure
    * @return true if all related contract are defined
    */
    function isSettingsCompleted() external view returns(bool){
        return NRouter != address(0) && NPairPool != address(0) && NHistorian != address(0) && NDCA != address(0) ? true : false;
    }
    /*
    * @user Network Status
    * () will be defined the unit of measure
    * @return netActive true if network active
    * @return routerBusy true if router busy
    */
    function neonStatus() external view returns(bool netActive, bool routerBusy){
        return INDCA_V2in(NDCA).neonStatus();
    }
    /*
    * @user Check Pair blacklisted
    * () will be defined the unit of measure
    * @param _pairId id of the pair
    * @return true if blacklisted
    */
    function isBlackListed(uint256 _pairId) external view returns(bool){
        (address srcToken, , , , ) = INPairPool_V2in(NPairPool).pairListed(_pairId);
        return srcToken == address(0);
    }
    /*
    * @user Neon DCAs numbers
    * () will be defined the unit of measure
    * @return actives total Active DCAs
    * @return totals total DCAs Created
    */
    function numberDCAs() external view returns(uint256 actives, uint256 totals){
        return INDCA_V2in(NDCA).numberDCAs();
    }
    /* UI*/
    /*
    * @user Get info of current DCA (for creating)
    * () will be defined the unit of measure
    * @param _pairId id of the pair
    * @return dcaActive true if active
    * @return srcToken address of the selected token DCA
    * @return srcDecimals decimals of selected token DCA
    */
    function getCurrentInfo(uint256 _pairId) external view returns(bool dcaActive, address srcToken, uint256 srcDecimals){
        (srcToken, srcDecimals, , , ) = INPairPool_V2in(NPairPool).pairListed(_pairId);
        INDCA_V2in.dashboardStruct memory tempData = INDCA_V2in(NDCA).getDetails(_pairId, msg.sender);
        dcaActive = tempData.dcaActive;
    }
    /*
    * @user Details info for the user
    * () will be defined the unit of measure
    * @return concat array of dashboardStruct (each DCA detail occupies 13 positions, first parameter "false" = no DCAs found)
    */
    function getDetailsBatch() external view returns(INDCA_V2in.dashboardStruct[] memory){
        uint256 totalPairs = INPairPool_V2in(NPairPool).numberListedPairs();
        INDCA_V2in.dashboardStruct[] memory data = new INDCA_V2in.dashboardStruct[](totalPairs);
        uint256 id;
        for(uint256 i=1; i<=totalPairs; i++){
            INDCA_V2in.dashboardStruct memory tempData = INDCA_V2in(NDCA).getDetails(i, msg.sender);
            if(tempData.dcaActive){
                data[id] = tempData;
                id += 1;
            }
        }
        return data;
    }
    /*
    * @user History info for the user
    * () will be defined the unit of measure
    * @return concat array of detailStruct (each DCA history occupies 4 positions, "empty obj = no DCAs found)
    */
    function getHistoryDataBatch() external view returns(INHistorian_V2in.detailStruct[] memory){
        return INHistorian_V2in(NHistorian).getHistoryDataBatch(msg.sender);
    }
    /* ROUTER*/
    /*
    * @router Pre-Check for DCA execution [Router]
    * () will be defined the unit of measure
    * @param _dcaId DCA id
    * @return execute true when need to be execute & DCA active
    * @return allowanceOK true when allowance OK
    * @return balanceOK true when balance OK
    */
    function DCAChecks(uint256 _dcaId) external view onlyRouter returns(bool execute, bool allowanceOK, bool balanceOK){
        return INDCA_V2in(NDCA).DCAChecks(_dcaId);
    }
    /*
    * @router Info to execute DCA [Router]
    * () will be defined the unit of measure
    * @param _dcaId DCA id
    * @return srcToken address of the token
    * @return srcDecimals number of decimals
    * @return destToken address of the token
    * @return destDecimals number of decimals
    * @return reciever address user for DCA
    * @return typeAMM AMM that will execute the swap
    * @return srcTokenAmount amount to be swapped
    */
    function DCAInfo(uint256 _dcaId) external view onlyRouter returns(
        address srcToken,
        uint256 srcDecimals,
        address destToken,
        uint256 destDecimals,
        address reciever,
        uint256 typeAMM,
        uint256 srcTokenAmount
    ){
        return INDCA_V2in(NDCA).DCAInfo(_dcaId);
    }
}