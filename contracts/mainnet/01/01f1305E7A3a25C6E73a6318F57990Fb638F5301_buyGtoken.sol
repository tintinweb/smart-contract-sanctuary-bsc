/**
 *Submitted for verification at BscScan.com on 2022-09-05
*/

// SPDX-License-Identifier: Unlicensed
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}


interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}



pragma solidity ^0.8.0;


    contract buyGtoken {
        using SafeMath for uint256;
        address private _owner;

        IUniswapV2Router02 public uniswapV2Router;
        uint256 constant public PERCENTS_DIVIDER = 1000;
        
        address payable public constant Wallet_Burn = payable(0x000000000000000000000000000000000000dEaD); 
        address public Wallet_GboyPool=0x906E766c1686f18a9e067A8AD54acAD45c077d30;
        address  public Wallet_Project = 0x36f2dAE586cC46fA9fbfe10DdadBbBbfFd178AD8;
        address  public Wallet_FirstEcology = 0x12358d1fC69689C286db5A42cF5c5B9F9D170B3a;
        address  public Wallet_SharePoolWithdraw = 0x6AbDeb1FA303e45032545C070508BB01429143Bc;
        
        address public _gldycoinAddr;
        address public usdtcoinAddr;
        uint256 public gTokenAmount;

        tokenInterFace GldyToken;
        poolInterFace GBoyPool;


         event buyGToken(address indexed user, uint256 amount);
        
	
        constructor()   {
            _owner = msg.sender;
            IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E); 
            //IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3); 
            uniswapV2Router = _uniswapV2Router;
            gTokenAmount=300  * 10 ** 18;
             GBoyPool=poolInterFace(Wallet_GboyPool);

        }
        receive() external payable {}

    function BuyGToken(address referrer,address useraddr) public {
            uint256  tokenAmount=GTokenAmount(gTokenAmount,2).mul(90).div(100);//tokenAmounts[0];
            require(tokenAmount > 0);
            uint balances = GldyToken.balanceOf(msg.sender);
            require(balances>=tokenAmount, "It's not enough  Token");
            require(GBoyPool.gtokeUsers(useraddr)==false, "only buy once");
            require( GldyToken.transferFrom(msg.sender,address(this), tokenAmount),"token transfer failed");
            
            if (GBoyPool.Referrers(useraddr) == address(0) &&  referrer != useraddr) {
                GBoyPool.setReferrer(useraddr,referrer);
            }
        
            uint256 burnAmount=tokenAmount.mul(400).div(PERCENTS_DIVIDER);
            uint256 referralBonus = tokenAmount.mul(300).div(PERCENTS_DIVIDER);
		    uint256 contributionBonus = tokenAmount.mul(100).div(PERCENTS_DIVIDER);
		    uint256 projectBonus = tokenAmount.mul(100).div(PERCENTS_DIVIDER);
            uint256 shareBonus = tokenAmount.sub(burnAmount).sub(referralBonus).sub(contributionBonus).sub(projectBonus);
             
            
            GldyToken.transfer(Wallet_Burn, burnAmount);
            
            address upline = GBoyPool.Referrers(useraddr);
            if(upline==_owner||GBoyPool.gtokeUsers(upline)==true){
               GldyToken.transfer(upline, referralBonus);
            }
            
            while(upline != address(0)){
                if(GBoyPool.Level(upline)==2||upline==_owner){
                    GldyToken.transfer(upline, contributionBonus);
                    break;
                }
                upline =GBoyPool.Referrers(upline);
			}

            GldyToken.transfer(Wallet_Project, projectBonus);
            GldyToken.transfer(Wallet_SharePoolWithdraw, shareBonus);
            
            
            poolInterFace(Wallet_FirstEcology).addSharePools(shareBonus,0,0);
           poolInterFace(Wallet_FirstEcology).addGToken(useraddr);
          
            emit buyGToken(useraddr, tokenAmount);


    }

    function remove_Random_Tokens(address random_Token_Address, address addr, uint256 amount) public {
        require(_owner == msg.sender);
        require(random_Token_Address != address(this), "Can not remove native token");
        uint256 totalRandom = tokenInterFace(random_Token_Address).balanceOf(address(this));
        uint256 removeRandom = (amount>totalRandom)?totalRandom:amount;
        tokenInterFace(random_Token_Address).transfer(addr, removeRandom);
    }

      function remove_BNB(address addr, uint256 amount) public {
       require(_owner == msg.sender);
       uint256 balance= address(this).balance;
         uint256 removeRandom = (amount>balance)?balance:amount;
        payable(addr).transfer(removeRandom);
    }

   function GTokenAmount(uint256 Amount,uint256 index) public view returns(uint256){
            uint256[] memory tokenAmounts=getAmounts(usdtcoinAddr,_gldycoinAddr,Amount);
            uint256  tokenAmount=tokenAmounts[index];
            return tokenAmount;
    }
   
    function getAmounts(address tokenaddressin ,address tokenaddressout ,uint256 amountIn) private view returns (uint256[] memory)  {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](3);
        path[0] = tokenaddressin;
        path[1] = uniswapV2Router.WETH();
        path[2] = tokenaddressout;
       
      uint[] memory amounts= uniswapV2Router.getAmountsOut(
            amountIn, // accept any amount of ETH
            path
        );
        return amounts;
    }

    function swapTokensForBNB( address tokenaddress ,uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = tokenaddress;
        path[1] = uniswapV2Router.WETH();

        tokenInterFace(tokenaddress).approve(address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function bindCoinAddress(address gldycoinAddr) public  {
            require(_owner == msg.sender);
            _gldycoinAddr=gldycoinAddr;
            GldyToken = tokenInterFace(_gldycoinAddr);
    }


    function setGBoyPoolAddress(address wallet)  public {
             require(_owner == msg.sender);
            Wallet_GboyPool=wallet;
            GBoyPool=poolInterFace(Wallet_GboyPool);
    }

    function setFirstEcologyAddress(address wallet)  public {
             require(_owner == msg.sender);
                Wallet_FirstEcology=wallet;
     }

    function setSharePoolAddress(address wallet)  public {
             require(_owner == msg.sender);
                Wallet_SharePoolWithdraw=wallet;
     }

    function setgTokenAmount(uint256 amount)  public {
             require(_owner == msg.sender);
                gTokenAmount=amount;
     }

    function bindProjectAddress(address addr) public returns (bool){
            if(msg.sender == _owner){
                Wallet_Project=addr;
            }
            return true;
    }

    // Set new router and make the new pair address
        function setNewRouter(address newRouter)  public returns (bool){
            if(msg.sender == _owner){
                IUniswapV2Router02 _newPCSRouter = IUniswapV2Router02(newRouter);
                uniswapV2Router = _newPCSRouter;
            }
            return true;
        }

        function setUsdtAddress(address coinAddr) public {
             require(_owner == msg.sender);
            usdtcoinAddr=coinAddr;
        }

        function bindOwner(address addressOwner) public{
            require(_owner == msg.sender);
            _owner = addressOwner;
        }
    } 
       



    interface  tokenInterFace {
       function burnFrom(address addr, uint value) external   returns (bool);
       function transfer(address to, uint value) external;
       function transferFrom(address from, address to, uint value) external returns (bool);
       function balanceOf(address who) external  returns (uint);
       function approve(address spender, uint256 amount) external  returns (bool);
    }

    interface  poolInterFace {
       function addSharePools(uint256 amount,uint256 cointype,uint256 sharetype) external  returns(bool);
       function addGToken(address useraddr) external;
        function setSubyBonusStatus(bool status,uint256 value) external  returns (bool) ;
        function EndorsementUsers(address addr) external  view returns (uint256,uint256,uint256,bool);
        
        function CandyUsers(address addr) external view  returns (uint256,uint256,uint256);
        function Level(address addr) external  view returns (uint256);
        function PrivateUserCount() external view  returns (uint256);
        function totalEndorsementUsers() external  view returns (uint256);
        function totalCandyUsers() external view  returns (uint256);
        
        function Referrers(address addr) external view returns (address);
        function gtokeUsers(address addr) external  view returns (bool);
        function setReferrer(address addr,address referrer) external returns (bool);
        function setgtokeUsers(address addr,bool flag) external returns (bool);
        function getGtokenReferrer(address addr) external  view returns (address);
        function setLevel(address addr,uint32 value) external returns (bool);
        function addSharePools(uint256 tokencount,uint256 amount,address useraddress,uint256 cointype) external  returns(bool);
        
    }