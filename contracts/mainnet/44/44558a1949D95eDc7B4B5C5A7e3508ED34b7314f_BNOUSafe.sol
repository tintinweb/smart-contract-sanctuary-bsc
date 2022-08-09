/**
 *Submitted for verification at BscScan.com on 2022-08-09
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
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

// MAFTECCHIP with Governance.
contract BNOUSafe is Ownable {
    using SafeMath for uint256;

    // The Bitnou Coin!
    IBEP20 public bnou;
    mapping(address => bool) public isOperator;
    address[] public operators;

    modifier onlyOperator() {
        require(isOperator[msg.sender], "Not operator");
        _;
    }

    event OperatorSet(address indexed _operator, bool _flag);

    constructor(
        address _bnou
    ) {
        bnou = IBEP20(_bnou);
        isOperator[msg.sender] = true;
    }

    // Safe maftec transfer function, just in case if rounding error causes pool to not have enough MAFTECs.
    function safeBNOUTransfer(address _to, uint256 _amount) public onlyOperator {
        uint256 bnouBal = bnou.balanceOf(address(this));
        if (_amount > bnouBal) {
            bnou.transfer(_to, bnouBal);
        } else {
            bnou.transfer(_to, _amount);
        }
    }

    function setOperator(address _operator, bool _flag) external onlyOwner {
        if (_flag) {
            if (!isOperator[_operator]) {
                isOperator[_operator] = true;
                operators.push(_operator);
            }
        } else {
            if (isOperator[_operator]) {
                isOperator[_operator] = false;
                for (uint256 i=0; i<operators.length; i++) {
                    if (operators[i] == _operator) {
                        operators[i] = operators[operators.length - 1];
                        operators.pop();
                        break;
                    }
                }
            }
        }

        emit OperatorSet(_operator, _flag);
    }

}