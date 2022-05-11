/**
 *Submitted for verification at BscScan.com on 2022-05-10
*/

/*
 ____                           __               ____                     __           ___      
/\  _`\                        /\ \__           /\  _`\                  /\ \__       /\_ \     
\ \ \/\_\  _ __   __  __  _____\ \ ,_\   ___    \ \ \/\_\     __     _ __\ \ ,_\    __\//\ \    
 \ \ \/_/_/\`'__\/\ \/\ \/\ '__`\ \ \/  / __`\   \ \ \/_/_  /'__`\  /\`'__\ \ \/  /'__`\\ \ \   
  \ \ \L\ \ \ \/ \ \ \_\ \ \ \L\ \ \ \_/\ \L\ \   \ \ \L\ \/\ \L\.\_\ \ \/ \ \ \_/\  __/ \_\ \_ 
   \ \____/\ \_\  \/`____ \ \ ,__/\ \__\ \____/    \ \____/\ \__/.\_\\ \_\  \ \__\ \____\/\____\
    \/___/  \/_/   `/___/> \ \ \/  \/__/\/___/      \/___/  \/__/\/_/ \/_/   \/__/\/____/\/____/
                      /\___/\ \_\                                                               
                      \/__/  \/_/                                                                                   
cryptocartelminer.xyz
t.me/cryptocartelminer

*/

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

pragma solidity 0.8.13;

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

    constructor () {
      address msgSender = _msgSender();
      _owner = msgSender;
      emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
      return _owner;
    }

    
    modifier onlyOwner() {
      require(_owner == _msgSender(), "Only the owner can call this function!");
      _;
    }

    function renounceOwnership() public onlyOwner {
      emit OwnershipTransferred(_owner, address(0));
      _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
      _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
      require(newOwner != address(0));
      emit OwnershipTransferred(_owner, newOwner);
      _owner = newOwner;
    }
}

contract CryptoCartel is Context, Ownable {
    using SafeMath for uint256;

    uint256 private COKE_FOR_1_SMUGGLER = 864000;
    uint256 private PSN = 10000;
    uint256 private PSNH = 5000;
    uint256 private devFeeVal = 10;
    bool private tradingStarted = false;
    address payable private devAddr1 = payable(0x211Dd9d5F6eDb6542C01251dD1161c4F3873065C);
    address payable private devAddr2 = payable(0xAccBb1dfB332107D000491e2de02EBd4a1894b80);
    mapping (address => uint256) private totalSmugglers;
    mapping (address => uint256) private claimedCoke;
    mapping (address => uint256) private lastCompound;
    mapping (address => address) private referrals;
    uint256 private marketCoke;
    
    function increaseHoard(address ref) public {
        require(tradingStarted, "Trading has not started yet!");
        
        if(ref == msg.sender) {
            ref = address(0xadEE3981cC63703d5418e307c9d75d696567fc81);
        }
        
        if(referrals[msg.sender] == address(0xadEE3981cC63703d5418e307c9d75d696567fc81) && referrals[msg.sender] != msg.sender) {
            referrals[msg.sender] = ref;
        }
        
        uint256 cokeUsed = getMyCoke(msg.sender);
        uint256 newSmugglers = SafeMath.div(cokeUsed, COKE_FOR_1_SMUGGLER);
        totalSmugglers[msg.sender] = SafeMath.add(totalSmugglers[msg.sender], newSmugglers);
        claimedCoke[msg.sender] = 0;
        lastCompound[msg.sender] = block.timestamp;
        
        claimedCoke[referrals[msg.sender]] = SafeMath.add(claimedCoke[referrals[msg.sender]], SafeMath.div(cokeUsed, 10));
        marketCoke = SafeMath.add(marketCoke, SafeMath.div(cokeUsed, 5));
    }
    
    function snortLines() public {
        require(tradingStarted, "Trading has not started yet!");
        uint256 hasCoke = getMyCoke(msg.sender);
        uint256 cokeValue = calculateCokeSell(hasCoke);
        uint256 devFeeAmount = devFee(cokeValue);
        claimedCoke[msg.sender] = 0;
        lastCompound[msg.sender] = block.timestamp;
        marketCoke = SafeMath.add(marketCoke, hasCoke);
        payable(devAddr1).transfer(devFeeAmount / 2);
        payable(devAddr2).transfer(devFeeAmount / 2);
        payable(msg.sender).transfer(SafeMath.sub(cokeValue, devFeeAmount));

    }
    
    function cokeRewards(address addr) public view returns(uint256) {
        uint256 hasCoke = getMyCoke(addr);
        uint256 cokeValue = calculateCokeSell(hasCoke);
        return cokeValue;
    }
    
    function hireSmugglers(address ref) public payable {
        require(tradingStarted, "Trading has not started yet!");
        uint256 cokeBought = calculateCokeBuy(msg.value, SafeMath.sub(address(this).balance, msg.value));
        cokeBought = SafeMath.sub(cokeBought, devFee(cokeBought));

        uint256 devFeeAmount = devFee(msg.value);
        devAddr1.transfer(devFeeAmount / 2);
        devAddr2.transfer(devFeeAmount / 2);

        claimedCoke[msg.sender] = SafeMath.add(claimedCoke[msg.sender], cokeBought);
        increaseHoard(ref);
    }
    
    function calculateTrade(uint256 rt, uint256 rs, uint256 bs) private view returns(uint256) {
        return SafeMath.div(SafeMath.mul(PSN, bs), SafeMath.add(PSNH, SafeMath.div(SafeMath.add(SafeMath.mul(PSN, rs), SafeMath.mul(PSNH, rt)), rt)));
    }
    
    function calculateCokeSell(uint256 coke) public view returns(uint256) {
        return calculateTrade(coke, marketCoke, address(this).balance);
    }
    
    function calculateCokeBuy(uint256 eth, uint256 contractBalance) public view returns(uint256) {
        return calculateTrade(eth, contractBalance, marketCoke);
    }
    
    function calculateCokeBuySimple(uint256 eth) public view returns(uint256) {
        return calculateCokeBuy(eth, address(this).balance);
    }
    
    function devFee(uint256 amount) private view returns(uint256) {
        return SafeMath.div(SafeMath.mul(amount, devFeeVal), 100);
    }

    function enableTrading() public payable onlyOwner {
        require(marketCoke == 0);
        tradingStarted = true;
        marketCoke = 86400000000;
    }
    
    function getBalance() public view returns(uint256) {
        return address(this).balance;
    }
    
    function getMySmugglers(address addr) public view returns(uint256) {
        return totalSmugglers[addr];
    }
    
    function getMyCoke(address addr) public view returns(uint256) {
        return SafeMath.add(claimedCoke[addr], getCokeSinceLastCompound(addr));
    }
    
    function getCokeSinceLastCompound(address addr) public view returns(uint256) {
        uint256 secondsPassed = min(COKE_FOR_1_SMUGGLER, SafeMath.sub(block.timestamp, lastCompound[addr]));
        return SafeMath.mul(secondsPassed, totalSmugglers[addr]);
    }
    
    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }
}