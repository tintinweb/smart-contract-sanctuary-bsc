/**
 *Submitted for verification at BscScan.com on 2023-01-27
*/

pragma solidity ^ 0.8.0;

// SPDX-License-Identifier: UNLICENSED

interface IBEP20 {
  function totalSupply() external view returns (uint256);
  function balanceOf(address who) external view returns (uint256);
  function allowance(address owner, address spender) external view returns (uint256);
  function transfer(address to, uint256 value) external returns (bool);
  function approve(address spender, uint256 value) external returns (bool);
  
  function transferFrom(address from, address to, uint256 value) external returns (bool);
  function burn(uint256 value) external returns (bool);
  event Transfer(address indexed from,address indexed to,uint256 value);
  event Approval(address indexed owner,address indexed spender,uint256 value);
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

contract TITANIUM {
    using SafeMath for uint256;
    event Multisended(uint256 value , address indexed sender);
    event WithDraw(address indexed  investor,uint256 WithAmt);
    event MemberPayment(address indexed  investor,uint netAmt,uint256 Withid);
    event Deposit(string investor,string investorId,uint256 package,string invest_type);
    event Reinvest(string user,uint256 amountBuy);
    event Registration(string user,address referrer,string referrerId,uint256 package);
    event Payment(uint256 NetQty);
	
    struct User {
        uint256 id;
        address referrer;
        uint256 partnersCount;
        uint256 levelIncome;
        uint256 totalBuy;
        uint256 sponcerIncome;
    }

    mapping(address => User) public users;
    mapping(uint256 => address) public idToAddress;
    mapping(uint8=>uint8) public refPercent;
    IBEP20 private BUSD; 
    uint256 public lastUserId;
    uint256 public ttlbuy;
    address public owner;
     address public devWallet;

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    constructor(address ownerAddress,address _devWallet,IBEP20 _BUSD) {
        owner = ownerAddress; 
        devWallet=_devWallet;
        BUSD = _BUSD;
        lastUserId = 1;
        users[owner].id = lastUserId;
        users[owner].referrer = address(0);
        users[owner].partnersCount = uint256(0);
        idToAddress[users[owner].id] = owner;
        lastUserId= lastUserId.add(1);     
    }
    
     

   function registration(uint256 _amount,string memory addr,address refadd,string memory _referrerId ) external {
        require(!isUserExists(msg.sender), "User Exists!");
        require(_amount>=50*1e18,"invalid package");
        uint256 devAmt=_amount*10/100;
        uint256 ownerAmt=_amount*90/100;
        require(BUSD.balanceOf(msg.sender) >= _amount,"Low BUSD Balance");
        require(BUSD.allowance(msg.sender,address(this)) >= _amount,"Invalid allowance");
        emit Registration(addr,refadd,_referrerId,_amount);
        BUSD.transferFrom(msg.sender, owner, ownerAmt);
        BUSD.transferFrom(msg.sender, devWallet, devAmt);
 	}

    function upgrade(uint256 _amount,string memory addr,string memory userId ) external {
       
        uint256 devAmt=_amount*10/100;
        uint256 ownerAmt=_amount*90/100;
        require(BUSD.balanceOf(msg.sender) >= _amount,"Low BUSD Balance");
        require(BUSD.allowance(msg.sender,address(this)) >= _amount,"Invalid allowance");
        BUSD.transferFrom(msg.sender, owner, ownerAmt);
        BUSD.transferFrom(msg.sender, devWallet, devAmt);
        emit Deposit(addr,userId,_amount,"LEVEL");
	}

    function matrix(uint256 _amount,string memory addr,string memory userId ) external {
       
        uint256 devAmt=_amount*10/100;
        uint256 ownerAmt=_amount*90/100;
        require(BUSD.balanceOf(msg.sender) >= _amount,"Low BUSD Balance");
        require(BUSD.allowance(msg.sender,address(this)) >= _amount,"Invalid allowance");
        BUSD.transferFrom(msg.sender, owner, ownerAmt);
        BUSD.transferFrom(msg.sender, devWallet, devAmt);
        emit Deposit(addr,userId,_amount,"MATRIX");
	}
    
    function multisendToken(address payable[]  memory  _contributors, uint256[] memory _balances, uint256 totalQty,uint256[] memory WithId,IBEP20 _TKN) public payable {
    	uint256 total = totalQty;
        uint256 i = 0;
        for (i; i < _contributors.length; i++) {
        require(total >= _balances[i]);
        total = total.sub(_balances[i]);
        _TKN.transferFrom(msg.sender, _contributors[i], _balances[i]);
		emit MemberPayment(_contributors[i],_balances[i],WithId[i]);
        }
		emit Payment(totalQty);
        
    }

    function withdrawToken(IBEP20 _token ,uint256 _amount) external onlyOwner {
        _token.transfer(owner,_amount);
    }

    function withdraw(uint256 _amount) external onlyOwner {
        payable(owner).transfer(_amount);
    }

	
    function isUserExists(address user) public view returns (bool) {
        return (users[user].id != 0);
    }

    function ChangeDev(address _devWallet) external onlyOwner {
        devWallet=_devWallet;
    }
    function ChangeOwner(address _ownerAddress) external onlyOwner {
        owner=_ownerAddress;
    }
}