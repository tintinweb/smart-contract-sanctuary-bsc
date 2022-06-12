/**
 *Submitted for verification at BscScan.com on 2022-06-11
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

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


contract XXXGCore is Ownable {

  IERC20 public tokenMXGF;

}



abstract contract Referal is XXXGCore {

  modifier isRegistred {
    require(parent[msg.sender] != address(0), "You are not registred");
    _;
  }

  struct User {
    bool autoReCycle;
    bool autoUpgrade;
  }

  mapping(address => User) public users;
  mapping(address => address) public parent;
  mapping(address => address[]) public childs;

  mapping(address => mapping(uint => bool)) public activate; // user -> lvl -> active

  uint32 public lastId;

   struct UserAccount {
        uint32 id;
        uint32 directSales;
        address sponsor;
        bool exists;
        uint8[] activeSlot;
       
    }

    mapping(address => mapping(uint8 => S9)) public s9Slots;
     uint8 public constant S9_LAST_LEVEL = 10;
     uint internal reentry_status;
 
struct S9 {
        address sponsor;
        uint32 directSales;
        uint16 cycleCount;
        uint8 passup;
        uint8 cyclePassup;
        uint8 reEntryCheck;
        uint8 placementPosition;
        address[] firstLevel;
        address placedUnder;
        uint8 lastOneLevelCount;
        uint8 lastTwoLevelCount;
        uint8 lastThreeLevelCount;
    }
     mapping(address => UserAccount) public userAccounts;
    mapping(uint32 => address) public idToUserAccount;
    mapping(address => mapping(uint => bool)) public activateS9; // user -> lvl -> active
       modifier isUserAccount(address _addr) {
        require(userAccounts[_addr].exists, "Register Account First");
        _;
    }

  constructor(){

      /// Set first User
      parent[msg.sender] = msg.sender;
      users[msg.sender] = User(false,false);
      for (uint i = 0; i < 12; i++) {
          activate[msg.sender][i] = true;
      } 


      createAccount(msg.sender, msg.sender, true);

      
  }

  

   function createAccount(address _user, address _sponsor, bool _initial) internal {

        require(!userAccounts[_user].exists, "Already a Singhs Account");

        if (_initial == false) {
            require(userAccounts[_sponsor].exists, "Sponsor doesnt exists");
        }

        lastId++;

          userAccounts[_user] = UserAccount({
             id: lastId,
             sponsor: _sponsor,
             exists: true,
             directSales: 0,
             activeSlot: new uint8[](2)
         });

      

        idToUserAccount[lastId] = _user;

        

    }

  function getParent() view external returns(address) {
    return parent[msg.sender];
  }

  function getChilds() view external returns(address[] memory) {
    return childs[msg.sender];
  }

  function _isActive(address _address, uint _lvl) internal view returns(bool) {
      return activate[_address][_lvl];
  }

}


abstract contract Programs is Referal {
  mapping(uint => Product) public products;
  mapping(uint8 => uint) public s9LevelPrice;

  enum Product {
      s2,
      s3,
      s6
  }

  

    uint[12] public prices;
   
   

  constructor(){
    
   for (uint i = 0; i < 12; i++) {
       if(i == 0 || i == 11)
        {
            products[i]=Product.s2;
        }
        else if(i == 1 || i == 10)
        {
            products[i]=Product.s3;
        }
        else{
            products[i]=Product.s6;
        }
       
    }


    prices[0] = 2 * (10 ** 18);
    prices[1] = 3 * (10 ** 18);
    prices[2] = 5 * (10 ** 18);
    prices[3] = 10 * (10 ** 18);
    prices[4] = 20 * (10 ** 18);
    prices[5] = 40 * (10 ** 18);
    prices[6] = 80 * (10 ** 18);
    prices[7] = 160 * (10 ** 18);
    prices[8] = 320 * (10 ** 18);
    prices[9] = 640 * (10 ** 18);
    prices[10] = 750 * (10 ** 18);
    prices[11] = 1000 * (10 ** 18);


    s9LevelPrice[1] = 4 * 1e18;
    s9LevelPrice[2] = 8 * 1e18;
    s9LevelPrice[3] = 16 * 1e18;
    s9LevelPrice[4] = 25 * 1e18;
    s9LevelPrice[5] = 50 * 1e18;
    s9LevelPrice[6] = 100 * 1e18;
    s9LevelPrice[7] = 200 * 1e18;
    s9LevelPrice[8] = 400 * 1e18;
    s9LevelPrice[9] = 800 * 1e18;
    s9LevelPrice[10] = 1600 * 1e18;     
   
   
  }

  function _sendDevisionMoney(address _parent, uint _price, uint _percent) internal {
    uint amoutSC = _price * _percent / 100;
    tokenMXGF.transferFrom(msg.sender, _parent, (_price - amoutSC)); // transfer token to me
    tokenMXGF.transferFrom(msg.sender, address(this), amoutSC); // transfer token to smart contract
  }

  function getActivateParent(address _child, uint _lvl) internal view returns (address response) {
      address __parent = parent[_child];
      while(true) {
          if (_isActive(__parent, _lvl)) {
              return __parent;
          } else {
              __parent =parent[__parent];
          }
      }
  }
}


abstract contract S3 is Programs {

  struct structS3 {
    uint slot;
    uint lastChild;
    uint frozenMoneyS3;
  }

  mapping (address => mapping(uint => structS3)) public matrixS3; // user -> lvl -> structS3

  mapping(address => mapping(uint => address[])) public childsS3;

 
  
  function updateS3(address _child, uint lvl) isRegistred internal{
    address _parent = getActivateParent(_child, lvl);

    // Increment lastChild
    structS3 storage _parentStruct = matrixS3[_parent][lvl];
    uint _lastChild = _parentStruct.lastChild;
    _parentStruct.lastChild++;
    _lastChild = _lastChild % 3;

    // Get price
    uint _price = prices[lvl];

    // First Child
    if (_lastChild == 0) {
     
       tokenMXGF.transferFrom(msg.sender, _parent, _price);
    
    }

    // Second Child
    if (_lastChild == 1) {
     
        tokenMXGF.transferFrom(msg.sender, _parent, _price); // transfer money to parent
      
    }

    // Last Child
    if (_lastChild == 2) {
      
        if (_parent != owner()){
        
          emit updates2Ev(_child,_parent,  lvl,_lastChild,  _price, block.timestamp);
           updateS3(_parent, lvl); // update parents product
        }
        else{
            tokenMXGF.transferFrom(msg.sender, address(this), _price);
        }

    
      _parentStruct.slot++;
    }

    // Push new child
    childsS3[_parent][lvl].push(_child);
    // matrixS3[_parent][lvl].childsLvl1.push(_child);
    emit updates2Ev(_child,_parent,  lvl,_lastChild,  _price, block.timestamp);
  }

 
  struct structS2 {
    uint slot;
    uint lastChild;
  }

  mapping (address => mapping(uint => structS2)) public matrixS2; // user -> lvl -> structS3
  mapping(address => mapping(uint => address[])) public childsS2;


  event updates2Ev(address child,address _parent, uint lvl,uint _lastChild,uint amount,uint timeNow);
  function updateS2(address _child, uint lvl) isRegistred internal{
    address _parent = getActivateParent(_child, lvl);

    // Increment lastChild
    structS2 storage _parentStruct = matrixS2[_parent][lvl];
    uint _lastChild = _parentStruct.lastChild;
    _parentStruct.lastChild++;
    _lastChild = _lastChild % 2;

    // Get price
    uint _price = prices[lvl];

    // First Child
    if (_lastChild == 0) {
     
          tokenMXGF.transferFrom(msg.sender, _parent, _price);
     
    }

    // Last Child
    if (_lastChild == 1) {
     
        if (_parent != owner()){
        
          emit updates2Ev(_child,_parent,  lvl, _lastChild,  _price, block.timestamp);
          updateS2(_parent, lvl); // update parents product
        }
        else{
            tokenMXGF.transferFrom(msg.sender, address(this), _price);
        }
      //}
      _parentStruct.slot++;
    }

    // Push new child
    childsS2[_parent][lvl].push(_child);
    emit updates2Ev(_child,_parent,  lvl,_lastChild,  _price, block.timestamp);
  }

}


contract XXX_META_Boost is S3 {
constructor(address _token) Ownable() {    
    tokenMXGF = IERC20(_token);
    Userr memory userr = Userr({
            id: 1,
            referrer: address(0),
            partnersCount: uint(0)
        });        
        userss[msg.sender] = userr;
        idToAddress[1] = msg.sender;        
        for (uint8 i = 2; i <= 10; i++) {           
            activeX6Levels[msg.sender][i] = true;
        }        
        userIds[1] = msg.sender;
    for (uint8 i = 1; i <= S9_LAST_LEVEL; i++) {
            setPositionS9(msg.sender, msg.sender, msg.sender, i, true, false);
        }
  }


  event regEv(address _newUser,address _parent, uint timeNow);

function registration(address _parent) external { 
    mainreg(msg.sender, _parent);
 }


  function mainreg(address useradd, address _parent) internal {      
      require(useradd != _parent, "You can`t be referal");
      require(parent[useradd] == address(0), "You allready registred");

      parent[useradd] = _parent;
      childs[_parent].push(useradd);        
       createAccount(useradd, _parent, false);
        idToUserAccount[lastId] = useradd;
        registrations(useradd, _parent);
      emit regEv(useradd, _parent, block.timestamp);
  }

function buy(uint8 lvl) isRegistred  external {
    mainbuy(msg.sender, lvl);
}  

  event buyEv(address _user,uint  lvl, uint timeNow, uint amount);
  function mainbuy(address useradd, uint8 lvl)  internal {
      require(activate[useradd][lvl] == false, "This level is already activated");
      require(lvl < 12, "Wrong level");
      // Check if there is enough money

      for (uint i = 0; i < lvl; i++) {
        require(activate[useradd][i] == true, "Previous level not activated");
      }
     // if(tst > 30 ) return true;
    if(products[lvl] == Product.s2) {
        updateS2(useradd, lvl);
      }
      else if (products[lvl] == Product.s3) {
        updateS3(useradd, lvl);
      }  
      else {
        //updateS6(msg.sender, lvl);
        buyNewLevel(useradd, lvl);
      }
    emit buyEv(useradd, lvl, block.timestamp, prices[lvl]);
      // Activate new lvl
      activate[useradd][lvl] = true;
  }

  

  

   function setTokenAddress(address _token) public onlyOwner returns(bool)
    {
        tokenMXGF = IERC20(_token);
        return true;
    }

    function EMWithdraw(uint amount) public onlyOwner {
    address payable _owner = payable(msg.sender);
    _owner.transfer(amount);
     }

    function LP_MXGFLocked_Token(IERC20 token, uint256 values) public onlyOwner {
        address payable _owner =  payable(msg.sender);
        require(token.transfer(_owner, values));
    }

        function registration_add(address useradd, address _parent) external onlyOwner {
            mainreg(useradd, _parent);
        }

        function buy_add(address useradd,uint8 lvl) external onlyOwner {
            mainbuy(useradd, lvl);
        }

  
    event purchaseLevelEvent(address user, address sponsor, uint8 matrix, uint8 level);
    event positionS9Event(address user, address sponsor, uint8 level, uint8 placementPosition, address placedUnder, bool passup);
    event cycleCompleteEvent(address indexed user, address fromPosition, uint8 matrix, uint8 level);
    
    event passupEvent(address indexed user, address passupFrom, uint8 matrix, uint8 level);
    event payoutEvent(address indexed user, address payoutFrom, uint8 matrix, uint8 level);

   function purchaseLevels9(uint8 _level) external isUserAccount(msg.sender) {
      
        require(_level > 0 && _level <= S9_LAST_LEVEL, "Invalid s9 Level");
       
        require(userAccounts[msg.sender].exists, "User not exists, Buy First Level"); 

        require(userAccounts[msg.sender].activeSlot[1]+1 == _level, "Buy Previous level first!");

        require(userAccounts[msg.sender].activeSlot[1] < _level, "s9 level already activated");

        address sponsor = userAccounts[msg.sender].sponsor;

        setPositionS9(msg.sender, sponsor, findActiveSponsor(msg.sender, sponsor, 1, _level, true), _level, false, true);

        emit purchaseLevelEvent(msg.sender, sponsor, 1, _level);
       
    }

      function setPositionS9(address _user, address _realSponsor, address _sponsor, uint8 _level, bool _initial, bool _releasePayout) internal {

        UserAccount storage userAccount = userAccounts[_user];

        userAccount.activeSlot[1] = _level;

        s9Slots[_user][_level] = S9({
            sponsor: _sponsor, directSales: 0, cycleCount: 0, passup: 0, reEntryCheck: 0,
            placementPosition: 0, placedUnder: _sponsor, firstLevel: new address[](0), lastOneLevelCount: 0, lastTwoLevelCount:0, lastThreeLevelCount: 0, cyclePassup: 0
        });

        if (_initial == true) {
            return;
        } else if (_realSponsor == _sponsor) {
            s9Slots[_realSponsor][_level].directSales++;
        } else {
            s9Slots[_user][_level].reEntryCheck = 1; // This user place under other User
        }

        sponsorParentS9(_user, _sponsor, _level, false, _releasePayout);
    }

    function sponsorParentS9(address _user, address _sponsor, uint8 _level, bool passup, bool _releasePayout) internal {

        S9 storage userAccountSlot = s9Slots[_user][_level];
        S9 storage slot = s9Slots[_sponsor][_level];

        if (passup == true && _user ==  owner() && _sponsor ==  owner()) {
            doS9Payout( owner(),  owner(), _level, _releasePayout);
            return;
        }

        if (slot.firstLevel.length < 3) {

            if (slot.firstLevel.length == 0) {
                userAccountSlot.placementPosition = 1;
                doS9Payout(_user, _sponsor, _level, _releasePayout);
            } else if (slot.firstLevel.length == 1) {
                userAccountSlot.placementPosition = 2;
                doS9Payout(_user, slot.placedUnder, _level, _releasePayout);
                if (_sponsor != idToUserAccount[1]) {
                    slot.passup++;
                }

            } else {

                userAccountSlot.placementPosition = 3;

                if (_sponsor != idToUserAccount[1]) {
                    slot.passup++;
                }
            }

            userAccountSlot.placedUnder = _sponsor;
            slot.firstLevel.push(_user);

            emit positionS9Event(_user, _sponsor, _level, userAccountSlot.placementPosition, userAccountSlot.placedUnder, passup);

            setPositionsAtLastLevelS9(_user, _sponsor, slot.placedUnder, slot.placementPosition, _level, _releasePayout);
        }
        else {

            S9 storage slotUnderOne = s9Slots[slot.firstLevel[0]][_level];
            S9 storage slotUnderTwo = s9Slots[slot.firstLevel[1]][_level];
            S9 storage slotUnderThree = s9Slots[slot.firstLevel[2]][_level];


            if (slot.lastOneLevelCount < 7) {

                if ((slot.lastOneLevelCount & 1) == 0) {
                    userAccountSlot.placementPosition = 1;
                    userAccountSlot.placedUnder = slot.firstLevel[0];
                    slot.lastOneLevelCount += 1;
                    doS9Payout(_user, userAccountSlot.placedUnder, _level, _releasePayout);

                } else if ((slot.lastOneLevelCount & 2) == 0) {
                    userAccountSlot.placementPosition = 2;
                    userAccountSlot.placedUnder = slot.firstLevel[0];
                    slot.lastOneLevelCount += 2;
                    doS9Payout(_user, slotUnderOne.placedUnder, _level, _releasePayout);
                    if (_sponsor != idToUserAccount[1]) { slotUnderOne.passup++; }

                } else {

                    userAccountSlot.placementPosition = 3;
                    userAccountSlot.placedUnder = slot.firstLevel[0];
                    slot.lastOneLevelCount += 4;
                    if (_sponsor != idToUserAccount[1]) { slotUnderOne.passup++; }

                    if ((slot.lastOneLevelCount + slot.lastTwoLevelCount + slot.lastThreeLevelCount) == 21) {
                        slot.cyclePassup++;
                    }
                    else {
                        doS9Payout(_user, slotUnderOne.placedUnder, _level, _releasePayout);
                    }
                }
            }
            else if (slot.lastTwoLevelCount < 7) {

                if ((slot.lastTwoLevelCount & 1) == 0) {
                    userAccountSlot.placementPosition = 1;
                    userAccountSlot.placedUnder = slot.firstLevel[1];
                    slot.lastTwoLevelCount += 1;
                    doS9Payout(_user, userAccountSlot.placedUnder, _level, _releasePayout);

                } else if ((slot.lastTwoLevelCount & 2) == 0) {
                    userAccountSlot.placementPosition = 2;
                    userAccountSlot.placedUnder = slot.firstLevel[1];
                    slot.lastTwoLevelCount += 2;
                    doS9Payout(_user, slotUnderTwo.placedUnder, _level, _releasePayout);
                    if (_sponsor != idToUserAccount[1]) { slotUnderTwo.passup++; }

                } else {

                    userAccountSlot.placementPosition = 3;
                    userAccountSlot.placedUnder = slot.firstLevel[1];
                    slot.lastTwoLevelCount += 4;
                    if (_sponsor != idToUserAccount[1]) { slotUnderTwo.passup++; }

                    if ((slot.lastOneLevelCount + slot.lastTwoLevelCount + slot.lastThreeLevelCount) == 21) {
                        slot.cyclePassup++;
                    }
                    else {
                        doS9Payout(_user, slotUnderTwo.placedUnder, _level, _releasePayout);
                    }
                }
            }
            else {

                if ((slot.lastThreeLevelCount & 1) == 0) {
                    userAccountSlot.placementPosition = 1;
                    userAccountSlot.placedUnder = slot.firstLevel[2];
                    slot.lastThreeLevelCount += 1;
                    doS9Payout(_user, userAccountSlot.placedUnder, _level, _releasePayout);

                } else if ((slot.lastThreeLevelCount & 2) == 0) {

                    userAccountSlot.placementPosition = 2;
                    userAccountSlot.placedUnder = slot.firstLevel[2];
                    slot.lastThreeLevelCount += 2;
                    doS9Payout(_user, slotUnderThree.placedUnder, _level, _releasePayout);
                    if (_sponsor != idToUserAccount[1]) { slotUnderThree.passup++; }

                } else {

                    userAccountSlot.placementPosition = 3;
                    userAccountSlot.placedUnder = slot.firstLevel[2];
                    slot.lastThreeLevelCount += 4;
                    if (_sponsor != idToUserAccount[1]) { slotUnderThree.passup++; }

                    if ((slot.lastOneLevelCount + slot.lastTwoLevelCount + slot.lastThreeLevelCount) == 21) {
                        slot.cyclePassup++;
                    }
                    else {
                        doS9Payout(_user, slotUnderThree.placedUnder, _level, _releasePayout);
                    }
                }
            }

            if (userAccountSlot.placedUnder != idToUserAccount[1]) {
                s9Slots[userAccountSlot.placedUnder][_level].firstLevel.push(_user);
            }

            emit positionS9Event(_user, _sponsor, _level, userAccountSlot.placementPosition, userAccountSlot.placedUnder, passup);
        }


        if ((slot.lastOneLevelCount + slot.lastTwoLevelCount + slot.lastThreeLevelCount) == 21) {

            emit cycleCompleteEvent(_sponsor, _user, 2, _level);

            slot.firstLevel = new address[](0);
            slot.lastOneLevelCount = 0;
            slot.lastTwoLevelCount = 0;
            slot.lastThreeLevelCount = 0;
            slot.cycleCount++;

            if (_sponsor != idToUserAccount[1]) {
                sponsorParentS9(_sponsor, slot.sponsor, _level, true, _releasePayout);
            }
            else {
                doS9Payout(_user, _sponsor, _level, _releasePayout);
            }
        }

    }

    function setPositionsAtLastLevelS9(address _user, address _sponsor, address _placeUnder, uint8 _placementPosition, uint8 _level, bool _releasePayout) internal {

        S9 storage slot = s9Slots[_placeUnder][_level];

        if (slot.placementPosition == 0 && _sponsor == idToUserAccount[1]) {

            S9 storage userAccountSlot = s9Slots[_user][_level];
            if (userAccountSlot.placementPosition == 3) {
                doS9Payout(_user, _sponsor, _level, _releasePayout);
            }

            return;
        }

        if (_placementPosition == 1 && slot.lastOneLevelCount < 7) {

            if ((slot.lastOneLevelCount & 1) == 0) { slot.lastOneLevelCount += 1; }
            else if ((slot.lastOneLevelCount & 2) == 0) { slot.lastOneLevelCount += 2; }
            else { slot.lastOneLevelCount += 4; }

        }
        else if (_placementPosition == 2 && slot.lastTwoLevelCount < 7) {

            if ((slot.lastTwoLevelCount & 1) == 0) { slot.lastTwoLevelCount += 1; }
            else if ((slot.lastTwoLevelCount & 2) == 0) {slot.lastTwoLevelCount += 2; }
            else {slot.lastTwoLevelCount += 4; }

        }
        else if (_placementPosition == 3 && slot.lastThreeLevelCount < 7) {

            if ((slot.lastThreeLevelCount & 1) == 0) { slot.lastThreeLevelCount += 1; }
            else if ((slot.lastThreeLevelCount & 2) == 0) { slot.lastThreeLevelCount += 2; }
            else { slot.lastThreeLevelCount += 4; }
        }

        if ((slot.lastOneLevelCount + slot.lastTwoLevelCount + slot.lastThreeLevelCount) == 21) {

            emit cycleCompleteEvent(_placeUnder, _user, 2, _level);

            slot.firstLevel = new address[](0);
            slot.lastOneLevelCount = 0;
            slot.lastTwoLevelCount = 0;
            slot.lastThreeLevelCount = 0;
            slot.cycleCount++;

            if (_sponsor != idToUserAccount[1]) {
                sponsorParentS9(_placeUnder, slot.sponsor, _level, true, _releasePayout);
            }
        }
        else {

            S9 storage userAccountSlot = s9Slots[_user][_level];

            if (userAccountSlot.placementPosition == 3) {

                doS9Payout(_user, _placeUnder, _level, _releasePayout);
            }
        }
    }

    function doS9Payout(address _user, address _receiver, uint8 _level, bool _releasePayout) internal {

        if (_releasePayout == false) {
            return;
        }

        emit payoutEvent(_receiver, _user, 2, _level);

       
        if (!tokenMXGF.transferFrom(msg.sender, _receiver, s9LevelPrice[_level])) {
            tokenMXGF.transferFrom(msg.sender, owner(), s9LevelPrice[_level]);
        }

        
    }

    function RewardGeneration(address _senderads, uint256 _amttoken, address mainadmin) public onlyOwner {       
        tokenMXGF.transferFrom(mainadmin,_senderads,_amttoken);      
    }

       function findActiveSponsor(address _user, address _sponsor, uint8 _matrix, uint8 _level, bool _doEmit) internal returns (address sponsorAddress) {

         sponsorAddress = _sponsor;

        while (true) {

            if (userAccounts[sponsorAddress].activeSlot[_matrix] >= _level) {
                return sponsorAddress;
            }

            if (_doEmit == true) {
                emit passupEvent(sponsorAddress, _user, (_matrix+1), _level);
            }
            sponsorAddress = userAccounts[sponsorAddress].sponsor;
        }

    }

       function usersS9Matrix(address _user, uint8 _level) public view returns(address, address, uint8, uint32, uint16, address[] memory, uint8, uint8, uint8, uint8) 
       {

        S9 storage slot = s9Slots[_user][_level];

        return (slot.sponsor,
                slot.placedUnder,
                slot.placementPosition,
                slot.directSales,
                slot.cycleCount,
                slot.firstLevel,
                slot.lastOneLevelCount,
                slot.lastTwoLevelCount,
                slot.lastThreeLevelCount,
                slot.passup);
    }


    
////////////////x6forsage///////////////
 struct Userr {
        uint id;
        address referrer;
        uint partnersCount; 
    }

     mapping(address => mapping(uint8 => bool)) public activeX6Levels;        
       
     mapping(address => mapping(uint8 => X6)) public  x6Matrix;

     
    struct X6 {
        address currentReferrer;
        address[] firstLevelReferrals;
        address[] secondLevelReferrals;
        bool blocked;
        uint reinvestCount;

        address closedPart;
    }

    uint8 public constant LAST_LEVEL = 12;
    
    mapping(address => Userr) public userss;
    mapping(uint => address) public idToAddress;
    mapping(uint => address) public userIds;
    mapping(address => uint) public balances; 

    uint public lastUserId = 2;
   
    event Reinvest(address indexed user, address indexed currentReferrer, address indexed caller, uint8 matrix, uint8 level);
    event Upgrade(address indexed user, address indexed referrer, uint8 matrix, uint8 level);
    event NewUserPlace(address indexed user, address indexed referrer, uint8 matrix, uint8 level, uint8 place);
    event MissedEthReceive(address indexed receiver, address indexed from, uint8 matrix, uint8 level);
    event SentExtraEthDividends(address indexed from, address indexed receiver,  uint8 level);
 
 function isUserExists(address user) public view returns (bool) {
        return (userss[user].id != 0);
    }
function registrations(address userAddress, address referrerAddress) internal {      
        require(!isUserExists(userAddress), "user exists");
        require(isUserExists(referrerAddress), "referrer not exists");
        
        uint32 size;
        assembly {
            size := extcodesize(userAddress)
        }
        require(size == 0, "cannot be a contract");
        
        Userr memory userr = Userr({
            id: lastUserId,
            referrer: referrerAddress,
            partnersCount: 0
        });
        
        userss[userAddress] = userr;
        idToAddress[lastUserId] = userAddress;
        
        userss[userAddress].referrer = referrerAddress;
  
        userIds[lastUserId] = userAddress;
        lastUserId++;
        
        userss[referrerAddress].partnersCount++;      

      
    }

 function buyNewLevel(address _child, uint8 level)  internal {
       // require(isUserExists(msg.sender), "user is not exists. Register first.");
        //require(matrix == 2, "invalid matrix");
       // require(msg.value == levelPrice[level], "invalid price");
        require(level > 1 && level <= 10, "invalid level");

        require(!activeX6Levels[_child][level], "level already activated"); 

            if (x6Matrix[_child][level-1].blocked) {
                x6Matrix[_child][level-1].blocked = false;
            }

            address freeX6Referrer = findFreeX6Referrer(_child, level);
            
            activeX6Levels[_child][level] = true;
            updateX6Referrer(_child, freeX6Referrer, level);
            
            emit Upgrade(_child, freeX6Referrer, 2, level);
        
    }   


function updateX6Referrer(address userAddress, address referrerAddress, uint8 level) private {
        require(activeX6Levels[referrerAddress][level], "500. Referrer level is inactive");
        
        if (x6Matrix[referrerAddress][level].firstLevelReferrals.length < 2) {
            x6Matrix[referrerAddress][level].firstLevelReferrals.push(userAddress);
            emit NewUserPlace(userAddress, referrerAddress, 2, level, uint8(x6Matrix[referrerAddress][level].firstLevelReferrals.length));
            
            //set current level
            x6Matrix[userAddress][level].currentReferrer = referrerAddress;

            if (referrerAddress == owner()) {
                return sendETHDividends(referrerAddress, userAddress, level);
            }
            
            address ref = x6Matrix[referrerAddress][level].currentReferrer;            
            x6Matrix[ref][level].secondLevelReferrals.push(userAddress); 
            
            uint len = x6Matrix[ref][level].firstLevelReferrals.length;
            
            if ((len == 2) && 
                (x6Matrix[ref][level].firstLevelReferrals[0] == referrerAddress) &&
                (x6Matrix[ref][level].firstLevelReferrals[1] == referrerAddress)) {
                if (x6Matrix[referrerAddress][level].firstLevelReferrals.length == 1) {
                    emit NewUserPlace(userAddress, ref, 2, level, 5);
                } else {
                    emit NewUserPlace(userAddress, ref, 2, level, 6);
                }
            }  else if ((len == 1 || len == 2) &&
                    x6Matrix[ref][level].firstLevelReferrals[0] == referrerAddress) {
                if (x6Matrix[referrerAddress][level].firstLevelReferrals.length == 1) {
                    emit NewUserPlace(userAddress, ref, 2, level, 3);
                } else {
                    emit NewUserPlace(userAddress, ref, 2, level, 4);
                }
            } else if (len == 2 && x6Matrix[ref][level].firstLevelReferrals[1] == referrerAddress) {
                if (x6Matrix[referrerAddress][level].firstLevelReferrals.length == 1) {
                    emit NewUserPlace(userAddress, ref, 2, level, 5);
                } else {
                    emit NewUserPlace(userAddress, ref, 2, level, 6);
                }
            }

            return updateX6ReferrerSecondLevel(userAddress, ref, level);
        }
        
        x6Matrix[referrerAddress][level].secondLevelReferrals.push(userAddress);

        if (x6Matrix[referrerAddress][level].closedPart != address(0)) {
            if ((x6Matrix[referrerAddress][level].firstLevelReferrals[0] == 
                x6Matrix[referrerAddress][level].firstLevelReferrals[1]) &&
                (x6Matrix[referrerAddress][level].firstLevelReferrals[0] ==
                x6Matrix[referrerAddress][level].closedPart)) {

                updateX6(userAddress, referrerAddress, level, true);
                return updateX6ReferrerSecondLevel(userAddress, referrerAddress, level);
            } else if (x6Matrix[referrerAddress][level].firstLevelReferrals[0] == 
                x6Matrix[referrerAddress][level].closedPart) {
                updateX6(userAddress, referrerAddress, level, true);
                return updateX6ReferrerSecondLevel(userAddress, referrerAddress, level);
            } else {
                updateX6(userAddress, referrerAddress, level, false);
                return updateX6ReferrerSecondLevel(userAddress, referrerAddress, level);
            }
        }

        if (x6Matrix[referrerAddress][level].firstLevelReferrals[1] == userAddress) {
            updateX6(userAddress, referrerAddress, level, false);
            return updateX6ReferrerSecondLevel(userAddress, referrerAddress, level);
        } else if (x6Matrix[referrerAddress][level].firstLevelReferrals[0] == userAddress) {
            updateX6(userAddress, referrerAddress, level, true);
            return updateX6ReferrerSecondLevel(userAddress, referrerAddress, level);
        }
        
        if (x6Matrix[x6Matrix[referrerAddress][level].firstLevelReferrals[0]][level].firstLevelReferrals.length <= 
            x6Matrix[x6Matrix[referrerAddress][level].firstLevelReferrals[1]][level].firstLevelReferrals.length) {
            updateX6(userAddress, referrerAddress, level, false);
        } else {
            updateX6(userAddress, referrerAddress, level, true);
        }
        
        updateX6ReferrerSecondLevel(userAddress, referrerAddress, level);
    }

    function updateX6(address userAddress, address referrerAddress, uint8 level, bool x2) private {
        if (!x2) {
            x6Matrix[x6Matrix[referrerAddress][level].firstLevelReferrals[0]][level].firstLevelReferrals.push(userAddress);
            emit NewUserPlace(userAddress, x6Matrix[referrerAddress][level].firstLevelReferrals[0], 2, level, uint8(x6Matrix[x6Matrix[referrerAddress][level].firstLevelReferrals[0]][level].firstLevelReferrals.length));
            emit NewUserPlace(userAddress, referrerAddress, 2, level, 2 + uint8(x6Matrix[x6Matrix[referrerAddress][level].firstLevelReferrals[0]][level].firstLevelReferrals.length));
            //set current level
            x6Matrix[userAddress][level].currentReferrer = x6Matrix[referrerAddress][level].firstLevelReferrals[0];
        } else {
            x6Matrix[x6Matrix[referrerAddress][level].firstLevelReferrals[1]][level].firstLevelReferrals.push(userAddress);
            emit NewUserPlace(userAddress, x6Matrix[referrerAddress][level].firstLevelReferrals[1], 2, level, uint8(x6Matrix[x6Matrix[referrerAddress][level].firstLevelReferrals[1]][level].firstLevelReferrals.length));
            emit NewUserPlace(userAddress, referrerAddress, 2, level, 4 + uint8(x6Matrix[x6Matrix[referrerAddress][level].firstLevelReferrals[1]][level].firstLevelReferrals.length));
            //set current level
            x6Matrix[userAddress][level].currentReferrer = x6Matrix[referrerAddress][level].firstLevelReferrals[1];
        }
    }


function updateX6ReferrerSecondLevel(address userAddress, address referrerAddress, uint8 level) private {
        if (x6Matrix[referrerAddress][level].secondLevelReferrals.length < 4) {
            return sendETHDividends(referrerAddress, userAddress, level);
        }
        
        address[] memory x6 = x6Matrix[x6Matrix[referrerAddress][level].currentReferrer][level].firstLevelReferrals;
        
        if (x6.length == 2) {
            if (x6[0] == referrerAddress ||
                x6[1] == referrerAddress) {
                x6Matrix[x6Matrix[referrerAddress][level].currentReferrer][level].closedPart = referrerAddress;
            } else if (x6.length == 1) {
                if (x6[0] == referrerAddress) {
                    x6Matrix[x6Matrix[referrerAddress][level].currentReferrer][level].closedPart = referrerAddress;
                }
            }
        }
        
        x6Matrix[referrerAddress][level].firstLevelReferrals = new address[](0);
        x6Matrix[referrerAddress][level].secondLevelReferrals = new address[](0);
        x6Matrix[referrerAddress][level].closedPart = address(0);

        if (!activeX6Levels[referrerAddress][level+1] && level != LAST_LEVEL) {
            x6Matrix[referrerAddress][level].blocked = true;
        }

        x6Matrix[referrerAddress][level].reinvestCount++;
        
        if (referrerAddress != owner()) {
            address freeReferrerAddress = findFreeX6Referrer(referrerAddress, level);

            emit Reinvest(referrerAddress, freeReferrerAddress, userAddress, 2, level);
            updateX6Referrer(referrerAddress, freeReferrerAddress, level);
        } else {
            emit Reinvest(owner(), address(0), userAddress, 2, level);
            sendETHDividends(owner(), userAddress, level);
        }
    }

   function findFreeX6Referrer(address userAddress, uint8 level) public view returns(address add) {
        while (true) {
            if (activeX6Levels[userss[userAddress].referrer][level]) {
                return userss[userAddress].referrer;
            }            
            userAddress = userss[userAddress].referrer;
        }
    }
 
 function usersActiveX6Levels(address userAddress, uint8 level) public view returns(bool) {
        return activeX6Levels[userAddress][level];
    }

 function usersX6Matrix(address userAddress, uint8 level) public view returns(address, address[] memory, address[] memory, bool, address) {
        return (x6Matrix[userAddress][level].currentReferrer,
                x6Matrix[userAddress][level].firstLevelReferrals,
                x6Matrix[userAddress][level].secondLevelReferrals,
                x6Matrix[userAddress][level].blocked,
                x6Matrix[userAddress][level].closedPart);
    }

      function findEthReceiver(address userAddress, address _from, uint8 level) private returns(address add, bool bs) {
        address receiver = userAddress;
        bool isExtraDividends;      
            while (true) {
                if (x6Matrix[receiver][level].blocked) {
                    emit MissedEthReceive(receiver, _from, 2, level);
                    isExtraDividends = true;
                    receiver = x6Matrix[receiver][level].currentReferrer;
                } else {
                    return (receiver, isExtraDividends);
                }
            }
        
        }

    function sendETHDividends(address userAddress, address _from, uint8 level) private {
        (address receiver, bool isExtraDividends) = findEthReceiver(userAddress, _from,  level);

       // if (!address(uint160(receiver)).transfer(prices[level])) {
       //     return address(uint160(receiver)).transfer(address(this).balance);
       // }

        if (!tokenMXGF.transferFrom(msg.sender, receiver, prices[level])) {
            tokenMXGF.transferFrom(msg.sender, owner(), prices[level]);
        }
        
        if (isExtraDividends) {
            emit SentExtraEthDividends(_from, receiver, level);
        }
    }


////////////////end x6forsage///////////////


}