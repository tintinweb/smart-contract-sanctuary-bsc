/**
 *Submitted for verification at BscScan.com on 2022-12-21
*/

/**
 *Submitted for verification at BscScan.com on 2022-12-20
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IBEP20 {
  function totalSupply() external view returns (uint256);
  function balanceOf(address who) external view returns (uint256);
  function allowance(address owner, address spender)
  external view returns (uint256);
  function transfer(address to, uint256 value) external returns (bool);
  function approve(address spender, uint256 value)
  external returns (bool);
  
  function transferFrom(address from, address to, uint256 value)
  external returns (bool);
  function burn(uint256 value)
  external returns (bool);
  event Transfer(address indexed from,address indexed to,uint256 value);
  event Approval(address indexed owner,address indexed spender,uint256 value);
}


contract Test{
   
    uint256 public totalToken;
      
    uint256 public  dailyPercent;

    uint256 public startTime;

    uint256 public paidCycle;

    address public owner; 

    address public first_wallet; 
    address public second_wallet; 
    address public third_wallet; 
    address public fourth_wallet; 
    address public fifth_wallet; 
    address public sixth_wallet; 
    
    event TokenDistribution(address indexed sender, address indexed receiver, uint total_token, uint live_rate, uint busd_amount);
    IBEP20 private TestToken; 

    constructor(address ownerAddress, IBEP20 _TestToken, address _first_wallet, address _second_wallet, address _third_wallet, address _fourth_wallet, address _fifth_wallet, address _sixth_wallet, uint256 _totalToken, uint256 _dailyPercent) 
    {
        owner = ownerAddress;        
        TestToken = _TestToken;
        first_wallet=_first_wallet; 
        second_wallet=_second_wallet; 
        third_wallet=_third_wallet; 
        fourth_wallet=_fourth_wallet; 
        fifth_wallet=_fifth_wallet; 
        sixth_wallet=_sixth_wallet; 
        totalToken=_totalToken;
        dailyPercent=_dailyPercent;
        startTime=block.timestamp;
    } 
    
  
    
    function getReleaseToken() public view returns(uint256 releasedToken, uint256 cycle)
	{
			uint256 _cycle=((block.timestamp-startTime)/1 minutes)-paidCycle;
            if(_cycle>0)
            {
                uint256 _released=((totalToken*dailyPercent)/1000000)*_cycle;
              return (_released,_cycle);  
            }
	}

    function withdrawToken() public{
            (uint256 total_token,)=getReleaseToken();
            if(total_token>0)
            {
                TestToken.transfer(first_wallet,((total_token*50)/100));
                TestToken.transfer(second_wallet,((total_token*10)/100));
                TestToken.transfer(third_wallet,((total_token*10)/100));
                TestToken.transfer(fourth_wallet,((total_token*10)/100));
                TestToken.transfer(fifth_wallet,((total_token*10)/100));
                TestToken.transfer(sixth_wallet,((total_token*10)/100));
            }
    }

     
}