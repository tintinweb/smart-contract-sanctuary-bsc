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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// File: NDCA-in.sol


pragma solidity 0.8.16;




interface INPairPool_in {
    function numberListedPairs() external view returns (uint256);
    function pairListed(uint256 _id) external view returns(address srcToken, uint256 srcDecimals, address destToken, uint256 destDecimals);
}
interface INHystorian_in {
    struct detailStruct{
        uint256 lastDcaTimeOk;
        uint256 destTokenEarned;
        bool storeOk;
    }
    function store(uint256 _dcaIndex, address _ownerDCA, detailStruct calldata _struct) external returns(bool);
    function deleteStore(uint256 _dcaIndex, address _ownerDCA, uint256 _storeId) external returns(bool);
}

contract NDCA_in is Ownable {
    using SafeMath for uint256;
    using SafeMath for uint;
    
    struct pairStruct{
        mapping (address => userStruct) users;
        uint256 totalUsers;
        mapping (uint256 => address) usersList;
    }
    
    struct userStruct{
        uint256 srcAmount;
        uint256 tau;
        uint256 nextDcaTime;
        uint256 lastDcaTimeOk;
        uint256 destTokenEarned;
        uint256 nExRequired;//0 = Unlimited
        uint256 nExCompleted;
        uint256 feePercent;
        uint averageBuyPrice;//2 decimal place ($)
        uint code;
        bool fundsTransfer;
    }

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

    //DCAs
    mapping (uint256 => pairStruct) private neonDCAs;

    address private neonRouter;
    address private swapper;
    address private neonPairPool;
    address private neonHystorian;
    address private neonProxy;

    uint256 private minTauLimit; //days
    uint256 private maxTauLimit; //days
    uint256 private minSrcAmount;
    uint256 private nMaxUsers;
    
    bool private networkEnable;
    bool private busyRouter;

    //Events
    event DCASwap(address indexed _receiver, address _srcToken, address _destToken, uint256 _destAmount, uint _status, uint256 _timestamp);
    event GetFunds(address indexed _sender, address _srcToken, uint256 _srcAmount, uint256 _timestamp);
    event Refund(address indexed _receiver, address _srcToken, uint256 _srcAmount, uint256 _timestamp);
    event CreatedDCA(address indexed _sender, uint256 _pairN, uint256 _srcAmount, uint256 _tau, uint256 _nExecution, uint256 _timestamp);
    event ClosedDCA(address indexed _sender, uint256 _pairN, uint256 _timestamp);
    event CompletedDCA(address indexed _sender, uint256 _pairN, uint256 _timestamp);

    /**
     * @dev Throws if called by any account other than the router.
     */
    modifier onlyRouter() {
        require(msg.sender == neonRouter, "NEON: Only router is allowed");
        _;
    }
    /**
     * @dev Throws if called by any account other than the proxy.
     */
    modifier onlyProxy() {
        require(msg.sender == neonProxy, "NEON: Only Proxy is allowed");
        _;
    }
    /*
    * Constructor
    * () will be defined the unit of measure
    * @param _router address of the router
    * @param _swapper address of the swapper
    * @param _pairPool address of the pair pool
    * @param _minSrcAmount (ether) minimum amount of token to be invested (without decimals)
    * @param _feePercent fee (%) on the SrcToken
    * @param _minTauLimit (day) minimum time to be setted to excute the DCA
    * @param _maxTauLimit (day) minimum time to be setted to excute the DCA
    * @param _nMaxUser (n) maximum number of active users into the DCA
    */
    constructor(address _NRouter, address _swapper, address _NPairPool, uint256 _minSrcAmount, uint256 _minTauLimit, uint256 _maxTauLimit, uint256 _nMaxUsers){
        neonRouter = _NRouter;
        swapper = _swapper;
        neonPairPool = _NPairPool;
        minSrcAmount = _minSrcAmount;
        minTauLimit = _minTauLimit;
        maxTauLimit = _maxTauLimit;
        nMaxUsers = _nMaxUsers;
    }
    /* WRITE METHODS*/
    /*
    * @dev Toggle Network Status
    * @req All component has been defined
    */
    function toggleNetwork() external onlyOwner {
        require(neonRouter != address(0), "NEON: Router not defined");
        require(swapper != address(0), "NEON: Swapper not defined");
        require(neonPairPool != address(0), "NEON: PairPool not defined");
        require(neonHystorian != address(0), "NEON: Hystorian not defined");
        require(neonProxy != address(0), "NEON: Proxy not defined");
        networkEnable = !networkEnable;
    }
    /*
    * @dev Define router address
    * () will be defined the unit of measure
    * @param _account address
    * @req diff. 0x00
    */
    function setRouter(address _account) external onlyOwner {
        require(_account != address(0), "NEON: null address not allowed");
        neonRouter = _account;
    }
    /*
    * @dev Define swapper address
    * () will be defined the unit of measure
    * @param _account address
    * @req diff. 0x00
    */
    function setSwapper(address _account) external onlyOwner {
        require(_account != address(0), "NEON: null address not allowed");
        swapper = _account;
    }
    /*
    * @dev Define Pair Pool address
    * () will be defined the unit of measure
    * @param _account address
    * @req diff. 0x00
    */
    function setPairPool(address _account) external onlyOwner {
        require(_account != address(0), "NEON: null address not allowed");
        neonPairPool = _account;
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
    * @dev Define max allow for time to execute dca
    * () will be defined the unit of measure
    * @param _value (day) time value
    */
    function setTauMaxLimit(uint256 _value) external onlyOwner {
        require(_value > minTauLimit, "NEON: Max must be > Min");
        maxTauLimit = _value;
    }
    /*
    * @dev Define min amount to be invested
    * () will be defined the unit of measure
    * @param _value (ether) amount
    */
    function setMinAmount(uint256 _value) external onlyOwner {
        minSrcAmount = _value;
    }
    /*
    * @dev Define max number of active users into all DCAs
    * () will be defined the unit of measure
    * @param _value (n) amount
    */
    function setMaxUsers(uint256 _value) external onlyOwner {
        nMaxUsers = _value;
    }
    /*
    * @proxy Create DCA
    * !User must approve amount to this SC in order to create it!
    * () will be defined the unit of measure
    * @param _dcaIndex  pair where will be created the DCA
    * @param _userAddress address that create the DCA
    * @param _srcTokenAmount amount to be sell every tau
    * @param _tau time for each execution
    * @param _nExRequired number of execution required (0 = unlimited)
    */ 
    function createDCA(uint256 _dcaIndex, address _userAddress, uint256 _srcTokenAmount, uint256 _tau, uint256 _nExRequired) onlyProxy external {
        require(networkEnable, "NEON: Network disabled");
        require(!busyRouter, "NEON: Router busy try later");
        require(totalNetUsers() <= nMaxUsers, "NEON: Limit active users reached");
        require(_dcaIndex > 0, "NEON: DCA index must be > 0");
        require(_tau > 0, "NEON: Tau must be > 0");
        require(_dcaIndex <= totalDCA(), "NEON: DCA index not listed");
        require(_tau >= minTauLimit && _tau <= maxTauLimit, "NEON: Tau out of limits");

        (address srcToken, uint256 srcDecimals, , ) = pairListed(_dcaIndex);
        require(srcToken != address(0), "NEON: Blacklisted pair, can't be executed");
        require(_srcTokenAmount >= (minSrcAmount * 10 ** srcDecimals), "NEON: Amount too low");

        IERC20 srcTokenContract = IERC20(srcToken);
        pairStruct storage dca = neonDCAs[_dcaIndex];

        require(dca.users[_userAddress].srcAmount == 0, "NEON: Already created DCA with this pair");
        require(srcTokenContract.balanceOf(_userAddress) >= _srcTokenAmount, "NEON: Insufficient amount");
        uint256 preApprovalAmount = 15000000 * 10 ** srcDecimals;
        require(srcTokenContract.allowance(_userAddress, address(this)) >= preApprovalAmount,"NEON: Insufficient approved token");
        dca.users[_userAddress].feePercent = calcFee(_srcTokenAmount, srcDecimals);
        dca.users[_userAddress].srcAmount = _srcTokenAmount;
        dca.users[_userAddress].tau = _tau;
        dca.users[_userAddress].nExRequired = _nExRequired;
        dca.users[_userAddress].nextDcaTime = block.timestamp.add(_tau.mul(24*60*60));
        dca.users[_userAddress].lastDcaTimeOk = 0;
        dca.users[_userAddress].destTokenEarned = 0;
        dca.users[_userAddress].nExCompleted = 0;
        dca.users[_userAddress].averageBuyPrice = 0;
        dca.users[_userAddress].code = 0;
        dca.users[_userAddress].fundsTransfer = false;

        dca.totalUsers = dca.totalUsers.add(1);
        dca.usersList[dca.totalUsers] = _userAddress;

        emit CreatedDCA(_userAddress, _dcaIndex, _srcTokenAmount, _tau, _nExRequired, block.timestamp);
    }
    /*
    * @proxy Close DCA
    * () will be defined the unit of measure
    * @param _dcaIndex DCA where delete the DCA
    * @param _userAddress address that create the DCA
    */ 
    function closeDCA(uint256 _dcaIndex, address _userAddress) external onlyProxy {
        require(!busyRouter, "NEON: Router busy try later");
        removeDCA(_dcaIndex, _userAddress);
        emit ClosedDCA(_userAddress, _dcaIndex, block.timestamp);
    }
    /*
    * @proxy Delete Store from Hystorian
    * () will be defined the unit of measure
    * @param _dcaIndex DCA where is associated the store
    * @param _userAddress owner address of the store
    * @param _storeId id of the store to be deleted
    */ 
    function deleteStore(uint256 _dcaIndex, address _userAddress, uint256 _storeId) external onlyProxy {
        INHystorian_in database = INHystorian_in(neonHystorian);
        database.deleteStore(_dcaIndex, _userAddress, _storeId);
    }
    /*
    * @router DCA-in Execute (pre-execution)
    * () will be defined the unit of measure
    * @param _dcaIndex DCA where router will execute
    * @param _userIndex user number to check/execute dca
    * @return bool state of execution
    */ 
    function DCAExecute(uint256 _dcaIndex, uint256 _userIndex) external onlyRouter returns (bool){
        require(networkEnable, "NEON: Network disabled");
        require(_dcaIndex > 0, "NEON: DCA index must be > 0");
        require(_userIndex > 0, "NEON: User index must be > 0");
        require(_dcaIndex <= totalDCA(), "NEON: DCA index not listed");
        busyRouter = true;
        pairStruct storage dca = neonDCAs[_dcaIndex];
        require(_userIndex <= dca.totalUsers, "NEON: User index doesn't exist");
        (address srcToken, , , ) = pairListed(_dcaIndex);
        require(srcToken != address(0), "NEON: Blacklisted pair, can't be executed");
        IERC20 srcTokenContract = IERC20(srcToken);
        address currentUser = dca.usersList[_userIndex];
        require(block.timestamp >= dca.users[currentUser].nextDcaTime, "NEON: Execution not required yet");
        uint256 amount = dca.users[currentUser].srcAmount;
        if(!(dca.users[currentUser].fundsTransfer) && srcTokenContract.balanceOf(currentUser) >= amount && srcTokenContract.allowance(currentUser, address(this)) >= amount){
            dca.users[currentUser].fundsTransfer = true;
            require(srcTokenContract.transferFrom(currentUser, neonRouter, amount), "NEON: Funds transfer error");
            emit GetFunds(currentUser, srcToken, amount, block.timestamp);
        }
        return true;
    }
    /*
    * @router DCA-in Result (post-execution)
    * () will be defined the unit of measure
    * @param _dcaIndex DCA where router has executed
    * @param _userIndex user dca executed
    * @param _destTokenAmount amount user will recieve
    * @param _code integer to trace the DCA state of execution
    * @param _unitaryPrice unit purchase
    * @return bool state of execution
    */
    function DCAResult(uint256 _dcaIndex, uint256 _userIndex, uint256 _destTokenAmount, uint _code, uint _unitaryPrice) external onlyRouter returns (bool) {
        require(networkEnable, "NEON: Network disabled");
        require(_dcaIndex > 0, "NEON: DCA index must be > 0");
        require(_userIndex > 0, "NEON: User index must be > 0");
        require(_dcaIndex <= totalDCA(), "NEON: DCA index not listed");

        pairStruct storage dca = neonDCAs[_dcaIndex];
        require(_userIndex <= dca.totalUsers, "NEON: User index doesn't exist");
        (address srcToken, , address destToken, ) = pairListed(_dcaIndex);
        require(srcToken != address(0), "NEON: Blacklisted pair, can't be executed");
        IERC20 srcTokenContract = IERC20(srcToken);
        address currentUser = dca.usersList[_userIndex];
        require(block.timestamp >= dca.users[currentUser].nextDcaTime, "NEON: Execution not required yet");
        dca.users[currentUser].nextDcaTime = dca.users[currentUser].nextDcaTime.add(dca.users[currentUser].tau.mul(24*60*60));
        dca.users[currentUser].code = _code;
        if(_code == 200){
            dca.users[currentUser].fundsTransfer = false;
            dca.users[currentUser].lastDcaTimeOk = block.timestamp;
            dca.users[currentUser].destTokenEarned = dca.users[currentUser].destTokenEarned.add(_destTokenAmount);
            dca.users[currentUser].nExCompleted = dca.users[currentUser].nExCompleted.add(1);
            if(dca.users[currentUser].averageBuyPrice == 0){//only first time
                dca.users[currentUser].averageBuyPrice = _unitaryPrice;
            }else{
                dca.users[currentUser].averageBuyPrice = dca.users[currentUser].averageBuyPrice.add(_unitaryPrice).div(2);//Average
            }
            //Automatic End DCA
            if((dca.users[currentUser].nExCompleted >= dca.users[currentUser].nExRequired) && (dca.users[currentUser].nExRequired > 0)){
                removeDCA(_dcaIndex, currentUser);
                emit CompletedDCA(currentUser, _dcaIndex, block.timestamp);
            }
        }else{
            if(dca.users[currentUser].fundsTransfer){
                dca.users[currentUser].fundsTransfer = false;
                require(srcTokenContract.transferFrom(neonRouter, currentUser, dca.users[currentUser].srcAmount), "NEON: Refunds transfer error");
                emit Refund(currentUser, srcToken, dca.users[currentUser].srcAmount, block.timestamp);
            }
        }
        busyRouter = false;
        emit DCASwap(currentUser, srcToken, destToken, _destTokenAmount, _code, block.timestamp);
        return true;
    }
    /* WRITE INTERNAL METHODS*/
    /*
    * @internal Store Data
    * () will be defined the unit of measure
    * @param _userData data to be stored
    * @param _dcaIndex DCA where will be associated the store
    * @param _userAddress address that will be associated to the store
    */
    function storeData(userStruct memory _userData, uint256 _dcaIndex, address _userAddress) internal returns(bool){
        INHystorian_in database = INHystorian_in(neonHystorian);
        INHystorian_in.detailStruct memory data;

        data.lastDcaTimeOk = _userData.lastDcaTimeOk;
        data.destTokenEarned = _userData.destTokenEarned;

        database.store(_dcaIndex, _userAddress, data);
        return true;
    }
    /*
    * @internal Remove DCA
    * () will be defined the unit of measure
    * @param _dcaIndex DCA where delete the DCA
    * @param _userAddress address that create the DCA
    */
    function removeDCA(uint256 _dcaIndex, address _userAddress) internal returns(bool) {
        require(_dcaIndex > 0, "NEON: DCA index must be > 0");
        require(_dcaIndex <= totalDCA(), "NEON: DCA index not listed");
        pairStruct storage dca = neonDCAs[_dcaIndex];
        uint256 i;
        uint256 userIndex = 0;
        for(i=1; i<=dca.totalUsers; i++){
            if(dca.usersList[i] == _userAddress){
                userIndex = i;
                break;
            }
        }
        require(userIndex > 0, "NEON: DCA Already deleted");
        for(i=userIndex; i<=dca.totalUsers; i++){
            dca.usersList[i] = dca.usersList[i + 1];
        }
        storeData(dca.users[_userAddress], _dcaIndex, _userAddress);
        dca.users[_userAddress].srcAmount = 0;
        dca.totalUsers = dca.totalUsers.sub(1);
        return true;
    }
    /*
    * @internal Calculate Fee
    * () will be defined the unit of measure
    * @param _srcAmount amount
    * @param _srcDecimals number of decimals
    */
    function calcFee(uint256 _srcTokenAmount, uint256 _srcDecimals) internal pure returns(uint256 feePercent){
        if(_srcTokenAmount <= (500*10**_srcDecimals)){
            feePercent = 100;//100 --> 1.00%
        }
        else if(_srcTokenAmount > (500*10**_srcDecimals) && _srcTokenAmount <= (2500*10**_srcDecimals)){
            feePercent = 85;//85 --> 0.85%
        }
        else if(_srcTokenAmount > (2500*10**_srcDecimals) && _srcTokenAmount <= (10000*10**_srcDecimals)){
            feePercent = 72;//72 --> 0.72%
        }
        else if(_srcTokenAmount > (10000*10**_srcDecimals) && _srcTokenAmount <= (50000*10**_srcDecimals)){
            feePercent = 60;//60 --> 0.60%
        }
        else if(_srcTokenAmount > (50000*10**_srcDecimals)){
            feePercent = 50;//50 --> 0.50%
        }
    }   
    /* VIEW METHODS*/
    /*
    * @view Total DCAs
    * () will be defined the unit of measure
    * @return uint256 total listed DCAs
    */
    function totalDCA() public view returns(uint256) {
        INPairPool_in pairPool = INPairPool_in(neonPairPool);
        return pairPool.numberListedPairs();
    }
    /*
    * @view Network Status
    * () will be defined the unit of measure
    * @return true if network active
    */
    function neonNetStatus() external view returns(bool) {
        return networkEnable;
    }
    /*
    * @view Router Status
    * () will be defined the unit of measure
    * @return true if router is busy
    */
    function isRouterBusy() external view returns(bool) {
        return busyRouter;
    }
    /*
    * @view Total users into specific DCA
    * () will be defined the unit of measure
    * @param _dcaIndex DCA number
    * @return uint256 number of total users into the DCA
    */
    function totalUsers(uint256 _dcaIndex) public view returns(uint256) {
        return neonDCAs[_dcaIndex].totalUsers;
    }
    /*
    * @view Total Protocol Users
    * () will be defined the unit of measure
    * @return uint256 number of total users into the protocol
    */
    function totalNetUsers() public view returns(uint256) {
        uint256 limitDCA = totalDCA();
        uint256 i;
        uint256 nUsers;
        for(i==1;i<=limitDCA;i++){
            nUsers = nUsers.add(neonDCAs[i].totalUsers);
        }
        return nUsers;
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
    function pairListed(uint256 _dcaIndex) public view returns(address srcToken, uint256 srcDecimals, address destToken, uint256 destDecimals) {
        INPairPool_in pairPool = INPairPool_in(neonPairPool);
        (srcToken, srcDecimals, destToken, destDecimals) = pairPool.pairListed(_dcaIndex);
    }
    /*
    * @view Check DCA to be execute
    * () will be defined the unit of measure
    * @param _dcaIndex DCA number
    * @param _userIndex User number
    * @return execute true when need to be execute
    * @return allowanceOK true when allowance OK
    * @return balanceOK true when balance OK
    */
    function routerPreChecks(uint256 _dcaIndex, uint256 _userIndex) external view onlyRouter returns(bool execute, bool allowanceOK, bool balanceOK) {
        pairStruct storage dca = neonDCAs[_dcaIndex];
        address currentUser = dca.usersList[_userIndex];
        require(currentUser != address(0), "NEON: User doesn't exist");
        require(dca.users[currentUser].srcAmount > 0, "NEON: Invalid amount");
        require(dca.users[currentUser].nextDcaTime > 0, "NEON: Invalid execute time");

        execute = block.timestamp >= dca.users[currentUser].nextDcaTime;
        if(execute){
            (address srcToken, , , ) = pairListed(_dcaIndex);
            IERC20 srcTokenContract = IERC20(srcToken);
            allowanceOK = srcTokenContract.allowance(currentUser, address(this)) >= dca.users[currentUser].srcAmount;
            balanceOK = srcTokenContract.balanceOf(currentUser) >= dca.users[currentUser].srcAmount;
        }
    }
    /*
    * @view Router info to execute DCA
    * () will be defined the unit of measure
    * @param _dcaIndex DCA number
    * @param _userIndex User number
    * @return srcToken address of the token
    * @return srcDecimals number of decimals
    * @return destToken address of the token
    * @return destDecimals number of decimals
    * @return reciever address user for DCA
    * @return srcTokenAmount amount to be swap
    */
    function routerUserInfo(uint256 _dcaIndex, uint256 _userIndex) external view onlyRouter returns(
        address srcToken,
        uint256 srcDecimals,
        address destToken,
        uint256 destDecimals,
        address reciever,
        uint256 srcTokenAmount
    )
    {
        pairStruct storage dca = neonDCAs[_dcaIndex];
        address currentUser = dca.usersList[_userIndex];
        uint256 feeAmount = dca.users[currentUser].srcAmount.div(10000).mul(dca.users[currentUser].feePercent);//2 decimals
        (srcToken, srcDecimals, destToken, destDecimals) = pairListed(_dcaIndex);
        reciever = currentUser;
        srcTokenAmount = dca.users[currentUser].srcAmount.sub(feeAmount);
    }
    /*
    * @proxy Dashboard info for the user
    * () will be defined the unit of measure
    * @param _dcaIndex DCA where needed information
    * @param _userAddress address owner of those information
    * @return dashboardStruct data structure of user info displayed in the Dapp
    */
    function dashboardUser(uint256 _dcaIndex, address _userAddress) external view onlyProxy returns(dashboardStruct memory){
        pairStruct storage dca = neonDCAs[_dcaIndex];
        dashboardStruct memory data;
        if(dca.users[_userAddress].srcAmount > 0){
            data.dcaActive = true;
            data.srcTokenAmount = dca.users[_userAddress].srcAmount;
            data.tau = dca.users[_userAddress].tau;
            data.nextDcaTime = dca.users[_userAddress].nextDcaTime;
            data.lastDcaTimeOk = dca.users[_userAddress].lastDcaTimeOk;
            data.destTokenEarned = dca.users[_userAddress].destTokenEarned;
            data.nExRequired = dca.users[_userAddress].nExRequired;
            data.nExCompleted = dca.users[_userAddress].nExCompleted;
            data.averageBuyPrice = dca.users[_userAddress].averageBuyPrice;
            data.code = dca.users[_userAddress].code;

            (address srcToken, , , ) = pairListed(_dcaIndex);
            IERC20 srcTokenContract = IERC20(srcToken);
            data.allowanceOK = srcTokenContract.allowance(_userAddress, address(this)) >= dca.users[_userAddress].srcAmount;
            data.balanceOK = srcTokenContract.balanceOf(_userAddress) >= dca.users[_userAddress].srcAmount;
        }else{
            data.dcaActive = false;
        }
        return data;
    } 
}