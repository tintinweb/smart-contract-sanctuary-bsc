/**
 *Submitted for verification at BscScan.com on 2022-08-14
*/

/**
Token:    Futurex (FUX)
Website:  https://fux.money

                                                                                                    
                                         ......:::::::......                                        
                                 ...:::^^^^^^~~~~~~^^^~~~~~~~^^^::..                                
                             ..:^^^^^^^^^^^^::.............:::^^^~~~~^^:.                           
                           .:^^^^^^^:::..::::^^^^^^^^^^^^^::::::::::^^~~^^:..                       
                        .:^^^^^^^::::^^^^^^^^^::::::^^^::::^^^^^^^::....:^^^:...                    
                    ..:^^^^^^^^^^^^^^^^^^::...................::::^^^^:....^^^^::..                 
                  .:^^^^^^^^^^^^^^^^^::..             .....:::::...::^^^::..:^^^^^:::.              
               .:^^^^^^^^^^^^^^^::::..                         ..:::...:^^^:::^^^^^^^^^:            
              .^^^^^^^^^^^^^:..::.                                  .:::..:^^^::^^^^^^^~^.          
             :^^^^^^^^^^^^.  ..                                         .::..:^^^^^^^^...::.        
           .^^^^^^^^^^^^..                                                 .:..:^^^^^^^.   ..       
           .^^^^^^^^^^:..                                                    .:..:^^^^:^:   ...     
        . .^^^^^^^^^^...                                                       ....^^^^::^.  ...    
       . .^^^^^^^^^^:.                                                           ...:^^^::^.  ..    
      . .^^^^^^^^^^^.                                                              . :^^^^...  ..   
     ...^^^^^^^^^^:                                                                   :^^^^. .  ..  
    .. ^^^^^^^^^^:                                                                     :^^^^. .     
    : :^^^^::^^^:                                                                       ^^^^~...    
   ...~^^^^.^^^^       ^^^~~~~~~~~~~~~~!7 .~^7^         :~^?. .^~^.         :^~?J.      .^^:^^ .    
   : ^^^^^:.^^^.       ^^~Y^:^^^^^^^^^^^: .~^?~         :^^Y:   .^~^.     .^^7Y!         :^^:~. .   
  ...^^^^^.:^^^        ^^~Y               .~^?~         :^^Y:     .^~^. .^^!Y7.           ^^:^^     
  . :^^^^^.^^^:        ^^~7. ..........   .~^?~         :^^Y:       :^~^^~JJ.             :^^:^     
  . :^^^^^.^^^.        ^^^~!!!!!!!!!!!!?! .~^?~         :^^Y:        ^^^^7~               .^^:^.    
  : :^^^^^ ^^^.        ^^~Y:::::::::::::. .~^7~         :^^Y.      :^^?7^^^.              .^^:^.    
  :.:^^^^^.:^^.        ^^~Y                :~~!        .^^7Y     .^^!Y7  .^~^.            .~^:^.    
  ...~^^^^:.^^:        ^^~Y                 .^~^.....:^^~JJ.   .^^!Y?.     :~~:           .^^:^.    
  .^.^^^^^^ :~^        :!7Y                   :~!!!!!7??7:    :!!?J:         ^!!^         ::::^.    
   ^:.^^^^^:.^^.        ...                      ..::..        ...            ....        ^:::^     
   .~::^^^^^::^^                                                                         .^::^:     
    ^~^^^^^^^::~:                                                                      . :.::^      
     ^^^^^^^^^::~.                                                                      .:.:^.      
     .^^^^^^^^^::^:                                                                   . ...^:       
      .^^^^^^^^^^^^:                                                                 .  ..:^        
       .^^^^^^^^^^::^:                                                       .      .    ::         
         :~^^^^^^^^^:^^.                                                    .:                      
          .^^^^^^^^^^^:^^:                                                  ::                      
            :^^^^^^^^^^^::^:.                                          .::   .                      
              :^^^^^^^^^^^^^^^:..                                  ..:^~^.                          
                :^~^^^^^^^^^^^^^^^^:..                    ..::::^^^~~^^^^^..                        
                  .^^^^^^^^^^^^^^^^^~~^^^^::::::::::::^^^^~~~~~^^^^^^^^^^^.                         
                    .:^~^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^:...                         
                       .:^~^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^~^...                          
                          .:^^~^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^~~^^:..                             
                              .::^^^~~~^^^^^^^^^^^^^^^^^~~~~^^^:..                                  
                                    ...:::^^^^^^^^^^^::::...                                        


ALL FUTURES, ONE SMART TOKEN

INVEST IN VIRTUAL FUTURES
ASSET-BALANCED TOKEN
REAL MARKETS UNDERLYING ASSETS
LONG - SHORT STRATEGIES AVAILABLE
LEVERAGE UP TO 10X AVAILABLE
AI MANAGED LIVE WALLET BALANCE

Futurex(FUX) is a BEP20 Smart Token on the BSC blockchain, managed by our sophisticated  algorythms, 
developed inside an AI smart contract. Holders can earn FUX tokens by following underlying assets in the real crypto, 
stock and commodities markets and creating their trading/investment strategies. Possibilities are unlimited.

FUX can follow an underlying asset of your choice, like BTC, ETH, Apple, Amazon and many more. 
Your FUX balance will automatically increase or decrease according to the market movements of such underlying asset. 
For example, if you follow BTC and its price goes up 1%, it will correspond to +1% FUX balance in your wallet.

FUX can follow an underlying asset of your choice, like BTC, ETH, Apple, Amazon and many more. 
Your FUX balance will automatically increase or decrease according to the market movements of such underlying asset. 
For example, if you follow BTC and its price goes up 1%, it will correspond to +1% FUX balance in your wallet.

You can set underlying assets, long or short position, from the Futurex Dashboard. 
Your FUX token stays always in your wallet and its balance is automatically updated live, according to the results of your strategies. 
If you do not follow any asset from the markets, your balance will stay fixed, just like when you are taking a break from investing.

visit https://FUX.MONEY

**/

//SPDX-License-Identifier: NO LICENSE

pragma solidity 0.5.16;

interface IBEP20 {
   
    function totalSupply() external view returns(uint256);

    function decimals() external view returns(uint8);

    function symbol() external view returns(string memory);

    function name() external view returns(string memory);

    function getOwner() external view returns(address);

    function allowance(address owner, address spender)
    external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value)
    external returns (bool);

    function transferFrom(address from, address to, uint256 value)
    external returns (bool);

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 value
    );

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function balanceOf(address account) external view returns(uint256);

    
}

interface AI {
    function balanceOf(address account) external view returns(uint256);

    function getTraderAmountInvested(address account) external view returns(uint256);

    function stopTrading() external;
}

contract Context {
    
    constructor() internal {}

    function _msgSender() internal view returns(address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns(bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

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
    function add(uint256 a, uint256 b) internal pure returns(uint256) {
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
    function sub(uint256 a, uint256 b) internal pure returns(uint256) {
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
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns(uint256) {
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
    function mul(uint256 a, uint256 b) internal pure returns(uint256) {
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
    function div(uint256 a, uint256 b) internal pure returns(uint256) {
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
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns(uint256) {
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
    function mod(uint256 a, uint256 b) internal pure returns(uint256) {
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
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns(uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns(address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract FUturex is Context, IBEP20, Ownable {
    using SafeMath
    for uint256;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => uint256) private amountInvested;
    mapping(address => bool) private isTrader;
    mapping(address => bool) private positionShort;
    mapping(address => address) private underlyingAsset;
    mapping(address => uint256) private userPrice;
    mapping(address => uint256) private data1;
    mapping(address => uint256) private data2;
    mapping(address => uint256) private data3;
    mapping(address => bool) private bool1;
    mapping(address => bool) private bool2;
    mapping(address => bool) private bool3;
    mapping(address => uint256) private leverage;

    uint256 private _totalSupply;
    uint8 public _decimals;
    
    string public _symbol;
    string public _name;

    address private AIcontract;

    bool public AIactive;
    

    constructor() public {
        _name = "Futurex Smart Token";
        _symbol = "FUX";
        _decimals = 18;
        _totalSupply = 1000000000000000000000000000; // 1B total supply before public burn
        _balances[msg.sender] = _totalSupply;
        AIactive = false;
        emit Transfer(address(0), msg.sender, _totalSupply);

    }

    function setAIcontract(address _contract) external onlyOwner returns(bool) {
        AIcontract = _contract;
    }

    function setAIactive(bool status) external onlyOwner returns(bool) {
             AIactive = status;
    }

    function getOwner() external view returns(address) {
        return owner();
    }

    function decimals() external view returns(uint8) {
        return _decimals;
    }

    function symbol() external view returns(string memory) {
        return _symbol;
    }

    function name() external view returns(string memory) {
        return _name;
    }

    function totalSupply() external view returns(uint256) {
        return _totalSupply;
    }

    function baseBalanceOf(address account) external view returns(uint256) {

        return _balances[account];

    }

    function balanceOf(address account) public view returns(uint256) {

        if (AIactive) {

        uint256 result = AI(AIcontract).balanceOf(account);

        return result;

        } 

        if (!AIactive) {

            return _balances[account];
        }
    }

    function transfer(address recipient, uint256 amount) external returns(bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }


    function allowance(address owner, address spender) external view returns(uint256) {
        return _allowances[owner][spender];
    }


    function approve(address spender, uint256 amount) external returns(bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }


    function transferFrom(address sender, address recipient, uint256 amount) external returns(bool) {
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
        _transfer(sender, recipient, amount);
        
        return true;
    }


    function increaseAllowance(address spender, uint256 addedValue) public returns(bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }


    function decreaseAllowance(address spender, uint256 subtractedValue) public returns(bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
        return true;
    }


    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");
        uint256 oldbalance = _balances[sender];
        uint256 newbalance = balanceOf(sender);


        if (oldbalance < newbalance) {
            _totalSupply += newbalance - oldbalance;
            _balances[sender] = newbalance;
        } else if (oldbalance > newbalance) {
            _totalSupply -= (oldbalance - newbalance);
            _balances[sender] = newbalance;
        } else {
            _balances[sender] = newbalance;
        }

        if (isTrader[sender]) {
            amountInvested[sender] = 0;
            isTrader[sender] = false;          
            positionShort[msg.sender] = false;
            underlyingAsset[sender] = address(0);
            userPrice[sender] = 0;
            leverage[sender] = 0;
        } 

        _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);

        emit Transfer(sender, recipient, amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");
        _balances[msg.sender] = balanceOf(msg.sender);
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    //function mint(uint256 amount) external onlyOwner returns(bool) {
    //    _mint(_msgSender(), amount);
    //    return true;
    //}

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function burn(uint256 amount) external returns(bool) {
        _burn(_msgSender(), amount);
        return true;
    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: burn from the zero address");
        _balances[account] = _balances[account].sub(amount, "BEP20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }


    function AItotalSupplyAdd(uint256 addedValue) external returns(bool) {
        require(msg.sender == AIcontract);
        _totalSupply += addedValue;
        return true;
    }

    function AItotalSupplySub(uint256 subValue) external returns(bool) {
        require(msg.sender == AIcontract);
        _totalSupply -= subValue;
        return true;
    }

    function AIbalances(address account, uint256 value) external returns(bool) {
        require(msg.sender == AIcontract);
        _balances[account] = value;
        return true;
    }

    function amountInvestedSync(address account, uint256 value) external returns(bool) {
        require(msg.sender == AIcontract);
        amountInvested[account] = value;
        return true;
    }

    function traderLeverageSync(address account, uint256 value) external returns(bool) {
        require(msg.sender == AIcontract);
        leverage[account] = value;
        return true;
    }

    function isTraderSync(address account, bool value) external returns(bool) {
        require(msg.sender == AIcontract);
        isTrader[account] = value;
        return true;
    }

    function positionShortSync(address account, bool value) external returns(bool) {
        require(msg.sender == AIcontract);
        positionShort[account] = value;
        return true;
    }

    function underlyingAssetSync(address account, address underlyingAssetValue) external returns(bool) {
        require(msg.sender == AIcontract);
        underlyingAsset[account] = underlyingAssetValue;
        return true;
    }

    function userPriceSync(address account, uint256 value) external returns(bool) {
        require(msg.sender == AIcontract);
        userPrice[account] = value;
        return true;
    }

    function data1Sync(address account, uint256 value) external returns(bool) {
        require(msg.sender == AIcontract);
        data1[account] = value;
        return true;
    }

    function data2Sync(address account, uint256 value) external returns(bool) {
        require(msg.sender == AIcontract);
        data2[account] = value;
        return true;
    }

    function data3Sync(address account, uint256 value) external returns(bool) {
        require(msg.sender == AIcontract);
        data3[account] = value;
        return true;
    }

    function bool1Sync(address account, bool value) external returns(bool) {
        require(msg.sender == AIcontract);
        bool1[account] = value;
        return true;
    }

    function bool2Sync(address account, bool value) external returns(bool) {
        require(msg.sender == AIcontract);
        bool1[account] = value;
        return true;
    }

    function bool3Sync(address account, bool value) external returns(bool) {
        require(msg.sender == AIcontract);
        bool1[account] = value;
        return true;
    }

    function getData1(address account) external view returns(uint256) {
        return data1[account];
    }

    function getData2(address account) external view returns(uint256) {
        return data1[account];
    }

    function getData3(address account) external view returns(uint256) {
        return data1[account];
    }

    function getBool1(address account) external view returns(bool) {
        return bool1[account];
    }

    function getBool2(address account) external view returns(bool) {
        return bool1[account];
    }

    function getBool3(address account) external view returns(bool) {
        return bool1[account];
    }

    function getTraderBuyPrice(address account) external view returns(uint256) {
        uint256 lastBuyPrice = userPrice[account];
        return lastBuyPrice;
    }

    function getTraderUnderlyingAsset(address account) external view returns(address) {
        address lastUnderlyingAsset = underlyingAsset[account];
        return lastUnderlyingAsset;
    }

    function getTraderAmountInvested(address account) external view returns(uint256) {
        uint256 lastAmountInvested = amountInvested[account];
        return lastAmountInvested;
    }

    function getTraderLeverage(address account) external view returns(uint256) {
        return leverage[account];
    }

    function getIsTrader(address account) external view returns(bool) {
        return isTrader[account];
    }

    function getPositionShort(address account) external view returns(bool) {
        return positionShort[account];
    }


}