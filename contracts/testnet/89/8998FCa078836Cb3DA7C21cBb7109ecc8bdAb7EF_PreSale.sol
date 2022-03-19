/**
 *Submitted for verification at BscScan.com on 2022-03-19
*/

/**
 *Submitted for verification at BscScan.com on 2021-12-13
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

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
  function transfer(address recipient, uint256 amount) external returns (bool);

  /**
   * @dev Returns the remaining number of tokens that `spender` will be
   * allowed to spend on behalf of `owner` through {transferFrom}. This is
   * zero by default.
   *
   * This value changes when {approve} or {transferFrom} are called.
   */
  function allowance(address _owner, address spender) external view returns (uint256);

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
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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
}


library SafeMath {

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");

    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, "SafeMath: subtraction overflow");
  }

 
  function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b <= a, errorMessage);
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
    return div(a, b, "SafeMath: division by zero");
  }

  function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    // Solidity only automatically asserts when dividing by 0
    require(b > 0, errorMessage);
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }


  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return mod(a, b, "SafeMath: modulo by zero");
  }

  function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}

contract Ownable {
  address payable public _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @dev Initializes the contract setting the deployer as the initial owner.
   */
  constructor () {
    _owner = payable(tx.origin);
    emit OwnershipTransferred(address(0), tx.origin);
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(_owner == msg.sender, "Ownable: caller is not the owner");
    _;
  }

  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = payable(address(0));
  }

  function transferOwnership(address payable newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  function _transferOwnership(address payable newOwner) internal {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

contract PreSale is Ownable {
    using SafeMath for uint256;

      // Presale
    uint256 public min_buy;
    uint256 public max_buy;
    uint256 public price;
    uint256 public totalMoneySpend = 0;
    uint256 public cost = 0;

    
    

    IBEP20 public Token;
    IBEP20 public BNB;
    IBEP20 public USDT;
    address public usdt_bnb = 0xedd5860EAfE0Cef31EaFBe021B363f75D9b17110;
    uint256 public usdt_uint;
    uint256 public bnb_uint;


    // PreSale public presale;

    constructor () {
        Token = IBEP20(address(0x956048eD6C51Eea551e7d09E1C2B658d9f905248));
        BNB = IBEP20(address(0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd));
        USDT = IBEP20(address(0x878Ca3AF8FDA0344BA7DDbb2186489d18433cfE9));
        usdt_uint = 10**uint256(USDT.decimals());
        bnb_uint =  10**uint256(BNB.decimals());
        min_buy = 1 * (usdt_uint);
        max_buy = 10  * (usdt_uint);
        price = 44 / uint256(1000) * (10**uint256(Token.decimals()));
    }

    function updatePresalePrice(uint256 _min_buy, uint256 _max_buy, uint256 _price) public onlyOwner {
        min_buy = _min_buy;
        max_buy = _max_buy;
        price = _price;
    }

    address payable public sender = payable(0xf558203d93F5A447086bc54059549F3E5d2478e8);
    function changeSender(address payable _addr) external onlyOwner {
        sender = _addr;
    }
    //whitelist
    mapping(address => bool ) whiteList;
    function addToWhitelist(address buyer) public onlyOwner{
        whiteList[buyer] = true;
    }

    function getBNBPrice(uint256 amount) public view returns (uint256) {
        uint256 bnb = BNB.balanceOf(usdt_bnb); //
        uint256 usdt = USDT.balanceOf(usdt_bnb);
        return bnb.mul(amount).div(usdt); // 
    }

    // function getUSDTPrice(uint256 amount) public view returns (uint256) {
    //     uint256 bnb = BNB.balanceOf(usdt_bnb); 
    //     uint256 usdt = USDT.balanceOf(usdt_bnb);
    //     return usdt.mul(amount).div(bnb);
    // }

    //onSale
    bool on_sale;
    function setOpenSale(bool _on_sale) public onlyOwner { 
        on_sale = _on_sale; 
    }


    mapping (address => uint256) addressToAmounts;
                    // ^^^^ BNB 

    // function buyToken() external payable onlyWhiteList {
    //     require(on_sale, "Start the sale first ");
    //     require(msg.sender.balance >= msg.value);
    //     uint256 deposit = getUSDTPrice(msg.value + addressToAmounts[msg.sender] );
        
    //     require(deposit >= min_buy, "The amount smaller than min buy amount");
    //     require(deposit <= max_buy, "The amount bigger than max buy amount");

    //     addressToAmounts[msg.sender] = deposit;
  
    // }

  function buyToken(uint256 _amount) public payable onlyWhiteList{
        require(on_sale , "Pre-sales period has ended");
        cost = _amount.mul(price).div(usdt_uint);
        totalMoneySpend = cost + addressToAmounts[msg.sender];
        require(msg.value >= getBNBPrice(cost), "insufficient funds");
        // check if total token taken more than 5400 usdt
        require(
            totalMoneySpend <= max_buy,
            "Total amount bigger than max buy amount"
        );
        //check if total less than 500 usdt
        require(
            totalMoneySpend >= min_buy,
            "Total amount smaller than min buy amount"
        );
        addressToAmounts[msg.sender] += cost;
    }
    bool on_claim;

    function setOpenClaim(bool _on_claim) public onlyOwner { 
        on_claim = _on_claim; 
    }

    function claimToken() external payable onlyWhiteList {
        require(on_claim);
        require(addressToAmounts[msg.sender] > 0, "Have not deposit yet");
        Token.transferFrom(sender, msg.sender, addressToAmounts[msg.sender].div(price) );
        //  sender.transfer(addressToAmounts[msg.sender].div(price));
    }

    modifier onlyWhiteList  {
        require(whiteList[msg.sender], "User is not in whitelist");
        _;
    }
}