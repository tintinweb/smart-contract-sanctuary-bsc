/**
 *Submitted for verification at BscScan.com on 2022-09-14
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;


interface Common {
  enum State { GENERATED, COLLECTED, RECYCLED }
  enum Category { COLLECTOR, GENERATOR, RECYCLER, BINOWNER }
  enum Share { COLLECTOR, GENERATOR, TEAM }

  error UserAlreadyExist();
  error UserAlreadyNotExist();
  error InvalidBinID();
  error EmptyBin();
  error CannotDeleteBinInEngagedMode();
  error InvalidWasteId();

  struct WasteData {
    bytes32 value;
    address collector;
    address generator;
    address recycler;
    State state;
  }

  struct Profile {
    uint32 transactionTime;
    uint wasteCount;
    bool approval;
    bool isRegistered;
  }

  struct BinData {
    WasteData[] bin;
    address owner;
  }

}

library WasteToWealthLib {
  /**
    @dev Sign up new collector
      @param self - Storage
      @param newCollector - Address of new Collector to add.
   */
  function registerCollector(mapping (Common.Category=>mapping(address=>Common.Profile)) storage self, address newCollector) internal {
    self[Common.Category.COLLECTOR][newCollector] = Common.Profile(_now(), 0, false, true);
  }

  /**
    @dev Dual function: 
            o Recycles collected waste.
            o Generate new waste.
   */
  function portToMap(
    mapping (Common.State=>Common.WasteData[]) storage self, 
    Common.WasteData memory inWaste,
    Common.State state
  ) internal {
    self[state].push(Common.WasteData(
        inWaste.value,
        inWaste.collector,
        inWaste.generator,
        inWaste.recycler,
        state
      )
    );
  }

  function portToArray(Common.BinData[] storage self, uint binId, Common.WasteData memory inWaste, Common.State state) internal {
    self[binId].bin.push(Common.WasteData(
      inWaste.value,
      inWaste.collector,
      inWaste.generator,
      inWaste.recycler,
      state
    )
    );
  }

  function popFromMapping(mapping (Common.State=>Common.WasteData[]) storage self, uint wasteId, Common.State state) internal returns(Common.WasteData memory _waste) {
    _waste = self[state][wasteId];
    delete self[state][wasteId];
  }

  function popFromArray(Common.BinData[] storage self, uint binId, uint wasteId) internal returns(Common.WasteData memory _waste) {
    _waste = self[binId].bin[wasteId];
    delete self[binId].bin[wasteId];
  }

  /**
    @dev Sets collectors status to either true or false
    @param value - Value to set status to.
    @param who - User to set status for.
    @param self - storage.
      Note : If value is true, collector's status must be false vice versa.
   */
  function setStatus(mapping (Common.Category=>mapping(address=>Common.Profile)) storage self, address who, bool value, Common.Category cat) internal {
    bool prevStatus = _previousStatus(self, who, cat);
    if(value) {
      if(prevStatus) revert Common.UserAlreadyExist();
      self[cat][who].approval = true;
    } else {
      if(!prevStatus) revert Common.UserAlreadyNotExist();
      self[cat][who].approval = false;
    }
  }

  function _previousStatus(mapping (Common.Category=>mapping(address=>Common.Profile)) storage self, address who, Common.Category cat) private view returns(bool) {
    return self[cat][who].approval;
  }

  /**
    @dev Registers new bin with owner.
        @param owner - Bin Owner
        @param self - Storage
        @return newId 
   */
  function registerNewBin(Common.BinData[] storage self, address owner) internal returns(uint newId) {
    newId = self.length;
    self.push();
    self[newId].owner = owner;
  }

  /**
    @dev Removes bin from bin array.
      @notice binId must be less than the bin array at any time since arrays are zero-based.
      @param self - Storage
   */
  function removeBin(Common.BinData[] storage self, uint binId) internal {
    (uint len, Common.BinData memory wasteBin)  = (self.length, self[binId]);
    if(wasteBin.bin.length == 0) revert Common.EmptyBin();
    for(uint i = 0; i < len; i++) {
      if(wasteBin.bin[i].state < Common.State.RECYCLED) {
        revert Common.CannotDeleteBinInEngagedMode();
      }
    } 
    delete self[binId];
  }

  function split(mapping (Common.Share=>uint8) storage self, uint amount) internal view returns(uint collector, uint generator, uint team) {
    collector = (self[Common.Share.COLLECTOR] * amount) / 100;
    generator = (self[Common.Share.GENERATOR] * amount) / 100;
    team = (self[Common.Share.TEAM] * amount) / 100;

  }

  function _now() internal view returns(uint32) { return uint32(block.timestamp); }

}


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


/**
 * @title Main
 * @author Bobeu: https://github.com/bobeu
 * A smart contract that will tokenize the disposal and collection of waste. 
    Users get a token when they dispose of their waste in a waste bin, collectors 
    get token for collecting waste and taking them to the waste recyclers 

    The process of tokenization happens when the waste drops in the waste bin. Every
    waste bin has a unique wallet ID which will receive the token at the end of evacuation.
    The owners of the waste bin will have a DAO. 

    *Wallet 
    *Token (iBoola token) which would be paired against either Avalanche, Celo or Polygon 
    *New users get 10 $IBT after sign up 
    *Community of waste bins will have a DAO 
    Waste generators get 10% collectors get 65 while the iBoola team gets 25% 
    Decimals: use standard 18 decimals 

    Mintable: not mintable

    Ownership privilege :  30% locked for 5 years, 20% for dev team 45% for  initial circulation, 
    5% for presale 

    PSEUDO
    ======
    Parties:
        o Waste generators.
        o Collectors.
        o Recyclers.

    o When waste is disposed or evacuated, then reward collectors.
    o Each waste bin has a unique identifer and an owner.
    o On sign up, user gets 10 $IBT Token.
    o Waste collectors own a DAO.
    o Waste bin owners own a DAO.
    o Reward sharing formula
    ========================
        - Waste generators 10%.
        - Collectors 65%.
        - Team 25%.
 */
contract WasteToWealth is Context, Common, Ownable {

    ///@dev New sign up reward
    uint public newSignUpReward;

    ///@dev iBoola Token
    address public token;

    ///@dev Total waste generated to date
    uint256 public totalWasteGenerated;

    ///@dev Collector reward
    uint public collectorReward;

    ///@dev Total bin registered to date
    uint public binCounter;

    /**
        @dev Array of bins 
            { Contain bins which contain collected wastes which contains wastedata}
            @notice Bins in this list are owned by addresses.
    */
    BinData[] public bins;
    
    mapping (Share=>uint8) public formula;
    

    /**
        @dev Mapping of Generated and Recycled Waste State -> binId (binCounter) -> WasteData
        Keys type: 
            o State
            o uint256

        value:
           array of struct(s) 
     */
    mapping (State=>WasteData[]) public garbages;
    
    /**
        @dev Mapping of Waste State -> user -> profile
        Keys type: 
            o State
            o address

        value:
            struct 
     */
    mapping (Category=>mapping(address=>Profile)) profiles;

    /**
        @dev Sign up fees for different category.
            @notice - It can be configured to suit any category.
     */
    mapping (Category=>uint256) public signUpFees;

    ///@dev Rewards
    // mapping(address=>uint) public rewards;


    modifier validateWasteId(uint binId, uint wasteId, State state, string memory errorMessage) {
        if(binId >= bins.length) revert InvalidBinID();
        if(state == State.COLLECTED) {
            if(wasteId >= bins[binId].bin.length) revert InvalidWasteId();
        }
        require(bins[binId].bin[wasteId].state == state, errorMessage);
        _;
    }

    ///Checks user's existence
    modifier isApproved(Category cat, address who) {
        if(!_getApproval(cat, who)) revert UserAlreadyNotExist();
        _;
    }

    ///@dev Validates category
    modifier validateCategory(uint8 cat) {
        require(cat < 4, "Invalid category");
        _;
    }

    constructor (address _token) { 
        token = _token;
        newSignUpReward = 10 * (10 ** 18);
        profiles[Category.BINOWNER][_msgSender()].approval = true;
        formula[Share.COLLECTOR] = 65;
        formula[Share.GENERATOR] = 10;
        formula[Share.TEAM] = 25;
    }

    /**
        @notice Sign up function. 
                o Caller must not already be a member. 
    */
    function signUpAsWasteCollector() public {
       require(!profiles[Category.COLLECTOR][_msgSender()].isRegistered, "Already sign up");
       WasteToWealthLib.registerCollector(profiles, _msgSender());
       IERC20(token).approve(_msgSender(), newSignUpReward);
    }

    /**
        @dev Adds new bin.
            @notice Caller must already be approves as BinOwner .
    */
    function addNewBin() public payable isApproved(Category.BINOWNER, _msgSender()) {
        WasteToWealthLib.registerNewBin(bins, _msgSender());
        binCounter ++;
    }

    /**
        @dev Removes bin at binId.
            @notice Caller must already be approves as BinOwner .
    */
    function removeBin(uint binId) public isApproved(Category.BINOWNER, _msgSender()) {
        address _owner = _getBinOwner(binId);
        if(_msgSender() != owner()) require(_msgSender() == _owner, "Not Authorized");
        
        WasteToWealthLib.removeBin(bins, binId);
    }

    ///@dev Return owner of bin at binId. 
    function _getBinOwner(uint binId) internal view returns(address) {
        return bins[binId].owner;
    }

    /**
        @dev Whitelist user
            Note Admin privilege.
                cat should reference the Category enum.
     */
    function whitelistuser(address who, uint8 category) public onlyOwner validateCategory(category) {
        WasteToWealthLib.setStatus(profiles, who, true, Category(category));
    }

    /**
        @dev Blacklist user
            Note Admin privilege.
                cat should reference the Category enum.
     */
    function blacklistUser(address who, uint8 category) public onlyOwner validateCategory(category){
        WasteToWealthLib.setStatus(profiles, who, false, Category(category));
    }

    /**
        @dev Set new fee
            @notice To perfectly select the right category,
                category parameter should not be greater than 4.
     */
    function setFee(uint8 category, uint newFee) public onlyOwner {
        require(category < 4, "Invalid category");
        signUpFees[Category(category)] = newFee;
    }

    /**
        @dev Generates new waste. 
        @notice Each waste is unique to another.
            Note To successfully generate waste, bin id must be provided.
                    This represents the destination where wastes are dumped.
     */
    function generateWaste(bytes memory _data) public isApproved(Category.GENERATOR, _msgSender()) {
        State state = State.GENERATED;
        totalWasteGenerated ++;
        uint nonce = totalWasteGenerated;
        WasteToWealthLib.portToMap(
            garbages, 
             WasteData(
                keccak256(abi.encodePacked(_data, nonce)), 
                address(0), 
                _msgSender(), 
                address(0),
                state
            ), 
            state
        );
    }

    /**
        @dev Gets approval for user 'who'
            @param cat - Category of user e.g COLLECTOR etc
            @param who - Address of user.
    */
    function _getApproval(Category cat, address who) internal view returns(bool) {
        return profiles[cat][who].approval;
    }

    /**
        @dev Collect waste.
            Note : Only generated waste can be collected
            @param binId - Bin where the waste is located.
            @param wasteId - Which waste to collect.
                    Note - Every waste is unique to another.
     */
    function recycle(uint binId, uint wasteId) internal isApproved(Category.RECYCLER, _msgSender()) validateWasteId(binId, wasteId, State.COLLECTED, "Invalid waste pointer") {
        WasteData memory outWaste = WasteToWealthLib.popFromArray(bins, binId, wasteId);
        WasteToWealthLib.portToMap(garbages, outWaste, State.RECYCLED);
        uint amount = collectorReward;

        (uint collector, uint generator, uint team) = WasteToWealthLib.split(formula, amount);
        IERC20(token).approve(outWaste.collector, collector);
        IERC20(token).approve(outWaste.generator, generator);
        IERC20(token).approve(address(this), team);

        // rewards[outWaste.collector] += collector;
        // rewards[outWaste.generator] += generator;
        // rewards[address(this)] += team;
    }


    function withdraw() public {
        // uint reward = rewards[_msgSender()];
        // require(reward > 0, "No reward");
        // rewards[_msgSender()] = 0;
        // IERC20(token).transfer(_msgSender(), reward);
        uint amount = IERC20(token).allowance(address(this), _msgSender());
        IERC20(token).transferFrom(address(this), _msgSender(), amount);
    }

    function collectWaste(uint binId, uint wasteId) public isApproved(Category.COLLECTOR, _msgSender()) validateWasteId(binId, wasteId, State.GENERATED, "Invalid waste pointer") {
        require(
            profiles[Category.COLLECTOR][_msgSender()].approval && 
            profiles[Category.COLLECTOR][_msgSender()].isRegistered,
            "Not allowed"
        );
        WasteData memory outWaste = WasteToWealthLib.popFromMapping(garbages, wasteId, State.GENERATED);
        WasteToWealthLib.portToArray(bins, binId, outWaste, State.COLLECTED);

    }

    ///@dev Sets new sign up reward. Note With access modifier
    function setSignUpReward(uint newReward) public onlyOwner{
        newSignUpReward = newReward;
    }

    ///@dev Sets new sign up reward. Note With access modifier
    function setCollectorUpReward(uint newReward) public onlyOwner{
        collectorReward = newReward;
    }


}