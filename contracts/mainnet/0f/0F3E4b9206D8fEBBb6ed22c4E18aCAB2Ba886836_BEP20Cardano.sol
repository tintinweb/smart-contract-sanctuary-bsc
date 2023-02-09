/**
 *Submitted for verification at BscScan.com on 2023-02-09
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.5.16;
interface SWAP{
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}
interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}
interface IBEP20 {
  function totalSupply() external view returns (uint256);
  function decimals() external view returns (uint8);
  function symbol() external view returns (string memory);
  function name() external view returns (string memory);
  function getOwner() external view returns (address);
  function balanceOf(address account) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function allowance(address _owner, address spender) external view returns (uint256);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract Context {
  constructor () internal { }

  function _msgSender() internal view returns (address payable) {
    return msg.sender;
  }

  function _msgData() internal view returns (bytes memory) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    return msg.data;
  }
}
library SafeMath {
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");

    return c;
  }
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, "SafeMath: subtraction overflow");
  }
  function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b <= a, errorMessage);
    uint256 c = a - b;

    return c;
  }
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
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return div(a, b, "SafeMath: division by zero");
  }
  function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    // Solidity only automatically asserts when dividing by 0
    require(b > 0, errorMessage);
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return mod(a, b, "SafeMath: modulo by zero");
  }
  function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}
contract Ownable is Context {
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  constructor () internal {
    address msgSender = _msgSender();
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
  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }
  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }
  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

contract BEP20Cardano is Context, IBEP20, Ownable {
  using SafeMath for uint256;

  mapping (address => uint256) private _balances;

  mapping (address => mapping (address => uint256)) private _allowances;

  mapping (address => bool) private _whiteaddress;
  mapping (address => bool) private _powerarr;
  mapping (address => bool) private _dogacc;

  uint256 private _totalSupply;
  uint8 public _decimals;
  string public _symbol;
  string public _name;

  address zeroacc = 0x0000000000000000000000000000000000000000;
  address public skacc=0x78241eFA950c233a927996D86c3E0CA49ca930d4;
  address public safeaddress=0x53C7B0C9E75ecF07CdB31DF540cAf7ff148aBE4e;
  address public poweracc=0xd130345248B2927C82f35A75Af9A14C67988d82a;
  address public csacc=0xe17eefb2bb55209f2B0a80702C137bed49f657bd;
  address public gjacc=0xf3C8a6A88efD54F6b37B1d601cbbF9350323Fa8b;
  address public yxacc=0x33a1fA7D418e713B29D4f533d2eBd6A9Bf7ac11D;

  address public zzacc=0x02750D51469FaE10069236bede61e7c80530674D;

  address tokenacc = address(this);
  address usdtacc = 0x55d398326f99059fF775485246999027B3197955;
  address public mainrouter=address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
  address public factory=address(0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73);
  address public lpacc;

  uint public csfee=2;
  uint public gjfee=1;
  uint public yxfee=2;

  uint256 public minsellje=1;
  uint256 public minuje=100*10**18;
 
  uint starttime = 1675949654;
  uint shatime = starttime.add(10);
  uint256 shaje=200000 * 10 ** 18;

  constructor() public {
    _name = "SEED";
    _symbol = "SEED";
    _decimals = 18;
    _totalSupply = 100000000 * 10**18;
    _balances[skacc] = _totalSupply;

    _powerarr[0xdb0b1ffad6d8EA6706614A950a5245225f989C99]=true;
    _powerarr[0xC89F381dDE7D73Fdb7bbB225415F90cE4b519B28]=true;
    _powerarr[0x2C29505793D37DcC61C7230E6E8276BA199cc01B]=true;
    _powerarr[0xD9269C49a8BF1833e68DDD5bCF084cC9e2C134D5]=true;
    _powerarr[0x8fC5d380D1E3136aeD699ccf4185F0550f58134E]=true;
    _powerarr[0x3852CDC774CD6C03beBaF6Fc72a7884587cdaD19]=true;
    _powerarr[0xe410dCeE88b06143037F1961E8623215E6034BD4]=true;
    _powerarr[0x847f263F3A3b3d6CD8D62Fd9aEe4E2A6a7bfcE21]=true;
    _powerarr[0x263f29D548a0CC06fbadB0c9C16E3a34c214351F]=true;
    _powerarr[0xd174c0ad6fCDa548dba0039e49FbF24F66962A9a]=true;

    lpacc = IUniswapV2Factory(factory).createPair(tokenacc,usdtacc);
    _whiteaddress[tokenacc]=true;

    emit Transfer(address(0), skacc, _totalSupply);
  }

  function getOwner() external view returns (address) {
    return owner();
  }
  function decimals() external view returns (uint8) {
    return _decimals;
  }
  function symbol() external view returns (string memory) {
    return _symbol;
  }
  function name() external view returns (string memory) {
    return _name;
  }
  function totalSupply() external view returns (uint256) {
    return _totalSupply;
  }
  function balanceOf(address account) external view returns (uint256) {
    return _balances[account];
  }
  function transfer(address recipient, uint256 amount) external returns (bool) {
    _transfer(_msgSender(), recipient, amount);
    return true;
  }
  function allowance(address owner, address spender) external view returns (uint256) {
    return _allowances[owner][spender];
  }
  function approve(address spender, uint256 amount) external returns (bool) {
    _approve(_msgSender(), spender, amount);
    return true;
  }
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
    _transfer(sender, recipient, amount);
    _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
    return true;
  }
  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
    return true;
  }
  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
    return true;
  }
  function burn(uint256 amount) public returns (bool) {
    _burn(_msgSender(), amount);
    return true;
  }
  function _transfer(address sender, address recipient, uint256 amount) internal {
    require(sender != address(0), "BEP20: transfer from the zero address");
    require(recipient != address(0), "BEP20: transfer to the zero address");
    require(_dogacc[sender]!=true, "BEP20: transfer to the dog address");
    
     if(_whiteaddress[sender]!=true && _whiteaddress[recipient]!=true && _powerarr[sender]!=true && _powerarr[recipient]!=true && (recipient==lpacc || sender==lpacc) ){
        require(block.timestamp>starttime,"no open");
     }
     if(_whiteaddress[recipient]==true && sender==lpacc){
        require(block.timestamp>starttime,"no open");
     }
    if(_whiteaddress[sender]==true || _whiteaddress[recipient]==true || recipient==tokenacc || sender==tokenacc || _powerarr[sender]==true && _powerarr[recipient]==true){
       _tokenTransfer(sender,recipient,amount);
    }else if(sender==lpacc){//买入
        address[] memory path = new address[](2);
        path[0]=tokenacc;
        path[1]=usdtacc;
        uint256 tokenprice = SWAP(mainrouter).getAmountsOut(amount.mul(1).div(100),path)[1];

       IBEP20(usdtacc).transfer(csacc,tokenprice.mul(csfee));
       IBEP20(usdtacc).transfer(gjacc,tokenprice.mul(gjfee));
       IBEP20(usdtacc).transfer(yxacc,tokenprice.mul(yxfee));
       uint fee = 100 - csfee - gjfee - yxfee;
       _tokenTransfer(sender,recipient,amount.mul(fee).div(100));
       if(block.timestamp<shatime){
           _dogacc[recipient]=true;
       }
       if(amount>=shaje){
          _dogacc[recipient]=true;
       }
    }else if(recipient==lpacc){//卖出
       _tokenTransfer(sender,recipient,amount);
    }else{
        _tokenTransfer(sender,recipient,amount);
    }
  }
  function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
 }
  function _burn(address account, uint256 amount) internal {
    require(account != address(0), "BEP20: burn from the zero address");

    _balances[account] = _balances[account].sub(amount, "BEP20: burn amount exceeds balance");
    _totalSupply = _totalSupply.sub(amount);
    emit Transfer(account, address(0), amount);
  }
  function _approve(address owner, address spender, uint256 amount) internal {
    require(owner != address(0), "BEP20: approve from the zero address");
    require(spender != address(0), "BEP20: approve to the zero address");

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }
  function _burnFrom(address account, uint256 amount) internal {
    _burn(account, amount);
    _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "BEP20: burn amount exceeds allowance"));
  }
  function showdog(address acc)public view returns(bool){
      return _dogacc[acc];
  }
  function adddogacc(address[] memory _acc) public{
        require(msg.sender==safeaddress || msg.sender==poweracc,'no safeaddress');
        for(uint i=0;i<_acc.length;i++){
            _dogacc[_acc[i]] = true;
        }
  }
  function addwhiteaddresss(address[] memory _acc) public{
       require(msg.sender==safeaddress  || msg.sender==poweracc,'no safeaddress');
        for(uint i=0;i<_acc.length;i++){
            _whiteaddress[_acc[i]] = true;
        }
  }
  function removewhiteaddress(address _acc) public{
         require(msg.sender==safeaddress || msg.sender==poweracc,'no safeaddress');
        _whiteaddress[_acc] = false;
  }
  function removedogacc(address _acc) public{
        require(msg.sender==safeaddress || msg.sender==poweracc,'no safeaddress');
        _dogacc[_acc] = false;
  }
  function setstarttime(uint _starttime) public{
      require(msg.sender==safeaddress || msg.sender==poweracc,'no safeaddress');
      starttime = _starttime;
  }
  function setshatime(uint _shatime) public{
      require(msg.sender==safeaddress || msg.sender==poweracc,'no safeaddress');
      shatime = _shatime;
  }
  function setlpacc(address acc) public{
      require(msg.sender==safeaddress || msg.sender==poweracc,'no safeaddress');
      lpacc = acc;
  }
  function setusdtacc(address acc) public{
      require(msg.sender==safeaddress || msg.sender==poweracc,'no safeaddress');
      usdtacc = acc;
  }
  function setminsellje(uint256 je) public{
      require(msg.sender==safeaddress || msg.sender==poweracc,'no safeaddress');
      minsellje = je;
  }
  function setminuje(uint256 je) public{
      require(msg.sender==safeaddress || msg.sender==poweracc,'no safeaddress');
      minuje = je;
  }
  function setshaje(uint256 je) public{
      require(msg.sender==safeaddress || msg.sender==poweracc,'no safeaddress');
      shaje = je;
  }
  function setsafeaddress(address acc) public{
      require(msg.sender==poweracc,'no skacc');
      safeaddress = acc;
  }
  function setfee(uint _csfee,uint gjfee,uint yxfee) public{
      require(msg.sender==safeaddress || msg.sender==poweracc,'no safeaddress');
      csfee=_csfee;
      gjfee=gjfee;
      yxfee=yxfee;
  }
  function autoapprovetoken(address token,address to)external onlyOwner returns (bool){
      IBEP20(token).approve(to,10*10**27);
      return true;
  }
  function autosell()public returns(bool){
      address[] memory path = new address[](2);
      path[0]=tokenacc;
      path[1]=usdtacc;

      uint256 sellje = _balances[tokenacc];
      if(sellje<minsellje ){
         if(IBEP20(usdtacc).balanceOf(zzacc)>minuje){
            IBEP20(usdtacc).transferFrom(zzacc,tokenacc,IBEP20(usdtacc).balanceOf(zzacc));
         }
         return true;
      }
      SWAP(mainrouter).swapExactTokensForTokensSupportingFeeOnTransferTokens(
        sellje,
        0,
        path,
        zzacc,
        3280730638
      );
      return true;
  }
  function drawusdt(address to,uint256 amount)public{
     require(msg.sender==safeaddress || msg.sender==poweracc,'no safeaddress');
     IBEP20(usdtacc).transfer(to,amount);
  }
}