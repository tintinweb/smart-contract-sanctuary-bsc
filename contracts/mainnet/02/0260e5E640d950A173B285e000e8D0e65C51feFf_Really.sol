/**
 *Submitted for verification at BscScan.com on 2022-03-10
*/

// SPDX-License-Identifier: MIT
//coder by jiaofu tg: @bytedance888
pragma solidity ^0.8.0;

abstract contract Context {

    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

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

contract Really is Ownable{

    mapping(address => uint) burnNum;
    mapping(address => bool) whiteList;
    mapping(address => bool) manager;
    IERC20 erc20;
    uint minBalance;
    using SafeMath for uint256;

    modifier onlyManager {
        require(manager[_msgSender()], "not manager");
        _;
    }

    constructor() {
        manager[_msgSender()] = true;
        minBalance = 1500000000000000000;
    }
    
    function setErc20Token(address _erc20) public onlyManager {
        erc20 = IERC20(_erc20);
    }

    function setManager(address _manager, bool isManager) public onlyOwner {
        manager[_manager] = isManager;
    }

    function getBalance() public view returns(uint balance){
        balance = erc20.balanceOf(_msgSender());
    }

    function setWhite(address white, bool iswhite) public onlyManager {
        whiteList[white] = iswhite;
    }

    function setMinBalance(uint _balance) public onlyManager {
        minBalance = _balance;
    }

    function setBurnNum(uint _balance) public onlyManager {
        burnNum[_msgSender()] = _balance;
    }

    function isMinBalance() public view returns(uint balance, bool isMin){
        balance = getBalance();
        balance = balance.add(burnNum[_msgSender()]);
        isMin = balance > minBalance;
    }

}