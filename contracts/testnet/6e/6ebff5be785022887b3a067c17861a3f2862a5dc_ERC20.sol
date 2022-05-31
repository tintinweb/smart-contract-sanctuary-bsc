pragma solidity ^0.4.24;

//import "./IERC20.sol";
import "./ERC20Detailed.sol";
import "./SafeMath.sol";
import "./Roster.sol";

 

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
 * Originally based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
  contract ERC20 is ERC20Detailed {
    using SafeMath for uint256;
    using Roster for Roster.roster;

    event  SetWhite(address,uint8);
    event  RemoveWhite(address,uint8);

    event  SetAllotAddress(address,uint8);

    event OwnershipTransferred(address, address);
    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowed;

    uint256 private _totalSupply;

    address _owner;
    /*
    address public _allot;
    uint8 public _allotRate=10;
    */
    address public addressRelease;
    address public addressFixed;
    address public addressLp;

    Roster.roster public whiteListFrom;
    Roster.roster public whiteListTo;
    uint constant digit = 1E18;
    constructor (string name, string symbol, uint256 total ) public ERC20Detailed(name, symbol,18)  {
        _owner = msg.sender;
        _totalSupply =total.mul(digit);
        _balances[msg.sender] = _totalSupply;
    }
    modifier onlyOwner() {
        require(_owner == msg.sender, "caller is not the owner");
        _;
    }

    function setReleaseAddress(address _address) public onlyOwner{
        require(_address != address(0));
        addressRelease = _address;
        emit SetAllotAddress(_address,1);
    }

    function setLpAddress(address _address) public onlyOwner{
        require(_address != address(0));
        addressLp = _address;
        emit SetAllotAddress(_address,2);
    }
    
    function setFixedAddress(address _address) public onlyOwner{
        require(_address != address(0));
        addressFixed = _address;
        emit SetAllotAddress(_address,3);
    }

    function WhiteFromList() public view returns(address[] memory){
      return(whiteListFrom.details());
    }
    function WhiteToList() public view returns(address[] memory){
      return(whiteListTo.details());
    }
    function WhiteFrom(address _address) public view returns(bool){
      return(whiteListFrom.isexists(_address));
    }
    function WhiteTo(address _address) public view returns(bool){
      return(whiteListTo.isexists(_address));
    }
    
    function SetWhiteFrom(address _address) public onlyOwner{
        whiteListFrom.set(_address,1);
    }
    /*
    //temp _old
    function  SetWhiteListTo(address _address)public onlyOwner{
        whiteListFrom.set(_address,1);
    }

    //temp _old
    function  SetWhiteListFrom(address _address)public onlyOwner{
        whiteListFrom.set(_address,1);
    }
    */

    function RemoveWhiteFrom(address _address) public onlyOwner{ 
      whiteListFrom.remove(_address,1);
    }

    function SetWhiteTo(address _address) public onlyOwner{
      whiteListTo.set(_address,2);
    }

    function RemoveWhiteTo(address _address) public onlyOwner{ 
      whiteListTo.remove(_address,2);
    }
    /*
    function setAllot(address _address) public onlyOwner{
        _allot = _address;
        emit SetAllot(_address);
    }
     function setAllotRate(uint8 _rate) public onlyOwner{
         require(_rate <= 99,"rate range of 0-99");
        _allotRate = _rate;        
    }
    */
    function transferOwnership(address _newOwner) public   onlyOwner {
        require(_newOwner != address(0), "  new owner is the zero address");
        emit OwnershipTransferred(_owner, _newOwner);
        _owner = _newOwner;
    }


    /**
    * @dev Total number of tokens in existence
    */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }
    
    

  /**
  * @dev Gets the balance of the specified address.
  * @param owner The address to query the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address owner) public view returns (uint256) {
    return _balances[owner];
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param owner address The address which owns the funds.
   * @param spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(
    address owner,
    address spender
   )
    public
    view
    returns (uint256)
  {
    return _allowed[owner][spender];
  }

  /**
  * @dev Transfer token for a specified address
  * @param to The address to transfer to.
  * @param value The amount to be transferred.
  */
  function transfer(address to, uint256 value) public returns (bool) {
    _transfer(msg.sender, to, value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param spender The address which will spend the funds.
   * @param value The amount of tokens to be spent.
   */
  function approve(address spender, uint256 value) public returns (bool) {
    require(spender != address(0));

    _allowed[msg.sender][spender] = value;
    emit Approval(msg.sender, spender, value);
    return true;
  }

  /**
   * @dev Transfer tokens from one address to another
   * @param from address The address which you want to send tokens from
   * @param to address The address which you want to transfer to
   * @param value uint256 the amount of tokens to be transferred
   */
  function transferFrom(
    address from,
    address to,
    uint256 value
  )
    public
    returns (bool)
  {
    require(value <= _allowed[from][msg.sender]);

    _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
    _transfer(from, to, value);
    return true;
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed_[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param spender The address which will spend the funds.
   * @param addedValue The amount of tokens to increase the allowance by.
   */
  function increaseAllowance(
    address spender,
    uint256 addedValue
  )
    public
    returns (bool)
  {
    require(spender != address(0));

    _allowed[msg.sender][spender] = (
    _allowed[msg.sender][spender].add(addedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed_[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param spender The address which will spend the funds.
   * @param subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseAllowance(
    address spender,
    uint256 subtractedValue
  )
    public
    returns (bool)
  {
    require(spender != address(0));

    _allowed[msg.sender][spender] = (
      _allowed[msg.sender][spender].sub(subtractedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }

  /**
  * @dev Transfer token for a specified addresses
  * @param from The address to transfer from.
  * @param to The address to transfer to.
  * @param value The amount to be transferred.
  */
  function _transfer(address from, address to, uint256 value) internal {
    require(value <= _balances[from]);
    require(to != address(0));

    uint valueM = value;
      if ((!whiteListFrom.isexists(from) ) && (!whiteListTo.isexists(to))){
          require(addressRelease != address(0),"Release address is empty");
          require(addressLp != address(0),"Lp address is empty");
          require(addressFixed != address(0),"Fixed address is empty");
          
          uint valueRelease = value.mul(2).div(100);
          uint valueFixed = value.mul(2).div(100);
          uint valueLp = value.mul(6).div(100);
          valueM = value.sub(valueRelease).sub(valueFixed).sub(valueLp);

          _balances[from] = _balances[from].sub(valueRelease);
          _balances[addressRelease] = _balances[addressRelease].add(valueRelease);
          emit Transfer(from, addressRelease, valueRelease);

           _balances[from] = _balances[from].sub(valueFixed);
          _balances[addressFixed] = _balances[addressFixed].add(valueFixed);
          emit Transfer(from, addressFixed, valueFixed);

          _balances[from] = _balances[from].sub(valueLp);
          _balances[addressLp] = _balances[addressLp].add(valueLp);
           emit Transfer(from, addressLp, valueLp);
      }

      _balances[from] = _balances[from].sub(valueM);
      _balances[to] = _balances[to].add(valueM);
      emit Transfer(from, to, valueM);
  }

  /**
   * @dev Internal function that mints an amount of the token and assigns it to
   * an account. This encapsulates the modification of balances such that the
   * proper events are emitted.
   * @param account The account that will receive the created tokens.
   * @param value The amount that will be created.
   */
  function _mint(address account, uint256 value) internal {
    require(account != 0);
    _totalSupply = _totalSupply.add(value);
    _balances[account] = _balances[account].add(value);
    emit Transfer(address(0), account, value);
  }

  /**
   * @dev Internal function that burns an amount of the token of a given
   * account.
   * @param account The account whose tokens will be burnt.
   * @param value The amount that will be burnt.
   */
  function _burn(address account, uint256 value) internal {
    require(account != 0);
    require(value <= _balances[account]);

    _totalSupply = _totalSupply.sub(value);
    _balances[account] = _balances[account].sub(value);
    emit Transfer(account, address(0), value);
  }

  /**
   * @dev Internal function that burns an amount of the token of a given
   * account, deducting from the sender's allowance for said account. Uses the
   * internal burn function.
   * @param account The account whose tokens will be burnt.
   * @param value The amount that will be burnt.
   */
  function _burnFrom(address account, uint256 value) internal {
    require(value <= _allowed[account][msg.sender]);

    // Should https://github.com/OpenZeppelin/zeppelin-solidity/issues/707 be accepted,
    // this function needs to emit an event with the updated approval.
    _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(
      value);
    _burn(account, value);
  }
}