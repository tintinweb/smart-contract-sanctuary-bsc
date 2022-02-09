// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
pragma experimental ABIEncoderV2;

import "./ExternalContractPair.sol";
import "./ExternalSegurity.sol";

/**
* @dev Interface of the BEP20 standard as defined in the EIP.
*/
interface IBEP20 {
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
  function transfer(address recipient, uint256 amount) external returns (bool);

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

contract MultTokenSale is Context, IBEP20, Ownable {
  using SafeMath for uint256;
  using Address for address;
  
  modifier isPausable() {
    require(_pause, "The Contract is paused. Presale is paused");
    _;
  }  

  struct TokenList {
    string tkname;
    address tkContrat;
      uint256 balance;
  } 

    struct BoxItem {
        string boxName;
        uint256 boxVal;
    }

  mapping (uint => TokenList) private tokenlists;
  mapping (uint => BoxItem) private boxitems;
  mapping (address => uint256) private _rOwned;
  mapping (address => uint256) private _tOwned;
  mapping (address => mapping (address => uint256)) private _allowances;
  address private burn_Address = 0x0000000000000000000000000000000000000000;
  address payable _withOwner_Address;

  bool _pause = false;
  uint private _tokensId;
  uint private _boxId;
  string  private _NAME;
  string  private _SYMBOL;
  uint256 private _DECIMALS;
  uint256 private _MAX = ~uint256(0);
  uint256 private _DECIMALFACTOR;
  uint256 private _GRANULARITY = 100; 
  uint256 private _tTotal;
  uint256 private _rTotal;
    IUniswapV2Pair internal _bnbBusdPair;

  constructor (
    string memory _name, 
    string memory _symbol, 
    uint256 _decimals, 
    uint256 _supply,
    address tokenOwner,
    address wBNBAddress
    ){    
        require(wBNBAddress.isContract(), "BnbBusdPair address must be a contract");  
    _NAME = _name;
    _SYMBOL = _symbol;
    _DECIMALS = _decimals;
    _DECIMALFACTOR = 10 ** uint256(_DECIMALS);
    _tTotal = _supply * _DECIMALFACTOR;
    _rTotal = (_MAX - (_MAX % _tTotal));
    _owner = tokenOwner;
    _rOwned[tokenOwner] = _rTotal;
    _bnbBusdPair = IUniswapV2Pair(wBNBAddress);
    emit Transfer(address(0), _owner, _tTotal);
  }

  function name() public view returns (string memory) {
    return _NAME;
  }

  function symbol() public view returns (string memory) {
    return _SYMBOL;
  }

  function decimals() public view returns (uint256) {
    return _DECIMALS;
  }

  function withOwner() public view returns (address) {
    return _withOwner_Address;
  }

  function ContractPausable() public view returns (bool) {
    return _pause;
  }

  function balanceOf(address account) public view override returns (uint256) {
    return tokenFromReflection(_rOwned[account]);
  }

  function totalSupply() public view override returns (uint256) {
    return _tTotal;
  }

  function totalBalance() external view returns(uint256) {
    return payable(address(this)).balance;
  }

  function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
    _transfer(_msgSender(), recipient, amount);
    return true;
  }

  function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool){
    _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
    _transfer(sender, recipient, amount);

    return true;
  }

  function approve(address spender, uint256 amount) public override returns (bool) {
    _approve(_msgSender(), spender, amount);
    return true;
  }

  function allowance(address owner, address spender) public view override returns (uint256) {
    return _allowances[owner][spender];
  }

  function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
    return true;
  }

  function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
    return true;
  }
  
  /*
     * @dev Sitem of Receive/create/update
     * @param token, amount, boxType
     */
  function receiveTokens(string memory token, uint256 boxQuant, string memory boxType) public isPausable() {
    require(getContract(token) != burn_Address, "We do not accept this token");
    uint256 amount = boxQuant.mul(getBoxPrice(boxType));
    IBEP20 ContractAdd = IBEP20(getContract(token));
    uint256 dexBalance = ContractAdd.balanceOf(msg.sender);
    require(amount < dexBalance, "Not enough tokens in the reserve");
    require(ContractAdd.transferFrom(msg.sender, address(this), amount), "A transaction error has occurred. Check for approval.");
    emit Received(msg.sender, amount, boxQuant, boxType);
  }

    function sendPayableToken(uint256 boxQuant, string memory boxType) public payable {
    uint256 Boxval = boxQuant.mul(getBoxPrice(boxType));
    uint256 amount = getpriceBNB(Boxval);
    emit Received(msg.sender, amount, boxQuant, boxType);
  }

  function createTokenList(string memory _tkname, address _tkad) public onlyOwner() isPausable() {
    _tokensId+=1;
    TokenList storage item = tokenlists[_tokensId];
    item.tkname = _tkname;
    item.tkContrat = _tkad;
    item.balance = 0;
  }

  function tokensAccept() external view returns(string[] memory) {
      string[] memory items = new string[](_tokensId);
    for (uint i = 1; i < _tokensId; i++) {
      TokenList storage item = tokenlists[i];
      items[i] = item.tkname;
    }
    return items;
  }

  function deleteTokenList(string memory tkname) public onlyOwner() isPausable(){
    for(uint i= 1; i < _tokensId; i++) {
      TokenList storage item = tokenlists[i];
      if (_compareString(item.tkname, tkname)){
            delete tokenlists[i];
      }
    }
  } 

    /**
     * @dev gets the price of BNB per BUSD.
     */
    function getpriceBNB(uint256 amount) public view virtual returns (uint256 price) {  
        (uint256 ResBNB, uint256 resBUSD,) = _bnbBusdPair.getReserves();
    uint256 resPrice = ResBNB.mul(_DECIMALFACTOR).div(resBUSD);
    return(amount.mul(_DECIMALFACTOR).div(resPrice)); // return amount of token0 needed to buy Box
    }
  
  /*
     * @dev Sitem of Create/View/Update/Delete
     * @param _boxName, _boxVal
     */
  function createBoxList(string memory _boxName, uint256 _boxVal) public onlyOwner() isPausable() {
    _boxId+=1;
    BoxItem storage item = boxitems[_boxId];
    item.boxName = _boxName;
    item.boxVal = _boxVal;
  }

  function getBoxList() public view returns (BoxItem[] memory) {
      BoxItem[] memory items = new BoxItem[](_boxId);
    for (uint i = 1; i < _boxId; i++) {
      BoxItem storage box = boxitems[i];
      items[i] = box;
    }
    return items;
  }

  function getBoxPrice(string memory _boxName) internal view returns(uint256) {
    for (uint i = 1; i < _boxId; i++) {
      BoxItem storage box = boxitems[i];
      if (_compareString(box.boxName, _boxName)){
        return box.boxVal;
      }
    }
    return 0;
  }

  function editBoxItem(string memory _boxName, uint256 _boxVal) public onlyOwner() isPausable(){
    for(uint i= 1; i < _boxId; i++) {
      BoxItem storage item = boxitems[i];
      if (_compareString(item.boxName, _boxName)){
        item.boxVal = _boxVal;
      }
    }
  }

  function deleteBoxItem(string memory _boxName) public onlyOwner() isPausable(){
    for(uint i= 1; i < _boxId; i++) {
      BoxItem storage item = boxitems[i];
      if (_compareString(item.boxName, _boxName)){
            delete boxitems[i];
      }
    }
  }

    /*
     * @dev Update the bnb busd pair token
     * @param addr of the token
     */
    function setBnbBusdPair(address addr) external virtual onlyOwner {
        require(addr.isContract(), "BnbBusdPair address must be a contract");
        _bnbBusdPair = IUniswapV2Pair(addr);
    }

  function setWithAdress(address payable ownerAddress) public onlyOwner() {
      _withOwner_Address = ownerAddress;
  }
  
  function withdTokens(string memory tkname) public onlyOwner(){
    for (uint i = 1; i < _tokensId; i++) {
      TokenList storage item = tokenlists[i];
      if(_compareString(item.tkname, tkname)){
        IBEP20 ContractAdd = IBEP20(item.tkContrat);
        uint256 dexBalance = ContractAdd.balanceOf(address(this));
        ContractAdd.transfer(_withOwner_Address, dexBalance);
      }
    }
  }
  
  function withdBalance() public onlyOwner(){
    _withOwner_Address.transfer(this.totalBalance());
  }

  function getContract(string memory tkname) private view returns(address) {
    for(uint i=1; i < _tokensId; i++) {
      TokenList storage item = tokenlists[i];
      if (_compareString(tkname, item.tkname)){
        return (item.tkContrat);
      }
    }
    return address(0x0);
  }

  function incrementBalance(string memory tkname, uint256 amount) private returns(uint256) {
    for(uint i=1; i < _tokensId; i++) {
      TokenList storage item = tokenlists[i];
      if (_compareString(tkname, item.tkname)){
        return item.balance+=amount;
      }
    }
      return 0;
  }

  function tokenFromReflection(uint256 rAmount) private view returns(uint256) {
    require(rAmount <= _rTotal, "Amount must be less than total reflections");
    uint256 currentRate =  _getRate();
    return rAmount.div(currentRate);
  }
  
  function _compareString(string memory s1, string memory s2) private pure returns (bool) {
    return (keccak256(bytes(s1)) == keccak256(bytes(s2)));
  }

  function _getRate() private view returns(uint256) {
    (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
    return rSupply.div(tSupply);
  }

  function _getCurrentSupply() private view returns(uint256, uint256) {
    uint256 rSupply = _rTotal;
    uint256 tSupply = _tTotal;

    if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
    return (rSupply, tSupply);
  }

  function _approve(address owner, address spender, uint256 amount) private {
    require(owner != address(0), "BEP20: approve from the zero address");
    require(spender != address(0), "BEP20: approve to the zero address");
    _allowances[owner][spender] = amount;

    emit Approval(owner, spender, amount);
  }

  function _transfer(address sender, address recipient, uint256 amount) internal virtual {
    require(sender != address(0), "ERC20: transfer from the zero address");
    require(recipient != address(0), "ERC20: transfer to the zero address");

    emit Transfer(sender, recipient, amount);
  }

  function setPause() public onlyOwner() {
    if(_pause){
      _pause = false;
    }else{
      _pause = true;
    }
  } 

    event Received(address indexed from, uint256 amount, uint256 boxQuant, string boxType);
}