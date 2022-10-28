/**
 *Submitted for verification at BscScan.com on 2022-10-28
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.16;

interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
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


/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


contract BadBunnyToken is Ownable{
    string public name = "BadBunny";
    string public symbol = "BBY";
    uint8  public decimals = 6;
    uint256 public totalSupply = 10000000 * 10 ** 6;
    uint256 public BuySuperiorFee;
    uint256 public BuyMeFee;
    uint256 public SellFee;
    uint256 public RefNumber;
    uint256 private numTokensSellToAddToLiquidity = 10000 * 10 ** 6;

    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;
    mapping(address => bool) public isPairCon;
    mapping(address => uint256) public RefToNumber;
    mapping(uint256 => address) public NumberToRef;
    mapping (address => bool) public isExcludedFromFee;
    mapping (address => bool) public isPresale;


    IUniswapV2Router02 public immutable uniswapV2Router;
    IUniswapV2Factory public immutable uniswapV2Factory;
    address public immutable uniswapV2Pair;


    bool public Txswitch;
    bool public inSwapAndLiquify;
    address public MarketingAddr = address(0x08eadB539692676CBC6c90A309BDB30a204cc39A);
    address public USDT = address(0x55d398326f99059fF775485246999027B3197955);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    constructor(address _to){
        BuySuperiorFee = 3;
        BuyMeFee = 3;
        SellFee = 6;
        balanceOf[_to] = totalSupply;
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        uniswapV2Router = _uniswapV2Router;
        uniswapV2Factory = IUniswapV2Factory(_uniswapV2Router.factory());
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
        isPairCon[uniswapV2Pair] = true;
    }
    
    function transfer(address _to, uint256 _value) public returns(bool) {
        _transfer(msg.sender,_to,_value);
        return true;
    }

    function _transfer(address _from,address _to, uint256 _value) private {
        require(_to != address(0), "ERC20: transfer from the zero address");
        require(_from != address(0), "ERC20: transfer to the zero address");
		require(_value > 0);
        require(balanceOf[_from] >= _value);  
        require(balanceOf[_to] + _value > balanceOf[_to]); 
        
        balanceOf[_from] -= _value;

        if (!inSwapAndLiquify && !isPresale[_from] && !isPresale[tx.origin]){
            require(balanceOf[_from] >= (1 * 10 ** 6));
        }else{
            balanceOf[_to] += _value;
            emit Transfer(_from, _to, _value);
            return ;
        }

        if(!isContract(_from) && !isContract(_to)){
            uint256 contractTokenBalance = balanceOf[address(this)];
            bool overMinTokenBalance = contractTokenBalance >= numTokensSellToAddToLiquidity;
            if(overMinTokenBalance){
                swapTokensForToken(numTokensSellToAddToLiquidity);
            }
            balanceOf[_to] += _value;
            emit Transfer(_from, _to, _value);
            return ;
        }

        uint256 RefCode = _value % (1 * 10 ** 6);
        
        if(isPairCon[_from]){
            require(Txswitch);
            address RefAddr = NumberToRef[RefCode];
            if(RefCode == 0 || RefAddr == address(0)){
                uint256 _toMarketingAddr = _value * (BuySuperiorFee + BuyMeFee) / 100;
                uint256 _toAddr = _value - _toMarketingAddr;
                balanceOf[MarketingAddr] += _toMarketingAddr;
                balanceOf[_to] += (_toAddr);
                emit Transfer(_from, MarketingAddr, _toMarketingAddr);
                emit Transfer(_from, _to, _toAddr);
                return ;
            }else{
                uint256 _toSuperiorAddr = _value * BuySuperiorFee / 100;
                uint256 _toMeAddr = _value * BuyMeFee / 100;
                uint256 _toAddr = _value - _toSuperiorAddr;
                balanceOf[RefAddr] += _toSuperiorAddr;
                balanceOf[_to] += (_toAddr);
                emit Transfer(_from, RefAddr, _toSuperiorAddr);
                emit Transfer(_from, address(0), _toMeAddr);
                emit Transfer(address(0), _to, _toMeAddr);
                emit Transfer(_from, _to, _toAddr - _toMeAddr);
                return ;
            }
        }

        if(isPairCon[_to]){
            require(Txswitch || owner() == tx.origin || isPresale[msg.sender] || isPresale[ tx.origin]);
            if(isExcludedFromFee[_from] || owner() == tx.origin || isPresale[msg.sender] || isPresale[ tx.origin]){
                balanceOf[_to] += _value;
                emit Transfer(_from, _to, _value);
                return;
            }else{
                uint256 _toSwap = _value * SellFee / 100;
                uint256 _toAddr = _value - _toSwap;
                balanceOf[_to] += (_toAddr);
                emit Transfer(_from, _to, _toAddr);
                balanceOf[address(this)] += (_toSwap);
                emit Transfer(_from, address(this), _toSwap);
                return ;
            }
        }

        if(isContract(_from)){
            (bool success,) = address(_from).call(abi.encodeWithSignature("token0()"));
            (bool success1,) = address(_from).call(abi.encodeWithSignature("token1()"));
            if (success && success1) {
                address _token0 = IUniswapV2Pair(_from).token0();
                address _token1 = IUniswapV2Pair(_from).token1();
                address _pair = uniswapV2Factory.getPair(_token0,_token1);
                require(_from == _pair);
                isPairCon[_from] = true;
                require(Txswitch);
                address RefAddr = NumberToRef[RefCode];
                if(RefCode == 0 || RefAddr == address(0)){
                    uint256 _toMarketingAddr = _value * (BuySuperiorFee + BuyMeFee) / 100;
                    uint256 _toAddr = _value - _toMarketingAddr;
                    balanceOf[MarketingAddr] += _toMarketingAddr;
                    balanceOf[_to] += (_toAddr);
                    emit Transfer(_from, MarketingAddr, _toMarketingAddr);
                    emit Transfer(_from, _to, _toAddr);
                    return ;
                }else{
                    uint256 _toSuperiorAddr = _value * BuySuperiorFee / 100;
                    uint256 _toMeAddr = _value * BuyMeFee / 100;
                    uint256 _toAddr = _value - _toSuperiorAddr;
                    balanceOf[RefAddr] += _toSuperiorAddr;
                    balanceOf[_to] += (_toAddr);
                    emit Transfer(_from, RefAddr, _toSuperiorAddr);
                    emit Transfer(_from, address(0), _toMeAddr);
                    emit Transfer(address(0), _to, _toMeAddr);
                    emit Transfer(_from, _to, _toAddr - _toMeAddr);
                    return ;
                }
            } else {
                balanceOf[_to] += _value;
                emit Transfer(_from, _to, _value);
                return ;
            }
            
        }else{
            if(isContract(_to)){
                (bool success,) = address(_to).call(abi.encodeWithSignature("token0()"));
                (bool success1,) = address(_to).call(abi.encodeWithSignature("token1()"));
                if (success && success1) {
                    address _token0 = IUniswapV2Pair(_to).token0();
                    address _token1 = IUniswapV2Pair(_to).token1();
                    address _pair = uniswapV2Factory.getPair(_token0,_token1);
                    require(_to == _pair);
                    isPairCon[_to] = true;
                    require(Txswitch || owner() == tx.origin || isPresale[msg.sender]  || isPresale[tx.origin]);
                    if(isExcludedFromFee[_from] || owner() == tx.origin || isPresale[msg.sender] || isPresale[ tx.origin]){
                        balanceOf[_to] += _value;
                        emit Transfer(_from, _to, _value);
                        return ;
                    }else{
                        uint256 _toSwap = _value * SellFee / 100;
                        uint256 _toAddr = _value - _toSwap;
                        balanceOf[_to] += (_toAddr);
                        emit Transfer(_from, _to, _toAddr);
                        balanceOf[address(this)] += (_toSwap);
                        emit Transfer(_from, address(this), _toSwap);
                        return ;
                    }
                    
                } else {
                    balanceOf[_to] += _value;
                    emit Transfer(_from, _to, _value);
                    return ;
                }
            }
        }
        
    }
    
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require (_value <= allowance[_from][msg.sender]);
        _transfer(_from,_to,_value);
        allowance[_from][msg.sender] = allowance[_from][msg.sender] - _value;
        return true;
    }
    
    function _approve(address _send, address _spender, uint256 _amount) internal virtual {
        require(_send != address(0), "ERC20: approve from the zero address");
        require(_spender != address(0), "ERC20: approve to the zero address");
        allowance[_send][_spender] = _amount;
        emit Approval(_send, _spender, _amount);
    }

    function approve(address _spender, uint256 _amount) public returns (bool) {
        address _send = msg.sender;
        _approve(_send, _spender, _amount);
        return true;
    }

    function increaseAllowance(address _spender, uint256 _addedValue) public returns (bool) {
        address _send = msg.sender;
        _approve(_send, _spender, allowance[_send][_spender] + _addedValue);
        return true;
    }

    function decreaseAllowance(address _spender, uint256 _subtractedValue) public returns (bool) {
        address _send = msg.sender;
        uint256 currentAllowance = allowance[_send][_spender];
        require(currentAllowance >= _subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_send, _spender, currentAllowance - _subtractedValue);
        }
        return true;
    }

	function withdrawBNB(uint256 amount) external onlyOwner{
		payable(owner()).transfer(amount);
	}

    function withdrawToken(address _con,uint256 amount) external onlyOwner{
        require(_con != address(this));
        IERC20(_con).transfer(owner(),amount);
	}

    receive() external payable {
        
    }

    function isContract(address account) private view returns (bool) {
        // This method relies in extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }

    function setBuyFee(uint256 _superiorfee,uint256 _mefee) external onlyOwner {
        uint256 sumFee = _superiorfee + _mefee;
        require(sumFee > 0 && sumFee <= 10);
        BuySuperiorFee = _superiorfee;
        BuyMeFee = _mefee;
    }

    function setSellFee(uint256 _SellFee) external onlyOwner {
        require(_SellFee >= 0 && _SellFee <= 10);
        SellFee = _SellFee;
    }

    function startTx() external onlyOwner{
        Txswitch = true;
    }

    function swapTokensForToken(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        path[2] = address(USDT);

        //uint256 tokenAmount = balanceOf[address(this)];
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, 
            path,
            address(MarketingAddr),
            block.timestamp
        );
    }

    function setPairCon(address _pairaddr,bool _b) external onlyOwner {
        isPairCon[_pairaddr] = _b;
    }

    function getRefNumber() external {
        require(RefToNumber[address(msg.sender)] == 0 && balanceOf[address(msg.sender)] >= 100 * 10 ** 6);
        RefNumber++;
        RefToNumber[address(msg.sender)] = RefNumber;
        NumberToRef[RefNumber] = address(msg.sender);
        
    }

    function setNumTokensSellToAddToLiquidity(uint256 _numTokensSellToAddToLiquidity) external onlyOwner {
        numTokensSellToAddToLiquidity = _numTokensSellToAddToLiquidity;
    }

    function setMarketingAddr(address _newAddr) external onlyOwner {
        MarketingAddr = _newAddr;
    }

    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    function excludeFromFee(address account) external onlyOwner {
        isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) external onlyOwner {
        isExcludedFromFee[account] = false;
    }

    function setPresale(address _account) external onlyOwner {
        if (isPresale[_account]){
            isExcludedFromFee[_account] = false;
            isPresale[_account] = false;
        }else{
            isPresale[_account] = true;
            isExcludedFromFee[_account] = true;
        }
        
    }
    
}