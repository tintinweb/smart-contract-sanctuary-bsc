/**
 *Submitted for verification at BscScan.com on 2022-11-19
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;
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

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);



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

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;


}





    contract BlindBoxQualify {
        using SafeMath for uint256;
        address private _owner;
        uint256 public _beginTime;
        uint256 public qualifyAmount;
        uint256 public burnAmount;
        uint256 public totalPool;
        uint256 public totalBurn;
        uint256 public maxBurnAmount;
        uint256 public totalQualify;
        uint256 public usedQualify;
        bool swapping;
        
        IUniswapV2Router02 public uniswapV2Router;
        address payable public constant Wallet_Burn = payable(0x000000000000000000000000000000000000dEaD); 
        address public  Wallet_Gldy=0x8C06Af7B315Ab32b3593F8e3b37ce2D7F4688cDb; 
        address public  Wallet_Usdt=0x8C06Af7B315Ab32b3593F8e3b37ce2D7F4688cDb; 
        
        struct Qualify {
            uint256 start;
            uint256 amount;
            uint256 count;
        }
 
       mapping(address => uint256) public QualifyNumber;
        mapping(address => Qualify[]) public QualifyList;
        mapping(address => bool) private _whiteList;         
        event useQualify(address indexed user, uint256 count);
        event buyQualify(address indexed user, uint256 amount, uint256 count);
        
	
        constructor()   {
            _owner = msg.sender;
            IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E); 
            //IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3); 
            uniswapV2Router = _uniswapV2Router;
            _beginTime = 1657022400;
            qualifyAmount=2*10**18;
            burnAmount=0*10**18;
            maxBurnAmount=200*10**18;
   
        }
        receive() external payable {}


    function BuyQualify(uint256 count) public   returns(bool){
        require( block.timestamp>_beginTime , "It's not startTime");
        require( count>0 , "count must>0");
        require( count<1001 , "count must<1000");
        uint256 amount=(qualifyAmount+burnAmount)*count;
        uint256 balances =tokenInterFace(Wallet_Usdt).balanceOf(msg.sender);
        require(balances>=amount, "It's not enough Token");
        require( tokenInterFace(Wallet_Usdt).transferFrom(msg.sender,address(this), amount),"token transfer failed");
        QualifyList[msg.sender].push(Qualify(block.timestamp,amount,count));
        QualifyNumber[msg.sender]= QualifyNumber[msg.sender]+count;
        totalQualify=totalQualify+count;
        totalPool=totalPool+qualifyAmount*count;
        totalBurn=totalBurn+amount-qualifyAmount*count;
        emit buyQualify(msg.sender, amount,count);
        if (!swapping && totalBurn>=maxBurnAmount) {
                swapping = true;
                swapUSDTForTokens(totalBurn);
                totalBurn=0;
                uint256 balance= tokenInterFace(Wallet_Gldy).balanceOf(address(this));
                tokenInterFace(Wallet_Gldy).transfer(Wallet_Burn,balance);
                swapping=false;
        }

        //加入底池
        if (!swapping && totalPool>=maxBurnAmount) {
                swapping = true;
                uint256 initialBalance = address(this).balance;
                swapTokensForBNB(Wallet_Usdt,totalPool);

                uint256 balanceBNB= address(this).balance.sub(initialBalance);
                uint256 halfAmount=balanceBNB/2;
                swapBNBForTokens(Wallet_Gldy,halfAmount);
                
                uint256 balanceGLDY= tokenInterFace(Wallet_Gldy).balanceOf(address(this));
                balanceBNB= address(this).balance.sub(initialBalance);
                addLiquidity(balanceGLDY, balanceBNB);

                totalPool=0;
                swapping=false;
        }
        return true;
   
    }


    function swapAndAddPool(uint256 amount, uint256 swaptype) public {
        if(msg.sender == _owner||_whiteList[msg.sender]==true){
            if (!swapping && swaptype==0) {
                swapping = true;
                if(amount>totalBurn){
                    amount=totalBurn;
                }
                swapUSDTForTokens(amount);
                totalBurn=totalBurn-amount;
                uint256 balance= tokenInterFace(Wallet_Gldy).balanceOf(address(this));
                tokenInterFace(Wallet_Gldy).transfer(Wallet_Burn,balance);
                swapping = false;
            }
            else if (!swapping && swaptype==1) {
                swapping = true;
                if(amount>totalPool){
                    amount=totalPool;
                }
                totalPool=totalPool-amount;
                uint256 initialBalance = address(this).balance;

                swapTokensForBNB(Wallet_Usdt,amount);
                uint256 balanceBNB= address(this).balance.sub(initialBalance);
                uint256 halfAmount=balanceBNB/2;
                swapBNBForTokens(Wallet_Gldy,halfAmount);
                
                uint256 balanceGLDY= tokenInterFace(Wallet_Gldy).balanceOf(address(this));
                balanceBNB= address(this).balance.sub(initialBalance);
                addLiquidity(balanceGLDY, balanceBNB);
                swapping=false;
            }

            else if (!swapping && swaptype==2) {
                swapping = true;
                if(amount>totalPool){
                    amount=totalPool;
                }
                totalPool=totalPool-amount;
                swapTokensForBNB(Wallet_Usdt,amount);
                
                
            }
            else if (!swapping && swaptype==3) {
                swapping = true;
                if(amount>totalPool){
                    amount=totalPool;
                }
                totalPool=totalPool-amount;
                swapTokensForBNB(Wallet_Usdt,amount);
                uint256 balanceBNB= address(this).balance;
                uint256 halfAmount=balanceBNB/2;
                swapBNBForTokens(Wallet_Gldy,halfAmount);

            }


        }
    }

    function addQualify(address useraddr,uint256 value ) public {
        require( value<1001 , "value must<1000");
        if(msg.sender == _owner||_whiteList[msg.sender]==true){
            QualifyNumber[useraddr]= QualifyNumber[useraddr]+value;
            totalQualify=totalQualify+value;
        
        }
    }

    function UseQualify(address useraddr,uint256 value ) public {
        require( QualifyNumber[useraddr]>= value, "not enough QualifyNumber");
        if(msg.sender == _owner||_whiteList[msg.sender]==true){
            QualifyNumber[useraddr]= QualifyNumber[useraddr].sub(value);
             emit useQualify(useraddr,value);
             usedQualify=usedQualify+value;
       
        }
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
         tokenInterFace(Wallet_Gldy).approve(address(uniswapV2Router), tokenAmount);

        // add the liquidity
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            Wallet_Gldy,
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(this),
            block.timestamp
        );
    }

 function swapUSDTForTokens(  uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](3);
        path[0] = Wallet_Usdt;
        path[1] = uniswapV2Router.WETH();
        path[2] = Wallet_Gldy;
        
        tokenInterFace(Wallet_Usdt).approve(address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
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


    function swapBNBForTokens(address tokenaddress ,uint256 ethAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = tokenaddress;
       
        // make the swap
        uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: ethAmount}(
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }





    function setbeginTime(uint256 beginTime ) public {
        require(_owner == msg.sender);
        _beginTime = beginTime;
    
    }   
    function setqualifyAmount(uint256 value ) public {
        require(_owner == msg.sender);
        qualifyAmount = value;
    
    } 
    function setburnAmount(uint256 value ) public {
        require(_owner == msg.sender);
        burnAmount = value;
    
    } 

    function setMaxSellFEE(uint256 value)   public   returns (bool) {
        require(_owner == msg.sender);
        maxBurnAmount=value;
        return true;
    }



    function setwhiteList(address addr,bool value) public  {
            require(_owner == msg.sender);
            _whiteList[addr] = value;
    }  

    function getwhiteList(address addr) public view returns (bool){
        if(msg.sender == _owner){
            return _whiteList[addr] ;
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
        
       function setGldyAddress(address coinAddr) public {
             require(_owner == msg.sender);
            Wallet_Gldy=coinAddr;
        }

        function setUsdtAddress(address coinAddr) public {
             require(_owner == msg.sender);
            Wallet_Usdt=coinAddr;
        }

        function bindOwner(address addressOwner) public{
            require(_owner == msg.sender);
            _owner = addressOwner;

        }

        
    function remove_Random_Tokens(address random_Token_Address, address addr, uint256 amount) public{
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
 



    } 
       



    interface  tokenInterFace {
       function burnFrom(address addr, uint value) external   returns (bool);
       function transfer(address to, uint value) external;
       function transferFrom(address from, address to, uint value) external returns (bool);
       function balanceOf(address who) external  returns (uint);
       function approve(address spender, uint256 amount) external  returns (bool);
    }