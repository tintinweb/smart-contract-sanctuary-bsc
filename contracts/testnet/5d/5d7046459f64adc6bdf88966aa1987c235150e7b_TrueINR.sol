/**
 *Submitted for verification at BscScan.com on 2022-02-22
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-19
*/

pragma solidity ^0.5.14;


library SafeMath 
{
    function mul(uint256 a, uint256 b) internal pure returns (uint256) 
    {
        if (a == 0) 
        {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }
    
    function div(uint256 a, uint256 b) internal pure returns (uint256) 
    {
        uint256 c = a / b;
        return c;
    }
    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) 
    {
        assert(b <= a);
        return a - b;
    }
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) 
    {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
    
    function ceil(uint256 a, uint256 m) internal pure returns (uint256) 
    {
        uint256 c = add(a,m);
        uint256 d = sub(c,1);
        return mul(div(d,m),m);
    }
    
    function safeSub(uint256 _x, uint256 _y) internal pure returns (uint256) {
        assert(_x >= _y);
        return _x - _y;
    }

}


// ----------------------------------------------------------------------------
// TRC Token Standard #20 Interface
// ----------------------------------------------------------------------------
contract TRC20Interface {
    function totalSupply() public view returns (uint256);
    function balanceOf(address tokenOwner) public view returns (uint256 balance);
    function allowance(address tokenOwner, address spender) public view returns (uint256 remaining);
    function transfer(address to, uint256 tokens) public returns (bool success);
    function approve(address spender, uint256 tokens) public returns (bool success);
    function transferFrom(address from, address to, uint256 tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint256 tokens);
}


// ----------------------------------------------------------------------------
// Contract function to receive approval and execute function in one call
//
// 
// ----------------------------------------------------------------------------
contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokens, address token, bytes memory data) public;
}


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address public owner;

    /**
      * @dev The Ownable constructor sets the original `owner` of the contract to the sender
      * account.
      */
    function Ownables() public {
        owner = msg.sender;
    }

    /**
      * @dev Throws if called by any account other than the owner.
      */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

}


contract BasicToken is Ownable, TRC20Interface {
    using SafeMath for uint;

    mapping(address => uint) public balances;


    /**
    * @dev Fix for the TRC20 short address attack.
    */
    modifier onlyPayloadSize(uint size) {
        require(!(msg.data.length < size + 4));
        _;
    }


    /**
    * @dev Gets the balance of the specified address.
    * @param _owner The address to query the the balance of.
    * @return An uint representing the amount owned by the passed address.
    */
    function balanceOf(address _owner) public view returns (uint balance) {
        return balances[_owner];
    }

}


// ----------------------------------------------------------------------------
// Owned contract
// ----------------------------------------------------------------------------
contract Owned {
    address public owner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
        owner = msg.sender;
    }
   
}

contract Pausable is Owned {
    event Pause();
    event Unpause();

    bool public paused = false;

    modifier whenNotPaused() {
      require(!paused);
      _;
    }

    modifier whenPaused() {
      require(paused);
      _;
    }

}

contract BlackList is Ownable, BasicToken {

    /////// Getters to allow the same blacklist to be used also by other contracts (including upgraded Tether) ///////
    function getBlackListStatus(address _maker) external view returns (bool) {
        return isBlackListed[_maker];
    }

    function getOwner() external view returns (address) {
        return owner;
    }

    mapping (address => bool) public isBlackListed;
    
    function addBlackList (address _evilUser) public onlyOwner {
        isBlackListed[_evilUser] = true;
        emit AddedBlackList(_evilUser);
    }

    function removeBlackList (address _clearedUser) public onlyOwner {
        isBlackListed[_clearedUser] = false;
        emit RemovedBlackList(_clearedUser);
    }

    event DestroyedBlackFunds(address _blackListedUser, uint _balance);

    event AddedBlackList(address _user);

    event RemovedBlackList(address _user);

}

library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    
    function add(Role storage role, address account) internal {
        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    
    function remove(Role storage role, address account) internal {
        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}




// ----------------------------------------------------------------------------
// TRC20 Token, with the addition of symbol, name and decimals and assisted
// token transfers
// ----------------------------------------------------------------------------
contract TrueINR is TRC20Interface, Pausable, BlackList {

    using SafeMath for uint256;
    using Roles for Roles.Role;
    
    string public symbol;
    string public  name;
    uint8 public decimals;
    uint256 private _totalSupply;
    address public MainAddress;

    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;
    mapping (address => uint256) freezeAccount;
    
    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);
    Roles.Role private _minters;
    
    mapping (address => uint256) public freezeList;
    
     // triggered when the total supply is decreased
    event Destruction(uint256 _amount);
    event FeeChange (uint256 fixedFee, uint256 minVariableFee, uint256 maxVariableFee, uint256 variableFeeNumerator);
    
      /**
   * Fixed fee amount in token units.
   */
  uint256 internal fixedFee;

  /**
   * Minimum variable fee in token units.
   */
  uint256 internal minVariableFee;

  /**
   * Maximum variable fee in token units.
   */
  uint256 internal maxVariableFee;

  /**
   * Variable fee numerator.
   */
  uint256 internal variableFeeNumerator;
  
      /**
   * Fee denominator (0.001%).
   */
  uint256 constant internal FEE_DENOMINATOR = 100000;

  /**
   * Maximum fee numerator (100%).
   */
  uint256 constant internal MAX_FEE_NUMERATOR = FEE_DENOMINATOR;

  /**
   * Minimum fee numerator (0%).
   */
  uint256 constant internal MIN_FEE_NUMERATIOR = 0;
  

  /**
   * Default transfer fee.
   */
  uint256 constant internal DEFAULT_FEE = 5e2;
  
  
  /**
   * Fee feeCollector
   */
   address internal feeCollector;
   


    // ------------------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------------------
    constructor() public {
        symbol = "TINR";
        name = "TrueINR";
        name = "TrueINR";
        decimals = 8;
        owner = msg.sender;
        _addMinter(msg.sender);
        feeCollector = msg.sender;
        
        fixedFee = DEFAULT_FEE;
        minVariableFee = 0;
        maxVariableFee = 0;
        variableFeeNumerator = 0;
    }

    modifier onlyMinter() {
        require(isMinter(msg.sender), "MinterRole: caller does not have the Minter role");
        _;
    }

    function isMinter(address account) public view returns (bool) {
        return _minters.has(account);
    }

    function addMinter(address account) public onlyMinter {
        _addMinter(account);
    }

    function renounceMinter() public {
        _removeMinter(msg.sender);
    }

    function _addMinter(address account) internal {
        _minters.add(account);
        emit MinterAdded(account);
    }

    function _removeMinter(address account) internal {
        _minters.remove(account);
        emit MinterRemoved(account);
    }

    modifier onlyOwner {

        require(msg.sender == owner || msg.sender == MainAddress);

        _;
    }


    function pause() onlyOwner whenNotPaused public {
      paused = true;
      emit Pause();
    }

    function unpause() onlyOwner whenPaused public {
      paused = false;
      emit Unpause();
    }


//............................................................................
//freeze and unfreeze
//................................................................

    function freeze(address freezeAddress) public onlyOwner returns (bool done)
    {
        freezeList[freezeAddress]=1;
        return isFreeze(freezeAddress);
        }

    function unFreeze(address freezeAddress) public onlyOwner returns (bool done)
    {
        delete freezeList[freezeAddress];
        return !isFreeze(freezeAddress); 
    }

    function isFreeze(address freezeAddress) public view returns (bool isFreezed) 
    {
        return freezeList[freezeAddress]==1;
    }
    

    

    // ------------------------------------------------------------------------
    // Total supply
    // ------------------------------------------------------------------------
    function totalSupply() public view returns (uint) {
        return _totalSupply ;
    }


    // ------------------------------------------------------------------------
    // Get the token balance for account tokenOwner
    // ------------------------------------------------------------------------
    function balanceOf(address tokenOwner) public view returns (uint balance) {
        return balances[tokenOwner];
    }


    // ------------------------------------------------------------------------
    // Transfer the balance from token owner's account to to account
    // - Owner's account must have sufficient balance to transfer
    // - 0 value transfers are allowed
    // ------------------------------------------------------------------------
    function transfer(address to, uint tokens) public whenNotPaused returns (bool success) {
         require(!isBlackListed[msg.sender]);
         require(!isFreeze(msg.sender));
        balances[msg.sender] = balances[msg.sender].sub(tokens);
        
         //calculate fee
        uint256 fee = calculateFee (tokens);
        
        //deduct fee
        uint256 remainingAmount = tokens-fee;
        
        balances[to] = balances[to].add(remainingAmount);
        balances[feeCollector] = balances[feeCollector].add(fee);
         
        emit Transfer(msg.sender, to, remainingAmount);
        return true;
    }

    

    // ------------------------------------------------------------------------
    // Token owner can approve for spender to transferFrom(...) tokens
    // from the token owner's account
    //
    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
    // recommends that there are no checks for the approval double-spend attack
    // as this should be implemented in user interfaces 
    // ------------------------------------------------------------------------
    function approve(address spender, uint tokens) public  whenNotPaused returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }


    // ------------------------------------------------------------------------
    // Transfer tokens from the from account to the to account
    // 
    // The calling account must already have sufficient tokens approve(...)-d
    // for spending from the from account and
    // - From account must have sufficient balance to transfer
    // - Spender must have sufficient allowance to transfer
    // - 0 value transfers are allowed
    // ------------------------------------------------------------------------
    function transferFrom(address from, address to, uint tokens) public whenNotPaused returns (bool success) {
         require(!isBlackListed[msg.sender]);
         require(!isFreeze(msg.sender));
        balances[from] = balances[from].sub(tokens);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
        
        //calculate fee
        uint256 fee = calculateFee (tokens);
        
        //deduct fee
        uint256 remainingAmount = tokens-fee;
        
        balances[to] = balances[to].add(remainingAmount);
        balances[feeCollector] = balances[feeCollector].add(fee);
        
        emit Transfer(from, to, remainingAmount);
        return true;
    }
    
    
    // ------------------------------------------------------------------------
    // Returns the amount of tokens approved by the owner that can be
    // transferred to the spender's account
    // ------------------------------------------------------------------------
     function reclaimToken(address _fromAddress, address _toAddress) public onlyOwner {
        uint256 balance = balanceOf(_fromAddress);
        balances[_fromAddress] = balances[_fromAddress].sub(balance);
        balances[_toAddress] = balances[_toAddress].add(balance);
        emit Transfer(_fromAddress, _toAddress, balance);
    }


    // ------------------------------------------------------------------------
    // Returns the amount of tokens approved by the owner that can be
    // transferred to the spender's account
    // ------------------------------------------------------------------------
    function allowance(address tokenOwner, address spender) public whenNotPaused view returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }


    // ------------------------------------------------------------------------
    // Token owner can approve for spender to transferFrom(...) tokens
    // from the token owner's account. The spender contract function
    // receiveApproval(...) is then executed
    // ------------------------------------------------------------------------
    function approveAndCall(address spender, uint tokens, bytes memory data) public whenNotPaused returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, address(this), data);
        return true;
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a `Transfer` event with `from` set to the zero address.
     *
     * Requirements
     *
     * - `to` cannot be the zero address.
     */
    function mint(address account, uint256 amount) public whenNotPaused onlyOwner{
        require(account != address(0), "TRC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        balances[account] = balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

     /**
     * @dev Destoys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a `Transfer` event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function burn(address account, uint256 value) public whenNotPaused onlyOwner{
        require(account != address(0), "TRC20: burn from the zero address");

        _totalSupply = _totalSupply.sub(value);
        balances[account] = balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }


 /**
     * @dev Destoys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a `Transfer` event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function DestroyToken(address account, uint256 value) public whenNotPaused onlyOwner{
        require(account != address(0), "TRC20: Destroy from the zero address");

        _totalSupply = _totalSupply.sub(value);
        balances[account] = balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }



    //........................................................
    //destroyBlackFunds
    //..................................................
    
    function destroyBlackFunds (address _blackListedUser) public onlyOwner {
        require(isBlackListed[_blackListedUser]);
        uint dirtyFunds = balanceOf(_blackListedUser);
        balances[_blackListedUser] = 0;
        _totalSupply -= dirtyFunds;
        emit DestroyedBlackFunds(_blackListedUser, dirtyFunds);
    }
    
    
     function setFeeCollector (address _feecollector) public onlyOwner {
        feeCollector = _feecollector;
    }
    
    
     /**
   * Set fee parameters.
   *
   * @param _fixedFee fixed fee in token units
   * @param _minVariableFee minimum variable fee in token units
   * @param _maxVariableFee maximum variable fee in token units
   * @param _variableFeeNumerator variable fee numerator
   */
  function setFeeParameters (uint256 _fixedFee, uint256 _minVariableFee, uint256 _maxVariableFee, uint256 _variableFeeNumerator) public payable {
    require (msg.sender == owner);

    require (_minVariableFee <= _maxVariableFee);
    require (_variableFeeNumerator <= MAX_FEE_NUMERATOR);

    fixedFee = _fixedFee;
    minVariableFee = _minVariableFee;
    maxVariableFee = _maxVariableFee;
    variableFeeNumerator = _variableFeeNumerator;
    emit FeeChange (_fixedFee, _minVariableFee, _maxVariableFee, _variableFeeNumerator);
  }
  
    
    /**
   * Get fee parameters.
   *
   * @return fee parameters
   */
  function getFeeParameters () public view returns (uint256 _fixedFee, uint256 _minVariableFee, uint256 _maxVariableFee, uint256 _variableFeeNumnerator) {
    _fixedFee = fixedFee;
    _minVariableFee = minVariableFee;
    _maxVariableFee = maxVariableFee;
    _variableFeeNumnerator = variableFeeNumerator;
  }
    
    
     /**
   * Calculate fee for transfer of given number of tokens.
   *
   * @param _amount transfer amount to calculate fee for
   * @return fee for transfer of given amount
   */
  function calculateFee (uint256 _amount) public view returns (uint256 _fee) {
    _fee = SafeMath.mul(_amount, variableFeeNumerator) / FEE_DENOMINATOR;
    if (_fee < minVariableFee) _fee = minVariableFee;
    if (_fee > maxVariableFee) _fee = maxVariableFee;
    _fee = SafeMath.add(_fee, fixedFee);
  }
    


    // ------------------------------------------------------------------------
    // Don't accept ETH
    // ------------------------------------------------------------------------
    function() external payable {
        revert();
    }


    // ------------------------------------------------------------------------
    // Owner can transfer out any accidentally sent TRC20 tokens
    // ------------------------------------------------------------------------
    function transferAnyTRC20Token(address tokenAddress, uint tokens) public whenNotPaused onlyOwner returns (bool success) {
        return TRC20Interface(tokenAddress).transfer(owner, tokens);
    }


    function setMainAddress (address _mainAddress) public onlyOwner whenNotPaused returns (bool) {
        
        require(_mainAddress != address(0));
        MainAddress = _mainAddress;

        return true;
    }

    function freeze_amount (address _userAddress, uint _freezeValue) public whenNotPaused onlyOwner returns (bool) {
        require(_userAddress != address(0));
        require(_freezeValue > 0);
        freezeAccount[_userAddress] = _freezeValue;
        balances[_userAddress] = balances[_userAddress].sub(_freezeValue);
        return true;
    }
    
    function Unfreeze_amount (address _userAddress, uint _unFreezeValue) public whenNotPaused onlyOwner returns (bool) {
        require(freezeAccount[_userAddress]>= _unFreezeValue);
        freezeAccount[_userAddress] -= _unFreezeValue;
        balances[_userAddress] = balances[_userAddress].add(_unFreezeValue);
        return true;
    }
    
    function getFreeze_amount (address _userAddress) public view returns(uint){
        return freezeAccount[_userAddress];
    }
    
}