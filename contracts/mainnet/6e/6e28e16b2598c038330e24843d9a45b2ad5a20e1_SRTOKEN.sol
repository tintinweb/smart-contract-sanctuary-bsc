/**
 *Submitted for verification at BscScan.com on 2022-08-15
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.10;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this;
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
        
    }
}

interface IFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

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

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

interface IDataToken {
    function lpRewardOwner() external view returns (address);
    function lpRewardToken() external view returns (address);
    function nodeRewardOwener() external view returns(address);
    function nodeRewardToken() external view returns (address);
    function marketingWalletAddress() external view returns (address);
    function liquidityReceiveAddress() external view returns (address);
    function asLpAddress() external view returns (address);
    function contractAddress() external view returns (address);

    function deadFee() external view returns (uint256);
    function reFee() external view returns (uint256);
    function liquidityFee() external view returns (uint256);
    function lpRewardFee() external view returns (uint256);
    function marketingFee() external view returns (uint256);
    function swapTokensAtAmount() external view returns (uint256);
    function asLpFee() external view returns (uint256);
    function minHolderAmountFee() external view returns (uint256);
    function openState() external view returns (uint256);

    function excludedFromFees(address _addr) external view returns (uint256);
    function wilteAddress(address _addr) external view returns(uint256);
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

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract SRTOKEN is Context, IERC20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _rOwned;
    mapping(address => mapping(address => uint256)) private _allowances;

    IRouter public uniswapV2Router;
    address public uniswapV2Pair;

    string private constant _name = "SR11";
    string private constant _symbol = "SR11";
    uint8 private constant _decimals = 18;
    uint256 private _totalSupply = 210000000 * 10 ** _decimals;
    uint256 private _minSupply = 21000000 * 10 ** _decimals;

    address public deadWallet = 0x000000000000000000000000000000000000dEaD; 

    IDataToken tokenData;
    IERC20 usdtToken;

    bool private swapping;

    uint256 public amountLiquidityFee;  
    uint256 public amountLpRewardFee; 
    uint256 public amountNodeFee;
    uint256 public amountAsLpFee;

    modifier lockTheSwap {
        swapping = true;
        _;
        swapping = false;
    }

    constructor(address _addrData){
        tokenData = IDataToken(_addrData);
        uniswapV2Router = IRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        uniswapV2Pair = IFactory(uniswapV2Router.factory()).createPair(address(this), tokenData.contractAddress());

        usdtToken = IERC20(tokenData.contractAddress());

        _rOwned[owner()] = _totalSupply;
        
        emit Transfer(address(0), owner(), _totalSupply);
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _rOwned[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(amount > 0, "amount error");
        if(tokenData.openState()==1 && (to == uniswapV2Pair || from == uniswapV2Pair) && tokenData.wilteAddress(from)==0){
            require(false ,"Transaction suspension");
        }
        require(balanceOf(from).sub(amount)>= balanceOf(from).div(100),"amount not enough");
        bool canSwap = balanceOf(address(this)) >= tokenData.swapTokensAtAmount();
        if (canSwap && !swapping && from != uniswapV2Pair && tokenData.excludedFromFees(from) == 0 && tokenData.excludedFromFees(to) == 0) {
             _swapAndLiquify(amountLiquidityFee, amountLpRewardFee,amountNodeFee,amountAsLpFee);
        }

        _tokenTransfer(from, to, amount);
    }

    function _tokenTransfer(address from, address to, uint256 amount) private {
        bool takeFee = true;
        if (tokenData.excludedFromFees(from) == 1 || tokenData.excludedFromFees(to) == 1) {
            takeFee = false;
        }
        if(from!= uniswapV2Pair && to!=uniswapV2Pair){
            takeFee = false;
        }
        if (takeFee){
            _rOwned[from] = _rOwned[from].sub(amount);
            amount = takeAllFee(from, amount,to); 
            _rOwned[to] = _rOwned[to].add(amount);
        }else{
            _rOwned[from] = _rOwned[from].sub(amount);
            _rOwned[to] = _rOwned[to].add(amount);
        }

        emit Transfer(from, to, amount);
    }

    function takeAllFee(address from, uint256 amount,address to) private returns(uint256 amountAfter) {
        amountAfter = amount;

        uint256 DFee = amount.mul(tokenData.deadFee()).div(100);
        if(DFee > 0 && _totalSupply > _rOwned[deadWallet].add(_minSupply)) {
            if (_rOwned[deadWallet].add(DFee).add(_minSupply) > _totalSupply){
                DFee = _totalSupply.sub(_rOwned[deadWallet]).sub(_minSupply);
            }

            amountAfter = amountAfter.sub(DFee);
            _rOwned[deadWallet] = _rOwned[deadWallet].add(DFee);
            emit Transfer(from, deadWallet, DFee);
        }

        uint256 MFee = amount.mul(tokenData.marketingFee()).div(100);
        if(MFee > 0) {
            amountAfter = amountAfter.sub(MFee);
            address marketAddress = tokenData.marketingWalletAddress();
            _rOwned[marketAddress] = _rOwned[marketAddress].add(MFee);
            emit Transfer(from, marketAddress, MFee);
        } 


        uint256 LFee = amount.mul(tokenData.liquidityFee()).div(100);
        amountLiquidityFee += LFee;
        amountAfter = amountAfter.sub(LFee);

        uint256 LPFee = amount.mul(tokenData.lpRewardFee()).div(100);
        amountLpRewardFee += LPFee;
        amountAfter = amountAfter.sub(LPFee);

        uint256 ndFee = amount.mul(tokenData.reFee()).div(100);
        amountNodeFee+=ndFee;
        amountAfter = amountAfter.sub(ndFee);
        uint256 asFee = 0;
        if(to == uniswapV2Pair){
            //卖出
            asFee = amount.mul(tokenData.asLpFee()).div(100);
            amountAsLpFee += asFee;
            amountAfter = amountAfter.sub(asFee);
        }

        _rOwned[address(this)] = _rOwned[address(this)].add(LFee).add(LPFee).add(ndFee).add(asFee);
        emit Transfer(from, address(this), LFee.add(LPFee).add(ndFee).add(asFee));
    }

    function _swapAndLiquify(uint256 liquidityTokens, uint256 rewardTokens,uint256 nodeToken,uint256 asLpToken) private lockTheSwap {
        if (rewardTokens > 0){
            _swapTokensForRewardToken(rewardTokens);
            amountLpRewardFee = amountLpRewardFee.sub(rewardTokens);
        }
        if(nodeToken > 0){
            _swapTokensForNodeToken(nodeToken);
            amountNodeFee = amountNodeFee.sub(nodeToken);
        }
        if(asLpToken > 0){
             _swapTokensForAsToken(asLpToken);
            amountAsLpFee = amountAsLpFee.sub(asLpToken);
        }
        
         if (liquidityTokens > 0){
            _swapTokensForUSDT(liquidityTokens);
            amountLiquidityFee = amountLiquidityFee.sub(liquidityTokens);
        }
    }

    function _swapTokensForUSDT(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = tokenData.contractAddress();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            uniswapV2Pair,
            block.timestamp
        );
    }


    function _swapTokensForRewardToken(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = tokenData.lpRewardToken();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(tokenAmount, 0, path, tokenData.lpRewardOwner(), block.timestamp);
    }

    function _swapTokensForNodeToken(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = tokenData.nodeRewardToken();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(tokenAmount, 0, path, tokenData.nodeRewardOwener(), block.timestamp);
    }
    function _swapTokensForAsToken(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = tokenData.nodeRewardToken();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(tokenAmount, 0, path, tokenData.asLpAddress(), block.timestamp);
    }

    receive() external payable {}

    function contractInfo() external view returns (uint256 _deadFee, uint256 _liquidityFee, uint256 _lpRewardFee, uint256 _marketingFee){
        _deadFee = tokenData.deadFee();
        _liquidityFee = tokenData.liquidityFee();


        _lpRewardFee = tokenData.lpRewardFee();
        _marketingFee = tokenData.marketingFee();
    }
}