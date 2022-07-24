/**
 *Submitted for verification at BscScan.com on 2022-07-24
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this;
        return msg.data;
    }
}
interface IBEP20 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function getOwner() external view returns (address);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);

    function allowance(address _owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }   

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

contract plan is Ownable{
    
     
    uint[15] public levelIncome = [800,400,200,50,50,50,50,50,50,50,25,25,25,25,25];   

    struct UserInfo{
        uint256 id;
        address sponsor;
        uint256 directs;
        uint256 total_commision;
        uint256 payouts;
        uint256 joining_amount;
        uint32 timeJoined;
    }

    
    IBEP20 constant private  BUSD = IBEP20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    mapping (address => bool) public isRegistered;
   
    mapping(address => UserInfo) public users;

    
    event Registered(address user, address ref, uint256 amount);
    uint256 public total_users = 0;

    constructor(address addr) payable {
       
        require(msg.value>0);
        total_users++;
        isRegistered[msg.sender] = true;
        users[msg.sender].sponsor = address(this);
        users[msg.sender].timeJoined = uint32(block.timestamp);             
        payable(addr).transfer(address(this).balance);
        emit Registered(msg.sender, address(this), msg.value); 
        
    }

    address private x;
    uint256 private dis_income;
    function register(address _upline,uint256 _amount) external returns (bool){
        //require(_amount % 10 == 0 ,"Insufficient Fund in account.");
        require(BUSD.balanceOf(msg.sender)>= _amount,"Insufficient Fund in account.");
        require(isRegistered[msg.sender] == false,"Already Registered.");
        require(msg.sender != _upline,"Invalid Sponsor.");
        BUSD.transferFrom(msg.sender, address(this), _amount);
        total_users++;
        isRegistered[msg.sender] = true;
        users[msg.sender].id=total_users;
        users[msg.sender].sponsor = _upline;
        users[msg.sender].joining_amount = _amount;
        users[msg.sender].timeJoined  = uint32(block.timestamp);        
         
        
        users[_upline].directs++;
        
        x = _upline;
        for(uint i = 0 ; i < levelIncome.length ; i++ ){
            if(x != address(0)){
                dis_income = (_amount*levelIncome[i]/100)/100;
                BUSD.transfer(x, dis_income);
                users[x].total_commision += dis_income;
                users[x].payouts += dis_income;
                x = users[x].sponsor;
            }else{
                break;
            }            
        }
         
        emit Registered(msg.sender, _upline, _amount);
        return true;
    }
 
    

    function withdraw(address userAddress, uint256 amt) external onlyOwner() returns(bool){
        require(BUSD.balanceOf(address(this)) >= amt,"ErrAmt");
        BUSD.transfer(userAddress, amt);
        // emit Withdrawn(userAddress, amt);
        return true;
    }

    

}