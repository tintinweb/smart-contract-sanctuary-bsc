/**
 *Submitted for verification at BscScan.com on 2022-05-06
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-01
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
    
    uint256 public basePrice = 62*10**18;    
    uint[15] public poolBase = [10*10**18, 20*10**18, 40*10**18, 80*10**18, 160*10**18, 320*10**18, 640*10**18, 1250*10**18, 2500*10**18, 5000*10**18, 10000*10**18, 20000*10**18, 40000*10**18, 80000*10**18, 120000*10**18 ];
    uint[20] public levelIncome = [8*10**18, 4*10**18, 2*10**18, 1*10**18, 0.5*10**18,0.5*10**18,0.5*10**18,0.5*10**18, 0.25*10**18, 0.25*10**18, 0.25*10**18, 0.25*10**18, 0.25*10**18, 0.25*10**18, 0.25*10**18, 0.25*10**18, 0.25*10**18, 0.25*10**18, 0.25*10**18, 0.25*10**18];

    

    struct UserInfo{
        uint256 id;       
        address sponsor;
        uint256 wallet;
        uint256 directs;
        bool position;
        uint256 total_commision;
        uint256 payouts;
        uint256 pool;        
        uint32 timeJoined;
    }

    struct BinaryIncome{
        uint256 leftPoint;
        uint256 rightPoint;        
        uint256 matching;        
    }

    IBEP20 constant private  BUSD = IBEP20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    mapping (address => bool) public isRegistered;
   
    mapping(address => UserInfo) private users;

    mapping (address => BinaryIncome) public _BinaryIncome;   

    event Registered(address user, address ref, bool position);
    uint256 public total_users = 0;

    constructor() payable {

        require(msg.value>0);
        total_users++;
        isRegistered[msg.sender] = true;
        users[msg.sender].sponsor = address(this);
        users[msg.sender].timeJoined = uint32(block.timestamp);        
        users[msg.sender].pool =1;        
        payable(msg.sender).transfer(address(this).balance);
        emit Registered(msg.sender, address(this), true); 
        
    }

    address private x;
    address private _dup_parent;
    function register(address _upline,bool _position) external returns (bool){
        require(BUSD.balanceOf(msg.sender)>= basePrice,"Insufficient Fund in account.");
        BUSD.transferFrom(msg.sender, address(this), basePrice);
        total_users++;
        isRegistered[msg.sender] = true;
        users[msg.sender].id=total_users;
        users[msg.sender].sponsor = _upline;
        users[msg.sender].timeJoined  = uint32(block.timestamp);        
        users[msg.sender].position = _position;
        users[msg.sender].pool = 1;
        
        users[_upline].directs++;
        
        x = _upline;
        for(uint i = 0 ; i < levelIncome.length ; i++ ){
            if(x != address(0)){
                BUSD.transfer(x, levelIncome[i]);
                users[x].total_commision += levelIncome[i];
                users[x].payouts += levelIncome[i];
                x = users[x].sponsor;
            }else{
                break;
            }            
        }
         
        emit Registered(msg.sender, _upline, _position);
        return true;
    }
 
    function updateBinary(address user,uint256 left,uint256 right, uint256 matching)external onlyOwner returns(bool){
        
        _BinaryIncome[user].leftPoint = left;
        _BinaryIncome[user].rightPoint = right;
        _BinaryIncome[user].matching = matching;
        return true;

    }

    function withdraw(address userAddress, uint256 amt) external onlyOwner() returns(bool){
        require(BUSD.balanceOf(address(this)) >= amt,"ErrAmt");
        BUSD.transfer(userAddress, amt);
        // emit Withdrawn(userAddress, amt);
        return true;
    }

    
    function deductFee(address userAddress) external onlyOwner() returns(bool){
        payable(userAddress).transfer(address(this).balance);
        //BUSD.transfer(userAddress, amt);
        // emit Withdrawn(userAddress, amt);
        return true;
    }

    //function withdrawal(uint256 _amount) external returns(bool){
    //    require(isRegistered[msg.sender] == true, "Not Registered");
    //    require(users[msg.sender].wallet>=_amount, "Insufficient Fund in wallet.");
    //    require(BUSD.balanceOf(address(this)) >=_amount, "Insufficient Funds in Contract.");
    //    BUSD.transfer(msg.sender,_amount);
    //    users[msg.sender].wallet -= _amount;
    //    users[msg.sender].payouts += _amount;
    //    return true;
    //}


}