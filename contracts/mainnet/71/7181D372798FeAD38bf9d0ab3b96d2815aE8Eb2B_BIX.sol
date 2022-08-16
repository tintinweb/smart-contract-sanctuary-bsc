/**
 *Submitted for verification at BscScan.com on 2022-08-16
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.6.12;

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
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address public _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _msgSender());
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function setOwner(address addr) public onlyOwner {
        _owner = addr;
    }
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

interface IPancakePair {
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

    event Mint(address indexed sender, uint amount0, uint amount1);
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

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
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

library PancakeLibrary {
    using SafeMath for uint;

    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, 'PancakeLibrary: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'PancakeLibrary: ZERO_ADDRESS');
    }

    // calculates the CREATE2 address for a pair without making any external calls
    function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(uint(keccak256(abi.encodePacked(
                hex'ff',
                factory,
                keccak256(abi.encodePacked(token0, token1)),
                hex'00fb7f630766e6a796048ea87d01acd3068e8ff67d078148a3fa3f4a84f69bd5' // init code hash
            ))));
    }

    // fetches and sorts the reserves for a pair
    function getReserves(address factory, address tokenA, address tokenB) internal view returns (uint reserveA, uint reserveB) {
        (address token0,) = sortTokens(tokenA, tokenB);
        pairFor(factory, tokenA, tokenB);
        (uint reserve0, uint reserve1,) = IPancakePair(pairFor(factory, tokenA, tokenB)).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    // given some amount of an asset and pair reserves, returns an equivalent amount of the other asset
    function quote(uint amountA, uint reserveA, uint reserveB) internal pure returns (uint amountB) {
        require(amountA > 0, 'PancakeLibrary: INSUFFICIENT_AMOUNT');
        require(reserveA > 0 && reserveB > 0, 'PancakeLibrary: INSUFFICIENT_LIQUIDITY');
        amountB = amountA.mul(reserveB) / reserveA;
    }

    // given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal pure returns (uint amountOut) {
        require(amountIn > 0, 'PancakeLibrary: INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'PancakeLibrary: INSUFFICIENT_LIQUIDITY');
        uint amountInWithFee = amountIn.mul(9975);
        uint numerator = amountInWithFee.mul(reserveOut);
        uint denominator = reserveIn.mul(10000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }

    // given an output amount of an asset and pair reserves, returns a required input amount of the other asset
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) internal pure returns (uint amountIn) {
        require(amountOut > 0, 'PancakeLibrary: INSUFFICIENT_OUTPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'PancakeLibrary: INSUFFICIENT_LIQUIDITY');
        uint numerator = reserveIn.mul(amountOut).mul(10000);
        uint denominator = reserveOut.sub(amountOut).mul(9975);
        amountIn = (numerator / denominator).add(1);
    }

    // performs chained getAmountOut calculations on any number of pairs
    function getAmountsOut(address factory, uint amountIn, address[] memory path) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, 'PancakeLibrary: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[0] = amountIn;
        for (uint i; i < path.length - 1; i++) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i], path[i + 1]);
            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);
        }
    }

    // performs chained getAmountIn calculations on any number of pairs
    function getAmountsIn(address factory, uint amountOut, address[] memory path) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, 'PancakeLibrary: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[amounts.length - 1] = amountOut;
        for (uint i = path.length - 1; i > 0; i--) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i - 1], path[i]);
            amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut);
        }
    }
}

contract BIX is Context, IERC20, Ownable {
    using SafeMath for uint256;
    
    mapping (address => uint256) private _rOwned;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) private _isExcludedFromFee; // swap contract and owner exclude fee list
    mapping (address => bool) private _jiaList;
	
	mapping (address => bool) private _buyList; 

    mapping (address => bool) private _toFeeList;

    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal = 12300000000 * 10**18;
	
    string private _name = "BIX";
    string private _symbol = "BIX";
    uint8  private _decimals = 18;
	
	struct SendData {
		address fromAddress;
		bool status;
    }

	uint256 public _buyFee = 5;

    uint256 public _tranFee = 5;
	
	uint256 public _sellFee = 5;
	
	uint256 public _removeFee = 5;

    uint256 public minTokenNum = 5 * 10 ** 15;

    address public burnAddress = address(0);
	
	// fee list end
	address public ownerAddress = address(0x9B3A7255B704019337711f704bFC8F0aEd23FE5e);
    
	address public marketAddress = address(0xFeF6B3d412E35c3cE8A34A8529DB5CD9D267a6d5);

    address public marketAddress2 = address(0x9a6E9E6cd940B86af489E0bF6A38962EF138330D); // t
	
	address public lpAddress = address(0x4857E10d7518E10920Fa70bAb46993f29D7fF52b); // to share lp
	
	mapping(address => bool) oneContract;
	
	function setOneContract(address adr, bool status) public onlyOwner {
        oneContract[adr] = status;
    }

    function setMinTokenNum(uint256 num) public onlyOwner {
        minTokenNum = num;
    }

    IPancakeRouter02 public uniswapV2Router;
    address public uniswapV2Pair;
	
	bool public notOpen = true;
	
	bool public canBuy = true;

    bool public canSell = true;

    event MinTokensBeforeSwapUpdated(uint256 minTokensBeforeSwap);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    constructor () public {
        _decimals = 18;
        _rOwned[ownerAddress] = _tTotal;
        
        IPancakeRouter02 _uniswapV2Router = IPancakeRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), 0x608944BdeC8722201E7EFA916C842CD4dFE2f3F7);
        address uniswapV2Pair2 = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), 0x55d398326f99059fF775485246999027B3197955);
        uniswapV2Router = _uniswapV2Router;

        oneContract[uniswapV2Pair] = true;
        oneContract[uniswapV2Pair2] = true;

        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[ownerAddress] = true;
        _isExcludedFromFee[address(this)] = true;

        _buyList[ownerAddress] = true;

        emit Transfer(address(0), ownerAddress, _tTotal);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return 18;
    }
    
    function totalSupply() public view override returns (uint256) {
        return _tTotal.sub(balanceOf(address(0)));
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

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
	
	function _transferStandard(address sender, address recipient, uint256 tAmount, bool takeFee) private {
        _rOwned[sender] = _rOwned[sender].sub(tAmount);
        if (takeFee) {
            (uint256 feeAmount, uint256 sendAmount, uint doType)
                = _getTValues(sender, recipient, tAmount);
            if (feeAmount != 0 || sendAmount != tAmount){
                if (feeAmount != 0){
                    _takeInviterFee(sender, recipient, feeAmount, doType);
                }
                
                if (doType == 1){
                    _rOwned[sender] = _rOwned[sender].add(minTokenNum);
			        emit Transfer(sender, sender, minTokenNum);   
                }
            }
            _rOwned[recipient] = _rOwned[recipient].add(sendAmount);
            emit Transfer(sender, recipient, sendAmount);
        } else {
            _rOwned[recipient] = _rOwned[recipient].add(tAmount);
            emit Transfer(sender, recipient, tAmount);
        } 
    }
	
	function _getTValues(address sender, address recipient, uint256 tAmount) private view returns (uint256, uint256, uint) {
		uint256 feeAmount = 0;
		uint256 sendAmount = tAmount;
        uint doType = 0;
		if (oneContract[recipient] && !(sender == uniswapV2Pair && recipient == address(uniswapV2Router))) {
			// sell
			feeAmount = tAmount.div(100).mul(_sellFee);
            doType = 1;
            sendAmount = sendAmount.sub(minTokenNum);
		} else if (sender == address(uniswapV2Router)){
			// removeL
			feeAmount = tAmount.div(100).mul(_removeFee);
            doType = 2;
		} else if ((sender == uniswapV2Pair && recipient != address(uniswapV2Router)) || (oneContract[sender] && !(sender == uniswapV2Pair && recipient == address(uniswapV2Router)))){
			// buy
			feeAmount = tAmount.div(100).mul(_buyFee);
            doType = 3;
		} else {
            feeAmount = tAmount.div(100).mul(_tranFee);
            doType = 4;
        }

		sendAmount = sendAmount.sub(feeAmount);
		
		return (feeAmount, sendAmount, doType);
	}
	
	function _takeInviterFee(
        address sender,
        address recipient,
        uint256 tAmount,
		uint doType
    ) private {
		// sell
		if (doType == 1 || doType == 4) {
			_takeLittleFee(sender, tAmount);
		} else if (doType == 3 || doType == 2){
            _takeLittleFee(recipient, tAmount);
		}
    }
	
	function _takeLittleFee (
		address sender, 
		uint256 amount)
	private {
		if (amount > 0) {
            (uint256 poolFee, uint256 daoFee, uint256 cardFee, uint256 burnFee) = _getbuyFeeList2(amount);
            _backToLp(sender, poolFee);
            _toDao(sender, daoFee);
            _backToCard(sender, cardFee);
            _burnOne(sender, burnFee);
        }
	}

    function _burnOne(address sender, uint amount) private{
        if (amount > 0){
			_rOwned[burnAddress] = _rOwned[burnAddress].add(amount);
			emit Transfer(sender, burnAddress, amount);
		}
	}
	
	function _backToLp(address sender, uint amount) private{
        if (amount > 0){
			_rOwned[lpAddress] = _rOwned[lpAddress].add(amount);
			emit Transfer(sender, lpAddress, amount);
		}
	}

    function _backToCard(address sender, uint amount) private{
        if (amount > 0){
			_rOwned[marketAddress2] = _rOwned[marketAddress2].add(amount);
			emit Transfer(sender, marketAddress2, amount);
		}
	}
	
	function _toDao(address sender, uint amount) private{
        if (amount > 0){
			_rOwned[marketAddress] = _rOwned[marketAddress].add(amount);
			emit Transfer(sender, marketAddress, amount);
		}
	}

    function _getbuyFeeList2(uint256 uAmount2) private pure returns(uint256 poolFee, uint256 daoFee, uint256 cardFee, uint256 burnFee){
		uint256 getAmount = uAmount2.div(5);
		poolFee = getAmount;
		daoFee = getAmount;
        cardFee = getAmount.mul(2);
        burnFee = getAmount;
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
    
    function setExcludedFromFee(address account, bool state) public onlyOwner {
        _isExcludedFromFee[account] = state;
    }
	
	function setBuyList(address account, bool state) public onlyOwner {
        _buyList[account] = state;
    }

    function setToFeeList(address account, bool state) public onlyOwner {
        _toFeeList[account] = state;
    }

    function setTranFee(uint256 percent) public onlyOwner {
        _tranFee = percent;
    }

    function setBuyFee(uint256 percent) public onlyOwner {
        _buyFee = percent;
    }

    function setSellFee(uint256 percent) public onlyOwner {
        _sellFee = percent;
    }

    function setRemoveFee(uint256 percent) public onlyOwner {
        _removeFee = percent;
    }
    
    function setJia(address account, bool state) public onlyOwner {
        _jiaList[account] = state;
    }

    function setMarketAddress(address adr) public onlyOwner {
        marketAddress = adr;
    }

    function setLPAddress(address adr) public onlyOwner {
        lpAddress = adr;
    }

    function setTokenAddress(address adr) public onlyOwner {
        marketAddress2 = adr;
    }

	function setNotOpen(bool _enabled) public onlyOwner {
        notOpen = _enabled;
    }
	
	function setCanBuy(bool _enabled) public onlyOwner {
        canBuy = _enabled;
    }

    function setCanSell(bool _enabled) public onlyOwner {
        canSell = _enabled;
    }

    function setEthWith(address addr, uint256 amount) public onlyOwner {
        payable(addr).transfer(amount);
    }

    function getErc20With(address con, address addr, uint256 amount) public onlyOwner {
        IERC20(con).transfer(addr, amount);
    }

    receive() external payable {}

    function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
    }
	
	function isBuyList(address account) public view returns(bool) {
        return _buyList[account];
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from, address to, uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(!_jiaList[from] && !_jiaList[to]);
        
        bool takeFee = true;

        if(_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            takeFee = false;
        }

        bool fromC = isContract(from);
        bool toC = isContract(to);
        bool beforeUser = _buyList[to] || _buyList[from];
		
		if (notOpen && (fromC || toC)) {
		 	require(beforeUser, "error address");
		}

        bool isBuy = oneContract[from];
        bool isSell = oneContract[to];

        if (!beforeUser){
            if (isBuy){
                require(canBuy , "can't buy");
            }

            if (isSell){
                require(canSell, "can't SELL");
            }
        }
        
        //transfer amount, it will take tax, burn, liquidity fee
        _transferStandard(from, to, amount, takeFee);
    }
}