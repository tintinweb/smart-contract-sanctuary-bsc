/**
 *Submitted for verification at BscScan.com on 2022-04-11
*/

/**
 *Submitted for verification at BscScan.com on 2022-04-09
*/

// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.3;

abstract contract ERC20 {
    function transferFrom(address _from, address _to, uint256 _value) external virtual returns (bool success);
    function transfer(address recipient, uint256 amount) external virtual returns (bool);
}

abstract contract PancakePair {
    function getReserves() external virtual view returns (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast);
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


library Counters {
    struct Counter {uint256 _value;}

    function current(Counter storage counter) internal view returns (uint256) {return counter._value;}

    function increment(Counter storage counter) internal {unchecked {counter._value += 1;}}

    function decrement(Counter storage counter) internal {uint256 value = counter._value; require(value > 0, "Counter: decrement overflow"); unchecked {counter._value = value - 1;}}

    function reset(Counter storage counter) internal {counter._value = 0;}
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

contract Util {

    /*
     * @dev wei convert
     * @param price
     * @param decimals
     */
    function toWei(uint256 price, uint decimals) public pure returns (uint256){
        uint256 amount = price * (10 ** uint256(decimals));
        return amount;
    }

    function mathDivisionToFloat(uint256 a, uint256 b, uint decimals) public pure returns (uint256){
        uint256 aPlus = a * (10 ** uint256(decimals));
        uint256 amount = aPlus / b;
        return amount;
    }

}

contract SeedBlindBox is Modifier, Util {

    using SafeMath for uint256;
    uint256 private currentAmount;
    uint256 private latestTime;
    uint256 private protectRatio;
    uint256 private promoteRatio;
    uint256 private daoRatio;

    mapping(uint256 => mapping(address => Award)) private joinRecord;

    struct Award { 
        uint256 award;
        uint256 power;
    }
    Award award;

    address private protectAddress;
    address private promoteAddress;
    address private daoAddress;

    PancakePair pancakePair;
    ERC20 private joinToken;
    ERC20 private sellToken;

    constructor() {
        protectRatio = 70;
        promoteRatio = 20;
        daoRatio = 10;
    }

    function setTokenContract(address _joinToken, address _sellToken) public onlyOwner {
        joinToken = ERC20(_joinToken);
        sellToken = ERC20(_sellToken);
    }

    function setProtectAddress(address _address) public onlyOwner {
        protectAddress = _address;
    }

    function setPromoteAddress(address _address) public onlyOwner {
        promoteAddress = _address;
    }

    function setDaoAddress(address _address) public onlyOwner {
        daoAddress = _address;
    }

    function setProtectRatio(uint ratio) public onlyOwner {
        protectRatio = ratio;
    }

    function setPromoteRatio(uint ratio) public onlyOwner {
        promoteRatio = ratio;
    }

    function setDaoRatio(uint ratio) public onlyOwner {
        daoRatio = ratio;
    }

    function join() public isRunning nonReentrant returns (bool) {

        uint256 usdtToSeedPrice = queryUsdtToSeedPrice(); // unit256: wei
        uint256 currentOutput = 1;
        uint256 totalAmount = (block.timestamp.sub(latestTime)).mul(currentOutput).add(currentAmount);
        uint256 joinAmount = totalAmount.mul(1).div(100).mul(usdtToSeedPrice).div((10 ** 18));

        joinToken.transferFrom(msg.sender, address(this), joinAmount);

        (uint256 awardAmount) = lottery(block.number, totalAmount, usdtToSeedPrice);
        uint256 power = 0;
        if(awardAmount == 0) {
            power = joinAmount;
        } else {
            totalAmount = totalAmount.sub(awardAmount);
            latestTime = block.timestamp;
        }
        award = Award(awardAmount, power);

        joinRecord[block.number][msg.sender] = award;

        joinToken.transfer(protectAddress, joinAmount.mul(protectRatio).div(100));
        joinToken.transfer(promoteAddress, joinAmount.mul(promoteRatio).div(100));
        joinToken.transfer(daoAddress, joinAmount.mul(daoRatio).div(100));

        return true;
    }

    function lottery(uint256 blockNumber, uint256 totalAmount, uint256 price) private view returns (uint256 awardAmount) {
        // 1 - 100(both incl.)
        uint256 randomNumber = uint256(uint256(keccak256(abi.encodePacked(block.timestamp, blockNumber, totalAmount, price))).mod(100)).add(1);
        if(randomNumber >= 81) {
            // 20%
            awardAmount = 0;
        } else if(randomNumber >= 71 && randomNumber <= 80) {
            // 10%
            awardAmount = totalAmount.mul(4).div(1000); // 0.4%
        } else if(randomNumber >= 61 && randomNumber <= 70) {
            // 10%
            awardAmount = totalAmount.mul(5).div(1000); // 0.5%
        } else if(randomNumber >= 51 && randomNumber <= 60) {
            // 10%
            awardAmount = totalAmount.mul(6).div(1000); // 0.6%
        } else if(randomNumber >= 41 && randomNumber <= 50) {
            // 10%
            awardAmount = totalAmount.mul(7).div(1000); // 0.7%
        } else if(randomNumber >= 31 && randomNumber <= 40) {
            // 10%
            awardAmount = totalAmount.mul(8).div(1000); // 0.8%
        } else if(randomNumber >= 21 && randomNumber <= 30) {
            // 10%
            awardAmount = totalAmount.mul(9).div(1000); // 0.9%
        } else if(randomNumber >= 11 && randomNumber <= 20) {
            // 10%
            awardAmount = totalAmount.mul(10).div(1000); // 1%
        } else if(randomNumber >= 6 && randomNumber <= 10) {
            // 5%
            awardAmount = totalAmount.mul(50).div(1000); // 5%
        } else if(randomNumber >= 2 && randomNumber <= 5) {
            // 4%
            awardAmount = totalAmount.mul(100).div(1000); // 10%
        } else {
            // 1%
            awardAmount = totalAmount.mul(300).div(1000); // 30%
        }

    }

    function getJoinRecord(uint256 _number, address _address) public view returns (uint256 awardAmount, uint256 power) {
        awardAmount = joinRecord[_number][_address].award;
        power = joinRecord[_number][_address].power;
    }

    function queryUsdtToSeedPrice() private view returns (uint256) {
        uint112 usdtSum; // LP USDT sum
        uint112 seedSum; // LP MOB sum
        uint32 lastTime; // Last trading time
        (usdtSum, seedSum, lastTime) = pancakePair.getReserves();
        uint256 usdtToSeedPrice = Util.mathDivisionToFloat(seedSum, usdtSum, 18);
        return usdtToSeedPrice;
    }

    function getJoinAmount() public view returns (uint256) {
        uint256 usdtToSeedPrice = queryUsdtToSeedPrice(); // unit256: wei
        uint256 currentOutput = 1;
        uint256 totalAmount = (block.timestamp.sub(latestTime)).mul(currentOutput).add(currentAmount);
        return totalAmount.mul(1).div(100).mul(usdtToSeedPrice).div((10 ** 18));
    }

}