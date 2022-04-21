/**
 *Submitted for verification at BscScan.com on 2022-04-21
*/

// File: EGBurnParty_flat.sol


// File: EGBurnParty_flat.sol


// File: @chainlink/contracts/src/v0.8/interfaces/KeeperCompatibleInterface.sol


pragma solidity ^0.8.0;

interface KeeperCompatibleInterface {
  /**
   * @notice method that is simulated by the keepers to see if any work actually
   * needs to be performed. This method does does not actually need to be
   * executable, and since it is only ever simulated it can consume lots of gas.
   * @dev To ensure that it is never called, you may want to add the
   * cannotExecute modifier from KeeperBase to your implementation of this
   * method.
   * @param checkData specified in the upkeep registration so it is always the
   * same for a registered upkeep. This can easily be broken down into specific
   * arguments using `abi.decode`, so multiple upkeeps can be registered on the
   * same contract and easily differentiated by the contract.
   * @return upkeepNeeded boolean to indicate whether the keeper should call
   * performUpkeep or not.
   * @return performData bytes that the keeper should call performUpkeep with, if
   * upkeep is needed. If you would like to encode data to decode later, try
   * `abi.encode`.
   */
  function checkUpkeep(bytes calldata checkData) external returns (bool upkeepNeeded, bytes memory performData);

  /**
   * @notice method that is actually executed by the keepers, via the registry.
   * The data returned by the checkUpkeep simulation will be passed into
   * this method to actually be executed.
   * @dev The input to this method should not be trusted, and the caller of the
   * method should not even be restricted to any single registry. Anyone should
   * be able call it, and the input should be validated, there is no guarantee
   * that the data passed in is the performData returned from checkUpkeep. This
   * could happen due to malicious keepers, racing keepers, or simply a state
   * change while the performUpkeep transaction is waiting for confirmation.
   * Always validate the data passed in.
   * @param performData is the data which was passed back from the checkData
   * simulation. If it is encoded, it can easily be decoded into other types by
   * calling `abi.decode`. This data should not be trusted, and should be
   * validated against the contract's current state.
   */
  function performUpkeep(bytes calldata performData) external;
}

// File: @chainlink/contracts/src/v0.8/KeeperBase.sol


pragma solidity ^0.8.0;

contract KeeperBase {
  error OnlySimulatedBackend();

  /**
   * @notice method that allows it to be simulated via eth_call by checking that
   * the sender is the zero address.
   */
  function preventExecution() internal view {
    if (tx.origin != address(0)) {
      revert OnlySimulatedBackend();
    }
  }

  /**
   * @notice modifier that allows it to be simulated via eth_call by checking
   * that the sender is the zero address.
   */
  modifier cannotExecute() {
    preventExecution();
    _;
  }
}

// File: @chainlink/contracts/src/v0.8/KeeperCompatible.sol


pragma solidity ^0.8.0;



abstract contract KeeperCompatible is KeeperBase, KeeperCompatibleInterface {}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
}

// File: @openzeppelin/contracts/utils/Counters.sol


// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
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


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
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

// File: EGBurnParty.sol


pragma solidity ^0.8.9;





/**
 *  _______  ______      ______  _     _  ______ __   _       _____  _______  ______ _______ __   __
 *  |______ |  ____      |_____] |     | |_____/ | \  |      |_____] |_____| |_____/    |      \_/  
 *  |______ |_____|      |_____] |_____| |    \_ |  \_|      |       |     | |    \_    |       |   
 *                                                                                                  
 */

contract EGBurnParty is Ownable, KeeperCompatibleInterface {

    using Counters for Counters.Counter;
    Counters.Counter public burnPartyCounter;
    Counters.Counter public tokenCounter;

    struct BurnPartyTokenInfo {
        uint256 index;
        address burnAddress;
        uint256 minStakeAmount;
        bool enabled;
    }

    struct BurnParty {
        uint256 partyId;            // burn party id
        address creator;            // burn party creator address
        string partyName;           // burn party name
        address partyToken;         // burn party token address
        uint256 startDate;          // burn party start date
        uint256 burnDate;           // burn party burn date
        uint256 currentQuantity;    // burn party current token amount
        uint256 requiredQuantity;   // burn party required quantity to burn
        uint256 stakeCounter;       // burn party counter of stakes
        bool started;               // burn party started status
        bool cancelled;             // burn party cancelled status
        bool ended;                 // burn party ended status
    }

    // `burnTokenInfoByAddress` detail: tokenAddress => token information
    mapping (address => BurnPartyTokenInfo) public burnTokenInfoByAddress;

    // `tokenIndexToAddress` detail: token index => token address
    mapping (uint256 => address) public tokenIndexToAddress;

    // `burnPartyById` detail: partyId => BurnParty
    mapping (uint256 => BurnParty) public burnPartyById;

    // `Stakes List` detail: Client_Address => Party_Id => Token_Amount
    mapping (address => mapping (uint256 => uint256)) public stakesList;

    modifier onlyCreator(uint256 partyId) {
        require(burnPartyById[partyId].creator == msg.sender || owner() == msg.sender, "EGBurnParty: caller is not the creator");
        _;
    }
    modifier availableBurnParty(uint256 partyId) {
        require(partyId > 0, "EGBurnParty: Party ID should be a positive number.");
        require(burnPartyById[partyId].partyId == partyId, 
            "EGBurnParty: Burn Party with specified ID does not exist.");
        _;
    }
    
    event UpdateBurnAddress(address indexed tokenAddress, address indexed burnAddress);
    event UpdateMinStakeAmount(address indexed tokenAddress, uint256 minStakeAmount);
    event AddBurnPartyToken(address indexed tokenAddress, address indexed burnAddress, uint256 minStakeAmount);
    event RemoveBurnPartyToken(address indexed tokenAddress);
    event CreateBurnParty(uint256 partyId, 
        string partyName, 
        address indexed partyToken, 
        uint256 startDate, 
        uint256 burnDate, 
        uint256 requiredQuantity, 
        uint256 stakeAmount
    );
    event UpdateBurnPartyName(uint256 partyId, string newName);
    event UpdateBurnPartyStartDate(uint256 partyId, uint256 newDate);
    event UpdateBurnPartyBurnDate(uint256 partyId, uint256 newDate);
    event UpdateBurnPartyRequiredQuantity(uint256 partyId, uint256 newValue);
    event StartBurnParty(uint256 partyId);
    event EndBurnParty(uint256 partyId);
    event CancelBurnParty(uint256 partyId);
    event RemoveBurnParty(uint256 partyId);
    event StakeBurnParty(uint256 partyId, uint256 value);
    event UnstakeFromBurnParty(uint256 partyId);

    constructor() {
        burnPartyCounter.increment();
    }

    function checkUpkeep(bytes calldata checkData) external override returns (bool upkeepNeeded, bytes memory performData) {
        uint256 count = 0;
        uint256 i;
        for(i = 0; i < burnPartyCounter.current(); i++ ){
            if((burnPartyById[i].startDate - block.timestamp) < 6000 && burnPartyById[i].started == false){
                count++;
            }
        }
        uint256[] memory list = new uint256[](count);
        uint256 j = 0;

        for(i = 0; i < burnPartyCounter.current(); i++ ){
            if((burnPartyById[i].startDate - block.timestamp) < 6000 && burnPartyById[i].started == false){
                list[j] = i;
                j++;
            }
        }

        return (true, abi.encodePacked(list));
    }
    
    function performUpkeep(bytes calldata performData) external override {
        burnPartyById[0].started = true; 
        for(uint256 i = 0; i < burnPartyCounter.current(); i++ ){
            if((burnPartyById[i].startDate - block.timestamp) < 6000 && burnPartyById[i].started == false){
               burnPartyById[i].started = true; 
            }
        }


        // uint256[] memory decodeValue = abi.decode(performData, (uint256[]));
        // uint256 i;
        // for(i = 0; i < decodeValue.length; i++){
        //     burnPartyById[decodeValue[i]].started = true;
        // }
    }

    /**
    * @param tokenAddress   burn party token address
    * @param burnAddress    burnning address
    * @dev  update burn address
    *       fire `UpdateBurnAddress` event
    */
    function updateBurnAddress(address tokenAddress, address burnAddress) external onlyOwner {
        require(burnAddress != address(0), "EGBurnParty: Zero address should not be added as a burn address");
        require(burnTokenInfoByAddress[tokenAddress].enabled == true, "EGBurnParty: Token is not registered as a burn party token");

        burnTokenInfoByAddress[tokenAddress].burnAddress = burnAddress;

        emit UpdateBurnAddress(tokenAddress, burnAddress);
    }

    /**
    * @param tokenAddress       burn party token address
    * @param minStakeAmount    burn party token initial stake amount
    * @dev  update the initial stake amount
    *       fire `UpdateMinStakeAmount` event
    */
    function updateMinStakeAmount(address tokenAddress, uint256 minStakeAmount) external onlyOwner {
        require(minStakeAmount > 0, "EGBurnParty: The initial stake amount should be a positive number.");
        require(burnTokenInfoByAddress[tokenAddress].enabled == true, "EGBurnParty: Token is not registered as a burn party token");

        burnTokenInfoByAddress[tokenAddress].minStakeAmount = minStakeAmount;

        emit UpdateMinStakeAmount(tokenAddress, minStakeAmount);
    }

    /**
    * @param tokenAddress       burn party token address
    * @param burnAddress        burn party burn address
    * @param minStakeAmount    burn party init stake amount
    * @dev  add burn party token
    *       fire `AddBurnPartyToken` event
    */
    function addBurnPartyToken(address tokenAddress, address burnAddress, uint256 minStakeAmount) external onlyOwner {
        require(tokenAddress != address(0), "EGBurnParty: The zero address should not be added as a burn party token");
        require(burnTokenInfoByAddress[tokenAddress].enabled == false, "EGBurnParty: Token has been already added.");
        require(burnAddress != address(0), "EGBurnParty: The zero address should not be added as a burn address");
        require(minStakeAmount > 0, "EGBurnParty: Init stake amount should be a positive number.");
        
        if(burnTokenInfoByAddress[tokenAddress].burnAddress == address(0)){
            burnTokenInfoByAddress[tokenAddress].index = tokenCounter.current();
            tokenIndexToAddress[tokenCounter.current()] = tokenAddress;
            tokenCounter.increment();
        }

        burnTokenInfoByAddress[tokenAddress].enabled = true;
        burnTokenInfoByAddress[tokenAddress].burnAddress = burnAddress;
        burnTokenInfoByAddress[tokenAddress].minStakeAmount = minStakeAmount;

        emit AddBurnPartyToken(tokenAddress, burnAddress, minStakeAmount);
    }

    /**
    * @param tokenAddress burn party token address
    * @dev  remove burn party token
    *       fire `RemoveBurnPartyToken` event
    */
    function removeBurnPartyToken(address tokenAddress) external onlyOwner {
        require(burnTokenInfoByAddress[tokenAddress].enabled == true, "EGBurnParty: Token has not been registered.");

        burnTokenInfoByAddress[tokenAddress].enabled = false;

        emit RemoveBurnPartyToken(tokenAddress);
    }

    /**
    * @param partyName burn party name
    * @param partyToken burn party token
    * @param startDate burn party start date
    * @param burnDate burn party end date
    * @param requiredQuantity minium amount for burnning
    *
    * @dev  create burn party object
    *       insert object into `burnPartyById`
    *       fire `CreateBurnParty` event
    */
    function createBurnParty(
        string memory partyName,
        address partyToken,
        uint256 startDate,
        uint256 burnDate,
        uint256 requiredQuantity,
        uint256 stakeAmount
    )
        external 
    {
        require( bytes(partyName).length > 0, 
            "EGBurnParty: Empty string should not be added as a burn party name");
        require( partyToken != address(0), 
            "EGBurnParty: The zero address should not be a party token");
        require(startDate > block.timestamp, 
            "EGBurnParty: Start date should be greater than current time.");
        require(burnDate > startDate, 
            "EGBurnParty: Burn date should be greater than start date.");
        require(requiredQuantity > 0, 
            "EGBurnParty: Required quantity should be a positive number.");
        require(burnTokenInfoByAddress[partyToken].enabled == true, 
            "EGBurnParty: Token is not registered as a burn party token.");
        require(stakeAmount >= burnTokenInfoByAddress[partyToken].minStakeAmount,
            "EGBurnParty: Stake amount should be greater than the min stake amount.");
        require(IERC20(partyToken).balanceOf(msg.sender) >= stakeAmount,
            "EGBurnParty: There is not the enough token to create burn party in your wallet.");
        
        BurnParty memory party = BurnParty({
            partyId: burnPartyCounter.current(),
            creator: msg.sender,
            partyName: partyName,
            partyToken: partyToken,
            startDate: startDate,
            burnDate: burnDate,
            currentQuantity: stakeAmount,
            requiredQuantity: requiredQuantity,
            stakeCounter: 1,
            started: false,
            cancelled: false,
            ended: false
        });
        burnPartyById[burnPartyCounter.current()] = party;
        stakesList[msg.sender][party.partyId] = stakeAmount;

        IERC20(partyToken).transferFrom(msg.sender, address(this), stakeAmount);
        
        burnPartyCounter.increment();

        emit CreateBurnParty(party.partyId, 
            partyName, 
            partyToken, 
            startDate, 
            burnDate, 
            requiredQuantity, 
            stakeAmount
        );
    }

    function updateBurnPartyName(uint256 partyId, string memory newName) external onlyCreator(partyId) availableBurnParty(partyId) {
        require( bytes(newName).length > 0, "EGBurnParty: Empty string cannot be added as a burn party name.");
        require(burnPartyById[partyId].started == false, 
            "EGBurnParty: Cannot update burn party after it has already started.");

        burnPartyById[partyId].partyName = newName;

        emit UpdateBurnPartyName(partyId, newName);
    }

    /**
    * @param partyId burn party id
    * @param newDate burn party start date
    * @dev update burn party start date
    *      fire `UpdateBurnPartyStartDate` event
    */
    function updateBurnPartyStartDate(uint256 partyId, uint256 newDate) external onlyCreator(partyId) availableBurnParty(partyId) {
        require(block.timestamp < newDate && newDate < burnPartyById[partyId].burnDate, 
            "EGBurnParty: Start date should be between current time and burn date");
        require(burnPartyById[partyId].started == false, 
            "EGBurnParty: Cannot update burn party after it has already started.");
        
        burnPartyById[partyId].startDate = newDate;

        emit UpdateBurnPartyStartDate(partyId, newDate);
    }

    /**
    * @param partyId burn party id
    * @param newDate burn date
    * @dev   update burn party requrired quantity 
    *        fire `UpdateBurnPartyBurnDate` event
    */
    function updateBurnPartyBurnDate(uint256 partyId, uint256 newDate) external onlyCreator(partyId) availableBurnParty(partyId) {
        require(newDate > block.timestamp && newDate > burnPartyById[partyId].startDate, 
                "EGBurnParty: Burn date should be greater than current time and start date.");
        require(burnPartyById[partyId].started == false, 
            "EGBurnParty: Cannot update burn party after it has already started.");
        
        burnPartyById[partyId].burnDate = newDate;

        emit UpdateBurnPartyBurnDate(partyId, newDate);
    }

    /**
    * @param partyId burn party id
    * @param newValue minium amount for burnning
    * @dev   update burn party requrired quantity 
    *        fire `UpdateBurnPartyRequiredQuantity` event
    */
    function updateBurnPartyRequiredQuantity(uint256 partyId, uint256 newValue) external onlyCreator(partyId) availableBurnParty(partyId) {
        require( newValue > 0, 
            "EGBurnParty: Required quantity should be a positive number.");
        require(burnPartyById[partyId].started == false, 
            "EGBurnParty: Cannot update burn party after it has already started.");
        
        burnPartyById[partyId].requiredQuantity = newValue;

        emit UpdateBurnPartyRequiredQuantity(partyId, newValue);
    }

    /**
    * @param partyId burn party id
    * @dev start burn party by id
    *      fire `StartBurnParty` event
    */
    function startBurnParty(uint256 partyId) external onlyCreator(partyId) availableBurnParty(partyId) {
        require(burnPartyById[partyId].started == false, 
            "EGBurnParty: Cannot update burn party after it has already started.");
        require(burnPartyById[partyId].startDate <= block.timestamp && block.timestamp < burnPartyById[partyId].burnDate, 
                "EGBurnParty: You can start burn party between start date and burn date.");
        
        BurnParty storage party = burnPartyById[partyId];
        party.started = true;

        emit StartBurnParty(partyId);
    }

    /**
    * @param partyId burn party id
    * @dev end burn party by id
    *      fire `EndBurnParty` event
    */
    function endBurnParty(uint256 partyId) external onlyCreator(partyId) availableBurnParty(partyId) {
        require(burnPartyById[partyId].started == true, "EGBurnParty: Party is not started.");
        require(burnPartyById[partyId].ended == false, "EGBurnParty: Party has already ended.");
        require(block.timestamp > burnPartyById[partyId].burnDate, 
                "EGBurnParty: You can finish burn party after burn date.");
        require(IERC20(burnPartyById[partyId].partyToken).balanceOf(address(this)) 
            >= burnPartyById[partyId].currentQuantity, 
            "EGBurnParty: Current balance of token is not enough to end the burn party.");
        require(burnPartyById[partyId].currentQuantity >= burnPartyById[partyId].requiredQuantity, 
            "EGBurnParty: Tokens currently staked are less than the quantity required for the burn");

        BurnParty storage party = burnPartyById[partyId];
        party.ended = true;

        IERC20(burnPartyById[partyId].partyToken)
            .transfer( burnTokenInfoByAddress[burnPartyById[partyId].partyToken].burnAddress, burnPartyById[partyId].currentQuantity);

        emit EndBurnParty(partyId);
    }

    /**
    * @param partyId burn party id
    * @dev cancel burn party by id
    *      fire `CancelBurnParty` event
    */
    function cancelBurnParty(uint256 partyId) external onlyCreator(partyId) availableBurnParty(partyId) {
        require(burnPartyById[partyId].started == true, "EGBurnParty: Party has not started.");
        require(burnPartyById[partyId].ended == false, "EGBurnParty: Party has already ended.");
        require(burnPartyById[partyId].currentQuantity < burnPartyById[partyId].requiredQuantity, 
                "EGBurnParty: You cannot cancel the burn party which has collected the required tokens.");
        require(block.timestamp > burnPartyById[partyId].burnDate, "EGBurnParty: You can cancel a burn party only after burn date.");

        BurnParty storage party = burnPartyById[partyId];
        party.ended = true;
        party.cancelled = true;

        emit CancelBurnParty(partyId);
    }

    /**
    * @param partyId burn party id
    * @dev remove burn party by id
    *      fire `RemoveBurnParty` event
    */
    function removeBurnParty(uint256 partyId) external onlyCreator(partyId) availableBurnParty(partyId) {
        require(burnPartyById[partyId].started == false, "EGBurnParty: You can remove a burn party only before start date.");

        uint256 stakedAmount = stakesList[msg.sender][partyId];
        stakesList[msg.sender][partyId] = 0;
        
        IERC20(burnPartyById[partyId].partyToken)
            .transfer(msg.sender, stakedAmount);
        
        delete burnPartyById[partyId];

        emit RemoveBurnParty(partyId);
    }

    /**
    * @param partyId burn party id
    * @param tokenAmount stake token amount
    * @dev  fire `StakeBurnParty` event
    */
    function stakeBurnParty(uint256 partyId, uint256 tokenAmount) external availableBurnParty(partyId) {
        require(tokenAmount > 0, "EGBurnParty: Amount required to burn should be a positive number.");
        require(burnPartyById[partyId].started == true, "EGBurnParty: Burn Party has not started.");
        require(burnPartyById[partyId].ended == false, "EGBurnParty: Burn Party has ended.");
        require(IERC20(burnPartyById[partyId].partyToken).balanceOf(msg.sender) >= tokenAmount, "EGBurnParty: Your token balance is insufficient for this burn party stake.");

        if(stakesList[msg.sender][partyId] == 0)
            burnPartyById[partyId].stakeCounter++;

        burnPartyById[partyId].currentQuantity += tokenAmount;
        stakesList[msg.sender][partyId] += tokenAmount;

        IERC20(burnPartyById[partyId].partyToken).transferFrom(msg.sender, address(this), tokenAmount);

        emit StakeBurnParty(partyId, tokenAmount);
    }

    /**
    * @param partyId burn party id
    * @dev fire `UnstakeFromBurnParty` event
    */
    function unstakeFromBurnParty(uint256 partyId) external availableBurnParty(partyId) {
        require(stakesList[msg.sender][partyId] > 0, "EGBurnParty: You have not participated in this burn party.");
        require( burnPartyById[partyId].cancelled == true, 
                 "EGBurnParty: You can unstake when the burn party is cancelled or after burn date.");
        require(IERC20(burnPartyById[partyId].partyToken).balanceOf(address(this)) >= stakesList[msg.sender][partyId], 
                    "EGBurnParty: Out of balance.");

        burnPartyById[partyId].currentQuantity -= stakesList[msg.sender][partyId];
        burnPartyById[partyId].stakeCounter--;
        uint256 unstakeAmount = stakesList[msg.sender][partyId];
        stakesList[msg.sender][partyId] = 0;
        
        IERC20(burnPartyById[partyId].partyToken).transfer(msg.sender, unstakeAmount);

        emit UnstakeFromBurnParty(partyId);
    }

    function getBlockTimeStamp() external view returns (uint256){
        return block.timestamp;
    }
}