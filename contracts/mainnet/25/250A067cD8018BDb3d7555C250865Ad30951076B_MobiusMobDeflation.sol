/**
 *Submitted for verification at BscScan.com on 2022-05-26
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-27
*/

// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.3;

abstract contract ERC20 {
    function transferFrom(address _from, address _to, uint256 _value) external virtual returns (bool success);
    function transfer(address recipient, uint256 amount) external virtual returns (bool);
    function balanceOf(address account) external virtual view returns (uint256);
    function approve(address spender, uint256 amount) external virtual returns (bool);
}

contract Modifier {
    address internal owner; // Constract creater
    address internal approveAddress;
    bool public running = true;
    uint256 internal constant _NOT_ENTERED = 1;
    uint256 internal constant _ENTERED = 2;
    uint256 internal _status;

    modifier onlyOwner(){
        require(msg.sender == owner, "Modifier: The caller is not the creator");
        _;
    }

    modifier onlyApprove(){
        require(msg.sender == approveAddress || msg.sender == owner, "Modifier: The caller is not the approveAddress");
        _;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }

    modifier isRunning {
        require(running, "Modifier: No Running");
        _;
    }

    constructor() {
        owner = msg.sender;
        _status = _NOT_ENTERED;
    }

    function setApproveAddress(address externalAddress) public onlyOwner(){
        approveAddress = externalAddress;
    }

    function startStop() public onlyOwner returns (bool success) {
        if (running) { running = false; } else { running = true; }
        return true;
    }

    /*
     * @dev Get approve address
     */
    function getApproveAddress() internal view returns(address){
        return approveAddress;
    }

    fallback () payable external {}
    receive () payable external {}
}

library SafeMath {
    /* a + b */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    /* a - b */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }
    /* a * b */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    /* a / b */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    /* a / b */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
    /* a % b */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }
    /* a % b */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

library Counters {
    struct Counter {uint256 _value;}

    function current(Counter storage counter) internal view returns (uint256) {return counter._value;}

    function increment(Counter storage counter) internal {unchecked {counter._value += 1;}}

    function decrement(Counter storage counter) internal {uint256 value = counter._value; require(value > 0, "Counter: decrement overflow"); unchecked {counter._value = value - 1;}}

    function reset(Counter storage counter) internal {counter._value = 0;}
}

contract Util {

    function toWei(uint256 price, uint decimals) public pure returns (uint256){
        uint256 amount = price * (10 ** uint256(decimals));
        return amount;
    }

}

interface IUniswapV2Router02 {

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

}

contract MobiusMobDeflation is Modifier, Util {

    using SafeMath for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private lotteryIssue;

    address private deflationPoolAddress;
    address private promoteAddress;
    address private minePoolAddress;

    uint256 private joinLimit;
    uint256 private deflationPoolRatio;
    uint256 private promoteRatio;
    uint256 private totalWaitReceive;
    uint256 private lastRunLotteryTime;

    mapping(uint256 => uint256) issueRunLotteryTime;
    mapping(uint256 => uint256) issueLottery;
    mapping(address => uint256) waitReceive;
    mapping(uint256 => mapping(address => uint256)) private issueWaitReceive;
    mapping(address => uint256) received;
    mapping(uint256 => mapping(address => Award[])) private deflationRecord;

    struct Award {
        uint256 issue;
        uint256 awardType;
        uint256 awardAmount;
        uint256 power;
    }

    Award [] awards;
    Award award;

    ERC20 private usdtToken;
    ERC20 private mobToken;
    IUniswapV2Router02 public immutable uniswapV2Router;

    constructor() {
        deflationPoolRatio = 50;
        promoteRatio = 20;
        joinLimit = 100000000000000000000;
        lotteryIssue.increment();
        lastRunLotteryTime = block.timestamp;

        promoteAddress = 0x4556B6F436c33bc9CDB44E87bca656957df26a94;
        minePoolAddress = 0x3B3522B5acb31681EE9277c7e75B7e2319a4A449;
        usdtToken = ERC20(0x7F47B73afEe8ca4D3D89242EC64d8b24E4AB8815);
        mobToken = ERC20(0x9775C1CF4c0ACe8D52d533cD4badcdEab9E4340C);

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        // IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        uniswapV2Router = _uniswapV2Router;

    }

    function setJoinLimit(uint256 _joinLimit) public onlyOwner {
        joinLimit = _joinLimit;
    }

    function approveToken() public onlyOwner {
        usdtToken.approve(address(uniswapV2Router), 115792089237316195423570985008687907853269984665640564039457584007913129639935);
    }

    function setTokenContract(address _usdtToken, address _mobToken) public onlyOwner {
        usdtToken = ERC20(_usdtToken);
        mobToken = ERC20(_mobToken);
    }

    function setDeflationPoolAddress(address _address) public onlyOwner {
        deflationPoolAddress = _address;
    }

    function setPromoteAddress(address _address) public onlyOwner {
        promoteAddress = _address;
    }

    function setMinePoolAddress(address _address) public onlyOwner {
        minePoolAddress = _address;
    }

    function setDeflationPoolRatio(uint ratio) public onlyOwner {
        deflationPoolRatio = ratio;
    }

    function setPromoteRatio(uint ratio) public onlyOwner {
        promoteRatio = ratio;
    }

    function join(uint256 amountToWei) public isRunning nonReentrant returns (bool) {
        if(amountToWei < joinLimit) {
            _status = _NOT_ENTERED;
            revert("Mobius: The deflation number is less than the limit");
        }
        if(amountToWei.mod(joinLimit) != 0) {
            _status = _NOT_ENTERED;
            revert("Mobius: The deflation number is invalid");
        }

        usdtToken.transferFrom(msg.sender, address(this), amountToWei);

        uint256 joinCopies = amountToWei.div(joinLimit);

        // set up length of array to 0
        delete awards;

        uint256 secondsOfDay = 24 * 60 * 60;
        uint256 intervalTime = block.timestamp - lastRunLotteryTime;
        if(intervalTime >= secondsOfDay) {
            lastRunLotteryTime = block.timestamp;
            issueRunLotteryTime[lotteryIssue.current()] = lastRunLotteryTime;
            lotteryIssue.increment();
        }

        for(uint8 i = 0; i < joinCopies; i++) {
            (uint256 awardType, uint256 awardAmount, uint256 power) = lottery(block.number, i, joinCopies);
            award = Award(lotteryIssue.current(), awardType, awardAmount, power);
            awards.push(award);
        }

        deflationRecord[block.number][msg.sender] = awards;

        uint256 poolAmount = amountToWei.mul(deflationPoolRatio).div(100);
        uint256 promoteAmount = amountToWei.mul(promoteRatio).div(100);
        uint256 minePoolAmount = amountToWei.sub(poolAmount).sub(promoteAmount);

        swapUsdtToMob(minePoolAmount);

        usdtToken.transfer(deflationPoolAddress, poolAmount);
        usdtToken.transfer(promoteAddress, promoteAmount);

        return true;
    }

    function lottery(uint256 seed, uint256 salt, uint256 sugar) private returns (uint256 awardType, uint256 awardAmount, uint256 power) {
        
        uint256 poolAmount = mobToken.balanceOf(address(this));

        // 1 - 100(both incl.)
        uint256 randomNumber = uint256(uint256(keccak256(abi.encodePacked(block.timestamp, seed, salt, sugar))).mod(100)).add(1);
        if(randomNumber >= 82) {
            awardType = 19;
            power = 100;

        } else if(randomNumber >= 65 && randomNumber <= 81) {
            awardType = 17;
            power = 100 * 2;

        } else if(randomNumber >= 50 && randomNumber <= 64) {
            awardType = 15;
            awardAmount = poolAmount.mul(175).div(100000); // 0.175%

        } else if(randomNumber >= 37 && randomNumber <= 49) {
            awardType = 13;
            awardAmount = poolAmount.mul(25).div(10000); // 0.25%

        } else if(randomNumber >= 26 && randomNumber <= 36) {
            awardType = 11;
            awardAmount = poolAmount.mul(50).div(10000); // 0.5%
            
        } else if(randomNumber >= 17 && randomNumber <= 25) {
            awardType = 9;
            awardAmount = poolAmount.mul(75).div(10000); // 0.75%

        } else if(randomNumber >= 10 && randomNumber <= 16) {
            awardType = 7;
            awardAmount = poolAmount.mul(100).div(10000); // 1%

        } else if(randomNumber >= 5 && randomNumber <= 9) {
            awardType = 5;
            awardAmount = poolAmount.mul(200).div(10000); // 2%

        } else if(randomNumber >= 2 && randomNumber <= 4) {
            awardType = 3;
            awardAmount = poolAmount.mul(300).div(10000); // 3%

        } else {
            awardType = 1;
            awardAmount = poolAmount.mul(500).div(10000); // 5%
        }

        if(awardType != 17 && awardType != 19) {
            
            totalWaitReceive = totalWaitReceive.add(awardAmount);
            waitReceive[msg.sender] = waitReceive[msg.sender].add(awardAmount);
            issueWaitReceive[lotteryIssue.current()][msg.sender] = issueWaitReceive[lotteryIssue.current()][msg.sender].add(awardAmount);
            issueLottery[lotteryIssue.current()] = issueLottery[lotteryIssue.current()].add(awardAmount);

        }

    }

    function swapUsdtToMob(uint256 tokenAmount) private {
        if(tokenAmount > 0) {
            address[] memory path = new address[](2);
            path[0] = address(usdtToken);
            path[1] = address(mobToken);

            // make the swap
            uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                tokenAmount,
                0,
                path,
                minePoolAddress,
                block.timestamp
            );
        }
        
    }

    function getDeflationRecord(uint256 _number, address _address, uint256 index) public view returns (uint256 issue, uint256 awardType, uint256 awardAmount, uint256 power) {
        issue = deflationRecord[_number][_address][index].issue;
        awardType = deflationRecord[_number][_address][index].awardType;
        awardAmount = deflationRecord[_number][_address][index].awardAmount;
        power = deflationRecord[_number][_address][index].power;
    }

    function getOwnAwardInfo(address _address) public view returns(uint256 waitAmount, uint256 receivedAmount) {
        waitAmount = waitReceive[_address].sub(issueWaitReceive[lotteryIssue.current()][_address]);
        receivedAmount = received[_address];
    }

    function receiveAward() public isRunning nonReentrant returns (bool) {
        
        uint256 waitAmount = waitReceive[msg.sender].sub(issueWaitReceive[lotteryIssue.current()][msg.sender]);

        if(waitAmount <= 0) {
            _status = _NOT_ENTERED;
            revert("Mobius: There is no reward available yet");
        }

        waitReceive[msg.sender] = waitReceive[msg.sender].sub(waitAmount);
        totalWaitReceive = totalWaitReceive.sub(waitAmount);
        received[msg.sender] = received[msg.sender].add(waitAmount);
        mobToken.transfer(msg.sender, waitAmount);

        return true;
    }

    function getDeflationInfo() public view returns (uint256 poolAmount, uint256 currentIssue, uint256 startTime) {
        uint256 mobBalance = mobToken.balanceOf(address(this));
        if(mobBalance == 0) {
            poolAmount = 0;
        } else {
            poolAmount = mobBalance.sub(totalWaitReceive).add(issueLottery[lotteryIssue.current()]);
        }
        currentIssue = lotteryIssue.current();
        startTime = lastRunLotteryTime;
    }

    function getRunLotteryTime(uint256 _issue) public view returns (uint256) {
        return issueRunLotteryTime[_issue];
    }

}