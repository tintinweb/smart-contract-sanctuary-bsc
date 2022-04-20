pragma solidity ^0.5.0;


import "./SafeMath.sol";

interface ERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract FQPool    {
    
    using SafeMath for uint256;
    uint256  total_deposits; 
    uint256  total_deposits_0; 
    uint256  total_deposits_1; 
    uint256  total_deposits_2; 
    uint256  total_deposits_3;  

    address  lptoken= 0xd2020779472a84E22E5491380dcaca10168D0957;

    ERC20 y=ERC20(lptoken);
    
    address owner;
    
	struct User {
        uint256 deposit_time;
        uint256 deposit_endtime;
        uint256 deposit_days;
        uint256 deposit_lpqty;		
        address leader;
        uint256 level;
    }    
    
    constructor() public{
        owner=msg.sender;
    }
    
    modifier admin{
        require(owner==msg.sender,"no permission");
        _;
    }

    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    
    mapping(address => User)   users;

    function stake(uint256 level,address tj, uint256 amount) public   { 
        require(amount > 0, "cannot stake 0!");
        require(tj!=msg.sender, "self can't leader!");
        require(tj != address(0), "referee not empty!");
        require(users[msg.sender].deposit_lpqty==0, " address is despoited,cannot repeat !");

        users[msg.sender].deposit_time = block.timestamp;
        users[msg.sender].level=level;
        users[msg.sender].deposit_lpqty+=amount;
     
        users[msg.sender].leader=tj;
        if (users[msg.sender].level==1)
        {
           users[msg.sender].deposit_endtime = users[msg.sender].deposit_time.add(30 days);
           users[msg.sender].deposit_days=30;
           total_deposits_1+=amount;
        }
        else if (users[msg.sender].level==2)
        {
           users[msg.sender].deposit_endtime = users[msg.sender].deposit_time.add(60 days);
           users[msg.sender].deposit_days=60;
           total_deposits_2+=amount;
        }
        else if (users[msg.sender].level==3)
        {
           users[msg.sender].deposit_endtime = users[msg.sender].deposit_time.add(90 days);
           users[msg.sender].deposit_days=90;
           total_deposits_3+=amount;
        } 
        else {
           total_deposits_0+=amount;
        }       
 
        total_deposits+=amount;
 
        // y.transferFrom(msg.sender,address(this),amount);
        emit Staked(msg.sender, amount);
    }

    function totalSupply() public view returns(uint256)
    {
        return total_deposits;
    }

    function withdraw(address _address) public {
        uint256 amount=users[_address].deposit_lpqty;

        require(amount > 0, "no deposit ");
        require(block.timestamp >= users[_address].deposit_endtime, "deposit unexpired ");
            
 
        users[_address].deposit_lpqty =0;
        users[_address].deposit_time=0;
        users[_address].deposit_endtime=0;
        users[_address].deposit_days=0;
        users[_address].level=0; 
        users[_address].leader=address(0);       

        total_deposits -= amount;
 

        y.transfer(msg.sender,amount);
        emit Withdrawn(msg.sender, amount);
    }    


    function setlpaddress(address _address) public admin {
        require(_address!=address(0),"lp address not empty!");
        lptoken=_address;
    }  

    function updateuserleader(address _user,address _leader) public admin {
        require(_user!=address(0),"address not empty!"); 
        require(_user!=_leader,"not allowed!"); 
        users[_user].leader=_leader;
    }  

   

    function getlp(address _address) public view returns(uint256 a)
    {
        a=y.balanceOf(_address);
    }

    function getlps() public view returns(uint256)
    {
        return y.totalSupply();
    }       


    function userpercent(address _address)  public view returns(uint256)
    {
        if (users[_address].deposit_lpqty==0)
        {
            return 0;
        }

        uint256 t=users[_address].level;
        uint256 c;
        if (t==1)
        {
            c=total_deposits_1;
        }
        else if (t==2)
        {
            c=total_deposits_2;
        }  
        else if (t==3)
        {
            c=total_deposits_3;
        }
        else 
        {
            c=total_deposits_0;
        }              
        return users[_address].deposit_lpqty*10**6/c;
    }

    function userinfo(address _address) public view returns(uint256 deposit_time,uint256 deposit_endtime,
        uint256 deposit_lpqty,address leader,uint256 deposit_days,uint256 level)
    {
        deposit_lpqty=users[_address].deposit_lpqty;
        deposit_time=users[_address].deposit_time;
        deposit_endtime=users[_address].deposit_endtime;
        deposit_days=users[_address].deposit_days;
        leader=users[_address].leader;   
        level=users[_address].level;
    }

    function deposits_mint() public view returns(uint256 c0,uint256 c1,uint256 c2,uint256 c3,uint256 total)
    {
        c0=total_deposits_0;
        c1=total_deposits_1;
        c2=total_deposits_2;
        c3=total_deposits_3;
        total=total_deposits;

    }

 
   
}