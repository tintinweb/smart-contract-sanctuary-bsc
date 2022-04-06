/**
 *Submitted for verification at BscScan.com on 2022-04-06
*/

pragma solidity >=0.4.0 <0.8.0;


contract owned {
    uint256[] public level_commision;

    struct User {
        uint256 id;
        address myaddress;
        address sponsor;
        uint256 directs;      
        uint256 direct_income;
        uint256 total_commision;
        uint256 deposit_amount;
        uint256 payouts;
        uint40 deposit_time;        
    }

    constructor() public { 
        owner = msg.sender; 
        level_commision.push(1000); //1st generation 
        level_commision.push(250); //2nd generation 
        level_commision.push(100); //3rd generation  
        level_commision.push(100); //4th generation 
        level_commision.push(50); //5th generation 
        level_commision.push(50); //6th generation 
        level_commision.push(50); //7th generation 
        level_commision.push(50); //8th generation 
        level_commision.push(50); //9th generation 
        level_commision.push(50); //10th generation 

    }
    address payable owner;   
    modifier onlyOwner {
        require(
            msg.sender == owner,
            "Nothing For You!"
        );
        _;
    }
}
interface IERC20 {
        function totalSupply() external view returns (uint);
    
        function balanceOf(address account) external view returns (uint);
    
        function transfer(address recipient, uint amount) external returns (bool);
    
        function allowance(address owner, address spender) external view returns (uint);
    
        function approve(address spender, uint amount) external returns (bool);
    
        function increaseAllowance(address spender, uint amount) external returns (bool);
    
        function transferFrom(
            address sender,
            address recipient,
            uint amount
        ) external returns (bool);
    
        event Transfer(address indexed from, address indexed to, uint value);
        event Approval(address indexed owner, address indexed spender, uint value);
    }

contract plan is owned {
    IERC20 public stakingToken;    
    uint256 public min_tokens = 10000;
    uint256 public distribute_persent = 6;
    uint256 private plan_diveder = 100;

    mapping(address => User) public users;
    uint256 public total_users = 1; 

    constructor(IERC20 _stakingtoken) public {       
        stakingToken = _stakingtoken;
        users[msg.sender].id = total_users; 
        users[msg.sender].myaddress = msg.sender;        
    }

    function stak(address _upline, uint256 _tokens) public returns (bool){       

        _stak(_upline, _tokens); 
        return true;
    }

    address private upline;
    function _stak(address _upline, uint256 _tokens) internal {
        
        //stakingToken.transferFrom(msg.sender, address(this), _tokens * (10 ** 18));
        uint256 cashback = (_tokens * (10 ** 18)) * distribute_persent / 100;
        stakingToken.transfer(msg.sender, cashback);

        total_users++;

        users[msg.sender].id = total_users;
        users[msg.sender].myaddress = msg.sender;
        users[msg.sender].sponsor = _upline;
             
        users[msg.sender].deposit_time = uint40(block.timestamp);            
        
        users[_upline].directs++; 

        for (uint i = 0; i < 10; i++) {
            upline = users[upline].sponsor;
            if(upline != address(0)){
                users[upline].total_commision = users[upline].total_commision + level_commision[i];
            }            
        }
        
    }



}