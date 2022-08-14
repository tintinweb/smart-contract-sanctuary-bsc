/**
 *Submitted for verification at BscScan.com on 2022-08-13
*/

//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.6.12;

interface IERC20 {
 
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function decimals() external view returns (uint8);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
 
 
}
 
library SafeMath {
 
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
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
 
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }
 
    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}
 

contract Ownable is Context {
    address private _owner;
    address private _creator;
    address private _previousOwner;
    uint256 private _lockTime;
 
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event UpdateUniswapV2Router(address indexed newAddress, address indexed oldAddress);
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        _creator = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
 
    function owner() public view returns (address) {
        return _owner;
    }
 
    function creator() public view returns (address) {
        return _creator;
    }
 
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
 
    modifier onlyCreator() {
        require(_creator == _msgSender(), "Ownable: caller is not the creator");
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
 
    function getUnlockTime() public view returns (uint256) {
        return _lockTime;
    }
 
    function getTime() public view returns (uint256) {
        return now;
    }
 
}

contract TokenClaim is Ownable{

    uint256 token_claim_amount = 100;
    mapping (address => bool) private claimed;
    IERC20 token; 
    uint256 decimals; 

    constructor(IERC20 _token, uint8 _decimals) public {
            token = _token;
            decimals = _decimals;
            token_claim_amount = 100 * 10 ** decimals;
    }

    function setClaimAmount(uint256 amount) public onlyOwner{
        token_claim_amount = amount;
    }

    function setToken(IERC20 _token) public onlyOwner{
        token = _token;
    }

    function setDecimals( uint8 _decimals) public onlyOwner{
        decimals = _decimals;
        token_claim_amount = token_claim_amount * 10 ** decimals;
    }

    function recoverTokens() public onlyOwner {
        token.transfer(owner(), token.balanceOf(address(this)));
    }

    function claimTokens() public {
        require(claimed[msg.sender] == false, "Tokens have already been claimed with this wallet");
        token.transfer(msg.sender, token_claim_amount);
        claimed[msg.sender] = true;
    }

}