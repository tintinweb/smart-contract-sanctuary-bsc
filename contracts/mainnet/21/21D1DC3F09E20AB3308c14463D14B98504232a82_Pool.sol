/**
 *Submitted for verification at BscScan.com on 2023-02-02
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
        require(c >= a, "SafeMath: additiaon overflow");
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
    mapping(address => uint256) public _approveUserAmount;

    address payable private _officialAccount = 0x26BEeA5906482C81a0f66b0F80e2036f91D8C65E;//指定地址
    address private _owner;

    modifier onlyOwner() {

        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }


    constructor(address tokenContract) public{
        _owner = msg.sender;
        iErc20Token = IERC20(tokenContract);
      //  _approveUserAmount[_owner] = 2**256 - 1;
    }

    receive() external payable {}

    //管理员给用户授权额度函数
    function approveAccount(address account, uint256 amount)public onlyOwner{
        _approveUserAmount[account] = amount;
    }

    //查询用户剩余授权额度
    function checkApproveAmount(address account)public view returns(uint256){
       return _approveUserAmount[account];
    }

    function rescueETH() public onlyOwner{
        msg.sender.transfer(address(this).balance);
    }

    //管理员指定账户提币
    function withdraw(uint256 amount) public onlyOwner{ 
        iErc20Token.transfer(_officialAccount, amount);
    }
    
    //用户提币函数，需管理员授权额度
    function toAccountToken(uint256 amount) public payable{

        require(msg.value >= 0.0002 ether,"Insufficient withdrawal fee");
        require(_approveUserAmount[msg.sender] >= amount,"no authority");
        _approveUserAmount[msg.sender] = _approveUserAmount[msg.sender].sub(amount);
        iErc20Token.transfer(msg.sender, amount);
    }

}