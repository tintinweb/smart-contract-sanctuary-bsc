/**
 *Submitted for verification at BscScan.com on 2022-04-28
*/

pragma solidity ^0.6.12;
// SPDX-License-Identifier: Unlicensed
interface IERC20 {
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
        return c;
    }
}
contract Pool {
    using SafeMath for uint256; 
    IERC20 private immutable iErc20Token;
    mapping(address => uint256) public _rewardAmountMap;
    uint256 private _dayToken = 200 * 10 ** 18;
    address private _account;
    address private _owner;
    uint256 public _tokenCount = 0;
    uint256 public _lastTime = 0;
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    constructor(address tokenContract) public{
        _owner = msg.sender;
        iErc20Token = IERC20(tokenContract);
    }

    function setAccount(address account)public onlyOwner{
        _account = account;
    }
    
    function toAccountToken(uint256 amount) public {
        if(_tokenCount == _dayToken && now - _lastTime > 86400){
            _tokenCount = 0;
        }
        _lastTime = now;
        require(_tokenCount.add(amount) <= _dayToken,"The ceiling has been set today");
        iErc20Token.transfer(msg.sender,amount);
        _tokenCount = _tokenCount.add(amount);
    }

}