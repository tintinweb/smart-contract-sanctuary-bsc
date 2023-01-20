/**
 *Submitted for verification at BscScan.com on 2023-01-20
*/

//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
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
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}
library Address {
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }
}
abstract contract Ownable {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }
    function owner() public view returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
interface IPancakeFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);
    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
    function INIT_CODE_PAIR_HASH() external view returns (bytes32);
}
interface IPancakeRouter01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
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
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}
interface IPancakeRouter02 is IPancakeRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}
contract usdtReceiver {
    address private usdt = 0x55d398326f99059fF775485246999027B3197955;//改为主网USDT地址
    constructor() {
        IBEP20(usdt).approve(msg.sender,~uint256(0));
    }
}
contract Rabbitking is Ownable, IBEP20 {
    using SafeMath for uint256;
    using Address for address;
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 internal _totalSupply;

    uint256 public buyFeeToWallet1 = 3;
    uint256 public buyFeeToWallet2 = 0;
    uint256 public buyFeeToInviter = 0;
    uint256 public buyFeeToLpDifidend = 0;
    uint256 public buyFeeToHolders = 0;
    uint256 public buyFeeToPool = 0;

    uint256 public sellFeeToWallet1 = 2;
    uint256 public sellFeeToWallet2 = 0;
    uint256 public sellFeeToInviter = 0;
    uint256 public sellFeeToLpDifidend = 5;
    uint256 public sellFeeToHolders = 0;
    uint256 public sellFeeToPool = 0;

    uint256 public feeToWallet1;
    uint256 public feeToWallet2;
    uint256 public feeToLpDifidend;
    uint256 public feeToHolders;
    uint256 public feeToPool;

    uint256 public minAmountToSwapForWallet = 10;  //分给钱包的手续费累积到这个值时，兑换成USDT转到钱包，可设置，默认10USDT
    uint256 public minAmountToLpDifidend = 100; //同上，累积到默认价值1000USDT的币量时，给LP持有者分红USDT，可设置
    uint256 public minAmountToHolders = 1000; //同上，累积到默认价值1000USDT的币量时，持币者分红USDT，可设置
    uint256 public minAmountToHoldersDifidend = 100;  //持币分红USDT的最低持币数量，可设置，默认为100
    uint256 public minAmountToPool = 100;//同上，累积到默认价值100USDT的币量时，添加流动性，可设置

    bool private isLiquidityAdded;
    address private pancakeRouterAddr = 0x10ED43C718714eb63d5aA57B78B54704E256024E;  //改成主网路由地址
    address private usdt = 0x55d398326f99059fF775485246999027B3197955;   //改成主网usdt地址
    address public wallet1 = 0x0CCE2435a2775D24a36B414139EbF4eA82D7786D; // 钱包1
    address public wallet2 = 0x0CCE2435a2775D24a36B414139EbF4eA82D7786D; // 钱包2
    address public marketing = 0x720Af67a5339e48e2543936b580EB7861AEA976f;  // 营销地址
    address private pair;
    address private lastPotentialLPHolder;
    address[] public tokenHolders;
    address[] public lpHolders;
    mapping (address => uint256) internal _balances;
    mapping (address => mapping (address => uint256)) internal _allowances;
    mapping (address => bool) private _holderIsExist;
    mapping (address => address) public inviter;
    mapping (address => bool) public _isLPHolderExist;
    mapping (address => bool) public isBlackList;
    mapping (address => bool) public exemptFee;
    IPancakeRouter02 private _router;
    usdtReceiver private _usdtReceiver;

    uint private unlocked = 1;
    modifier lock() {
        require(unlocked == 1, 'LOCKED');
        unlocked = 0;
        _;
        unlocked = 1;
    }
    constructor() {
        _name = "Rabbitking";
        _symbol = "Rabbitking";
        _decimals = 18;
        _totalSupply = 2023 * (1e18); 
	    _balances[msg.sender] = _totalSupply;
        tokenHolders.push(msg.sender);
        _holderIsExist[msg.sender] = true;
        exemptFee[msg.sender] = true;
        exemptFee[marketing] = true;
        exemptFee[address(this)] = true;
        _router = IPancakeRouter02(pancakeRouterAddr);
        pair = IPancakeFactory(_router.factory()).createPair(
            address(usdt),
            address(this)
        );
        _usdtReceiver = new usdtReceiver();
        _approve(address(this), address(pancakeRouterAddr), ~uint256(0));
	    emit Transfer(address(0), msg.sender, _totalSupply);  
    }
    function name() public view returns (string memory) {
        return _name;
    }
    function symbol() public view returns (string memory) {
        return _symbol;
    }
    function decimals() public view returns (uint8) {
        return _decimals;
    }
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }
    function transfer(address recipient, uint256 amount) public override  returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
    function allowance(address towner, address spender) public view override returns (uint256) {
        return _allowances[towner][spender];
    }
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        uint256 currentAllowance = _allowances[sender][msg.sender];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, msg.sender, currentAllowance.sub(amount, "BEP20: transfer amount exceeds allowance"));
        return true;
    }
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(!isBlackList[sender], "blacklist users");
        if(sender != pair && recipient != pair && _balances[recipient] == 0 && inviter[recipient] == address(0)) {
            inviter[recipient] = sender;
        }
        if(!isLiquidityAdded && recipient == pair) {
            isLiquidityAdded = true;
            lpHolders.push(sender);
            _isLPHolderExist[sender] = true;
        }
        if(!recipient.isContract() && recipient != address(0) && !_holderIsExist[recipient]) {
            tokenHolders.push(recipient);
            _holderIsExist[recipient] = true;
        }

        uint256 price = tokenPrice();
        if(sender != pair && unlocked == 1 && feeToWallet1.mul(price).div(1e18) > minAmountToSwapForWallet*(1e18)) {
            swapUSDTForWallet(wallet1);
        }
        price = tokenPrice();
        if(sender != pair && unlocked == 1 && feeToWallet2.mul(price).div(1e18) > minAmountToSwapForWallet*(1e18)) {
            swapUSDTForWallet(wallet2);
        }
        price = tokenPrice();
        if(sender != pair && unlocked == 1 && feeToLpDifidend.mul(price).div(1e18) > minAmountToLpDifidend*(1e18)) {
            difidendToLPHolders();
        }
        price = tokenPrice();
        if(sender != pair && unlocked == 1 && feeToHolders.mul(price).div(1e18) > minAmountToHolders*(1e18)) {
            difidendToHolders();
        }
        price = tokenPrice();
        if(sender != pair && unlocked == 1 && feeToPool.mul(price).div(1e18) > minAmountToPool*(1e18)) {
            swapAndLiquify();
        }
        
        uint256 fixFee;
        uint256 unfixFee;
        if(!exemptFee[sender] && !exemptFee[recipient]) {
            if(sender == pair) { // buy
                if(buyFeeToWallet1 > 0) {
                    uint256 feeWallet1 = amount.div(100).mul(buyFeeToWallet1);
                    fixFee = fixFee.add(feeWallet1);
                    feeToWallet1 = feeToWallet1.add(feeWallet1);
                }
                if(buyFeeToWallet2 > 0) {
                    uint256 feeWallet2 = amount.div(100).mul(buyFeeToWallet2);
                    fixFee = fixFee.add(feeWallet2);
                    feeToWallet2 = feeToWallet2.add(feeWallet2);
                }
                if(fixFee > 0) {
                    _balances[address(this)] = _balances[address(this)].add(fixFee);
                    emit Transfer(sender, address(this), fixFee);
                }
                unfixFee = processFee(sender, recipient, amount, buyFeeToInviter, buyFeeToLpDifidend, buyFeeToHolders, buyFeeToPool);
            } else if(recipient == pair) { // sell or addLiquidity
                if(sellFeeToWallet1 > 0) {
                    uint256 feeWallet1 = amount.div(100).mul(sellFeeToWallet1);
                    fixFee = fixFee.add(feeWallet1);
                    feeToWallet1 = feeToWallet1.add(feeWallet1);
                }
                if(sellFeeToWallet2 > 0) {
                    uint256 feeWallet2 = amount.div(100).mul(sellFeeToWallet2);
                    fixFee = fixFee.add(feeWallet2);
                    feeToWallet2 = feeToWallet2.add(feeWallet2);
                }
                if(fixFee > 0) {
                    _balances[address(this)] = _balances[address(this)].add(fixFee);
                    emit Transfer(sender, address(this), fixFee);
                }
                unfixFee = processFee(sender, recipient, amount, sellFeeToInviter, sellFeeToLpDifidend, sellFeeToHolders, sellFeeToPool);
            }
        }   
        uint256 finalAmount = amount.sub(fixFee).sub(unfixFee);
        _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(finalAmount);

        if(lastPotentialLPHolder != address(0) && !_isLPHolderExist[lastPotentialLPHolder]) {
            uint256 lpAmount = IBEP20(pair).balanceOf(lastPotentialLPHolder);
            if(lpAmount > 0) {
                lpHolders.push(lastPotentialLPHolder);
                _isLPHolderExist[lastPotentialLPHolder] = true;
            }
        }
        if(recipient == pair) {
            lastPotentialLPHolder = sender;
        }

        
        emit Transfer(sender, recipient, finalAmount);
    }
    function tokenPrice() private view returns(uint256){
        uint256 tokenAmount = _balances[pair];
        if(tokenAmount == 0) return 0;
        uint256 USDTAmount = IBEP20(usdt).balanceOf(pair);
        return USDTAmount.mul(1e18).div(tokenAmount);

    }
    function processFee(address sender,address recipient,uint256 amount,uint256 feeToInviterPencent,uint256 feeToLpDifidendPencent,uint256 feeToHoldersPencent,uint256 feeToPoolPencent) private returns(uint256) {
        uint256 totalFee;
        if(feeToInviterPencent > 0) {
            uint256 feeAmount = amount.mul(feeToInviterPencent).div(100);
            address cur;
            address to;
            if(sender == pair) {
                cur = recipient;
            } else {
                cur = sender;
            }
            if(inviter[cur] != address(0)) {
                to = inviter[cur];
            } else {
                to = marketing;
            }
            _balances[to] = _balances[to].add(feeAmount);
            totalFee = totalFee.add(feeAmount);
            emit Transfer(sender, to, feeAmount);
        }
        if(feeToLpDifidendPencent > 0) {
            uint256 feeAmount = amount.mul(feeToLpDifidendPencent).div(100);
            feeToLpDifidend = feeToLpDifidend.add(feeAmount);
            _balances[address(this)] = _balances[address(this)].add(feeAmount);
            totalFee = totalFee.add(feeAmount);
            emit Transfer(sender, address(this), feeAmount);
        }
        if(feeToHoldersPencent > 0) {
            uint256 feeAmount = amount.mul(feeToHoldersPencent).div(100);
            feeToHolders = feeToHolders.add(feeAmount);
            _balances[address(this)] = _balances[address(this)].add(feeAmount);
            totalFee = totalFee.add(feeAmount);
            emit Transfer(sender, address(this), feeAmount);
        }
        if(feeToPoolPencent > 0) {
            uint256 feeAmount = amount.mul(feeToPoolPencent).div(100);
            feeToPool = feeToPool.add(feeAmount);
            _balances[address(this)] = _balances[address(this)].add(feeAmount);
            totalFee = totalFee.add(feeAmount);
            emit Transfer(sender, address(this), feeAmount);
        }
        return totalFee;
    }
    function swapUSDTForWallet(address wallet) private lock{
        uint256 amount;
        if(wallet == wallet1) {
            amount = feeToWallet1;
        } else {
            amount = feeToWallet2;
        }
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = usdt;
        _router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amount,
            0,
            path,
            wallet,
            block.timestamp
        );
        if(wallet == wallet1) {
            feeToWallet1 = 0;
        } else {
            feeToWallet2 = 0;
        }
    }
    function swapUSDTForThis(bool flag) private returns (uint256){ //flag为true时分红给LP Holders,为false时分给持币人
        uint256 amount;
        if(flag) {
            amount = feeToLpDifidend;
        } else {
            amount = feeToHolders;
        }
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = usdt;
        uint256 presentBalance = IBEP20(usdt).balanceOf(address(_usdtReceiver));
        _router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amount,
            0,
            path,
            address(_usdtReceiver),
            block.timestamp
        );
        if(flag) {
            feeToLpDifidend = 0;
        } else {
            feeToHolders = 0;
        }
        uint256 receivedUSDT = (IBEP20(usdt).balanceOf(address(_usdtReceiver))).sub(presentBalance);
        return receivedUSDT;
    }
    function difidendToLPHolders() private lock {
        uint256 totalLPAmount = IBEP20(pair).totalSupply() - 1000;
        uint256 totalReward = swapUSDTForThis(true);
        for(uint256 i = 0; i < lpHolders.length; i++){
            uint256 LPAmount = IBEP20(pair).balanceOf(lpHolders[i]);
            if( LPAmount > 0) {
                uint256 reward = totalReward.mul(LPAmount).div(totalLPAmount);
                if(reward < 0) continue;
                IBEP20(usdt).transferFrom(address(_usdtReceiver),lpHolders[i], reward);
            }
        }
    }
    function difidendToHolders() private lock {
        uint256 totalReward = swapUSDTForThis(false);
        for(uint256 i = 0; i < tokenHolders.length; i++){
            uint256 holdersAmount = _balances[tokenHolders[i]];
            if( holdersAmount > minAmountToHoldersDifidend) {
                uint256 reward = totalReward.mul(holdersAmount).div(_totalSupply);
                if(reward < 0) continue;
                IBEP20(usdt).transferFrom(address(_usdtReceiver),tokenHolders[i], reward);
            }
        }
    }
    function swapAndLiquify() private lock {
        uint256 half = feeToPool.div(2);
        uint256 otherHalf = feeToPool.sub(half);
        uint256 initialBalance = IBEP20(usdt).balanceOf(address(_usdtReceiver));
        swapTokensForLiquidity(half); 
        uint256 newBalance = (IBEP20(usdt).balanceOf(address(_usdtReceiver))).sub(initialBalance);
        IBEP20(usdt).transferFrom(address(_usdtReceiver),address(this), newBalance);
        IBEP20(usdt).approve(pancakeRouterAddr,~uint256(0));
        _router.addLiquidity(address(this), usdt, otherHalf, newBalance, 0, 0, marketing, block.timestamp);
        feeToPool = 0;
    }
    function swapTokensForLiquidity(uint256 amount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = usdt;
        _router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amount,
            0,
            path,
            address(_usdtReceiver),
            block.timestamp
        );
    }
    function claimLeftUSDT() external onlyOwner { //如果合约身上有剩余的USDT，提取到营销地址
        uint256 left = IBEP20(usdt).balanceOf(address(_usdtReceiver));
        IBEP20(usdt).transferFrom(address(_usdtReceiver), marketing, left);
    }
    function setMinAmountToSwapForWallet(uint256 value) external onlyOwner() { 
        //分给钱包的手续费累积到这个值时，兑换成USDT转到钱包，可设置，默认10USDT,单位为USDT,不要18个0，例如设置20USDT才分，则value传入20，下面的类似
        minAmountToSwapForWallet = value;
    }
    function setMinAmountToLpDifidend(uint256 value) external onlyOwner() { 
        minAmountToLpDifidend = value;
    }
    function setMinAmountToHolders(uint256 value) external onlyOwner() { 
        minAmountToHolders = value;
    }
    function setMinAmountToHoldersDifidend(uint256 value) external onlyOwner() { 
        minAmountToHoldersDifidend = value;
    }
    function setMinAmountToPool(uint256 value) external onlyOwner() { 
        minAmountToPool = value;
    }
    function setBuyFeeToInviter(uint256 value) external onlyOwner() { 
        buyFeeToInviter = value;
    }
    function setBuyFeeToLpDifidend(uint256 value) external onlyOwner() { 
        buyFeeToLpDifidend = value;
    }
    function setBuyFeeToHolders(uint256 value) external onlyOwner() { 
        buyFeeToHolders = value;
    }
    function setBuyFeeToPool(uint256 value) external onlyOwner() { 
        buyFeeToPool = value;
    }
    function setSellFeeToInviter(uint256 value) external onlyOwner() { 
        sellFeeToInviter = value;
    }
    function setSellFeeToLpDifidend(uint256 value) external onlyOwner() { 
        sellFeeToLpDifidend = value;
    }
    function setSellFeeToHolders(uint256 value) external onlyOwner() { 
        sellFeeToHolders = value;
    }
    function setSellFeeToPool(uint256 value) external onlyOwner() { 
        sellFeeToPool = value;
    }
    function addBlackList(address account, bool flag) external onlyOwner() { //加入黑名单
        isBlackList[account] = flag;
    }
    function setExemptFee(address account, bool flag) external onlyOwner() { //设置免手续费
        exemptFee[account] = flag;
    }
    function setNewWallet1(address account) external onlyOwner() { //设置钱包1的新地址
        wallet1 = account;
    }
    function setNewWallet2(address account) external onlyOwner() { //设置钱包2的新地址
        wallet2 = account;
    }
    function setBuyFeeToWallet1(uint256 value) external onlyOwner() { //设置到钱包1的买入手续费
        buyFeeToWallet1 = value;
    }
    function setBuyFeeToWallet2(uint256 value) external onlyOwner() { //设置到钱包2的买入手续费
        buyFeeToWallet2 = value;
    }
    function setSellFeeToWallet1(uint256 value) external onlyOwner() { //设置到钱包1的卖出手续费
        sellFeeToWallet1 = value;
    }
    function setSellFeeToWallet2(uint256 value) external onlyOwner() { //设置到钱包2的卖出手续费
        sellFeeToWallet2 = value;
    }
}