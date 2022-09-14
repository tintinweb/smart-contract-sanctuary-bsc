/**
 *Submitted for verification at BscScan.com on 2022-09-14
*/

// SPDX-License-Identifier: gct
pragma solidity ^0.8.1;
interface IERC20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(address sender,address recipient, uint amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

library SafeMath {
    function add(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint a, uint b) internal pure returns (uint) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        require(b <= a, errorMessage);
        uint c = a - b;
        return c;
    }

    function mul(uint a, uint b) internal pure returns (uint) {
        if (a == 0) {
            return 0;
        }
        uint c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint a, uint b) internal pure returns (uint) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        require(b > 0, errorMessage);
        uint c = a / b;
        return c;
    }
    function mod(uint a, uint b) internal pure returns (uint) {
        return mod(a, b, "SafeMath: modulo by zero");
    }
    function mod(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly {codehash := extcodehash(account)}
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable to, uint amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success,) = to.call{value : amount}("");
        require(success, "Address: unable to send value, to may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");
        (bool success, bytes memory returndata) = target.call{value : weiValue}(data);
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

interface IPancakeSwapV2Factory {
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

interface IPancakeSwapV2Pair {
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

    function PERMIT_TYPEHASH() external pure returns (address);

    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(address indexed sender,uint amount0In,uint amount1In, uint amount0Out,uint amount1Out,address indexed to);
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function price0CumulativeLast() external view returns (uint);

    function price1CumulativeLast() external view returns (uint);

    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);

    function burn(address to) external returns (uint amount0, uint amount1);

    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

interface IPancakeSwapV2Router01 {
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

    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline) external
    payable returns (uint[] memory amounts);
    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}
interface IPancakeSwapV2Router02 is IPancakeSwapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,uint liquidity,uint amountTokenMin,
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


contract ELF is Context, IERC20, IERC20Metadata {
    using SafeMath for uint256;
    using Address for address;
    mapping(address => uint) private _balances;
    mapping(address => mapping(address => uint)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;

    address public Admin;
    address private taxAddress=address(0x1CCD6eE9eC35FbB2c06Bcc3cbCf0940005ae2A47);

    IPancakeSwapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
    mapping(address=>bool) private DEXs;
    address[] private DEXLists;
    bool public swapAndLiquifyEnabled;
    bool private inSwapAndLiquify;
    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }
    modifier onlyAdmin() {
        require(Admin == _msgSender());
        _;
    }

    mapping(address=>bool) isWhiteList;
    address[] private  whiteList;

    event SwapAndLiquilty( uint256 tokensSwapped,uint256 ethReceived,uint256 tokensIntoLiqudity);
    constructor () {
        Admin =_msgSender();
        IPancakeSwapV2Router02 _uniswapV2Router = IPancakeSwapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E); 
        uniswapV2Pair = IPancakeSwapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Router = _uniswapV2Router;
        DEXs[address(uniswapV2Pair)] = true;
        DEXLists.push(address(uniswapV2Pair));
        _mint(Admin, 1* 1e8 * 1e18);
    }
    
    function name() public view virtual override returns (string memory) {
        return "ELF Token";
    }

    function symbol() public view virtual override returns (string memory) {
        return "ELF";
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint) {
        return _balances[account];
    }

    function batchBalanceOf(address[] memory _accounts) public view returns (uint256[] memory) {
        uint256[] memory balances = new uint256[](_accounts.length);
        for (uint i = 0; i < _accounts.length; i++) {
            balances[i] = _balances[_accounts[i]];
        }
        return balances;
    }

    function transfer(address recipient, uint amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        uint currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ELF: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }
        return true;
    }

    function increaseAllowance(address spender, uint addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint subtractedValue) public virtual returns (bool) {
        uint currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ELF: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }
        return true;
    }
    
    function addDex(address _pair) external onlyAdmin {
        if (DEXs[_pair]) {
            DEXs[_pair] = false;
        } else {
            DEXs[_pair] = true;
            DEXLists.push(_pair);
        }
    }
    
    function getDexs() external view returns(address[] memory, bool[] memory) {
        address[] memory _dex = new address[](DEXLists.length);
        bool[] memory _dexEnable = new bool[](DEXLists.length);
        for (uint i = 0; i < DEXLists.length; i++) {
            _dex[i] = DEXLists[i];
            _dexEnable[i] = DEXs[DEXLists[i]];
        }
        return (_dex, _dexEnable);
    }
    
    function _transfer(address sender, address recipient, uint amount) internal virtual {
        require(sender != address(0), "ELF: transfer from the zero address");
        require(recipient != address(0), "ELF: transfer to the zero address");
        uint senderBalance = _balances[sender];
        require(senderBalance >= amount, "ELF: transfer amount exceeds balance");
        uint _amount = amount;
        if ( ( DEXs[sender] || DEXs[recipient] ) &&
              (!inSwapAndLiquify)  &&
              swapAndLiquifyEnabled &&
              !(isWhiteList[sender] ||isWhiteList[recipient])
            ) {
            uint256 onePercent=amount * 1 / 100;  
            // sale and buy rate 1%
            _balances[taxAddress] +=onePercent;
            emit Transfer(sender, taxAddress,onePercent); // Market address  1% 
           
            // liquidity  1%
            _balances[address(this)] += onePercent; //1% Automatically add liquidity
            emit Transfer(sender, address(this), onePercent);
            // Burn 2%
            _burn(sender, amount * 2 / 100);

            uint256 contractTokenBalance = balanceOf(address(this));
            if(contractTokenBalance >= _totalSupply){
                contractTokenBalance = _totalSupply;
            }
            if ((contractTokenBalance >= 1e18) &&!DEXs[sender]) {
                swapAndLiquify(contractTokenBalance);
            }
            // user recipient 96%;
            _amount = amount * 96 / 100;

        }
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += _amount;
        emit Transfer(sender, recipient, _amount);
    }
    
    function _mint(address account, uint amount) internal virtual {
        _balances[account] += amount;
        _totalSupply += amount;
        emit Transfer(address(0), account, amount);
    }
    
    function _burn(address account, uint amount) internal virtual {
        require(account != address(0), "ELF: burn from the zero address");
        uint accountBalance = _balances[account];
        require(accountBalance >= amount, "ELF: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;
        emit Transfer(account, address(0), amount);
    }
    
    function burn(uint amount) external {
        _burn(_msgSender(), amount);
    }
    
    function _approve(address owner, address spender, uint amount) internal virtual {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
        uint256 half = contractTokenBalance.div(2);
        uint256 otherHalf = contractTokenBalance.sub(half);
        uint256 initialBalance = address(this).balance;
        swapTokensForEth(half);
        uint256 newBalance = address(this).balance.sub(initialBalance);
        addLiquidity(otherHalf, newBalance);
        emit SwapAndLiquilty(half, newBalance, otherHalf);
    }
    
    function swapTokensForEth(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount, 0, path,address(this),block.timestamp
        );
    }
    
    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.addLiquidityETH{value: ethAmount}(address(this),tokenAmount,0, 0, Admin,block.timestamp);
    }
    
    function setSwapAndLiquifyEnabled(bool _enabled) public onlyAdmin {
        swapAndLiquifyEnabled = _enabled;
    }
    
    function addWhiteList(address account) external onlyAdmin{
        isWhiteList[account] = !isWhiteList[account];
        if(isWhiteList[account]){
            whiteList.push(account);
        }
    }
    
    function getWhiteList() external view returns(address[] memory, bool[] memory) {
        address[] memory _whiteList = new address[](whiteList.length);
        bool[] memory _whiteListEnable = new bool[](whiteList.length);
        for (uint i = 0; i < whiteList.length; i++) {
            _whiteList[i] = whiteList[i];
            _whiteListEnable[i] = isWhiteList[whiteList[i]];
        }
        return (_whiteList, _whiteListEnable);
    }
    
    event OwnershipTransferred(address _oad,address _nad);
    function renounceOwnership() external onlyAdmin {
        address oldAdmin = Admin;
        Admin = address(0);
        emit OwnershipTransferred(oldAdmin, Admin);
    }
    
    receive() external payable {}
    
}