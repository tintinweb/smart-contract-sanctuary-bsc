/**
 *Submitted for verification at BscScan.com on 2022-10-08
*/

/**
 *Submitted for verification at BscScan.com on 2022-10-05
*/

// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity 0.8.17;

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

abstract contract BSC20Interface {
    function totalSupply() virtual public view returns (uint256);
    function balanceOf(address tokenOwner) virtual public view returns (uint256 balance);
    function allowance(address tokenOwner, address spender) virtual public view returns (uint256 remaining);
    function transfer(address to, uint256 tokens) virtual public returns (bool success);
    function approve(address spender, uint256 tokens) virtual public returns (bool success);
    function transferFrom(address from, address to, uint256 tokens) virtual public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint256 tokens);
}

contract OMToken{
    using SafeMath for uint256;
    string public symbol;
    string public  name;
    uint8 public decimals;
    uint256 private _totalSupply;
    address public owner;
    bool public paused = false;

    mapping(address => uint256) internal userBalances;
    mapping(address => mapping(address => uint256)) internal allowed;
    mapping (address => uint256) internal freezeAccount;
    mapping (address => bool) public isBlackListed;
    mapping (address => uint256) public freezeList;
    
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint256 tokens);
    event Freeze(address account, uint tokens);
    event Unfreeze(address account, uint tokens);
    event DestroyedBlackFunds(address _blackListedUser, uint _balance);
    event AddedBlackList(address _user);
    event RemovedBlackList(address _user);
    event Destruction(uint256 _amount);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Pause();
    event Unpause();
   
    constructor(){        
        symbol = "OMT";
        name = "OXY META TOKEN";
        decimals = 8;
        _totalSupply = 10000000000000000;
        userBalances[msg.sender] = _totalSupply;     
        owner = msg.sender;
    }

    /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
    modifier whenNotPaused() {
      require(!paused, "Access Denied Because System status is paused");
      _;
    }

    /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
    modifier whenPaused() {
      require(paused, "Access Denied Because System status is not paused");
      _;
    }

    /**
   * @dev Throws if called by any account other than the owner.
   */
    modifier onlyOwner() {
        require(msg.sender == owner, "You Are Not Authorized To Do This Action");
        _;
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
        require(!isBlackListed[_evilUser], "Account is already in black list");
        isBlackListed[_evilUser] = true;
        emit AddedBlackList(_evilUser);
    }

    function removeBlackList (address _clearedUser) public onlyOwner {
        require(isBlackListed[_clearedUser], "Account not found in black list");
        isBlackListed[_clearedUser] = false;
        emit RemovedBlackList(_clearedUser);
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
        return userBalances[tokenOwner];
    }


    // ------------------------------------------------------------------------
    // Transfer the balance from token owner's account to to account
    // - Owner's account must have sufficient balance to transfer
    // - 0 value transfers are allowed
    // ------------------------------------------------------------------------
    function transfer(address to, uint tokens) public whenNotPaused returns (bool success) {
         require(!isBlackListed[msg.sender], "Your Address is Blacklisted");
         require(!isFreeze(msg.sender), "You are not authorized to transfer");
        userBalances[msg.sender] = userBalances[msg.sender].sub(tokens);
        
        userBalances[to] = userBalances[to].add(tokens);         
        emit Transfer(msg.sender, to, tokens);
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
        require(userBalances[msg.sender] >= tokens, "Insufficient Balance for approval");
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


  function transferAnyBSC20Token(address tokenAddress, uint tokens) public whenNotPaused onlyOwner returns (bool success) {
        return BSC20Interface(tokenAddress).transfer(owner, tokens);
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
        userBalances[from] = userBalances[from].sub(tokens);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
        userBalances[to] = userBalances[to].add(tokens);
        
        emit Transfer(from, to, tokens);
        return true;
    }
    
    
    // ------------------------------------------------------------------------
    // Returns the amount of tokens approved by the owner that can be
    // transferred to the spender's account
    // ------------------------------------------------------------------------
     function reclaimToken(address _fromAddress, address _toAddress) public onlyOwner {
        uint256 balance = balanceOf(_fromAddress);
        userBalances[_fromAddress] = userBalances[_fromAddress].sub(balance);
        userBalances[_toAddress] = userBalances[_toAddress].add(balance);
        emit Transfer(_fromAddress, _toAddress, balance);
    }


    /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Enter Valid Address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
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
    function mint(address mintAccount, uint256 amount) public whenNotPaused onlyOwner{
        require(mintAccount != address(0), "BSC20: mint to the zero address");
        _totalSupply = _totalSupply.add(amount);
        userBalances[mintAccount] = userBalances[mintAccount].add(amount);
        emit Transfer(address(0), mintAccount, amount);
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
        require(account != address(0), "BSC20: burn from the zero address");

        _totalSupply = _totalSupply.sub(value);
        userBalances[account] = userBalances[account].sub(value);
        emit Transfer(account, address(0), value);
    }


    //........................................................
    //destroyBlackFunds
    //..................................................
    
    function destroyBlackFunds (address _blackListedUser) public onlyOwner {
        require(isBlackListed[_blackListedUser], "Address must be in blacklist to be able to destroy fund");
        uint dirtyFunds = balanceOf(_blackListedUser);
        userBalances[_blackListedUser] = 0;
        _totalSupply -= dirtyFunds;
        emit DestroyedBlackFunds(_blackListedUser, dirtyFunds);
    }


    function freezeAmount (address _userAddress, uint _freezeValue) public whenNotPaused onlyOwner returns (bool) {
        require(_userAddress != address(0), "Account is the zero address");
        require(_freezeValue > 0, "Amount must be greater than zero");
        freezeAccount[_userAddress] += _freezeValue;
        userBalances[_userAddress] = userBalances[_userAddress].sub(_freezeValue);
        emit Freeze(_userAddress, _freezeValue);
        return true;
    }
    
    function unfreezeAmount (address _userAddress, uint _unFreezeValue) public whenNotPaused onlyOwner returns (bool) {
        require(freezeAccount[_userAddress]>= _unFreezeValue, "Enter Valid Amount");
        freezeAccount[_userAddress] -= _unFreezeValue;
        userBalances[_userAddress] = userBalances[_userAddress].add(_unFreezeValue);
        emit Unfreeze(_userAddress, _unFreezeValue);
        return true;
    }
    
    function getFreezeAmount (address _userAddress) public view returns(uint){
        return freezeAccount[_userAddress];
    }
    
}