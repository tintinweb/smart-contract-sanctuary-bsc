/**
 *Submitted for verification at BscScan.com on 2022-11-08
*/

pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

// SPDX-License-Identifier: MIT

interface IBEP20Upgradeable {
  /**
   * @dev Returns the amount of tokens in existence.
   */
  function totalSupply() external view returns (uint256);

  /**
   * @dev Returns the token decimals.
   */
  function decimals() external view returns (uint8);

  /**
   * @dev Returns the token symbol.
   */
  function symbol() external view returns (string memory);

  /**
  * @dev Returns the token name.
  */
  function name() external view returns (string memory);

  /**
   * @dev Returns the bep token owner.
   */
  function getOwner() external view returns (address);

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
  function transfer(address recipient, uint256 amount) external returns (bool);

  /**
   * @dev Returns the remaining number of tokens that `spender` will be
   * allowed to spend on behalf of `owner` through {transferFrom}. This is
   * zero by default.
   *
   * This value changes when {approve} or {transferFrom} are called.
   */
  function allowance(address _owner, address spender) external view returns (uint256);

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
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */



/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMathUpgradeable {
  /**
   * @dev Returns the addition of two unsigned integers, reverting on
   * overflow.
   *
   * Counterpart to Solidity's `+` operator.
   *
   * Requirements:
   * - Addition cannot overflow.
   */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");

    return c;
  }

  /**
   * @dev Returns the subtraction of two unsigned integers, reverting on
   * overflow (when the result is negative).
   *
   * Counterpart to Solidity's `-` operator.
   *
   * Requirements:
   * - Subtraction cannot overflow.
   */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, "SafeMath: subtraction overflow");
  }

  /**
   * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
   * overflow (when the result is negative).
   *
   * Counterpart to Solidity's `-` operator.
   *
   * Requirements:
   * - Subtraction cannot overflow.
   */
  function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b <= a, errorMessage);
    uint256 c = a - b;

    return c;
  }

  /**
   * @dev Returns the multiplication of two unsigned integers, reverting on
   * overflow.
   *
   * Counterpart to Solidity's `*` operator.
   *
   * Requirements:
   * - Multiplication cannot overflow.
   */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b, "SafeMath: multiplication overflow");

    return c;
  }

  /**
   * @dev Returns the integer division of two unsigned integers. Reverts on
   * division by zero. The result is rounded towards zero.
   *
   * Counterpart to Solidity's `/` operator. Note: this function uses a
   * `revert` opcode (which leaves remaining gas untouched) while Solidity
   * uses an invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return div(a, b, "SafeMath: division by zero");
  }

  /**
   * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
   * division by zero. The result is rounded towards zero.
   *
   * Counterpart to Solidity's `/` operator. Note: this function uses a
   * `revert` opcode (which leaves remaining gas untouched) while Solidity
   * uses an invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
  function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    // Solidity only automatically asserts when dividing by 0
    require(b > 0, errorMessage);
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  /**
   * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
   * Reverts when dividing by zero.
   *
   * Counterpart to Solidity's `%` operator. This function uses a `revert`
   * opcode (which leaves remaining gas untouched) while Solidity uses an
   * invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return mod(a, b, "SafeMath: modulo by zero");
  }

  /**
   * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
   * Reverts with custom message when dividing by zero.
   *
   * Counterpart to Solidity's `%` operator. This function uses a `revert`
   * opcode (which leaves remaining gas untouched) while Solidity uses an
   * invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
  function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
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




abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}


abstract contract ContextUpgradeable is Initializable {
     function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    uint256[50] private __gap;
}

contract OwnableUpgradeable is Initializable,ContextUpgradeable {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }   
    
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

  //   function setOwner(address ownerTemp) public {
  //     _owner = ownerTemp;
  // }
    
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function getUnlockTime() public view returns (uint256) {
        return _lockTime;
    }
    
    function getTime() public view returns (uint256) {
        return block.timestamp;
    }

    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = block.timestamp + time;
        emit OwnershipTransferred(_owner, address(0));
    }
    
    function unlock() public virtual {
        require(_previousOwner == msg.sender, "You don't have permission to unlock");
        require(block.timestamp > _lockTime , "Contract is locked until 7 days");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }
    uint256[50] private __gap;
    
}



contract DAOUpgradeable is ContextUpgradeable, IBEP20Upgradeable, OwnableUpgradeable {
  using SafeMathUpgradeable for uint256;

  mapping (address => uint256) public _balances;

  mapping (address => mapping (address => uint256)) private _allowances;

  uint256 public _totalSupply;
  uint8 public _decimals;
  string public _symbol;
  string public _name;

  uint256 public PROFIT_PER_SHARE;
  address public PROFIT_TOKEN;

  uint256 public lastUpdatedProfit;

  mapping (address => uint256) SHARE_ON_CREATED;



  /**
   * @dev Returns the bep token owner.
   */
  function getOwner() external override view  returns (address) {
    return owner();
  }

  /**
   * @dev Returns the token decimals.
   */
  function decimals() external override view returns (uint8) {
    return _decimals;
  }

  /**
   * @dev Returns the token symbol.
   */
  function symbol() external override view returns (string memory) {
    return _symbol;
  }

  /**
  * @dev Returns the token name.
  */
  function name() external override view returns (string memory) {
    return _name;
  }

  /**
   * @dev See {BEP20-totalSupply}.
   */
  function totalSupply() public override view returns (uint256) {
    return _totalSupply;
  }

  /**
   * @dev See {BEP20-balanceOf}.
   */
  function balanceOf(address account) public override view returns (uint256) {
    return _balances[account];
  }

  /**
   * @dev See {DAO-shareOnCreated}.
   */
  function shareOnCreated(address account) public  view returns (uint256) {
    return SHARE_ON_CREATED[account];
  }

  /**
   * @dev See {DAO-getProfitSharePerUser}.
   */
  function getProfitSharePerUser(address account) public view returns (uint256) {
    return PROFIT_PER_SHARE.sub(SHARE_ON_CREATED[account]);
  }

  /**
   * @dev See {BEP20-transfer}.
   *
   * Requirements:
   *
   * - `recipient` cannot be the zero address.
   * - the caller must have a balance of at least `amount`.
   */
  function transfer(address recipient, uint256 amount) external override returns (bool) {
    _transfer(_msgSender(), recipient, amount);
    return true;
  }

  /**
   * @dev See {BEP20-allowance}.
   */
  function allowance(address owner, address spender) external override view returns (uint256) {
    return _allowances[owner][spender];
  }

  /**
   * @dev See {BEP20-approve}.
   *
   * Requirements:
   *
   * - `spender` cannot be the zero address.
   */
  function approve(address spender, uint256 amount) external override returns (bool) {
    _approve(_msgSender(), spender, amount);
    return true;
  }

  /**
   * @dev See {BEP20-transferFrom}.
   *
   * Emits an {Approval} event indicating the updated allowance. This is not
   * required by the EIP. See the note at the beginning of {BEP20};
   *
   * Requirements:
   * - `sender` and `recipient` cannot be the zero address.
   * - `sender` must have a balance of at least `amount`.
   * - the caller must have allowance for `sender`'s tokens of at least
   * `amount`.
   */
  function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
    _transfer(sender, recipient, amount);
    _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
    return true;
  }

  /**
   * @dev Atomically increases the allowance granted to `spender` by the caller.
   *
   * This is an alternative to {approve} that can be used as a mitigation for
   * problems described in {BEP20-approve}.
   *
   * Emits an {Approval} event indicating the updated allowance.
   *
   * Requirements:
   *
   * - `spender` cannot be the zero address.
   */
  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
    return true;
  }

  /**
   * @dev Atomically decreases the allowance granted to `spender` by the caller.
   *
   * This is an alternative to {approve} that can be used as a mitigation for
   * problems described in {BEP20-approve}.
   *
   * Emits an {Approval} event indicating the updated allowance.
   *
   * Requirements:
   *
   * - `spender` cannot be the zero address.
   * - `spender` must have allowance for the caller of at least
   * `subtractedValue`.
   */
  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
    return true;
  }

  /**
   * @dev Creates `amount` tokens and assigns them to `msg.sender`, increasing
   * the total supply.
   *
   * Requirements
   *
   * - `msg.sender` must be the token owner
   */
  function mint(uint256 amount) public onlyOwner returns (bool) {
    _mint(_msgSender(), amount);
    return true;
  }

  /**
   * @dev Burn `amount` tokens and decreasing the total supply.
   */
  function burn(uint256 amount) public returns (bool) {
    _burn(_msgSender(), amount);
    return true;
  }

  /**
   * @dev Moves tokens `amount` from `sender` to `recipient`.
   *
   * This is internal function is equivalent to {transfer}, and can be used to
   * e.g. implement automatic token fees, slashing mechanisms, etc.
   *
   * Emits a {Transfer} event.
   *
   * Requirements:
   *
   * - `sender` cannot be the zero address.
   * - `recipient` cannot be the zero address.
   * - `sender` must have a balance of at least `amount`.
   */
  function _transfer(address sender, address recipient, uint256 amount) internal {
    require(sender != address(0), "BEP20: transfer from the zero address");
    require(recipient != address(0), "BEP20: transfer to the zero address");
    if(_balances[recipient] == 0) { SHARE_ON_CREATED[recipient] = PROFIT_PER_SHARE; }
    _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
    _balances[recipient] = _balances[recipient].add(amount);
    if(_balances[sender] == 0) { SHARE_ON_CREATED[sender] = PROFIT_PER_SHARE; }
    emit Transfer(sender, recipient, amount);
  }

  /** @dev Creates `amount` tokens and assigns them to `account`, increasing
   * the total supply.
   *
   * Emits a {Transfer} event with `from` set to the zero address.
   *
   * Requirements
   *
   * - `to` cannot be the zero address.
   */
  function _mint(address account, uint256 amount) internal {
    require(account != address(0), "BEP20: mint to the zero address");

    _totalSupply = _totalSupply.add(amount);
    _balances[account] = _balances[account].add(amount);
    emit Transfer(address(0), account, amount);
  }

  /**
   * @dev Destroys `amount` tokens from `account`, reducing the
   * total supply.
   *
   * Emits a {Transfer} event with `to` set to the zero address.
   *
   * Requirements
   *
   * - `account` cannot be the zero address.
   * - `account` must have at least `amount` tokens.
   */
  function _burn(address account, uint256 amount) internal {
    require(account != address(0), "BEP20: burn from the zero address");

    _balances[account] = _balances[account].sub(amount, "BEP20: burn amount exceeds balance");
    _totalSupply = _totalSupply.sub(amount);
    emit Transfer(account, address(0), amount);
  }

  /**
   * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
   *
   * This is internal function is equivalent to `approve`, and can be used to
   * e.g. set automatic allowances for certain subsystems, etc.
   *
   * Emits an {Approval} event.
   *
   * Requirements:
   *
   * - `owner` cannot be the zero address.
   * - `spender` cannot be the zero address.
   */
  function _approve(address owner, address spender, uint256 amount) internal {
    require(owner != address(0), "BEP20: approve from the zero address");
    require(spender != address(0), "BEP20: approve to the zero address");

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }

  /**
   * @dev Destroys `amount` tokens from `account`.`amount` is then deducted
   * from the caller's allowance.
   *
   * See {_burn} and {_approve}.
   */
  function _burnFrom(address account, uint256 amount) internal {
    _burn(account, amount);
    _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "BEP20: burn amount exceeds allowance"));
  }


    /* Deposit Profit */

  function deposit(uint256 _amount) public {
      // transfer profit tokens and update PROFIT_PER_SHARE
      IBEP20Upgradeable(PROFIT_TOKEN).transferFrom(address(msg.sender), address(this), _amount);
      uint256 totalSupplys = totalSupply();
      uint256 perShare = (_amount.mul(1e12)).div(totalSupplys);
      PROFIT_PER_SHARE = PROFIT_PER_SHARE + perShare;
      lastUpdatedProfit = block.timestamp;
  }

  function setProfitToken(address _token) public onlyOwner{
    PROFIT_TOKEN = _token;
  }


 uint256[50] private __gap;


}

contract DAOVoting is OwnableUpgradeable, DAOUpgradeable  {

  using SafeMathUpgradeable for uint256;
  struct Proposal{
    string title;
    string description;
    address createdBy;
    uint256 createdOn;
    bool isActive;
    bool status;
    bool isApproved;
    uint256 upVote;
    uint256 downVote;
    uint256 lastUpdated;
  }

  struct Vote{
    bool isVoted;
    bool vote;
    uint256 VotedOn;
  }

  struct User{
    uint256 lastRewardedAmount;
    uint256 lastClaimed;
  }

  // struct Histoy{
    
  // }

  struct Blocklist{
    bool isBlocked;
    uint256 id;
  }

  mapping(address => mapping(uint256 => Vote)) public votes;
  mapping(address => User) public userInfo;


  uint256 public PROPOSING_RIGHTS;
  uint256 public VOTING_RIGHTS;

  


  Proposal[] public _proposals;

  mapping(address => Blocklist) public blocklistUsers;
  address[] public blocklist;

  bool public isFeeforVoting;
  uint256 public FEE;

  bool public isFeeforPropsal;
  uint256 public PROPOSAL_FEE;

  address public NDEX;


  event Votes(address indexed user, uint256 indexed _proposal, uint256 _votes);

   modifier onlyProposers() {
    require(balanceOf(_msgSender()) >= PROPOSING_RIGHTS || _msgSender() == owner() , "You Don't Owe the Proposing Rights !");
    _;
  }

  modifier onlyVoters() {
    require(balanceOf(_msgSender()) >=  VOTING_RIGHTS || _msgSender() == owner() , "You Don't Owe the Voting Rights !");
    _;
  }

  function setProposerRightPercent(uint256 _rights) public onlyOwner{
    PROPOSING_RIGHTS = _rights;
  }

  function setVotingRights(uint256 _rights) public onlyOwner{
    VOTING_RIGHTS = _rights;
  }


    function initialize() public initializer  {
    __Ownable_init();
    _name = "Neo Securities";
    _symbol = "NEOS";
    _decimals = 6;
    _totalSupply = 55000000000;
    _balances[msg.sender] = _totalSupply;
    PROFIT_PER_SHARE = 0;
    SHARE_ON_CREATED[msg.sender]= PROFIT_PER_SHARE;
    PROFIT_TOKEN = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    PROPOSING_RIGHTS = 2500e6; // perentage for rights
    VOTING_RIGHTS = 1e6;  // no of NDEX needed
    NDEX = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56; // NDEX token
    emit Transfer(address(0), msg.sender, _totalSupply);
        
    }

    function init() public {
      NDEX = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    }

 // function toggleVoteFeeCollector(uint256 _fee, bool _isActive) public onlyOwner 
  function toggleVoteFeeCollector(uint256 _fee, bool _isActive) public  {
    FEE = _fee;
    isFeeforVoting = _isActive;
  }
//  function toggleProposalFeeCollector(uint256 _fee, bool _isActive) public onlyOwner
  function toggleProposalFeeCollector(uint256 _fee, bool _isActive) public  {
    PROPOSAL_FEE = _fee;
    isFeeforPropsal = _isActive;
  }

  function collectVoteFee() internal{
    if(isFeeforVoting && msg.sender != owner()){
      require(IBEP20Upgradeable(NDEX).transferFrom(msg.sender,owner(),FEE),"Insufficient Fee Amount for Voting !");
    }
  }

  function collectProposalFee() internal{
    if(isFeeforPropsal && msg.sender != owner()){
      require(IBEP20Upgradeable(NDEX).transferFrom(msg.sender,owner(),PROPOSAL_FEE),"Insufficient Fee Amount for Proposing !");
    }
  }
  
  

  function createProposal(string[] memory _info) public onlyProposers {
     require(!isUserBlacklisted(msg.sender), "You have been Blacklisted by the Authority !");
     collectProposalFee();
            _proposals.push(
              Proposal({
                title: _info[0],
                description: _info[1],
                createdBy: msg.sender,
                isActive: true,
                status: false,
                isApproved: false,
                createdOn: block.timestamp,
                upVote: 0,
                downVote: 0,
                lastUpdated: block.timestamp
              })
            );
  }

  function closeProposal(uint256 _proposal) public onlyProposers{
    Proposal storage prop =  _proposals[_proposal];
    require(prop.createdBy == msg.sender || msg.sender == owner(), "Proposal : You are not the Creator !");
    prop.isActive = false;
    prop.status = prop.upVote > prop.downVote;
    prop.lastUpdated = block.timestamp;
  }

//   function addOrRemoveBlocklistedUser(address _address) external onlyOwner

  function addOrRemoveBlocklistedUser(address _address) external {
        toggleBlocklistedUser(_address);
    }
//  function approveProposal(uint256 _proposal) external onlyOwner
  function approveProposal(uint256 _proposal) external  {
     Proposal storage prop =  _proposals[_proposal];
     prop.isApproved = true;
  }

  function toggleBlocklistedUser(address _address) internal {
     if(blocklistUsers[_address].isBlocked){
          uint256 blockId = blocklistUsers[_address].id;
          blocklist[blockId] = blocklist[blocklist.length - 1];
          blocklistUsers[blocklist[blocklist.length - 1]].id = blockId;
          blocklistUsers[_address].isBlocked = false;
          blocklist.pop();
        }else{
            blocklistUsers[_address].isBlocked = true;
            blocklistUsers[_address].id = blocklist.length;
            blocklist.push(_address);
        }
  }

  function isUserBlacklisted (address _address) public view returns (bool){
    return blocklistUsers[_address].isBlocked;
  }
            //  function addOrRemoveMultipleBlocklists(address[] calldata _addresses) external onlyOwner
  function addOrRemoveMultipleBlocklists(address[] calldata _addresses) external  {
      for (uint i=0; i<_addresses.length; i++) {
         toggleBlocklistedUser(_addresses[i]);
      }
  }

  function getVoteWeightPerUser(address _user) public view returns (uint256) {
      return (balanceOf(_user).mul(1e18)).div(totalSupply());
  }

  function vote(uint256 _proposal,bool _vote) public onlyVoters {
      Proposal storage prop =  _proposals[_proposal];
      require(prop.isActive, "Proposal is Closed by Proposer !");
      require(prop.isApproved, "Proposal is not Approved by the Authority !");
      require(!isUserBlacklisted(msg.sender), "You have been Blacklisted by the Authority !");
      collectVoteFee();
      uint256 voteWeight = getVoteWeightPerUser(msg.sender);
      if(votes[msg.sender][_proposal].isVoted && votes[msg.sender][_proposal].vote != _vote){
        // already voted and changes
        votes[msg.sender][_proposal].vote ? prop.upVote -= voteWeight : prop.downVote -= voteWeight;
       _vote ? prop.upVote += voteWeight : prop.downVote += voteWeight;
      }else if(!votes[msg.sender][_proposal].isVoted){ 
       _vote ? prop.upVote += voteWeight : prop.downVote += voteWeight;
      }
      prop.lastUpdated = block.timestamp;
      votes[msg.sender][_proposal].vote = _vote;
      votes[msg.sender][_proposal].isVoted = true;
      votes[msg.sender][_proposal].VotedOn = block.timestamp;
      emit Votes(msg.sender,_proposal,voteWeight);
  }
  // function deleteProposal(uint256 _proposal) public onlyOwner
   function deleteProposal(uint256 _proposal) public {
        _proposals[_proposal] = _proposals[_proposals.length - 1];
        _proposals.pop();
    }

    function getTotalProposals() public view returns (Proposal[] memory){
        return _proposals;
    }

  function pendingProfit(address _user) public view returns (uint256) {
    uint256 share = balanceOf(_user);
    User storage user = userInfo[_user]; 
    uint256 profitShare = getProfitSharePerUser(_user);
    uint256 reward = (share.mul(profitShare).div(1e12)).sub(user.lastRewardedAmount);
    return reward;
  }

  function claim() public {
    require(!isUserBlacklisted(msg.sender), "You have been Blacklisted by the Authority !");

    User storage user = userInfo[msg.sender]; 
    uint256 share = balanceOf(msg.sender);
    uint256 profitShare = getProfitSharePerUser(msg.sender);
    uint256 reward = (share.mul(profitShare).div(1e12)).sub(user.lastRewardedAmount);
    if(reward > IBEP20Upgradeable(PROFIT_TOKEN).balanceOf(msg.sender)) { reward = IBEP20Upgradeable(PROFIT_TOKEN).balanceOf(msg.sender); }
    IBEP20Upgradeable(PROFIT_TOKEN).transfer(msg.sender,reward);
    user.lastRewardedAmount = (share.mul(profitShare).div(1e12));
    user.lastClaimed = block.timestamp;
  }

}