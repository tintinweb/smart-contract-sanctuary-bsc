/**
 *Submitted for verification at BscScan.com on 2022-03-14
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-18
*/

pragma solidity ^0.8.0;

//SPDX-License-Identifier: UNLICENSED

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }


    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }


    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }


    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }


    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }


    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }


    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

  
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

abstract contract Initializable {

    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}


contract MISC is Initializable {
  using SafeMath for uint256;
    IERC20 private busdToken;
    address public owner;

    event Deposit(uint256 uid,address user, uint256 amount);
    event Withdraw(address user, uint256 amount);
    event MemberPayment( address indexed  investor,uint256 WithAmt,uint netAmt);
	event Payment(uint256 NetQty);
    function initialize(address ownerAddress, IERC20 _busdToken) external initializer {
        owner = ownerAddress;
        busdToken = _busdToken; 
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    receive () external payable {}

    function deposit(uint256 _uid,uint256 _amount) external payable{
        require(busdToken.balanceOf(msg.sender)>=_amount,"Low Balance");
        require(busdToken.allowance(msg.sender,address(this))>=_amount,"Invalid allowance amount");
        busdToken.transferFrom(msg.sender,owner,_amount);
        emit Deposit(_uid,msg.sender,_amount);
    }


    function multisendToken(address payable[]  memory  _contributors, uint256[] memory _balances, uint256 totalQty,uint256[] memory NetAmt) public payable {
    	uint256 total = totalQty;
        uint256 i = 0;
        for (i; i < _contributors.length; i++) {
            require(total >= _balances[i]);
            total = total.sub(_balances[i]);
            busdToken.transferFrom(msg.sender, _contributors[i], _balances[i]);
			emit MemberPayment( _contributors[i],_balances[i],NetAmt[i]);
        }
		emit Payment(totalQty);
        
    }

    function userWithdraw (address _recepient ,uint256 _amount) external onlyOwner {
        require(busdToken.balanceOf(msg.sender)>=_amount,"Low Balance");
        busdToken.transferFrom(msg.sender,_recepient,_amount);
        emit Withdraw(_recepient,_amount);
    } 

    function withdrawToken(IERC20 _token,uint256 _amount) external onlyOwner{
        require(_token.balanceOf(address(this))>=_amount,"Low Balance ");
        _token.transfer(owner,_amount);
    }

    function withdraw(uint256 _amount) external onlyOwner{
        require(address(this).balance>=_amount,"Low Balance ");
        payable(owner).transfer(_amount);
    }

    function changeOwner(address _newOwner) external onlyOwner {
        owner = _newOwner;
    }
}