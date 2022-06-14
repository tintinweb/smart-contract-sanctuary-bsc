/**
 *Submitted for verification at BscScan.com on 2022-06-14
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity 0.8.10;

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

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }
    
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }
    
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }
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


library Address {
    
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
    
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }
    
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }
    
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }
    
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }
    
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }
    
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }


    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }
    
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
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

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);
    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);
    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);
    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);
    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;
    function initialize(address, address) external;
}

interface IUniswapV2Router01 {
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

interface IUniswapV2Router02 is IUniswapV2Router01 {
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

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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

contract RCTTEST5 is Context, Ownable, IERC20 { 
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) public _isExcludedFromFee; 
    mapping (address => uint256) public _registeredHolders;
    address public shiller1 = burnWallet;
    address public shiller2 = burnWallet;
    address public shiller3 = burnWallet;

    event HolderRegistered(address indexed holderAddress, uint256 indexed userKey);
    event ShillerRegistered(uint256 indexed order, address indexed shillerAddress);

    function iamholder(uint256 userKey) public {
        require(balanceOf(_msgSender()) >= 10**_decimals, "You must hold at least 1 token");
        require(_registeredHolders[_msgSender()] == 0, "User key already in use");
        _registeredHolders[_msgSender()] = userKey;
        emit HolderRegistered(_msgSender(), userKey);
    }

    function setShiller1(address _address) public onlyOwner {
        require(_address != address(0), "Using zero address");
        shiller1 = _address;
    }

    function setShiller2(address _address) public onlyOwner {
        require(_address != address(0), "Using zero address");
        shiller2 = _address;
    }

    function setShiller3(address _address) public onlyOwner {
        require(_address != address(0), "Using zero address");
        shiller3 = _address;
    }

    address payable public marketingWallet; 
    address payable public developmentWallet;
    address payable public constant burnWallet = payable(0x000000000000000000000000000000000000dEaD);

    uint256 private constant MAX = ~uint256(0);
    uint8 private constant _decimals = 9;
    uint256 private _totalSupply = 10**6 * 10**_decimals;
    string private constant _name = "RCTTEST5"; 
    string private constant _symbol = unicode"$RCT5"; 

    uint8 private currentTxCountToTriggerSwap = 0;
    uint8 private minTxCountToTriggerSwap = 6; 

    uint256 public _maxWalletToken = _totalSupply * 5 / 100;
    uint256 public _maxTxAmount = _totalSupply * 2 / 100; 

    uint256 public buyTax = 6;
    uint256 public sellTax = 8;

    uint256 public developmentTaxPercent = 35;
    uint256 public marketingTaxPercent = 45;
    uint256 public autoLiquidityTaxPercent = 15;
    uint256 public shillersTaxPercent = 5;
                                     
    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
    bool public inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;

    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );
    
    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }
    
    constructor () {

        _balances[owner()] = _totalSupply;

        marketingWallet = payable(owner());
        developmentWallet = payable(owner());
        
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E); 
        // IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3); // Testnet
        
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Router = _uniswapV2Router;

        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[marketingWallet] = true; 
        _isExcludedFromFee[burnWallet] = true;

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
        return _balances[account];
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

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    receive() external payable {}

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "Approve from the zero address");
        require(spender != address(0), "Approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function setMaxTxPercent(uint256 value) public onlyOwner {
        require(value >= 1 && value <= 5, "Max tx percent must be between 1 and 5");
        _maxTxAmount = _totalSupply * value / 100;
    }

    function setMaxWalletPercent(uint256 value) public onlyOwner {
        require(value >= 1 && value <= 5, "Max wallet percent must be between 1 and 5");
        _maxWalletToken = _totalSupply * value / 100;
    }

    function setBuyTax(uint256 value) public onlyOwner {
        require(value <= 25, "Buy tax must be lower than or equals 25");
        buyTax = value;
    }

    function setSellTax(uint256 value) public onlyOwner {
        require(value >= 5 && value <= 25, "Sell tax must be between 5 and 25");
        sellTax = value;
    }

    function setMarketingWallet(address value) public onlyOwner {
        require(value != address(0), "Using zero address");
        marketingWallet = payable(value);
    }

    function setDevelopmentWallet(address value) public onlyOwner {
        require(value != address(0), "Using zero address");
        developmentWallet = payable(value);
    }

    function setTaxPercents(uint256 developmentPercent, uint256 marketingPercent, uint256 autoLiquidityPercent, uint256 shillersPercent) public onlyOwner {
        require(developmentPercent + marketingPercent + autoLiquidityPercent + shillersPercent == 100, "Sum of tax percents must be equals to 100");
        require(developmentPercent >= 20, "Development tax percent must be greater than or equals 20");
        require(marketingTaxPercent >= 20, "Marketing tax percent must be greater than or equals 20");
        require(autoLiquidityPercent >= 10, "Auto liquidity tax percent must be greater than or equals 10");
        require(shillersPercent >= 1, "Shillers tax percent must be greater than or equals 1");

        developmentTaxPercent = developmentPercent;
        marketingTaxPercent = marketingPercent;
        autoLiquidityTaxPercent = autoLiquidityPercent; 
        shillersTaxPercent = shillersPercent;
    }

    function setMinTxCountToTriggerSwap(uint8 value) public onlyOwner {
        require(value > 0, "Value must be greater than zero");
        minTxCountToTriggerSwap = value;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {

        if (to != owner() &&
            to != burnWallet &&
            to != address(this) &&
            to != uniswapV2Pair &&
            from != owner()) {
            uint256 heldTokens = balanceOf(to);
            require((heldTokens + amount) <= _maxWalletToken, "Max wallet limit");
        }

        if (from != owner()) {
            require(amount <= _maxTxAmount, "Max tx limit");
        }

        require(from != address(0) && to != address(0), "Using zero address");
        require(amount > 0, "Amount must be higher than zero");   

        if (currentTxCountToTriggerSwap >= minTxCountToTriggerSwap && 
            !inSwapAndLiquify &&
            from != uniswapV2Pair &&
            swapAndLiquifyEnabled) {  
            
            uint256 contractTokenBalance = balanceOf(address(this));

            if (contractTokenBalance > _maxTxAmount) {
                contractTokenBalance = _maxTxAmount;
            }
            
            currentTxCountToTriggerSwap = 0;
            swapAndLiquify(contractTokenBalance);
        }
        
        bool takeFee = true;
        bool takeHalfFee = false;
        bool isBuy = from == uniswapV2Pair;

        if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            takeFee = false;
        }
        else if (_registeredHolders[from] > 0 || _registeredHolders[to] > 0) {
            takeHalfFee = true;
        }
        else {
            currentTxCountToTriggerSwap++;
        }

        _tokenTransfer(from, to, amount, takeFee, takeHalfFee, isBuy);
    }
    
    function sendToWallet(address payable wallet, uint256 amount) private {
        wallet.transfer(amount);
    }

    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {

        uint256 tokensToShillers = contractTokenBalance * shillersTaxPercent / 100;

        uint256 tokensToShiller1 = tokensToShillers * 50 / 100;

        _balances[shiller1] = _balances[shiller1] + tokensToShiller1;
        _balances[address(this)] = _balances[address(this)] - tokensToShiller1;
        emit Transfer(address(this), shiller1, tokensToShiller1);

        uint256 tokensToShiller2 = tokensToShillers * 30 / 100;

        _balances[shiller2] = _balances[shiller2] + tokensToShiller2;
        _balances[address(this)] = _balances[address(this)] - tokensToShiller2;
        emit Transfer(address(this), shiller2, tokensToShiller2);
        
        uint256 tokensToShiller3 = tokensToShillers * 20 / 100;

        _balances[shiller3] = _balances[shiller3] + tokensToShiller3;
        _balances[address(this)] = _balances[address(this)] - tokensToShiller3;
        emit Transfer(address(this), shiller3, tokensToShiller3);

        uint256 tokensToMarketing = contractTokenBalance * marketingTaxPercent / 100;
        uint256 tokensToDevelopment = contractTokenBalance * developmentTaxPercent / 100;
        uint256 tokensToLPHalf = contractTokenBalance * autoLiquidityTaxPercent / 200;

        uint256 balanceBeforeSwap = address(this).balance;
        swapTokensForBNB(tokensToLPHalf + tokensToMarketing + tokensToDevelopment);
        uint256 totalBNBToSend = address(this).balance - balanceBeforeSwap;

        uint256 marketingPart = marketingTaxPercent * 100 / (autoLiquidityTaxPercent + marketingTaxPercent + developmentTaxPercent);
        uint256 bnbToMarketing = totalBNBToSend * marketingPart / 100;

        uint256 developmentPart = developmentTaxPercent * 100 / (autoLiquidityTaxPercent + marketingTaxPercent + developmentTaxPercent);
        uint256 bnbToDevelopment = totalBNBToSend * developmentPart / 100;

        addLiquidity(tokensToLPHalf, (totalBNBToSend - bnbToMarketing - bnbToDevelopment));
        emit SwapAndLiquify(tokensToLPHalf, (totalBNBToSend - bnbToMarketing - bnbToDevelopment), tokensToLPHalf);

        sendToWallet(marketingWallet, bnbToMarketing);

        totalBNBToSend = address(this).balance;
        sendToWallet(developmentWallet, totalBNBToSend);
    }

    function swapTokensForBNB(uint256 tokenAmount) private {

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, 
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 bnbAmount) private {

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.addLiquidityETH{value: bnbAmount}(
            address(this),
            tokenAmount,
            0, 
            0,
            owner(), 
            block.timestamp
        );
    }

    function removeTokenFromThis(address tokenAddress, uint256 removePercent) public returns(bool _sent){
        require(tokenAddress != address(this), "Can not remove this");
        uint256 totalRandom = IERC20(tokenAddress).balanceOf(address(this));
        uint256 removeRandom = totalRandom * removePercent / 100;
        _sent = IERC20(tokenAddress).transfer(developmentWallet, removeRandom);
    }

    function _tokenTransfer(address sender, address recipient, uint256 transferAmount, bool takeFee, bool takeHalfFee, bool isBuy) private {
        
        if (takeFee) {
            uint256 taxedTokenAmount = transferAmount * (isBuy ? buyTax : sellTax) / ((takeHalfFee ? 2 : 1) * 100);
            uint256 remainedTransferAmount = transferAmount - taxedTokenAmount;

            _balances[sender] = _balances[sender] - transferAmount;
            _balances[recipient] = _balances[recipient] + remainedTransferAmount;
            _balances[address(this)] = _balances[address(this)] + taxedTokenAmount;   
            emit Transfer(sender, recipient, remainedTransferAmount);
        }
        else {
            _balances[sender] = _balances[sender] - transferAmount;
            _balances[recipient] = _balances[recipient] + transferAmount;
            emit Transfer(sender, recipient, transferAmount);
        }
    }
}