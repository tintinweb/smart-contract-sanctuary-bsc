/**
 *Submitted for verification at BscScan.com on 2022-03-13
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

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
interface ADRouter{
	function transferFroms(address token,address from,address to,uint256 amount) external ;
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
interface Mining{
	function router() external view returns (address);
}

contract ACDMining{
	using SafeMath for uint;
	address  public _owner;
	uint256 public allRewardDebt;
	uint256 public ADnum;
	uint256 public LPnum;
	uint256 public ADXnum;
	uint256 public totalAmount;
	address public router;
	uint256 salt = 0;
	uint256 public lastStartTime;
	uint256 public IntervalTime;
	uint256 public canWinNum;
	uint256 public winningrate;
	uint256 public condition = 0;
	uint256 public deadrate;
	uint256 public waitDead;
	uint256 public winIndex;
	uint256 public oneAddrCanLiquidateNum = 20;
	uint256 public accumulateAD = 0;
	uint256 public liquidateReward;
	address[] public addrList;
	mapping(address => uint256)addrListIndex;

	struct User {
    uint256 lpamount;
    uint256 ADamount;
    uint256 myRewardDebt;
	uint256 DigADXForRewardDebt;
	uint256 myRewardDebtByADX;
	uint256 condition;
	
}	
    mapping (address => User) internal users;
	address public ADtoken;
	address public ADXtoken;
	address public ADXtokenFrom;
	address public uniswapV2Pair;
	address public deadwallet;
	
	
    constructor() public {
        _owner = msg.sender;
		
		router = Mining(0xDfE8BE15c21Ac151bEDe90D0b52f9FC10aDf9FEA).router();//lp????????????
		allRewardDebt = 0;
		ADtoken = 0x6a0D1655f74a9856Ee450FBA023C0580D7fC5268;//AD????????????
		ADXtoken = 0x4eC7928Bb924DdD09f12c302Df28e510fB475F59;//ADX????????????
        uniswapV2Pair = 0x5cAFeb7B27935885f72fBF23eF1c4EDdcBA0CE6C;//lp??????
		ADXtokenFrom = 0xB4ad4E144bE33Bf4aE7ff7479aE129D6b99BC287;//ADX????????????
		ADnum = 50000 * 10**18;//????????????????????????AD
		LPnum = 100;//????????????????????????LP???????????????100000???
		ADXnum = 5 * 10**18;//???????????????ADX??????
		IERC20(uniswapV2Pair).approve(router,~uint256(0));
		IERC20(ADtoken).approve(router,~uint256(0));
		lastStartTime = 1647259200;//?????????????????????(?????????)
		IntervalTime = 86400;//????????????
		winningrate = 100;//???????????????????????????1000???
		deadrate = 100;//?????????????????????1000???
		deadwallet = address(0xdead);//????????????
		liquidateReward = 500 * 10**18;//????????????AD??????
		
		}
		
	
		modifier onlyOwner() {
        require(msg.sender == _owner, "Ownable: caller is not the owner");
        _;
    }
	    receive() external payable {

  	}
	function invest() public {
		require(condition == 0);
		User storage user = users[msg.sender];
		require(user.condition == 0);
		ADRouter(router).transferFroms(ADtoken,msg.sender,address(this),ADnum);
		uint256 LPamount = (IERC20(uniswapV2Pair).totalSupply()).mul(LPnum).div(100000);
		ADRouter(router).transferFroms(uniswapV2Pair,msg.sender,address(this),LPamount);
		user.myRewardDebt = allRewardDebt;
		user.lpamount = LPamount;
		user.ADamount = ADnum;
		user.condition = 1;
		totalAmount = totalAmount.add(ADnum);
		addrListIndex[msg.sender] = addrList.length;
		addrList.push(msg.sender);
		
	}
	function Release() public {
		require(condition == 0);
		User storage user = users[msg.sender];
		if(user.condition == 1){
		uint256 totalADamount = (user.ADamount).add((allRewardDebt-user.myRewardDebt).mul(user.ADamount).div(10**12));
		IERC20(ADtoken).transfer(msg.sender,totalADamount);
		IERC20(uniswapV2Pair).transfer(msg.sender,user.lpamount);
		totalAmount = totalAmount.sub(user.ADamount);
		user.myRewardDebt = allRewardDebt;
		user.condition = 0;
		addrList[addrListIndex[msg.sender]] = addrList[addrList.length-1];
		addrListIndex[addrList[addrList.length-1]] = addrListIndex[msg.sender];
		addrList.pop();
		
		}
		if(user.condition == 2){
		uint256 totalADamount = (user.DigADXForRewardDebt-user.myRewardDebt).mul(user.ADamount).div(10**12);
		IERC20(ADtoken).transfer(msg.sender,totalADamount);
		IERC20(uniswapV2Pair).transfer(msg.sender,user.lpamount);
		IERC20(ADXtoken).transferFrom(ADXtokenFrom,msg.sender,user.myRewardDebtByADX);
		user.myRewardDebt = allRewardDebt;
		user.condition = 0;
		user.myRewardDebtByADX = 0;
		}
	}
	//????????????
	function liquidate() public {
		if(now > lastStartTime+IntervalTime){
			if(condition == 0){
				condition = 1;
				canWinNum = (addrList.length).mul(winningrate).div(1000);
				winIndex = 0;
			}
			uint256 a = winIndex+oneAddrCanLiquidateNum < canWinNum ? winIndex+oneAddrCanLiquidateNum : canWinNum;
			uint256 Random;
			uint256 winner;
			for(uint i = winIndex;i < a; i++){
				Random = getRandomNumber();
				winner = Random % (addrList.length);
                address winneraddr = addrList[winner];
				users[winneraddr].condition = 2;
				users[winneraddr].DigADXForRewardDebt = allRewardDebt;
				users[winneraddr].myRewardDebtByADX = ADXnum.mul(users[winneraddr].ADamount).div(ADnum);
				accumulateAD = accumulateAD.add((users[winneraddr].ADamount).mul(1000-deadrate).div(1000));
				waitDead = waitDead.add((users[winneraddr].ADamount).mul(deadrate).div(1000));
				totalAmount = totalAmount.sub(users[winneraddr].ADamount);
                addrList[addrListIndex[winneraddr]] = addrList[addrList.length-1];
		        addrListIndex[addrList[addrList.length-1]] = addrListIndex[winneraddr];
				addrList.pop();
                winIndex++;
			}
			IERC20(ADtoken).transfer(msg.sender,liquidateReward);
			waitDead = waitDead.sub(liquidateReward);
			if(a == canWinNum){
				condition = 0;
				lastStartTime = lastStartTime+IntervalTime;
				allRewardDebt = allRewardDebt.add(accumulateAD.mul(10**12).div(totalAmount));
				accumulateAD = 0;
				IERC20(ADtoken).transfer(deadwallet,waitDead.div(10));
				
			}
		}	
	}
	function getRandomNumber() private returns(uint256) {
        uint256 rand = uint256(keccak256(abi.encodePacked(now, msg.sender, salt)));
        salt++;        
        return rand;
    }
	function getTotalNum() public view returns(uint256){
		return addrList.length;
	}
	function getmyRewardDebt()public view returns(uint256){
	User storage user = users[msg.sender];
	uint256 a;
	if(user.condition == 0){
		a = 0;
	}
	if(user.condition == 1){
		a = (allRewardDebt - user.myRewardDebt).mul(user.ADamount);
	}
		if(user.condition == 2){
		a = (user.DigADXForRewardDebt - user.myRewardDebt).mul(user.ADamount);
	}
	return a;
	}
	function getUser()public view returns(uint256,uint256,uint256,uint256,uint256,uint256){
	User storage user = users[msg.sender];
	return(user.lpamount,user.ADamount,user.myRewardDebt,
	user.DigADXForRewardDebt,
	user.myRewardDebtByADX,user.condition);
	}
	//???????????????
	function setOwner(address newOwner) public onlyOwner{
		_owner = newOwner;
	}
	//?????????????????????AD??????
	function setADnum(uint256 a)public onlyOwner{
		ADnum = a;
	}
	//?????????????????????LP?????????????????????100000???
	function setLPnum(uint256 a)public onlyOwner{
		LPnum = a;
	}
	//???????????????????????????ADX
	function setADXnum(uint256 a)public onlyOwner{
		ADXnum = a;
	}
		//??????????????????
	function setIntervalTime(uint256 a)public onlyOwner{
		IntervalTime = a;
	}
	//????????????????????????????????????????????????
	function setlastStartTime(uint256 a)public onlyOwner{
		lastStartTime = a;
	}
	//??????????????????????????????????????????????????????????????????1000?????????10%?????????100???
	function setwinningrate(uint256 a)public onlyOwner{
		winningrate = a;
	}
	//??????????????????????????????1000???
	function setdeadrate(uint256 a)public onlyOwner{
		deadrate = a;
	}
	//????????????????????????????????????????????????
	function setoneAddrCanLiquidateNum(uint256 a)public onlyOwner{
		oneAddrCanLiquidateNum = a;
	}
	//????????????????????????AD??????
	function setliquidateReward(uint256 a)public onlyOwner{
		liquidateReward = a;
	}
}