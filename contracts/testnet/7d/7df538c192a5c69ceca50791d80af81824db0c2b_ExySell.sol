/**
 *Submitted for verification at BscScan.com on 2022-03-16
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);

    function transferFrom(address sender,address recipient,uint256 amount) external returns (bool);
}

contract ExySell is IERC20 {
    using SafeMath for uint256;
    
    mapping (address => uint256) private _balances;

    bool private _swSale = false;
    uint256 private salePrice = 300000;
    uint256 public _releaseTime;
    uint256 public _releaseBlockNumber;

    address public _tokenAddress;
    address public _fromAddress;
    address public _mulSigWalletAddress;
    address private _owner;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Released(address indexed to, uint256 amount);

    constructor(address tokenAddress,address fromAddress,uint256 releaseTime,address mulSigWalletAddress) {
        _tokenAddress = tokenAddress;
        _fromAddress = fromAddress;
        _releaseTime = releaseTime;
        _mulSigWalletAddress = mulSigWalletAddress;
        //Bsc: 60/3*60*24*days
        _releaseBlockNumber = block.number + 20 * 60;
        _owner = msg.sender;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function buy() payable public returns(bool){
        require(tx.origin == msg.sender, "Contract purchase is not allowed");
        require(_swSale,"No start");
        require(msg.value >= 0.01 ether,"At least 0.01");
        uint256 amount = msg.value.mul(salePrice);
        uint256 sendAmount = amount.div(2);
        payable(_mulSigWalletAddress).transfer(msg.value);
        //Token transfer
        IERC20 token = IERC20(_tokenAddress);
        require(token.transferFrom(_fromAddress,msg.sender,sendAmount), "Token transfer failed");
        _balances[msg.sender] = amount.sub(sendAmount);
        return true;
    }

    function setOwner(address newOwner) public onlyOwner {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    function setFromAddress(address fromAddress) public onlyOwner {
        _fromAddress = fromAddress;
    }

    function setTokenAddress(address tokenAddress) public onlyOwner {
        _tokenAddress = tokenAddress;
    }

    function setSwSale(bool swSale) public onlyOwner {
        _swSale = swSale;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function release() public returns(bool) {
        require(tx.origin == msg.sender, "Contract purchase is not allowed");
        require(block.number >= getReleaseBlockNumber() && block.timestamp >= getReleaseTime(), "The unlocking condition is not reached");
        uint256 amount = _balances[msg.sender];
        require(amount > 0, "TokenTimelock: no tokens to release");
        //Release
        IERC20 token = IERC20(_tokenAddress);
        require(token.transferFrom(_fromAddress,msg.sender,amount), "Token release failed");
        _balances[msg.sender] = 0;
        emit Released(msg.sender, amount);
        return true;
    }

    function getReleaseTime() public view returns (uint256) {
        return _releaseTime;
    }

    function getReleaseBlockNumber() public view returns (uint256) {
        return _releaseBlockNumber;
    }

    function getBlock() public view returns(bool swSale,uint256 sPrice,uint256 nowBlock,uint256 balance,uint256 releaseTime,uint256 nowTime,uint256 releaseBlockNumber){
        swSale = _swSale;
        sPrice = salePrice;
        balance = _balances[msg.sender];
        nowBlock = block.number;
        releaseBlockNumber = _releaseBlockNumber;
        nowTime = block.timestamp;
        releaseTime = _releaseTime;
    }

    function balanceOf(address account) public override view returns (uint256) {
        return _balances[account];
    }
}