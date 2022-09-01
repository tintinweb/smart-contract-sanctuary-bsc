/**
 *Submitted for verification at BscScan.com on 2022-09-01
*/

//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

library SafeMath {
    function add(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    function sub(uint a, uint b) internal pure returns (uint) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        require(b <= a, errorMessage);
        uint c = a - b;
        return c;
    }
    function mul(uint a, uint b) internal pure returns (uint) {
        if (a == 0) {
            return 0;
        }
        uint c = a * b;
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

library TransferHelper {
    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::transferFrom: transferFrom failed'
        );
    }
}

interface IBEP20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint value);
}

abstract contract Ownable {
    address public _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }
    function owner() public view returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
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

contract MinerPool is Ownable{
    using SafeMath for uint;

    address public walletA=0xCE3fF91919104c3008D5100fAdA30266D8ee7099;
    address public walletB=0xdD25fCbF41b84DD34f7B0C8b31Ba4F89F5070626;
    uint public shareA = 10;

    function charge(address token,  uint amount) external {
        require(amount > 0, 'invalid amount');
        uint amountA = amount.mul(shareA).div(100);
        uint amountB = amount.sub(amountA);
		require(IBEP20(token).allowance(msg.sender, address(this)) >= amount, 'allowance not enough');
		require(IBEP20(token).balanceOf(msg.sender) >= amount, 'balance not enough');
        TransferHelper.safeTransferFrom(token, msg.sender, walletA, amountA);
        TransferHelper.safeTransferFrom(token, msg.sender, walletB, amountB);
    }

    function setWalletA(address value) external onlyOwner { 
        walletA = value;
    }

    function setWalletB(address value) external onlyOwner { 
        walletB = value;
    }

    function setShareA(uint value) external onlyOwner { 
        require(value <= 100, "wrong value");
        shareA = value;
    }

    function viewAmountOfThis(address token) external view returns(uint) {  //查看当前合约的持币数量
        uint amount = IBEP20(token).balanceOf(address(this));
        return amount;
    }

    function exactTokens(address token, uint amount) external onlyOwner {
        uint balanceOfThis = IBEP20(token).balanceOf(address(this)); //提取合约中剩余的币
        require(balanceOfThis >= amount, 'no balance');
        IBEP20(token).transfer(msg.sender, amount);
    }
}