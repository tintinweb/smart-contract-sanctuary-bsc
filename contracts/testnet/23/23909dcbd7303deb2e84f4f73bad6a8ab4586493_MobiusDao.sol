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

    function toWei(uint256 price, uint decimals) public pure returns (uint256){
        uint256 amount = price * (10 ** uint256(decimals));
        return amount;
    }

}

contract MobiusDao is Modifier, Util {

    using SafeMath for uint256;

    uint256 public networkPledge;
    uint256 public networkRedeem;
    uint256 private redeemTime;

    mapping(address => uint256) pledgeMapping;
    mapping(address => uint256) redeemMapping;
    mapping(address => uint256) redeemIndex;
    mapping(address => mapping(uint256 => uint256)) redeemIndexTime;
    mapping(address => mapping(uint256 => uint256)) redeemIndexQuantity;

    ERC20 private pancakePair;

    constructor() {
        redeemTime = 10;
        pancakePair = ERC20(0x9ca5C700B116E6C67C8C316872BCf516959d2735);
    }

    function setTokenContract(address _pancakePair) public onlyOwner {
        pancakePair = ERC20(_pancakePair);
    }

    function setRedeemTime(uint256 _redeemTime) public onlyOwner {
        redeemTime = _redeemTime;
    }

    function pledge(uint256 amountToWei) public isRunning nonReentrant returns (bool) {

        pancakePair.transferFrom(msg.sender, address(this), amountToWei);
        pledgeMapping[msg.sender] = pledgeMapping[msg.sender].add(amountToWei);
        networkPledge = networkPledge.add(amountToWei);
        return true;
    }

    function redeem(uint256 amountToWei) public isRunning nonReentrant returns (bool) {
        
        if(pledgeMapping[msg.sender] < amountToWei) {
            _status = _NOT_ENTERED;
            revert("Mobius: Insufficient redeemable quantity");
        }
        
        pledgeMapping[msg.sender] = pledgeMapping[msg.sender].sub(amountToWei);
        networkRedeem = networkRedeem.add(amountToWei);
        redeemMapping[msg.sender] = redeemMapping[msg.sender].add(amountToWei);
        redeemIndex[msg.sender] = redeemIndex[msg.sender].add(1);
        redeemIndexTime[msg.sender][redeemIndex[msg.sender]] = block.timestamp;
        redeemIndexQuantity[msg.sender][redeemIndex[msg.sender]] = amountToWei;

        return true;
    }

    function getMyPledge(address _address) public view returns(uint256){
        return pledgeMapping[_address];
    }

    function getMyRedeem(address _address) public view returns(uint256){
        return redeemMapping[_address];
    }

    function getWaitReceiveQuantity(address _address) public view returns(uint number) {
        if(redeemMapping[_address] == 0) {
            return 0;
        }
        return computeWaitReceiveQuantity(_address);
    }

    function receiveRedeem() public isRunning nonReentrant returns (bool) {
        if(redeemMapping[msg.sender] == 0) {
            _status = _NOT_ENTERED;
            revert("Mobius: Insufficient quantity available");
        }
        
        uint256 waitReceive = 0;
        uint256 secondsOfDay = 24 * 60 * 60 * redeemTime;
        if(redeemIndex[msg.sender] > 0) {
            for(uint8 i=1; i<=redeemIndex[msg.sender]; i++) {
                if(block.timestamp >= (redeemIndexTime[msg.sender][i].add(secondsOfDay))) {
                    waitReceive = waitReceive.add(redeemIndexQuantity[msg.sender][i]);
                    redeemIndexQuantity[msg.sender][i] = 0;
                }
            }
        }

        redeemMapping[msg.sender] = redeemMapping[msg.sender].sub(waitReceive);
        pancakePair.transfer(msg.sender, waitReceive);

        return true;
    }

    function computeWaitReceiveQuantity(address _address) private view returns (uint256 number) {
        uint256 secondsOfDay = 24 * 60 * 60 * redeemTime;
        if(redeemIndex[_address] > 0) {
            uint256 waitReceive = 0;
            for(uint8 i=1; i<=redeemIndex[_address]; i++) {
                if(block.timestamp >= (redeemIndexTime[_address][i].add(secondsOfDay))) {
                    waitReceive = waitReceive.add(redeemIndexQuantity[_address][i]);
                }
            }
            return waitReceive;
        } else {
            return 0;
        }
    
    }

}