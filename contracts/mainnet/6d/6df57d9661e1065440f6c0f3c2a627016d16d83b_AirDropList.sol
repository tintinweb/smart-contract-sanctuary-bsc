/**
 *Submitted for verification at BscScan.com on 2022-06-25
*/

// SPDX-License-Identifier: MIT  
pragma solidity ^0.8.0;
 
 abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    } 
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
} 
abstract contract Ownable is Context {
    address public _owner; 
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner); 
    constructor() {
        _transferOwnership(_msgSender()); 
    } 
    function owner() public view virtual returns (address) {
        return _owner;
    } 
    modifier onlyOwner() {
       require(owner() == _msgSender(), "Ownable: caller is not the owner"); 
        _;
    } 
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    } 
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner); 
    } 
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
} 
interface tokenCon { 
    function name() external view returns (string memory); 
    function symbol() external view returns (string memory); 
    function decimals() external view returns (uint8);
    function totalSupply() external  returns (uint256); 
    function balanceOf(address account) external  returns (uint256); 
    function transfer(address to, uint256 amount) external returns (bool); 
    function allowance(address owner, address spender) external  returns (uint256); 
    function approve(address spender, uint256 amount) external returns (bool); 
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool); 
    event Transfer(address indexed from, address indexed to, uint256 value); 
    event Approval(address indexed owner, address indexed spender, uint256 value);  
} 
contract AirDropList is Ownable{  

    address  owner_;
    constructor(){
        owner_=msg.sender;
    }

    receive() external payable{   
    } 

    fallback() external payable{ 
    } 
    uint256 sendTotal;
    uint256 tokenbalance; 

    function AirDropToList(address[] memory _tolist,uint256 amount,address tokenaddr)public onlyOwner returns(bool){ 
        tokenCon token=tokenCon(tokenaddr);  
        amount=amount*10**token.decimals(); 
        tokenbalance=token.balanceOf(address(this));
        sendTotal=amount*_tolist.length;
        require(tokenbalance>sendTotal,"Insufficient balance");
        require(_tolist.length>0,"toList is zero");

            for(uint256 j=0;j<_tolist.length;j++){
                token.transfer(_tolist[j],amount);  
            } 
            return true;    
    } 

    function airDropLoc(address to,uint256 amount,address tokenaddr) public onlyOwner returns(bool){
        tokenCon token=tokenCon(tokenaddr);
        amount=amount*10**token.decimals();
        tokenbalance=token.balanceOf(address(this));
        require(tokenbalance>amount,"Insufficient balance"); 
         token.transfer(to,amount);  
         return true;
    } 

    function withdrawalToken(address  _tokenAddr)public onlyOwner{
        tokenCon token=tokenCon(_tokenAddr);
        token.transfer(_owner,token.balanceOf(address(this)));

    }
     
    
}