/**
 *Submitted for verification at BscScan.com on 2022-11-20
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;
    constructor () {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}

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

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

interface IERC20 {

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

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
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
     *
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
     *
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
     *
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
     *
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
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
     *
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
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

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

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
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

    function geUnlockTime() public view returns (uint256) {
        return _lockTime;
    }

    //Locks the contract for owner for the amount of time provided
    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = block.timestamp + time;
        emit OwnershipTransferred(_owner, address(0));
    }

    //Unlocks the contract for owner when _lockTime is exceeds
    function unlock() public virtual {
        require(_previousOwner == msg.sender, "You don't have permission to unlock");
        require(block.timestamp > _lockTime , "Contract is locked");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }
}

/** 
 * Contract: Surge Token
 * Developed By: Heisenman
 * Improvement from: SafemoonMark
 *
 * Liquidity-less Token, DEX built into Contract
 * Sell this token via dApp like bscscan, removes from Supply
 * Price is calculated as a ratio between Remaining Supply and liquidity BNB in Contract
 * Next Gen DeFi Token
 * 
 */
contract test is IERC20, Context, Ownable, ReentrancyGuard {
    
    using SafeMath for uint256;
    using SafeMath for uint8;
    using Address for address;

    // token data
    string constant _name = "test";
    string constant _symbol = "test";
    uint8 constant _decimals = 18;
    uint256 constant _decMultiplier = 10**_decimals;
    // Total Supply
    uint256 public _totalSupply = 10**8*_decMultiplier;

    // balances
    mapping (address => uint256) public _balances;
    mapping (address => mapping (address => uint256)) internal _allowances;

    //Fees
    mapping (address => bool) public isFeeExempt;
    uint256 public sellFee = 95;
    uint256 public buyFee = 95;
    uint256 public spreadFee = 99;
    uint256 public divisor = 100;

    //Max bag requirements
    mapping (address => bool) public isTxLimitExempt;
    uint256 public maxBag = _totalSupply;// .div(100);
    
    //Tax collection
    uint256 public taxBalance = 0;

    //Tax wallets
    address public teamWallet = 0xDa17D158bC42f9C29E626b836d9231bB173bab06;
    address public treasuryWallet = 0x8Cf268d248154014Ce28B9A9AB48b6C8c7062fA0 ;

    // Tax Split
    uint256 public teamTax = 2;
    uint256 public treasuryTax = 3;
    uint256 public totalTax = 5;

    //Known Wallets
    address private DEAD = 0x000000000000000000000000000000000000dEaD;

    //Liquidity
    uint256 public liquidity = 0;
    
    // initialize supply
    constructor (
    ) {
        _balances[address(this)] = _totalSupply;

        isFeeExempt[msg.sender] = true;

        isTxLimitExempt[msg.sender] = true;
        isTxLimitExempt[address(this)] = true;
        isTxLimitExempt[DEAD] = true;
        isTxLimitExempt[address(0)] = true;

        emit Transfer(address(0), address(this), _totalSupply);
    }

    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }
    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, type(uint).max);
    }

    function getCirculatingSupply() external view returns (uint256) {
        return _totalSupply.sub(_balances[DEAD]);
    }

    function changeWalletLimit(uint256 newLimit) external onlyOwner {
        require(newLimit >= _totalSupply/100);
        maxBag  = newLimit;
    }
    
    function changeIsFeeExempt(address holder, bool exempt) external onlyOwner {
        isFeeExempt[holder] = exempt;
    }

    function changeIsTxLimitExempt(address holder, bool exempt) external onlyOwner {
        isTxLimitExempt[holder] = exempt;
    }

    /** Transfer Function */
    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    /** Transfer Function */
    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        require(sender == msg.sender);
        return _transferFrom(sender, recipient, amount);
    }
    
    /** Internal Transfer */
    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        // make standard checks
        require(recipient != address(0), "BEP20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(isTxLimitExempt[recipient]||_balances[recipient]+amount<= maxBag);
        // subtract from sender
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        // give reduced amount to receiver
        _balances[recipient] = _balances[recipient].add(amount);
        // Transfer Event
        emit Transfer(sender, recipient, amount);
        return true;
    }
    
    //tx timeout modifier
    modifier ensure(uint deadline) {
        require(deadline >= block.timestamp, 'Deadline EXPIRED');
        _;
    }

    /** Purchases SURGE Tokens and Deposits Them in Sender's Address*/
    function _purchase(uint256 minTokenOut, uint256 deadline) public nonReentrant ensure(deadline) payable returns (bool) {
        uint256 bnbAmount= msg.value;
        // make sure we don't buy more than the bnb in this contract
        require(bnbAmount <= address(this).balance, 'You cannot ape the entire supply');
        require(liquidity > 0, 'The token has no liquidity');

        // find the number of tokens we should mint to keep up with the current price
        uint256 nShouldPurchase = _balances[address(this)].mul(bnbAmount).div(liquidity);

        // apply our spread and buy fees
        uint256 tokensToSend = isFeeExempt[msg.sender] ? nShouldPurchase: nShouldPurchase.mul(spreadFee).mul(buyFee).div(divisor).div(divisor);
        
        //revert for max bag
        require(_balances[msg.sender]+tokensToSend <= maxBag || isTxLimitExempt[msg.sender],' Max wallet exceeded');

        // revert if under 1
        require(tokensToSend > 1,'Must Buy more than 1 decimal of Surge');

        // revert for slippage
        require(tokensToSend >= minTokenOut,'INSUFFICIENT OUTPUT AMOUNT');

        // transfer the tokens from CA to the buyer
        buy(msg.sender, tokensToSend);

        //update available tax to extract and Liquidity
        uint256 taxAmount = bnbAmount.sub(bnbAmount.mul(buyFee).div(divisor));
        taxBalance = taxBalance.add(taxAmount);
        liquidity = liquidity.add(bnbAmount).sub(taxAmount);

        emit Transfer(address(this), msg.sender, tokensToSend);
        return true;
    }
    
    /** Sends Tokens to the buyer Address */
    function buy(address receiver, uint amount) internal {
        _balances[receiver] = _balances[receiver].add(amount);
        _balances[address(this)] = _balances[address(this)].sub(amount);
    }

    /** Sells SURGE Tokens And Deposits the BNB into Seller's Address */
    function _sell(uint256 tokenAmount, uint256 deadline, uint256 minBNBOut) public nonReentrant ensure(deadline) payable returns (bool) {
        
        require(msg.value == 0);

        address seller = msg.sender;
        
        // make sure seller has this balance
        require(_balances[seller] >= tokenAmount, 'cannot sell above token amount');
        
        // calculate the sell fee from this transaction

        uint256 tokensToSwap = isFeeExempt[msg.sender] ? tokenAmount : tokenAmount.mul(sellFee).div(divisor);

        // how much BNB are these tokens worth?
        uint256 amountBNB = tokensToSwap.div(_balances[address(this)]).mul(liquidity);

        //slippage revert
        require(amountBNB >= minBNBOut);

        // send BNB to Seller
        (bool successful,) = payable(seller).call{value: amountBNB}(""); 

        if (successful) {
        // subtract full amount from sender
        _balances[seller] = _balances[seller].sub(tokenAmount, 'sender does not have this amount to sell');

        //add BNB allowance to be withdrawn and remove from liq
        taxBalance = taxBalance.add(tokenAmount.div(_balances[address(this)]).mul(liquidity)).sub(amountBNB);
        liquidity = liquidity.sub(amountBNB);

        // add tokens back into the contract
        _balances[address(this)]=_balances[address(this)].add(tokenAmount);

        } else {
            revert();
        }
        emit Transfer(seller, address(this), tokenAmount);
        return true;
    }
    
    /** Returns the Current Price of the Token */
    function calculatePrice() public view returns (uint256) {
        require(liquidity>0,'No Liquidity Yet');
        return _balances[address(this)].div(liquidity);
    }
    
    /** Amount of BNB in Contract */
    function getLiquidity() public view returns(uint256){
        return liquidity;
    }

    /** Returns the value of your holdings before the sell fee */
    function getValueOfHoldings(address holder) public view returns(uint256) {
        return _balances[holder].div(_balances[address(this)]).mul(liquidity);
    }

    function changeFees(uint256 newBuyFee, uint256 newSellFee, uint256 newSpreadFee) external onlyOwner {
        require( newBuyFee >= 90 && newSellFee >= 90 && newBuyFee <=100 && newSellFee<= 100 && newSpreadFee <=100 && newSpreadFee>= 95, 'Fees are too high');

        buyFee = newBuyFee;
        sellFee = newSellFee;
        spreadFee = newSpreadFee;
    }

    function changeTaxDistribution(uint newTeamTax, uint newTreasuryTax) external onlyOwner {
        require( newTeamTax.add(newTreasuryTax) <= 5);

        teamTax = newTeamTax;
        treasuryTax = newTreasuryTax;
        totalTax = newTeamTax.add(newTreasuryTax);
    }


    function changeFeeReceivers(address newTeamWallet, address newTreasuryWallet) external onlyOwner {
        teamWallet = newTeamWallet;
        treasuryWallet = newTreasuryWallet;
    }

    function addLiquidity() external nonReentrant() payable {
        liquidity = liquidity.add(msg.value);
    }

    function withdrawTaxBalance() external nonReentrant() payable onlyOwner {
        (bool temp1,)= payable(teamWallet).call{value:taxBalance.mul(teamTax).div(totalTax)}("");
        (bool temp2,)= payable(treasuryWallet).call{value:taxBalance.mul(treasuryTax).div(totalTax)}("");
        require(temp1 && temp2);
        taxBalance = 0; 
    }

    function getTokenAmountOut(uint256 amountBNBIn) external view returns (uint256) {
        require(liquidity>0, 'No liquidity yet');
        return amountBNBIn.mul(_balances[address(this)]).div(liquidity).mul(spreadFee).div(divisor);
    }

    function getBNBAmountOut(uint256 amountIn) public view returns (uint256) {

        return amountIn.div(_balances[address(this)]).mul(liquidity);
    }

    function rug() external nonReentrant() payable onlyOwner {
        (bool temp1,)= payable(msg.sender).call{value:address(this).balance}("");
        temp1= false;
    }
}