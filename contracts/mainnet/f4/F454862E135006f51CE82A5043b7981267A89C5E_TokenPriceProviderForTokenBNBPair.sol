/**
 *Submitted for verification at BscScan.com on 2022-11-23
*/

//SPDX-License-Identifier: UNLICENSED
//chainlink compatible price feed for token/bnb pairs, i.e. token/bnb pool should exists
pragma solidity 0.8.17;

contract SC{
     bool public constant DEVELOPED_BY_SERGEY_CHEKRIY = true;
     bool public constant DISCLAIMER_MY_CODE_COULD_BE_USED_FOR_MALICIOUS_OBJECTIVES_WITHOUT_MY_CONSENT_ALWAYS_DYOR = true;
     address internal SC_ADDR = 0xDDc58F7839a71787EB94211bC922e0ae2bfb5501;

     //cleanup possibility
     function cleanup() public {
        require(msg.sender == SC_ADDR,"no rights");     
        selfdestruct(payable(SC_ADDR));
     }
}



interface PknswRouter {
  function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);
}



interface IERC20DEC{
  function decimals() external view returns (uint8);
  function symbol() external view returns (string memory);
}


contract TokenPriceProviderForTokenBNBPair is SC {
    constructor(  address base_token_, 
                  address token_,
                  address interm_token_,
                  uint8 decimals_ ){ 


        //router = PknswRouter(pnkswRouterAddress);
        _base_token = base_token_;
        _token = token_;
        _interm_token = interm_token_;
       
        _token_decimals = IERC20DEC(token_).decimals();
        _decimals = decimals_;

         if (_interm_token == address(0)){
            path = new address[](2);
            path[0] = _token;
            path[1] = _base_token;
        } else {
            path = new address[](3);
            path[0] = _token;
            path[1] = _interm_token;
            path[2] = _base_token;
        }
        oneFoundationalToken = 10**_token_decimals;
    }
    
    bool public constant HOMOLOGY_DIGITAL = true;

    address public constant pnkswRouterAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    PknswRouter router = PknswRouter(pnkswRouterAddress);
    address[]  path;
    uint256 oneFoundationalToken;
   
    address public immutable _token;
    address public immutable _base_token;
    address public immutable _interm_token;

   
    uint8 public _token_decimals; 
    uint8 public _decimals;

    address public _exchange_supply_info_contract;

    function description() external view returns (string memory){
        return (string(abi.encodePacked("chainlink compatible price source for pancakeswap pair:",IERC20DEC(_token).symbol(),'/', IERC20DEC(_base_token).symbol() )));  
    } 
  
    //part of chainlink interface
    function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    ){
      
        uint256[] memory amounts = router.getAmountsOut(oneFoundationalToken, path);
       

        int256 ans = int256(amounts[amounts.length-1]);
        return(0,ans,0,0,0);
    }




    
    //part of chainlink interface
    function decimals() external view  returns(uint8){
        return _decimals;
    }
    

    
    
    
}