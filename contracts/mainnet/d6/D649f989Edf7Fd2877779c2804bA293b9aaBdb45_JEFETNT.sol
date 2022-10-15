/**
 *Submitted for verification at BscScan.com on 2022-10-15
*/

/**
 *Submitted for verification at FtmScan.com on 2022-09-08
*/

// SPDX-License-Identifier: MIT
//JEFE BNB STAKING ALGO , find your strategy and get the best ROI!
//WWW.JEFETOKEN.COM buy us if you like us. 
//PLAY2EARN - multi-blockchain web3
// JEFE TOKEN FTM CONTRACT 0x5b2AF7fd27E2Ea14945c82Dd254c79d3eD34685e


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
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
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

pragma solidity 0.8.9;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
    * @dev Initializes the contract setting the deployer as the initial owner.
    */
    constructor () {
      address msgSender = _msgSender();
      _owner = msgSender;
      emit OwnershipTransferred(address(0), msgSender);
    }

    /**
    * @dev Returns the address of the current owner.
    */
    function owner() public view returns (address) {
      return _owner;
    }

    
    modifier onlyOwner() {
      require(_owner == _msgSender(), "Ownable: caller is not the owner");
      _;
    }
//when we delegate our token to signer
    function renounceOwnership() public onlyOwner {
      emit OwnershipTransferred(_owner, address(0));
      _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
      _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
      require(newOwner != address(0), "Ownable: new owner is the zero address");
      emit OwnershipTransferred(_owner, newOwner);
      _owner = newOwner;
    }
}

contract JEFETNT is Context, Ownable {
    using SafeMath for uint256;

    uint256 private FierrazoMachin = 1080000;//for final version should be seconds in a day
    uint256 private patron = 10000;
    uint256 private Patron = 5000;
    uint256 private devFeeVal = 3;
    bool private initialized = false;
    address payable private recAdd;
    address payable private clientAdd;
    mapping (address => uint256) private hatcheryMiners;
    mapping (address => uint256) private claimedJefes;
    mapping (address => uint256) private lastHatch;
    mapping (address => address) private referrals;
    uint256 private marketJefes;

    constructor() {
        recAdd = payable(msg.sender);
        clientAdd = payable(address(0x4b564515Ee500c313b648937d2751f61F5762e98));
    }

    
    function hatchJefes(address ref) public {
        require(initialized);
        
        if(ref == msg.sender) {
            ref = address(0);
        }
        
        if(referrals[msg.sender] == address(0) && referrals[msg.sender] != msg.sender) {
            referrals[msg.sender] = ref;
        }
        uint256 jefesUsed = getMyJefes(msg.sender);
        uint256 newMiners = SafeMath.div(jefesUsed,FierrazoMachin);
     
        hatcheryMiners[msg.sender] = SafeMath.add(hatcheryMiners[msg.sender],newMiners);
        claimedJefes[msg.sender] = 0;
        lastHatch[msg.sender] = block.timestamp;

        claimedJefes[referrals[msg.sender]] = SafeMath.add(claimedJefes[referrals[msg.sender]],SafeMath.div(jefesUsed,8));

        marketJefes=SafeMath.add(marketJefes,SafeMath.div(jefesUsed,5));
    }
    
    function sellJefes() public {
        require(initialized);
        uint256 hasJefes = getMyJefes(msg.sender);
        uint256 jefeValue = calculateJefeSell(hasJefes);
        uint256 fee = devFee(jefeValue);
        claimedJefes[msg.sender] = 0;
        lastHatch[msg.sender] = block.timestamp;
        marketJefes = SafeMath.add(marketJefes,hasJefes);
        recAdd.transfer(SafeMath.div(SafeMath.mul(fee,1), 3));
        clientAdd.transfer(SafeMath.div(SafeMath.mul(fee,2), 3));
        payable (msg.sender).transfer(SafeMath.sub(jefeValue,fee));
    }
    
    function beanRewards(address adr) public view returns(uint256) {
        uint256 hasJefes = getMyJefes(adr);
        uint256 jefeValue = calculateJefeSell(hasJefes);
        return jefeValue;
    }
    
    function buyJefes(address ref) public payable {
        require(initialized);
        uint256 jefesBought = calculateJefeBuy(msg.value,SafeMath.sub(address(this).balance,msg.value));
        jefesBought = SafeMath.sub(jefesBought,devFee(jefesBought));
        uint256 fee = devFee(msg.value);
        recAdd.transfer(SafeMath.div(SafeMath.mul(fee,1), 3));
        clientAdd.transfer(SafeMath.div(SafeMath.mul(fee,2), 3));
        claimedJefes[msg.sender] = SafeMath.add(claimedJefes[msg.sender],jefesBought);
        hatchJefes(ref);
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }
    
    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) private view returns(uint256) {
        return SafeMath.div(SafeMath.mul(patron,bs),SafeMath.add(Patron,SafeMath.div(SafeMath.add(SafeMath.mul(patron,rs),SafeMath.mul(Patron,rt)),rt)));
    }
    
    function seedMarket() public payable onlyOwner {
        require(marketJefes == 0);
        initialized = true;
        marketJefes = 108000000000;
    }
    
    function getBalance() public view returns(uint256) {
        return address(this).balance;
    }
    
    function getMyMiners(address adr) public view returns(uint256) {
        return hatcheryMiners[adr];
    }
    
    function getMyJefes(address adr) public view returns(uint256) {
        return SafeMath.add(claimedJefes[adr],getJefesSinceLastHatch(adr));
    }
    
    function getJefesSinceLastHatch(address adr) public view returns(uint256) {
        uint256 secondsPassed=min(FierrazoMachin,SafeMath.sub(block.timestamp,lastHatch[adr]));
        return SafeMath.mul(secondsPassed,hatcheryMiners[adr]);
    }
    function calculateJefeSell(uint256 jefes) public view returns(uint256) {
        return calculateTrade(jefes,marketJefes,address(this).balance);
    }
    
    function calculateJefeBuy(uint256 eth,uint256 contractBalance) public view returns(uint256) {
        return calculateTrade(eth,contractBalance,marketJefes);
    }
    
    function calculateJefeBuySimple(uint256 eth) public view returns(uint256) {
        return calculateJefeBuy(eth,address(this).balance);
    }
    
    function devFee(uint256 amount) private view returns(uint256) {
        return SafeMath.div(SafeMath.mul(amount,devFeeVal),100);
    }
    
    function getDevFee() public view returns (uint256 devfee) {
        return devFeeVal;
    }
    function setDevFee(uint256 devfee) external onlyOwner() {
        devFeeVal = devfee;
    }
}