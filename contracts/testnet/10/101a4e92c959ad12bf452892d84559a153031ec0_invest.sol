/**
 *Submitted for verification at BscScan.com on 2022-05-12
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract invest {

    struct User {
        uint256 invested_amount;
        uint256 profit;
        uint256 profit_withdrawn;
        uint256 start_time;
        uint256 exp_time;
        bool time_started;
    }

    mapping(address => User) public invest_map;
    uint256 liquifyLimit=1;
    uint256 count;
    function invest_fun() public payable {
        require(msg.value >= 0, "Please Enter Amount more than 0");
        require(liquifyLimit < address(this).balance,"it's cross liquifyLimit that is 1 eth");
        count++;
        if (invest_map[msg.sender].time_started == false) {
            invest_map[msg.sender].start_time = block.timestamp;
            invest_map[msg.sender].time_started = true;
            invest_map[msg.sender].exp_time = block.timestamp + 86400;
        }
        // liquifyLimit = (msg.value / 1);
        invest_map[msg.sender].invested_amount += msg.value;
        invest_map[msg.sender].profit += ( (msg.value * 171 * 86400 ) / (1000000));
    }

    function current_profit() public view returns (uint256) {
        uint256 local_profit;
      if(block.timestamp <= invest_map[msg.sender].exp_time){
          if((block.timestamp - invest_map[msg.sender].start_time / 86400) > 1){
             local_profit = ((invest_map[msg.sender].invested_amount) * (block.timestamp - invest_map[msg.sender].start_time) / 86400);
            //  return local_profit;
           
          }
      else{
           local_profit =0;
      }
      }
      
      return local_profit;
       
    }

    function withdraw() public payable returns(bool){
        uint256 current_profit = current_profit();
    
        payable(msg.sender).transfer(current_profit + invest_map[msg.sender].invested_amount);
        delete(invest_map[msg.sender]);
        return true;
    }


    function distribute() public payable returns(bool) {
        require(address(this).balance >=1,"balance is less then 1 eth");
       uint256 distbal= (address(this).balance * 171)/1000000;
       uint256 perpersonbal = distbal/count;
       payable(msg.sender).transfer(perpersonbal);
       return true;

    }
}