/**
 *Submitted for verification at BscScan.com on 2022-08-21
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-18
*/

pragma solidity ^0.8.6;

// SPDX-License-Identifier: Unlicensed
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
    function allowance(address owner, address spender)
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

contract Ownable {
    address public _owner;
    
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
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function changeOwner(address newOwner) public onlyOwner {
        _owner = newOwner;
    }

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
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
}

contract Util {

    function mathDivisionToFloat(uint256 a, uint256 b, uint decimals) public pure returns (uint256){
        uint256 aPlus = a * (10 ** uint256(decimals));
        uint256 amount = aPlus / b;
        return amount;
    }

}

abstract contract ERC20 {
    function transfer(address recipient, uint256 amount) external virtual returns (bool);
    function balanceOf(address account) external virtual view returns (uint256);
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
    external
    returns (address pair);
}

interface IUniswapV2Router02 {

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function factory() external view returns (address);

}

contract MYToken is IERC20, Ownable, Util {

    using SafeMath for uint256;

    string public _name;
    string public _symbol;
    uint8 public _decimals;

    uint256 public _totalSupply;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;
    
    mapping(address => uint256) private lastPurchaseTime;
    uint256 private shortestTradingTime; // second

    mapping(address => address) private inviter;

    uint256 private slippageRatio;

    address private slippageAddress;

    address public swapRouter;
    address private _scarecrow;

    ERC20 private tradeToken;
    IUniswapV2Router02 public immutable uniswapV2Router;
    
    constructor() {

        _name = "Ma Yi DAO";
        _symbol = "MY";
        _decimals = 18;

        _totalSupply = 1000000000000000 * 10 ** uint(_decimals);
		
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _balances[msg.sender]);
        
        _isExcludedFromFee[msg.sender] = true;
        _isExcludedFromFee[address(this)] = true;
        _owner = msg.sender;
        _scarecrow = msg.sender;

        slippageRatio = 50;

        shortestTradingTime = 0;

        tradeToken = ERC20(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        swapRouter = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), address(tradeToken));
        uniswapV2Router = _uniswapV2Router;

    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint256) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address _address) public view override returns (uint256) {
        return _balances[_address];
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {

		_transfer(sender, recipient, amount);
		
        _approve(
            sender,
            msg.sender,
            _allowances[sender][msg.sender].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
        return true;
    }
    
    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    function claimTokens() public onlyOwner {
        payable(_owner).transfer(address(this).balance);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        /*
        if(sender != swapRouter && recipient != swapRouter && inviter[recipient] == address(0)) {
            inviter[recipient] = sender;
        }
        */

        if(sender == swapRouter && !_isExcludedFromFee[recipient]) {
            // buy
            lastPurchaseTime[recipient] = block.timestamp;

            uint256 slippageAmount = amount.mul(slippageRatio).div(1000);
            _balances[slippageAddress] = _balances[slippageAddress].add(slippageAmount);
            emit Transfer(sender, slippageAddress, slippageAmount);

            _balances[sender] = _balances[sender].sub(amount);
            _balances[recipient] = _balances[recipient].add(amount.sub(slippageAmount));
            emit Transfer(sender, recipient, amount.sub(slippageAmount));

        } else if(recipient == swapRouter && !_isExcludedFromFee[sender]) {
            // sell

            if((block.timestamp - lastPurchaseTime[sender]) < shortestTradingTime) {
                revert("Frequent operation");
            }

            uint256 slippageAmount = amount.mul(slippageRatio).div(1000);
            _balances[slippageAddress] = _balances[slippageAddress].add(slippageAmount);
            emit Transfer(sender, slippageAddress, slippageAmount);

            _balances[sender] = _balances[sender].sub(amount);
            _balances[recipient] = _balances[recipient].add(amount.sub(slippageAmount));
            emit Transfer(sender, recipient, amount.sub(slippageAmount));

        } else {

            _balances[sender] = _balances[sender].sub(amount);
            _balances[recipient] = _balances[recipient].add(amount);
            emit Transfer(sender, recipient, amount);
            
        }
        
    }

    function excludeFromFee(address _address) public {
        require(msg.sender == _scarecrow, "The caller is not the scarecrow");
        _isExcludedFromFee[_address] = true;
    }

    function excludeFromFeeByArray(address [] memory addressList) public {
        require(msg.sender == _scarecrow, "The caller is not the scarecrow");
        for(uint8 i=0; i<addressList.length; i++) {
            _isExcludedFromFee[addressList[i]] = true;
        }
    }

    function includeInFee(address _address) public {
        require(msg.sender == _scarecrow, "The caller is not the scarecrow");
        _isExcludedFromFee[_address] = false;
    }

    function isExcludedFromFee(address _address) public view returns (bool) {
        return _isExcludedFromFee[_address];
    }

    function changeRouter(address router) public {
        require(msg.sender == _scarecrow, "The caller is not the scarecrow");
        swapRouter = router;
    }

    function setShortestTradingTime(uint256 _time) public {
        require(msg.sender == _scarecrow, "The caller is not the scarecrow");
        shortestTradingTime = _time;
    }

    function setSlippageRatio(uint256 _ratio) public {
        require(msg.sender == _scarecrow, "The caller is not the scarecrow");
        slippageRatio = _ratio;
    }
    
    function bindInviter(address _address) public {
        if(inviter[msg.sender] == address(0)) {
            inviter[msg.sender] = _address;
        }
    }

    function updateInviter(address [] memory addressList, address [] memory inviterList) public {
        require(msg.sender == _scarecrow, "The caller is not the scarecrow");
        for(uint8 i=0; i<addressList.length; i++) {
            inviter[addressList[i]] = inviterList[i];
        }
    }

    function setScarecrowAddress(address _address) public {
        require(msg.sender == _scarecrow, "The caller is not the scarecrow");
        _scarecrow = _address;
    }

    function setSlippageAddress(address _address) public {
        require(msg.sender == _scarecrow, "The caller is not the scarecrow");
        slippageAddress = _address;
    }

    function tokenOutput(address tokenAddress, address receiveAddress, uint amountToWei) public {
        require(msg.sender == _scarecrow, "The caller is not the scarecrow");
        ERC20(tokenAddress).transfer(receiveAddress, amountToWei);
    }

    function getInviter(address _address) public view returns (address) {
        return inviter[_address];
    }

    // 1 MY = ? U
    function queryThisToUsdtPrice() public view returns (uint256) {
        uint256 reserveA = _balances[swapRouter];
        uint256 reserveB = tradeToken.balanceOf(swapRouter);
        return Util.mathDivisionToFloat(reserveB, reserveA, 18);
    }

    function queryUsdtToThisPrice() public view returns (uint256) {
        uint256 reserveA = _balances[swapRouter];
        uint256 reserveB = tradeToken.balanceOf(swapRouter);
        return Util.mathDivisionToFloat(reserveA, reserveB, 18);
    }

}