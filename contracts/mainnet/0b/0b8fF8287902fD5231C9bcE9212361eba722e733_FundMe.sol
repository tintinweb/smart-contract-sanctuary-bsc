// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./AggregatorV3Interface.sol";
import "./PriceConverter.sol";

error NotOwner();

contract FundMe {
    using PriceConverter for uint256;

  
    

    // Could we make this constant?  /* hint: no! We should make it immutable! */
    address public /* immutable */ i_owner;
    uint256 public constant MINIMUM_USD = 10 * 1e18;
    struct Donate {
            uint256 to;
            address from;
            uint256 amount;
 }
//  Donate[] public funders;
//   mapping (uint => Donate) public donate;
  uint256 public funderCount;
  Donate[] public funders;
  
    
    constructor() {
        funderCount= 0;
       
        i_owner = msg.sender;
    }

    function fund(uint256 id) public payable {
        require(msg.value.getConversionRate() >= MINIMUM_USD, "Send Minimum 10$");

        funders.push(Donate(id,msg.sender,msg.value));
        funderCount++;
       
   
    }
    
    function getVersion() public view returns (uint256){
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526);
        return priceFeed.version();
    }
    
    modifier onlyOwner {
        // require(msg.sender == owner);
        if (msg.sender != i_owner) revert NotOwner();
        _;
    }
    
    function withdraw() public onlyOwner {
 
       
       
        delete funders;
        funderCount = 0;
        // // transfer
      
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }
   

    fallback() external payable {
        fund(0);
    }

    receive() external payable {
        fund(0);
    }

}

// Concepts we didn't cover yet (will cover in later sections)
// 1. Enum
// 2. Events
// 3. Try / Catch
// 4. Function Selector
// 5. abi.encode / decode
// 6. Hash with keccak256
// 7. Yul / Assembly