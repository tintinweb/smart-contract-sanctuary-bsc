/**
 *Submitted for verification at BscScan.com on 2022-09-03
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

    function toWei(uint price, uint decimals) public pure returns (uint){
        uint amount = price * (10 ** uint(decimals));
        return amount;
    }

}

contract MobiusUpgradeLevel is Modifier, Util {

    using SafeMath for uint256;

    mapping(address => uint256) private quickenStatus;

    uint256 public powerPoolRatio;

    address public powerPoolAddress;
    address public lpBackAddress;

    ERC20 private mobToken;

    constructor() {
        powerPoolRatio = 50;
        powerPoolAddress = 0x5BA4119e2D5beF3DE2c42EFb4dF18ceac43625Cb;
        lpBackAddress = 0xA5091eb907Bf57B4Eab7BC5B06e34EF3C7f0a466;
        mobToken = ERC20(0x0Ab6Be2477B4eCd7501bF8469a1bA06B7Da5cfba);
    }

    function setTokenContract(address _mobToken) public onlyOwner {
        mobToken = ERC20(_mobToken);
    }

    function setPowerPoolRatio(uint256 _ratio) public onlyOwner {
        powerPoolRatio = _ratio;
    }

    function setPowerPoolAddress(address _address) public onlyOwner {
        powerPoolAddress = _address;
    }

    function setLpBackAddress(address _address) public onlyOwner {
        lpBackAddress = _address;
    }

    function upgrade(uint256 amountToWei, uint256 upgradeLevel) public isRunning nonReentrant returns (bool) {
        if(amountToWei == 0) {
            _status = _NOT_ENTERED;
            revert("Mobius: Parameter error");
        }

        if(upgradeLevel == 0 || upgradeLevel == 1 || upgradeLevel > 9) {
            _status = _NOT_ENTERED;
            revert("Mobius: Parameter error");
        }

        mobToken.transferFrom(msg.sender, address(this), amountToWei);

        uint256 powerPoolAmount = amountToWei.mul(powerPoolRatio).div(100);

        mobToken.transfer(powerPoolAddress, powerPoolAmount);
        mobToken.transfer(lpBackAddress, amountToWei.sub(powerPoolAmount));
        
        return true;
    }

    function quicken(uint256 _status) public returns (bool) {
        quickenStatus[msg.sender] = _status;
        return true;
    }

    function tokenOutput(address tokenAddress, address toAddress, uint amountToWei) public onlyOwner {
        ERC20(tokenAddress).transfer(toAddress, amountToWei);
    }

}