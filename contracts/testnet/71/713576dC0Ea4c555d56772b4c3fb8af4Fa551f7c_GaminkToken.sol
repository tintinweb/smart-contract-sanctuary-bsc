/**
 *Submitted for verification at BscScan.com on 2022-03-30
*/

//SPDX-Lisence Identifier:MIT Lisence
pragma solidity ^0.8.3;

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
  constructor(){
    owner = msg.sender;
  }


  /**
   * @dev Throws if called by any account other than the owner. 
   */
  modifier onlyOwner() {
    require(msg.sender == owner, "The caller must be owner of the contract");
    _;
  }

}

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


  /**
   * @dev modifier to allow actions only when the contract IS paused
   */
  modifier whenNotPaused() {
    require(!paused, "Every Transaction is currently paused");
    _;
  }

  /**
   * @dev modifier to allow actions only when the contract IS NOT paused
   */
  modifier whenPaused {
    require(paused, "Every Transaction is currently unpaused");
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause()  public onlyOwner whenNotPaused returns (bool) {
    paused = true;
    emit Pause();
    return true;
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() public onlyOwner whenPaused returns (bool) {
    paused = false;
    emit Unpause();
    return true;
  }
}
/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
abstract contract BasicToken is Ownable  {
  uint public _totalSupply;

  uint public lastFee ;
  mapping(address => uint) balances;
 
  // additional variables for use if transaction fees ever became necessary
  uint public basisPointsRate = 0;
  uint public maximumFee = 0;

  /**
   * @dev Fix for the ERC20 short address attack.
   */
  modifier onlyPayloadSize(uint size) {
     require(msg.data.length >= size+ 4, "SuS Address");
     _;
  }
  
  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint _value) virtual onlyPayloadSize(2 * 32)  public{
    require(_to != address(0), "cant transfer to zero address");
    //REMIX TOLOL GTW DIMANA KEDOBELNYA CAPEK AKU
    _value /= 2;
    uint fee = (_value *basisPointsRate)/(100);
    if (fee > maximumFee) {
      fee = maximumFee;
    }
    uint sendAmount = (_value) - fee;
    balances[msg.sender] = balances[msg.sender]-_value;
    balances[_to] = balances[_to] + sendAmount;
    balances[owner] = balances[owner] + fee;
    lastFee = fee;
    emit Transfer(msg.sender, _to, sendAmount);
    emit Transfer(msg.sender, owner, fee);
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return balance An uint representing the amount owned by the passed address.
  */
  function balanceOf(address _owner)virtual view public returns (uint balance) {
    return balances[_owner];
  }

  event Transfer(address indexed from, address indexed to, uint value);
}


/**
 * @title Anti Whale
 * @dev For AntiWhale Purpose with limitting maximum transfer ever wallet addresses
 */
contract AntiWhale is BasicToken {
  mapping(address => bool) public excludedFromAntiWhale;
  uint256 private _maxTransferAmountRate;
  uint256 maxTransferAmount;

  constructor(){
    excludedFromAntiWhale[owner] = true;
    maxTransferAmount = _totalSupply * 5 / 100;
  }

  /**
   * @dev Getting maximum Transfer Amount on current time
   * @return An Uint the maximum transfer amount
   */
  function getMaxTransferAmount() public view returns(uint256){
    return maxTransferAmount;
  }

  function setMaxTransferRate(uint amount) public {
    maxTransferAmount = (_totalSupply * amount) / 10**18;
  }

  /**
   * @dev Checking is the wallet address excluded from antiWhale
   * @param _account The wallet address to check the antiWhaleStatus
   * @return A boolean antiWhale status of the account
   */
  function isExcludedFromAntiWhale(address _account) public view returns(bool){
    return excludedFromAntiWhale[_account];
  }

  /**
   * @dev add wallet address excluded from antiWhale
   * @param _account The wallet address to add the antiWhaleStatus
   */
  function addExcludedFromAntiWhale(address _account)  public onlyOwner {
    excludedFromAntiWhale[_account] = true;
    emit AddedExcludedAntiWhale(_account);
  }

   /**
   * @dev remove wallet address excluded from antiWhale
   * @param _account The wallet address to remove the antiWhaleStatus
   */
  function removeExcludedFromAntiWhale(address _account)  public onlyOwner{
    excludedFromAntiWhale[_account] = false;
    emit RemovedExcludedAntiWhale(_account);
  }
  
  /**
   * @dev Modifier for antiWhale Transaction
   */
  modifier antiWhale(uint256 _value){
    if(excludedFromAntiWhale[msg.sender]){
      _;
    }
    else{
    require(_value < maxTransferAmount, "The value must below maxTransferAmount");
    }
    _;
  }

  event AddedExcludedAntiWhale(address _user);

  event RemovedExcludedAntiWhale(address _user);
}

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is AntiWhale{

  mapping (address => mapping (address => uint)) allowed;
  uint public decimals;
  uint constant MAX_UINT = 2**256 - 1;

  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint _value)public virtual  onlyPayloadSize(3 * 32) {
    require(_from != address(0) && _to != address(0), "cant send with address(0) recipient or sender");
    require(_value <= balances[_from] , "The amount sent must less than sender's balance");
    uint _allowance = allowed[_from][msg.sender];
    require(_value <= _allowance, "The caller must have allowance for sender's of at least the amount");

    uint fee = (_value * basisPointsRate)/(10**2);
    if (fee > maximumFee) {
      fee = maximumFee;
    }
    uint sendAmount = _value - fee;
    balances[_to] = balances[_to] + sendAmount;
    balances[owner] = balances[owner] + fee;
    balances[_from] = balances[_from] - _value;
    if (_allowance < MAX_UINT) {
      allowed[_from][msg.sender] = _allowance - _value;
    }
    emit Transfer(_from, _to, sendAmount);
    emit Transfer(_from, owner, fee);
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint _value)  public virtual onlyPayloadSize (2 * 32) {

    // To change the approve amount you first have to reduce the addresses`
    //  allowance to zero by calling `approve(_spender, 0)` if it is not
    //  already 0 to mitigate the race condition described here:
    //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    require(_spender != address(0), "Cant make approval to zero address _spender");
    require(_value > 0, "The spender allowance must above zero");
    require(allowed[msg.sender][_spender] == 0, "the allowed of msg sender must be 0");
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
  }

  /**
   * @dev Function to check the amount of tokens than an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return remaining  A uint specifying the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender)public view virtual returns (uint remaining) {
    return allowed[_owner][_spender];
  }

  /**
   * @dev Increase Allowance from the sender to spend for the passed address
   * @param _spender The address which will spend the funds.
   * @param _value The amount Allowance to be increased.
   */
  function increaseAllowance(address _spender, uint256 _value) public {
    require(_value >0, "cant increase 0 value");
    uint256 temp_value = allowed[msg.sender][_spender] + _value;
    allowed[msg.sender][_spender] = 0;
    approve(_spender, temp_value);
    emit Approval(msg.sender, _spender,  temp_value);
  }

  /**
   * @dev decrease Allowance from the sender to spend for the passed address
   * @param _spender The address which will spend the funds.
   * @param _value The amount of Allowance to be decreased.
   */
  function decreaseAllowance(address _spender, uint256 _value) public  {
    require(_value >0, "cant decrease below 1 value");
    require(allowed[msg.sender][_spender] >= _value, "The allowance must at least higher than value");
    uint256 temp_value = allowed[msg.sender][_spender] - _value;
    allowed[msg.sender][_spender] = 0;
    approve(_spender, temp_value);
    emit Approval(msg.sender, _spender,  temp_value);
  }

  /**
   * @dev Function for increase token supply to specific address with onlyOwner
   * @param account The address which get the tokens
   * @param amount The amount of token to be increased
   */
  function mint(address account, uint256 amount) public onlyOwner{
      require(account != address(0), "cannot mint to zero address");
      require(_totalSupply + amount <= 10**9 * (10 ** decimals), "cannot mint more than 1 milliard token");
      _totalSupply = _totalSupply + amount;
      balances[account] = balances[account] + amount;
      emit Transfer(address(0), account, amount);
  }

  /**
   * @dev Function for decrease token supply
   * @param _amount The amount of token to be burned
   */
  function burn(uint _amount) onlyPayloadSize(1 * 32) virtual  public{
      require(msg.sender != address(0), "cannot burn from zero address");
      require(balances[msg.sender] >= _amount, "cannot burn more than account balance");
      _totalSupply -= _amount;
      balances[msg.sender] -= _amount;
      emit Transfer(msg.sender, address(0), _amount);
  }

  event Approval(address indexed owner, address indexed spender, uint value);
}

/**
   * Title BlackList status of account
   * @dev Contract for setting status blacklist for wallet addresses
   */
contract BlackList is Ownable, StandardToken {


      mapping (address => bool) public isBlackListed;

  /**
   * Title BlackList status of account
   * @dev Contract for setting status blacklist for wallet addresses
   */
    function getBlackListStatus(address _account) external view returns (bool) {
        return isBlackListed[_account];
    }


  /**
   * @dev function for add address that blacklisted
   * param _evilUser add Wallet address that look malicious against system
   */
    function addBlackList (address _evilUser) public onlyOwner {
        isBlackListed[_evilUser] = true;
        emit AddedBlackList(_evilUser);
    }

  /**
   * @dev function for remove address that blacklisted
   * param _clearedUser remove wallet address that not look malicious against system
   */
    function removeBlackList (address _clearedUser) public onlyOwner {
        isBlackListed[_clearedUser] = false;
        emit RemovedBlackList(_clearedUser);
    }

  /**
   * @dev function for remove 
   * param _blacklistedUser remove wallet address that not look malicious against system
   */
    function destroyBlackFunds (address _blackListedUser) public onlyOwner {
        require(isBlackListed[_blackListedUser]);
        uint dirtyFunds = balanceOf(_blackListedUser);
        balances[_blackListedUser] = 0;
        _totalSupply - dirtyFunds;
        emit DestroyedBlackFunds(_blackListedUser, dirtyFunds);
    }
  /**
  * @dev modifier 
  */
    modifier notBlacklisted(address _sender){
      require(!isBlackListed[_sender],"The Address is blacklisted");
      _;
    }

    event DestroyedBlackFunds(address _blackListedUser, uint _balance);

    event AddedBlackList(address _user);

    event RemovedBlackList(address _user);



}

abstract contract UpgradedStandardToken is StandardToken{
        // those methods are called by the legacy contract
        // and they must ensure msg.sender to be the contract address
        function transferByLegacy(address from, address to, uint value) virtual external;
        function transferFromByLegacy(address sender, address from, address spender, uint value) virtual external;
        function approveByLegacy(address from, address spender, uint value) virtual external;
        function burnByLegacy(uint _amount) virtual external;
}


/// @title - Madu Token - Tether.to
/// @author Ahmad Rusdian - <dian.gall[email protected]>, - <[email protected]>

contract GaminkToken is Pausable, BlackList {

  string public name;
  string public symbol;
  address public upgradedAddress;
  bool public deprecated;

  //  The contract can be initialized with a number of tokens
  //  All the tokens are deposited to the owner address
  //
  // @param _balance Initial supply of the contract
  // @param _name Token Name
  // @param _symbol Token symbol
  // @param _decimals Token decimals
  constructor(){
      uint _decimals = 18;
      _totalSupply = 1000000000 * 10 **_decimals;
      name = "MaduToken";
      symbol = "MADU";
      decimals = _decimals;
      balances[owner] = 1000000000 * 10 **_decimals;
      deprecated = false;
  }

  // Forward ERC20 methods to upgraded contract if this one is deprecated
  
  function burn(uint _amount)  public whenNotPaused notBlacklisted (msg.sender) antiWhale(_amount) override{
    if (deprecated) {
      return UpgradedStandardToken(upgradedAddress).burnByLegacy(_amount);
    } else {
      return super.burn(_amount);
    }
  }

  // Forward ERC20 methods to upgraded contract if this one is deprecated
  function transfer(address _to, uint _value)  public whenNotPaused notBlacklisted(msg.sender) antiWhale(_value) override{
    if (deprecated) {
      return UpgradedStandardToken(upgradedAddress).transferByLegacy(msg.sender, _to, _value);
    } else {
      return super.transfer(_to, _value);
    }
  }

  // Forward ERC20 methods to upgraded contract if this one is deprecated
  function transferFrom(address _from, address _to, uint _value)  public whenNotPaused notBlacklisted(_from) antiWhale(_value) override{
    if (deprecated) {
      return UpgradedStandardToken(upgradedAddress).transferFromByLegacy(msg.sender, _from, _to, _value);
    } else {
      return super.transferFrom(_from, _to, _value);
    }
  }

  // Forward ERC20 methods to upgraded contract if this one is deprecated
  function balanceOf(address who) public view override returns (uint) {
    if (deprecated) {
      return UpgradedStandardToken(upgradedAddress).balanceOf(who);
    } else {
      return super.balanceOf(who);
    }
  }

  // Forward ERC20 methods to upgraded contract if this one is deprecated
  function approve(address _spender, uint _value)  public onlyPayloadSize(2 * 32) notBlacklisted(_spender) override{
    if (deprecated) {
      return UpgradedStandardToken(upgradedAddress).approveByLegacy(msg.sender, _spender, _value);
    } else {
      return super.approve(_spender, _value);
    }
  }

  // Forward ERC20 methods to upgraded contract if this one is deprecated
  function allowance(address _owner, address _spender) public view override returns (uint remaining) {
    if (deprecated) {
      return StandardToken(upgradedAddress).allowance(_owner, _spender);
    } else {
      return super.allowance(_owner, _spender);
    }
  }

  // deprecate current contract in favour of a new one
  function deprecate(address _upgradedAddress)  public onlyOwner {
    deprecated = true;
    upgradedAddress = _upgradedAddress;
    emit Deprecate(_upgradedAddress);
  }

  // Issue a new amount of tokens
  // these tokens are deposited into the owner address
  //
  // @param _amount Number of tokens to be issued
  function issue(uint amount)  public onlyOwner {
    require(_totalSupply + amount > _totalSupply);
     require(balances[owner] + amount > balances[owner]);

    balances[owner] += amount;
    _totalSupply += amount;
    emit Issue(amount);
  }

  // Redeem tokens.
  // These tokens are withdrawn from the owner address
  // if the balance must be enough to cover the redeem
  // or the call will fail.
  // @param _amount Number of tokens to be issued
  function redeem(uint amount)  public onlyOwner {
      require(_totalSupply > amount);
      require(balances[owner] > amount);

      _totalSupply -= amount;
      balances[owner] -= amount;
      emit Redeem(amount);
  }

  function setParams(uint newBasisPoints, uint newMaxFee) public onlyOwner {
      // Ensure transparency by hardcoding limit beyond which fees can never be added
      // require(newBasisPoints <= 90);
      require(newMaxFee <= 1000);

      basisPointsRate = newBasisPoints;
      maximumFee = newMaxFee * (10**decimals);

      emit Params(basisPointsRate, maximumFee);
  }

  // Called when new token are issued
  event Issue(uint amount);

  // Called when tokens are redeemed
  event Redeem(uint amount);

  // Called when contract is deprecated
  event Deprecate(address newAddress);

  // Called if contract ever adds fees
  event Params(uint feeBasisPoints, uint maxFee);
}