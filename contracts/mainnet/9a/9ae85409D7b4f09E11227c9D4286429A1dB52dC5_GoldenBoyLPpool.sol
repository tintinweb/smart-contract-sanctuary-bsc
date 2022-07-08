/**
 *Submitted for verification at BscScan.com on 2022-07-08
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
    contract GoldenBoyLPpool {
        using SafeMath for uint256;
        address private _owner;
        IUniswapV2Router02 public uniswapV2Router;
         uint256 constant public PERCENTS_DIVIDER = 1000;
        uint256 constant public TIME_STEP = 1 days;
        address payable public constant Wallet_Burn = payable(0x000000000000000000000000000000000000dEaD); 
        address public  Wallet_Market=0xc897D7597C7a5ad8aE280925B911bDe874939785; 
        address public Wallet_GboyPool;
        address  public Wallet_Project = 0x36f2dAE586cC46fA9fbfe10DdadBbBbfFd178AD8;
        address payable public Wallet_FirstEcology;
        bool private isburn;
        address public _gldycoinAddr;
        address public _subycoinAddr;
         uint256 public _beginLPTime;
         uint256 public totalLP;
        uint256 private totalGivenLP;
        uint256 private LPBonus;
        uint256 private LPGivenBonus;
        uint256 public totalLPWithdrawn;
        uint256 public MaxSellFEE;
        uint256 public totalBurn;
        bool private swapping;
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
        mapping(address => bool) private _whiteList;
        mapping(address => User) public LPUsers;
       
        tokenInterFace GldyToken;
        tokenInterFace SubyToken;
        poolInterFace GBoyPool;

        event CandyWithdrawn(address indexed user, uint256 amount);
        event NewCandy(address indexed user,address referrer);
        event CandyUnlock(address indexed user,uint256 amount);
        event NewDeposit(address indexed user, uint256 amount);
        event WithdrawnLP(address indexed user, uint256 amount);
        
	
        constructor()   {
            _owner = msg.sender;
            IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E); 
            //IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3); 
            uniswapV2Router = _uniswapV2Router;

            _beginLPTime = 1657022400;
            //_beginLPTime = block.timestamp;
            LPBonus=700* 10 ** 18;
            LPGivenBonus=300* 10 ** 18;
            MaxSellFEE=100000* 10 ** 18;
   
        }
        receive() external payable {}

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
        GldyToken.transfer(Wallet_FirstEcology, shareBonus);
        tokenInterFace(Wallet_FirstEcology).addSharePools(shareBonus,0,1);
        totalLP=totalLP+tokenAmount;
        User storage lpuser=LPUsers[msg.sender];
        lpuser.deposits.push(Deposit(block.timestamp,tokenAmount));
        emit NewDeposit(msg.sender, tokenAmount);
     
    }


    function swapAndAddPool(address subyAddr, uint256 amount) public {
        if(msg.sender == _owner){
            if (!swapping ) {
                swapping = true;
                if(amount>totalBurn){
                    amount=totalBurn;
                }
                swapTokensForBNB(_gldycoinAddr,amount);
                totalBurn=totalBurn-amount;
                uint256 balance= address(this).balance;
                payable(subyAddr).transfer(balance);
                swapping=false;
            }
        }

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
             if(lpuser.checkpoint > _beginLPTime){
                checkpoint=lpuser.checkpoint;
             }else{
                checkpoint=_beginLPTime;
             }
              
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
    function setWalletFirstEcology(address wallet)   public   returns (bool) {
        require(_owner == msg.sender);
         Wallet_FirstEcology=payable(wallet);
         return true;
    }
    function setLPBouns(uint256  bouns,uint256 givenBonus)   public   returns (bool) {
        require(_owner == msg.sender);
         LPBonus=bouns;
         LPGivenBonus=givenBonus;
         return true;
    }

    


    

    
    function remove_Random_Tokens(address random_Token_Address, uint256 percent_of_Tokens) public returns(bool _sent){
         require(_owner == msg.sender,'only owner');
       require(random_Token_Address != address(this), "Can not remove native token");
        uint256 totalRandom = IERC20(random_Token_Address).balanceOf(address(this));
        uint256 removeRandom = totalRandom*percent_of_Tokens/100;
        _sent = IERC20(random_Token_Address).transfer(_owner, removeRandom);
    }

        
    function AddLp(address useraddr,uint256 tokenAmount,uint256 timestamp) public{
        require(_owner == msg.sender);
        totalLP=totalLP+tokenAmount;
        User storage lpuser=LPUsers[useraddr];
        lpuser.deposits.push(Deposit(timestamp,tokenAmount));
        emit NewDeposit(msg.sender, tokenAmount);
    
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
    function setbeginTime( uint256 lpTime) public {
        require(_owner == msg.sender);
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

         function bindProjectAddress(address addr) public returns (bool){
            if(msg.sender == _owner){
                Wallet_Project=addr;
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


    // Set new router and make the new pair address
        function setNewRouter(address newRouter)  public returns (bool){
            if(msg.sender == _owner){
                IUniswapV2Router02 _newPCSRouter = IUniswapV2Router02(newRouter);
                uniswapV2Router = _newPCSRouter;
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
         function addSharePools(uint256 amount,uint256 cointype,uint256 sharetype) external  returns(bool);
        
        function GtokenUserCount() external view  returns (uint256);
    }

    interface  poolInterFace {
        function EndorsementUsers(address addr) external  view returns (uint256,uint256,uint256,bool);
        
        function Level(address addr) external  view returns (uint256);
        function totalEndorsementUsers() external  view returns (uint256);
         
        function Referrers(address addr) external view returns (address);
        function setReferrer(address addr,address referrer) external returns (bool);
        function getGtokenReferrer(address addr) external  view returns (address);
        function setLevel(address addr,uint32 value) external returns (bool);
        function addSharePools(uint256 tokencount,uint256 amount,address useraddress,uint256 cointype) external  returns(bool);
        
    }

    interface IERC20 {
    
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}