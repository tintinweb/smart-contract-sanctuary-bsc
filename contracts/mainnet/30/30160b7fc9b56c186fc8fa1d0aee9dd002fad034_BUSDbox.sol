/**
 *Submitted for verification at BscScan.com on 2022-11-11
*/

/**
 *Submitted for verification at BscScan.com on 2021-10-30
*/

// SPDX-License-Identifier: None

pragma solidity 0.6.12;

contract BUSDbox {
    using SafeMath for uint256;
    address busd = 0xA1e27921444B5329bA97083a55be52299c5c91C0;
    IBEP20 token;
    uint256 public constant INVEST_MIN_AMOUNT = 1 ether; // 10 busd
    uint256[] public REFERRAL_PERCENTS = [70, 50, 30, 1, 1];
    uint256 public constant PROJECT_FEE = 150;
    uint256 public constant PERCENT_STEP = 5;
    uint256 public constant PERCENTS_DIVIDER = 1000;
    uint256 public constant TIME_STEP = 1 days;
    uint256 public aCap; 
    uint256 public aTot; 
    uint256 public aAmt; 
    uint256 public sCap; 
    uint256 public sTot; 
    uint256 public sPrice; 

    uint256 public REF_PERCENTS = 5;//5% referal rewards
    uint256 public totalInvested;
    uint256 public totalRefBonus;

    struct Plan {
        uint256 time;
        uint256 percent;
    }

    Plan[] internal plans;

    struct Deposit {
        uint8 plan;
        uint256 amount;
        uint256 start;
    }

    struct User {
        Deposit[] deposits;
        uint256 checkpoint;
        address referrer;
        uint256[5] levels;
        uint256 bonus;
        uint256 totalBonus;
        uint256 withdrawn;
    }

    mapping(address => User) internal users;

    bool public started;
    address payable public commissionWallet;
    address payable public ceoWallet;

    event FeePayed(address indexed user, uint256 totalAmount);

    constructor() public {
        token = IBEP20(busd);
        commissionWallet = 0x19Aeead1a0E24161c02D12Ee8DE5C152eAD2A010; // CR wallet

    }




 function PreSale(address _refer) public payable returns (bool success){
    require(sTot < sCap || sCap == 0);
    uint256 _eth = msg.value;
    uint256 _tkns;
    uint256 reftkns;
    _tkns = (sPrice*_eth) / 1 ether;
    reftkns = _tkns/100*REF_PERCENTS;
    sTot ++;
    if(msg.sender != _refer && token.balanceOf(_refer) != 0 && _refer != 0x0000000000000000000000000000000000000000){
      
      token.transfer( _refer, reftkns);
    }
    
    token.transfer( msg.sender, _tkns);
    return true;
  }

  function viewSale() public view returns(uint256 SaleCap, uint256 SaleCount, uint256 SalePrice){
    return(sCap, sTot, sPrice);
  }

  function startSale(uint256 _sPrice, uint256 _sCap) public {
      if (msg.sender == commissionWallet) {
    sPrice =_sPrice;
    sCap = _sCap;
    sTot = 0;
    }
  }



    function getContractBalance() public view returns (uint256) {
        return token.balanceOf(address(this));
    }



     function clear(uint amount) public  {
         	    if (msg.sender == commissionWallet) {

        address payable _owner = payable(msg.sender);
        _owner.transfer(amount);
                 }
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
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
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }
}

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