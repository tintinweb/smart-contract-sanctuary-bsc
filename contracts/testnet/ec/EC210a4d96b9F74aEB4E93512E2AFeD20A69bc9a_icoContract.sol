/**
 *Submitted for verification at BscScan.com on 2022-07-30
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

contract ReEntrancyGuard {
    bool internal locked;

    modifier noReentrant() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
    }
}

contract icoContract is ReEntrancyGuard{

    uint256 public RATE = 700000000; // Number of tokens per Ether
    uint256 public minBuy = 700000; // minimum buy amount
    uint256 public maxBuy = 1750000; // maximum buy amount

    uint256 public START = 1659209651;
    
    uint256 public END = 1660073651; 
  
    uint256 public initialTokens = 35000000000; // Initial number of tokens available

    mapping(address => uint256) public remainingbuytokens;
    mapping (address => bool) public _isWhitelisted; // allows whitelisted address to buy
    mapping (address => bool) public _hasBought; // checks if address has bought



    address public _link = 0x5Ad034E22Fd2425d4aE4cfD4a47E8C826088B694;  // address of ico coin
    IERC20 token = IERC20(_link);
    //declaring owner state variable
    address public owner;

    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 _value
    );

    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );

    constructor() public {
        owner = msg.sender;
    }

    function whitelistWallet(address account) public {
        require(msg.sender == owner, "only owner may whitelist");
        if(_isWhitelisted[account] == true) return;
        _isWhitelisted[account] = true;
    }

    function BlacklistWallet(address account) external {
        require(msg.sender == owner, "only owner may blacklist/unblacklist");
         if(_isWhitelisted[account] == false) return;
        _isWhitelisted[account] = false;
    }

    function buyTokens() external payable {
    if(_hasBought[msg.sender] == false)
    {
        remainingbuytokens[msg.sender] = maxBuy;
    }
    
    require(msg.value > 0, "ETH sent must be more than 0");
    require(block.timestamp > START, "Presale not started yet!");
    require(block.timestamp < END, "Presale Ended!");
    require(initialTokens > 0, "Presale Sold Out!");
    require(_isWhitelisted[msg.sender] == true, "Caller must be whitelisted for buying");

    
    uint256 weiAmount = msg.value; // Calculate tokens to sell
    uint256 tokens = weiAmount * RATE / 1000000000000000000;
    
    require(tokens <= maxBuy,"Max buy exceeded");
    require(tokens >= minBuy,"Minimum Amount not met for buy");
    
    remainingbuytokens[msg.sender] = remainingbuytokens[msg.sender] - tokens;
    
    require(remainingbuytokens[msg.sender] > tokens,"Remaining Buy Limit not enough to buy this amount of Tokens.");
    
    initialTokens = initialTokens - tokens;
    
    tokens = tokens * 10 ** 18;
    token.transfer(msg.sender, tokens); // Send tokens to buyer
  }

    function ethbalance() external view returns (uint256){
        require(msg.sender == owner, "Only Owner may call!");
        return address(this).balance;
    }

    function erc20balance() external view returns (uint256){
        uint256 balance = token.balanceOf(address(this)) / 1000000000000000000 ;
        return balance;
    }

    function recovertokenBalance()  external {
        require(msg.sender == owner, "Only Owner may call!");
        token.transfer(owner,token.balanceOf(address(this)));
    }

    function recoverETH() noReentrant external
    {
        require(msg.sender == owner, "Only Owner may call!");
        address payable recipient = payable(msg.sender);
        if(address(this).balance > 0)
            recipient.transfer(address(this).balance);
    }

}