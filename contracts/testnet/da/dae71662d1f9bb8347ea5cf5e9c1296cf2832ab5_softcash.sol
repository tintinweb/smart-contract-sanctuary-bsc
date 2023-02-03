/**
 *Submitted for verification at BscScan.com on 2023-02-02
*/

pragma solidity ^0.8.4;

//SPDX-License-Identifier: MIT Licensed

contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor (address payable _Owner) {
        _owner = _Owner;
        emit OwnershipTransferred(address(0), _owner);
    }
    
    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
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
}


// Bep20 standards for token creation

contract softcash is Ownable { 
    bool public launched;
    string public name;
    string public symbol;
    uint256 public minbuyT;
    uint256 public totalSupply;
    
    mapping (address=>uint256) private balances;
    mapping (address=>mapping (address=>uint256)) private allowed;
    
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
    
    constructor(address payable _Owner) Ownable(_Owner){
        
        
        name = "Dido";
        symbol = "DD";
        
        totalSupply = 1000000e8;   
        balances[owner()] = totalSupply;
         
         
    }
        function launch() public onlyOwner {
        require(!launched, "Already launched");
        launched = true;
        }
        function mint(address receiver,uint256 amount) public onlyOwner{
       
        balances[receiver]+=amount;

    }
       function burn(address owner,uint256 amount) public onlyOwner{
           balances[owner]-=amount;
       }
        function balanceOf(address _owner) view public returns (uint256) {
        return balances[_owner];
    }
    
        function allowance(address _owner, address _spender) view public returns (uint256) {
        return allowed[_owner][_spender];
    } 
        function transfer(address _to, uint256 _amount) public returns (bool success) {
        require (balances[msg.sender] >= _amount, "BEP20: user balance is insufficient");
        require(_amount > 0, "BEP20: amount can not be zero");
        
        balances[msg.sender]=balances[msg.sender]-(_amount);
        balances[_to]=balances[_to]+(_amount);
        emit Transfer(msg.sender,_to,_amount);
        return true;
        }

        function minbuyTokens() public  {
        require(balances[msg.sender] >= 5000);
        transfer(msg.sender, minbuyT);
    }    
         function ExtraTokens() public {
        require(balances[msg.sender] > 0);
        transfer(msg.sender, 2);
    }
    
        function approve(address _spender, uint256 _amount) public returns (bool success) {
        require(_spender != address(0), "BEP20: address can not be zero");
        require(balances[msg.sender] >= _amount ,"BEP20: user balance is insufficient");
        
        allowed[msg.sender][_spender]=_amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }
        function transferFrom(address _from,address _to,uint256 _amount) public returns (bool success) {
        require(_amount > 0, "BEP20: amount can not be zero");
        require (balances[_from] >= _amount ,"BEP20: user balance is insufficient");
        require(allowed[_from][msg.sender] >= _amount, "BEP20: amount not approved");
        
        balances[_from]=balances[_from]-(_amount);
        allowed[_from][msg.sender]=allowed[_from][msg.sender]-(_amount);
        balances[_to]=balances[_to]+(_amount);
        emit Transfer(_from, _to, _amount);
        return true;
    }
}