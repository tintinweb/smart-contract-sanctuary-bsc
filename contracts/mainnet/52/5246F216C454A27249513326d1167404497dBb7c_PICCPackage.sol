pragma solidity ^0.8.0;
// SPDX-License-Identifier: Unlicensed

import "./DataPlayer.sol";
 
contract PICCPackage is DataPlayer {
    using SafeMath for uint;
   IUniswapV2Router02 public immutable uniswapV2Router;
    constructor()
     {
        _owner = msg.sender; 
        ProjectPartyWallet = msg.sender; 
        RewardWallet = msg.sender; 
        ProtectiveWallet = msg.sender; 
        USDTRewardWallet = msg.sender; 
        PICCRewardWallet = msg.sender; 
        _operator = msg.sender; 
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        uniswapV2Router = _uniswapV2Router;
        _USDTIns.approve(address(0x10ED43C718714eb63d5aA57B78B54704E256024E), 10000000000000000000000000000000000000000000000000000);
    }


 
// 购买套餐
    function BUYPackage(uint256 PackageType,uint256 PackagePartition ) public{
 
        require(PICC_Limit > 0, "Package sell out");  
        require(PackageType > 0, "Package sell out");  
        require( PackagePrice[PackageType] > 0, "Package sell out");  

        uint256 USDTBalance = 0;
 
        if(PackagePartition == 0){
            uint256   Price =  PackagePrice[PackageType].mul(2).div(10);
            uint256   share =  Packageshare[PackageType];
            USDTBalance =   Price;
            _USDTIns.transferFrom(msg.sender, address(this),USDTBalance);
            if(PI_Limit > 0 ||CC_Limit == 0){
                PI_Limit = PI_Limit.add(share);
            }else{
                PICC_Limit = PICC_Limit.sub(share);
                CC_Limit = CC_Limit.sub(share);
            }
        }else if(PackagePartition == 1)
        {
            uint256   Price =  PackagePrice[PackageType].mul(8).div(10);
            uint256   share =  Packageshare[PackageType];
            USDTBalance = Price;
            _USDTIns.transferFrom(msg.sender, address(this),USDTBalance);
            if(CC_Limit > 0||PI_Limit == 0){
                CC_Limit = CC_Limit.add(share);
            }else{
                PICC_Limit = PICC_Limit.sub(share);
                PI_Limit = PI_Limit.sub(share);
            }
        }else  
        {
            uint256   Price =  PackagePrice[PackageType];
            uint256   share =  Packageshare[PackageType];
            USDTBalance =   Price;
            _USDTIns.transferFrom(msg.sender, address(this),USDTBalance);
            PICC_Limit = PICC_Limit.sub(share);
        }
        UForERC20(USDTBalance.mul(6).div(10));
        _USDTIns.transfer(ProjectPartyWallet, USDTBalance.mul(2).div(10));
        _USDTIns.transfer(RewardWallet, USDTBalance.mul(15).div(100));
        _USDTIns.transfer(ProtectiveWallet, USDTBalance.mul(5).div(100));
    }

   function activation(uint256 PackageType ,uint256 ID  ) public payable   {
 
        require(PICC_Limit > 0, "Package sell out");  
        require(PackageType > 0, "Package sell out");  
 
        uint256 USDTBalance = 0;
        uint256  allowance  = PlayerPackage[msg.sender][PackageType];
        require(allowance > 0, "allowance is 0");  
  
        USDTBalance =  PackagePrice[PackageType].mul(2).div(10);

        uint256   share =  Packageshare[PackageType];

 
        PICC_Limit = PICC_Limit.sub(share);


        UForERC20(USDTBalance.mul(6).div(10));
        _USDTIns.transfer(ProjectPartyWallet, USDTBalance.mul(2).div(10));
        _USDTIns.transfer(RewardWallet, USDTBalance.mul(15).div(100));
        _USDTIns.transfer(ProtectiveWallet, USDTBalance.mul(5).div(100));

        PlayerPackage[msg.sender][PackageType] = PlayerPackage[msg.sender][PackageType].sub(1);

    }   
 



// 套餐转让
   function circulationPackage(uint256 PackageType ,address targetAddress ) public {
        uint256  allowance  = PlayerPackage[msg.sender][PackageType];
        require(allowance > 0, "allowance is 0");  
        PlayerPackage[msg.sender][PackageType] = PlayerPackage[msg.sender][PackageType].sub(1);
        PlayerPackage[targetAddress][PackageType] = PlayerPackage[msg.sender][PackageType].add(1);
    }   




 

    function UForERC20(uint256 tokenAmount) public   {
        address[] memory path = new address[](2);
        path[0] = address(_USDTIns);
        path[1] = address(_PICCIns);
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,  
            path,
            address(1),
            block.timestamp
        );
    }
// PICC合成
    function PICCsynthesis(uint256 ID,uint256 ID1 )  public{   
    }

// PI，CC卡转让
    function PICCturn(uint256 ID,uint256 Packagetype,address playAddress)  public{  
    }

// PICC激活 
    function PICCactivation(uint256 ID)  public{       
    }

    // PICC提现
    function Withdrawal(uint256  Balance)  public{       
    }

    // PC兑换
    function PCexchange(uint256  ID)  public{       
    }

// USDT奖励
    function USDTReward (uint256 USDTBalance,address playAddress)  public only_operator{
        _USDTIns.transferFrom(USDTRewardWallet, address(playAddress),USDTBalance);     
    }

// PICC奖励
    function PICCReward (uint256 PICCBalance,address playAddress)  public only_operator{
         _PICCIns.transferFrom(USDTRewardWallet, address(playAddress),PICCBalance);
    }
  
   
}