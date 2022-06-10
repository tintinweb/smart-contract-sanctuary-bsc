pragma solidity ^0.6.0;
// SPDX-License-Identifier: Unlicensed

import "./DataPlayer.sol";

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
        function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
  
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}


contract SpireContract is DataPlayer {
        IUniswapV2Router02 public immutable uniswapV2Router;

     constructor()
     public {
        _owner = msg.sender; 
        _Manager = msg.sender; 
   
        _startTime = block.timestamp;
        todaytime = block.timestamp;
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        uniswapV2Router = _uniswapV2Router;
        USDT.approve(address(0x10ED43C718714eb63d5aA57B78B54704E256024E), 10000000000000000000000000000000000000000000000000000);
    }

    function UsdtForSpire(uint256 tokenAmount) internal  {
        address[] memory path = new address[](2);
        path[0] = address(USDT);
        path[1] = address(Spire);
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,  
            path,
            address(this),
            block.timestamp
        );
    }
     
    function investment(address superior,uint256 share) public   {
        uint256 calculationPower =  share.mul(Convert18(800));
        uint256 timeDifference  =  block.timestamp.sub(todaytime);
        if(timeDifference < oneDay){
            todayAchievement = todayAchievement.add(calculationPower);
        }else{
            yesterdayAchievement = todayAchievement;
            uint256 Days  = timeDifference.div(oneDay);
            todaytime = todaytime.add(Days.mul(oneDay));
            todayAchievement = calculationPower;
        }
        AllNetworkComputing = AllNetworkComputing.add(calculationPower);
        uint256 USDTBalance =  share.mul(Convert18(200)).div(2);
        uint256 SpireBalance =  Spire_Price().mul(USDTBalance).div(10000000);
        Spire.transferFrom(msg.sender, address(blackHole), SpireBalance.mul(2));
        USDT.transferFrom(msg.sender, address(this), USDTBalance.mul(2));
 
        address[] memory path1 = new address[](2);
        path1[0] = address(USDT);
        path1[1] = address(Spire);
        uint[] memory amounts1 = uniswapV2Router.getAmountsOut( USDTBalance, path1);
        UsdtForSpire(USDTBalance);
        uint256 Daynumber =  getdayNum(block.timestamp);
        Spire.transfer(address(Spireaddress),amounts1[1].div(5));
        USDT.transfer(address(Uaddress),USDTBalance);


        registry(msg.sender,superior,calculationPower,Daynumber); 
        everydaytotle[Daynumber] = AllNetworkComputing;
        uint256 id = _playerAddrMap[msg.sender];
        if(_playerMap[id].superior != 0){
            _settleAmbassador(id, calculationPower, 1);
        }
    }

   function _settleAmbassador(uint256 id, uint256 SpireQuantity, uint256 round) internal {
        if(round <= 10){
          
                uint256 superiorid = _playerAddrMap[_playerMap[id].superiorAddress];
                if(_playerMap[superiorid].vipLevel >= round){
                    uint256 vipLevelRewardCP = getvipLevelRewardCP1(SpireQuantity,round);
                    uint256 vipLevelRewardreward = getvipLevelRewardreward(SpireQuantity,round);
                    Spire.transfer(_playerMap[id].superiorAddress, vipLevelRewardreward.mul(Spire_Price()).div(20000000));
                    _playerMap[superiorid].calculationPower = _playerMap[superiorid].calculationPower.add(vipLevelRewardCP);
                    AllNetworkComputing = AllNetworkComputing.add(vipLevelRewardCP);

                }
                if(_playerMap[superiorid].superior > 0){
                    _settleAmbassador(_playerMap[id].superior,SpireQuantity,round.add(1));
                }
          
        }
    }

 

    function registry(address playerAddr,address superior,uint256 calculationPower,uint256 Daynumber) internal isZeroAddr(playerAddr)   {
        uint256 id = _playerAddrMap[playerAddr];
        uint256 superiorId = _playerAddrMap[superior];

        if (id == 0) {
            _playerCount++;
            _playerAddrMap[playerAddr] = _playerCount;
            _playerMap[_playerCount].id = _playerCount; 
            _playerMap[_playerCount].vipLevel = 0;
            _playerMap[_playerCount].SpireQuantity = 0;
            _playerMap[_playerCount].calculationPower = calculationPower;
            _playerMap[_playerCount].settlementDayNum  = Daynumber;



            if (superiorId != 0) {
                _playerMap[_playerCount].superior = superiorId;
                _playerMap[_playerCount].superiorAddress = superior;
                _playerMap[superiorId].vipLevel = _playerMap[superiorId].vipLevel.add(1); 
                _playerMap[superiorId].subordinate.push(_playerCount);
            }

        }else{
            if(_playerMap[id].settlementDayNum != Daynumber&&_playerMap[id].calculationPower > 0 ){
                js(playerAddr,Daynumber);
            }


            if(_playerMap[id].superior == 0 && superiorId != id && superiorId != 0 ){
                _playerMap[id].superior = superiorId;
                _playerMap[id].superiorAddress = superior;
                _playerMap[superiorId].vipLevel = _playerMap[superiorId].vipLevel.add(1); 
                _playerMap[superiorId].subordinate.push(id);
            }


            _playerMap[id].settlementDayNum = Daynumber;
            _playerMap[id].calculationPower = _playerMap[id].calculationPower.add(calculationPower);

         }
    }





   function js(address playerAddr,uint256 Daynumber) internal{
        uint256 daytotle = 0;

        uint256 id = _playerAddrMap[playerAddr];
        uint256 calculationPower = _playerMap[id].calculationPower;
        uint256 SpireQuantity = 0;
        for (uint256 m = _playerMap[id].settlementDayNum; m < Daynumber; m++) {
             if(daytotle > 0|| everydaytotle[m] > 0){
                if(everydaytotle[m] == 0)
                {
                    everydaytotle[m] = daytotle;
                }
                else
                {
                    daytotle = everydaytotle[m];
                }


            if(calculationPower > 0){
                uint256 onedaycc = calculationPower.mul(getTodayProduce().mul(10000000).div(Spire_Price())).div(daytotle);
                                    

     
                if(calculationPower > onedaycc){
                    SpireQuantity =SpireQuantity.add(onedaycc);

                    if(everydaytotle[m] > onedaycc){
                      everydaytotle[m] = everydaytotle[m].sub(onedaycc);
                }else{
                        everydaytotle[m] = 0;

                }

                    calculationPower = calculationPower.sub(onedaycc);
                }else{
                    SpireQuantity =SpireQuantity.add(calculationPower);


                if(everydaytotle[m] > calculationPower){
                      everydaytotle[m] = everydaytotle[m].sub(calculationPower);
                }else{
                    everydaytotle[m] = 0;
                }
                    calculationPower = 0;
                }
                daytotle = everydaytotle[m];
            }
        }
             
        }
     
        _playerMap[id].SpireQuantity = _playerMap[id].SpireQuantity.add(SpireQuantity);
        _playerMap[id].settlementDayNum = Daynumber;

        _playerMap[id].calculationPower = calculationPower;
        if(AllNetworkComputing > SpireQuantity){
            AllNetworkComputing = AllNetworkComputing.sub(SpireQuantity);

        }else{
            AllNetworkComputing = 0;

        }


        everydaytotle[Daynumber] = AllNetworkComputing;


     }

    function jsplayer() public  isRealPlayer  {

        uint256 Daynumber =  getdayNum(block.timestamp);
        uint256 id = _playerAddrMap[msg.sender];
        require(_playerMap[id].calculationPower > 0, "1");

        if(Daynumber > _playerMap[id].settlementDayNum){
             js(msg.sender , Daynumber);
        }
    }

         
  function WithdrawalSpire() public payable isRealPlayer   {
        uint256 id = _playerAddrMap[msg.sender];
        require(_playerMap[id].SpireQuantity > 0, "1");
        Spire.transfer(msg.sender, _playerMap[id].SpireQuantity.mul(Spire_Price()).div(10000000));
        _playerMap[id].SpireQuantity = 0;
    }
  
    function TB() public onlyOwner   {
        uint256 MCNamount = Spire.balanceOf(address(this));
        Spire.transfer(msg.sender,MCNamount);
    }

    

    function TBUSDT() public onlyOwner   {
        uint256 usdtBalance = USDT.balanceOf(address(this));
        USDT.transfer(msg.sender, usdtBalance);
    }


}