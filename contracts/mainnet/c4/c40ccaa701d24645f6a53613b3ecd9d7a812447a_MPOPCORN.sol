/**
 *Submitted for verification at BscScan.com on 2022-07-03
*/

// SPDX-License-Identifier: MIT

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

interface ERC20 {
    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

contract MPOPCORN is Context, Ownable {

    using SafeMath for uint256;
    //mainnet
    address popcorn =  0x705c31BaB80ADbb90400c802c6E313D51C6B025A;
    
    address public devAddress;
    uint256 private Corn_TO_HATCH_1MINERS = 7854545;
    uint256 private PSN = 10000;
    uint256 private PSNH = 5000;
    uint256 private devFeeVal = 0;
    bool private initialized = false;
    mapping (address => uint256) private hatcheryMiners;
    mapping (address => uint256) private claimedCorn;
    mapping (address => uint256) private lastHatch;
    mapping (address => address) private referrals;
    uint256 private marketCorn;
    
    constructor() {
        devAddress = msg.sender;
    }
    
    function hatchCorn(address ref) public {
        require(initialized);
        
        if(ref == msg.sender) {
            ref = address(0);
        }
        
        if(referrals[msg.sender] == address(0) && referrals[msg.sender] != msg.sender) {
            referrals[msg.sender] = ref;
        }
        
        uint256 cornUsed = getMyCorn(msg.sender);
        uint256 newMiners = SafeMath.div(cornUsed,Corn_TO_HATCH_1MINERS);
        hatcheryMiners[msg.sender] = SafeMath.add(hatcheryMiners[msg.sender],newMiners);
        claimedCorn[msg.sender] = 0;
        lastHatch[msg.sender] = block.timestamp;
        
        //send referral corn
        claimedCorn[referrals[msg.sender]] = SafeMath.add(claimedCorn[referrals[msg.sender]], SafeMath.div(SafeMath.mul(cornUsed,13),100));
        
        //boost market to nerf miners hoarding
        marketCorn = SafeMath.add(marketCorn,SafeMath.div(cornUsed,5));
    }
    
    function sellCorn() public {
        require(initialized);
        uint256 hasCorn = getMyCorn(msg.sender);
        uint256 cornValue = calculateCornSell(hasCorn);
        uint256 fee = devFee(cornValue);
        claimedCorn[msg.sender] = 0;
        lastHatch[msg.sender] = block.timestamp;
        marketCorn = SafeMath.add(marketCorn,hasCorn);
        ERC20(popcorn).transfer(devAddress, fee);
        ERC20(popcorn).transfer(address(msg.sender), SafeMath.sub(cornValue,fee));
    }
    
    function MPOPCORNRewards(address adr) public view returns(uint256) {
        uint256 hasCorn = getMyCorn(adr);
        uint256 CornValue = calculateCornSell(hasCorn);
        return CornValue;
    }
    
    function buyCorn(address ref, uint256 amount) public {
        require(initialized);

        ERC20(popcorn).transferFrom(address(msg.sender), address(this), amount);
        uint256 balance = ERC20(popcorn).balanceOf(address(this));
        uint256 cornBought = calculateCornBuy(amount,SafeMath.sub(balance,amount));
        cornBought = SafeMath.sub(cornBought,devFee(cornBought));
        uint256 fee = devFee(amount);
        ERC20(popcorn).transfer(devAddress, fee);
        claimedCorn[msg.sender] = SafeMath.add(claimedCorn[msg.sender],cornBought);
        hatchCorn(ref);
    }
    
    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) private view returns(uint256) {
        return SafeMath.div(SafeMath.mul(PSN,bs),SafeMath.add(PSNH,SafeMath.div(SafeMath.add(SafeMath.mul(PSN,rs),SafeMath.mul(PSNH,rt)),rt)));
    }
    
    function calculateCornSell(uint256 corn) public view returns(uint256) {
        return calculateTrade(corn,marketCorn,ERC20(popcorn).balanceOf(address(this)));
    }
    
    function calculateCornBuy(uint256 eth,uint256 contractBalance) public view returns(uint256) {
        return calculateTrade(eth,contractBalance,marketCorn);
    }
    
    function calculateCornBuySimple(uint256 eth) public view returns(uint256){
        return calculateCornBuy(eth,ERC20(popcorn).balanceOf(address(this)));
    }
    
    function devFee(uint256 amount) private view returns(uint256) {
        return SafeMath.div(SafeMath.mul(amount,devFeeVal),100);
    }
    
    function seedMarket(uint256 amount) public {
        ERC20(popcorn).transferFrom(address(msg.sender), address(this), amount);
        require(marketCorn==0);
        initialized=true;
        marketCorn = 78545454545;
    }
    
    function getBalance() public view returns(uint256) {
        return ERC20(popcorn).balanceOf(address(this));
    }
    
    function getMyMiners(address adr) public view returns(uint256) {
        return hatcheryMiners[adr];
    }
    
    function getMyCorn(address adr) public view returns(uint256) {
        return SafeMath.add(claimedCorn[adr],getCornSinceLastHatch(adr));
    }
    
    function getCornSinceLastHatch(address adr) public view returns(uint256) {
        uint256 secondsPassed=min(Corn_TO_HATCH_1MINERS,SafeMath.sub(block.timestamp,lastHatch[adr]));
        return SafeMath.mul(secondsPassed,hatcheryMiners[adr]);
    }
    
    function setMpopcornInCan(uint256 _MPOPCORN) public onlyOwner {
        Corn_TO_HATCH_1MINERS = _MPOPCORN;
    }
    
    function setDevFee(uint256 fee) public onlyOwner {
        devFeeVal = fee; 
    }
    
    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }
}