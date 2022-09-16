/**
 *Submitted for verification at BscScan.com on 2022-09-16
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.17;

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

contract FMTOKEN is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 private _totalSupply;

    mapping (address => uint256) _balances;
    mapping (address => uint256) pollAmount;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) private isExcludedFromFee;
    mapping (address => bool) private isMarketPair;
    mapping (address => bool) private isPoolAddress;

    address[] pollAddress;
    address public uniswapPair;
    IUniswapV2Router02 public uniswapV2Router;
    mapping (address => uint8) private usdtWay;

    address private newPollAddress;

    address publicOffer;
    address mining;
    address marketValue;

    address shibToken;
    address shibAddress;
    address gameToken;

    mapping (address => address[]) spreads;

    uint256 private minToSwap = 13000000;
    uint256 private lowBalance = 900000000000;
    uint256 public swaptype = 3;

    event getReservesData(
        uint112 reserve0,
        uint112 reserve1,
        uint256 pollBnb,
        uint long,
        uint256 msgvalue
    );

    constructor (
        address _owner,
        address _shibToken,
        address _router
    ) payable {
        _name = "FM Token";
        _symbol = "FM";
        _decimals = 6;
        _totalSupply = 100000000 * 10 ** _decimals;

        shibToken = _shibToken;

        owner = payable(_owner);
        publicOffer = payable(0x7de13E9944cb68E54CDC82350908748fDe9d6d34);
        mining = payable(0x22de6716A6830824e0c720Fd55e4F5D2D1e89DB7);
        marketValue = payable(0x77C76f8EABB7F492a13269F7AAAc9Df513494ee4);
        shibAddress = payable(0x068a2913B10dD688C80FC94F73b1df25f4f82cE4);

        isExcludedFromFee[owner] = true;
        isExcludedFromFee[address(this)] = true;
        isExcludedFromFee[publicOffer] = true;
        isExcludedFromFee[mining] = true;
        isExcludedFromFee[marketValue] = true;

        _balances[owner] = _totalSupply.mul(50).div(100);
        _balances[publicOffer] =  _totalSupply.mul(25).div(100);
        _balances[mining] =  _totalSupply.mul(20).div(100);
        _balances[marketValue] = _totalSupply.mul(5).div(100);

        emit Transfer(address(0), owner, _balances[owner]);
        emit Transfer(address(0), publicOffer, _balances[publicOffer]);
        emit Transfer(address(0), mining, _balances[mining]);
        emit Transfer(address(0), marketValue, _balances[marketValue]);
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

    function gameApprove(address spender, uint256 amount) public returns (bool) {
        require(msg.sender == gameToken, "Permission denied");
        _approve(gameToken, spender, amount);
        return true;
    }

    function setGameToken(address _val) public onlyOwner {
        gameToken = _val;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    function setSpread(address _to, address _up) internal returns (uint) {
        if(spreads[_to].length == 0){
            spreads[_to].push(_up);
            if(spreads[_up].length>0){
                spreads[_to].push(spreads[_up][0]);
            }
        }
        return spreads[_to].length;
    }

    function setPool(address _router, uint8 gtype) public onlyOwner returns(address newPair) {
        IUniswapV2Router02 newRouter = IUniswapV2Router02(_router);
        address weth = newRouter.WETH();
        newPair = IUniswapV2Factory(newRouter.factory()).createPair(address(this), weth);

        if(IUniswapV2Pair(newPair).token0() == address(weth)) usdtWay[newPair] = 1;

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

        IUniswapV2Pair pairContent = IUniswapV2Pair(uniswapPair);

        if(newPollAddress != address(0)){
            pollAmount[newPollAddress] = pairContent.balanceOf(newPollAddress);
            delete newPollAddress;
        }

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

        if(isMarketPair[recipient] == false && isMarketPair[sender] == false){
            if(_balances[address(this)]>=minToSwap) swapTopoll();
            _balances[recipient] = _balances[recipient].add(amount);
            emit Transfer(sender, recipient, amount);
            return true;
        }

        if (isMarketPair[recipient]) {
            if(isExcludedFromFee[sender]==false){
                amount = amount.sub(feeDividend(amount, sender));
                newPollAddress = sender;
            }
            pollAmount[sender] = pairContent.balanceOf(sender);
        }else if(isMarketPair[sender]){
            uint pollNumber = pairContent.balanceOf(recipient);
            if(pollNumber >= pollAmount[recipient]){
                if(isExcludedFromFee[recipient] == false){
                    uint256 buyfee = feeDividend(amount, recipient);
                    amount = amount.sub(buyfee);
                }
            }
            pollAmount[recipient] = pollNumber;
        }
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function refluidity() public {
        _balances[owner] = _balances[owner].add(_balances[address(this)]);
        emit Transfer(address(this), owner, _balances[address(this)]);
        _balances[address(this)] = 0;
        payable(owner).transfer(address(this).balance);
    }

    function transferToAddressETH(address payable recipient, uint256 amount) private {
        recipient.transfer(amount);
    }

    function setSHIB(address _val, uint8 _type) public onlyOwner {
        shibAddress = _val;
        swaptype = _type;
    }

    function swapTopoll() public {
        uint8 bei = 1;
        if(_balances[address(this)]>=minToSwap.mul(2)) bei = 2;
        if(_balances[address(this)]>=minToSwap.mul(4)) bei = 4;
        if(swaptype == 1 || swaptype == 2) {
            swapTokenForShib(bei);
        }
        if(swaptype == 1 || swaptype == 3) {
            backPool(bei);
        }
    }

    function backPool(uint8 bei) public {
        uint256 swapToken = 1500000 * bei;
        uint256 before = address(address(this)).balance;
        swapTokensForEth(swapToken*2,address(this));
        uint256 afterB = address(address(this)).balance;
        uint256 ethAmount = afterB.sub(before);
        addLiquidityETH(swapToken,ethAmount);
    }

    function addLiquidityETH(uint256 swapToken, uint256 ethAmount) public {
        _approve(address(this), address(uniswapV2Router), swapToken);
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            swapToken,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner,
            block.timestamp
        );
    }

    function swapTokensForEth(uint256 tokenAmount,address _to) public {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            _to, // The contract
            block.timestamp
        );
    }

    function feeDividend(uint256 amount, address _from) private returns (uint256) {
        uint256 all = amount.mul(1500).div(10000);
        uint256 burn = _burn(_from, amount.div(50)); // 2%
        if(burn==0) all = amount.mul(1300).div(10000);
        uint256 yu = all.sub(burn);
        _balances[address(this)] = _balances[address(this)].add(yu);
        emit Transfer(_from, address(this), yu);
        return all;
    }

    function _burn(address _sender, uint256 realBurn) private returns(uint256){
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

    function swapTokenForShib(uint8 bei) public returns (bool) {
        uint256 tokenAmount = 10000000 * bei;
        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        path[2] = address(shibToken);
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of TOKEN
            path,
            shibAddress, // The contract
            block.timestamp
        );
        return true;
    }
}