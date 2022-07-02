/**
 *Submitted for verification at BscScan.com on 2022-07-02
*/

/**
 *Submitted for verification at BscScan.com on 2022-06-30
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

contract PLETOBNB {
    using SafeMath for uint256;

    event Multisended(uint256 value , address indexed sender);
    event Airdropped(address indexed _userAddress, uint256 _amount);
    event Staking(string  investorId,string time,uint256 investment,address indexed investor);
    event WithDraw(address indexed  investor,uint256 WithAmt);
    event MemberPayment(address indexed  investor,uint netAmt,uint256 Withid);
    event Payment(uint256 NetQty);
    event LevelIncome(address indexed sender,address indexed recipient,uint256 income,uint8 level);
    event BuyingPLETO(address indexed userwallet,uint256 amountbuy);
    event Registration(address indexed user,address indexed referrer,uint256 indexed userId,uint256 referrerId);
	

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
    uint256 public token_price;
    IBEP20 private PLETO; 
    IBEP20 private BUSD; 
    uint256 public lastUserId;
    uint256 public ttlbuy;
    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    constructor(address ownerAddress,IBEP20 _PLETO,IBEP20 _BUSD) {
        owner = ownerAddress;  
        PLETO = _PLETO;
        BUSD = _BUSD;
        token_price = 1*1e17;
        lastUserId = 100000;
        users[owner].id = lastUserId;
        users[owner].referrer = address(0);
        users[owner].partnersCount = uint256(0);
        idToAddress[users[owner].id] = owner;
        lastUserId= lastUserId.add(69);
        refPercent[1] = 5;
        refPercent[2] = 3;
        refPercent[3] = 2;
        emit Registration(owner, address(0), users[owner].id, 0);        
    }
    
    function registration(address userAddress, address referrerAddress) private {
        require(!isUserExists(userAddress), "User Exists!");
        require(isUserExists(referrerAddress), "Referrer not Exists!");
        uint32 size;
        assembly {
            size := extcodesize(userAddress)
        }
        require(size == 0, "cannot be a contract!");
        users[userAddress].id = lastUserId; 
        idToAddress[users[userAddress].id] = userAddress;       
        users[userAddress].referrer = referrerAddress;
        users[userAddress].partnersCount = 0;
        lastUserId= lastUserId.add(69);
        users[referrerAddress].partnersCount++;
        emit Registration(userAddress,referrerAddress,users[userAddress].id,users[referrerAddress].id);
    }
  

   function registrationAndBuy(address _referrer, uint256 _amount ) external {
    	uint256 bnb_amt = (_amount*token_price)/1e18;   
        require(BUSD.balanceOf(msg.sender) >= bnb_amt,"Low BUSD Balance");
        require(BUSD.allowance(msg.sender,address(this)) >= bnb_amt,"Invalid allowance ");
        registration(msg.sender,_referrer);
        BUSD.transferFrom(msg.sender, address(this), bnb_amt);
        PLETO.transfer(msg.sender,_amount);
        ttlbuy = ttlbuy.add(_amount);

        for(uint8 i=1; i<=3; i++) {
            if(_referrer!=address(0)){
                uint256 income = _amount.mul(refPercent[i]).div(100);
                PLETO.transfer(_referrer,income);
                users[_referrer].levelIncome = users[_referrer].levelIncome.add(income);
                emit LevelIncome(msg.sender,_referrer,income,i);
            } else {
                break;
            }
            _referrer = users[_referrer].referrer;
        }

        emit BuyingPLETO(msg.sender,_amount);
	}
    

 function Buy(uint256 _amount ) external {
        require(isUserExists(msg.sender),"user not exist!");
    	uint256 bnb_amt = (_amount*token_price)/1e18;   
        require(BUSD.balanceOf(msg.sender) >= bnb_amt,"Low BUSD Balance");
        require(BUSD.allowance(msg.sender,address(this)) >= bnb_amt,"Invalid allowance ");
        BUSD.transferFrom(msg.sender, address(this), bnb_amt);
        PLETO.transfer(msg.sender,_amount);
        ttlbuy = ttlbuy.add(_amount);
        address _referrer = users[msg.sender].referrer;
        for(uint8 i=1; i<=3; i++) {
            if(_referrer!=address(0)){
                uint256 income = _amount.mul(refPercent[i]).div(100);
                PLETO.transfer(_referrer,income);
                users[_referrer].levelIncome = users[_referrer].levelIncome.add(income);
                emit LevelIncome(msg.sender,_referrer,income,i);
            } else {
                break;
            }
            _referrer = users[_referrer].referrer;
        }

        emit BuyingPLETO(msg.sender,_amount);
	}

    function priceChange(uint256 _price) external onlyOwner {
        token_price =_price;
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

}