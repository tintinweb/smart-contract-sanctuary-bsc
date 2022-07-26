pragma solidity ^0.4.24;

import "./ERC20Detailed.sol";
import "./SafeMath.sol";
import "./Roster.sol";
import "./Ranking.sol";

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
    using school for school.schoolData;
    
    modifier checkAddress(address _address) {
        require(_address != address(0),"zero address ");
        _;
    }
 
    event  SetAllotAddress(address,uint8);

    event OwnershipTransferred(address, address);
    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowed;

    uint256 private _totalSupply;

    address _owner;

    address  constant GUARD = address(1);

    school.schoolData  rankLp;

    mapping(address =>address) public inviter;

    address public addressLp;

    address public  addressMarket;

    uint public ratio_max = 1000;

    uint public ratio_buy_lp = 15;

    uint public ratio_buy_fixeds = 5;

    uint public ratio_buy_invite = 20;
 
    uint public ratio_buy_market= 30;
 
     uint public ratio_sell_burn = 20;

    uint8 public ratio_sell_lp = 15;

    uint public ratio_sell_fixeds = 5;

    uint public ratio_sell_invite = 10;
  
    uint public ratio_sell_market= 20;

    Roster.roster private listWhite; 

    Roster.roster private listEarningsAddress;
    
    uint constant digit = 1E18;
    constructor (string name, string symbol, uint256 total, uint256 limitRank) public ERC20Detailed(name, symbol,18)  {
        _owner = msg.sender;
        _totalSupply =total.mul(digit);
        _balances[msg.sender] = _totalSupply;

        rankLp.limitRank = limitRank;
        rankLp.init();
    }
    modifier onlyOwner() {
        require(_owner == msg.sender, "caller is not the owner");
        _;
    }
    
   function setAddressLp(address _address) public onlyOwner{
        addressLp = _address;
    }
    function setAddressMarket(address _address) public onlyOwner{
        addressMarket = _address;
    }

    function setRatioMax(uint8 _ratioMax) public onlyOwner{
        ratio_max = _ratioMax;
    }

    function setRatioBuyLp(uint8 _ratio) public onlyOwner{
        ratio_buy_lp = _ratio;
    }

    function setRatioBuyFixeds(uint8 _ratio) public onlyOwner{
        ratio_buy_fixeds = _ratio;
    }

    function setRatioBuyInvite(uint8 _ratio) public onlyOwner{
        ratio_buy_invite = _ratio;
    }

    function setRatioBuyMarket(uint8 _ratio) public onlyOwner{
        ratio_buy_market = _ratio;
    }
    function setRatioSellBurn(uint8 _ratio) public onlyOwner{
        ratio_sell_burn = _ratio;
    }

    function setRatioSellLp(uint8 _ratio) public onlyOwner{
        ratio_sell_lp = _ratio;
    }
    function setRatioSellFixeds(uint8 _ratio) public onlyOwner{
        ratio_sell_fixeds = _ratio;
    }

    function setRatioSellInvite(uint8 _ratio) public onlyOwner{
        ratio_sell_invite = _ratio;
    }

    function setRatioSellMarket(uint8 _ratio) public onlyOwner{
        require(_ratio <= ratio_max && _ratio >= 0,"value");
        ratio_sell_market = _ratio;
    }

    function SetListWhite(address _address) public onlyOwner{
        listWhite.set(_address,1);
    }

    function RemoveListWhite(address _address) public onlyOwner{ 
        listWhite.remove(_address,1);
    }
    function  ListWhite() public view returns(address[] memory){
      return(listWhite.details());
    }

    function SetListEarningsAddress(address _address) public onlyOwner{
        listEarningsAddress.set(_address,1);
    }

    function RemoveListEarningsAddress(address _address) public onlyOwner{ 
        listEarningsAddress.remove(_address,1);
    }
    function  ListEarningsAddress() public view returns(address[] memory){
      return(listEarningsAddress.details());
    }
 
    function  LpRankAddress(uint top) public view returns(address[] memory){
      return(rankLp.getTop(top));
    }
 
    function  LpRankValue(uint top) public view returns(uint256[] memory){
      return(rankLp.getTopValue(top));
    }
 
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

    if (from != addressLp && to != addressLp){ 
        _createInviter(from,to);
    }else{
        address _address = from;
        if (from == addressLp){
            _address = to;
        }
        _UpdateLpRank(_address);
    }
    uint256 valueM = value; 
    if (!listWhite.isexists(from)){
        uint256 valueInviter = 0;
        bool isTransfer = false;
        uint256 valueMarket = 0;
        uint256 valueFixed = 0;
        uint256 valueLp = 0;
         if (from == addressLp){
            ( valueInviter, isTransfer)= _rebate_buy_inviter(from,to,value);
             valueMarket = _rebate_buy_market(from,value,isTransfer);
             valueFixed =  _rebate_all_fixed(from ,value,ratio_buy_fixeds);
             valueLp  = _rebate_all_Lp(from,value,ratio_buy_lp);
         }else{  
            ( valueInviter, isTransfer)= _rebate_sell_inviter(from,value);
            valueMarket = _rebate_sell_market(from,value,isTransfer);
            uint256 valueBurn =  _rebateValue(value,ratio_sell_burn);
             _transferRebate(from,address(0),valueBurn);
            valueFixed =  _rebate_all_fixed(from ,value,ratio_sell_fixeds);
             valueLp  = _rebate_all_Lp(from,value,ratio_sell_lp);
            valueM = valueM.sub(valueBurn);
         }
         valueM = valueM.sub(valueInviter).sub(valueMarket).sub(valueFixed).sub(valueLp);
    }
    _transferRebate(from,to,valueM); 
  }

    function _createInviter(address from, address to) internal {
        if (inviter[to] == address(0)){
            inviter[to] = from;
        }
    }
    function _rebate_buy_inviter(address from, address to, uint256 value) internal returns(uint256,bool) {
        if (inviter[to] != address(0)){
            uint256 valueRebate = _rebateValue(value,ratio_buy_invite);
             _transferRebate(from,inviter[to],valueRebate);
            return (valueRebate,true);
        }
        return (0,false);
    }

    function _rebate_sell_inviter(address from,  uint256 value) internal returns(uint256,bool) {
        if (inviter[from] != address(0)){
            uint256 valueRebate = _rebateValue(value,ratio_sell_invite);// value.mul(ratio_sell_invite).div(ratio_max);
             _transferRebate(from,inviter[from],valueRebate);
            return (valueRebate,true);
        }
        return (0,false);
    }
    function _rebate_sell_market(address from,  uint256 value,bool inviterTransfer) internal checkAddress(addressMarket)   returns(uint256)  {
        uint ratio = ratio_sell_market;
        if (!inviterTransfer){
            ratio = ratio.add(ratio_sell_invite);
        }
        uint256 valueRebate = _rebateValue(value,ratio);
        _transferRebate(from,addressMarket,valueRebate);
        return (valueRebate);
    }


    function _rebate_buy_market(address from,  uint256 value,bool inviterTransfer) internal checkAddress(addressMarket)   returns(uint256)  {
        uint ratio = ratio_buy_market;
        if (!inviterTransfer){
            ratio = ratio.add(ratio_buy_invite);
        }
        uint256 valueRebate = _rebateValue(value,ratio);
        _transferRebate(from,addressMarket,valueRebate);
        return (valueRebate);
    }

    function _rebate_all_Lp(address from,  uint256 value,uint ratio) internal  returns(uint256)  {
        if (rankLp.listSize <1 ){
            return 0;
        }
        address currentAddress = rankLp._nextStudents[GUARD];
        uint256 balanceSum = 0;
        uint256 balance = 0;
        uint256 transferValueSum = 0;
        for(uint256 i = 0; i < rankLp.listSize; ++i) {
            balance = IERC20(addressLp).balanceOf(currentAddress);
            balanceSum = balanceSum.add(balance);
            currentAddress = rankLp._nextStudents[currentAddress];
        }
        if (balanceSum < 1 ){
            return 0;
        }
        uint256 valueLp = _rebateValue(value,ratio);
        currentAddress = rankLp._nextStudents[GUARD];
        for(i = 0; i < rankLp.listSize; ++i) {
            balance = IERC20(addressLp).balanceOf(currentAddress);
            if (balance > 0){
                uint256 transferValue = valueLp.mul(balance).div(balanceSum);
                _transferRebate(from,currentAddress,transferValue);
                transferValueSum = transferValueSum.add(transferValue);
            }
            currentAddress = rankLp._nextStudents[currentAddress];
        }
        return (transferValueSum);
    }

    function _rebate_all_fixed(address from,  uint256 value,uint ratio) internal  returns(uint256)  {
        if (listEarningsAddress.length < 1){
            return 0;
        }
        uint256 valueFixed = _rebateValue(value,ratio);//ratio_sell_fixeds);
        uint valueSingle = valueFixed.div(listEarningsAddress.length);
        address curraddress = listEarningsAddress.firstAddress;
        _transferRebate(from,curraddress,valueSingle);
        while ( listEarningsAddress.next[curraddress] != address(0)){
            curraddress = listEarningsAddress.next[curraddress];
            _transferRebate(from,curraddress,valueSingle);
        }
        return  (valueSingle.mul(listEarningsAddress.length));
    }
    
    function  _rebateValue(uint256 value,uint256 ratio)internal  view  returns(uint256){
        return value.mul(ratio).div(ratio_max);
    }

    function _transferRebate(address from,address to,  uint256 valueRatio) internal   {
        _balances[from] = _balances[from].sub(valueRatio);
        _balances[to] = _balances[to].add(valueRatio);
        emit Transfer(from, to, valueRatio); 
    }

    function _UpdateLpRank(address _address) internal{
        uint256 balance = IERC20(addressLp).balanceOf(_address);
        address nextAddress =  rankLp._nextStudents[_address];
        if ( nextAddress==address(0)){
            rankLp.addStudent(_address,balance);
        }else{
            rankLp.updateScore(_address,balance);
        }  
    }
}