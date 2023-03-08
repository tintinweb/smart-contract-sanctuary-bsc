/**
 *Submitted for verification at BscScan.com on 2023-03-08
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
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
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
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
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

interface IW3swapRouter01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

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
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IW3swapRouter02 is IW3swapRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

contract YF3 {
    using SafeMath for uint256; 
	address public _usdtAddress = 0x55d398326f99059fF775485246999027B3197955;
	
    address takeAddress = 0xE1e198271A6C3da10c25115A6371FACDBC69f03F;
    address BAddress = 0x74F36b167b17298Cbc8FFd543e1f5dd71A448c30;
    address marketAddress = 0x3E4f5e3F97EF4D5dE72074Bdb078065Eadb21da1;
	
	address public contract1 = address(0x0B54948b93998c24B842E95D0dD90A407A9DD349);
	IW3swapRouter02 public router1 = IW3swapRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E);

    //0xBe87D06358A741D606a6861824c326C9B09f283D
	
	uint256 public maxLength = 10;
	uint256 public minTime = 15 days;
	uint256 public addTime = 1 days;
	uint public maxAddTime = 45 days;
	uint public startTime;
    uint public coinTime;
    uint public drawFeeTime;
    uint coinDay = 100;
    uint feeDay = 101;

    uint calTime = 1 days;

    mapping(address => bool) haveBind;
	
	bool startGiveCoin = false;
	
	uint totalUser = 0;
	
	uint minInput = 100e18;
	uint maxInput = 4000e18;
	
	uint[10] backPercent = [50, 10, 20, 30, 10, 20, 20, 20, 10, 10];
	
	uint[4] shareList = [980, 10, 5, 5];

    address destoryAddress = 0xf39A21d876A242De7618154085Ecc896438Ba94c;
	
	uint drawFee = 2;
	uint backStatic = 225;
	uint scoreNeed = 50;
	
	uint addOneDayBack = 1;
	uint minStartBack = 100;

    uint assetId = 0;

    bool canStatic = true;
    mapping (address => AssetLog[]) internal assetLogList;
	
	uint maxU = 0;

    uint userAddScore = 0;

    uint all = 1000;
    
	struct UserInfo {
		address bindAddress;
        uint256 logTime;
        uint256 level;
        uint256 maxDo;
		uint256 usdtAmount;
        uint256 scoreNum;  // total all doing
        uint256 teamNum;
        uint256 hasDoing;
		uint256 myDo;
        uint256 validCal;
		uint256 teamDo;
        uint256 freezePrize;
		uint256 hasBackFreezePrize;
        uint256 hasBack; // has get all prize
		uint256 haveHelpCount;
	}
 
	struct PrizeInfo {
		uint256 staticPrize;
		uint256 nextPrize;
		uint256 fivePrize;
        uint256 sixPrize;
	}
	
	struct HelpInfo {
        uint256 amount;
        uint256 logTime;
        uint256 endTime;
        bool isScore; 
        bool isBack;
        bool hasCal;
    }
	
	struct ReleaseInfo {
		uint256 amount;
		uint256 logTime;
		uint256 lastRealseDay;
		uint256 hasRealse;
	}
	
    struct AssetLog {
		uint _id;
		address userAddress;
		uint changeNum;
        uint changeType;
        bool add; // 0 add 1 sub
		uint logTime;
	}
	
	mapping (address => UserInfo) userInfo;
	mapping (address => PrizeInfo) prizeInfo;
	mapping (address => HelpInfo[]) helpInfoList;
	mapping (address => ReleaseInfo) releaseInfo;
	
	mapping(address => mapping(uint256 => address[])) teamUsers;
	
	
	event sendScore(address sendAddress, address receiverAddress, uint amount);
	event bindOne(address yourAddress, address bindAddress);
    event drawCoin(address yourAddress, uint amount);
    event getRelease(address yourAddress, uint amount);


    constructor(address scoreAddress) {
        userInfo[scoreAddress].scoreNum = 1e24;
    }

    function drawCoinFunction(uint amount) public {
        uint nowTime = block.timestamp;
        UserInfo memory yourInfo = userInfo[msg.sender];
        require(yourInfo.usdtAmount >= amount, "not enough money");
        yourInfo.usdtAmount = yourInfo.usdtAmount.sub(amount);

        IERC20 usdtContract = IERC20(_usdtAddress);
        uint feeAmount = amount.mul(drawFee).div(all);
        uint nowDay = nowTime / calTime;
		uint lastDay = startTime / calTime;

        if (nowDay.sub(lastDay) >= feeDay){
            IERC20 newCoin = IERC20(contract1);
            uint needCoin = getTokenPrice(1e18);
            needCoin = feeAmount.mul(1e18).div(needCoin);
            assert(newCoin.transferFrom(msg.sender, destoryAddress, needCoin) == true);
            usdtContract.transfer(msg.sender, amount);
        } else {
            usdtContract.transfer(msg.sender, amount.sub(feeAmount));
            usdtContract.transfer(BAddress, feeAmount);
        }

        userInfo[msg.sender] = yourInfo;
        assetLogList[msg.sender].push(AssetLog(++assetId, msg.sender, amount, 5, false, nowTime));
        emit drawCoin(msg.sender, amount);
    }

    function getMaxU() public view returns(uint, bool){
        return (maxU, startGiveCoin);
    }

    function gettotalUser() public view returns(uint){
        return totalUser;
    }

	function joinHelp(uint256 amount, bool doType) public {
		require(amount >= minInput && amount <= maxInput, "not valid amount");
		IERC20 usdtContract = IERC20(_usdtAddress);
		UserInfo memory yourInfo = userInfo[msg.sender];

		uint nowTime = block.timestamp;

        if (startTime == 0){
            startTime = nowTime;
            coinTime = nowTime.add(coinDay.mul(calTime));
            drawFeeTime = nowTime.add(feeDay.mul(calTime));
        }

		uint nowDay = nowTime / calTime;
		uint lastDay = startTime / calTime;

        if (yourInfo.validCal == 0 && yourInfo.bindAddress != address(0)){
            yourInfo.validCal = amount;
            updateTeamNum(msg.sender);
        }

        if (yourInfo.maxDo == 0){
            totalUser = totalUser.add(1);
            if (!startGiveCoin && nowDay.sub(lastDay) >= coinDay){
                startGiveCoin = true;
            }
        }

		if (!doType){
			if (startGiveCoin && yourInfo.maxDo == 0){
				giveNewCoin(msg.sender, amount);
			}
			
            //coin
            assert(usdtContract.transferFrom(msg.sender, takeAddress, amount.mul(shareList[3]).div(all)) == true);
            assert(usdtContract.transferFrom(msg.sender, BAddress, amount.mul(shareList[1]).div(all)) == true);
            assert(usdtContract.transferFrom(msg.sender, marketAddress, amount.mul(shareList[2]).div(all)) == true);
            assert(usdtContract.transferFrom(msg.sender, address(this), amount.mul(shareList[0]).div(all)) == true);
        } else {
            // score + coin
            assert(usdtContract.transferFrom(msg.sender, BAddress, amount.mul(scoreNeed).div(all)) == true);
			require(yourInfo.scoreNum >= amount, "not have enough score");
			yourInfo.scoreNum = yourInfo.scoreNum.sub(amount);

            assetLogList[msg.sender].push(AssetLog(++assetId, msg.sender, amount, 1, false, nowTime));
        }
		
		uint needDay = minTime;
		uint _addDay = yourInfo.haveHelpCount.div(2).mul(addTime);
		if (_addDay >= maxAddTime){
			needDay = needDay.add(maxAddTime);
		} else {
			needDay = needDay.add(_addDay);
		}

        if (amount > yourInfo.maxDo){
			yourInfo.maxDo = amount;
		}
        yourInfo.haveHelpCount = ++yourInfo.haveHelpCount;
        yourInfo.hasDoing = yourInfo.hasDoing.add(amount);

		userInfo[msg.sender] = yourInfo;

        backTeam(msg.sender, amount);
        rewardStatic(msg.sender, amount);
        _updateLevel(msg.sender);

		helpInfoList[msg.sender].push(HelpInfo(amount, nowTime, nowTime.add(needDay), doType, false, haveBind[msg.sender]));
		
		uint nowU = usdtContract.balanceOf(address(this));
		if (nowU >= maxU){
            if (!canStatic){
                canStatic = true;
            }
            
			maxU = nowU;
		}
	}
	
	function rewardStatic (address yourAddress, uint _amount) private {
		HelpInfo[] memory myHelp = helpInfoList[yourAddress];
		uint nowTime = block.timestamp;
		bool hasBack = false;
		uint backIndex = 0;
		uint addScore = 0;

		for (uint i = myHelp.length; i>0; i--){
			HelpInfo memory helpI = myHelp[i - 1];
			if (helpI.endTime <= nowTime && helpI.amount <= _amount && !helpI.isBack){
				hasBack = true;
				backIndex = i - 1;
				break;
			}
		}
		//-- 
		UserInfo memory yourInfo = userInfo[yourAddress];
		// static back need check
		
        IERC20 usdtContract = IERC20(_usdtAddress);
		uint nowU = usdtContract.balanceOf(address(this));        
		
		if (hasBack){
            HelpInfo memory nowHelp = helpInfoList[yourAddress][backIndex];

			helpInfoList[yourAddress][backIndex].isBack = true;

            if(nowHelp.hasCal){
                addScore = _amount.sub(nowHelp.amount);
            } else {
                addScore = _amount;
            }

            yourInfo.usdtAmount = yourInfo.usdtAmount.add(nowHelp.amount);
            //yourInfo.hasBack = yourInfo.hasBack.add(nowHelp.amount);
            //prizeInfo[yourAddress].staticPrize = prizeInfo[yourAddress].staticPrize.add(nowHelp.amount);
            assetLogList[msg.sender].push(AssetLog(++assetId, msg.sender, nowHelp.amount, 3, true, nowTime));

            if (nowU <= maxU.mul(7).div(10) && canStatic){
                canStatic = false;
            }

            if (yourInfo.maxDo >= yourInfo.hasBack || canStatic){
                uint prizeNum = nowHelp.amount.mul(backStatic).div(all);
                yourInfo.usdtAmount = yourInfo.usdtAmount.add(prizeNum.mul(7).div(10));
                yourInfo.scoreNum = yourInfo.scoreNum.add(prizeNum.mul(3).div(10));

                userAddScore = userAddScore.add(prizeNum.mul(3).div(10));
                yourInfo.hasBack = yourInfo.hasBack.add(prizeNum);

                assetLogList[msg.sender].push(AssetLog(++assetId, msg.sender, prizeNum, 2, true, nowTime));
                prizeInfo[yourAddress].staticPrize = prizeInfo[yourAddress].staticPrize.add(prizeNum);
            }

            yourInfo.myDo = yourInfo.myDo.add(_amount.sub(nowHelp.amount));
		} else {
			if (yourInfo.freezePrize > 0){
				uint releaseNum = 0;
				if (yourInfo.freezePrize >= _amount){
					releaseNum = _amount;
				} else {
					releaseNum = yourInfo.freezePrize;
				}

                yourInfo.usdtAmount = yourInfo.usdtAmount.add(releaseNum.mul(7).div(10));
                yourInfo.scoreNum = yourInfo.scoreNum.add(releaseNum.mul(3).div(10));
                userAddScore = userAddScore.add(releaseNum.mul(3).div(10));

                yourInfo.hasBack = yourInfo.hasBack.add(releaseNum);
                yourInfo.freezePrize = yourInfo.freezePrize.sub(releaseNum);
                yourInfo.hasBackFreezePrize = yourInfo.hasBackFreezePrize.add(releaseNum);

                assetLogList[msg.sender].push(AssetLog(++assetId, msg.sender, releaseNum, 110, true, nowTime));
			}

			addScore = _amount;
			yourInfo.myDo = yourInfo.myDo.add(_amount);
		}
		
		updateTeam(yourAddress, addScore);
		userInfo[yourAddress] = yourInfo;
	}

    function getUserInfo(address yourAddress) public view returns(address, uint, uint, uint, uint, uint, uint, uint, uint, uint, uint, uint){
        UserInfo memory _userInfo = userInfo[yourAddress];
        return (_userInfo.bindAddress, _userInfo.level, _userInfo.haveHelpCount, _userInfo.maxDo, _userInfo.usdtAmount, _userInfo.scoreNum, _userInfo.teamNum, _userInfo.myDo, _userInfo.teamDo, _userInfo.freezePrize, _userInfo.hasBackFreezePrize, _userInfo.hasBack);
    }

    function getUserInfoMore(address yourAddress) public view returns(uint, uint, uint){
        UserInfo memory _userInfo = userInfo[yourAddress];
        return (_userInfo.hasDoing, _userInfo.validCal, userAddScore);
    }

    function getRealse(address yourAddress) public view returns(uint, uint, uint, uint){
        ReleaseInfo memory yourRealse = releaseInfo[yourAddress];
        return (yourRealse.amount, yourRealse.logTime, yourRealse.lastRealseDay, yourRealse.hasRealse);
    }

    function getPrizeInfo(address yourAddress) public view returns(uint, uint, uint, uint){
        PrizeInfo memory yourPrize = prizeInfo[yourAddress];
        return (yourPrize.staticPrize, yourPrize.nextPrize, yourPrize.fivePrize, yourPrize.sixPrize);
    }

    function getStartTime() public view returns (uint, uint, uint, uint){
        if (startTime == 0){
            uint startTime2 = block.timestamp;
            uint coinTime2 = startTime2.add(coinDay.mul(calTime));
            uint drawFeeTime2 = startTime2.add(feeDay.mul(calTime));
            return (startTime2, backStatic, coinTime2, drawFeeTime2);
        } else {
            return (startTime, backStatic, coinTime, drawFeeTime);
        }
        
    }

    function getOrderlist(address yourAddress, uint page, uint limit) public view returns(uint backLength, uint[] memory amountReturn, uint[] memory logTimeReturn, uint[] memory endTimeReturn, bool[] memory isBackReturn){
        HelpInfo[] memory yourHelp = helpInfoList[yourAddress];
        backLength = yourHelp.length;
        uint start = 0;
        start = start.add(limit.mul(page.sub(1)));
        uint leftLength = backLength.sub(start);
        uint trueLength = limit;
        uint end = leftLength;

        if (leftLength > limit){
            end = start.add(limit);
        } else {
            trueLength = leftLength;
        }

        amountReturn = new uint[](trueLength);
        logTimeReturn = new uint[](trueLength);
        endTimeReturn = new uint[](trueLength);
        isBackReturn = new bool[](trueLength);

        for (uint i = start + 1; i <= end; i++){
            HelpInfo memory obj = yourHelp[i.sub(1)];
            amountReturn[trueLength.sub(i)] = obj.amount;
            logTimeReturn[trueLength.sub(i)] = obj.logTime;
            endTimeReturn[trueLength.sub(i)] = obj.endTime;
            isBackReturn[trueLength.sub(i)] = obj.isBack;
        }
    }
	
	function releaseUser() public {
		ReleaseInfo memory yourRealse = releaseInfo[msg.sender];
		uint releaseAmount = yourRealse.amount;
		
        require(releaseAmount > 0, "not have release");
		uint nowTime = block.timestamp;
		uint nowDay = nowTime.div(calTime);
		uint lastdays = yourRealse.lastRealseDay.div(calTime);
		uint release = releaseAmount.mul(nowDay.sub(lastdays)).mul(2).div(all);
		
        if (release.add(yourRealse.hasRealse) >= releaseAmount){
            release = releaseAmount.sub(yourRealse.hasRealse);
        }

		yourRealse.lastRealseDay = nowTime;
		yourRealse.hasRealse = yourRealse.hasRealse.add(release);

        IERC20 newCoin = IERC20(contract1);
        newCoin.transfer(msg.sender, release);

        releaseInfo[msg.sender] = yourRealse;

        assetLogList[msg.sender].push(AssetLog(++assetId, msg.sender, release, 301, true, nowTime));
        emit getRelease(msg.sender, release);
	}
	
	function backTeam(address yourAddress, uint _amount) private {
		UserInfo storage user = userInfo[yourAddress];
        address parentAddress = user.bindAddress;
        uint nowTime = block.timestamp;
        for(uint i = 0; i < maxLength; i++){
            if(parentAddress != address(0)){
                uint256 doAmount = _amount;
                UserInfo memory parentUserInfo = userInfo[parentAddress];
				uint256 maxDo = parentUserInfo.maxDo;
				if(maxDo < _amount){
					doAmount = maxDo;
				}

                PrizeInfo storage parentPrize = prizeInfo[parentAddress];
                uint256 _giveAmount;
                if(i > 4){
                    if(userInfo[parentAddress].level > 4){
                        _giveAmount = doAmount.mul(backPercent[i]).div(all);

                        parentPrize.sixPrize = parentPrize.sixPrize.add(_giveAmount);
                        parentUserInfo.freezePrize = parentUserInfo.freezePrize.add(_giveAmount);
                        userInfo[parentAddress] = parentUserInfo;

                        assetLogList[parentAddress].push(AssetLog(++assetId, parentAddress, _giveAmount, 113, true, nowTime));
                    }
                } else if(i > 0){
                    if(userInfo[parentAddress].level > 3){
                        _giveAmount = doAmount.mul(backPercent[i]).div(all);
                        parentPrize.fivePrize = parentPrize.fivePrize.add(_giveAmount);

                        parentUserInfo.hasBack = parentUserInfo.hasBack.add(_giveAmount);
                        parentUserInfo.usdtAmount = parentUserInfo.usdtAmount.add(_giveAmount.mul(7).div(10));
                        parentUserInfo.scoreNum = parentUserInfo.scoreNum.add(_giveAmount.mul(3).div(10));

                        userAddScore = userAddScore.add(_giveAmount.mul(3).div(10));

                        userInfo[parentAddress] = parentUserInfo;

                        assetLogList[parentAddress].push(AssetLog(++assetId, parentAddress, _giveAmount, 112, true, nowTime));
                    }
                } else{
                    _giveAmount = doAmount.mul(backPercent[i]).div(all);
                    parentPrize.nextPrize = parentPrize.nextPrize.add(_giveAmount);

                    parentUserInfo.hasBack = parentUserInfo.hasBack.add(_giveAmount);
                    parentUserInfo.usdtAmount = parentUserInfo.usdtAmount.add(_giveAmount.mul(7).div(10));
                    parentUserInfo.scoreNum = parentUserInfo.scoreNum.add(_giveAmount.mul(3).div(10));
                    userAddScore = userAddScore.add(_giveAmount.mul(3).div(10));

                    userInfo[parentAddress] = parentUserInfo;

                    assetLogList[parentAddress].push(AssetLog(++assetId, parentAddress, _giveAmount, 111, true, nowTime));
                }
                parentAddress = parentUserInfo.bindAddress;
            }else{
                break;
            }
        }
	}
	
	function updateTeam(address yourAddress, uint _amount) private {
		UserInfo storage user = userInfo[yourAddress];
        address parentAddress = user.bindAddress;
        for(uint i = 0; i < maxLength; i++){
            if(parentAddress != address(0)){
                userInfo[parentAddress].teamDo = userInfo[parentAddress].teamDo.add(_amount);
                _updateLevel(parentAddress);
                parentAddress = userInfo[parentAddress].bindAddress;
            }else{
                break;
            }
        }
	}
	
	function bindParent (address _bindAddress) public {
		require(/*userInfo[_bindAddress].myDo > 0 || **/_bindAddress != address(0) && _bindAddress != msg.sender, "invalid bindAddress");
		
		address myAddress = _bindAddress;
        bool myBind = false;
        for (uint i=0; i <= 200; i++){
            if (myAddress == address(0)){
                break;
            }
            myAddress = userInfo[myAddress].bindAddress;
            if (myAddress == msg.sender){
                myBind = true;
                break;
            }
        }
		
		require(!myBind, "unvalid address4");
        UserInfo storage user = userInfo[msg.sender];
        require(!haveBind[msg.sender], "has bind");
        user.bindAddress = _bindAddress;
        user.logTime = block.timestamp;
    
        haveBind[msg.sender] = true;
        emit bindOne(msg.sender, _bindAddress);
	}
	
	function sendScoreFunction (address yourAddress, uint _amount) public {
		UserInfo storage user = userInfo[msg.sender];
        require(_amount%1e20 == 0, "Must be an integer multiple of one hundred");
		require(user.scoreNum >= _amount, "not have enough score");
		user.scoreNum = user.scoreNum.sub(_amount);
		userInfo[yourAddress].scoreNum = userInfo[yourAddress].scoreNum.add(_amount);

        uint nowTime = block.timestamp;
        assetLogList[msg.sender].push(AssetLog(++assetId, msg.sender, _amount, 4, false, nowTime));
        assetLogList[yourAddress].push(AssetLog(++assetId, yourAddress, _amount, 4, true, nowTime));
		emit sendScore(msg.sender, yourAddress, _amount);
	}
	
	function updateTeamNum(address _yourAddress) private {
        UserInfo storage user = userInfo[_yourAddress];
        address parentAddress = user.bindAddress;
        for(uint256 i = 0; i < maxLength; i++){
            if(parentAddress != address(0)){
                userInfo[parentAddress].teamNum = userInfo[parentAddress].teamNum.add(1);
                teamUsers[parentAddress][i].push(_yourAddress);
                _updateLevel(parentAddress);
                parentAddress = userInfo[parentAddress].bindAddress;
            }else{
                break;
            }
        }
    }
	
	function _updateLevel(address _myAddress) private {
        UserInfo storage user = userInfo[_myAddress];
        uint256 levelNow = _calLevelNow(_myAddress);
        if(levelNow > user.level){
            user.level = levelNow;
        }
        userInfo[_myAddress] = user;
    }

    function _calLevelNow(address _myAddress) private view returns(uint256 nowLevel) {
        UserInfo storage user = userInfo[_myAddress];
        uint256 myDoing = user.myDo;
		
		(, uint maxScore,uint minScore) = getTeamScore(_myAddress);
		
        if(myDoing >= 4000e18){
            if(minScore >= 50000e18 && maxScore >= 50000e18 && user.teamNum >= 100){
                nowLevel = 5;
            }else if(minScore >= 20000e18 && maxScore >= 20000e18 && user.teamNum >= 50){
                nowLevel = 4;
            }else{
                nowLevel = 3;
            }
        } else if(myDoing >= 2000e18){
            if(minScore >= 20000e18 && maxScore >= 20000e18 && user.teamNum >= 50){
                nowLevel = 4;
            }else{
                nowLevel = 3;
            }
        } else if(myDoing >= 1000e18){
            nowLevel = 2;
        } else if(myDoing >= 100e18){
            nowLevel = 1;
        }
    }
	
	function getTeamScore(address _myAddress) public view returns(uint256 allScore, uint256 maxScore, uint256 otherScore){
        for(uint256 i = 0; i < teamUsers[_myAddress][0].length; i++){
            uint256 oneScore = userInfo[teamUsers[_myAddress][0][i]].teamDo.add(userInfo[teamUsers[_myAddress][0][i]].myDo);
            allScore = allScore.add(oneScore);
            if(oneScore > maxScore){
                maxScore = oneScore;
            }
        }
        otherScore = allScore.sub(maxScore);
    }
	
	
	function giveNewCoin(address yourAddress, uint _amount) private{
		uint nowUpdateTime = block.timestamp;
		uint nowDay = nowUpdateTime / calTime;
		uint lastDay = startTime / calTime;

        uint backPer = minStartBack.add(nowDay.sub(lastDay).sub(coinDay));
        if (backPer >= 1000){
            backPer = 1000;
        }
        uint giveAmount = _amount.mul(backPer).div(1000);
        uint giveRelease = getTokenPrice(1e18);
        giveRelease = giveAmount.mul(1e18).div(giveRelease);
		ReleaseInfo memory yourReleaseInfo = releaseInfo[yourAddress];
		if (yourReleaseInfo.logTime == 0){
			releaseInfo[yourAddress] = ReleaseInfo(giveRelease, nowUpdateTime, nowUpdateTime, 0);
		}
	}
	
	function getTokenPrice(uint total) public view returns (uint amount1){
        address[] memory path = new address[](2);
	    path[0] = contract1;
	    path[1] = _usdtAddress;
        amount1 = router1.getAmountsOut(total,path)[1];
    }

    function getTeamUser(address yourAddress, uint indexPage, uint page, uint limit) public view returns(uint length, address[] memory addressReturn, uint[] memory myDoReturn, uint[] memory doBackReturn, uint[] memory teamBack){
        address[] memory myList = teamUsers[yourAddress][indexPage];
        
        length = myList.length;
        uint pageIndex = page.sub(1).mul(limit);
        uint resultLength;
        if (pageIndex.add(limit) <= length){
            resultLength = limit;
        } else {
            resultLength = length.sub(pageIndex);
        }

        addressReturn = new address[](resultLength);
        myDoReturn = new uint[](resultLength);
        doBackReturn = new uint[](resultLength);
        teamBack = new uint[](resultLength);

        for (uint i = 0; i < resultLength; i ++) {
            uint index = i + pageIndex;
            address oneAddress = myList[i];
            if (index < length) {
                UserInfo memory oneInfo = userInfo[oneAddress];
                addressReturn[i] = oneAddress;
                doBackReturn[i] = oneInfo.hasDoing;
                myDoReturn[i] =  oneInfo.myDo;
                teamBack[i] = oneInfo.teamDo;
            }
        }
    }

    function GetAssetLog(address yourAddress, uint page, uint limit) public view returns (uint length, uint[] memory _idReturn, address[] memory _addressReturn, uint[] memory _changeNumReturn, uint[] memory _changeTypeReturn, bool[] memory _addTypeReturn, uint[] memory _timeReturn) {
        AssetLog[] memory yourAssetList = assetLogList[yourAddress];
        length = yourAssetList.length;
        uint pageIndex = page.sub(1).mul(limit);
        uint resultLength;
        uint calLength = length>0?length.sub(1): 0;
        if (pageIndex.add(limit) <= length){
            resultLength = limit;
        } else {
            resultLength = length.sub(pageIndex);
        }

        _idReturn = new uint[](resultLength);
		_timeReturn = new uint[](resultLength);
		_addressReturn = new address[](resultLength);
		_changeNumReturn = new uint[](resultLength);
        _changeTypeReturn = new uint[](resultLength);
        _addTypeReturn = new bool[](resultLength);
        for (uint i = 0; i < resultLength; i ++) {
            uint index = i.add(pageIndex);
            if (index < length) {
                AssetLog memory obj = yourAssetList[calLength.sub(index)];
                _idReturn[i] = obj._id;
				_addressReturn[i] = obj.userAddress;
                _changeNumReturn[i] = obj.changeNum;
                _changeTypeReturn[i] = obj.changeType;
                _addTypeReturn[i] = obj.add;
				_timeReturn[i] = obj.logTime;
            }
        }
    }
}