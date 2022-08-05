/**
 *Submitted for verification at BscScan.com on 2022-08-04
*/

/*

 Aurum Finance - Aurum Arcade

*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() external virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) external virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

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
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract AurumArcade is Context, Ownable {

    // Player Stats / Ranking
    enum GameOutcome{ WIN, LOSE }
    enum PlayerRanks{ BRONZE, SILVER, GOLD, PLATINUM, DIAMOND, PREDATOR }
    int public BronzeScore = 0;
    int public SilverScore = 500;
    int public GoldScore = 1000;
    int public PlatinumScore = 1500;
    int public DiamondScore = 2000;
    int public PredatorScore = 2500;

    // Setting a default value
    PlayerRanks constant startingRank = PlayerRanks.BRONZE;
    
    struct PlayerRankingEntity{    
        PlayerRanks rank;      // players current rank
        int rankScore;         // player rank score
        uint256 wins;          // total wins
        uint256 loses;         // totals loses
    }

    // ranking score logic
    int public challengeWinRankIncrease = 100;    
    int public challengeLostRankIncrease = -100;      
    mapping (address => bool) public accountBlacklisted;  // users blacklisted  
    
    mapping (address => PlayerRankingEntity)  private playerRankings;  // users ranks
    

    /* ----------------------------------------------
    * RANKING METHODS 
    * ---------------------------------------------- */
      	
  	// @dev Arcade Public functions -------------------------------------
    function getPlayerRanking(address _account) public view returns(PlayerRankingEntity memory) {      
        return playerRankings[_account];
    }

    function updateRankingIncreaseLogic(int _challengeWinRankIncrease, int _challengeLostRankIncrease) external onlyOwner {      
        challengeWinRankIncrease = _challengeWinRankIncrease;
        challengeLostRankIncrease = _challengeLostRankIncrease;
    }

    function updateRankingLogic(int _BronzeScore,int _SilverScore,int _GoldScore,int _PlatinumScore,int _DiamondScore,int _Predator) external onlyOwner { 
        BronzeScore = _BronzeScore;
        SilverScore = _SilverScore;
        GoldScore = _GoldScore;
        PlatinumScore = _PlatinumScore;
        DiamondScore = _DiamondScore;
        PredatorScore = _Predator;
    }
    
    function resetPlayerRankStats(address _account) external onlyOwner {
        playerRankings[_account].wins = 0;
        playerRankings[_account].loses = 0;
        playerRankings[_account].rankScore = 0;
        playerRankings[_account].rank = PlayerRanks.BRONZE;
    }

    
    function setBlacklistedPlayer(address _account, bool isBlacklisted) external onlyOwner {
        accountBlacklisted[_account] = isBlacklisted;
    }
    
    function isBlacklistedPlayer(address _account) public view returns (bool){
      return accountBlacklisted[_account];
    }

  	// @dev Arcade Private functions -------------------------------------
    function updatePlayerRanking(address _account, GameOutcome _outcome, int _rankScore) private {              
        
        if(_outcome == GameOutcome.WIN){
            playerRankings[_account].wins ++;
            playerRankings[_account].rankScore += _rankScore;
        }
        else if (_outcome == GameOutcome.LOSE){
            playerRankings[_account].loses ++;
            playerRankings[_account].rankScore -= _rankScore;
        }
        
        // BRONZE
        if(playerRankings[_account].rankScore < SilverScore){
            playerRankings[_account].rank = PlayerRanks.BRONZE;
        }
        // SILVER
        else if(playerRankings[_account].rankScore < SilverScore){
            playerRankings[_account].rank = PlayerRanks.SILVER;
        }
        // GOLD
        else if(playerRankings[_account].rankScore < SilverScore){
            playerRankings[_account].rank = PlayerRanks.GOLD;
        }
        // PLATINUM
        else if(playerRankings[_account].rankScore < SilverScore){
            playerRankings[_account].rank = PlayerRanks.PLATINUM;
        }
        // DIAMOND
        else if(playerRankings[_account].rankScore < SilverScore){
            playerRankings[_account].rank = PlayerRanks.DIAMOND;
        }
        // PREDATOR
        else{
            playerRankings[_account].rank = PlayerRanks.PREDATOR;
        }
    } 
    
    /* ----------------------------------------------
    * WEEKLY CONTEST METHODS 
    * ---------------------------------------------- */
 
    // Weekly Contest Variables
     struct WeeklyContestEntity {
        uint256 contestId;                          // unique identifier 
        string gameName;                            // name of game
        uint256 creationTime;                       // contest creation time
        uint256 contestPrice;                       // contest entry fee  
        uint256 numOfcontestants;                   // total numnber of contestants
        bool active;                                // contest active
    }

    WeeklyContestEntity[] public contests;                  // list of contests    
    mapping (address => uint256[])  private usersContests;  // users contests
    uint256[] private activeContests;                       // active contest ids
    uint256 public totalContestCreated = 0;                 // total number of contests
    uint256 public totalContestants = 0;                    // total number of contestants
    uint256 public totalStaked = 0;                         // total number of staked tokens

    uint256 public contestFee = 0;                  // contest fees
    uint256 public feeDenomiator = 100;             // fee multipler
    address public feeWallet = 0x01976b2c219B41149310aF8149b0f87BC077bb0b; 

    // Create link to Aurum Contract
    IERC20 public AURUM = IERC20(0xA7253E993E69F89feb7874bfbA1c8410F3a7cA3c);

    constructor() { }
    
    /* ----------------------------------------------
    * CONTEST METHODS 
    * ---------------------------------------------- */
  	// @dev Owner functions start -------------------------------------

    function createContest(string memory _gameName, uint256 _entryFee) external onlyOwner {
        
        // contest creation conditions
        require(bytes(_gameName).length > 0, "GameName is required");  
        require(bytes(_gameName).length > 32, "GameName cannot be longer than 32 characters");       
        require(_entryFee > 0, "Game entry fee should be not 0");    

        // create contest   
        contests.push(
            WeeklyContestEntity({
                contestId: (totalContestCreated + 1),
                gameName: _gameName,
                creationTime: block.timestamp,
                contestPrice: _entryFee,
                numOfcontestants: 0,
                active: true
            })
        );
        activeContests.push(totalContestCreated + 1);

        // increment stat counters
        totalContestCreated++;
    }
    
    function AddContestant(uint256 _contestId, address _account) external onlyOwner {
        require(!isBlacklistedPlayer(_account), "This address has been blacklisted");
        uint256 contestIndex = getContestIndex(_contestId);
        require(!checkIfContestant(_contestId,_account), "The address is already part of the contest");        
        contests[contestIndex].numOfcontestants++;
        usersContests[_account].push(_contestId);
        totalContestants++;
    }
    
    function endContest(uint256 _contestId, address payable[] memory winnders,  uint256[] memory payOutPercentage) external onlyOwner {
        uint256 contestIndex = getContestIndex(_contestId);
        require(winnders.length > 0 , "winnders arrays must be > 0");
        require(payOutPercentage.length > 0 , "payOutPercentage arrays must be > 0");
        require(winnders.length == payOutPercentage.length, "endContest:: Arrays must be the same length");
        require(contests[contestIndex].numOfcontestants > 0, "contest has no contestentas");

        // payout winners
        uint256 contestPrice = contests[contestIndex].contestPrice;
        uint256 contestPot = contestPrice * contests[contestIndex].numOfcontestants;
        for(uint i = 0; i < winnders.length; i++){            
            uint256 reward = contestPot*payOutPercentage[i]/feeDenomiator;
            AURUM.transfer(winnders[i], reward);
        }

        contests[contestIndex].active = false;
        removeActiveGame(_contestId);
    }
    
    function setTeamWallet(address _wallet) external onlyOwner {
        feeWallet = _wallet;
    }

    function setContestFee(uint256 _fee) external onlyOwner {
        contestFee = _fee;
    }

  	// @dev Arcade Public functions -------------------------------------

    function joinContest(uint256 _contestId) external {
        // contest conditions - active and account not already playing
        uint256 contestIndex = getContestIndex(_contestId);
        require(contests[contestIndex].active, "ContestId is still no longer active.");
        address account = msg.sender;
        require(!isBlacklistedPlayer(account), "This address has been blacklisted");
        require(!checkIfContestant(_contestId,account), "Your already taking part in the contest"); 

        // take contest price from user wallet
        uint256 contestPrice = contests[contestIndex].contestPrice;
        AURUM.transferFrom(account, address(this), contestPrice);

        // if contest fee enabled send to fee wallet 
        if(contestFee > 0){
            uint256 operationsPrice = contestPrice*contestFee/feeDenomiator;
            AURUM.transfer(feeWallet, operationsPrice);  
        }

        // add wallet to contest
        contests[contestIndex].numOfcontestants++;
        usersContests[account].push(_contestId);

        // increment stat counters
        totalContestants++;
        totalStaked+= contestPrice;
    }
    
    function getContestInfo(uint256 _contestId) public view returns(WeeklyContestEntity memory) {      
        require(contests.length > 0, "No current contests");    
        // contest conditions - exists and active
        uint256 contestIndex = getContestIndex(_contestId);
        return contests[contestIndex];
    }
    
    function getAllActiveContests() public view returns(uint256[] memory) { 
        require(activeContests.length > 0, "No active contests");  
        return activeContests;
    }
    
    function getAllContests() public view returns(WeeklyContestEntity[] memory allContests) { 
        require(contests.length > 0, "No current contests");  
        return allContests = contests;
    }
    
    function isContestant(uint256 _contestId, address _account) public view returns (bool){
        return checkIfContestant(_contestId, _account);
    }

  	// @dev Arcade Private functions -------------------------------------
    function removeActiveGame(uint256 _contestId) private {
        
        // remove active game from active array
        uint256 removedIndex;
        bool gameRemoved = false;
        for(uint256 i = 0; i < activeContests.length; i++){
            if(activeContests[i] == _contestId){         
                delete activeContests[i];
                removedIndex = i;
                gameRemoved = true;
                break;
            }
        }

        // move all elements up from the element we want to delete. Then pop the last element because it isn't needed anymore.
        if(gameRemoved){
            for (uint256 i = removedIndex; i < activeContests.length - 1; i++) {
                activeContests[i] = activeContests[i + 1];
            }
            activeContests.pop();
        }
    }

    function getContestIndex(uint256 _contestId) internal view returns (uint256)  {
        // consumable conditions - exists and active
        require(contests.length > 0, "No current contests"); 
        uint256  requestedContestIndex = 0;
        for(uint256 i = 0; i < contests.length; i++){
            if(contests[i].contestId == _contestId){
                requestedContestIndex = i;
                break;
            }
        }        
        require(requestedContestIndex>0, "ContestId doesnt exist."); 
        return requestedContestIndex;      
    }  

    function checkIfContestant(uint256 _contestId, address _account) internal view returns (bool) {
        
        uint256[] storage enteredContests = usersContests[_account];
        uint256 enteredContestsCount = enteredContests.length;
        require(enteredContestsCount > 0, "Address currently isnt in any contests");
        
        bool hasEnterContest = false; 
        for (uint256 i = 0; i < enteredContestsCount; i++) {
            if(enteredContests[i] == _contestId){
                hasEnterContest = true;
                break;
            }
        } 
        return hasEnterContest;
    }    
     
 
    /* ----------------------------------------------
    * CONSUMABLE METHODS 
    * ---------------------------------------------- */
    // In Game Consumables Contest Variables
    struct InGameConsumablesEntity {
        uint256 consumableId;                       // unique identifier 
        string gameName;                           // name of game 
        string consumableName;                     // name of consumable 
        uint256 consumablePrice;                    // consumable purchase fee  
        uint256 totalPurchases;                     // total purchases   
        uint256 expiryDays;                         // consumable expiry fee  
        bool expires;                               // consumable expires    
        bool active;                                // consumable active
    }

    struct OwnedConsumablesEntity {
        uint256 consumableId;                       // unique identifier 
        uint256 purchaseDate;                       // consumable purchase date 
        uint256 expiryDays;                         // consumable expiry fee      
    }

    InGameConsumablesEntity[] public consumables;                   // list of consumables 
    uint256 public totalConsumablesCreated = 0;                     // total number of consumables
    uint256[] private activeConsumables;                            // active consumable ids
    mapping(address => OwnedConsumablesEntity[]) consumablesOwned;  // list of consumables (by consumableId)    
    uint256 public totalConsumablesBought = 0;                      // total number of aurum burned
    uint256 public totalAurumBurned = 0;                            // total number of aurum burned

  	// @dev Owner functions start -------------------------------------

    function createConsumable(string memory _gameName, string memory _consumableName, uint256 _consumablePrice, uint256 expiryDays) external onlyOwner {
        
        // contest creation conditions
        require(bytes(_gameName).length > 0, "GameName is required");  
        require(bytes(_gameName).length > 32, "GameName cannot be longer than 32 characters");      
        require(bytes(_consumableName).length > 0, "ConsumableName is required");  
        require(bytes(_consumableName).length > 32, "ConsumableName cannot be longer than 32 characters");       
        require(_consumablePrice > 0, "Game entry fee should be not 0");    

        // create consumable   
        consumables.push(
            InGameConsumablesEntity({
                consumableId: (totalConsumablesCreated + 1),
                gameName: _gameName,
                consumableName: _consumableName,
                consumablePrice: _consumablePrice,
                totalPurchases: 0,
                expiryDays: expiryDays,
                expires: (expiryDays > 0),
                active: true
            })
        );
        activeConsumables.push(totalConsumablesCreated + 1);
        
        // increment stat counters
        totalConsumablesCreated++;
    }

    function updateConsumable(uint256 _consumableId, uint256 _consumablePrice, uint256 _expiryDays, bool _active) external onlyOwner { 
        // consumable conditions - exists and active      
        uint256 consumableIndex = getConsumableIndex(_consumableId);
        require(_consumablePrice > 0, "Game entry fee should be not 0");    
        consumables[consumableIndex].consumablePrice = _consumablePrice;  
        consumables[consumableIndex].expiryDays = _expiryDays;  
        consumables[consumableIndex].active = _active; 

        if(_active){
            bool isActive = false;
            for (uint256 i; i< activeConsumables.length;i++){
                if (activeConsumables[i] ==_consumableId){
                    isActive = true;
                    break;
                }
            }
            if(!isActive){
                activeConsumables.push(totalConsumablesCreated + 1);
            }            
        }else{
            removeActiveConsumable(_consumableId);
        }
    } 
    
    function AddConsumable(uint256 _consumableId, address _account) external onlyOwner {        
        uint256 consumableIndex = getConsumableIndex(_consumableId);
        require(!checkIfHasConsumable(_consumableId,_account), "The address already own this consumable");        
        require(!consumables[consumableIndex].active, "This consumable is no longer active");        
        
        consumablesOwned[_account].push(
            OwnedConsumablesEntity({
                consumableId: _consumableId,
                purchaseDate: block.timestamp,
                expiryDays: consumables[consumableIndex].expiryDays
            })
        );        
    }
          
  	// @dev Arcade Public functions -------------------------------------
    function buyConsumable(uint256 _consumableId) external {
        // consumable conditions - active and account not already playing       
        uint256 consumableIndex = getConsumableIndex(_consumableId);
        address account = msg.sender;
        require(!checkIfHasConsumable(_consumableId, account), "The address already own this consumable");        
        require(!consumables[consumableIndex].active, "This consumable is no longer active");  

        // take contest price from user wallet
        uint256 consumablePrice = consumables[consumableIndex].consumablePrice;
        AURUM.transferFrom(account, address(0xdead), consumablePrice);

        // add consumable to address 
        consumablesOwned[account].push(
            OwnedConsumablesEntity({
                consumableId: _consumableId,
                purchaseDate: block.timestamp,
                expiryDays: consumables[consumableIndex].expiryDays
            })
        );        

        // increment stat counters
        totalConsumablesBought++;
        consumables[consumableIndex].totalPurchases++;
        totalAurumBurned+= consumablePrice;
    }

  	 
    function getConsumableInfo(uint256 _consumableId) public view returns( InGameConsumablesEntity memory) {        
        // consumable conditions - exists and active
        uint256 consumableIndex = getConsumableIndex(_consumableId); 
        return consumables[consumableIndex];  
    } 
        
    function getAllActiveConsumables() public view returns(uint256[] memory) { 
        require(activeConsumables.length > 0, "No active consumables");  
        return activeConsumables;
    }
    
    function getAllPlayerConsumables(address _account) public view returns(OwnedConsumablesEntity[] memory) { 
        require(consumablesOwned[_account].length > 0, "No current owned consumables");
        return consumablesOwned[_account];
    }
     
    function getAllConsumables() public view returns(InGameConsumablesEntity[] memory allConsumables) { 
        return allConsumables = consumables;
    }

  	// @dev Arcade Private functions -------------------------------------
    function removeActiveConsumable(uint256 _consumableId) private {
        
        // remove active game from active array
        uint256 removedIndex;
        bool consumableRemoved = false;
        for(uint256 i = 0; i < activeConsumables.length; i++){
            if(activeConsumables[i] == _consumableId){         
                delete activeConsumables[i];
                removedIndex = i;
                consumableRemoved = true;
                break;
            }
        }

        // move all elements up from the element we want to delete. Then pop the last element because it isn't needed anymore.
        if(consumableRemoved){
            for (uint256 i = removedIndex; i < activeConsumables.length - 1; i++) {
                activeConsumables[i] = activeConsumables[i + 1];
            }
            activeConsumables.pop();
        }
    }

    function getConsumableIndex(uint256 _consumableId) internal view returns (uint256)  {
        // consumable conditions - exists and active
        require(consumables.length > 0, "No current consumables");
        uint256 requestedConsumableIndex = 0;
        for(uint256 i = 0; i < consumables.length; i++){
            if(consumables[i].consumableId == _consumableId){
                requestedConsumableIndex = i;
                break;
            }
        }        
        require(requestedConsumableIndex>0, "ConsumableId doesnt exist."); 
        return requestedConsumableIndex;      
    }

    function checkIfHasConsumable(uint256 _consumableId, address _account) internal view returns (bool) {

        uint256 consumableIndex = getConsumableIndex(_consumableId);
        bool hasActiveConsumable;                 
        OwnedConsumablesEntity[] storage accountConsumables = consumablesOwned[_account];
        uint256 ownedConsumableCount = accountConsumables.length;
        require(ownedConsumableCount > 0, "Address doesnt own any consumables");
         
        for (uint256 i = 0; i < ownedConsumableCount; i++) {
            if(accountConsumables[i].consumableId == _consumableId){
                // 60 (to get the minutes), 60 (to get the hours) and 24 (to get the days)
                uint daysDiff = (block.timestamp - accountConsumables[i].purchaseDate) / 60 / 60 / 24; 
                if(daysDiff <= consumables[consumableIndex].expiryDays){
                    hasActiveConsumable=true; 
                    break;
                }
            }
        } 

        return hasActiveConsumable;
    }     
    
    /* ----------------------------------------------
    * Challenges METHODS 
    * ---------------------------------------------- */
    // In Game Challenges Variables
    struct InGameChallengesEntity {
        address challenger;                         // address of challenger
        uint256 challengeId;                        // unique identifier 
        uint256 createdDate;                        // challenge creation date 
        uint256 startedDate;                        // challenge start date 
        string gameName;                           // name of game  
        uint256 challengeStake;                     // stake price     
        uint256 challengeScore;                     // challenger score
        PlayerRanks challengeRanking;               // challenger rank 

        address opponent;                           // address of opponent
        uint256 opponentScore;                      // opponent score
        PlayerRanks opponentRanking;                // opponent rank 

        bool challengeAccepted;                     // challenge active
        bool claimed;                               // challenge claimed
    } 

    uint256 public challengeAllowedHours = 1;           // hours allowed for response score

    InGameChallengesEntity[] public challenges;         // list of challenges 
    mapping(address => uint256[]) playerChallenges;     // list of player challenges (by challengeId)    
    uint256[] private activeChallenges;                 // active challenge ids
    uint256 public totalChallengesCreated = 0;          // total number of challenges 

  	// @dev Owner functions start -------------------------------------

  	// @dev Arcade Public functions -------------------------------------
     function createChallenge(string memory _gameName, uint256 _challengeStake, uint256 _challengeScore) external {
         
        address account = msg.sender;

        // challenges creation conditions
        require(!isBlacklistedPlayer(account), "This address has been blacklisted");
        require(bytes(_gameName).length > 0, "GameName is required");  
        require(bytes(_gameName).length > 32, "GameName cannot be longer than 32 characters");          
        require(_challengeStake > 0, "Challenge stake should be not 0");            
        require(_challengeScore > 0, "Challenge score should be not 0");    
        PlayerRankingEntity memory challengerRanking = getPlayerRanking(account);

        // take challenges stake from user wallet 
        AURUM.transferFrom(account, address(this), _challengeStake);

        // create challenges   
        InGameChallengesEntity memory newChallenge;
        newChallenge.challenger = account;
        newChallenge.challengeId = (totalChallengesCreated + 1);
        newChallenge.createdDate = block.timestamp;
        newChallenge.gameName = _gameName;
        newChallenge.challengeStake = _challengeStake;
        newChallenge.challengeScore = _challengeScore;
        newChallenge.challengeRanking = challengerRanking.rank;
        newChallenge.challengeAccepted = false;
        newChallenge.claimed = false;

        challenges.push(newChallenge);
        playerChallenges[account].push(totalChallengesCreated + 1);
        
        // increment stat counters
        totalChallengesCreated++;
        totalStaked+= _challengeStake;
    }

    function acceptChallenge(uint256 _challengeId) external {
           
        // challenges creation conditions
        uint256 challengeIndex = getChallengeIndex(_challengeId);
        require(!challenges[challengeIndex].challengeAccepted, "Challenge has already been accepted.");
        
        address account = msg.sender;
        require(!isBlacklistedPlayer(account), "This address has been blacklisted");
        PlayerRankingEntity memory opponentRanking = getPlayerRanking(account);
        require(account != challenges[challengeIndex].challenger, "You cannot challenge yourself");
        require(opponentRanking.rank > challenges[challengeIndex].challengeRanking, "You cannot accept lower ranked challenges");
   
        // take challenges stake from user wallet 
        AURUM.transferFrom(account, address(this), challenges[challengeIndex].challengeStake);

        // set opponent
        challenges[challengeIndex].opponent = account;
        challenges[challengeIndex].opponentRanking = opponentRanking.rank;
        challenges[challengeIndex].challengeAccepted = true; 
        challenges[challengeIndex].startedDate = block.timestamp;
        playerChallenges[account].push(totalChallengesCreated + 1);
        
        // increment stat counters
        totalStaked+= challenges[challengeIndex].challengeStake;
    }

    function setChallengeOpponentsScore(uint256 _challengeId, uint256 _opponentScore) external {
         
        address account = msg.sender;
        require(!isBlacklistedPlayer(account), "This address has been blacklisted");

        // challenges creation conditions
        uint256 challengeIndex = getChallengeIndex(_challengeId);
        require(account != challenges[challengeIndex].opponent, "You are not the opponent");

        uint hoursDiff = (block.timestamp - challenges[challengeIndex].startedDate) / 60 / 60;                     
        require(challenges[challengeIndex].opponentScore == 0 , "Score has already been submited");                  
        require(hoursDiff <= challengeAllowedHours, "Challenge time has expired");
        
        // set opponent
        challenges[challengeIndex].opponentScore = _opponentScore;
    } 
        
    function getAllActiveChallenges() public view returns(uint256[] memory) { 
        require(activeChallenges.length > 0, "No active challenges");  
        return activeChallenges;
    }
    
    function getAllChallenges() public view returns(InGameChallengesEntity[] memory) { 
        require(challenges.length > 0, "No current challenges");  
        return challenges;
    }
    
    function getAllPlayerGameChallengeIds(address _account) public view returns(uint256[] memory) { 
        require(playerChallenges[_account].length > 0, "No current challenges");  
        return playerChallenges[_account];
    }
    
    
    function getaddressChallangeClaimablePot(address _account) public view returns(uint256) { 
        require(challenges.length > 0, "No current challenges");  
        uint256 winningPot = 0;
        for(uint256 i = 0; i < challenges.length; i++){  
            if(!challenges[i].claimed){
                if(challenges[i].challenger == _account){            
                    // 60 (to get the minutes), 60 (to get the hours) 
                    uint hoursDiff = (block.timestamp - challenges[i].startedDate) / 60 / 60; 
                    if((challenges[i].challengeScore > challenges[i].opponentScore) || (hoursDiff > challengeAllowedHours && !(challenges[i].challengeScore < challenges[i].opponentScore))){
                        winningPot+= (challenges[i].challengeStake * 2);
                    }
                } 
                else if(challenges[i].opponent == _account){    
                    if(challenges[i].opponentScore > challenges[i].challengeScore){
                        winningPot+= (challenges[i].challengeStake * 2);
                    }
                }
            }
        }
        return winningPot;
    }

        
    function claimChallangePot() external { 
        require(challenges.length > 0, "No current challenges");  
        address account = msg.sender;
        require(!isBlacklistedPlayer(account), "This address has been blacklisted");
        uint256 rewardsTotal = 0;
        for(uint256 i = 0; i < challenges.length; i++){  
            if(!challenges[i].claimed){
                if( challenges[i].challenger == account){            
                    // 60 (to get the minutes), 60 (to get the hours) 
                    uint hoursDiff = (block.timestamp - challenges[i].startedDate) / 60 / 60; 
                    if((challenges[i].challengeScore > challenges[i].opponentScore) || (hoursDiff > challengeAllowedHours && !(challenges[i].challengeScore < challenges[i].opponentScore))){
                       rewardsTotal += (challenges[i].challengeStake * 2);
                       challenges[i].claimed = true;
                       updatePlayerRanking(challenges[i].challenger, GameOutcome.WIN, challengeWinRankIncrease);
                       updatePlayerRanking(challenges[i].opponent, GameOutcome.LOSE, challengeLostRankIncrease);
                    }
                } 
                else if( challenges[i].opponent == account){    
                    if(challenges[i].opponentScore > challenges[i].challengeScore){
                        rewardsTotal += (challenges[i].challengeStake * 2);
                        challenges[i].claimed = true;
                       updatePlayerRanking(challenges[i].opponent, GameOutcome.WIN, challengeWinRankIncrease);
                       updatePlayerRanking(challenges[i].challenger, GameOutcome.LOSE, challengeLostRankIncrease);
                    }
                }
            }
        }
        AURUM.transfer(account, rewardsTotal);   
    }

  	// @dev Arcade Private functions -------------------------------------        
    function removeActiveChallenge(uint256 _challengeId) private {
        
        // remove active challenge from active array
        uint256 removedIndex;
        bool challengeRemoved = false;
        for(uint256 i = 0; i < activeChallenges.length; i++){
            if(activeChallenges[i] == _challengeId){         
                delete activeChallenges[i];
                removedIndex = i;
                challengeRemoved = true;
                break;
            }
        }

        // move all elements up from the element we want to delete. Then pop the last element because it isn't needed anymore.
        if(challengeRemoved){
            for (uint256 i = removedIndex; i < activeChallenges.length - 1; i++) {
                activeChallenges[i] = activeChallenges[i + 1];
            }
            activeChallenges.pop();
        }
    }

    function getChallengeIndex(uint256 _challengeId) internal view returns (uint256)  {
        // challenge conditions - exists and active
        require(challenges.length > 0, "No current challenges");
        uint256 requestedChallengeIndex = 0;
        for(uint256 i = 0; i < challenges.length; i++){
            if(challenges[i].challengeId == _challengeId){
                requestedChallengeIndex = i;
                break;
            }
        }        
        require(requestedChallengeIndex>0, "ContestId doesnt exist."); 
        return requestedChallengeIndex;      
    }  

    // Claim BNB awards
    function claim() public payable onlyOwner {
        address account = msg.sender;
        payable(account).transfer(address(this).balance);    
    }
}