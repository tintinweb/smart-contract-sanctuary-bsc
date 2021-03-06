/**
 *Submitted for verification at BscScan.com on 2021-12-12
*/

pragma solidity >=0.5.0 <0.6.0;

interface ERC20 {


 function balanceOf(address _owner) external view returns (uint balance);
 function transfer(address _to, uint _value) external returns (bool success);
 function transferFrom(address _from, address _to, uint _value) external returns (bool success);
 function approve(address _spender, uint _value) external returns (bool success);
 function allowance(address _owner, address _spender) external view returns (uint remaining);

}

contract tran{
    
    address public F;
     
    struct Play{
      
        address  agent;
        uint256 sell_time;
        uint256 number;
        uint256 buy_time;
        bool is_buy;
        bool is_first;
        uint256 sell_count;
    }
      struct Agent{
        uint256 number;
        uint256 sell_count;
    }
       uint256 rate;
       mapping (address => Play) public plays;
       mapping (address => Agent) public agents;
      mapping (address => bool) public isIng;
      address public contract_address;
      address public usdt_contract_address;
     address public owner;
    constructor() public {
        owner = msg.sender;
   
	}

      modifier onlyOwner() {
        require(msg.sender == owner);
        _;
     }	
       function getBalanceERC() public returns(uint256){
        ERC20 erc = ERC20(contract_address);
        return erc.balanceOf(address(this));
    }

      function setcontract_rate(uint256 _rate) onlyOwner public returns(bool) {
        rate = _rate;
       return true;
      }
    function setusdtcontract_address(address _usdt) onlyOwner public returns(bool) {
        usdt_contract_address = _usdt;
       return true;
      }
     function setcontract_address(address _newaddress) onlyOwner public returns(bool) {
        contract_address = _newaddress;
       return true;
      }
      function sell_token(uint256 token_price) public returns(bool){
          require(plays[msg.sender].sell_time <= now);
          require(token_price != 0);
          require(agents[msg.sender].number > 0);

          //??????????????????????????????
          plays[msg.sender].is_buy = false; 
          //????????????????????????????????????
          plays[msg.sender].buy_time = now + 24 hours;
          //???????????????1 ???????????????????????? ??????1
          if(agents[msg.sender].number != 100){
              agents[msg.sender].sell_count = agents[msg.sender].sell_count - 1;
          }
          require(agents[msg.sender].sell_count != 0);
           plays[msg.sender].sell_count = plays[msg.sender].sell_count+1;
          //??????????????????????????????
          ERC20 erc = ERC20(contract_address);
          erc.transferFrom(msg.sender,address(this), plays[msg.sender].number);
          //?????????????????????????????????usdt
          uint256 all_price = plays[msg.sender].number * token_price;
          ERC20 erc1 = ERC20(usdt_contract_address);
          erc1.transfer(msg.sender,all_price);
          return true;  
      }
      function buy_token(address agent,uint256 number,uint256 token_price)  public returns(bool) {
          
          uint256 sell_time = now + 24 hours;
          require(plays[msg.sender].number == 0);
          require(!plays[msg.sender].is_buy);
          if(plays[msg.sender].agent ==address(0x0)){
               //??????????????????????????????????????????
                  plays[msg.sender].agent = agent;
                    agents[agent].number = plays[agent].number + 1;
                    if(agents[agent].number == 1){
                        agents[agent].sell_count = 1;
                    }else if(agents[agent].number == 2){
                        agents[agent].sell_count = 3 - plays[agent].sell_count;
                    }else if(agents[agent].number >= 3 && agents[agent].number <= 5){
                          agents[agent].sell_count = 6- plays[agent].sell_count;
                    }else if(plays[agent].number > 5 && agents[agent].number <= 10){
                         agents[agent].sell_count = 10 - plays[agent].sell_count;
                    }else if(plays[agent].number > 10){
                         agents[agent].sell_count = 100;
                    }
          }
     
          plays[msg.sender].sell_time = sell_time;
          plays[msg.sender].number = number;
          plays[msg.sender].is_buy = true;
          if(!plays[msg.sender].is_first){
              uint256 all_price = number*token_price;
          }else{
              //???????????????????????????????????????????????????
               require(plays[msg.sender].buy_time <= now);
              uint256 all_price = number*token_price*rate/100;
          }
          //????????????usdt?????????
          ERC20 erc1 = ERC20(usdt_contract_address);
          erc1.transferFrom(msg.sender,address(this), plays[msg.sender].number);
          //???????????????????????????
          ERC20 erc = ERC20(contract_address);
          erc.transfer(msg.sender,number);
          return true;
    }
 
     
 
    
    
}