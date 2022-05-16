/**
 *Submitted for verification at BscScan.com on 2022-05-16
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.5.16;

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
  // Empty internal constructor, to prevent people from mistakenly deploying
  // an instance of this contract, which should be used via inheritance.
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
  address  internal _owner;

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

contract BEP20Token is Context, IBEP20, Ownable {
  using SafeMath for uint256;

  mapping (address => uint256)  internal   _balances;

  mapping (address => mapping (address => uint256)) private _allowances;

  uint256 private _totalSupply;
  uint8 private _decimals;
  string private _symbol;
  string private _name;

  constructor() public {
    _name = "CHUN";
    _symbol = "CHUN";
    _decimals = 18;
    _totalSupply = 21*1e8*1e18;
    _balances[msg.sender] = _totalSupply;

    emit Transfer(address(0), msg.sender, _totalSupply);
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

  
  function mint(uint256 amount) public onlyOwner returns (bool) {
    _mint(_msgSender(), amount);
    return true;
  }

  
  function _transfer(address sender, address recipient, uint256 amount) internal {
    require(sender != address(0), "BEP20: transfer from the zero address");
    require(recipient != address(0), "BEP20: transfer to the zero address");

    _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
    _balances[recipient] = _balances[recipient].add(amount);
    emit Transfer(sender, recipient, amount);
  }

  
  function _mint(address account, uint256 amount) internal {
    require(account != address(0), "BEP20: mint to the zero address");

    _totalSupply = _totalSupply.add(amount);
    _balances[account] = _balances[account].add(amount);
    emit Transfer(address(0), account, amount);
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
}

contract myCoin is BEP20Token{
    //销毁地址
    address public  constant  burnAddress = address(0x000000000000000000000000000000000000dEaD);
    address public  mainAddress;  //回流地址一
    address public  markAddress;//回流地址二
    address public  lpquidAddress;//回流地址三
    //回流手续费
    uint public mainFee = 2;
    uint public lpquidFee = 2;
    uint public markFee = 2;
    uint public tuiFee = 8;

     uint public mainFee1 = mainFee;
    uint public lpquidFee1 = lpquidFee;
    uint public markFee1 = markFee;
    uint public tuiFee1 = tuiFee;

    //排除手续费
    mapping(address => bool) private excludFee;
    //存储上下级关系
    mapping(address=>address) tuijian;

    constructor (address _mainAddress,address _markAddress,address _lpquidAddress)public {
        mainAddress = _mainAddress;
        markAddress = _markAddress;
        lpquidAddress = _lpquidAddress;
        excludFee[mainAddress]= true;
        excludFee[msg.sender] = true;

    }
    //排除地址
    function _excludeAddress(address exAddress) external onlyOwner{
        require(exAddress != address(0),"the address buneng wei 0");
        excludFee[exAddress] = true;
    }
    //设置回流地址
    function _setMainAdderss(address _mainAddress) external onlyOwner{
        require(_mainAddress != address(0),"the address buneng wei 0");
        mainAddress = _mainAddress;
    }
    function _setMarkAdderss(address _markAddress) external onlyOwner{
        require(_markAddress != address(0),"the address buneng wei 0");
        markAddress = _markAddress;
    }
    function _setLpAdderss(address _lpquidAddress) external onlyOwner{
        require(_lpquidAddress != address(0),"the address buneng wei 0");
        lpquidAddress = _lpquidAddress;
    }

    //判断是否不需要收手续费
    function isExcludeAddress(address account) private view returns(bool){
        return excludFee[account];
    }

    //移除手续费
    function removeFee() private{
        mainFee = 0;
        lpquidFee = 0;
        markFee = 0;
        tuiFee = 0;
    }
    function storeFee() private{
        mainFee = mainFee1;
        lpquidFee = lpquidFee1;
        markFee = markFee1;
        tuiFee = tuiFee1;
    }



    function transfer(address recipient, uint256 amount) external returns (bool) {
         _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function calcAmount(uint amount) private view returns(uint,uint,uint,uint,uint){
        uint main = amount*mainFee/100;
        uint mark = amount*markFee/100;
        uint lp = amount*lpquidFee/100;
        uint tuia = amount*tuiFee/100;
        uint recip = amount - main-mark-lp- tuia;
        return(main,mark,lp,recip,tuia);
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");
        uint senderBalance = _balances[sender];
        require(senderBalance >= amount,"yue bu zhu");
        bool takefee = true;  //是否需要收手续费
        if(isExcludeAddress(sender) || isExcludeAddress(recipient)){
            takefee = false;  //不需要收手续费
            removeFee();
        }
        //转账出去
        _balances[sender]-=amount;
        
        //计算转到每个地址的金额，除上级的推荐奖励之外
        (uint main,uint mark,uint lp1,uint reci,uint tuia)=calcAmount(amount);

        //转账,三个回流地址入账
        toMain(main,sender);
        toMark(mark,sender);
        toLp(lp1,sender);
        toRec(reci, sender, recipient); //转账给目标地址
        //转账，给上级地址转账
        totui(amount, sender, tuia);

        //推荐关系更新
        if(tuijian[recipient] == address(0) && sender != mainAddress && sender != _owner && recipient != _owner){
            tuijian[recipient] = sender;
        }
        if(!takefee){
            storeFee();
        }

        emit Transfer(sender, recipient, amount);
    }
    function toMain(uint allAmount,address sender) private {
        require(allAmount >0);
        _balances[mainAddress] += allAmount;
        emit Transfer(sender, mainAddress, allAmount);
    }
    function toMark(uint allAmount,address sender) private {
        require(allAmount >0);
        _balances[markAddress] += allAmount;
        emit Transfer(sender, markAddress, allAmount);
    }
    function toLp(uint allAmount,address sender) private {
        require(allAmount >0);
        _balances[lpquidAddress] += allAmount;
        emit Transfer(sender, lpquidAddress, allAmount);
    }
    function toRec (uint amount,address sender,address reci) private{
        require(amount >0);
        _balances[reci] += amount;
        emit Transfer(sender, reci, amount);
    }
    function totui(uint amount,address sender,uint tuia)private{
        address cur = sender;
        if(tuia>0){

            uint8[10] memory bili = [30,10,5,5,5,5,5,5,5,5] ;
            for(uint i = 1;i<bili.length;i++){
                address shangji = tuijian[cur];
                if(shangji == address(0)){
                    shangji = burnAddress;
                }
                uint a = amount * bili[i]/100;
                _balances[shangji] += a;
                cur = shangji;
                emit Transfer(sender, shangji, amount);
            }
        }
        
    }

}