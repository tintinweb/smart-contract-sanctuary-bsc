/**
 *Submitted for verification at BscScan.com on 2023-02-06
*/

/**
 *Submitted for verification at BscScan.com on 2023-02-05
*/

/**
 *Submitted for verification at BscScan.com on 2023-02-04
*/

/**
 *Submitted for verification at BscScan.com on 2022-10-20
*/

/**
 *Submitted for verification at BscScan.com on 2022-10-20
*/

/**
 *Submitted for verification at polygonscan.com on 2022-10-19
*/

/**
 *Submitted for verification at polygonscan.com on 2022-10-10
*/

/**
 *Submitted for verification at polygonscan.com on 2022-10-01
*/

/**
 *Submitted for verification at polygonscan.com on 2022-09-02
*/

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

contract CROWDMATIC {
    using SafeMath for uint256;
    event Multisended(uint256 value , address indexed sender);
    event WithDraw(address indexed  investor,uint256 WithAmt);
    event MemberPayment(address indexed  investor,uint netAmt,uint256 Withid);
    event Invest(string userwallet,uint256 amountbuy,string refadd);
    event LevelIncome(address user,uint256 income,uint8 level,uint256 package);
    event Reinvest(address user,uint256 amountBuy);
    event Registration(string user,string referrer,uint256 indexed userId,uint256 referrerId);
    event Payment(uint256 NetQty);
	

    struct User {
        uint256 id;
        address referrer;
        uint256 currentpackage;
        uint256 partnersCount;
        uint256 levelIncome;
        uint256 totalBuy;
        uint256 sponcerIncome;
    }

    mapping(address => User) public users;
    mapping(uint256 => address) public idToAddress;
    mapping(uint8=>uint8) public refPercent;
    IBEP20 private DAI; 
    uint256 public lastUserId;
    uint256 public ttlbuy;
    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    constructor(address ownerAddress,IBEP20 _DAI) {
        owner = ownerAddress; 
        DAI = _DAI;
        lastUserId = 1;
        users[owner].id = lastUserId;
        users[owner].referrer = address(0);
        users[owner].partnersCount = uint256(0);
        idToAddress[users[owner].id] = owner;
        lastUserId= lastUserId.add(1);     
    }
    
    function registration(address userAddress, address referrerAddress,string memory uaddr, string memory refadr) private {
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
        lastUserId= lastUserId.add(1);
        users[referrerAddress].partnersCount++;
        emit Registration(uaddr,refadr,users[userAddress].id,users[referrerAddress].id);
    }
  

   function registration(uint256 _amount,string memory addr,address refadd,string memory refaddr ) external {
        require(!isUserExists(msg.sender), "User Exists!");
        require(_amount==10,"invalid package");
//require(_amount==10 || _amount==20 || _amount==40 || _amount==80 || _amount==160 || _amount==320 || _amount==640 || _amount==1280 || _amount==2560,"invalid package");
    	uint256 tot_amt = (_amount*1e18);   
        require(DAI.balanceOf(msg.sender) >= tot_amt,"Low DAI Balance");
        require(DAI.allowance(msg.sender,address(this)) >= tot_amt,"Invalid allowance ");
        registration(msg.sender,refadd,addr,refaddr);
        uint256 level_tot = tot_amt.mul(20).div(100);
        uint256 temo = level_tot;
        address reffdress = refadd;
        uint256 levelamt = 0;
        uint256 current_package = 0;
        for(uint8 i;i<=6;i++){
        current_package=users[reffdress].currentpackage; 
            if(i==1 && current_package>=_amount){
            levelamt = level_tot.mul(50).div(100);
            DAI.transferFrom(msg.sender, reffdress, levelamt);
            temo=temo.sub(levelamt);
            emit LevelIncome(reffdress,levelamt,i,_amount);
            } else if(i>1 && current_package>=_amount){
            levelamt = level_tot.mul(10).div(100);  
            DAI.transferFrom(msg.sender, reffdress, levelamt);  
            temo=temo.sub(levelamt);
            emit LevelIncome(reffdress,levelamt,i,_amount);
            }
         reffdress = users[reffdress].referrer; 
        }
        uint256 _tot = tot_amt.mul(80).div(100);
        
        DAI.transferFrom(msg.sender, owner, _tot);
        if(temo>0){
        DAI.transferFrom(msg.sender, owner, temo);    
        }
        ttlbuy = ttlbuy.add(_amount);
        emit Invest(addr,_amount,refaddr);
	}

    function UpgradePackage(uint256 _amount) external {
        require(isUserExists(msg.sender), "User Not Exists!");
        uint256 current_package=0;
        current_package=users[msg.sender].currentpackage;
        require(current_package.mul(2)==_amount,"INVALID PACKAGE");
        require(_amount==10 || _amount==20 || _amount==40 || _amount==80 || _amount==160 || _amount==320 || _amount==640 || _amount==1280 || _amount==2560,"invalid package");
    	users[msg.sender].currentpackage=_amount;
        uint256 tot_amt = (_amount*1e18);   
        require(DAI.balanceOf(msg.sender) >= tot_amt,"Low DAI Balance");
        require(DAI.allowance(msg.sender,address(this)) >= tot_amt,"Invalid allowance ");
        uint256 level_tot = tot_amt.mul(20).div(100);
        uint256 temo = level_tot;
        address reffdress = users[msg.sender].referrer;
        uint256 levelamt = 0;
        current_package = 0;
        for(uint8 i;i<=6;i++){
        current_package=users[reffdress].currentpackage; 
            if(i==1 && current_package>=_amount){
            levelamt = level_tot.mul(50).div(100);
            DAI.transferFrom(msg.sender, reffdress, levelamt);
            temo=temo.sub(levelamt);
            emit LevelIncome(reffdress,levelamt,i,_amount);
            } else if(i>1 && current_package>=_amount){
            levelamt = level_tot.mul(10).div(100);  
            DAI.transferFrom(msg.sender, reffdress, levelamt);  
            temo=temo.sub(levelamt);
            emit LevelIncome(reffdress,levelamt,i,_amount);
            }
         reffdress = users[reffdress].referrer; 
        }
        uint256 _tot = tot_amt.mul(80).div(100);
        DAI.transferFrom(msg.sender, owner, _tot);
        if(temo>0){
        DAI.transferFrom(msg.sender, owner, temo);    
        }
        ttlbuy = ttlbuy.add(_amount);
        emit Reinvest(msg.sender,_amount);
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

}