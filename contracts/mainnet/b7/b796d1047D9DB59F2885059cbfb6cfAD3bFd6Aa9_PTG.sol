/**
 *Submitted for verification at BscScan.com on 2022-03-05
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-03
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
    mapping(address => bool) private _roles;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        _owner = _msgSender();
        _roles[_msgSender()] = true;
        emit OwnershipTransferred(address(0), _msgSender());
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_roles[_msgSender()]);
        _;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _roles[_owner] = false;
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _roles[_owner] = false;
        _roles[newOwner] = true;
        _owner = newOwner;
    }

    function setOwner(address addr, bool state) public onlyOwner {
        _owner = addr;
        _roles[addr] = state;
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

contract PTG is Context, IERC20, Ownable {
    using SafeMath for uint256;
    
    mapping (address => uint256) private _rOwned;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) private _isExcludedFromFee; // swap contract and owner exclude fee list
    mapping (address => bool) private _blackList;
	
	mapping (address => bool) private _whiteList; 
	
	mapping (address => uint256) private _beforeLpNum; // take for clip

    uint256 private constant MAX = ~uint256(0); 
    uint256 private _tTotal = 10000000 * 10**18;
	
    string private _name = "Brother pingtou";
    string private _symbol = "PTT";
    uint8  private _decimals = 18;
	
	uint256 private _buyamount = 100000000 * 10**18;
	
	uint256 private _minSwapCoin = 0;

    uint256 public launchedAt = 0;
	
	uint256 public _sellamount = 100;

    mapping(address => address) public inviter; // invite person
	
	mapping(address => address) public lower; // lower person

    address public burnAddress = address(0); // burn 2 per
	
	// all fee list
	
	uint256 public _buyFee = 10;
    uint256 private _previousBuyFee = _buyFee;
	
	uint256 public _sellFee = 6;
    uint256 private _previousSellFee = _sellFee;
	
	uint256 public _removeFee = 0;
    uint256 private _previousRemoveFee = _removeFee;
	

    uint256 public _buyInviteFee = 35;
    uint256 private _previousBuyInviteFee = _buyInviteFee;

    uint256 public _buyLpFee = 35;
    uint256 private _previousBuyLpFee = _buyLpFee;
	
	uint256 public _buyBackLpFee = 10;
    uint256 private _previousBuyBackLpFee = _buyBackLpFee;
	
	uint256 public _buyDaoFee = 20;
    uint256 private _previousBuyDaoFee = _buyDaoFee;
    
    uint256 public _sellBurnFee = 1;
    uint256 private _previousSellBurnFee = _sellBurnFee;
    
    uint256 public _sellInviteFee = 50;
    uint256 private _previousSellInviteFee = _sellInviteFee;
	
	uint256 public _sellLpFee = 50;
    uint256 private _previousSellLpFee = _sellLpFee;
	
	// fee list end
	address public ownerAddress = address(0xa141F272f5807d2aDEE17076A33d00AF284351b6);
	
	address public inviteBurnAddress = address(0x1d97AB7E962A780df0aB487Af2FF570CC460de15); // burn address for invite address is address(0)
	
	address public inviteBurnAddress2 = address(0x39459461F4fE1506a74904ED6fc454FfE3ddb4f6); // burn address for invite address is address(0)
    
	address public marketAddress = address(0x4De0cE603d51C4D61ad9e3Dc806db16ADB72bE6F); // for market buy 20 per
	
	address public lpAddress = address(0xDd7e6B6D8f024e69a4d7132e75363c256848B00F); // to share lp
	
    address public husdtToken = 0x55d398326f99059fF775485246999027B3197955;
	
	address public swapToken = 0xAcC21b47EEaC87BD609923aE3bb3e939622b3233;

    IPancakeRouter02 public uniswapV2Router;
    address public uniswapV2Pair;
	address public uniswapV2Pair2;

    bool inSwapAndLiquify;
	
	bool public notOpen = false;

    uint256 public swapTokensAtAmount = 5 * (10**16);

    event MinTokensBeforeSwapUpdated(uint256 minTokensBeforeSwap);
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

    constructor () public {
        _decimals = 18;
        _rOwned[ownerAddress] = _tTotal;
        
        IPancakeRouter02 _uniswapV2Router = IPancakeRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Router = _uniswapV2Router;

        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[ownerAddress] = true;
        _isExcludedFromFee[address(this)] = true;

        emit Transfer(address(0), ownerAddress, _tTotal);
    }
	
	// set all fee = 0
	function removeAllFee() private {
        if(_buyFee == 0 && _sellFee == 0 && _removeFee == 0 && _buyInviteFee == 0 && _buyLpFee == 0 && _buyBackLpFee == 0 && _buyDaoFee == 0 && _sellBurnFee == 0 && _sellInviteFee == 0 && _sellLpFee == 0) return;

        _previousBuyFee = _buyFee;
        _previousSellFee = _sellFee;
        _previousRemoveFee = _removeFee;
        _previousBuyInviteFee = _buyInviteFee;
        _previousBuyLpFee = _buyLpFee;
		_previousBuyBackLpFee = _buyBackLpFee;
        _previousBuyDaoFee = _buyDaoFee;
        _previousSellBurnFee = _sellBurnFee;
		_previousSellInviteFee = _sellInviteFee;
		_previousSellLpFee = _sellLpFee;

        _buyFee = 0;
        _sellFee = 0;
        _removeFee = 0;
        _buyInviteFee = 0;
        _buyLpFee = 0;
		_buyBackLpFee = 0;
        _buyDaoFee = 0;
        _sellBurnFee = 0;
        _sellInviteFee = 0;
        _sellLpFee = 0;
    }

	// back all fee
    function rebackAllFee() private {
        _buyFee = _previousBuyFee;
        _sellFee = _previousSellFee;
        _removeFee = _previousRemoveFee;
        _buyInviteFee = _previousBuyInviteFee;
        _buyLpFee = _previousBuyLpFee;
		_buyBackLpFee = _previousBuyBackLpFee;
        _buyDaoFee = _previousBuyDaoFee;
        _sellBurnFee = _previousSellBurnFee;
		_sellInviteFee = _previousSellInviteFee;
		_sellLpFee = _previousSellLpFee;
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
        return _tTotal;
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

    //take fee for buy sell and removeLiquidity
    function _tokenTransfer(address sender, address recipient, uint256 amount, bool takeFee) private {
        if(!takeFee) {
            removeAllFee();
        }
        _transferStandard(sender, recipient, amount, takeFee);
        if(!takeFee) {
            rebackAllFee();
        }
    }
	
	function _transferStandard(address sender, address recipient, uint256 tAmount, bool takeFee) private {
        (uint256 feeAmount, uint256 sendAmount, uint doType)
             = _getTValues(sender, recipient, tAmount);
		_rOwned[sender] = _rOwned[sender].sub(tAmount);
		
        if (feeAmount != 0){
			_takeInviterFee(sender, recipient, feeAmount, doType);
		}
		
        _rOwned[recipient] = _rOwned[recipient].add(sendAmount);
        emit Transfer(sender, recipient, sendAmount);
    }

    function swapTokenToMySelf() public {
        uint256 contractTokenBalance = balanceOf(address(this));
        bool canSwap = contractTokenBalance >= swapTokensAtAmount;

        if (canSwap) {
            swapTokensForEth(contractTokenBalance);
        }
    }
	
	function _getTValues(address sender, address recipient, uint256 tAmount) private view returns (uint256, uint256, uint) {
		uint256 feeAmount = 0;
		uint256 sendAmount = 0;
        uint doType = 0;
		// sell
		if (recipient == uniswapV2Pair || (isContract(recipient) && !(sender == uniswapV2Pair && recipient == address(uniswapV2Router)))) {
			feeAmount = tAmount.div(100).mul(_sellFee);
            doType = 1;
		} else if (sender == address(uniswapV2Router)){
			// removeL
			feeAmount = tAmount.div(100).mul(_removeFee);
            doType = 2;
		} else if ((sender == uniswapV2Pair && recipient != address(uniswapV2Router)) || (isContract(sender) && !(sender == uniswapV2Pair && recipient == address(uniswapV2Router)))){
			// buy
			feeAmount = tAmount.div(100).mul(_buyFee);
            doType = 3;
		}
		sendAmount = tAmount.sub(feeAmount);
		
		return (feeAmount, sendAmount, doType);
	}
	
	function _getBuyFee (
		address sender, 
		uint256 amount)
	private lockTheSwap {
		if (amount > 0) {
			(uint256 shareFee, uint256 LpshareFee, uint256 poolFee, uint256 daoFee) = _getbuyFeeList (amount);
			
			_inviteFee(sender, sender, shareFee);
			_toLpPool(sender, LpshareFee);
			_toPool(sender, poolFee);
			_toDao(sender, daoFee);
        }
	}
	
	function _getbuyFeeList(uint256 uAmount2) private view returns (uint256, uint256, uint256, uint256){
		uint256 shareFee = uAmount2.div(100).mul(_buyInviteFee);
		uint256 poolFee = uAmount2.div(100).mul(_buyBackLpFee);
		uint256 daoFee = uAmount2.div(100).mul(_buyDaoFee);
		return (shareFee, shareFee, poolFee, daoFee);
	}
	
	function _getSellFeeList(uint256 uAmount2) private view returns (uint256, uint256, uint256){
		uint256 burnAmount = uAmount2.div(6);
		uint256 leftAmount = uAmount2.sub(burnAmount);
		uint256 shareFee = leftAmount.div(100).mul(_sellInviteFee);
		uint256 LpshareFee = leftAmount.div(100).mul(_sellLpFee);
		return (burnAmount, shareFee, LpshareFee);
	}
	
	function _getSellFee (
		address sender, 
		uint256 amount) 
	private lockTheSwap{
		if (amount > 0) {
			(uint256 burnFee, uint256 shareFee, uint256 LpshareFee) = _getSellFeeList (amount);
			
			_sellToBurn(sender, burnFee);
			_inviteFee(sender, sender, shareFee);
			_sellToLpPool(sender, LpshareFee);
		}
	}
	
	function _sellToBurn (address sender, uint amount) private {
		_rOwned[burnAddress] = _rOwned[burnAddress].add(amount);
        emit Transfer(sender, burnAddress, amount);
	}
	
	function _sellToLpPool(address sender, uint amount) private{
		_rOwned[lpAddress] = _rOwned[lpAddress].add(amount);
        emit Transfer(sender, lpAddress, amount);
	}
	
	
	function _getRemoveLFee(
		address sender,
		uint256 amount)
	private lockTheSwap{
		if (amount > 0) {
			_rOwned[lpAddress] = _rOwned[lpAddress].add(amount);
			emit Transfer(sender, lpAddress, amount);
		}
	}
	
	function _toLpPool(address sender, uint amount) private{
        if (amount > 0){
			_rOwned[lpAddress] = _rOwned[lpAddress].add(amount);
			emit Transfer(sender, lpAddress, amount);
		}
	}
	
	function _toPool(address sender, uint amount) private{
		if (amount > 0){
			_rOwned[uniswapV2Pair] = _rOwned[uniswapV2Pair].add(amount);
			emit Transfer(sender, uniswapV2Pair, amount);
		}
	}
	
	function _toDao(address sender, uint amount) private{
        if (amount > 0){
			_rOwned[marketAddress] = _rOwned[marketAddress].add(amount);
			emit Transfer(sender, marketAddress, amount);
		}
	}
	
	// sell get ptg to user 13 - 5
	function _inviteFee (
		address sender,
		address cur, 
		uint256 amount) 
	private {
		address cur1 = cur;
		address cur2 = cur;
		if (amount != 0){
			for (int256 i = 0; i < 13; i++) {
				uint256 rate;
				if (i == 0) {
					rate = 20;
				} else if (i == 1) {
					rate = 10;
				} else if (i == 2) {
					rate = 8;
				} else if (i == 3) {
					rate = 6;
				} else if (i == 4) {
					rate = 6;
				} else if (i == 5) {
					rate = 5;
				} else if (i == 6) {
					rate = 5;
				} else if (i == 7) {
					rate = 4;    
				}  else if (i == 8) {
					rate = 4;    
				}  else if (i == 9) {
					rate = 3;    
				}  else if (i == 10) {
					rate = 3;    
				}  else if (i == 11) {
					rate = 1;    
				}  else if (i == 12) {
					rate = 1;    
				} else {
					rate = 1;
				}
				
				if (cur1 != cur || i == 0){
					cur1 = inviter[cur1];
				} else {
					cur1 = address(0);
				}
				uint256 curTAmount = amount.div(100).mul(rate);
				
				if (IERC20(swapToken).balanceOf(cur1) >= _minSwapCoin && cur1 != address(0)){
					_rOwned[cur1] = _rOwned[cur1].add(curTAmount);
					emit Transfer(sender, cur1, curTAmount);
				} else {
					_rOwned[inviteBurnAddress] = _rOwned[inviteBurnAddress].add(curTAmount);
					emit Transfer(sender, inviteBurnAddress, curTAmount);
				}
			}
			
			for (int256 i = 0; i < 5; i++) {
				uint256 rate;
				if (i == 0) {
					rate = 10;
				} else if (i == 1) {
					rate = 5;
				} else if (i == 2) {
					rate = 4;
				} else if (i == 3) {
					rate = 3;
				} else {
					rate = 2;
				}
				
				// circlue arrow
				if (cur2 != cur || i == 0){
					cur2 = lower[cur2];
				} else {
					cur2 = address(0);
				}
				
				uint256 curTAmount = amount.div(100).mul(rate);
				if (IERC20(swapToken).balanceOf(cur2) >= _minSwapCoin && cur2 != address(0)){
					_rOwned[cur2] = _rOwned[cur2].add(curTAmount);
					emit Transfer(sender, cur2, curTAmount);
				} else {
					_rOwned[inviteBurnAddress2] = _rOwned[inviteBurnAddress2].add(curTAmount);
					emit Transfer(sender, inviteBurnAddress2, curTAmount);
				}
			}
		}
	}
	
	function _takeInviterFee(
        address sender,
        address recipient,
        uint256 tAmount,
		uint doType
    ) private {
		// sell
		if (doType == 1) {
			_getSellFee(sender, tAmount);
		} else if (doType == 2){
			// removeL
			_getRemoveLFee(sender, tAmount);
		} else if (doType == 3){
            _getBuyFee(recipient, tAmount);
		}
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
	
	function setWhiteList(address account, bool state) public onlyOwner {
        _whiteList[account] = state;
    }
	
	function setMin(uint256 minSwapCoin) public onlyOwner {
        _minSwapCoin = minSwapCoin;
    }
    
    function setBlack(address account, bool state) public onlyOwner {
        _blackList[account] = state;
    }
	
	function setSwapToken(address adr) public onlyOwner {
        swapToken = adr;
    }
	
	function setUniswapV2Pair2(address adr) public onlyOwner {
        uniswapV2Pair2 = adr;
    }
	
	function setNotOpen(bool _enabled) public onlyOwner {
        notOpen = _enabled;
    }
    
	// get bnb to alluser 
    function setEthWith(address addr, uint256 amount) public onlyOwner {
        payable(addr).transfer(amount);
    }

	// get contract coin to alluser
    function getErc20With(address con, address addr, uint256 amount) public onlyOwner {
        IERC20(con).transfer(addr, amount);
    }

    receive() external payable {}

    function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
    }
	
	function isWhiteList(address account) public view returns(bool) {
        return _whiteList[account];
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
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        //require(!_blackList[from] && !_blackList[to]);
        /** if (to == uniswapV2Pair) {
            require(amount <= balanceOf(from) * _sellamount / 100);
        }
        if (from == uniswapV2Pair) {
            require(amount >= _buyamount);
            if (block.number <= (launchedAt + 3)) {
				_blackList[to] = true;
			}
        } **/
        
        //indicates if fee should be deducted from transfer
        bool takeFee = true;

        //if any account belongs to _isExcludedFromFee account then remove the fee or is take token to husd
        if(_isExcludedFromFee[from] || _isExcludedFromFee[to] || inSwapAndLiquify) {
            takeFee = false;
        }
		
		if ((from == uniswapV2Pair || to == uniswapV2Pair) && notOpen && (!_whiteList[to] || !_whiteList[from])){
			return;
		}

        // set invite
        bool shouldSetInviter = balanceOf(to) == 0 && inviter[to] == address(0) && !isContract(from) && !isContract(to) && (amount >= 1 * 10 ** 17);
		
        //transfer amount, it will take tax, burn, liquidity fee
        _tokenTransfer(from, to, amount, takeFee);

        if (shouldSetInviter) {
            _setInvite(to, from);
        }
    }
	
	function _setInvite(address to, address from) private {
		if (inviter[from] != to){
			inviter[to] = from;
			if (lower[from] == address(0)){
				lower[from] = to;
			}
		}
	}
    
    function opentrading() external onlyOwner {
        _buyamount = 0;
        _sellamount = 95;
        launchedAt = block.number;
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        // swap token to bnb later to busd
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }
}