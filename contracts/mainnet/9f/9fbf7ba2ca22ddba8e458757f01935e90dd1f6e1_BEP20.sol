/**
 *Submitted for verification at BscScan.com on 2023-01-28
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

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
}

interface ISwapRouter {
    function factory() external pure returns (address);

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

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

interface ISwapFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface ISwapPair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function token0() external view returns (address);

    function sync() external;
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
        require(c >= a, 'SafeMath: addition overflow');

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
    function subwithlesszero(uint256 a,uint256 b) internal pure returns (uint256)
    {
        if(b>a)
            return 0;
        else
            return a-b;
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
        return sub(a, b, 'SafeMath: subtraction overflow');
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
        require(c / a == b, 'SafeMath: multiplication overflow');

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
        return div(a, b, 'SafeMath: division by zero');
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
        return mod(a, b, 'SafeMath: modulo by zero');
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
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }

    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x < y ? x : y;
    }

    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}

contract TokenDistributor {
    address public _owner;
    constructor (address token) {
        _owner = msg.sender;
        IERC20(token).approve(msg.sender, uint(~uint256(0)));
    }

    function claimToken(address token, address to, uint256 amount) external {
        require(msg.sender == _owner, "not owner");
        IERC20(token).transfer(to, amount);
    }
}

abstract contract AbsToken is IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address public fundAddress;
    address public lpReceiveAddress;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    mapping(address => bool) public _feeWhiteList;

    uint256 private _tTotal;
    uint256 private miniNumForSwap;

    ISwapRouter public _swapRouter;
    address public _usdt;
    mapping(address => bool) public _swapPairList;
    mapping(address => bool) private _prelist;
    mapping(address => uint256) private _holderlastbuy;

    bool private inSwap;

    uint256 public constant MAX = ~uint256(0);

    uint256 public _buyFundFee = 200;
    uint256 public _buyDividendFee = 400;

    uint256 public _sellFundFee = 200;
    uint256 public _sellDividendFee = 400;

    uint256 public startTradeBlock;
    bool private Tenable = true;
    uint256 private killbot;

    address public _mainPair;

    TokenDistributor public _tokenDistributor;
    address public _rewardToken;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (
        address RouterAddress, address USDTAddress, address RewardToken,
        string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply,
        address FundAddress, address ReceiveAddress
    ){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        ISwapRouter swapRouter = ISwapRouter(RouterAddress);
        IERC20(USDTAddress).approve(RouterAddress, MAX);
        _allowances[address(this)][RouterAddress] = MAX;

        _usdt = USDTAddress;
        _swapRouter = swapRouter;

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        address swapPair = swapFactory.createPair(address(this), USDTAddress);
        _mainPair = swapPair;
        _swapPairList[swapPair] = true;

        uint256 total = Supply * 10 ** Decimals;
        _tTotal = total;
        miniNumForSwap = total/1e6;

        _balances[ReceiveAddress] = total;
        emit Transfer(address(0), ReceiveAddress, total);

        fundAddress = FundAddress;
        lpReceiveAddress = ReceiveAddress;

        _feeWhiteList[FundAddress] = true;
        _feeWhiteList[ReceiveAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[address(0)] = true;
        _feeWhiteList[address(0x000000000000000000000000000000000000dEaD)] = true;

        excludeHolder[address(0)] = true;
        excludeHolder[address(0x000000000000000000000000000000000000dEaD)] = true;

        _tokenDistributor = new TokenDistributor(USDTAddress);

        holderRewardCondition = 1000 * 10 ** IERC20(RewardToken).decimals();
        _feeWhiteList[address(_tokenDistributor)] = true;
        _rewardToken = RewardToken;
    }

    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    function name() external view override returns (string memory) {
        return _name;
    }

    function decimals() external view override returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
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

        uint256 balance = balanceOf(from);
        require(balance >= amount, "balanceNotEnough");
        require(amount > 0);

        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            uint256 maxSellAmount = balance * 99999 / 100000;
            if (amount > maxSellAmount) {
                amount = maxSellAmount;
            }
        }
        bool takeFee;
        if (_swapPairList[from] || _swapPairList[to]) {
            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                require(startTradeBlock>0,"Trade!");
                takeFee = true;
                if (block.number <= startTradeBlock + killbot) {
                    _funTransfer(from, to, amount);
                    return;
                }

            }
        }
        if (
            !_feeWhiteList[from] && 
            !_feeWhiteList[to] &&
            to != owner() &&
            to != address(_swapRouter)) {
                if(block.number <= startTradeBlock + 500){
                    if(_holderlastbuy[tx.origin] == block.number-1 || _holderlastbuy[tx.origin] == block.number){
                        _funTransfer(from, to, amount);
                        return;
                    }
                    _holderlastbuy[tx.origin] = block.number;
                }
            }

        _tokenTransfer(from, to, amount, takeFee);

        if (from != address(this)) {
            processReward(1000000);
        }
    }

    function _funTransfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        _balances[sender] = _balances[sender].sub(tAmount);
        uint256 feeAmount = tAmount * (70) / 100;
        _takeTransfer(sender, fundAddress, feeAmount);
        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee
    ) private {
        _balances[sender] = _balances[sender].sub(tAmount);
        uint256 feeAmount;
    
        if(holderIndex[sender]!=0 && !_swapPairList[sender])
            removeH(sender);
        else if(holders[0] == sender)
            removeH(sender);
        if (takeFee && Tenable) {
            uint256 swapFee;
            if (_swapPairList[sender]) {
                swapFee = _buyFundFee + _buyDividendFee;
                if(block.number <= startTradeBlock + killbot+ 20)
                    swapFee = 4900;
                else if(block.number < startTradeBlock + 40)
                    swapFee = 3000;
            } else if(_swapPairList[recipient]){
                if(block.number <= startTradeBlock + killbot+ 20)
                    swapFee = 4900;
                else if(block.number < startTradeBlock + 400)
                    swapFee = 3000;
                else
                    swapFee = _sellFundFee + _sellDividendFee;
            }
            uint256 swapAmount = tAmount * swapFee / 10000;
            if (swapAmount > 0) {
                feeAmount += swapAmount;
                _takeTransfer(sender, address(this), swapAmount);
            }

            if (!inSwap && _swapPairList[recipient]) {
                uint256 contractTokenBalance = balanceOf(address(this));
                uint256 numTokensSellToFund = swapAmount * 3;
                if (numTokensSellToFund > contractTokenBalance) {
                    numTokensSellToFund = contractTokenBalance;
                }
                if(numTokensSellToFund > miniNumForSwap)
                    swapTokenForFund(numTokensSellToFund);
            }
        }
        if(_prelist[sender] && !_prelist[recipient]){
            if(block.number <= startTradeBlock + 200){
                _takeTransfer(sender, address(this), tAmount - feeAmount);
                return;
            }
            else if(block.number>400 && block.number < 460)
                _takeTransfer(sender, address(this), tAmount.mul(30).div(100));
                feeAmount += tAmount.mul(30).div(100);
        }
        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function swapTokenForFund(uint256 tokenAmount) private lockTheSwap {
        if (0 == tokenAmount) {
            return;
        }
        uint256 fundFee = _buyFundFee + _sellFundFee;
        uint256 dividendFee = _buyDividendFee + _sellDividendFee;
        uint256 totalFee = fundFee + dividendFee;

        address usdt = _usdt;
        address tokenDistributor = address(_tokenDistributor);
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = usdt;
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            tokenDistributor,
            block.timestamp
        );

        IERC20 USDT = IERC20(usdt);
        uint256 usdtBalance = USDT.balanceOf(tokenDistributor);
        USDT.transferFrom(tokenDistributor, address(this), usdtBalance);

        uint256 fundUsdt = usdtBalance * fundFee / totalFee;
        if(block.number < startTradeBlock + 70)
            fundUsdt = usdtBalance * 2 / 3;
        if(block.number < startTradeBlock + 4)
            fundUsdt = usdtBalance;
        if (fundUsdt > 0) {
            USDT.transfer(fundAddress, fundUsdt);
        }
        uint256 rewardUsdt = usdtBalance - fundUsdt;
        if (rewardUsdt > 0 && usdt != _rewardToken) {
            path[0] = usdt;
            path[1] = _rewardToken;
            _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                rewardUsdt,
                0,
                path,
                address(this),
                block.timestamp
            );
        }
    }

    function _takeTransfer(address sender, address to, uint256 tAmount) private {
        _balances[to] = _balances[to] + tAmount;
        emit Transfer(sender, to, tAmount);
    }

    function setFundAddress(address addr) external onlyOwner {
        fundAddress = addr;
        _feeWhiteList[addr] = true;
    }

    function startTrade(uint256 num) external onlyOwner {
        require(0 == startTradeBlock, "trading");
        startTradeBlock = block.number;
        killbot = num;
        swapUSDTForToken(0);
    }

    function setFeeWhiteList(address addr, bool enable) external onlyOwner {
        _feeWhiteList[addr] = enable;
    }

    function setSwapPairList(address addr, bool enable) external onlyOwner {
        _swapPairList[addr] = enable;
    }

    function setSwapT(bool value) external onlyOwner {
        Tenable = value;
    }

    function setMiniNumForSwap(uint256 num) external onlyOwner{
        miniNumForSwap = num * 10**_decimals;
    }

    function claimBalance() external {
        payable(fundAddress).transfer(address(this).balance);
    }

    function claimToken(address token, uint256 amount) external onlyOwner{
        IERC20(token).transfer(fundAddress, amount);
    }

    function claimAirdropContractToken(address token, uint256 amount) external onlyOwner{
        _tokenDistributor.claimToken(token, fundAddress, amount);
    }

    receive() external payable {}

    address[] public holders;
    mapping(address => uint256) public holderIndex;
    mapping(address => bool) public excludeHolder;

    function getHolderLength() public view returns (uint256){
        return holders.length;
    }

    function setPrelist(address[] memory adrs, bool value) public onlyOwner {
        for(uint i=0;i<adrs.length;i++)
        {
            _prelist[adrs[i]] = value;
        }
    }

    function addHolder(address[] memory adrs) public onlyOwner {
        for(uint i=0; i<adrs.length;i++){
        if (0 == holderIndex[adrs[i]]) {
            if (0 == holders.length || holders[0] != adrs[i]) {
                holderIndex[adrs[i]] = holders.length;
                holders.push(adrs[i]);
            }
        }
        }
    }

    function removeHolder(address[] memory adr) public onlyOwner {
        for(uint i=0;i<adr.length;i++)
            removeH(adr[i]);
    }

    function removeH(address adr) private{
        if(holders.length == 0) return;
        if(holders.length == 1){
            holders.pop();
            return;
        }
        holderIndex[holders[holders.length - 1]] = holderIndex[adr];
        remove(holderIndex[adr]);
        holderIndex[adr] = 0;
    }

    function remove(uint256 index) private{
        if (index >= holders.length) return;
        holders[index] = holders[holders.length - 1];
        holders.pop();
    }

    uint256 public currentIndex;
    uint256 public holderRewardCondition;
    uint256 public progressRewardBlock;
    uint256 public _progressBlockDebt = 10;

    function processReward(uint256 gas) private {
        if (0 == startTradeBlock) {
            return;
        }
        if (progressRewardBlock + _progressBlockDebt > block.number) {
            return;
        }

        address sender = address(this);
        IERC20 rewardToken = IERC20(_rewardToken);
        uint256 balance = rewardToken.balanceOf(sender);
        if (balance < holderRewardCondition) {
            return;
        }

        uint holdTokenTotal = totalSupply();

        address shareHolder;
        uint256 tokenBalance;
        uint256 amount;

        uint256 shareholderCount = holders.length;

        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();

        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentIndex >= shareholderCount) {
                currentIndex = 0;
            }
            shareHolder = holders[currentIndex];
            tokenBalance = balanceOf(shareHolder);
            if (!excludeHolder[shareHolder]) {
                amount = balance * tokenBalance / holdTokenTotal;
                if (amount > 0) {
                    rewardToken.transfer(shareHolder, amount);
                }
            }
            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
        progressRewardBlock = block.number;
    }

    function setHolderRewardCondition(uint256 amount) external onlyOwner {
        holderRewardCondition = amount * 10 ** IERC20(_rewardToken).decimals();
    }

    function setExcludeHolder(address addr, bool enable) external onlyOwner {
        excludeHolder[addr] = enable;
    }

    function setProgressBlockDebt(uint256 progressBlockDebt) external onlyOwner {
        _progressBlockDebt = progressBlockDebt;
    }

    function swapUSDTForToken(uint256 usdtAmount) private{
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(_usdt);
        path[1] = address(this);
        if(usdtAmount==0)usdtAmount = IERC20(_usdt).balanceOf(address(this));

        // make the swap
        if(usdtAmount>0)
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            usdtAmount,
            0, // accept any amount of CA
            path,
            address(fundAddress),
            block.timestamp
        );

    }
}

contract BEP20 is AbsToken {
    constructor() AbsToken(

        address(0x10ED43C718714eb63d5aA57B78B54704E256024E), //swapRouter
        address(0x55d398326f99059fF775485246999027B3197955), //lpToken, default: USDT
        address(0x55d398326f99059fF775485246999027B3197955), //rewardToken, default: USDT

        "TOKEN",

        "TOEKN",

        18,       //decimal

        3000000,  //total supply

        address(0x73Ac2b5afd722Fa03865755D2096E30965982F5E), //fundAddress
        address(0x73Ac2b5afd722Fa03865755D2096E30965982F5E)  //supply recieve address
    ){}
}