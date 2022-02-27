/**
 *Submitted for verification at BscScan.com on 2022-02-26
*/

// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.4; 
 
contract Stake_bnb{ 
        using SafeMath for uint256;
        uint256 public stake_hold = 0; 
        uint256 public stake_reward = 0; 
        address payable public secureAdress; 
        address public owner; 
        uint256 public minInvestments = (0.005 ether); 
        uint256 public maxInvestments = (100 ether); 
        uint256 public percentage = 15; 
        address payable contrato;

        // Adress de seguridad 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2
        // Adress de tesoreria 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db

        struct investor{ 
            uint256 balance_stake; 
            uint256 maxReward; 
            uint256 rewardNow; 
            uint256 rewardClaimed;
            uint256 lastUpdateTime; 
            bool status_stake;
        } 
        
        modifier Unicamente(address _address){
            require(_address == owner, "You do not have permissions for this function");
            _;
        }
 
        mapping(address => investor) public client; 
        
        constructor () { 
            secureAdress = payable(address(0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2)); 
            owner = msg.sender; 
            contrato = payable(address(this));
        } 

        function deposit(address _ref) payable public returns(bool){ 
            uint256 _amount = msg.value; 
            require(_amount >= minInvestments,"the value entered is less than the minimum for stake"); 
            require(_amount <= maxInvestments,"the value entered is less than the maximum for stake"); 
            uint256 fee = SafeMath.div(SafeMath.mul(_amount,30),100); 
            secureAdress.transfer(fee); 
            stake_hold += SafeMath.sub(_amount,fee);  
            client[msg.sender].lastUpdateTime = block.timestamp; 
            client[msg.sender].maxReward += SafeMath.div(SafeMath.mul(_amount,150),100);
            stake_reward += SafeMath.div(SafeMath.mul(_amount,150),100); 
            client[msg.sender].balance_stake = _amount; 
            client[msg.sender].status_stake = true;
            if(_ref != msg.sender){
                uint256 add_ref = SafeMath.div(SafeMath.mul(_amount,5),100); 
                client[_ref].rewardNow += add_ref;
            }
            return true; 
        } 

        function verBalance() public view returns ( uint256 ){
            return contrato.balance;
        }
 
        function withdraw() public returns (bool){ 
            uint256 balance = contrato.balance; 
            uint256 val_withdraw = client[msg.sender].rewardNow; 
            require(client[msg.sender].status_stake == true, "Your stake has not been activated");
            require(balance > val_withdraw , "The contract has no liquidity to send"); 
            require(val_withdraw >= minInvestments, "You do not have the balance you wish to withdraw"); 
            require(client[msg.sender].rewardClaimed < client[msg.sender].maxReward, "This withdrawal exceeds the maximum rewards allowed");
            stake_hold -= val_withdraw; 
            payable(msg.sender).transfer(client[msg.sender].rewardNow); 
            client[msg.sender].rewardClaimed += client[msg.sender].rewardNow;
            client[msg.sender].rewardNow = 0;
            return true; 
        } 
 
        function addStake(address _address) public returns (bool){ 
            require(client[_address].balance_stake > 0 , "You have no balance to generate profits"); 
            if(client[_address].lastUpdateTime + 1 days <= block.timestamp){
                client[_address].rewardNow += SafeMath.div(SafeMath.mul(client[_address].balance_stake,percentage),100);
            }else{
                revert("You don't have the time");
            }
            return true;
            
        } 
 
        function balanceContract() public view returns (uint256){ 
            return address(this).balance; 
        }  

        // modificar porcentaje de ganacias
        function updatePercentageValue(uint256 _value) public Unicamente(msg.sender) returns (uint256) {
            return percentage = _value;
        }

        
         
}

// Implementacion de la libreria SafeMath para realizar las operaciones de manera segura
// Fuente: "https://gist.github.com/giladHaimov/8e81dbde10c9aeff69a1d683ed6870be"

library SafeMath{
    // Restas
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
      assert(b <= a);
      return a - b;
    }
    
    // Sumas
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
      uint256 c = a + b;
      assert(c >= a);
      return c;
    }

    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
      // assert(b > 0); // Solidity automatically throws when dividing by 0
      uint256 c = a / b;
      // assert(a == b * c + a % b); // There is no case in which this doesn't hold
      return c;
    }
    
    // Multiplicacion
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }
}