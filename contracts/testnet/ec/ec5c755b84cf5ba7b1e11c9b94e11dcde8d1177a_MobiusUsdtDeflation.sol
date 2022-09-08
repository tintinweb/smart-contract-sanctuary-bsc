/**
 *Submitted for verification at BscScan.com on 2022-09-08
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

contract MobiusUsdtDeflation is Modifier, Util {

    using SafeMath for uint256;

    address private deflationPoolAddress;
    address private promoteAddress;
    address private minePoolAddress;

    uint256 private joinLimit;
    uint256 private deflationPoolRatio;
    uint256 private promoteRatio;

    ERC20 private usdtToken;
    ERC20 private mobToken;

    constructor() {
        deflationPoolRatio = 50;
        promoteRatio = 20;
        joinLimit = 20000000000000000000;

        promoteAddress = 0x4556B6F436c33bc9CDB44E87bca656957df26a94;
        minePoolAddress = 0x491B298E585521eD6f0BE21a8fBD7a0A5A6c848d;
        mobToken = ERC20(0x1365a1069C4cd570093396Dc92502315747d95bF);

    }

    function setJoinLimit(uint256 _joinLimit) public onlyOwner {
        joinLimit = _joinLimit;
    }

    function setTokenContract(address _mobToken) public onlyOwner {
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

        mobToken.transferFrom(msg.sender, address(this), amountToWei);

        uint256 deflationPoolAmount = amountToWei.mul(deflationPoolRatio).div(100);
        uint256 promoteAmount = amountToWei.mul(promoteRatio).div(100);
        uint256 minePoolAmount = amountToWei.sub(deflationPoolAmount).sub(promoteAmount);

        mobToken.transfer(deflationPoolAddress, deflationPoolAmount);
        mobToken.transfer(minePoolAddress, minePoolAmount);
        mobToken.transfer(promoteAddress, promoteAmount);

        return true;
    }

}