/**
 *Submitted for verification at BscScan.com on 2022-03-18
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-27
*/

// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.3;

abstract contract ERC20 {
    function transferFrom(address _from, address _to, uint256 _value) external virtual returns (bool success);
    function transfer(address recipient, uint256 amount) external virtual returns (bool);
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

}

contract MobiusDeflation is Modifier, Util {

    using SafeMath for uint;

    uint private onePoolAmount;
    uint private twoPoolAmount;
    uint private deflationLimit;
    uint private awardPoolRatio;
    uint private teamAwardRatio;
    uint private destroyRatio;
    uint private swapRatio;
    uint private daoRatio;

    mapping(uint => mapping(address => Award[])) private deflationRecord;

    struct Award { 
        uint8 awardType;
        uint oneAward;
        uint twoAward;
        uint power;
    }

    Award [] awards;
    Award award;

    address private teamAwardAddress;
    address private destroyAddress;
    address private swapAddress;
    address private daoAddress;

    ERC20 private buyToken;
    ERC20 private sellToken;

    constructor() {
        awardPoolRatio = 60;
        teamAwardRatio = 20;
        destroyRatio = 10;
        swapRatio = 5;
        daoRatio = 5;
        deflationLimit = 100000000000000000000;
    }

    /*
     * @dev Set up | Creator call | Set the token contract address
     * @param _buyToken  Configure the purchase token contract address
     * @param _sellToken Configure the address of the sell token contract
     */
    function setTokenContract(address _buyToken, address _sellToken) public onlyOwner {
        buyToken = ERC20(_buyToken);
        sellToken = ERC20(_sellToken);
    }

    function setTeamAwardAddress(address _address) public onlyOwner {
        teamAwardAddress = _address;
    }

    function setDestroyAddress(address _address) public onlyOwner {
        destroyAddress = _address;
    }

    function setSwapAddress(address _address) public onlyOwner {
        swapAddress = _address;
    }

    function setDaoAddress(address _address) public onlyOwner {
        daoAddress = _address;
    }

    function setAwardPoolRatio(uint ratio) public onlyOwner {
        awardPoolRatio = ratio;
    }

    function setTeamAwardRatio(uint ratio) public onlyOwner {
        teamAwardRatio = ratio;
    }

    function setDestroyRatio(uint ratio) public onlyOwner {
        destroyRatio = ratio;
    }

    function setSwapRatio(uint ratio) public onlyOwner {
        swapRatio = ratio;
    }

    function setDaoRatio(uint ratio) public onlyOwner {
        daoRatio = ratio;
    }

    /*
     * @dev Update | All | Join deflation
     * @param amountToWei join deflation
     */
    function joinDeflation(uint256 amountToWei) public isRunning nonReentrant returns (bool) {
        if(amountToWei < deflationLimit) {
            _status = _NOT_ENTERED;
            revert("Mobius: The deflation number is less than the limit");
        }
        if(amountToWei.mod(deflationLimit) != 0) {
            _status = _NOT_ENTERED;
            revert("Mobius: The deflation number is invalid");
        }

        uint intoPoolAmount = amountToWei.mul(awardPoolRatio).div(100);
        onePoolAmount = onePoolAmount.add(intoPoolAmount);

        uint joinCopies = amountToWei.div(deflationLimit);

        // set up length of array to 0
        delete awards;

        for(uint i = 0; i < joinCopies; i++) {
            (uint8 awardType, uint oneAward, uint twoAward, uint power) = lottery(block.number, i, joinCopies);
            award = Award(awardType, oneAward, twoAward, power);
            awards.push(award);
        }

        deflationRecord[block.number][msg.sender] = awards;

        buyToken.transferFrom(msg.sender, address(this), amountToWei);
        buyToken.transfer(teamAwardAddress, amountToWei.mul(teamAwardRatio).div(100));
        buyToken.transfer(destroyAddress, amountToWei.mul(destroyRatio).div(100));
        buyToken.transfer(swapAddress, amountToWei.mul(swapRatio).div(100));
        buyToken.transfer(daoAddress, amountToWei.mul(daoRatio).div(100));

        return true;
    }

    function lottery(uint seed, uint salt, uint sugar) private returns (uint8 awardType, uint oneAward, uint twoAward, uint power) {
        // 1 - 100(both incl.)
        uint randomNumber = uint(uint(keccak256(abi.encodePacked(block.timestamp, seed, salt, sugar))).mod(100)).add(1);
        if(randomNumber >= 82) {
            awardType = 19;
            power = 100;
        } else if(randomNumber >= 65 && randomNumber <= 81) {
            awardType = 17;
            power = 100 * 2;
        } else if(randomNumber >= 50 && randomNumber <= 64) {
            awardType = 15;
            oneAward = onePoolAmount.mul(175).div(100000); // 0.175%
            if(twoPoolAmount >= 1) { twoAward = twoPoolAmount.mul(175).div(100000); }
        } else if(randomNumber >= 37 && randomNumber <= 49) {
            awardType = 13;
            oneAward = onePoolAmount.mul(25).div(10000); // 0.25%
            if(twoPoolAmount >= 1) { twoAward = twoPoolAmount.mul(25).div(10000); }
        } else if(randomNumber >= 26 && randomNumber <= 36) {
            awardType = 11;
            oneAward = onePoolAmount.mul(50).div(10000); // 0.5%
            if(twoPoolAmount >= 1) { twoAward = twoPoolAmount.mul(50).div(10000); }
        } else if(randomNumber >= 17 && randomNumber <= 25) {
            awardType = 9;
            oneAward = onePoolAmount.mul(75).div(10000); // 0.75%
            if(twoPoolAmount >= 1) { twoAward = twoPoolAmount.mul(75).div(10000); }
        } else if(randomNumber >= 10 && randomNumber <= 16) {
            awardType = 7;
            oneAward = onePoolAmount.mul(100).div(10000); // 1%
            if(twoPoolAmount >= 1) { twoAward = twoPoolAmount.mul(100).div(10000); }
        } else if(randomNumber >= 5 && randomNumber <= 9) {
            awardType = 5;
            oneAward = onePoolAmount.mul(200).div(10000); // 2%
            if(twoPoolAmount >= 1) { twoAward = twoPoolAmount.mul(200).div(10000); }
        } else if(randomNumber >= 2 && randomNumber <= 4) {
            awardType = 3;
            oneAward = onePoolAmount.mul(300).div(10000); // 3%
            if(twoPoolAmount >= 1) { twoAward = twoPoolAmount.mul(300).div(10000); }
        } else {
            awardType = 1;
            oneAward = onePoolAmount.mul(500).div(10000); // 5%
            if(twoPoolAmount >= 1) { twoAward = twoPoolAmount.mul(500).div(10000); }
        }

        if(awardType != 17 && awardType != 19) {
            onePoolAmount = onePoolAmount.sub(oneAward);
            if(twoPoolAmount >= 1) {
                twoPoolAmount = twoPoolAmount.sub(twoAward);
                sellToken.transfer(msg.sender, twoAward);
            }
            buyToken.transfer(msg.sender, oneAward);
        }

    }

    function getDeflationRecord(uint _number, address _address) public view returns(Award [] memory) {
        return deflationRecord[_number][_address];
    }

}