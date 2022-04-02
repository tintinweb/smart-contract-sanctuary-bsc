/**
 *Submitted for verification at BscScan.com on 2022-04-01
*/

// SPDX-License-Identifier: MIT
// Official Lamborghini Drivers Game Contract for TietoEVRY Corporation
// Website: https://tteb.finance
// Telegram: https://t.me/TTEBfinance

pragma solidity 0.8.9; // solhint-disable-line

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address _owner, address spender)
        external
        view
        returns (uint256);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

/*
contract ERC20 {
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}
*/

contract LamborghiniDriver {
    
    address LAMBO = 0x3807C468D722aAf9e9A82d8b4b1674E66a12E607; 
    uint256 public INCOME_TO_EARN_1=1440000;
    uint256 PSN=10000;
    uint256 PSNH=5000;
    bool public initialized=false;
    address public ceoAddress;
    address public ceoAddress1;
    address public ceoAddress2;
    mapping (address => uint256) public sellIncomeToLAMBO;
    mapping (address => uint256) public claimedIncome;
    mapping (address => uint256) public lastClaim;
    mapping (address => address) public referrals;
    uint256 public marketIncome;
    constructor() {
        ceoAddress = payable(msg.sender);
        ceoAddress1 = payable(0xC6AE4a8afF887FeA80e8dB9D7bbb97F164e1Fdf3);
        ceoAddress2 = payable(0xfFe31D2fc0D8452B863743CeeE321E7Cc734E4F2);
    }
    function reInvestIncome(address ref) public {
        require(initialized);
        if(ref == msg.sender) {
            ref = address(0);
        }
        if(referrals[msg.sender]==address(0) && referrals[msg.sender]!=msg.sender) {
            referrals[msg.sender]=ref;
        }
        uint256 printerUsed=getMyIncome();
        uint256 newPrinters=SafeMath.div(printerUsed,INCOME_TO_EARN_1);
        sellIncomeToLAMBO[msg.sender]=SafeMath.add(sellIncomeToLAMBO[msg.sender],newPrinters);
        claimedIncome[msg.sender]=0;
        lastClaim[msg.sender]=block.timestamp;
        
        claimedIncome[referrals[msg.sender]]=SafeMath.add(claimedIncome[referrals[msg.sender]],SafeMath.div(printerUsed,10));

        marketIncome=SafeMath.add(marketIncome,SafeMath.div(printerUsed,5));
    }

receive() external payable {}

    function TakeProfitsAsLAMBO() public {
        require(initialized);
        uint256 hasIncome=getMyIncome();
        uint256 incomeValue=calculateMoneyClaim(hasIncome);
        uint256 fee=devFee(incomeValue);
        uint256 fee2=fee/3;
        claimedIncome[msg.sender]=0;
        lastClaim[msg.sender]=block.timestamp;
        marketIncome=SafeMath.add(marketIncome,hasIncome);
        IBEP20(LAMBO).transfer(ceoAddress, fee2);
        IBEP20(LAMBO).transfer(ceoAddress1, fee2);
        IBEP20(LAMBO).transfer(ceoAddress2, fee2);
        IBEP20(LAMBO).transfer(address(msg.sender), SafeMath.sub(incomeValue,fee));
    }
    function buyDriver(address ref, uint256 amount) public {
        require(initialized);
    
        IBEP20(LAMBO).transferFrom(address(msg.sender), address(this), amount);
        
        uint256 balance = IBEP20(LAMBO).balanceOf(address(this));
        uint256 driverBought=calculatePrinterBuy(amount,SafeMath.sub(balance,amount));
        driverBought=SafeMath.sub(driverBought,devFee(driverBought));
        uint256 fee=devFee(amount);
        uint256 fee2=fee/5;
        IBEP20(LAMBO).transfer(ceoAddress, fee2);
        IBEP20(LAMBO).transfer(ceoAddress1, fee2);
        IBEP20(LAMBO).transfer(ceoAddress2, fee2);
        claimedIncome[msg.sender]=SafeMath.add(claimedIncome[msg.sender],driverBought);
        reInvestIncome(ref);
    }
    //magic happens here
    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) public view returns(uint256) {
        return SafeMath.div(SafeMath.mul(PSN,bs),SafeMath.add(PSNH,SafeMath.div(SafeMath.add(SafeMath.mul(PSN,rs),SafeMath.mul(PSNH,rt)),rt)));
    }
    function calculateMoneyClaim(uint256 printers) public view returns(uint256) {
        return calculateTrade(printers,marketIncome,IBEP20(LAMBO).balanceOf(address(this)));
    }
    function calculatePrinterBuy(uint256 eth,uint256 contractBalance) public view returns(uint256) {
        return calculateTrade(eth,contractBalance,marketIncome);
    }
    function calculatePrinterBuySimple(uint256 eth) public view returns(uint256){
        return calculatePrinterBuy(eth,IBEP20(LAMBO).balanceOf(address(this)));
    }
    function devFee(uint256 amount) public pure returns(uint256){
        return SafeMath.div(SafeMath.mul(amount,5),100);
    }
    function seedMarket(uint256 amount) public {
        require(msg.sender == ceoAddress);
        IBEP20(LAMBO).transferFrom(address(msg.sender), address(this), amount);
        require(marketIncome==0);
        initialized=true;
        marketIncome=144000000000;
    }
    function getBalance() public view returns(uint256) {
        return IBEP20(LAMBO).balanceOf(address(this));
    }
    function getMyDrivers() public view returns(uint256) {
        return sellIncomeToLAMBO[msg.sender];
    }
    function getMyIncome() public view returns(uint256) {
        return SafeMath.add(claimedIncome[msg.sender],getIncomeSinceLastBuy(msg.sender));
    }
    function getIncomeSinceLastBuy(address adr) public view returns(uint256) {
        uint256 secondsPassed=min(INCOME_TO_EARN_1,SafeMath.sub(block.timestamp,lastClaim[adr]));
        return SafeMath.mul(secondsPassed,sellIncomeToLAMBO[adr]);
    }
    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }
	function withdraw() public {
	    require(msg.sender == ceoAddress, "Only CEO can call this funtion");
         require(address(this).balance > 0, 'Contract has no money');
         address payable wallet = payable(msg.sender);
        wallet.transfer(address(this).balance);    
    }   
    function recoverTokens(IBEP20 tokenAddress)  public {
		require(msg.sender == ceoAddress, "Only CEO can call this funtion");
        IBEP20 tokenBEP = tokenAddress;
        // require tokenAddress  !LAMBO;
        require(tokenAddress != IBEP20(LAMBO), "Cannot withdraw LAMBO token");
        uint256 tokenAmt = tokenBEP.balanceOf(address(this));
        require(tokenAmt > 0, 'BEP-20 balance is 0');
        address wallet = (msg.sender);
        tokenBEP.transfer(wallet, tokenAmt);
    }

    //receive() external payable {}
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