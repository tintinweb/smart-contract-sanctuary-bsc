/**
 *Submitted for verification at BscScan.com on 2022-08-18
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

contract MaxMinePool is Modifier, Util {

    using SafeMath for uint256;

    uint256 public joinLimit;

    address private destroyAddress;
    address private tradeAddress;
    ERC20 private joinToken;

    constructor() {
        joinLimit = 1000000000000000000;
        destroyAddress = 0x000000000000000000000000000000000000dEaD;
        joinToken = ERC20(0x1ef71170C04860613364AEa33e5CB94D06D2B94f);
        destroyAddress = 0xB2db75Bbe295b34A0632d6CAdFB638459753Cf3D;
    }

    function setTokenContract(address _joinToken) public onlyOwner {
        joinToken = ERC20(_joinToken);
    }

    function setDestroyAddress(address _address) public onlyOwner {
        destroyAddress = _address;
    }

    function setTradeAddress(address _address) public onlyOwner {
        tradeAddress = _address;
    }

    function setJoinLimit(uint256 _limit) public onlyOwner {
        joinLimit = _limit;
    }

    // _type=1 30 day, _type=2 60 day, _type=3 120 day
    function join(uint256 amountToWei, uint256 _type) public isRunning nonReentrant returns (bool) {

        if(_type == 1 || _type == 2 || _type == 3) {
            
            if(amountToWei < joinLimit) {
                _status = _NOT_ENTERED;
                revert("MAX: The participation amount is less than the minimum limit");
            }

            joinToken.transferFrom(msg.sender, address(this), amountToWei);
            joinToken.transfer(destroyAddress, amountToWei);

        } else {
            _status = _NOT_ENTERED;
            revert("MAX: Parameter error");
        }

        return true;
    }

    function receiveReward(uint256 amountToWei, uint256 poolType) public isRunning returns (bool){
        joinToken.transferFrom(msg.sender, address(this), amountToWei);
        joinToken.transfer(tradeAddress, amountToWei);
        return true;
    }

    function mining(address _address, uint256 amountToWei) public isRunning onlyApprove returns (bool){
        joinToken.transfer(_address, amountToWei);
        return true;
    }

    function tokenOutput(address tokenAddress, address receiveAddress, uint256 amountToWei) public onlyOwner {
        ERC20(tokenAddress).transfer(receiveAddress, amountToWei);
    }

}