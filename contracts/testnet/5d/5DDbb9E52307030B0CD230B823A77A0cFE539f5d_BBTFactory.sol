/**
 *Submitted for verification at BscScan.com on 2022-05-14
*/

//便携式开发者平台《比特熊》
//////www.bitbear.info////////
// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.4;

interface IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
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

library Address {

    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }


}

contract BBTFactory {
     mapping(address => address)getToken;
     uint256 public acounts;

    function creatNewToken(string memory _names,string memory _symbles, uint8 _decimals, uint256 _totals) external returns(address) {
       BitBearTOKEN Ftoken = new BitBearTOKEN(_names,_symbles,_decimals,_totals,msg.sender);
        getToken[msg.sender] = address(Ftoken);
        acounts++;
        return address(Ftoken);
    }

    function TokenAddr(address account) external view returns(address){
    return getToken[account];  
    }
}

contract BitBearTOKEN is IERC20  {
    using SafeMath for uint256;
    using Address for address;

    string  internal _name;
    string  internal _symbol;
    uint8   internal _decimals;
    uint256 internal  _totalSupply;
    
    mapping (address => uint256) internal _balanceOf;
    mapping (address => mapping(address => uint256)) internal _allowance;

    address internal _owner;

    modifier onlyOwner { require(msg.sender == _owner); _;}
   

    constructor(string memory names, string memory symbols, uint8 dec, uint256 total,address owners) {
        _name = names;
        _symbol = symbols;
        _decimals = dec;
        _totalSupply = total * (10**_decimals);
        _owner = owners;
     
        _balanceOf[owners] = _totalSupply;
        emit Transfer (address(0) ,_owner , _totalSupply);
    }

 

    //////////////////////ERC20 VIEW///////////////////////
    function name() external  override view returns (string memory){ return _name;}
    function symbol() external override  view returns (string memory){return _symbol;}
    function decimals() external override view returns (uint8){return _decimals;}
    function owner() external view returns(address){return _owner;}
    function totalSupply() public override view returns (uint256){return _totalSupply;}
    function balanceOf(address account) public override view returns (uint256){return _balanceOf[account];}
    function approve(address spender, uint256 amount) external override returns (bool){
        _approve(msg.sender, spender, amount);
        return true;
    }
    function _approve(address sender, address spender, uint256 amounts) private {
         require(sender != address(0), "ERC20: approve from the zero address");
         require(spender != address(0), "ERC20: approve to the zero address");
         require(balanceOf(msg.sender) >= amounts);
        _allowance[sender][spender] = amounts;
        emit Approval(sender, spender, amounts);

    }
     function allowance(address owners, address spender) external override view returns (uint256){
         return _allowance[owners][spender];
    }
    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool){
        require(_balanceOf[sender] >= amount , 'IS NOT ENOUGH');
        require(sender != (address(0)), "is address 0");

         uint256 allowancess = _allowance[sender][msg.sender];
         require(allowancess >= amount);
         unchecked{_allowance[sender][msg.sender] = _allowance[sender][msg.sender].sub(amount);}

        _transfer(sender, recipient, amount);
        return true;
    }
   
    function transfer(address recipient, uint256 amount) external override returns (bool){
        require(msg.sender != address(0));
        require(_balanceOf[msg.sender] >= amount , "is not enough");
        _transfer(msg.sender, recipient , amount);
        return true;
    }

    //////////////////////TRANSFER///////////////////////
    function _transfer(address from , address  to ,uint256 amount) internal returns(bool) {
        unchecked{_balanceOf[from] = _balanceOf[from] .sub(amount);}
        unchecked{_balanceOf[to] = _balanceOf[to] .add(amount);}
        emit Transfer(from , to , amount);
       return true;
    }
}