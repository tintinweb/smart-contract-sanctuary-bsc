/**
 *Submitted for verification at BscScan.com on 2022-03-11
*/

pragma solidity >=0.5.0 <0.6.0;

interface ERC20 {


 function balanceOf(address _owner) external view returns (uint balance);
 function transfer(address _to, uint _value) external returns (bool success);
 function transferFrom(address _from, address _to, uint _value) external returns (bool success);
 function approve(address _spender, uint _value) external returns (bool success);
 function allowance(address _owner, address _spender) external view returns (uint remaining);

}
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

    function max64(uint64 a, uint64 b) internal pure returns (uint64) {
        return a >= b ? a : b;
    }

    function min64(uint64 a, uint64 b) internal pure returns (uint64) {
        return a < b ? a : b;
    }

    function max256(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min256(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}

contract tran{
    
     using SafeMath for uint256;
    uint256 public count = 1;
    uint256 public Timecount = 3;
    uint256 public Time = 5 minutes;
    uint256 public STime = 1 hours;
    address public owner;
    address  project_address;
    uint256 public number;  //每次需要入金的数量
    uint256 public all_number;//总奖池金额
    mapping (uint256 => address[]) public gameplayer;
    uint256 public endtime = now + 1 hours;
    address deadaddress = 0x000000000000000000000000000000000000dEaD;
    mapping(address => uint256) balances;
    mapping (uint256 => uint256) public timenumber;
    mapping (address => mapping(uint256 => uint256)) public my_number;
    mapping (address => mapping(uint256 => uint256)) public gameNumbers;
	ERC20 public erc;
      struct all_address{
            address addrs;
     }
     struct member{
            address agent;
            address last_agent;
     }
     mapping (address => member) public members;
	mapping (uint256 => all_address) public plays;
    constructor() public {
        owner = msg.sender;
        number = 100000000000;
        project_address = msg.sender;
       
	}

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    function setUsdt(address _usdt)onlyOwner public returns(bool) {
	    erc = ERC20(_usdt);
	    return true;
	}
       function setNumber(uint256 _number)onlyOwner public returns(bool) {
	    number = _number;
	    return true;
	}
       function setTimecount(uint256 _Timecount)onlyOwner public returns(bool) {
	    Timecount = _Timecount;
	    return true;
	}
     function setTime(uint256 _time)onlyOwner public returns(bool) {
	    Time = _time;
	    return true;
	}
     function setSTime(uint256 _stime)onlyOwner public returns(bool) {
	    STime = _stime;
	    return true;
	}
      function setproject_address(address _project_address)onlyOwner public returns(bool) {
	    project_address = _project_address;
	    return true;
	}
    //查询用户可提取的金额
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }
     //参与
     function play(address agent_address) public payable{
            require(count > 0);
            require(erc.balanceOf(msg.sender) >= number,"Sorry, your credit is running low");
            if(agent_address != address(0x0) && members[msg.sender].agent == address(0x0)){
             members[msg.sender].agent = agent_address;
             if(members[agent_address].agent != address(0x0)){
                 members[msg.sender].last_agent = members[agent_address].agent;
             }
            }
           
            uint256 synumber = 0;
            timenumber[count] = timenumber[count]+1;
            if(timenumber[count] <= Timecount){
            endtime =  endtime+Time;
            }
            if(members[msg.sender].agent != address(0x0)){
                synumber = number*2/100;
                balances[members[msg.sender].agent] =  balances[members[msg.sender].agent]+(number*2/100);
                if(members[msg.sender].last_agent != address(0x0)){
                     synumber = synumber + number*1/100;
                     balances[members[msg.sender].last_agent] =  balances[members[msg.sender].last_agent]+(number*1/100);
                }
            }
             all_number = all_number+number-synumber;
              if(check_gameplayer(count,msg.sender) == false){
                 gameplayer[count].push(msg.sender);
              }
               tranFrom(msg.sender,address(this),number);
               gameNumbers[msg.sender][count] = now;
               my_number[msg.sender][count] = my_number[msg.sender][count]+number;

     }
      function tranFrom(address _addr1,address _addr2,uint256 _amount) private{
        erc.transferFrom(_addr1,_addr2,_amount);
    }
    //获取top6 会返回全部只显示6个
    function getTop6(uint256 _num) public view returns(address[] memory) {
        address[] memory addrs;
        if(gameplayer[_num].length<=0){
            return addrs;
        }
        addrs = gameplayer[_num];
        address temp;
        for(uint i=0;i<addrs.length-1;i++){
            for(uint j;j<addrs.length-i-1;j++){
                if(gameNumbers[addrs[j+1]][_num]>gameNumbers[addrs[j]][_num]){
                    temp = addrs[j];
                    addrs[j] = addrs[j+1];
                    addrs[j+1] = temp;
                }
            }
        }
        return addrs;
    }
    function check_gameplayer(uint256 _num,address _address) private view returns (bool){
        for(uint i=0;i<gameplayer[_num].length;i++){
             if(_address == gameplayer[_num][i]){
               return true;
             }
        }
        return false;
    }
    //提币接口
    function withdraw()public returns(bool) {
        require(balances[msg.sender] >= 0 );
           erc.transfer(msg.sender,balances[msg.sender]);
           balances[msg.sender] = 0;
           return true;
    }
      //开始新的一期接口 此处需要判断是否为owner 不是的话不显示按钮
     function start() onlyOwner public returns(bool) { 
       address[] memory top6 = getTop6(count);
        if(top6.length > 0){
            uint256 rewards =  (all_number*5/100);
           
            
             for(uint8 i=1;i<top6.length;i++){
                  if(i < 5){//2到6的地址有分润  总共5个
                          balances[top6[i]] =  balances[top6[i]]+(rewards/5);
                  }
             }
         }
        uint256 project_rewards = all_number*2/100;
       
        balances[project_address] =  balances[project_address]+project_rewards;
      
        uint256 dead_number = all_number*10/100;
        erc.transfer(deadaddress,dead_number);
        balances[top6[0]] =  balances[top6[0]]+all_number*83/100;
        count = count+1;
        all_number = 0;
        endtime = now+ STime;
	    return true;
	}

   
   

    
 
   

    
    
    
}