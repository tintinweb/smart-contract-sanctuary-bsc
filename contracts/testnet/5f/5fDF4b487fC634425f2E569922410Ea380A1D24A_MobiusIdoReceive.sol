/**
 *Submitted for verification at BscScan.com on 2022-06-04
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

abstract contract MobiusCircle {
    function transferJoin(address joinAddress, uint256 amountToWei) external virtual returns (bool);
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

contract Util {

    function toWei(uint price, uint decimals) public pure returns (uint){
        uint amount = price * (10 ** uint(decimals));
        return amount;
    }

}

contract MobiusIdoReceive is Modifier, Util {

    using SafeMath for uint256;

    mapping(address => uint) private buyIdoNumber;
    mapping(address => uint256) private receiveIdoNumber;
    uint256 private swapOnlineTime;
    uint256 private circleOnlineTime;
    uint256 private idoReceivePeriod;

    ERC20 private mobToken;
    MobiusCircle private mobiusCircle;

    constructor() {
        swapOnlineTime = 0;
        circleOnlineTime = 0;
        idoReceivePeriod = 1;
        mobToken = ERC20(0x9775C1CF4c0ACe8D52d533cD4badcdEab9E4340C);
        mobiusCircle = MobiusCircle(0x3B3522B5acb31681EE9277c7e75B7e2319a4A449);
    }

    function setTokenContract(address _mobToken, address contractAddress) public onlyOwner {
        mobToken = ERC20(_mobToken);
        mobiusCircle = MobiusCircle(contractAddress);
    }

    function setSwapOnlineTime() public onlyOwner {
        swapOnlineTime = block.timestamp;
    }

    function getNumberForIdo() public view returns(uint256 number) {
        if(swapOnlineTime == 0 || receiveIdoNumber[msg.sender] > 0) {
            return 0;
        }
        return computeReceiveIdoNumber();
    }

    function receiveForIdo() public isRunning nonReentrant returns (bool) {
        if(swapOnlineTime == 0 || receiveIdoNumber[msg.sender] > 0) {
            _status = _NOT_ENTERED;
            revert("Mobius: No amount available at the moment");
        }
        uint256 receiveNumber = computeReceiveIdoNumber();
        receiveIdoNumber[msg.sender] = receiveNumber;
        mobToken.transfer(msg.sender, receiveNumber);
        uint256 notReceiveNumber = buyIdoNumber[msg.sender].sub(receiveNumber);
        if(notReceiveNumber > 0) {
            mobToken.transfer(0x000000000000000000000000000000000000dEaD, notReceiveNumber);
        }
        return true;
    }

    function joinCircle() public isRunning nonReentrant returns (bool) {
        if(circleOnlineTime == 0 || receiveIdoNumber[msg.sender] > 0) {
            _status = _NOT_ENTERED;
            revert("Mobius: No amount available at the moment");
        }
        uint256 receiveNumber = computeReceiveIdoNumber();
        receiveIdoNumber[msg.sender] = receiveNumber;

        mobiusCircle.transferJoin(msg.sender, receiveNumber);

        uint256 notReceiveNumber = buyIdoNumber[msg.sender].sub(receiveNumber);
        if(notReceiveNumber > 0) {
            mobToken.transfer(0x000000000000000000000000000000000000dEaD, notReceiveNumber);
        }
        return true;
    }

    function computeReceiveIdoNumber() private view returns (uint256 number) {
        // uint256 secondsOfDay = 24 * 60 * 60;
        uint256 secondsOfDay = 3 * 60;
        uint256 onlineDay = block.timestamp.sub(swapOnlineTime).div(secondsOfDay);
        if(onlineDay < idoReceivePeriod) {
            return buyIdoNumber[msg.sender].mul(25).div(100);
        }
        uint256 availableReceivePeriod = onlineDay.div(idoReceivePeriod).add(1);
        if(availableReceivePeriod >= 4) {
            return buyIdoNumber[msg.sender];
        }
        return buyIdoNumber[msg.sender].mul(25).div(100).mul(availableReceivePeriod);
    }

    function setIdoAmount(address [] memory addressList, uint256 [] memory amountList) public onlyOwner {
        for(uint8 i=0; i<addressList.length; i++) {
            buyIdoNumber[addressList[i]] = amountList[i];
        }
    }

}