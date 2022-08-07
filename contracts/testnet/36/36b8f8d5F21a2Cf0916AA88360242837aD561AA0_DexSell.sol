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

  //uint256 public _unitTokenValue;
  //uint256 public _unitTokenValueListing;

  //address[] internal _wallets;
  function getPreLaunchAddress() external view returns (address) { return address(preLaunch); }

  constructor () {
    //preLaunch.updateRate(333);
  }

  receive() external payable {}



  function newLaunch(
    address contractToken,
  uint256[] memory infos,
       bool refoundBurn,
    uint256 startData,  
    uint256 endData, 
   string[] memory social
  ) external {

  // Building contract
  preLaunch = new PreLaunch(msg.sender, contractToken, infos, refoundBurn, startData, endData);


    uint256 _tokensNeed;
    uint256 _tokensToSale;
    uint256 _tokensToLiquidity;
    uint8 deci = IERC20Ext(contractToken).decimals();
    _tokensToSale = infos[2].div(1000000000000000000).mul(infos[0]); 
    _tokensToLiquidity = _tokensToSale.div(100).mul(infos[5]);
    _tokensNeed = _tokensToSale + _tokensToLiquidity;
    _tokensNeed = _tokensNeed * (10 ** deci);
    IERC20Ext(address(contractToken)).transferFrom(msg.sender, address(preLaunch), _tokensNeed);


    // Registrando a launchPad
    _preSale[_totalLaunchs].tokenContract=contractToken;
    _preSale[_totalLaunchs].preSaleContract=address(preLaunch);

    _preSale[_totalLaunchs].name = IERC20Ext(contractToken).name();      
    _preSale[_totalLaunchs].symbol = IERC20Ext(contractToken).symbol();
    _preSale[_totalLaunchs].decimals = deci;

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
    _preSale[_totalLaunchs].social=social;
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



  function getPoolID (uint256 idPool) public view returns (LaunchPad memory) { 
    return _preSale[idPool]; 
  }

  function getPool (address contractPoolOrToken) public view returns (LaunchPad memory) { 
    uint256 idPool = _preSaleList[contractPoolOrToken];
    return _preSale[idPool]; 
  }















/*
  function calculate() public {

    uint256 rate=3000; // 1 BNB = 3000 TOKEN ( 1000000000000000000 / 3000 )
    //uint256 softCap=150000000000000000000;
    uint256 hardCap=300000000000000000000;
    //uint256 minimum=100000000000000000;
    //uint256 maximum=1000000000000000000;
    uint256 liquidityPercent=52;
    uint256 liquidityRate=2000;
    //uint256 liquidityDays=30;

    //Preco por unidade , saber quantos BNB valem cada TOKEN
    _unitTokenValue = uint(1000000000000000000).div(rate);
    _unitTokenValueListing = uint(1000000000000000000).div(liquidityRate);

    // calcular total MAXIMO de tokens q eu preciso 
    _tokensToSale = hardCap.div(1000000000000000000).mul(rate); // = 300 BNB * rate 3000 = 900.000 token p vendas + 
    _tokensToLiquidity = _tokensToSale.div(100).mul(liquidityPercent); // 900.000 / 100 cotas * 52%
    _tokensNeed = _tokensToSale + _tokensToLiquidity;
    // % de liquidez

  }
*/


/*

  function ComprarCalc () public payable returns (uint256) {
    
    uint256 BNBenviado = msg.value;

    uint256 entregar = BNBenviado.div(_unitTokenValue);

    return entregar;
  }
*/






}