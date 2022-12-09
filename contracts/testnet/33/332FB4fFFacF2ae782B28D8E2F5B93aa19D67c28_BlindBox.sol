/**
 *Submitted for verification at BscScan.com on 2022-12-08
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





    contract BlindBox {
        using SafeMath for uint256;
        address private _owner;
        uint256 constant public TIME_STEP = 1 days;
        uint256 public _beginTime;
        uint256 public totalPool;
        uint256 public totalSharePool;
        uint256 public totalBurn;
        uint256 public maxBurnAmount;
        uint256 private gTokenAmount;
        uint256[5] public totalHeros;
        uint256[10] public randcount;    
        uint256 constant public PERCENTS_DIVIDER = 1000;
        uint256 public HalfTime;
        uint256 public HalfNumber;
        uint256[5] public releaseNUmber;
        uint256[5] public needUSDT;
 
        bool swapping;
        
        IUniswapV2Router02 public uniswapV2Router;
        address payable public constant Wallet_Burn = payable(0x000000000000000000000000000000000000dEaD); 
        address public  Wallet_Gldy=0x8C06Af7B315Ab32b3593F8e3b37ce2D7F4688cDb; 
        address public  Wallet_Usdt=0x8C06Af7B315Ab32b3593F8e3b37ce2D7F4688cDb; 
        address public  Wallet_Qualify=0x78A5bC53ee1BB381958a56092F60800d14ac5cF2; 
        address public  Wallet_Rand=0x78A5bC53ee1BB381958a56092F60800d14ac5cF2; 
        address public Wallet_GboyPool=0x906E766c1686f18a9e067A8AD54acAD45c077d30;
        address public Wallet_FirstEcology=0x12358d1fC69689C286db5A42cF5c5B9F9D170B3a;
        address  public Wallet_Project = 0x36f2dAE586cC46fA9fbfe10DdadBbBbfFd178AD8;
        address  public Wallet_SharePoolWithdraw = 0x6AbDeb1FA303e45032545C070508BB01429143Bc;
        address  public  Wallet_Suby=0xB38B6A14657d9E531A1cE4A2c6450B41ca1A5497;

        struct WithDrawHis {
            uint256 amount;
            uint256 heroType;
            uint256 timestamp;
        }

        struct User {
            uint256[5] Heros;
            uint256 generalFrags;
            uint256 rareFrags;
            uint256[5] checkpoint;
            uint256[5] canwithdrawn;
            uint256[5] withdrawn;
            uint256 totalwithdraw;
            //WithDrawHis[] withDrawHis;
        }
 
        struct NeedQualify {
            uint256 generalFrags;
            uint256 rareFrags;
            uint256 amount;
        }
 
        mapping(address => uint256) public QualifyNumber;
        mapping(address => bool) private _whiteList;         
        mapping(address => User) private Users;         
        event useQualify(address indexed user, uint256 count);
        event Withdrawn(address indexed user, uint256 amount, uint256 herotype);
        event CompositeHero(address indexed user, uint256 herotype, uint256 mode);
        

        event BuyHero(address indexed user, uint256 herotype);
        event GiveHero(address indexed user, uint256 herotype);
       event OpenBlindBox(address indexed user,uint256 count,uint256[10] result);
            
        
        NeedQualify[2][5] public NeedQualifys;
	
        constructor()   {
            _owner = msg.sender;
            IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E); 
            //IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3); 
            uniswapV2Router = _uniswapV2Router;
            _beginTime = 1657022400;
            maxBurnAmount=200*10**18;
            gTokenAmount=10  * 10 ** 18;

            NeedQualifys[0][0]=NeedQualify(30,0,0);
            NeedQualifys[0][1]=NeedQualify(30,0,0);
            NeedQualifys[1][0]=NeedQualify(40,1,10);
            NeedQualifys[1][1]=NeedQualify(70,0,10);
            NeedQualifys[2][0]=NeedQualify(50,2,20);
            NeedQualifys[2][1]=NeedQualify(140,0,20);
            NeedQualifys[3][0]=NeedQualify(60,3,30);
            NeedQualifys[3][1]=NeedQualify(200,0,30);
            NeedQualifys[4][0]=NeedQualify(70,4,40);
            NeedQualifys[4][1]=NeedQualify(350,0,40);

            HalfTime=0;
            HalfNumber=0;
            releaseNUmber[0]=500*10**18;
            releaseNUmber[1]=1000*10**18;
            releaseNUmber[2]=2000*10**18;
            releaseNUmber[3]=3000*10**18;
            releaseNUmber[4]=5000*10**18;
            needUSDT[0]=500*10**18;
            needUSDT[1]=1000*10**18;
            needUSDT[2]=2000*10**18;
            needUSDT[3]=3000*10**18;
            needUSDT[4]=5000*10**18;
        }
        receive() external payable {}

        function withdraw(uint256 herotype) public {
            User storage user = Users[msg.sender];
            require(block.timestamp > _beginTime);
            uint256 totalAmount=Canwithdraw(msg.sender, herotype) ;
             totalAmount=totalAmount+user.canwithdrawn[herotype];
            require(totalAmount > 0, "User has no dividends");
            require(tokenInterFace(Wallet_Suby).balanceOf(address(this))>=totalAmount, "Not enough Suby");
            tokenInterFace(Wallet_Suby).transfer(msg.sender, totalAmount);
            user.checkpoint[herotype] = block.timestamp;
            user.withdrawn[herotype]=user.withdrawn[herotype].add(totalAmount);
            user.totalwithdraw = user.totalwithdraw.add(totalAmount);
            user.canwithdrawn[herotype]=0; 
            emit Withdrawn(msg.sender, totalAmount,herotype);
        }

        function Canwithdraw(address usersddr,uint256 herotype) public view returns(uint256) {
            User memory user = Users[usersddr];
            if(block.timestamp <= _beginTime)return 0;
            if(user.Heros[herotype] ==0 )return 0;
            if(totalHeros[herotype] ==0 )return 0;
            uint256 dividends;
            uint256 totalAmount;
            uint256 multiple;
            if(HalfNumber==0||HalfNumber==1 &&block.timestamp<HalfTime ){
                dividends = (user.Heros[herotype]
                            .mul(releaseNUmber[herotype]).div(totalHeros[herotype]))
                            .mul(block.timestamp.sub(user.checkpoint[herotype]))
                            .div(TIME_STEP);
                return dividends;
            }else{
                    if(block.timestamp>HalfTime){
                        if(user.checkpoint[herotype]>HalfTime)
                        {
                            if(HalfNumber==4){
                                dividends=0;
                            }else{
                                multiple=2**HalfNumber;
                                dividends = user.Heros[herotype]
                                    .mul(releaseNUmber[herotype]).div(totalHeros[herotype])
                                    .mul(block.timestamp.sub(user.checkpoint[herotype]));
                                 dividends =    dividends.div(TIME_STEP).div(multiple);
                             }
                            return dividends;
                        }else{
                            multiple=2**(HalfNumber);
                            dividends = (user.Heros[herotype]
                                .mul(releaseNUmber[herotype]).div(totalHeros[herotype]))
                                .mul(block.timestamp.sub(HalfTime));
                                dividends =    dividends.div(TIME_STEP).div(multiple);
                            multiple=2**(HalfNumber-1);
                            uint256  dividends2= (user.Heros[herotype]
                                .mul(releaseNUmber[herotype]).div(totalHeros[herotype]))
                                .mul(HalfTime.sub(user.checkpoint[herotype]));
                                dividends2=dividends2.div(TIME_STEP).div(multiple);
                           totalAmount=    dividends+dividends2;
                            return totalAmount;

                        }
                    }else{
                        multiple=2**(HalfNumber-1);
                        dividends = (user.Heros[herotype]
                                .mul(releaseNUmber[herotype]).div(totalHeros[herotype]))
                                .mul(block.timestamp.sub(user.checkpoint[herotype]));
                                dividends=dividends.div(TIME_STEP).div(multiple);
                                return dividends;
                    }
            }
        }


        function compositehero(uint256 heroType,uint256 mode) public   returns(bool)
        {
    
            require( block.timestamp>_beginTime , "It's not startTime");
            require( heroType<=4 , "heroType must<=4");
            require( mode<=1 , "mode must<=1");
            NeedQualify memory needQualify=NeedQualifys[heroType][mode];
            User storage user=Users[msg.sender];
            if(user.Heros[heroType]>0){
                needQualify.rareFrags=needQualify.rareFrags+1;
            }

            if(heroType>0){
                require( totalHeros[heroType-1]>=1000 , " previous heros must<=1000");
                require( user.Heros[heroType-1]>0 , "previous Heros must>0");
            }
            if(needQualify.amount>0){
                //U本位
                uint256  tokenAmount=GTokenAmount(needQualify.amount*10**18,2).mul(90).div(100);//tokenAmounts[0];
                require(tokenAmount > 0);
            
                uint256 balances =tokenInterFace(Wallet_Gldy).balanceOf(msg.sender);
                require(balances>=tokenAmount, "It's not enough Token");
                require( tokenInterFace(Wallet_Gldy).transferFrom(msg.sender,address(this), tokenAmount),"token transfer failed");
                //totalPool=totalPool+tokenAmount;
                bonus(msg.sender,tokenAmount);

                //这里怎么分要沟通一下
        
            }
            if(needQualify.rareFrags>0){
                require(user.rareFrags>=needQualify.rareFrags, "It's not enough rareFrags");
                user.rareFrags=user.rareFrags.sub(needQualify.rareFrags);
            }
            if(needQualify.generalFrags>0){
                require(user.generalFrags>=needQualify.generalFrags, "It's not enough generalFrags");
                user.generalFrags=user.generalFrags.sub(needQualify.generalFrags);
            }


            if(user.Heros[heroType]>0){
                uint256 totalAmount=Canwithdraw(msg.sender, heroType);
                user.canwithdrawn[heroType]=user.canwithdrawn[heroType]+totalAmount;
                
            }
            user.checkpoint[heroType]=block.timestamp;
            
            user.Heros[heroType]=user.Heros[heroType]+1;
            totalHeros[heroType]=totalHeros[heroType]+1;
            emit CompositeHero(msg.sender, heroType,mode);
        
            return true;
        }

        function bonus(address useraddr,uint256 tokenAmount) private  {

            uint256 burnAmount=tokenAmount.mul(200).div(PERCENTS_DIVIDER);
            uint256 referralBonus = tokenAmount.mul(300).div(PERCENTS_DIVIDER);
            uint256 contributionBonus = tokenAmount.mul(100).div(PERCENTS_DIVIDER);
            uint256 projectBonus = tokenAmount.mul(100).div(PERCENTS_DIVIDER);
            uint256 shareBonus = tokenAmount.sub(burnAmount).sub(burnAmount).sub(referralBonus).sub(contributionBonus).sub(projectBonus);


            address upline = poolInterFace(Wallet_GboyPool).getGtokenReferrer(useraddr);
            if(upline != address(0)){
                 tokenInterFace(Wallet_Gldy).transfer(upline, referralBonus);
            }
            else{
                totalBurn=totalBurn+referralBonus;
            }
            totalBurn=totalBurn+burnAmount;
            if (!swapping && totalBurn>=maxBurnAmount) {
                swapping = true;

                swapTokensForBNB(Wallet_Gldy,totalBurn);
                totalBurn=0;
                uint256 balance= address(this).balance;
                
                payable(Wallet_Suby).transfer(balance );
                swapping=false;
            }

            upline = poolInterFace(Wallet_GboyPool).Referrers(useraddr);
            while(upline != address(0)){
                if(poolInterFace(Wallet_GboyPool).Level(upline)==2||upline==_owner){
                    tokenInterFace(Wallet_Gldy).transfer(upline, contributionBonus);
                    break;
                }
                upline =poolInterFace(Wallet_GboyPool).Referrers(upline);
            }

            tokenInterFace(Wallet_Gldy).transfer(Wallet_Project, projectBonus);
            //tokenInterFace(Wallet_Gldy).transfer(Wallet_FirstEcology, shareBonus);
            tokenInterFace(Wallet_Gldy).transfer(Wallet_Burn, burnAmount);
            //poolInterFace(Wallet_SharePoolWithdraw).addSharePools(shareBonus,0,1);
            totalSharePool=totalSharePool+shareBonus;
                //添加加共享池
            if(totalSharePool>maxBurnAmount){
                poolInterFace(Wallet_SharePoolWithdraw).addSharePools(totalSharePool,0,0);
                tokenInterFace(Wallet_Gldy).transfer(Wallet_SharePoolWithdraw, totalSharePool);
                totalSharePool=0;

            }
                
        
        }


        function buyHero(uint256 heroType) public   returns(bool){
            require( block.timestamp>_beginTime , "It's not startTime");
            require( heroType<=4 , "heroType must<=4");

            User storage user=Users[msg.sender];
            if(heroType>0){
                require( totalHeros[heroType-1]>=1000 , " previous heros must<=1000");
                require( user.Heros[heroType-1]>0 , "previous Heros must>0");
            }
                //U本位
                uint256  tokenAmount=GTokenAmount(needUSDT[heroType],2).mul(90).div(100);//tokenAmounts[0];
                require(tokenAmount > 0);
            
                uint256 balances =tokenInterFace(Wallet_Gldy).balanceOf(msg.sender);
                require(balances>=tokenAmount, "It's not enough Token");
                require( tokenInterFace(Wallet_Gldy).transferFrom(msg.sender,address(this), tokenAmount),"token transfer failed");
                //totalPool=totalPool+tokenAmount;
                bonus(msg.sender,tokenAmount);

     
           
             if(user.Heros[heroType]>0){
                uint256 totalAmount=Canwithdraw(msg.sender, heroType);
                user.canwithdrawn[heroType]=user.canwithdrawn[heroType]+totalAmount;
                
            }
            user.checkpoint[heroType]=block.timestamp;
            
            user.Heros[heroType]=user.Heros[heroType]+1;
            totalHeros[heroType]=totalHeros[heroType]+1;
                
            emit BuyHero(msg.sender, heroType);
            return true;


        }

        function giveHero(address useraddr,uint256 heroType,uint256  count) public   returns(bool){
            require( count>0 , "count must>0");
            require( count<=10 , "count must<=50");
            require( heroType<=4 , "heroType must<=4");
            if(msg.sender == _owner||_whiteList[msg.sender]==true){
                if(Users[useraddr].Heros[heroType]>0){
                    uint256 totalAmount=Canwithdraw(useraddr, heroType);
                    Users[useraddr].canwithdrawn[heroType]=Users[useraddr].canwithdrawn[heroType]+totalAmount;
                    
                }
                Users[useraddr].checkpoint[heroType]=block.timestamp;
                Users[useraddr].Heros[heroType]=Users[useraddr].Heros[heroType]+count;
                totalHeros[heroType]=totalHeros[heroType]+count;
                emit GiveHero(msg.sender, heroType);
            
            }
            return true;
        }

        function openBlindBox(uint256 count) public   returns(uint256,uint256[10] memory){
            require( block.timestamp>_beginTime , "It's not startTime");
            require( count>0 , "count must>0");
            require( count<=10 , "count must<=10");
            uint256 qualifyNumber=tokenInterFace(Wallet_Qualify).QualifyNumber(msg.sender);
            require(qualifyNumber >= count, "qualifyNumber must>count");
            
            uint256  tokenAmount=GTokenAmount(gTokenAmount,2).mul(90).div(100);//tokenAmounts[0];
            require(tokenAmount > 0, "tokenAmount must>0");
            uint256 amount=tokenAmount*count;
            uint256 balances =tokenInterFace(Wallet_Gldy).balanceOf(msg.sender);
            require(balances>=amount, "It's not enough Token");
            require( tokenInterFace(Wallet_Gldy).transferFrom(msg.sender,address(this), amount),"token transfer failed");
            tokenInterFace(Wallet_Qualify).UseQualify(msg.sender, count);
            User storage user=Users[msg.sender];
            
 
            uint256[10] memory result;
            for(uint256 i=0;i<count;i++){
                uint256 rand=tokenInterFace(Wallet_Rand).rand(msg.sender,randcount);
                result[i]=rand;
                if(rand>=0  && rand<5){
                    user.Heros[rand]= user.Heros[rand]+1;
                    tokenInterFace(Wallet_Rand).reSetList(msg.sender,rand);
                    if(user.Heros[rand]>0){
                        uint256 totalAmount=Canwithdraw(msg.sender, rand);
                        user.canwithdrawn[rand]=user.canwithdrawn[rand]+totalAmount;
                        
                    }
                    user.checkpoint[rand]=block.timestamp;

                    randcount[rand]=randcount[rand]+1;
                    totalHeros[rand]=totalHeros[rand]+1;
                }else if(rand==5){
                    if(poolInterFace(Wallet_GboyPool).gtokeUsers(msg.sender)==true){
                        user.rareFrags= user.rareFrags+1;
                        randcount[6]=randcount[6]+1;
                        result[i]=6;
                    }else{
                        poolInterFace(Wallet_FirstEcology).addGToken(msg.sender);
                        randcount[5]=randcount[5]+1;
                        //result[i]=5;
                    }
                    //Users[msg.sender].Heros[0]= Users[msg.sender].Heros[0]+1;
                    
                }else if(rand==6){
                    user.rareFrags= user.rareFrags+1;
                    randcount[6]=randcount[6]+1;
                    //result[i]=6;
                    
                }else{
                    user.generalFrags= user.generalFrags+1;
                    randcount[7]=randcount[7]+1;
                    //result[i]=7;
                }
                randcount[8]=randcount[8]+1;
            }
            bonus(msg.sender, amount); 
            emit OpenBlindBox(msg.sender,count,result);
            return(count,result);
        }



        function GTokenAmount(uint256 Amount,uint256 index) public view returns(uint256){
                uint256[] memory tokenAmounts=getAmounts(Wallet_Usdt,Wallet_Gldy,Amount);
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

        function SetgTokenAmount(uint256 value ) public {
            require(_owner == msg.sender);
            gTokenAmount= value;
        
        }  
        function SetNeedUsdt(uint256 index, uint256 value ) public {
            require(_owner == msg.sender);
            needUSDT[index] = value;
        
        }  

        function SetHalfTime( uint256 value ) public {
            require(_owner == msg.sender);
            HalfTime= value;
        
        }  
        function SetHalfNumber( uint256 value ) public {
            require(_owner == msg.sender);
            HalfNumber= value;
        
        }

        function AddGeneralFrags(address useraddr, uint256 value ) public {
            require(_owner == msg.sender);
            Users[useraddr].generalFrags = Users[useraddr].generalFrags+value;
        
        }  
        function AddRareFrags(address useraddr, uint256 value ) public {
            require(_owner == msg.sender);
            Users[useraddr].rareFrags = Users[useraddr].rareFrags+value;
        
        }  

        function setbeginTime(uint256 beginTime ) public {
            require(_owner == msg.sender);
            _beginTime = beginTime;
        
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
        function setQualifyAddress(address coinAddr) public {
             require(_owner == msg.sender);
            Wallet_Qualify=coinAddr;
        }
        function setRandAddress(address coinAddr) public {
             require(_owner == msg.sender);
            Wallet_Rand=coinAddr;
        }
        function setSharePoolAddress(address coinAddr) public {
             require(_owner == msg.sender);
            Wallet_SharePoolWithdraw=coinAddr;
        }
        function setSubyAddress(address coinAddr) public {
             require(_owner == msg.sender);
            Wallet_Suby=coinAddr;
        }

        function bindOwner(address addressOwner) public{
            require(_owner == msg.sender);
            _owner = addressOwner;

        }



        function getUserHeros(address addr)  public view returns (uint256,uint256,uint256,uint256,uint256){
            
            return (Users[addr].Heros[0],Users[addr].Heros[1],Users[addr].Heros[2],Users[addr].Heros[3],Users[addr].Heros[4]);
        }

        function getUserFrags(address addr)  public view returns (uint256,uint256){
            
            return (Users[addr].generalFrags,Users[addr].rareFrags);
        }
        function getUsercheckpoint(address addr)  public view returns (uint256,uint256,uint256,uint256,uint256){
            
            return (Users[addr].checkpoint[0],Users[addr].checkpoint[1],Users[addr].checkpoint[2],Users[addr].checkpoint[3],Users[addr].checkpoint[4]);
        }
        function getUsercanwithdrawn(address addr)  public view returns (uint256,uint256,uint256,uint256,uint256){
            
            return (Users[addr].canwithdrawn[0],Users[addr].canwithdrawn[1],Users[addr].canwithdrawn[2],Users[addr].canwithdrawn[3],Users[addr].canwithdrawn[4]);
        }
        function getUserwithdrawn(address addr)  public view returns (uint256,uint256,uint256,uint256,uint256){
            
            return (Users[addr].withdrawn[0],Users[addr].withdrawn[1],Users[addr].withdrawn[2],Users[addr].withdrawn[3],Users[addr].withdrawn[4]);
        }
        function getUsertotalwithdraw(address addr)  public view returns (uint256){
            
            return (Users[addr].totalwithdraw);
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
       function QualifyNumber(address spender) external  returns (uint256);
       function UseQualify(address spender, uint256 count) external ;
       function rand(address spender,uint256[10] memory randcount) external  returns (uint256);
        function reSetList(address spender,uint256 rand) external  returns (bool);
       
       
    }


    interface  poolInterFace {
        function setSubyBonusStatus(bool status,uint256 value) external  returns (bool) ;
        function EndorsementUsers(address addr) external  view returns (uint256,uint256,uint256,bool);
         function addGToken(address useraddr) external;
       
        function CandyUsers(address addr) external view  returns (uint256,uint256,uint256);
        function Level(address addr) external  view returns (uint256);
        function PrivateUserCount() external view  returns (uint256);
        function totalEndorsementUsers() external  view returns (uint256);
        
        function Referrers(address addr) external view returns (address);
        function gtokeUsers(address addr) external  view returns (bool);
        function setReferrer(address addr,address referrer) external returns (bool);
        function setgtokeUsers(address addr,bool flag) external returns (bool);
        function getGtokenReferrer(address addr) external  view returns (address);
        function setLevel(address addr,uint32 value) external returns (bool);
       // function addSharePools(uint256 tokencount,uint256 amount,address useraddress,uint256 cointype) external  returns(bool);
        function addSharePools(uint256 amount,uint256 cointype,uint256 sharetype) external  returns(bool);
       
    }