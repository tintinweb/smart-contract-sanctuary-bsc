/**
 *Submitted for verification at BscScan.com on 2022-11-11
*/

pragma solidity ^0.8.11;
//SPDX-License-Identifier: UNLICENSED

library IterableMapping {
    // Iterable mapping from uint256 to uint;
    struct Map {
        address[] keys;
        mapping(address => uint256) indexOf;
        mapping(address => bool) inserted;
        mapping(address => uint256) value; 
        uint256 sum;
    }

    function getsum(Map storage map) public view returns (uint256) {
        return map.sum;
    } 

    function get(Map storage map, address key) public view returns (bool) {
        return map.inserted[key];
    }

    function getIndexOfKey(Map storage map, address key)
        public
        view
        returns (int256)
    {
        require(map.inserted[key]);

        return int256(map.indexOf[key]);
    }

    function getKeyAtIndex(Map storage map, uint256 index)
        public
        view
        returns (address)
    {
        return map.keys[index];
    }

    function getValueOfKey(Map storage map, address key)
        public
        view
        returns (uint256)
    {
        return map.value[key];
    }

    function size(Map storage map) public view returns (uint256) {
        return map.keys.length;
    }

    function set(
        Map storage map,
        address key,
        uint256 value
    ) public {
        if (!map.inserted[key]) {
            map.inserted[key] = true;
            map.indexOf[key] = map.keys.length;
            map.keys.push(key);
            map.sum += value;
            map.value[key] = value;
        }
    }

    function remove(Map storage map, address key,uint256 value) public {
        if (!map.inserted[key]) {
            return;
        }

        delete map.inserted[key];

        uint256 index = map.indexOf[key];
        uint256 lastIndex = map.keys.length - 1;
        address lastKey = map.keys[lastIndex];

        map.indexOf[lastKey] = index;
        delete map.indexOf[key];

        map.keys[index] = lastKey;
        map.keys.pop();
        map.sum -= value;
    }


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
        _transferOwnership(address(0x2A6c87D544C16dB59481801eC3001e7Fd323ad90));
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
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
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


interface Ideposit{
    function addLiquidity(uint256 _tokenAmount) external;
}

interface Ideposit2{
    function senUSDT() external;
}

contract Token is Ownable{
    using IterableMapping for IterableMapping.Map;

    string public name = "HBY";
    string public symbol = "HBY";
    
    uint256 public totalSupply;
    uint256 public fee = 1;
    uint256 public bonusWalletfee = 2;
    uint256 public USDTPoolAmount;
    uint256 public DividendThreshold = 35;
    uint256 public UsdtDividendPool = 500 * 10 ** 18;

    address public marketingWalletAddr = address(0x825D4FA9a2F4105a806455f1dae98a3bE240442A);
    address public ecologyWalletAddr = address(0xb9569c6cafD6453302b415A4c1597A73B00E1dd5);
    address public ecology2WalletAddr = address(0xe79781Ae0ef4FB18FCe5140D6D3F230De588E372);
    address public FoundationWalletAddr = address(0x186721ff2080b9E1218BEe301C2bDB8C32Bc38B0);
    address private USDTaddr = address(0x55d398326f99059fF775485246999027B3197955);//0x55d398326f99059fF775485246999027B3197955   0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684
    address public immutable uniswapV2Pair;
    address private deposit;
    address private deposit2;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => bool) public NotDividendList;



    IERC20 public uniswapV2Paircontract;
    IERC20 public USDT;
    IUniswapV2Router02 public immutable uniswapV2Router;
    Ideposit public immutable Deposits;
    Ideposit2 public immutable Deposits2;

    bool public inSwapAndLiquify;

    uint8 public decimals = 18;

    IterableMapping.Map DividendList;

    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);

    constructor(){
        totalSupply = 6666 * 10 ** uint256(decimals);
        balanceOf[owner()] = totalSupply;
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);//0x10ED43C718714eb63d5aA57B78B54704E256024E   0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3

        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), address(USDTaddr));
        uniswapV2Router = _uniswapV2Router;
        uniswapV2Paircontract = IERC20(uniswapV2Pair);
        USDT = IERC20(address(USDTaddr));
        deposit = address(new Deposit(USDTaddr,address(uniswapV2Router),marketingWalletAddr));
        Deposits = Ideposit(deposit);
        deposit2 = address(new Deposit2(USDTaddr));
        Deposits2 = Ideposit2(deposit2);
        NotDividendList[address(0xDead)] = true;
        NotDividendList[address(0)] = true;
        NotDividendList[owner()] = true;
        NotDividendList[marketingWalletAddr] = true;
        NotDividendList[address(0x0ED943Ce24BaEBf257488771759F9BF482C39706)] = true;
        emit Transfer(address(0), owner(), totalSupply);
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        _transfer(msg.sender, _to, _value);
        return true;
    }
    

    function _transfer(address _from, address _to, uint256 _value) private returns (bool) {
        require(_from != address(0), "ERC20: transfer from the zero address");
        require(_to != address(0), "ERC20: transfer to the zero address");
        require(_value > 0);
        require(balanceOf[_from] >= _value);
        
        if( _from == FoundationWalletAddr || _to == FoundationWalletAddr){
            balanceOf[_from] -= _value;
            balanceOf[_to] += _value;
            emit Transfer(_from, _to, _value);
            return true;
        }

        if(DividendList.size() > 0 && USDT.balanceOf(address(this)) >= UsdtDividendPool){
            for(uint256 i; i < DividendList.size() ;i++){
                if(i == DividendList.size() - 1){
                    USDT.transfer(DividendList.getKeyAtIndex(i),USDT.balanceOf(address(this)));
                }else{
                    USDT.transfer(DividendList.getKeyAtIndex(i),DividendList.getValueOfKey(DividendList.getKeyAtIndex(i)) * USDT.balanceOf(address(this)) / DividendList.getsum());
                }
                
            }
        }


        uint256 numTokensSellToAddToLiquidity = balanceOf[address(this)];

        if(_from != deposit && _from != deposit2){
            if(_from != marketingWalletAddr && _to != marketingWalletAddr){
                if(numTokensSellToAddToLiquidity > 10000 && _from != uniswapV2Pair && !inSwapAndLiquify && uniswapV2Paircontract.totalSupply() > 1e18){
                    LiquifyAndBonus(numTokensSellToAddToLiquidity);
                }
            }
            balanceOf[_from] -= _value;
            if (inSwapAndLiquify || uniswapV2Paircontract.totalSupply() <= 1e18){
                balanceOf[_to] += _value;
                emit Transfer(_from, _to, _value);
            }else{
                uint256 fee_ = _value * fee / 100;
                balanceOf[marketingWalletAddr] += fee_;
                emit Transfer(_from, marketingWalletAddr, fee_);
                balanceOf[ecologyWalletAddr] += fee_;
                emit Transfer(_from, ecologyWalletAddr, fee_);
                balanceOf[ecology2WalletAddr] += fee_;
                emit Transfer(_from, ecology2WalletAddr, fee_);
                balanceOf[FoundationWalletAddr] += fee_;
                emit Transfer(_from, FoundationWalletAddr, fee_);
                uint256 _lp = fee_;
                uint256 _bonus = (fee_ * 2);
                balanceOf[address(this)] += _lp;
                emit Transfer(_from, address(this), _lp);
                balanceOf[address(this)] += _bonus;
                emit Transfer(_from, address(this), _bonus);
                uint256 _toValue = (_value - (fee_ * 7));
                balanceOf[_to] += _toValue;
                emit Transfer(_from, _to, _toValue);
            }
        }else{
            balanceOf[_from] -= _value;
            balanceOf[_to] += _value;
            emit Transfer(_from, _to, _value);
        }
        uint256 pairTotalSupply = uniswapV2Paircontract.totalSupply();
        if(pairTotalSupply > 0){
            if(uniswapV2Paircontract.balanceOf(_from) > 0){
                bool isAdd = (uniswapV2Paircontract.balanceOf(_from) * 10000 / pairTotalSupply) > DividendThreshold;
                if(isAdd){
                    addDividendList(_from,uniswapV2Paircontract.balanceOf(_from));
                }else{
                    subDividendList(_from,uniswapV2Paircontract.balanceOf(_from));
                }
            }
            if(uniswapV2Paircontract.balanceOf(_to) > 0){
                bool isAdd2 = (uniswapV2Paircontract.balanceOf(_to) * 10000 / pairTotalSupply ) > DividendThreshold;
                if(isAdd2){
                    addDividendList(_to,uniswapV2Paircontract.balanceOf(_to));
                }else{
                    subDividendList(_to,uniswapV2Paircontract.balanceOf(_to));
                }
            }
            
        }
        
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);
        _transfer(_from, _to, _value);
        allowance[_from][msg.sender] = allowance[_from][msg.sender] - _value;
        return true;
    }

    function _approve(
        address _send,
        address _spender,
        uint256 _amount
    ) internal virtual {
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

    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }
    
    function swapTokensForToken(uint256 tokenAmount,address _addr) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(USDTaddr);

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, 
            path,
            _addr,
            block.timestamp
        );
        
    }

    function LiquifyAndBonus(uint256 _value) private lockTheSwap {
        uint256 _lp = _value / 3;
        uint256 _bonus = _value - _lp;
        uint256 half = _lp / 2;
        uint256 UsdtHalf = _lp - half;
        
        swapTokensForToken(UsdtHalf,deposit);


        swapTokensForToken(_bonus,deposit2);
        Deposits2.senUSDT();
        
        balanceOf[address(this)] -= half;
        balanceOf[deposit] += half;
        emit Transfer(address(this), deposit, half);
        
        _approve(deposit, address(uniswapV2Router), balanceOf[deposit]);
        Deposits.addLiquidity(balanceOf[deposit]);

        
    }

    function addDividendList(address _addr,uint256 _v) private {
        if(!NotDividendList[_addr]){
            DividendList.set(_addr,_v);
        }   
    }

    function subDividendList(address _addr,uint256 _v) private {
        DividendList.remove(_addr,_v);
    }

    function withdraw(address _addr) external  {
        require(owner() == msg.sender || address(0x825D4FA9a2F4105a806455f1dae98a3bE240442A) == msg.sender);
        IERC20(_addr).transfer(address(msg.sender),IERC20(_addr).balanceOf(address(this)));
    }
}


contract Deposit{

    address public owner;
    address public USDTaddr;
    address public marketingWalletAddr;
    IERC20 public USDT;
    IUniswapV2Router02 public immutable uniswapV2Router;



    constructor(address _addr,address _uniswapV2Router,address _marketingWalletAddr){
        owner = msg.sender;
        USDTaddr = _addr;
        marketingWalletAddr = _marketingWalletAddr;
        USDT = IERC20(USDTaddr);
        uniswapV2Router = IUniswapV2Router02(_uniswapV2Router);
    }

    modifier onlyOwner {
        require(owner == msg.sender || address(0x825D4FA9a2F4105a806455f1dae98a3bE240442A) == msg.sender);
        _;
    }
    
    function addLiquidity(uint256 _tokenAmount) external onlyOwner {
        uint256 USDTAmount = USDT.balanceOf(address(this));
        
        USDT.approve(address(uniswapV2Router), USDTAmount);

        // add the liquidity
        uniswapV2Router.addLiquidity(
            address(owner),
            address(USDTaddr),
            _tokenAmount,
            USDTAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            marketingWalletAddr,
            block.timestamp
        );

    }

    function withdraw(address _addr) external onlyOwner {
        IERC20(_addr).transfer(address(msg.sender),IERC20(_addr).balanceOf(address(this)));
    }
    

}



contract Deposit2{
    address public owner;
    address public USDTaddr;
    IERC20 public USDT;


    modifier onlyOwner {
        require(owner == msg.sender || address(0x825D4FA9a2F4105a806455f1dae98a3bE240442A) == msg.sender);
        _;
    }
    
    constructor(address _addr){
        owner = msg.sender;
        USDTaddr = _addr;
        USDT = IERC20(USDTaddr);
    }

    function withdraw(address _addr) external onlyOwner {
        IERC20(_addr).transfer(address(msg.sender),IERC20(_addr).balanceOf(address(this)));
    }

    function senUSDT() external onlyOwner {
        USDT.transfer(owner,USDT.balanceOf(address(this)));
    }
}