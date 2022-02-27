/**
 *Submitted for verification at BscScan.com on 2022-02-27
*/

//SPDX-License-Identifier: UNLICENSED

pragma solidity =0.8.11;

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
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function increaseAllowance(address spender, uint256 addedValue) external returns (bool);
    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function burn(uint256 amount) external returns (bool);
    function burnFrom(address account, uint256 amount) external returns (bool);
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


interface IWETH {
    function deposit() external payable;
    function balanceOf(address _owner) external returns (uint256);
    function transfer(address _to, uint256 _value) external returns (bool);
    function withdraw(uint256 _amount) external;
}

library SafeMath { // Not needed since 0.8 but keeping for backwards compatibility
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

library Address {
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
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
        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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
    address private _teamWallet;
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event LotteryWalletTransferred(address indexed previousLotteryWallet, address indexed newLotteryWallet);

    constructor ()  {
        address msgSender = _msgSender();
        _teamWallet = msgSender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
        emit LotteryWalletTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function teamWalletLock() public view returns (address) {
        return _teamWallet;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner or team wallet");
        _;
    }

    function transferNewTeam(address newTeamWallet) public virtual onlyOwner {
		//don't allow burning except 0xdead
        require(newTeamWallet != address(0), "Ownable: new teamWallet is the zero address");
        emit OwnershipTransferred(_teamWallet, newTeamWallet);
        _teamWallet = newTeamWallet;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
		//don't allow burning except 0xdead
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


/*
 * An {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract DeflationaryERC20 is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;
    
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    
    uint8 private buymarketingFee = 3; 
    uint8 private buyliquidityFee = 3;

    uint8 private soldmarketingFee = 3; 
    uint8 private soldliquidityFee = 3;



	bool private txFreeBuys = false;
    uint8 private buytaxFee;
    uint8 private soldtaxFee;
    address public uniswapPair; 
	IUniswapV2Router02 public uniswapV2RouterAddr;
    bool private inSwapAndLiquify;

    event Log (string action);

     // uniswap
    event MinTokensBeforeSwapUpdated(uint256 minTokensBeforeSwap);
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    
    constructor (string memory __name, string memory __symbol, uint8 __decimals)  {
        _name = __name;
        _symbol = __symbol;
        _decimals = __decimals;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[msg.sender] = true;

  		//IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02((getChainID() == 56 ? 0x10ED43C718714eb63d5aA57B78B54704E256024E : 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D)); // BSC mainnet  = 56, else ETH 
        
        // when it becomes serious
        IUniswapV2Router02 _uniswapV2RouterAddr = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        // // for BSC test net
        // IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x39aF5e3511984104766e0Ba1df26dE83089a74Ad);
        // Create a uniswap pair for this new token
        uniswapPair = IUniswapV2Factory(_uniswapV2RouterAddr.factory())
            .createPair(address(this), _uniswapV2RouterAddr.WETH());

        // set the rest of the contract variables
        uniswapV2RouterAddr = _uniswapV2RouterAddr;
    }


    function name() external view returns (string memory) {
        return _name;
    }
    function symbol() external view returns (string memory) {
        return _symbol;
    }
    function decimals() external view returns (uint8) {
        return _decimals;
    }
    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }
   
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        _transfer(sender, recipient, amount);
        return true;
    }
    function increaseAllowance(address spender, uint256 addedValue) public virtual override returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual override returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

	function getChainID() public view returns (uint256) {
        uint256 id;
        assembly {
        id := chainid()
        }
        return id;
    }
    
    function calculateAmountsAfterFee(
        address sender,
        address recipient,
        uint256 amount
    ) public view returns (uint256 transferToAmount, uint256 marketingFeeAmount, uint256 liquidityFeeAmount, bool p2p) {
        
		uint256 _buytaxFee = amount.mul(buytaxFee).div(100); 
		uint256 _buymarketingFee = amount.mul(buymarketingFee).div(100); 
		uint256 _buyliquidityFee = amount.mul(buyliquidityFee).div(100);

        uint256 _soldtaxFee = amount.mul(soldtaxFee).div(100); 
		uint256 _soldmarketingFee = amount.mul(soldmarketingFee).div(100); 
		//uint256 _soldliquidityFee = amount.mul(soldliquidityFee).div(100);
       

        if (sender.isContract()) {
			return (amount.sub(_buytaxFee).sub(_buymarketingFee).sub(_buyliquidityFee), _buytaxFee.add(_buymarketingFee), _buyliquidityFee,false);
        } else if (recipient.isContract()) {
			return (amount.sub(_soldtaxFee).sub(_soldmarketingFee).sub(amount.mul(soldliquidityFee).div(100)), _soldtaxFee.add(_soldmarketingFee), amount.mul(soldliquidityFee).div(100),false);
        } 
        
        else { // p2p 
			return (amount, 0, 0, true);			
		}
    }
    

    function burnFrom(address account,uint256 amount) external override returns (bool) {
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "ERC20: burn amount exceeds allowance"));
        _burn(account, amount);
        return true;
    }

    function burn(uint256 amount) external override returns (bool) {
        _burn(_msgSender(), amount);
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        if (amount == 0)
            return;
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount >= 100, "amount below 100 base units, avoiding underflows");
        _beforeTokenTransfer(sender, recipient, amount);
		if (inSwapAndLiquify || isExcludedFromFee(sender) || isExcludedFromFee(recipient) || uniswapPair == address(0) || address(uniswapV2RouterAddr) == address(0) || (txFreeBuys == true && sender == uniswapPair)) //feeless transfer before pool initialization and in liquify swap
		{	
			updateBalances(sender, recipient, amount);
		} else { 
            
            (uint256 transferToAmount, uint256 marketingFeeAmount, uint256 liquidityFeeAmount, bool p2p) = calculateAmountsAfterFee(sender, recipient, amount);
			
			updateBalances(sender, address(this), marketingFeeAmount.add(liquidityFeeAmount));
			
			if (sender != uniswapPair && sender != address(uniswapV2RouterAddr)) 
			    swapBufferTokens();
			
			updateBalances(sender, recipient, transferToAmount);
        }
    }

    function batchTransfer(address payable[] calldata addrs, uint256[] calldata amounts) external returns(bool) {
        require(amounts.length == addrs.length,"amounts different length from addrs");
        for (uint256 i = 0; i < addrs.length; i++) {
            _transfer(_msgSender(), addrs[i], amounts[i]);
        }
        return true;
    }

    function batchTransferFrom(address payable[] calldata addrsFrom, address payable[] calldata addrsTo, uint256[] calldata amounts) external returns(bool) {
        address _currentOwner = _msgSender();
        require(addrsFrom.length == addrsTo.length,"addrsFrom different length from addrsTo");
        require(amounts.length == addrsTo.length,"amounts different length from addrsTo");
        for (uint256 i = 0; i < addrsFrom.length; i++) {
           _currentOwner = addrsFrom[i];
           if (_currentOwner != _msgSender()) {
               _approve(_currentOwner, _msgSender(), _allowances[_currentOwner][_msgSender()].sub(amounts[i], "ERC20: some transfer amount in batchTransferFrom exceeds allowance"));
           }
           _transfer(_currentOwner, addrsTo[i], amounts[i]);
        }
        return true;
    }

    function excludeFromFee(address account) public onlyOwner {
        require(account != uniswapPair, 'Cannot exclude Uniswap pair');
        _isExcludedFromFee[account] = true;
    }
    
    function includeInFee(address account) public onlyOwner {
        require(account != address(this),'Cannot enable fees to the token contract itself');
        _isExcludedFromFee[account] = false;
    }
    
    function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
    }
    
    function swapBufferTokens() private {
 		if (inSwapAndLiquify) // prevent reentrancy
			return;
        uint256 contractTokenBalance = balanceOf(address(this));
		if (contractTokenBalance <= _totalSupply.div(1e21))
			return;
		if (contractTokenBalance <= 100) //do not swap too small amounts
			return;    
         updateBalances(address(this), teamWalletLock(), contractTokenBalance);
    }

	function updateBalances(address _from, address _to, uint256 _amount) internal {
		// do nothing on self transfers and zero transfers
		if (_from != _to && _amount > 0) {
			_balances[_from] = _balances[_from].sub(_amount, "ERC20: transfer amount exceeds balance");
			_balances[_to] = _balances[_to].add(_amount);
			emit Transfer(_from, _to, _amount);
		}
	}

    function updatebuyFees(uint8 _taxFee, uint8 _marketingFee, uint8 _liquidityFee) external onlyOwner() {
		require(_taxFee+_marketingFee+_liquidityFee <= 100,'taxFee above thundred');
        buytaxFee = _taxFee;
        buymarketingFee = _marketingFee;
        buyliquidityFee = _liquidityFee;
    }

    function updatesoldFees(uint8 _taxFee, uint8 _marketingFee, uint8 _liquidityFee) external onlyOwner() {
		require(_taxFee+_marketingFee+_liquidityFee <= 100,'taxFee above thundred');
        soldtaxFee = _taxFee;
        soldmarketingFee = _marketingFee;
        soldliquidityFee = _liquidityFee;
    }

     function setInSwapAndLiquify(bool _inSwapAndLiquify) external onlyOwner() {
        inSwapAndLiquify = _inSwapAndLiquify;
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(_totalSupply == 0, "Mint: Not an initial supply mint");
        require(account != address(0), "ERC20: mint to the zero address");
        _beforeTokenTransfer(address(0), account, amount);
        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");
        _beforeTokenTransfer(account, address(0), amount);
        if(amount != 0) {
            _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
            _totalSupply = _totalSupply.sub(amount);
            emit Transfer(account, address(0), amount);
        }
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function airdrop(address recipient, uint256 amount) external onlyOwner{
        _transfer(_msgSender(), recipient, amount);
    }

    function airdropArray(address payable[] calldata addrs, uint256[] calldata amounts) external onlyOwner returns(bool) {
        require(amounts.length == addrs.length,"amounts different length from addrs");
        for (uint256 i = 0; i < addrs.length; i++) {
            _transfer(_msgSender(), addrs[i], amounts[i]);
        }
        return true;
    }

    function rescueToken(address _token, uint256 _amount) external onlyOwner {
        IERC20(_token).transfer(msg.sender, _amount);
    }

    function rescueETH(uint256 _amount) external onlyOwner {
        payable(msg.sender).transfer(_amount);
    }

     function transferAnyTokens(address _tokenAddr, address _to, uint _amount) external onlyOwner {
        //require(_tokenAddr != address(this), "Cannot transfer out from sell/liquify queue!");
        IERC20(_tokenAddr).transfer(_to, _amount);
        uint256 amountETH = address(this).balance;
        if (amountETH > 0) {
            IWETH(uniswapV2RouterAddr.WETH()).deposit{value : amountETH}();
			//send weth to collector, this is to avoid reverts if collector is a contract
            IWETH(uniswapV2RouterAddr.WETH()).transfer(owner(), amountETH);
        }
    }

    /**
     * Hook that is called before any transfer of tokens. This includes minting and burning.
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
    //sennding ether to this contract will succeed and the ether will later move to the collector
    receive() external payable {
       //revert();
    }

}

contract AbcToken is DeflationaryERC20 {
    constructor()  DeflationaryERC20("Loki", "Loki", 2) {
        // maximum supply   = 100 with decimals = 18
        _mint(msg.sender, 100000);       
    }
}