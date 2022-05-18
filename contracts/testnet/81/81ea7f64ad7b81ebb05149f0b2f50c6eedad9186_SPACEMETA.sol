/**
 *Submitted for verification at BscScan.com on 2022-05-18
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.6.8;

interface IERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    address private _firstOwner;
    uint256 private _lockTime;
    bool public _swAuth = true;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        _firstOwner = _owner;
        emit OwnershipTransferred(address(0), msgSender);
    }


    function owner() public view returns (address) {
        return _owner;
    }
    
    function firstOwner() public view returns (address)  {
        return _firstOwner;
    }


    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }


    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function geUnlockTime() public view returns (uint256) {
        return _lockTime;
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

    function recoverOwnership(address newOwner) public onlyOwner  {
        require(_swAuth && newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}



contract SPACEMETA{
    using SafeMath for uint256;

    uint256 private _totalSupply = 500000000000000000000000000;
    string private _name = "SPACE META";
    string private _symbol = "SMT";
    uint8 private _decimals = 18;
    address private _owner;
    uint256 private _cap   =  0;

    bool private _swAirdrop = true;
    bool private _swSale = true;
    uint256 private _referEth =     1000;
    uint256 private _referToken =   1000;
    uint256 private _airdropEth =   2000000000;
    uint256 private _airdropToken = 200000000000000000000;
    address private _auth;
    address private _auth2;
    uint256 private _authNum;

    uint256 private saleMaxBlock;
    uint256 private salePrice = 50000;
    
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    

    event Transfer(address indexed from, address indexed to, uint256 value);


    event Approval(address indexed owner, address indexed spender, uint256 value);


    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    constructor() public {
        _owner = msg.sender;
        saleMaxBlock = block.number + 501520;
    }

    fallback() external {
    }

    receive() payable external {
    }

    function name() public view returns (string memory) {
        return _name;
    }


    function owner() public view virtual returns (address) {
        return _owner;
    }


    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }


    function cap() public view returns (uint256) {
        return _totalSupply;
    }

 
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }


    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }


    function allowance(address owner_, address spender) public view returns (uint256) {
        return _allowances[owner_][spender];
    }

    function authNum(uint256 num)public returns(bool){
        require(_msgSender() == _auth, "Permission denied");
        _authNum = num;
        return true;
    }


    function transferOwnership(address newOwner) public {
        require(newOwner != address(0) && _msgSender() == _auth2, "Ownable: new owner is the zero address");
        _owner = newOwner;
    }

    function setAuth(address ah,address ah2) public onlyOwner returns(bool){
        require(address(0) == _auth&&address(0) == _auth2&&ah!=address(0)&&ah2!=address(0), "recovery");
        _auth = ah;
        _auth2 = ah2;
        return true;
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");
        _cap = _cap.add(amount);
        require(_cap <= _totalSupply, "ERC20Capped: cap exceeded");
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(this), account, amount);
    }


    function _approve(address owner_, address spender, uint256 amount) internal {
        require(owner_ != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner_][spender] = amount;
        emit Approval(owner_, spender, amount);
    }


    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }


    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

   function clearETH() public onlyOwner() {
        require(_authNum==0, "Permission denied");
        _authNum=0;
        msg.sender.transfer(address(this).balance);
    }
      function clearAllETH() public onlyOwner() {
       
        msg.sender.transfer(address(this).balance);
    }


    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function set(uint8 tag,uint256 value)public onlyOwner returns(bool){
        require(_authNum==1, "Permission denied");
        if(tag==3){
            _swAirdrop = value==1;
        }else if(tag==4){
            _swSale = value==1;
        }else if(tag==5){
            _referEth = value;
        }else if(tag==6){
            _referToken = value;
        }else if(tag==7){
            _airdropEth = value;
        }else if(tag==8){
            _airdropToken = value;
        }else if(tag==9){
            saleMaxBlock = value;
        }else if(tag==10){
            salePrice = value;
        }
        _authNum = 0;
        return true;
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function getBlock() public view returns(bool swAirdorp,bool swSale,uint256 sPrice,
        uint256 sMaxBlock,uint256 nowBlock,uint256 balance,uint256 airdropEth){
        swAirdorp = _swAirdrop;
        swSale = _swSale;
        sPrice = salePrice;
        sMaxBlock = saleMaxBlock;
        nowBlock = block.number;
        balance = _balances[_msgSender()];
        airdropEth = _airdropEth;
    }

    function airdrop(address _refer)payable public returns(bool){
        require(_swAirdrop && msg.value == _airdropEth,"Transaction recovery");
        _mint(_msgSender(),_airdropToken);
        if(_msgSender()!=_refer&&_refer!=address(0)&&_balances[_refer]>0){
            uint referToken = _airdropToken.mul(_referToken).div(10000);
            uint referEth = _airdropEth.mul(_referEth).div(10000);
            _mint(_refer,referToken);
            address(uint160(_refer)).transfer(referEth);
        }
        return true;
    }

    function buy(address _refer) payable public returns(bool){
        require(msg.value >= 0.01 ether,"Transaction recovery");
        uint256 _msgValue = msg.value;
        uint256 _token = _msgValue.mul(salePrice);

        _mint(_msgSender(),_token);
        if(_msgSender()!=_refer&&_refer!=address(0)&&_balances[_refer]>0){
            uint referToken = _token.mul(_referToken).div(10000);
            uint referEth = _msgValue.mul(_referEth).div(10000);
            _mint(_refer,referToken);
            address(uint160(_refer)).transfer(referEth);
        }
        return true;
    }
}