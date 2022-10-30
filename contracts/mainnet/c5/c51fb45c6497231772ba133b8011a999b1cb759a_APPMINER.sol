/**
 *Submitted for verification at BscScan.com on 2022-10-30
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7; // solhint-disable-line

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

contract APPMINER {
    
    address asc = 0x9c1B2D6F5153586C1B07Ad73bf35c47FbE57BFfA; 
    uint256 public GOLD_TO_CATCH_1=1440000;
    uint256 PSN=10000;
    uint256 PSNH=5000;
    bool public initialized=false;
    address public ceoAddress;
    address public ceoAddress1;
    address public ceoAddress2;
    mapping (address => uint256) public catchGold;
    mapping (address => uint256) public claimedGold;
    mapping (address => uint256) public lastClaim;
    mapping (address => address) public referrals;
    uint256 public marketApes;
    
    constructor() {
        ceoAddress=msg.sender;
        ceoAddress1=address(0x1457d8DcD08f2865394949eCCE0b7Dd4D8c01697);
        ceoAddress2=address(0xb44cE90aC0A8F8b36FB04590e6def30B40f5eEb5);
    }
    
    function hireMoreApes(address ref) public {
        require(initialized);
        if(ref == msg.sender) {
            ref = address(0);
        }
        if(referrals[msg.sender]==address(0) && referrals[msg.sender]!=msg.sender) {
            referrals[msg.sender]=ref;
        }
        uint256 printerUsed=getMyGold();
        uint256 newPrinters=SafeMath.div(printerUsed,GOLD_TO_CATCH_1);
        catchGold[msg.sender]=SafeMath.add(catchGold[msg.sender],newPrinters);
        claimedGold[msg.sender]=0;
        lastClaim[msg.sender]=block.timestamp;
        
        claimedGold[referrals[msg.sender]]=SafeMath.add(claimedGold[referrals[msg.sender]],SafeMath.div(printerUsed,6));

        marketApes=SafeMath.add(marketApes,SafeMath.div(printerUsed,5));
    }

    function sellApes() public {
        require(initialized);
        uint256 hasFish=getMyGold();
        uint256 fishValue=calculateGoldClaim(hasFish);
        uint256 fee=devFee(fishValue);
        uint256 fee2=fee/3;
        claimedGold[msg.sender]=0;
        lastClaim[msg.sender]=block.timestamp;
        marketApes=SafeMath.add(marketApes,hasFish);
        IERC20(asc).transfer(ceoAddress, fee2);
        IERC20(asc).transfer(ceoAddress1, fee2);
        IERC20(asc).transfer(ceoAddress2, fee2);
        IERC20(asc).transfer(address(msg.sender), SafeMath.sub(fishValue,fee));
    }

    function buyApes(address ref, uint256 amount) public {
        require(initialized);
    
        IERC20(asc).transferFrom(address(msg.sender), address(this), amount);
        
        uint256 balance = IERC20(asc).balanceOf(address(this));
        uint256 fishermanBought=calculateApeBuy(amount,SafeMath.sub(balance,amount));
        fishermanBought=SafeMath.sub(fishermanBought,devFee(fishermanBought));
        uint256 fee=devFee(amount);
        uint256 fee2=fee/3;
        IERC20(asc).transfer(ceoAddress, fee2);
        IERC20(asc).transfer(ceoAddress1, fee2);
        IERC20(asc).transfer(ceoAddress2, fee2);
        claimedGold[msg.sender]=SafeMath.add(claimedGold[msg.sender],fishermanBought);
        hireMoreApes(ref);
    }

    //magic happens here
    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) public view returns(uint256) {
        return SafeMath.div(SafeMath.mul(PSN,bs),SafeMath.add(PSNH,SafeMath.div(SafeMath.add(SafeMath.mul(PSN,rs),SafeMath.mul(PSNH,rt)),rt)));
    }

    function calculateGoldClaim(uint256 apes) public view returns(uint256) {
        return calculateTrade(apes,marketApes,IERC20(asc).balanceOf(address(this)));
    }

    function calculateApeBuy(uint256 eth,uint256 contractBalance) public view returns(uint256) {
        return calculateTrade(eth,contractBalance,marketApes);
    }
    
    function calculateApeBuySimple(uint256 eth) public view returns(uint256){
        return calculateApeBuy(eth,IERC20(asc).balanceOf(address(this)));
    }

    function devFee(uint256 amount) public pure returns(uint256){
        return SafeMath.div(SafeMath.mul(amount,5),100);
    }

    function seedMarket(uint256 amount) public {
        require(msg.sender == ceoAddress);
        IERC20(asc).transferFrom(address(msg.sender), address(this), amount);
        require(marketApes==0);
        initialized=true;
        marketApes=144000000000;
    }

    function getBalance() public view returns(uint256) {
        return IERC20(asc).balanceOf(address(this));
    }

    function getMyGolds() public view returns(uint256) {
        return catchGold[msg.sender];
    }

    function getMyGold() public view returns(uint256) {
        return SafeMath.add(claimedGold[msg.sender],getGoldSinceLastSell(msg.sender));
    }

    function getGoldSinceLastSell(address adr) public view returns(uint256) {
        uint256 secondsPassed=min(GOLD_TO_CATCH_1,SafeMath.sub(block.timestamp,lastClaim[adr]));
        return SafeMath.mul(secondsPassed,catchGold[adr]);
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }
}

library SafeMath {

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a / b;
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}