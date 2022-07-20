/**
 *Submitted for verification at BscScan.com on 2022-07-19
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
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

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: weiValue}(
            data
        );
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
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
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function geUnlockTime() public view returns (uint256) {
        return _lockTime;
    }

    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = block.timestamp + time;
        emit OwnershipTransferred(_owner, address(0));
    }

    function unlock() public virtual {
        require(
            _previousOwner == msg.sender,
            "You don't have permission to unlock"
        );
        require(block.timestamp > _lockTime, "Contract is locked until 7 days");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }
}

interface IPancakeSwapFactory {
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

interface IPancakeSwapPair {
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

interface IPancakeSwapRouter{
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

contract CommunityHedgeToken is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping(address => uint256) private _balances;
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private constant MAX = ~uint256(0) / 10;
    uint256 private _totalSupply = 1000000000 * 1e18;

    string private _name = "Community Hedge Token";
    string private _symbol = "$CHT";
    uint8 private _decimals = 18;

    uint256 public _marketingFee = 0;
    uint256 public _marketingBuyFee = 2;
    uint256 public _marketingSellFee = 2;

    uint256 public _liquidityFee = 0;
    uint256 public _liquidityBuyFee = 2;
    uint256 public _liquiditySellFee = 2;

    uint256 public _buyBackAndBurnFee = 0;
    uint256 public _buyBackAndBurnBuyFee = 2;
    uint256 public _buyBackAndBurnSellFee = 2;

    address public storeAddress;
    address public busdAddress = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address public marketingWallet = 0x4F7558641007E22E2D105104EA7D8971dBFF538C;
    
    address public immutable deadAddress = 0x000000000000000000000000000000000000dEaD;

    uint256 public liquidityStore;

    address public pancakeswapPair;
    IPancakeSwapRouter public immutable pancakeSwapRouter;

    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;

    uint256 public _maxWalletSize = _totalSupply.mul(10).div(1000);
    uint256 private numTokensSellToAddToLiquidity = 1 * 1e18;

    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    modifier lockTheSwap() {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor() {
        _balances[_msgSender()] = _totalSupply;

        busdAddress = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
        IPancakeSwapRouter _pancakeSwapRouter = IPancakeSwapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        // pancakeswapPair = IPancakeSwapFactory(_pancakeSwapRouter.factory()).createPair(address(this), busdAddress);
        pancakeSwapRouter = _pancakeSwapRouter;

        _isExcludedFromFee[address(this)] = true;

        emit Transfer(address(0), _msgSender(), _totalSupply);
    }

    function setpairAddress(address _addr) public onlyOwner {
        pancakeswapPair = _addr;
    }

    function setStoreAddress(address _storeAddress) public onlyOwner {
        storeAddress = _storeAddress;
    }

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function setSellMarketingFee(uint256 marketingFee) external onlyOwner {
        _marketingSellFee = marketingFee;
    }

    function setSellLiquidityFee(uint256 liquidityFee) external onlyOwner {
        _liquiditySellFee = liquidityFee;
    }

    function setBuyMarketingFee(uint256 marketingFee) external onlyOwner {
        _marketingBuyFee = marketingFee;
    }

    function setBuyLiquidityFee(uint256 liquidityFee) external onlyOwner {
        _liquidityBuyFee = liquidityFee;
    }

    function setBuyBackBuyFee(uint256 buyBackBuyFee) external onlyOwner {
        _buyBackAndBurnBuyFee = buyBackBuyFee;
    }

    function setBuyBackSellFee(uint256 buyBackSellFee) external onlyOwner {
        _buyBackAndBurnSellFee = buyBackSellFee;
    }

    function setMaxWalletPercent(uint256 maxWallPercent) external onlyOwner {
        _maxWalletSize = _totalSupply.mul(maxWallPercent).div(10**3);
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    //to recieve ETH from pancakeSwapRouter when swaping
    receive() external payable {}

    function _burn(address from, uint256 amount) private {
        _balances[from] = _balances[from].sub(amount);
        if (_totalSupply > amount) _totalSupply = _totalSupply.sub(amount);
    }

    function _getValues(uint256 tAmount)
        private
        returns (uint256 tTransferAmount)
    {
        uint256 tMarketing = tAmount.mul(_marketingFee).div(10**2);
        uint256 tLiquidity = tAmount.mul(_liquidityFee).div(10**2);
        uint256 tBuybackAndBurn = tAmount.mul(_buyBackAndBurnFee).div(10**2);

        tTransferAmount = tAmount.sub(
            tBuybackAndBurn + tMarketing + tLiquidity
        );

        _takeFee(tLiquidity, tMarketing, tBuybackAndBurn);
    }

    function removeAllFee() private {
        _buyBackAndBurnFee = 0;
        _marketingFee = 0;
        _liquidityFee = 0;
    }

    function setSellFee() private {
        _buyBackAndBurnFee = _buyBackAndBurnSellFee;
        _marketingFee = _marketingSellFee;
        _liquidityFee = _liquiditySellFee;
    }

    function setBuyFee() private {
        _buyBackAndBurnFee = _buyBackAndBurnBuyFee;
        _marketingFee = _marketingBuyFee;
        _liquidityFee = _liquidityBuyFee;
    }

    function buyBackTokens(uint256 amount) public onlyOwner {
    	if (amount > 0) {
    	    swapBUSDForTokens(amount);
	    }
    }

    function isExcludedFromFee(address account) private view returns (bool) {
        return _isExcludedFromFee[account];
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

        if (from != owner() && to != owner() && to != pancakeswapPair) {
            uint256 walletCurrentBalance = balanceOf(to);
            require(
                walletCurrentBalance + amount <= _maxWalletSize,
                "Exceeds maximum wallet token amount"
            );
        }

        uint256 liquidifyAmount = liquidityStore > 0
            ? balanceOf(address(this))
            : 0;

        bool overMinTokenBalance = liquidifyAmount >=
            numTokensSellToAddToLiquidity;
        if (
            overMinTokenBalance &&
            !inSwapAndLiquify &&
            from != pancakeswapPair &&
            to != pancakeswapPair &&
            swapAndLiquifyEnabled
        ) {
            //add liquidity
            swapAndLiquify(liquidifyAmount);
        }

        bool takeFee = true;

        if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            takeFee = false;
        }

        if (from == pancakeswapPair) {
            setBuyFee();
        } else if (to == pancakeswapPair) {
            setSellFee();
        }

        //transfer amount, it will take tax, burn, liquidity fee
        _tokenTransfer(from, to, amount, takeFee);
    }

    function swapAndLiquify(uint256 liquidifyAmount) private lockTheSwap {
        uint256 halfOfLiquify = liquidifyAmount.div(2);
        uint256 otherHalfOfLiquify = liquidifyAmount.sub(halfOfLiquify);

        uint256 initialBalance = IERC20(busdAddress).balanceOf(address(this));

        swapTokensForBUSD(halfOfLiquify); // <- this breaks the BNB -> TOKEN swap when swap+liquify is triggered

        uint256 newBalance = (IERC20(busdAddress).balanceOf(address(this))).sub(initialBalance);

        addLiquidity(otherHalfOfLiquify, newBalance);
        liquidityStore = 0;

        emit SwapAndLiquify(halfOfLiquify, newBalance, otherHalfOfLiquify);
    }

    function swapTokensForBUSD(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = busdAddress;

        _approve(address(this), address(pancakeSwapRouter), tokenAmount);

        pancakeSwapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of busd
            path,
            address(this),
            block.timestamp
        );
    }

    function swapBUSDForTokens(uint256 amount) private {
        address[] memory path = new address[](2);
        path[0] = busdAddress;
        path[1] = address(this);

        pancakeSwapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amount,
            0, // accept any amount of busd
            path,
            deadAddress,
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 busdAmount) private {
        _approve(address(this), address(pancakeSwapRouter), tokenAmount);

        pancakeSwapRouter.addLiquidity (
            address(this),
            busdAddress,
            tokenAmount,
            busdAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner(),
            block.timestamp
        );
    }

    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount,
        bool takeFee
    ) private {
        if (!takeFee) removeAllFee();
        _transferStandard(sender, recipient, amount);
        removeAllFee();
    }

    function _takeFee(
        uint256 tLiquidity,
        uint256 tMarketing,
        uint256 tBuybackAndBurn
    ) private {
        if(tBuybackAndBurn > 0) {
            _balances[address(this)].add(tBuybackAndBurn);
            swapBUSDForTokens(tBuybackAndBurn);
        }
        _balances[address(this)].add(tLiquidity);
        liquidityStore = liquidityStore.add(tLiquidity);
        _balances[marketingWallet] = _balances[marketingWallet].add(tMarketing);

    }

    function _transferStandard(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        uint256 tTransferAmount = _getValues(tAmount);

        _balances[sender] = _balances[sender].sub(tAmount);
        _balances[recipient] = _balances[recipient].add(tTransferAmount);

        emit Transfer(sender, recipient, tAmount);
    }

    function removeStuckToken(address _address) external onlyOwner {
        require(
            _address != address(this),
            "Can't withdraw tokens destined for liquidity"
        );
        require(
            IERC20(_address).balanceOf(address(this)) > 0,
            "Can't withdraw 0"
        );

        IERC20(_address).transfer(
            owner(),
            IERC20(_address).balanceOf(address(this))
        );
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

    function burn(address from, uint256 amount) public onlyOwner {
        require(_balances[from] >= amount, "not enough balance");
        _burn(from, amount);
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
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
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _spendAllowance(sender, recipient, amount);
        _transfer(sender, recipient, amount);
        return true;
    }

    function _spendAllowance(
        address owner,
        address recipient,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, msg.sender);
        // if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            if(msg.sender != recipient) {
                unchecked {
                    _approve(owner, msg.sender, currentAllowance - amount);
                }
            }
        // }
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
        return true;
    }
}