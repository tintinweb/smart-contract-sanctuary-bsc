/**
 *Submitted for verification at BscScan.com on 2022-05-21
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

contract MobiusDeflation is Modifier, Util {

    using SafeMath for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private lotteryIssue;

    address private promoteAddress;
    address private destroyAddress;

    uint256 private joinLimit;
    uint256 private deflationPoolRatio;
    uint256 private promoteRatio;
    uint256 private totalUsdtWaitReceive;
    uint256 private totalMobWaitReceive;
    uint256 private lastRunLotteryTime;

    mapping(uint256 => uint256) issueUsdtLottery;
    mapping(uint256 => uint256) issueMobLottery;

    mapping(address => uint256) waitUsdtReceive;
    mapping(address => uint256) waitMobReceive;

    mapping(uint256 => mapping(address => uint256)) private issueWaitUsdtReceive;
    mapping(uint256 => mapping(address => uint256)) private issueWaitMobReceive;

    mapping(address => uint256) usdtReceived;
    mapping(address => uint256) mobReceived;

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

        promoteAddress = 0xAE6c148Ce7D5a059c67C468F96F4F03E8Ae4f3DD;
        destroyAddress = 0x000000000000000000000000000000000000dEaD;
        usdtToken = ERC20(0xD4Da02aA780b257D3AB7cD4A9F8E50dDf1B6aFE1);
        mobToken = ERC20(0x1365a1069C4cd570093396Dc92502315747d95bF);

        // IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
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

    function setPromoteAddress(address _address) public onlyOwner {
        promoteAddress = _address;
    }

    function setDestroyAddress(address _address) public onlyOwner {
        destroyAddress = _address;
    }

    function setDeflationPoolRatio(uint ratio) public onlyOwner {
        deflationPoolRatio = ratio;
    }

    function setPromoteRatio(uint ratio) public onlyOwner {
        promoteRatio = ratio;
    }

    function joinUsdtPool(uint256 amountToWei) public isRunning nonReentrant returns (bool) {
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
            lotteryIssue.increment();
            lastRunLotteryTime = block.timestamp;
        }

        for(uint8 i = 0; i < joinCopies; i++) {
            (uint256 awardType, uint256 awardAmount, uint256 power) = lottery(block.number, i, joinCopies, true);
            award = Award(lotteryIssue.current(), awardType, awardAmount, power);
            awards.push(award);
        }

        deflationRecord[block.number][msg.sender] = awards;

        uint256 poolAmount = amountToWei.mul(deflationPoolRatio).div(100);
        uint256 promoteAmount = amountToWei.mul(promoteRatio).div(100);
        uint256 destroyAmount = amountToWei.sub(poolAmount).sub(promoteAmount);

        swapUsdtToMob(destroyAmount);

        usdtToken.transfer(promoteAddress, promoteAmount);

        return true;
    }

    function joinMobPool(uint256 amountToWei) public isRunning nonReentrant returns (bool) {
        if(amountToWei < joinLimit) {
            _status = _NOT_ENTERED;
            revert("Mobius: The deflation number is less than the limit");
        }
        if(amountToWei.mod(joinLimit) != 0) {
            _status = _NOT_ENTERED;
            revert("Mobius: The deflation number is invalid");
        }

        mobToken.transferFrom(msg.sender, address(this), amountToWei);
        uint256 poolAmount = amountToWei.mul(deflationPoolRatio).div(100);
        uint256 promoteAmount = amountToWei.mul(promoteRatio).div(100);
        uint256 destroyAmount = amountToWei.sub(poolAmount).sub(promoteAmount);

        mobToken.transfer(destroyAddress, destroyAmount);
        mobToken.transfer(promoteAddress, promoteAmount);

        uint256 joinCopies = amountToWei.div(joinLimit);

        // set up length of array to 0
        delete awards;

        uint256 secondsOfDay = 24 * 60 * 60;
        uint256 intervalTime = block.timestamp - lastRunLotteryTime;
        if(intervalTime >= secondsOfDay) {
            lotteryIssue.increment();
            lastRunLotteryTime = block.timestamp;
        }

        for(uint8 i = 0; i < joinCopies; i++) {
            (uint256 awardType, uint256 awardAmount, uint256 power) = lottery(block.number, i, joinCopies, false);
            award = Award(lotteryIssue.current(), awardType, awardAmount, power);
            awards.push(award);
        }

        deflationRecord[block.number][msg.sender] = awards;

        return true;
    }

    function lottery(uint256 seed, uint256 salt, uint256 sugar, bool flag) private returns (uint256 awardType, uint256 awardAmount, uint256 power) {
        
        uint256 poolAmount = 0;
        if(flag) {
            poolAmount = usdtToken.balanceOf(address(this));
        } else {
            poolAmount = mobToken.balanceOf(address(this));
        }

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
            if(flag) {
                awardAmount = poolAmount.mul(175).div(100000); // 0.175%
            } else {
                awardAmount = poolAmount.mul(175).div(100000);
            }
        } else if(randomNumber >= 37 && randomNumber <= 49) {
            awardType = 13;
            if(flag) {
                awardAmount = poolAmount.mul(25).div(10000); // 0.25%
            } else {
                awardAmount = poolAmount.mul(25).div(10000);
            }
        } else if(randomNumber >= 26 && randomNumber <= 36) {
            awardType = 11;
            if(flag) {
                awardAmount = poolAmount.mul(50).div(10000); // 0.5%
            } else {
                awardAmount = poolAmount.mul(50).div(10000);
            }
        } else if(randomNumber >= 17 && randomNumber <= 25) {
            awardType = 9;
            if(flag) {
                awardAmount = poolAmount.mul(75).div(10000); // 0.75%
            } else {
                awardAmount = poolAmount.mul(75).div(10000);
            }
        } else if(randomNumber >= 10 && randomNumber <= 16) {
            awardType = 7;
            if(flag) {
                awardAmount = poolAmount.mul(100).div(10000); // 1%
            } else {
                awardAmount = poolAmount.mul(100).div(10000);
            }
        } else if(randomNumber >= 5 && randomNumber <= 9) {
            awardType = 5;
            if(flag) {
                awardAmount = poolAmount.mul(200).div(10000); // 2%
            } else {
                awardAmount = poolAmount.mul(200).div(10000);
            }
        } else if(randomNumber >= 2 && randomNumber <= 4) {
            awardType = 3;
            if(flag) {
                awardAmount = poolAmount.mul(300).div(10000); // 3%
            } else {
                awardAmount = poolAmount.mul(300).div(10000);
            }
        } else {
            awardType = 1;
            if(flag) {
                awardAmount = poolAmount.mul(500).div(10000); // 5%
            } else {
                awardAmount = poolAmount.mul(500).div(10000);
            }
        }

        if(awardType != 17 && awardType != 19) {
            
            if(flag) {
                totalUsdtWaitReceive = totalUsdtWaitReceive.add(awardAmount);
                waitUsdtReceive[msg.sender] = waitUsdtReceive[msg.sender].add(awardAmount);
                issueWaitUsdtReceive[lotteryIssue.current()][msg.sender] = issueWaitUsdtReceive[lotteryIssue.current()][msg.sender].add(awardAmount);
                issueUsdtLottery[lotteryIssue.current()] = issueUsdtLottery[lotteryIssue.current()].add(awardAmount);
            } else {
                totalMobWaitReceive = totalMobWaitReceive.add(awardAmount);
                waitMobReceive[msg.sender] = waitMobReceive[msg.sender].add(awardAmount);
                issueWaitMobReceive[lotteryIssue.current()][msg.sender] = issueWaitMobReceive[lotteryIssue.current()][msg.sender].add(awardAmount);
                issueMobLottery[lotteryIssue.current()] = issueMobLottery[lotteryIssue.current()].add(awardAmount);
            }

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
                destroyAddress,
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

    function getOwnAwardInfo() public view returns(uint256 usdtWaitAmount, uint256 mobWaitAmount, uint256 usdtReceivedAmount, uint256 mobReceivedAmount) {
        usdtWaitAmount = waitUsdtReceive[msg.sender].sub(issueWaitUsdtReceive[lotteryIssue.current()][msg.sender]);
        mobWaitAmount = waitMobReceive[msg.sender].sub(issueWaitMobReceive[lotteryIssue.current()][msg.sender]);
        usdtReceivedAmount = usdtReceived[msg.sender];
        mobReceivedAmount = mobReceived[msg.sender];
    }

    function receiveAward() public isRunning nonReentrant returns (bool) {
        
        uint256 usdtAmount = waitUsdtReceive[msg.sender].sub(issueWaitUsdtReceive[lotteryIssue.current()][msg.sender]);
        uint256 mobAmount = waitMobReceive[msg.sender].sub(issueWaitMobReceive[lotteryIssue.current()][msg.sender]);

        if(usdtAmount <= 0 && mobAmount <= 0) {
            _status = _NOT_ENTERED;
            revert("Mobius: There is no reward available yet");
        }

        if(usdtAmount > 0) {
            waitUsdtReceive[msg.sender] = waitUsdtReceive[msg.sender].sub(usdtAmount);
            totalUsdtWaitReceive = totalUsdtWaitReceive.sub(usdtAmount);
            usdtReceived[msg.sender] = usdtReceived[msg.sender].add(usdtAmount);
            usdtToken.transfer(msg.sender, usdtAmount);
        }

        if(mobAmount > 0) {
            waitMobReceive[msg.sender] = waitMobReceive[msg.sender].sub(mobAmount);
            totalMobWaitReceive = totalMobWaitReceive.sub(mobAmount);
            mobReceived[msg.sender] = mobReceived[msg.sender].add(mobAmount);
            mobToken.transfer(msg.sender, mobAmount);
        }

        return true;
    }

    function getDeflationInfo() public view returns (uint256 usdtAmount, uint256 mobAmount) {
        usdtAmount = usdtToken.balanceOf(address(this)).sub(totalUsdtWaitReceive).add(issueUsdtLottery[lotteryIssue.current()]);
        mobAmount = mobToken.balanceOf(address(this)).sub(totalMobWaitReceive).add(issueMobLottery[lotteryIssue.current()]);
    }

}