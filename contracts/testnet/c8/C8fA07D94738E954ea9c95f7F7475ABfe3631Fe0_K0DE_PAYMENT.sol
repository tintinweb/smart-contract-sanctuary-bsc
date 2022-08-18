/**
 *Submitted for verification at BscScan.com on 2022-08-18
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from,address to,uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
interface IRouter {
    function factory() external pure returns (address);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline) external;
}
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
library Address{
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}


contract K0DE_PAYMENT is Ownable{
    using Address for address payable;

    IERC20 public k0deContract;
    address private DEAD = 0x000000000000000000000000000000000000dEaD;
    address public STABLECOIN = 0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684;

    IRouter public router;
    uint256 public priceSingleBotUSD = 10;
    uint256 public pricePackageBotUSD = 30;
    uint256 public _totalk0deTokensPaid;

    constructor(){
        IERC20 _k0deContract = IERC20(0xe55b947C562114EEe6AD416b5748aC5bB5fE26EE);
        k0deContract = _k0deContract;
        IRouter _router = IRouter(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        router = _router;
    }

    function getTokensAmount(uint256 usdAmount) public view returns(uint256){
        address[] memory path = new address[](3);
        path[0] = STABLECOIN; //USDT
        path[1] = router.WETH(); //WBNb
        path[2] = address(k0deContract); //k0de
        uint[] memory amounts = new uint[](2);
        amounts = router.getAmountsOut(usdAmount * 1 ether,path); 
        return amounts[2]; // this returns a number that's needed to be divided by 10**18
    }

    //before making payments user has to call Approve on k0de contract and approve this PaymentCA
    function singlePayment() external returns(bool){
        uint256 paymentAmount = getTokensAmount(priceSingleBotUSD);
        require(k0deContract.balanceOf(msg.sender) >= paymentAmount,"Insuffecient Funds");
        _totalk0deTokensPaid+=paymentAmount;
        k0deContract.transferFrom(msg.sender,address(this),paymentAmount);
        //from here we can either burn half or send half basically anything
        emit SinglePayment(msg.sender,paymentAmount);
        return true;
    }

    function packagePayment() external returns(bool){
        uint256 paymentAmount = getTokensAmount(pricePackageBotUSD);
        require(k0deContract.balanceOf(msg.sender) >= paymentAmount,"Insuffecient Funds");
        _totalk0deTokensPaid+=paymentAmount;
        k0deContract.transferFrom(msg.sender,address(this),paymentAmount);
        //from here we can either burn half or send half basically anything
        emit SinglePayment(msg.sender,paymentAmount);
        return true;
    }

    event SinglePayment(address payor, uint256 tokensAmount);
    event PackagePayment(address payor, uint256 tokensAmount);
}