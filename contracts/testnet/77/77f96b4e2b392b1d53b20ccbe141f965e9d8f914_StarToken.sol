/**
 *Submitted for verification at BscScan.com on 2022-04-19
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

    function mathDivisionToFloat(uint256 a, uint256 b, uint decimals) public pure returns (uint256) {
        uint256 aPlus = a * (10 ** uint256(decimals));
        uint256 amount = aPlus / b;
        return amount;
    }

}

abstract contract ERC20 {
    function transferFrom(address _from, address _to, uint256 _value) external virtual returns (bool success);
    function transfer(address recipient, uint256 amount) external virtual returns (bool);
    function balanceOf(address account) external virtual view returns (uint256);
    function approve(address spender, uint256 amount) external virtual returns (bool);
}

abstract contract PancakePair {
    function getReserves() external virtual view returns (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast);
}

interface IUniswapV2Router02 {

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

}

contract StarToken is IERC20, Ownable, Util {

    using SafeMath for uint256;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    uint256 private _totalSupply;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => uint256) private lastPurchaseTime;
    uint private shortestTradingTime; // second

    mapping(address => address) private inviter;
    address public swapRouter;

    uint256 private lpPoolRatio;
    uint256 private fwPoolRatio;
    uint256 private marketingRatio;
    uint256 private fundRatio;
    uint256 private destroyRatio;

    address private lpPoolAddress;
    address private fwPoolAddress;
    address private marketingAddress;
    address private fundAddress;
    address private destroyAddress;

    uint256 public highestPrice;
    uint256 public fallPercent;

    PancakePair pancakePair;
    IUniswapV2Router02 public immutable uniswapV2Router;
    ERC20 private usdtToken;
    
    constructor() {

        _name = "Star";
        _symbol = "Star";
        _decimals = 18;

        _totalSupply = 88000 * 10 ** uint(_decimals);
		
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _balances[msg.sender]);
        
        _isExcludedFromFee[msg.sender] = true;
        _isExcludedFromFee[address(this)] = true;
        _owner = msg.sender;
        shortestTradingTime = 30;

        lpPoolAddress = 0xAE6c148Ce7D5a059c67C468F96F4F03E8Ae4f3DD;
        fwPoolAddress = lpPoolAddress;
        marketingAddress = lpPoolAddress;
        fundAddress = lpPoolAddress;

        destroyAddress = 0x000000000000000000000000000000000000dEaD;
        uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);

        lpPoolRatio = 30;
        fwPoolRatio = 20;
        marketingRatio = 20;
        fundRatio = 10;
        destroyRatio = 20;

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

    //this method is responsible for taking all fee, if takeFee is true
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        if(sender != swapRouter && recipient != swapRouter && inviter[recipient] == address(0)) {
            inviter[recipient] = sender;
        }

        if(sender == swapRouter && !_isExcludedFromFee[recipient]) {
            // buy
            lastPurchaseTime[recipient] = block.timestamp;

            transferSlippage(sender, recipient, amount, 1);

            updateHighestPrice();

        } else if(recipient == swapRouter && !_isExcludedFromFee[sender]) {
            // sell
            require(block.timestamp - lastPurchaseTime[sender] >= shortestTradingTime, "Frequent operation");

            transferSlippage(sender, recipient, amount, 2);

            updateHighestPrice();
            
        } else {
            _balances[sender] = _balances[sender].sub(amount);
            _balances[recipient] = _balances[recipient].add(amount);
            emit Transfer(sender, recipient, amount);
        }
        
    }

    function excludeFromFee(address _address) public onlyOwner {
        _isExcludedFromFee[_address] = true;
    }

    function includeInFee(address _address) public onlyOwner {
        _isExcludedFromFee[_address] = false;
    }

    function isExcludedFromFee(address _address) public view returns (bool) {
        return _isExcludedFromFee[_address];
    }

    function changeRouter(address router) public onlyOwner {
        swapRouter = router;
        pancakePair = PancakePair(router);
    }

    function setShortestTradingTime(uint _time) public onlyOwner {
        shortestTradingTime = _time;
    }

    function getInviter(address _address) public view returns (address) {
        return inviter[_address];
    }

    // 1 Star = ? U
    function queryStarToUsdtPrice() public view returns (uint256) {
        uint112 usdtSum; // LP USDT sum
        uint112 starSum; // LP Seed sum
        uint32 lastTime; // Last trading time
        (starSum, usdtSum, lastTime) = pancakePair.getReserves();
        return Util.mathDivisionToFloat(usdtSum, starSum, 18);
    }

    function updateHighestPrice() private {
        uint256 usdtToStarPrice = queryStarToUsdtPrice(); // unit256: wei
        if(usdtToStarPrice > highestPrice) {
            highestPrice = usdtToStarPrice;   
        }
    }

    function transferSlippage(address sender, address recipient, uint256 amount, uint8 transferType) private {

        uint256 lpPoolAmount = amount.mul(lpPoolRatio).div(1000);
        uint256 fwPoolAmount = amount.mul(fwPoolRatio).div(1000);
        uint256 marketingAmount = amount.mul(marketingRatio).div(1000);
        uint256 fundAmount= amount.mul(fundRatio).div(1000);

        _balances[lpPoolAddress] = _balances[lpPoolAddress].add(lpPoolAmount);
        _balances[fwPoolAddress] = _balances[fwPoolAddress].add(fwPoolAmount);
        _balances[marketingAddress] = _balances[marketingAddress].add(marketingAmount);
        _balances[fundAddress] = _balances[fundAddress].add(fundAmount);

        emit Transfer(sender, lpPoolAddress, lpPoolAmount);
        emit Transfer(sender, fwPoolAddress, fwPoolAmount);
        emit Transfer(sender, marketingAddress, marketingAmount);
        emit Transfer(sender, fundAddress, fundAmount);

        uint256 slippageAmount = 0;
        if(transferType == 1) {
            slippageAmount = lpPoolAmount.add(fwPoolAmount).add(marketingAmount).add(fundAmount);
        } else {

            uint256 destroyAmount = amount.mul(destroyRatio).div(1000);
            _balances[destroyAddress] = _balances[destroyAddress].add(destroyAmount);
            emit Transfer(sender, destroyAddress, destroyAmount);
            slippageAmount = lpPoolAmount.add(fwPoolAmount).add(marketingAmount).add(fundAmount).add(destroyAmount);

            uint256 usdtToStarPrice = queryStarToUsdtPrice(); // unit256: wei
            if(usdtToStarPrice < highestPrice) {
                fallPercent = (highestPrice.sub(usdtToStarPrice)).div(highestPrice).mul(100);
                uint256 increaseAmount = 0;
                if(fallPercent > 20) {
                    increaseAmount = amount.mul(400).div(1000);
                } else if(fallPercent > 15) {
                    increaseAmount = amount.mul(300).div(1000);
                } else if(fallPercent > 10) {
                    increaseAmount = amount.mul(200).div(1000);
                } else if(fallPercent > 5) {
                    increaseAmount = amount.mul(100).div(1000);
                }

                if(increaseAmount > 0) {
                    slippageAmount = slippageAmount.add(increaseAmount);

                    uint256 tempAmount = increaseAmount.mul(500).div(1000);
                    _balances[fwPoolAddress] = _balances[fwPoolAddress].add(tempAmount);
                    emit Transfer(sender, fwPoolAddress, tempAmount);

                    tempAmount = increaseAmount.mul(200).div(1000);
                    _balances[address(this)] = _balances[address(this)].add(tempAmount);
                    emit Transfer(sender, address(this), tempAmount);

                    tempAmount = increaseAmount.mul(300).div(1000);
                    _balances[address(this)] = _balances[address(this)].add(tempAmount);
                    emit Transfer(sender, address(this), tempAmount);

                    swapThisToUsdt(tempAmount, address(this));
                    swapUsdtToThis(destroyAddress);

                }

            }
            
        }

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount.sub(slippageAmount));
        emit Transfer(sender, recipient, amount.sub(slippageAmount));
    }

    function swapThisToUsdt(uint256 tokenAmount, address to) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(usdtToken);

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            to,
            block.timestamp
        );
        
    }

    function swapUsdtToThis(address to) private {

        uint256 tokenAmount = usdtToken.balanceOf(address(this));

        address[] memory path = new address[](2);
        path[0] = address(usdtToken);
        path[1] = address(this);

        usdtToken.approve(address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            to,
            block.timestamp
        );
        
    }

    function setLpPoolRatio(uint256 ratio) public onlyOwner {
        lpPoolRatio = ratio;
    }

    function setFwPoolRatio(uint256 ratio) public onlyOwner {
        fwPoolRatio = ratio;
    }

    function setMarketingRatio(uint256 ratio) public onlyOwner {
        marketingRatio = ratio;
    }

    function setFundRatio(uint256 ratio) public onlyOwner {
        fundRatio = ratio;
    }

    function setLpPoolAddress(address _address) public onlyOwner {
        lpPoolAddress = _address;
    }

    function setFwPoolAddress(address _address) public onlyOwner {
        fwPoolAddress = _address;
    }

    function setMarketingAddress(address _address) public onlyOwner {
        marketingAddress = _address;
    }

    function setFundAddress(address _address) public onlyOwner {
        fundAddress = _address;
    }

    function setUsdtToken(address _token) public onlyOwner {
        usdtToken = ERC20(_token);
    }

}