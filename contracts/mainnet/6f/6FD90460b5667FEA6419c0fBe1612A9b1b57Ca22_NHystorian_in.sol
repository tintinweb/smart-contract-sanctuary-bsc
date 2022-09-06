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

// File: @openzeppelin/contracts/utils/math/SafeMath.sol


// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// File: NHystorian-in.sol


pragma solidity 0.8.16;



interface INPairPool_in {
    function numberListedPairs() external view returns (uint256);
}

contract NHystorian_in is Ownable {
     using SafeMath for uint256;

    struct pairStruct{
        mapping (address => dataStruct) users;
    }

    struct dataStruct{
        mapping (uint256 => detailStruct) userData;
        uint256 nStore;
        uint256 idxBuffer;
    }
    
    struct detailStruct{
        uint256 lastDcaTimeOk;
        uint256 destTokenEarned;
        bool storeOk;
    }

    mapping (uint256 => pairStruct) private database;

    address private neonDCA;
    address private neonPairPool;
    address private neonProxy;

    event Stored(address _owner, uint256 _storeId, uint256 _timestamp);
    event DeletedStore(address _owner, uint256 _storeId, uint256 _timestamp);

     /**
     * @dev Throws if called by any account other than the NDCA.
     */
    modifier onlyNeonDCA() {
        require(msg.sender == neonDCA, "NEON: Only NDCA is allowed");
        _;
    }
    /**
     * @dev Throws if called by any account other than the NDCA.
     */
    modifier onlyProxy() {
        require(msg.sender == neonProxy, "NEON: Only Proxy is allowed");
        _;
    }
    /*
    * Constructor
    * () will be defined the unit of measure
    * @param _neonDCA address of the NDCA
    * @param _neonPairPool address of the Pair Pool
    */
    constructor(address _NDCA, address _NPairPool){
          neonDCA = _NDCA;
          neonPairPool = _NPairPool;
    }
    /* WRITE METHODS*/
    /*
    * @dev Define NDCA address
    * () will be defined the unit of measure
    * @param _account address
    * @requirement diff. 0x00
    */
    function setNDCA(address _account) external onlyOwner {
        require(_account != address(0), "NEON: null address not allowed");
        neonDCA = _account;
    }
    /*
    * @dev Define Pair Pool address
    * () will be defined the unit of measure
    * @param _account address
    * @requirement diff. 0x00
    */
    function setPairPool(address _account) external onlyOwner {
        require(_account != address(0), "NEON: null address not allowed");
        neonPairPool = _account;
    }
    /*
    * @dev Define Proxy address
    * () will be defined the unit of measure
    * @param _account address
    * @req diff. 0x00
    */
    function setProxy(address _account) external onlyOwner {
        require(_account != address(0), "NEON: null address not allowed");
        neonProxy = _account;
    }
    /*
    * @NDCA Store information
    * () will be defined the unit of measure
    * @param _dcaIndex pair where will be associated the store
    * @param _userAddress address that own the DCA
    * @param _struct data to be stored
    */
     function store(uint256 _dcaIndex, address _userAddress, detailStruct calldata _struct) external onlyNeonDCA returns(bool){
        require(_dcaIndex > 0, "NEON: DCA index must be > 0");
        require(_userAddress != address(0), "NEON: Address not defined");
        require(_dcaIndex <= totalPairs(), "NEON: DCA index not listed");
        pairStruct storage dataPair = database[_dcaIndex];
        uint256 nStore;
        if(dataPair.users[_userAddress].idxBuffer == 0){
            nStore = dataPair.users[_userAddress].nStore;
            dataPair.users[_userAddress].nStore = dataPair.users[_userAddress].nStore.add(1);
        }else{
            nStore = dataPair.users[_userAddress].idxBuffer.sub(1);
        }
        
        if (_struct.lastDcaTimeOk > 0){//in case of close without ex
            dataPair.users[_userAddress].userData[nStore + 1].lastDcaTimeOk = _struct.lastDcaTimeOk;
        }else{
            dataPair.users[_userAddress].userData[nStore + 1].lastDcaTimeOk = block.timestamp;
        }
        
        dataPair.users[_userAddress].userData[nStore + 1].destTokenEarned = _struct.destTokenEarned;
        dataPair.users[_userAddress].userData[nStore + 1].storeOk = true;//recorded value
        //buffer
        if(dataPair.users[_userAddress].nStore >= 200){
            if(dataPair.users[_userAddress].idxBuffer >= 200){
                dataPair.users[_userAddress].idxBuffer = 1;
            }else{
                dataPair.users[_userAddress].idxBuffer = dataPair.users[_userAddress].idxBuffer.add(1);
            }
        }
        emit Stored(_userAddress, nStore, block.timestamp);
        return true;
     }
    /*
    * @NDCA Delete Stored information
    * () will be defined the unit of measure
    * @param _dcaIndex pair where has been associated the store
    * @param _userAddress address that own the store
    * @param _storeId data id to be deleted
    */
     function deleteStore(uint256 _dcaIndex, address _userAddress, uint256 _storeId) external onlyNeonDCA returns(bool){
        require(_dcaIndex > 0, "NEON: DCA index must be > 0");
        require(_userAddress != address(0), "NEON: Address not defined");
        require(_storeId > 0, "NEON: Store index must be > 0");
        pairStruct storage dataPair = database[_dcaIndex];
        uint256 nStore = dataPair.users[_userAddress].nStore;
        require(_storeId <= nStore, "NEON: Store index out of limit");
        uint256 i;
        for(i=_storeId; i<=nStore; i++){
            dataPair.users[_userAddress].userData[i] = dataPair.users[_userAddress].userData[i + 1];
        }
        dataPair.users[_userAddress].nStore = dataPair.users[_userAddress].nStore.sub(1);
        if(_storeId == dataPair.users[_userAddress].idxBuffer){
            dataPair.users[_userAddress].idxBuffer = dataPair.users[_userAddress].idxBuffer.sub(1);
        }

        emit DeletedStore(_userAddress, _storeId, block.timestamp);
        return true;
     }
    /* VIEW METHODS*/
    /*
    * @internal Total DCAs
    * () will be defined the unit of measure
    * @return uint256 total listed DCAs
    */
    function totalPairs() internal view returns(uint256) {
        INPairPool_in pairPool = INPairPool_in(neonPairPool);
        return pairPool.numberListedPairs();
    }
    /*
    * @proxy Hystorian All info for the user (Struct)
    * () will be defined the unit of measure
    * @param _dcaIndex pair where has been associated the store
    * @param _userAddress address that own the store
    * @return detailStruct user informations
    */
     function userHystorianBatch(uint256 _dcaIndex, address _userAddress) external onlyProxy view returns(detailStruct[] memory){
        pairStruct storage dataPair = database[_dcaIndex];
        uint256 nStore = dataPair.users[_userAddress].nStore;
        detailStruct[] memory data = new detailStruct[](nStore);
        uint256 i;
        for(i=1; i<=nStore; i++){
            data[i-1] = dataPair.users[_userAddress].userData[i];
        }
        return data;
    }
    /*
    * @proxy Hystorian info for the user (Single Struct)
    * () will be defined the unit of measure
    * @param _dcaIndex pair where has been associated the store
    * @param _userAddress address that own the store
    * @return detailStruct user informations
    */
     function userHystorian(uint256 _dcaIndex, address _userAddress, uint256 _storeId) external onlyProxy view returns(detailStruct memory){
        pairStruct storage dataPair = database[_dcaIndex];
        return dataPair.users[_userAddress].userData[_storeId];
    }
}