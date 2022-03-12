/**
 *Submitted for verification at BscScan.com on 2022-03-12
*/

// SPDX-License-Identifier: MIT



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

// File: contracts/Ownable.sol



pragma solidity ^0.8.0;


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
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: contracts/IERC20.sol



pragma solidity ^0.8.0;

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

// File: contracts/IERC20Metadata.sol



pragma solidity ^0.8.0;


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

// File: contracts/MetaCat.sol


pragma solidity ^0.8.0;




interface IPancakeFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;

    function INIT_CODE_PAIR_HASH() external view returns (bytes32);
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
    event Swap(address indexed sender, uint amount0In, uint amount1In, uint amount0Out, uint amount1Out, address indexed to);
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

interface IPancakeRouter01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(address tokenA, address tokenB, uint amountADesired, uint amountBDesired, uint amountAMin, uint amountBMin, address to, uint deadline ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(address token, uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(address tokenA, address tokenB, uint liquidity, uint amountAMin, uint amountBMin, address to, uint deadline) external returns (uint amountA, uint amountB);
    function removeLiquidityETH( address token, uint liquidity, uint amountTokenMin, address to, uint deadline) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(address tokenA, address tokenB, uint liquidity, uint amountAMin, uint amountBMin, address to, uint deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(uint amountIn,uint amountOutMin,address[] calldata path,address to,uint deadline) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IPancakeRouter02 is IPancakeRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(uint amountOutMin, address[] calldata path, address to, uint deadline ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
}

contract MetaCat is Ownable, IERC20, IERC20Metadata{
    //token-param
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    uint256 private _totalDestroy;
    uint256 private _totalSurplus;
    string private _name;
    string private _symbol;
    //apply-param
    mapping(address=>address) private _prarentMap;
    mapping(address=>bool) private _whiteList;
    //address-param
    address public _marketing = 0x8fbB764BCEa3E6bC98CE23be8F394A82752262bC; // 1%
    address public _pairPool = 0x9A792fB836d59Ae6A8051D8Dfb9c0711f399F28E;  // 2%

    address public _yuanToos = 0x88e82023AFF20F5B3e906f9d67b2FA09fD682bEe; // 38% Yuan yu zhou (250800)
    address public _lpsToos = 0x9A792fB836d59Ae6A8051D8Dfb9c0711f399F28E;  // 20% lps(132000)
    address public _chibi = 0x8fbB764BCEa3E6bC98CE23be8F394A82752262bC;   // 15% chibi fen hong (99000)
    address public _ido = 0x553fa13562991a6B522D7Abc3F0B0047aE395601;      // 10% 5%  shizhi  jishu (99000)
    address public _fund = 0xaaA085A025B3AD27A04951f27db2AE2b0c0866fd;     // 2% 10%  kongtu shengtai (79200)
    //swap router
    IPancakeRouter02 public _router;
    //swap pair
    address public _pair;

    //apply-method
    function addParentMap(address recipient) private {
        if(_prarentMap[recipient] == address(0)){
            if(msg.sender == _pair || recipient ==  _pair) return;
            if(msg.sender == recipient) return;
            if(recipient == _prarentMap[msg.sender]) return;
            _prarentMap[recipient] = msg.sender;
        }
    }

    function getParentMap(address sender) public view returns(address) {
        return _prarentMap[sender];
    }

    // dnamic
    function dnamicRewards(address sender, uint256 amount) private {

        address parent = _prarentMap[sender];

        uint256 total = amount * 4 / 100;

        uint256 reward = 0;

        for (uint i = 0; i < 10; i++) {

            if(parent != address(0)){
                
                if(i == 0){//level 1
                    reward = amount * 1 / 100;
                }

                if(i == 1){//level 2
                    reward = amount * 6 / 1000;
                }

                if(i >= 2){//level 3-10
                    reward = amount * 3 / 1000;
                }

                _balances[parent] += reward;

                total -= reward;

                emit Transfer(sender, parent, reward);

                parent = _prarentMap[parent];
            }
        }

        if(total != 0){
            emit Transfer(sender, address(0), total);
        }
        
    }
    //"1000000000000000000"
    function airdrop(address[] memory addrlist, uint256 amount) public returns(bool) {

        require(addrlist.length != 0, "ERC20: airdrop address not is empty");

        require(addrlist.length <= 50, "ERC20: airdrop address max 50");

        for(uint i = 0; i < addrlist.length; i++) {
            if(addrlist[i] != _pairPool && addrlist[i] != _marketing && addrlist[i] != _yuanToos && addrlist[i] != _lpsToos && addrlist[i] != _chibi && addrlist[i] != _ido && addrlist[i] != _fund){
                transfer(addrlist[i],amount);
            }
        }

        return true;
    }

    //token-method
    constructor() {

        _name = "MetaCat";

        _symbol = "MCT";

        _initWhite();

        _initMake(660000 * 10**18, 250800 * 10**18, 132000 * 10**18, 99000 * 10**18, 99000 * 10**18, 79200 * 10**18);

        //IPancakeRouter02 router = IPancakeRouter02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);//binance PANCAKE V2 testbsc
        IPancakeRouter02 router = IPancakeRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E);//binance PANCAKE V2 maintbsc
        // set the rest of the contract variables	
        _router = router;
        // Create a uniswap pair for this new token
        _pair = IPancakeFactory(router.factory()).createPair(address(this), router.WETH());
        // distribution dao node ido drop

    }
    
    function _initMake(uint256 amount, uint256 u_yuanToos, uint256 u_lpsToos, uint256 u_chibi, uint256 u_ido, uint256 u_fund) private {
        _totalSupply = amount;
        _totalSurplus = amount - (6666 * 10**18);
        _balances[_yuanToos] = u_yuanToos;
        emit Transfer(address(0), _yuanToos, u_yuanToos);
        _balances[_lpsToos] = u_lpsToos;
        emit Transfer(address(0), _lpsToos, u_lpsToos);
        _balances[_chibi] = u_chibi;
        emit Transfer(address(0), _chibi, u_chibi);
        _balances[_ido] = u_ido;
        emit Transfer(address(0), _ido, u_ido);
        _balances[_fund] = u_fund;
        emit Transfer(address(0), _fund, u_fund);
    }

    function _initWhite() private{
        _whiteList[_yuanToos] = true;
        _whiteList[_lpsToos] = true;
        _whiteList[_chibi] = true;
        _whiteList[_ido] = true;
        _whiteList[_fund] = true;
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

    function totalDestroy() public view virtual returns (uint256) {
        return _totalDestroy;
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

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    //to recieve ETH from swapV2Router when swaping
    receive() external payable {}

    function withdraw() payable public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function withdrawCoin(address recipient) public onlyOwner {
        uint256 amount = balanceOf(address(this));
        _transfer(address(this), recipient, amount);
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        addParentMap(recipient);
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }

        if(sender != _pair){
            require(_balances[sender] >= (1 * 10**18), "ERC20: Transfer balance must be greater than one");
        }

        if(sender == _pair || recipient == _pair){
            if(_whiteList[sender] || _whiteList[recipient]){
                _balances[recipient] += amount;
                emit Transfer(sender, recipient, amount);
            }else{
                // 1% destroy
                uint256  number_ = (amount*1/100);
                uint256  _number = _totalSurplus - _totalDestroy;
                
                if(number_ > _number){
                    number_ = _number;
                }

                if(number_ > 0){
                    _totalSupply = _totalSupply - number_;
                    _totalDestroy = _totalDestroy + number_;
                    emit Transfer(sender, address(0), number_);
                }

                // 1% marketing
                _balances[_marketing] += (amount*1/100);
                emit Transfer(sender, _marketing, amount*1/100);
                // 2% lp
                _balances[_pairPool] += (amount*2/100);
                emit Transfer(sender, _pairPool, amount*2/100);
                // 4% share
                if(recipient == _pair){
                    dnamicRewards(sender, amount);
                }else{
                    dnamicRewards(tx.origin, amount);
                }
                // 92% surplus
                _balances[recipient] += (amount*92/100);
                emit Transfer(sender, recipient, (amount*92/100));
            }

        }else{
            _balances[recipient] += amount;
            emit Transfer(sender, recipient, amount);
        }
        
        //add lps
        if(_balances[_pairPool] >= 100 * 10**18){
            _balances[_pair] += _balances[_pairPool];
            emit Transfer(_pairPool, _pair, _balances[_pairPool]);
            _balances[_pairPool]=0;
            IPancakePair(_pair).sync();
        }

    }

}