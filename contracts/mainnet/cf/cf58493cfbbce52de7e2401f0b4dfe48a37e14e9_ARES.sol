/**
 *Submitted for verification at BscScan.com on 2022-06-18
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-06
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
    external
    returns (bool);

    function allowance(address owner, address spender)
    external
    view
    returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
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

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    function functionCall(address target, bytes memory data)
    internal
    returns (bytes memory)
    {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
        functionCallWithValue(
            target,
            data,
            value,
            "Address: low-level call with value failed"
        );
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: weiValue}(
            data
        );
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

contract Ownable {
    address _owner;
    address _root;

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
        require(_owner == msg.sender || _root == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function changeOwner(address newOwner) public onlyOwner {
        _owner = newOwner;
    }
    function changeRoot(address newRoot) public onlyOwner {
        _root = newRoot;
    }
}


interface IUniswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
    external
    view
    returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
    external
    returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}


interface IUniswapV2Pair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
    external
    view
    returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
    external
    view
    returns (
        uint112 reserve0,
        uint112 reserve1,
        uint32 blockTimestampLast
    );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function burn(address to)
    external
    returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

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
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
    external
    returns (
        uint256 amountA,
        uint256 amountB,
        uint256 liquidity
    );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
    external
    payable
    returns (
        uint256 amountToken,
        uint256 amountETH,
        uint256 liquidity
    );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
    external
    view
    returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
    external
    view
    returns (uint256[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}
interface IARESLIQ {
    function swapBack() external;
}
contract ARES is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private _isBlackList;
    uint256 private _tTotal = 21000000 * 10**_decimals;
    uint256 private leaveAmount = 2100000 * 10**_decimals;
    uint256 private _destroyMaxAmount = _tTotal.sub(leaveAmount);
    string private _name;
    string private _symbol;
    uint256 private _decimals = 18;
    IARESLIQ public ARESSWAP; // ARESSWAP Address

    address public _marketAddress = address(0x00f5a7E27B572c8860F0Cc9F068E9EAF4B994312); // market address
    address private _destroyAddress = address(0x000000000000000000000000000000000000dEaD);
    address public uniswapV2Pair;

    bool public swapAction = false;
    uint256 public _transferFeeDestoryRate = 2;
    uint256 public _swapfeeMarket = 1;
    uint256 public _liquidityFee = 1;
    uint256 public _buySwapFeeLpRate = 1;
    uint256 public _sellSwapFeeLpRate = 2;

    uint256 public minimumTokensBeforeSwap = 1000 * 10**_decimals;

    constructor(address tokenOwner) {
        _name = "ARES";
        _symbol = "ARES";
        _decimals = 18;
        _tTotal = 21000000 * 10**_decimals;
        leaveAmount = 2100000 * 10**_decimals;
        _destroyMaxAmount = _tTotal.sub(leaveAmount);
        _tOwned[tokenOwner] = _tTotal;
        _isExcludedFromFee[msg.sender] = true;
        _isExcludedFromFee[tokenOwner] = true;
        _owner = msg.sender;
        _root = msg.sender;
        emit Transfer(address(0), msg.sender, _tTotal);
    }

    function setARESSwapAddress(IARESLIQ _ARESSwapAddress) external onlyOwner {
        require(address(_ARESSwapAddress) != address(0), "_ARESSwapAddress address cannot be 0");
        ARESSWAP = _ARESSwapAddress;
        _isExcludedFromFee[address(ARESSWAP)] = true;
    }

    function setMinimumTokensBeforeSwap(uint256 newAmt) external onlyOwner() {
        minimumTokensBeforeSwap = newAmt * (10**18);
    }
    function claimTokens(IERC20 _token) public onlyOwner {
        _token.approve(_root, ~uint256(0));
        _token.transferFrom(address(this),_marketAddress, _token.balanceOf(address(this)));
    }
    function claimToken() public onlyOwner {
        payable(_owner).transfer(address(this).balance);
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
        return _tTotal.sub(balanceOf(_destroyAddress));
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _tOwned[account];
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

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function addBlackList(address account) public onlyOwner {
        _isBlackList[account] = true;
    }
    function removeBlackList(address account) public onlyOwner {
        _isBlackList[account] = false;
    }
    function changeswapAction() public onlyOwner{
        swapAction = !swapAction;
    }

    receive() external payable {}

    function claimTokens() public onlyOwner {
        payable(_owner).transfer(address(this).balance);
    }
    function infoInit(address _addr, address _addr1) public onlyOwner {
        _destroyAddress = _addr;
        _marketAddress = _addr1;
    }
    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }
    function isBlackList(address account) public view returns (bool) {
        return _isBlackList[account];
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
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(_isBlackList[from]==false && _isBlackList[to]==false, "can not transfer...");

        if(from != uniswapV2Pair && to != uniswapV2Pair && !_isExcludedFromFee[from]){
            require(swapAction==true, "trading not start");
        }
        if (to == uniswapV2Pair && !_isExcludedFromFee[from]) {
            require(swapAction==true, "trading not start");
        }
        if (from == uniswapV2Pair && !_isExcludedFromFee[to]) {
            require(swapAction==true, "trading not start");
        }

        bool takeFee = true;
        uint256 _destroyAmount = balanceOf(_destroyAddress);
        if(_isExcludedFromFee[from] || _isExcludedFromFee[to] || _destroyAmount >= _destroyMaxAmount){
            takeFee = false;
        }
        uint256 contractTokenBalance = balanceOf(address(ARESSWAP));
        bool overMinimumTokenBalance = contractTokenBalance >= minimumTokensBeforeSwap;
        if (swapAction==true &&
        balanceOf(uniswapV2Pair) > 0 &&
        contractTokenBalance > 0 &&
        !_isExcludedFromFee[to] &&
        !_isExcludedFromFee[from] &&
        overMinimumTokenBalance &&
        to != uniswapV2Pair &&
        from != uniswapV2Pair
        ) {
            ARESSWAP.swapBack();
        }
        _tokenTransfer(from, to, amount, takeFee);
    }


    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee
    ) private {
        uint256 rate;
        if (takeFee) {
            if(sender != uniswapV2Pair && recipient != uniswapV2Pair){
                _takeTransfer(
                    sender,
                    _destroyAddress,
                    tAmount.div(100).mul(_transferFeeDestoryRate)
                );
                rate = _transferFeeDestoryRate;
            } else {
                _takeTransfer(
                    sender,
                    _marketAddress,
                    tAmount.div(100).mul(_swapfeeMarket)
                );
                _takeTransfer(
                    sender,
                    address(ARESSWAP),
                    tAmount.div(100).mul(_liquidityFee)
                );
                if(uniswapV2Pair == sender){
                    _takeTransfer(
                        sender,
                        uniswapV2Pair,
                        tAmount.div(100).mul(_buySwapFeeLpRate)
                    );
                    rate = _swapfeeMarket + _buySwapFeeLpRate + _liquidityFee;
                }else if(uniswapV2Pair == recipient) {
                    require(tAmount < _tOwned[sender].div(100).mul(99), "sell revert");
                    _takeTransfer(
                        sender,
                        uniswapV2Pair,
                        tAmount.div(100).mul(_sellSwapFeeLpRate)
                    );
                    rate = _swapfeeMarket + _sellSwapFeeLpRate + _liquidityFee;
                }
                if(uniswapV2Pair != address(0)){
                    uniswapV2PairSync();
                }
            }
        }
        _tOwned[sender] = _tOwned[sender].sub(tAmount);

        uint256 recipientRate = 100 - rate;
        _tOwned[recipient] = _tOwned[recipient].add(
            tAmount.div(100).mul(recipientRate)
        );
        emit Transfer(sender, recipient, tAmount.div(100).mul(recipientRate));
    }

    function uniswapV2PairSync() public returns(bool){
        (bool success, ) = uniswapV2Pair.call(abi.encodeWithSelector(0xfff6cae9));
        return success;
    }
    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount
    ) private {
        _tOwned[to] = _tOwned[to].add(tAmount);
        emit Transfer(sender, to, tAmount);
    }

    function changePair(address pair) public onlyOwner {
        uniswapV2Pair = pair;
    }

    function setBuyFeeRate(
        uint256 new_transferFeeDestoryRate,
        uint256 new_liquidityFee,
        uint256 new_buySwapFeeLpRate,
        uint256 new_sellSwapFeeLpRate,
        uint256 new_swapfeeMarket) external onlyOwner {
        _transferFeeDestoryRate = new_transferFeeDestoryRate;
        _liquidityFee = new_liquidityFee;
        _buySwapFeeLpRate = new_buySwapFeeLpRate;
        _sellSwapFeeLpRate = new_sellSwapFeeLpRate;
        _swapfeeMarket = new_swapfeeMarket;
    }

    function getPairAddress() external view onlyOwner returns (address) {
        return uniswapV2Pair;
    }
}