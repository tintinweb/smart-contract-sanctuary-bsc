/**
 *Submitted for verification at BscScan.com on 2022-07-01
*/

// SPDX-License-Identifier: Unlicensed

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}


// Dependency file: contracts/interfaces/IUniswapV2Router02.sol

// pragma solidity >=0.6.2;

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
        address public _burnAddress = 0x000000000000000000000000000000000000dEaD;
        address public  Wallet_Market=0xc897D7597C7a5ad8aE280925B911bDe874939785; 
        address public Wallet_bonus;
        address public Wallet_GboyPool;
        address  public Wallet_Project = 0x36f2dAE586cC46fA9fbfe10DdadBbBbfFd178AD8;
        address public _gldycoinAddr;
        address public _subycoinAddr;
        address public usdtcoinAddr;
        uint256 public GtokenUserCount;
        uint256 public MaxGtokenUser;
        uint256 private gTokenAmount;
        uint256 private _beginTime;
        uint256 private totalWithdrawn;
        uint256 private totalLP;
        uint256 private totalGivenLP;
        uint256 private LPBonus;
        uint256 private LPGivenBonus;
        uint256 private totalLPWithdrawn;
        bool private isRelease;
        
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
        }
        struct GtokenBonus {
            address usersddr;
            address uplinkaddr;
            address getaddr;
            uint256 checkpoint;
            uint256 bonus;
            bool isGet;
        }
        
        mapping(address => GtokenBonus[]) private gtokenBonus;
        mapping(address => GtokenBonus[]) private uplinkBonus;
        mapping(address => Endorsement) public EndorsementUsers;
        mapping(address => User) public LPUsers;
        mapping(address => bool) private _whiteList;
        
        tokenInterFace GldyToken;
        tokenInterFace SubyToken;
        poolInterFace GBoyPool;
        poolInterFace BonusPool;

        event Newbie(address user);
        event NewDeposit(address indexed user, uint256 amount,uint lptype);
        event Withdrawn(address indexed user, uint256 amount);
        event WithdrawnLP(address indexed user, uint256 amount);
         event buyGToken(address indexed user, uint256 amount);
        
	
        constructor()   {
            _owner = msg.sender;
            //IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E); 
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3); 
            uniswapV2Router = _uniswapV2Router;
        
            _beginTime = block.timestamp;//开始释放时间
            gTokenAmount=1* 10 ** 18;
            //gTokenAmount=300  * 10 ** 18;
            LPBonus=700* 10 ** 18;
            LPGivenBonus=300* 10 ** 18;
            MaxGtokenUser=20000;
    
        }
        receive() external payable {}

    //公募提现，1、无令牌1%，有令牌3%，已赎回不能提现，同步赠送LP 与购买LP有区别   
	function withdraw() public {
		 (uint256 amount,uint256 GLDYCoins,,bool isredeem)= GBoyPool.EndorsementUsers(msg.sender) ;
        Endorsement storage user = EndorsementUsers[msg.sender];
		require(amount>0 && isredeem ==false);
		
        uint256 userPercentRate =(GBoyPool.gtokeUsers(msg.sender)==true)?MAX_PERCENT:BASE_PERCENT;
        require(block.timestamp > _beginTime);
        require(isredeem ==false);
		uint256 dividends;
        require(user.withdrawn  < GLDYCoins);
		     
        uint256 checkpoint=(user.checkpoint > _beginTime)?user.checkpoint :_beginTime;
		     //if (user.checkpoint > _beginTime) {
        dividends = (GLDYCoins.mul(userPercentRate).div(PERCENTS_DIVIDER))
						.mul(block.timestamp.sub(checkpoint))
						.div(TIME_STEP);
          
		if (user.withdrawn.add(dividends) > GLDYCoins) {
			dividends =  GLDYCoins.sub(user.withdrawn);
		}


        user.withdrawn = user.withdrawn.add(dividends); /// changing of storage data

		require(dividends > 0, "User has no dividends");
        require(GldyToken.balanceOf(address(this))>=dividends.mul(2), "Not enough Gldy");

        GldyToken.transfer(msg.sender, dividends);
        user.checkpoint = block.timestamp;
          
        //赠送同数量LP，改成销毁同数量的母币
       // _addGivenLP(msg.sender, dividends);
        GldyToken.transfer(_burnAddress, dividends);
    	totalWithdrawn = totalWithdrawn.add(dividends);
    	emit Withdrawn(msg.sender, dividends);

	}



    function getUserDividends(address userAddress) public view returns (uint256) {
		(,uint256 GLDYCoins,,bool isredeem)= GBoyPool.EndorsementUsers(userAddress) ;
        Endorsement storage user = EndorsementUsers[msg.sender];
		uint256 userPercentRate =(GBoyPool.gtokeUsers(msg.sender)==true)?MAX_PERCENT:BASE_PERCENT;
        if(block.timestamp < _beginTime)return 0;
        if(isredeem ==true)return 0;
		uint256 dividends;
        if(user.withdrawn  >= GLDYCoins)return 0;
        uint256 checkpoint=(user.checkpoint > _beginTime)?user.checkpoint :_beginTime;
		dividends = (GLDYCoins.mul(userPercentRate).div(PERCENTS_DIVIDER))
						.mul(block.timestamp.sub(checkpoint))
						.div(TIME_STEP);
        if (user.withdrawn.add(dividends) > GLDYCoins) {
					dividends =  GLDYCoins.sub(user.withdrawn);
		}

		return dividends;
	}

    
    //300USDT等额的母币进行购买，40%销毁，30%令牌推荐，10% 共享池。。。。
    //上线没令牌给24小时激活时间，再往上再给24小时，再往上直接销毁
    //如果上线是主帐号，则直接转帐
    //总量20000个
    //先要授权母币给合约
    function BuyGToken(address referrer) public {
            //uint256[] memory tokenAmounts=getAmounts(usdtcoinAddr,_gldycoinAddr,gTokenAmount);
            uint256  tokenAmount=GTokenAmount(gTokenAmount,2).mul(90).div(100);//tokenAmounts[0];
            require(tokenAmount > 0);
            require(block.timestamp > _beginTime);
            uint balances = GldyToken.balanceOf(msg.sender);
            require(balances>=tokenAmount, "It's not enough  Token");
            require(GBoyPool.gtokeUsers(msg.sender)==false, "only buy once");
            require(GtokenUserCount<MaxGtokenUser);
            require( GldyToken.transferFrom(msg.sender,address(this), tokenAmount),"token transfer failed");
            GBoyPool.setgtokeUsers(msg.sender, true);
            GtokenUserCount=GtokenUserCount+1;
            if(GtokenUserCount==MaxGtokenUser){
                BonusPool.setSubyBonusStatus(true,block.timestamp);
            }
            if (GBoyPool.Referrers(msg.sender) == address(0) &&  referrer != msg.sender) {
                GBoyPool.setReferrer(msg.sender,referrer);
            }
        
            uint256 burnAmount=tokenAmount.mul(400).div(PERCENTS_DIVIDER);
            uint256 referralBonus = tokenAmount.mul(300).div(PERCENTS_DIVIDER);
		    uint256 contributionBonus = tokenAmount.mul(100).div(PERCENTS_DIVIDER);
		    uint256 projectBonus = tokenAmount.mul(100).div(PERCENTS_DIVIDER);
            uint256 shareBonus = tokenAmount.sub(burnAmount).sub(referralBonus).sub(contributionBonus).sub(projectBonus);
             
            
            GldyToken.transfer(_burnAddress, burnAmount);
            //查找上线令牌并赠送
            address upline = GBoyPool.Referrers(msg.sender);
            if(upline==_owner||GBoyPool.gtokeUsers(upline)==true){
               GldyToken.transfer(upline, referralBonus);
            }
            else{
                address upline2 = GBoyPool.Referrers(upline);
                gtokenBonus[upline].push(GtokenBonus(upline,upline2,address(0),block.timestamp,referralBonus,false));
                uplinkBonus[upline2].push(GtokenBonus(upline,upline2,address(0),block.timestamp,referralBonus,false));
            }
           GldyToken.transfer(Wallet_Market, contributionBonus);
            GldyToken.transfer(Wallet_Project, projectBonus);
            GldyToken.transfer(Wallet_bonus, shareBonus);
            BonusPool.addSharePools(GtokenUserCount,shareBonus,msg.sender,0);

            // SharePoint[msg.sender]=sharePools.length;
            emit buyGToken(msg.sender, tokenAmount);


    }

    //购买LP：不限金额，40%销毁，30%上线。。。。

    function buyLP(address referrer,uint256 tokenAmount) public  {

            require(tokenAmount > 0);
            uint balances = GldyToken.balanceOf(msg.sender);
            require(balances>=tokenAmount, "It's not enough  Token");
            require( GldyToken.transferFrom(msg.sender,address(this), tokenAmount),"token transfer failed");
           
            uint256 burnAmount=tokenAmount.mul(400).div(PERCENTS_DIVIDER);
            uint256 referralBonus = tokenAmount.mul(300).div(PERCENTS_DIVIDER);
		    uint256 contributionBonus = tokenAmount.mul(100).div(PERCENTS_DIVIDER);
		    uint256 projectBonus = tokenAmount.mul(100).div(PERCENTS_DIVIDER);
            uint256 shareBonus = tokenAmount.sub(burnAmount).sub(referralBonus).sub(contributionBonus).sub(projectBonus);
            
            if (GBoyPool.Referrers(msg.sender) == address(0) &&  referrer != msg.sender) {
                GBoyPool.setReferrer(msg.sender,referrer);
            }

            //查找上线令牌并赠送,上线不存在，直接销毁 ？？？？？？

            address upline = GBoyPool.getGtokenReferrer(msg.sender);
            if(upline != address(0)){
                GldyToken.transfer(upline, referralBonus);
			}
            else{
                burnAmount=burnAmount+referralBonus;
            }
            totalBurn=totalBurn+burnAmount;
            if (!swapping /*&& totalBurn>=10000*10**18*/) {
                swapping = true;
                swapTokensForBNB(GldyToken,_gldycoinAddr,totalBurn);
                totalBurn=0;
                uint256 balance= address(this).balance;
                payable(_subycoinAddr).transfer(balance );
                swapping=false;
            }

            GldyToken.transfer(Wallet_Market, contributionBonus);
            GldyToken.transfer(Wallet_Project, projectBonus);
            BonusPool.addSharePools(GtokenUserCount,shareBonus,address(0),0);
            totalLP=totalLP+tokenAmount;
            User storage lpuser=LPUsers[msg.sender];
            lpuser.deposits.push(Deposit(block.timestamp,tokenAmount));
            emit NewDeposit(msg.sender, tokenAmount,0);
     
    }

    //LP提现，令牌奖励提现,赠送部分改成，每天300个由所有背书均分
    function withdrawLP() public {
		User storage lpuser = LPUsers[msg.sender];
		require(block.timestamp > _beginTime);
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
        //增加背书用户提取LP
        (uint256 amount,,,bool isredeem)= GBoyPool.EndorsementUsers(msg.sender) ;
        uint256 totalEndorsementUsers= GBoyPool.totalEndorsementUsers();
        if(amount>0 && isredeem ==false){
             checkpoint=(lpuser.checkpoint > _beginTime)?lpuser.checkpoint:_beginTime;
                dividends = (LPGivenBonus.div(totalEndorsementUsers))
						.mul(block.timestamp.sub(checkpoint))
						.div(TIME_STEP);
          
            totalAmount = totalAmount.add(dividends);
       
        }

        require(totalAmount > 0, "User has no dividends");
        require(SubyToken.balanceOf(address(this))>=totalAmount, "Not enough Suby");

        SubyToken.transfer(msg.sender, dividends);
        lpuser.checkpoint = block.timestamp;
           
        totalLPWithdrawn = totalLPWithdrawn.add(dividends);
        
		emit WithdrawnLP(msg.sender, totalAmount);

	}

    //添加LP可提现

//LP提现，令牌奖励提现,赠送部分改成，每天300个由所有背书均分
    function CanwithdrawLP() public view returns(uint256) {
		User memory lpuser = LPUsers[msg.sender];
		if(block.timestamp <= _beginTime)return 0;
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
        //增加背书用户提取LP
        (uint256 amount,,,bool isredeem)= GBoyPool.EndorsementUsers(msg.sender) ;
        uint256 totalEndorsementUsers= GBoyPool.totalEndorsementUsers();
        if(amount>0 && isredeem ==false){
            checkpoint=(lpuser.checkpoint > _beginTime)?lpuser.checkpoint:_beginTime;
            dividends = (LPGivenBonus.div(totalEndorsementUsers))
				.mul(block.timestamp.sub(checkpoint))
				.div(TIME_STEP);
            totalAmount = totalAmount.add(dividends);
       
        }

        return totalAmount;

	}
    
    //令牌奖励提现,加一个超时销毁判断wwww

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

    function getgtokenBounslength() public view returns(uint256,uint256){
        return (gtokenBonus[msg.sender].length,gtokenBonus[msg.sender].length);
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



    function swapTokensForBNB(tokenInterFace token ,address tokenaddress ,uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = tokenaddress;
        path[1] = uniswapV2Router.WETH();

        token.approve(address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }
    function setbeginTime(uint256 value) public {
        require(_owner == msg.sender);
        _beginTime = value;

    }   
    function setGBoyPoolAddress(address Wallet)  public {
             require(_owner == msg.sender);
            Wallet_GboyPool=Wallet;
            GBoyPool=poolInterFace(Wallet_GboyPool);
    }
    function setbonusAddress(address Wallet )  public  {
             require(_owner == msg.sender);
           Wallet_bonus=Wallet;
            BonusPool=poolInterFace(Wallet_bonus);
    }
    function setMaxGtokenUser(uint256  value )  public {
             require(_owner == msg.sender);
           MaxGtokenUser=value;
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
        
        function Referrers(address addr) external view returns (address);
        function gtokeUsers(address addr) external  view returns (bool);
        function setReferrer(address addr,address referrer) external returns (bool);
        function setgtokeUsers(address addr,bool flag) external returns (bool);
        function getGtokenReferrer(address addr) external  view returns (address);
        function setLevel(address addr,uint32 value) external returns (bool);
        function addSharePools(uint256 tokencount,uint256 amount,address useraddress,uint256 cointype) external  returns(bool);
        
    }