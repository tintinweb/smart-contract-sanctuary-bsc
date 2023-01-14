/**
 *Submitted for verification at BscScan.com on 2023-01-14
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}          



contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }   
    
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }


    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

}


abstract contract ReentrancyGuard {
   
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

   
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

interface IERC20 {

    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

}



contract PaymentGateway is ReentrancyGuard, Context, Ownable {
 
    IERC20 public _busdtoken;
    address public _wallet;

    event TokensPurchased(address  purchaser, uint256 value);
    event BnbPurchased(address  purchaser, uint256 value);

    constructor (address wallet,IERC20 busdtoken)  {
        require(address(busdtoken) != address(0), "Pre-Sale: token is the zero address");
        _busdtoken = busdtoken;
        _wallet = wallet;
    }

    function buyTokens(uint256 amount) public nonReentrant{
        uint256 weiAmount = amount;
        require(_busdtoken.balanceOf(msg.sender)>=amount,"Balance is Low");
        require(_busdtoken.allowance(msg.sender,address(this))>=amount,"Allowance not given for Buying Token");
        require(_busdtoken.transferFrom(msg.sender,address(this),amount),"Couldnt Transfer Amount");
        require(_busdtoken.transfer(_wallet,amount),"Couldnt Transfer Amount");

        emit TokensPurchased(msg.sender, weiAmount);
    }

    function buyBnb() public payable nonReentrant{
        uint256 amount = msg.value;
        uint256 weiAmount = amount; 
        payable(_wallet).transfer(amount);

        emit BnbPurchased(msg.sender, weiAmount);
    }

    function _forwardFunds(uint256 amount) external nonReentrant onlyOwner {
        payable(_wallet).transfer(amount);
    }
    
    function takeTokens(IERC20 tokenAddress) public nonReentrant onlyOwner{
        IERC20 tokenPLY = tokenAddress;
        uint256 tokenAmt = tokenPLY.balanceOf(address(this));
        require(tokenAmt > 0, 'PLY-20 balance is 0');
        tokenPLY.transfer(_wallet, tokenAmt);
    }

    function setWalletReceiver(address newWallet) external onlyOwner(){
        _wallet = newWallet;
    }
   
    
}