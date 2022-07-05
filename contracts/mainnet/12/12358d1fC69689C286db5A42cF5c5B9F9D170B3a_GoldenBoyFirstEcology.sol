/**
 *Submitted for verification at BscScan.com on 2022-07-05
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


    contract GoldenBoyFirstEcology {
        using SafeMath for uint256;
        address private _owner;

        IUniswapV2Router02 public uniswapV2Router;
        uint256 constant public BASE_PERCENT = 10;
        uint256 constant public MAX_PERCENT = 30;
        uint256 constant public PERCENTS_DIVIDER = 1000;
        uint256 constant public TIME_STEP = 1 days;
        uint256 constant public HALF_YEAR = 180 days;
        uint256 constant public ONE_YEAR = 365 days;
        address payable public constant Wallet_Burn = payable(0x000000000000000000000000000000000000dEaD); 
        address public  Wallet_Market=0xc897D7597C7a5ad8aE280925B911bDe874939785; 
        address public Wallet_GboyPool;
        address  public Wallet_Project = 0x36f2dAE586cC46fA9fbfe10DdadBbBbfFd178AD8;
        
        uint256 public totalWithdrawnCandy;
        uint256 public  halfYearTime ;
        uint256 private GldyProjectBonus;
        uint256 private GldyPrivatetBonus;
        uint256 private projectwithdrawtime;
        uint256 private  projecttotalwithdraw;
        uint256 private   totalPrivateWithdraw;
        uint256 private  Privatewithdrawtime;
        uint256 private  SubyProjectBonus;
        uint256 private  SubyProjectBonusWithDraw;
        uint256 private  SubyGtokenBonus;
        uint256 private  SubyPrivateBonus;
        uint256 private  SubyPrivateBonusWithDraw;
        uint256 private  SubyBonusStartTime;
        bool private SubyBonusCanWithdraw;
        bool private _iscanCandy;
        bool private isburn;

        address public _gldycoinAddr;
        address public _subycoinAddr;
        address public usdtcoinAddr;
        uint256 public GtokenUserCount;
        uint256 public MaxGtokenUser;
        uint256 private gTokenAmount;
        uint256 public _beginGtokenTime;
        uint256 public _beginLPTime;
        uint256 private totalWithdrawn;
        uint256 public totalLP;
        uint256 private totalGivenLP;
        uint256 private LPBonus;
        uint256 private LPGivenBonus;
        uint256 public totalLPWithdrawn;
        uint256 public MaxSellFEE;
        
        uint256 totalBurn;
        bool swapping;
        struct Endorsement {
            uint256 withdrawn;
            uint256 checkpoint;
        }
        struct Deposit {
            uint256 start;
            uint256 amount;
            //uint256 checkpoint;
        }
        struct User {
            Deposit[] deposits;
            uint256 checkpoint;
            uint256 bonus;
            //uint256 canwithdraw;
            uint256 withdrawn;
            //uint256 totalLP;
        }
        struct GtokenBonus {
            address usersddr;
            address uplinkaddr;
            address getaddr;
            uint256 checkpoint;
            uint256 bonus;
            bool isGet;
        }
        
        uint256 public  totalCandyUsers;
 
        struct CandyUser {
           uint256 start;
            uint256 amount;
            uint256 recommendamount;
            uint256 unlockamount;
            uint256 checkpoint;
            uint256 withdrawn;
        }

        struct SharePool {
            uint256 checkpoint;
            uint256 bonus;
            uint256 PrivateUserCount;
            uint256 GtokenUserCount;
            uint256 cointype;
            uint256 sharetype;
        }

        SharePool[] public sharePools;
        mapping(address => uint256) public SharePoint;
        
        mapping(address => CandyUser) public CandyUsers;
        mapping(address => bool) private _whiteList;

        mapping(address => uint256) public SubyGtokenBonusTotalWithDraw;
         
        mapping(address => GtokenBonus[]) public gtokenBonus;
        mapping(address => GtokenBonus[]) public uplinkBonus;
        mapping(address => Endorsement) public EndorsementUsers;
        mapping(address => User) public LPUsers;
        
        tokenInterFace GldyToken;
        tokenInterFace SubyToken;
        poolInterFace GBoyPool;

        event CandyWithdrawn(address indexed user, uint256 amount);
        event NewCandy(address indexed user,address referrer);
        event CandyUnlock(address indexed user,uint256 amount);
        event privatewithdraw(address indexed user,uint256 amount);
        event ProjectWithdraw(address indexed user,uint256 amount);
        event Newbie(address user);
        event NewDeposit(address indexed user, uint256 amount);
        event Withdrawn(address indexed user, uint256 amount);
        event WithdrawnLP(address indexed user, uint256 amount);
         event buyGToken(address indexed user, uint256 amount);
        
	
        constructor()   {
            _owner = msg.sender;
            IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E); 
            //IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3); 
            uniswapV2Router = _uniswapV2Router;

            _beginGtokenTime = 1657022400;
            _beginLPTime = 1657022400;
            halfYearTime=1657022400+HALF_YEAR;
            gTokenAmount=300  * 10 ** 18;
            LPBonus=700* 10 ** 18;
            LPGivenBonus=300* 10 ** 18;
            MaxGtokenUser=20000;
            GldyProjectBonus =200000000*  10 ** 18;
            GldyPrivatetBonus=1500000000*  10 ** 18;
            SubyProjectBonus=1000000* 10 ** 18;
            SubyGtokenBonus=2000000* 10 ** 18;
            SubyPrivateBonus=1000000* 10 ** 18;
             _iscanCandy=true;
              MaxSellFEE=100000* 10 ** 18;
      
   
        }
        receive() external payable {}


    function sharePoolsWithdraw() public {
        require(GBoyPool.gtokeUsers(msg.sender)==true, "only GToken user Withdraw");
        uint256 rate=1;
        if(GBoyPool.Level(msg.sender)==2){
            rate=rate+10;
        }
        uint256 totaluser;
        uint256 dividends;
        uint256 totalGldy;
        uint256 totalBNB;
         
        for(uint256 i=SharePoint[msg.sender];i<sharePools.length;i++){
            totaluser=sharePools[i].PrivateUserCount*10+sharePools[i].GtokenUserCount;
            if(totaluser>0){
                dividends=sharePools[i].bonus*rate/totaluser;
                if(sharePools[i].cointype==0){
                    totalGldy=totalGldy+dividends;
                }else{
                    totalBNB=totalBNB+dividends;
                }
            }
            
        }
        require(totalGldy > 0 || totalBNB>0);
        if(totalGldy>0){
            require(GldyToken.balanceOf(address(this))>=totalGldy , "User has no dividends");
            GldyToken.transfer(msg.sender, totalGldy);
        }
        if(totalBNB>0){
            payable(msg.sender).transfer(totalBNB);
        }
        SharePoint[msg.sender]=sharePools.length;
    
    }
    
    function addSharePools(uint256 amount,uint256 cointype,uint256 sharetype) public  returns(bool){
        if(msg.sender == _owner||_whiteList[msg.sender]==true){
            uint256 PrivateUserCount=GBoyPool.PrivateUserCount();
            sharePools.push(SharePool(block.timestamp,amount,PrivateUserCount,GtokenUserCount,cointype,sharetype));
            
        }
        return true;
    }

        function Candy(address referrer) public   returns (bool){
            require(_iscanCandy == true, "It's not Candy");
            require( block.timestamp>_beginGtokenTime , "It's not startTime1");
             (,uint256 amount ,)= GBoyPool.CandyUsers(msg.sender) ;
            CandyUser  storage user=CandyUsers[msg.sender];
            require(user.amount == 0&& amount == 0);
            require(totalCandyUsers+GBoyPool.totalCandyUsers() < 100000);
            if (GBoyPool.Referrers(msg.sender) == address(0)  && referrer != msg.sender) {
                GBoyPool.setReferrer(msg.sender,referrer);
             }

            address ref=GBoyPool.Referrers(msg.sender) ;
            require(ref != address(0));
            require(GBoyPool.Referrers(ref) != address(0)||ref==_owner);

            user.start = block.timestamp;
            user.amount=3000 ;
            totalCandyUsers = totalCandyUsers.add(1);
            CandyUsers[ref].recommendamount=CandyUsers[ref].recommendamount.add(1500);
            emit NewCandy(msg.sender, referrer);
            return true;
        } 

        function candyUnlock() public{
            (,uint256 amount ,uint256 recommendamount)= GBoyPool.CandyUsers(msg.sender) ;
            CandyUser  storage user=CandyUsers[msg.sender];
            require(block.timestamp > _beginGtokenTime);
            uint256 totalamount=amount+recommendamount+user.amount+user.recommendamount;
            uint unlockamount=totalamount/3*10**18-user.unlockamount;
            require(unlockamount>0);
            uint balances = GldyToken.balanceOf(msg.sender);
            require(balances>=unlockamount, "It's not enough  Token");
            require( GldyToken.transferFrom(msg.sender,Wallet_Burn, unlockamount),"token transfer failed");
            if(user.unlockamount==0)user.checkpoint=block.timestamp;
            user.unlockamount= user.unlockamount+unlockamount;
            emit CandyUnlock(msg.sender, unlockamount);
            
       
        }
        function candyWithDraw() public{
            (,uint256 amount ,uint256 recommendamount)= GBoyPool.CandyUsers(msg.sender) ;
            CandyUser storage user=CandyUsers[msg.sender];
            require(block.timestamp > _beginGtokenTime);
            uint256 totalamount=(amount+recommendamount+user.amount+user.recommendamount)*10**18;
            require(user.unlockamount>0," unlock first");
            require(totalamount>0);
            uint256 dividends;
            require(user.withdrawn  < totalamount);
        
		    dividends = (totalamount.div(30))
						.mul(block.timestamp.sub(user.checkpoint))
						.div(TIME_STEP);
            
			if (user.withdrawn.add(dividends) > totalamount) {
					dividends = totalamount.sub(user.withdrawn);
			}
            if (user.withdrawn.add(dividends) > user.unlockamount.mul(3)) {
					dividends = user.unlockamount.mul(3).sub(user.withdrawn);
			}

			user.withdrawn = user.withdrawn.add(dividends); /// changing of storage data

            require(dividends > 0, "User has no dividends");
            require(GldyToken.balanceOf(address(this))>=dividends, "User has no dividends");
            GldyToken.transfer(msg.sender, dividends);
            user.checkpoint = block.timestamp;
            totalWithdrawnCandy = totalWithdrawnCandy.add(dividends);
            
            emit CandyWithdrawn(msg.sender, dividends);  
            
        }


        function SubyProjectBonusWithdraw() public {
            require(SubyBonusCanWithdraw ==true);
            require(SubyBonusStartTime <block.timestamp);
             uint256 dividends;
             uint256 totalAmount;
            require(msg.sender==Wallet_Project);
            dividends=SubyProjectBonus.mul(block.timestamp.sub(SubyBonusStartTime)).div(ONE_YEAR);
            totalAmount=dividends-SubyProjectBonusWithDraw;
            if(SubyProjectBonusWithDraw+totalAmount>SubyProjectBonus)totalAmount=SubyProjectBonus-SubyProjectBonusWithDraw;
            SubyProjectBonusWithDraw=SubyProjectBonusWithDraw+totalAmount;
            require(SubyToken.balanceOf(address(this))>=totalAmount , "User has no dividends");
            SubyToken.transfer(msg.sender, totalAmount);
            
        }

        function SubyPrivateBonusWithdraw() public {
            require(SubyBonusCanWithdraw ==true);
            require(SubyBonusStartTime <block.timestamp);
             uint256 dividends;
             uint256 totalAmount;
            require(msg.sender==Wallet_Market);
            dividends=SubyPrivateBonus.mul(block.timestamp.sub(SubyBonusStartTime)).div(ONE_YEAR);
            totalAmount=dividends-SubyPrivateBonusWithDraw;
            if(SubyPrivateBonusWithDraw.add(totalAmount)>SubyPrivateBonus)totalAmount=SubyPrivateBonus.sub(SubyPrivateBonusWithDraw);
            SubyPrivateBonusWithDraw=SubyPrivateBonusWithDraw.add(totalAmount);
            require(SubyToken.balanceOf(address(this))>=totalAmount , "User has no dividends");
            SubyToken.transfer(msg.sender, totalAmount);
        }



        function SubyGtokenBonusWithdraw() public {
            require(SubyBonusCanWithdraw ==true);
            require(SubyBonusStartTime <block.timestamp);
              uint256 dividends;
             uint256 totalAmount;
            require(GBoyPool.gtokeUsers(msg.sender)==true, "only GToken user Withdraw");
            
             dividends=SubyGtokenBonus.mul(block.timestamp.sub(SubyBonusStartTime)).div(ONE_YEAR).div(MaxGtokenUser);
            if(dividends>SubyGtokenBonus.div(MaxGtokenUser)) {
                dividends=SubyGtokenBonus.div(MaxGtokenUser);
            }
            totalAmount=dividends.sub(SubyGtokenBonusTotalWithDraw[msg.sender]);
            
            SubyGtokenBonusTotalWithDraw[msg.sender]=SubyGtokenBonusTotalWithDraw[msg.sender].add(totalAmount);
            require(SubyToken.balanceOf(address(this))>=totalAmount , "User has no dividends");
            SubyToken.transfer(msg.sender, totalAmount);


        }


    function Privatewithdraw() public {
            require(msg.sender==Wallet_Market||msg.sender==_owner);
            uint256 burnamount=GldyToken.balanceOf(Wallet_Burn);
            uint256 burnrate=burnamount.div(500000000*10**18);
            uint256 CanWithdraw;
            if(burnrate<=10){
                uint256 totalCanWithdraw=burnrate*50000000*10**18;
                CanWithdraw=totalCanWithdraw-totalPrivateWithdraw;
            }else{
                uint256 release1=500000000*10**18;
                uint256 dividends;
                if(Privatewithdrawtime> 0){
                    dividends=GldyPrivatetBonus.sub(release1).mul(block.timestamp.sub(Privatewithdrawtime)).div(ONE_YEAR);
                }
                else{
                    dividends=0;
                }
                CanWithdraw=release1+dividends-totalPrivateWithdraw;
            }
            if(burnrate>=10&&Privatewithdrawtime==0){
                Privatewithdrawtime=block.timestamp;
            }
            if(totalPrivateWithdraw+CanWithdraw>GldyPrivatetBonus)CanWithdraw=GldyPrivatetBonus-totalPrivateWithdraw;
            totalPrivateWithdraw=totalPrivateWithdraw+CanWithdraw;
            require(GldyToken.balanceOf(address(this))>=CanWithdraw , "User has no dividends");
             GldyToken.transfer(Wallet_Market, CanWithdraw);
            emit privatewithdraw(Wallet_Market, CanWithdraw);
    }


    function projectwithdraw() public {
            require(msg.sender==Wallet_Project||msg.sender==_owner);
            require(block.timestamp > halfYearTime);
            uint256 dividends;
            if(projectwithdrawtime> halfYearTime){
                dividends=GldyProjectBonus.mul(block.timestamp.sub(projectwithdrawtime)).div(HALF_YEAR);
            }
            else{
                dividends=GldyProjectBonus.mul(block.timestamp.sub(halfYearTime)).div(HALF_YEAR);
            }
            if(projecttotalwithdraw+dividends>GldyProjectBonus)dividends=GldyProjectBonus-projecttotalwithdraw;
            projecttotalwithdraw=projecttotalwithdraw+dividends;
            require(GldyToken.balanceOf(address(this))>=dividends , "User has no dividends");
             GldyToken.transfer(Wallet_Project, dividends);
             projectwithdrawtime=block.timestamp ;
            emit ProjectWithdraw(Wallet_Project, dividends);
         

    }

    function withdraw() public {
		 (uint256 amount,uint256 GLDYCoins,,bool isredeem)= GBoyPool.EndorsementUsers(msg.sender) ;
        Endorsement storage user = EndorsementUsers[msg.sender];
		require(amount>0 && isredeem ==false);
		
        uint256 userPercentRate =(GBoyPool.gtokeUsers(msg.sender)==true)?MAX_PERCENT:BASE_PERCENT;
        require(block.timestamp > _beginGtokenTime);
        require(isredeem ==false);
		uint256 dividends;
        require(user.withdrawn  < GLDYCoins);
		     
        uint256 checkpoint=(user.checkpoint > _beginGtokenTime)?user.checkpoint :_beginGtokenTime;
		     //if (user.checkpoint > _beginTime) {
        dividends = (GLDYCoins.mul(userPercentRate).div(PERCENTS_DIVIDER))
						.mul(block.timestamp.sub(checkpoint))
						.div(TIME_STEP);
          
		if (user.withdrawn.add(dividends) > GLDYCoins) {
			dividends =  GLDYCoins.sub(user.withdrawn);
		}


        user.withdrawn = user.withdrawn.add(dividends); 

		require(dividends > 0, "User has no dividends");
        require(GldyToken.balanceOf(address(this))>=dividends.mul(2), "Not enough Gldy");

        GldyToken.transfer(msg.sender, dividends);
        user.checkpoint = block.timestamp;
        GldyToken.transfer(Wallet_Burn, dividends);
    	totalWithdrawn = totalWithdrawn.add(dividends);
    	emit Withdrawn(msg.sender, dividends);

	}


    function BuyGToken(address referrer) public {
            uint256  tokenAmount=GTokenAmount(gTokenAmount,2).mul(90).div(100);//tokenAmounts[0];
            require(tokenAmount > 0);
            require(block.timestamp > _beginGtokenTime);
            uint balances = GldyToken.balanceOf(msg.sender);
            require(balances>=tokenAmount, "It's not enough  Token");
            require(GBoyPool.gtokeUsers(msg.sender)==false, "only buy once");
            require(GtokenUserCount<MaxGtokenUser);
            require( GldyToken.transferFrom(msg.sender,address(this), tokenAmount),"token transfer failed");
            GBoyPool.setgtokeUsers(msg.sender, true);
            GtokenUserCount=GtokenUserCount+1;
            if(GtokenUserCount==MaxGtokenUser){
                SubyBonusCanWithdraw=true;
                SubyBonusStartTime=block.timestamp;
            }
            if (GBoyPool.Referrers(msg.sender) == address(0) &&  referrer != msg.sender) {
                GBoyPool.setReferrer(msg.sender,referrer);
            }
        
            uint256 burnAmount=tokenAmount.mul(400).div(PERCENTS_DIVIDER);
            uint256 referralBonus = tokenAmount.mul(300).div(PERCENTS_DIVIDER);
		    uint256 contributionBonus = tokenAmount.mul(100).div(PERCENTS_DIVIDER);
		    uint256 projectBonus = tokenAmount.mul(100).div(PERCENTS_DIVIDER);
            uint256 shareBonus = tokenAmount.sub(burnAmount).sub(referralBonus).sub(contributionBonus).sub(projectBonus);
             
            
            GldyToken.transfer(Wallet_Burn, burnAmount);
            
            address upline = GBoyPool.Referrers(msg.sender);
            if(upline==_owner||GBoyPool.gtokeUsers(upline)==true){
               GldyToken.transfer(upline, referralBonus);
            }
            else{
                address upline2 = GBoyPool.Referrers(upline);
                gtokenBonus[upline].push(GtokenBonus(upline,upline2,address(0),block.timestamp,referralBonus,false));
                uplinkBonus[upline2].push(GtokenBonus(upline,upline2,address(0),block.timestamp,referralBonus,false));
            }
            upline = GBoyPool.Referrers(msg.sender);
			while(upline != address(0)){
                if(GBoyPool.Level(upline)==2||upline==_owner){
                    GldyToken.transfer(upline, contributionBonus);
                    break;
                }
                upline =GBoyPool.Referrers(upline);
			}

            GldyToken.transfer(Wallet_Project, projectBonus);
            uint256 PrivateUserCount=GBoyPool.PrivateUserCount();
            sharePools.push(SharePool(block.timestamp,shareBonus,PrivateUserCount,GtokenUserCount,0,0));
            SharePoint[msg.sender]=sharePools.length;
            
            emit buyGToken(msg.sender, tokenAmount);


    }

    function buyLP(address referrer,uint256 tokenAmount) public  {

            require(tokenAmount > 0);
            uint balances = GldyToken.balanceOf(msg.sender);
            require(balances>=tokenAmount, "It's not enough  Token");
            require(block.timestamp > _beginLPTime);
            require( GldyToken.transferFrom(msg.sender,address(this), tokenAmount),"token transfer failed");
           
            uint256 burnAmount=tokenAmount.mul(400).div(PERCENTS_DIVIDER);
            uint256 referralBonus = tokenAmount.mul(300).div(PERCENTS_DIVIDER);
		    uint256 contributionBonus = tokenAmount.mul(100).div(PERCENTS_DIVIDER);
		    uint256 projectBonus = tokenAmount.mul(100).div(PERCENTS_DIVIDER);
            uint256 shareBonus = tokenAmount.sub(burnAmount).sub(referralBonus).sub(contributionBonus).sub(projectBonus);
            
            if (GBoyPool.Referrers(msg.sender) == address(0) &&  referrer != msg.sender) {
                GBoyPool.setReferrer(msg.sender,referrer);
            }

            address upline = GBoyPool.getGtokenReferrer(msg.sender);
            if(upline != address(0)){
                GldyToken.transfer(upline, referralBonus);
			}
            else{
                burnAmount=burnAmount+referralBonus;
            }



            totalBurn=totalBurn+burnAmount;
            if (!swapping && totalBurn>=MaxSellFEE) {
                swapping = true;
                swapTokensForBNB(_gldycoinAddr,totalBurn);
                totalBurn=0;
                uint256 balance= address(this).balance;
                payable(_subycoinAddr).transfer(balance );
                swapping=false;
            }

            upline = GBoyPool.Referrers(msg.sender);
			while(upline != address(0)){
                if(GBoyPool.Level(upline)==2||upline==_owner){
                    GldyToken.transfer(upline, contributionBonus);
                    break;
                }
                upline =GBoyPool.Referrers(upline);
			}

            GldyToken.transfer(Wallet_Project, projectBonus);
            uint256 PrivateUserCount=GBoyPool.PrivateUserCount();
            sharePools.push(SharePool(block.timestamp,shareBonus,PrivateUserCount,GtokenUserCount,0,1));
             
            totalLP=totalLP+tokenAmount;
            User storage lpuser=LPUsers[msg.sender];
            lpuser.deposits.push(Deposit(block.timestamp,tokenAmount));
            emit NewDeposit(msg.sender, tokenAmount);
     
    }


    function withdrawLP() public {
		User storage lpuser = LPUsers[msg.sender];
		require(block.timestamp > _beginLPTime);
        uint256 dividends;
        uint checkpoint;
        uint256 totalAmount;

        for (uint256 i = 0; i < lpuser.deposits.length; i++) {
            if (lpuser.deposits[i].start > lpuser.checkpoint) {
                checkpoint=lpuser.deposits[i].start;
            }
            else{
                checkpoint=lpuser.checkpoint;
            }
            dividends = (lpuser.deposits[i].amount
                .mul(LPBonus).div(totalLP))
                .mul(block.timestamp.sub(checkpoint))
                .div(TIME_STEP);
            totalAmount = totalAmount.add(dividends);
        }
        (uint256 amount,,,bool isredeem)= GBoyPool.EndorsementUsers(msg.sender) ;
        uint256 totalEndorsementUsers= GBoyPool.totalEndorsementUsers();
        if(amount>0 && isredeem ==false){
             checkpoint=(lpuser.checkpoint > _beginLPTime)?lpuser.checkpoint:_beginLPTime;
                dividends = (LPGivenBonus.div(totalEndorsementUsers))
						.mul(block.timestamp.sub(checkpoint))
						.div(TIME_STEP);
            totalAmount = totalAmount.add(dividends);
        }
       require(totalAmount > 0, "User has no dividends");
        require(SubyToken.balanceOf(address(this))>=totalAmount, "Not enough Suby");
        SubyToken.transfer(msg.sender, totalAmount);
        lpuser.checkpoint = block.timestamp;
        totalLPWithdrawn = totalLPWithdrawn.add(totalAmount);
    	emit WithdrawnLP(msg.sender, totalAmount);

	}
    function CanwithdrawLP(address usersddr) public view returns(uint256) {
		User memory lpuser = LPUsers[usersddr];
		if(block.timestamp <= _beginLPTime)return 0;
        uint256 dividends;
        uint checkpoint;
        uint256 totalAmount;
        for (uint256 i = 0; i < lpuser.deposits.length; i++) {
            if (lpuser.deposits[i].start > lpuser.checkpoint) {
                checkpoint=lpuser.deposits[i].start;
            }
            else{
                checkpoint=lpuser.checkpoint;
            }
                   dividends = (lpuser.deposits[i].amount
                        .mul(LPBonus).div(totalLP))
                        .mul(block.timestamp.sub(checkpoint))
                        .div(TIME_STEP);
            totalAmount = totalAmount.add(dividends);
        }
        
        (uint256 amount,,,bool isredeem)= GBoyPool.EndorsementUsers(usersddr) ;
        uint256 totalEndorsementUsers= GBoyPool.totalEndorsementUsers();
        if(amount>0 && isredeem ==false){
            checkpoint=(lpuser.checkpoint > _beginLPTime)?lpuser.checkpoint:_beginLPTime;
            dividends = (LPGivenBonus.div(totalEndorsementUsers))
				.mul(block.timestamp.sub(checkpoint))
				.div(TIME_STEP);
            totalAmount = totalAmount.add(dividends);
       
        }

        return totalAmount;

	}
    
    function getgtokenBouns() public{
        if(msg.sender!=_owner){
            require(GBoyPool.gtokeUsers(msg.sender)==true, "Gtoken user first");
        }
        uint256 totalAmount;

        GtokenBonus[] storage bouns=gtokenBonus[msg.sender];
        for (uint256 i = 0; i < bouns.length; i++) {
            if(bouns[i].isGet==false && bouns[i].checkpoint<block.timestamp+TIME_STEP){
                totalAmount=totalAmount+bouns[i].bonus;
                bouns[i].isGet=true;
                bouns[i].getaddr=msg.sender;
            }
        }
        GtokenBonus[] storage upbouns=uplinkBonus[msg.sender];
        for (uint256 i = 0; i < upbouns.length; i++) {
            if(upbouns[i].isGet==false && upbouns[i].checkpoint<block.timestamp+TIME_STEP*2&&upbouns[i].checkpoint+TIME_STEP<block.timestamp){
                totalAmount=totalAmount+upbouns[i].bonus;
                upbouns[i].isGet=true;
                upbouns[i].getaddr=msg.sender;
            }
        }
        require(totalAmount > 0, "User has no dividends");
        require(GldyToken.balanceOf(address(this))>=totalAmount, "It's not enough  Token");
        GldyToken.transfer(msg.sender, totalAmount);
 
    }

    function getgtokenBounslength(address useraddr) public view returns(uint256,uint256){
        return (gtokenBonus[useraddr].length,gtokenBonus[useraddr].length);
    }
    function getsharePoolslength() public view returns(uint256){
        return (sharePools.length);
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
    function setbeginTime(uint256 gtokenTime,uint256 lpTime) public {
        require(_owner == msg.sender);
        _beginGtokenTime = gtokenTime;
        _beginLPTime = lpTime;

    }   

    function setMaxSellFEE(uint256 value)   public   returns (bool) {
        require(_owner == msg.sender);
       MaxSellFEE=value;
        return true;
    }


    function setGBoyPoolAddress(address wallet)  public {
             require(_owner == msg.sender);
            Wallet_GboyPool=wallet;
            GBoyPool=poolInterFace(Wallet_GboyPool);
    }

    function setMaxGtokenUser(uint256  value )  public {
             require(_owner == msg.sender);
           MaxGtokenUser=value;
    }


        function bindMarketAddress(address addr) public returns (bool){
            if(msg.sender == _owner){
                Wallet_Market=addr;
            }
            return true;
        }

         function bindProjectAddress(address addr) public returns (bool){
            if(msg.sender == _owner){
                Wallet_Project=addr;
            }
            return true;
        }

        function setCanCandy(bool value) public returns (bool){
            if(msg.sender == _owner){
                _iscanCandy=value;
            }
            return true;
        }

    function bindAddress(address MarketAddr,address ProjectAddr) public{
            require(_owner == msg.sender);
           Wallet_Market=MarketAddr;
            Wallet_Project=payable(ProjectAddr);
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

     function addGToken(address useraddr) public {
        if(msg.sender == _owner||_whiteList[msg.sender]==true){
            if(GBoyPool.gtokeUsers(useraddr)==false){
                GBoyPool.setgtokeUsers(useraddr, true);
                GtokenUserCount=GtokenUserCount+1;
                SharePoint[useraddr]=sharePools.length;
                if(GtokenUserCount==MaxGtokenUser){
                    SubyBonusCanWithdraw=true;
                    SubyBonusStartTime=block.timestamp;
                }
            }
        }
    }
    // Set new router and make the new pair address
        function setNewRouter(address newRouter)  public returns (bool){
            if(msg.sender == _owner){
                IUniswapV2Router02 _newPCSRouter = IUniswapV2Router02(newRouter);
                uniswapV2Router = _newPCSRouter;
            }
            return true;
        }
    function burnGldy() public returns (bool) {
            if(msg.sender == _owner){
                require(isburn==false);
                uint256 totalEndorsementUsers=GBoyPool.totalEndorsementUsers();
                uint256 burncoin=(2700-totalEndorsementUsers)*1500000*10**18*2;
                 GldyToken.transfer(Wallet_Burn, burncoin);   
                isburn=true;
            }
            return true;
        }


         function sethalfYearTime(uint256 value) public returns (bool) {
            if(msg.sender == _owner){
                halfYearTime=value;
            }
            return true;
        }

        function bindCoinAddress(address gldycoinAddr,address subycoinAddr) public  {
            require(_owner == msg.sender);
            _gldycoinAddr=gldycoinAddr;
            _subycoinAddr=subycoinAddr;
            GldyToken = tokenInterFace(_gldycoinAddr);
            SubyToken = tokenInterFace(subycoinAddr);
         }

        function setUsdtAddress(address coinAddr) public {
             require(_owner == msg.sender);
            usdtcoinAddr=coinAddr;
        }

        function bindOwner(address addressOwner) public{
            require(_owner == msg.sender);
            _owner = addressOwner;

        }
 
	function getUserAmountOfDeposits(address userAddress) public view returns(uint256) {
		return LPUsers[userAddress].deposits.length;
	}

	function getUserDeposits(address userAddress,uint256 index) public view returns(uint256,uint256) {
	    User memory user = LPUsers[userAddress];
        return (user.deposits[index].start,user.deposits[index].amount);

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