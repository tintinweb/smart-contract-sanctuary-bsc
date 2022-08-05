// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.7;

import "./SafeMath.sol";
import "./ReentrancyGuard.sol";
import "./Authorized.sol";
import "./PreLaunch.sol";

contract DexSell is Authorized, ReentrancyGuard {

  using SafeMath for uint;

  PreLaunch public preLaunch;

  struct LaunchPad {
    address tokenContract;
    address preSaleContract;
     string name;      
     string symbol;    
      uint8 decimals;  
    uint256 rate; 
    uint256 softCap; 
    uint256 hardCap;  
    uint256 minimum;  
    uint256 maximum; 
    uint256 liquidityPercent;
    uint256 liquidityRate;  
    uint256 liquidityDays;  
       bool refoundBurn; 
    uint256 startData;  
    uint256 endData; 
   string[] social;
       bool complete; 
    address owner;
    uint256 sales;
  }

  //     StructID    Struct  
  mapping(uint256 => LaunchPad) _preSale;
  //     Token       Struct ID
  mapping(address => uint256 ) _preSaleList;
  //     Counter
  uint256 public _totalLaunchs;

  //address[] internal _wallets;
  function getPreLaunchAddress() external view returns (address) { return address(preLaunch); }

  constructor () {
    //preLaunch.updateRate(333);
  }


  function newLaunch(
    address contractToken,
  uint256[] memory infos,
       bool refoundBurn,
    uint256 startData,  
    uint256 endData, 
   string[] memory social
  ) external {

    preLaunch = new PreLaunch(
      payable(0xBF8fB3263E2084156EFC64722DdAEeC517Ae45BD),
      payable(0xBF8fB3263E2084156EFC64722DdAEeC517Ae45BD),
      payable(0xBF8fB3263E2084156EFC64722DdAEeC517Ae45BD)
    );

    _preSale[_totalLaunchs].tokenContract=contractToken;
    _preSale[_totalLaunchs].preSaleContract=address(preLaunch);

    _preSale[_totalLaunchs].rate=infos[0]; 
    _preSale[_totalLaunchs].softCap=infos[1]; 
    _preSale[_totalLaunchs].hardCap=infos[2];  
    _preSale[_totalLaunchs].minimum=infos[3];  
    _preSale[_totalLaunchs].maximum=infos[4];  
    _preSale[_totalLaunchs].liquidityPercent=infos[5];
    _preSale[_totalLaunchs].liquidityRate=infos[6];  
    _preSale[_totalLaunchs].liquidityDays=infos[7];  

    _preSale[_totalLaunchs].refoundBurn=refoundBurn;
    _preSale[_totalLaunchs].startData=startData;  
    _preSale[_totalLaunchs].endData=endData; 
    //_preSale[_totalLaunchs].social=social;
    _preSale[_totalLaunchs].owner=msg.sender;

        //number list Mapping from address token and address launch
       _preSaleList[address(preLaunch)] = _totalLaunchs;
       _preSaleList[address(contractToken)] = _totalLaunchs;

    _totalLaunchs = _totalLaunchs.add(1);

  }


  function getQueues() public view returns (LaunchPad[] memory) {
    uint totalItemCount = _totalLaunchs;
    uint256 currentIndex = 0;

    uint totalItemCountNew;

    for (uint i = 0; i < totalItemCount; i++) {
      if (!_preSale[i].complete) {
      totalItemCountNew +=1;
      }
    }

    LaunchPad[] memory items = new LaunchPad[](totalItemCountNew);
    for (uint i = 0; i < totalItemCount; i++) {
      if (!_preSale[i].complete) {
      items[currentIndex] = _preSale[i];
      currentIndex += 1;
      }
    }
  return items;
  }

}