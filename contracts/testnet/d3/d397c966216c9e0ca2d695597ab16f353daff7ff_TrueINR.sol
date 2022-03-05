/**
 *Submitted for verification at BscScan.com on 2022-03-04
*/

// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity ^0.8.10;

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256){
        if (a == 0){
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }
    
    function sub(uint256 a, uint256 b) internal pure returns (uint256){
        assert(b <= a);
        return a - b;
    }
    
    function add(uint256 a, uint256 b) internal pure returns (uint256){
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract TrueINR {

    using SafeMath for uint256;
    
    string public symbol;
    string public  name;
    uint8 public decimals;
    uint256 private _totalSupply;
    uint256 internal fixedFee;
    uint256 internal minVariableFee;
    uint256 internal maxVariableFee;
    uint256 internal variableFeeNumerator;
    address internal feeCollector;
    address public owner;
    bool public paused = false;

    mapping(address => bool) internal bearer;
    mapping(address => uint256) internal balances;
    mapping(address => mapping(address => uint256)) internal allowed;
    mapping (address => uint256) internal freezeAccount;
    mapping (address => bool) public isBlackListed;
    mapping (address => uint256) public freezeList;
    
    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint256 tokens);
    event Freeze(address account, uint tokens);
    event Unfreeze(address account, uint tokens);
    event DestroyedBlackFunds(address _blackListedUser, uint _balance);
    event AddedBlackList(address _user);
    event RemovedBlackList(address _user);
    event Destruction(uint256 _amount);
    event FeeChange (uint256 fixedFee, uint256 minVariableFee, uint256 maxVariableFee, uint256 variableFeeNumerator);
    event Pause();
    event Unpause();
   
    constructor(){
        symbol = "TINR";
        name = "TrueINR";
        decimals = 8;

        owner = msg.sender;
        _addMinter(msg.sender);
        feeCollector = msg.sender;
        
        fixedFee = 5e2;
    }

    /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
    modifier whenNotPaused() {
      require(!paused);
      _;
    }

    /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
    modifier whenPaused() {
      require(paused);
      _;
    }

    /**
   * @dev Throws if called by any account other than the owner.
   */
    modifier onlyOwner() {
        require(msg.sender == owner, "You Are Not Authorized To Do This Action");
        _;
    }

    modifier onlyMinter() {
        require(isMinter(msg.sender), "MinterRole: caller does not have the Minter role");
        _;
    }

    function isMinter(address account) public view returns (bool) {
        return hasRole(account);
    }

    function addMinter(address account) public onlyMinter {
        _addMinter(account);
    }

    function renounceMinter() public onlyOwner {
        _removeMinter(msg.sender);
    }

    function _addMinter(address account) internal {
        addRole(account);
        emit MinterAdded(account);
    }

    function _removeMinter(address account) internal {
        removeRole(account);
        emit MinterRemoved(account);
    }

    /**
   * @dev called by the owner to pause, triggers stopped state
   */
    function pause() public onlyOwner whenNotPaused{
      paused = true;
      emit Pause();
    }

    /**
   * @dev called by the owner to unpause, returns to normal state
   */
    function unpause() public onlyOwner whenPaused{
      paused = false;
      emit Unpause();
    }

    function getBlackListStatus(address _maker) external view returns (bool) {
        return isBlackListed[_maker];
    }    
    
    function addBlackList (address _evilUser) public onlyOwner {
        isBlackListed[_evilUser] = true;
        emit AddedBlackList(_evilUser);
    }

    function removeBlackList (address _clearedUser) public onlyOwner {
        isBlackListed[_clearedUser] = false;
        emit RemovedBlackList(_clearedUser);
    }

    function addRole(address account) internal {
        require(!hasRole(account), "Roles: account already has role");
        bearer[account] = true;
    }
    
    function removeRole(address account) internal {
        require(hasRole(account), "Roles: account does not have role");
        bearer[account] = false;
    }
    
    function hasRole(address account) internal view returns (bool) {
        require(account != address(0), "Roles: account is the zero address");
        return bearer[account];
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
         require(!isBlackListed[msg.sender], "Your Address is Blacklisted");
         require(!isFreeze(msg.sender), "You are not authorized to transfer");
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

/**
   * approve should be called when allowed[spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   */
  function increaseApproval(address spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][spender] = allowed[msg.sender][spender].add(_addedValue);
    emit Approval(msg.sender, spender, allowed[msg.sender][spender]);
    return true;
  }

  function decreaseApproval(address spender, uint _subtractedValue) public returns (bool) {
    uint oldValue = allowed[msg.sender][spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][spender] = 0;
    } else {
      allowed[msg.sender][spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, spender, allowed[msg.sender][spender]);
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
         require(!isBlackListed[msg.sender], "Your Address is Blacklisted");
         require(!isFreeze(msg.sender), "You are not authorized to transfer");
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
        require(account != address(0), "ERC20: mint to the zero address");

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
        require(account != address(0), "ERC20: burn from the zero address");

        _totalSupply = _totalSupply.sub(value);
        balances[account] = balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }


    //........................................................
    //destroyBlackFunds
    //..................................................
    
    function destroyBlackFunds (address _blackListedUser) public onlyOwner {
        require(isBlackListed[_blackListedUser], "Address must be in blacklist to be able to destroy fund");
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
    require (_variableFeeNumerator <= 100000);

    fixedFee = _fixedFee;
    minVariableFee = _minVariableFee;
    maxVariableFee = _maxVariableFee;
    variableFeeNumerator = _variableFeeNumerator;
    emit FeeChange (_fixedFee, _minVariableFee, _maxVariableFee, _variableFeeNumerator);
  }
  
    
 
  function getFeeParameters () public view returns (uint256 _fixedFee, uint256 _minVariableFee, uint256 _maxVariableFee, uint256 _variableFeeNumnerator) {
    _fixedFee = fixedFee;
    _minVariableFee = minVariableFee;
    _maxVariableFee = maxVariableFee;
    _variableFeeNumnerator = variableFeeNumerator;
  }
    

  function calculateFee (uint256 _amount) public view returns (uint256 _fee) {
    _fee = SafeMath.mul(_amount, variableFeeNumerator) / 100000;
    if (_fee < minVariableFee) _fee = minVariableFee;
    if (_fee > maxVariableFee) _fee = maxVariableFee;
    _fee = SafeMath.add(_fee, fixedFee);
  }


    function freezeAmount (address _userAddress, uint _freezeValue) public whenNotPaused onlyOwner returns (bool) {
        require(_userAddress != address(0), "Account is the zero address");
        require(_freezeValue > 0, "Amount must be greater than zero");
        freezeAccount[_userAddress] = _freezeValue;
        balances[_userAddress] = balances[_userAddress].sub(_freezeValue);
        emit Freeze(_userAddress, _freezeValue);
        return true;
    }
    
    function unfreezeAmount (address _userAddress, uint _unFreezeValue) public whenNotPaused onlyOwner returns (bool) {
        require(freezeAccount[_userAddress]>= _unFreezeValue, "Enter Valid Amount");
        freezeAccount[_userAddress] -= _unFreezeValue;
        balances[_userAddress] = balances[_userAddress].add(_unFreezeValue);
        emit Unfreeze(_userAddress, _unFreezeValue);
        return true;
    }
    
    function getFreezeAmount (address _userAddress) public view returns(uint){
        return freezeAccount[_userAddress];
    }
    
}