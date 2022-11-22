// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) internal pure returns (bytes memory) {
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

library Math {
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function safeSub(uint256 a, uint256 b) internal pure returns (uint256) {
        if (b > a) {
            return 0;
        } else {
            return a - b;
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }

    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}

library SafeERC20 {
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        require((value == 0) || (token.allowance(address(this), spender) == 0), "SafeERC20: approve from non-zero to non-zero allowance");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
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

interface ISwapPair {
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

interface ISwapRouter01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA, address tokenB, uint amountADesired, uint amountBDesired, uint amountAMin, uint amountBMin, address to, uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function addLiquidityETH(
        address token, uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address to, uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function removeLiquidity(
        address tokenA, address tokenB, uint liquidity, uint amountAMin, uint amountBMin, address to, uint deadline
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETH(
        address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline
    ) external returns (uint amountToken, uint amountETH);

    function removeLiquidityWithPermit(
        address tokenA, address tokenB, uint liquidity, uint amountAMin, uint amountBMin, address to, uint deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETHWithPermit(
        address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);

    function swapExactTokensForTokens(
        uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline
    ) external returns (uint[] memory amounts);

    function swapTokensForExactTokens(
        uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline
    ) external returns (uint[] memory amounts);
    
    function swapExactETHForTokens(
        uint amountOutMin, address[] calldata path, address to, uint deadline
    ) external payable returns (uint[] memory amounts);
    
    function swapTokensForExactETH(
        uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline
    ) external returns (uint[] memory amounts);
    
    function swapExactTokensForETH(
        uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline
    ) external returns (uint[] memory amounts);
    
    function swapETHForExactTokens(
        uint amountOut, address[] calldata path, address to, uint deadline
    ) external payable returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface ISwapRouter02 is ISwapRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline
    ) external returns (uint amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin, address[] calldata path, address to, uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline
    ) external;
}

interface ISwapFactory {
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

interface ISwapCallee {
    function swapCall(address sender, uint amount0, uint amount1, bytes calldata data) external;
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract Ownable {
    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        owner = msg.sender;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}

contract Whitelist is Ownable {

    mapping(address => bool) public whitelist;
    
    event WhitelistedAddressAdded(address addr);
    event WhitelistedAddressRemoved(address addr);

    modifier onlyWhitelisted() {
        require(whitelist[msg.sender], 'not whitelisted');
        _;
    }

    function addAddressToWhitelist(address addr) public onlyOwner returns(bool success) {
        if (!whitelist[addr]) {
            whitelist[addr] = true;
            emit WhitelistedAddressAdded(addr);
            success = true;
        }
    }

    function addAddressesToWhitelist(address[] calldata addrs) public onlyOwner returns(bool success) {
        for (uint256 i = 0; i < addrs.length; i++) {
            if (addAddressToWhitelist(addrs[i])) {
                success = true;
            }
        }
    }

    function removeAddressFromWhitelist(address addr) onlyOwner public returns(bool success) {
        if (whitelist[addr]) {
            whitelist[addr] = false;
            emit WhitelistedAddressRemoved(addr);
            success = true;
        }
    }

    function removeAddressesFromWhitelist(address[] calldata addrs) onlyOwner public returns(bool success) {
        for (uint256 i = 0; i < addrs.length; i++) {
            if (removeAddressFromWhitelist(addrs[i])) {
                success = true;
            }
        }
    }
}

contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
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

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);

        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount);
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal virtual {
        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}

/*
                                          ,ooooooooooo,
                                       ,;OOOOOOOOOOOOOOo,
                                    ,ooOOOOOOOOOOOOOOOOOo;,,,,
                                ,ooooOOOOOOOOOOOOOOOOOOOOooo(@`,
                     _  __   __;oooooo OOOOOOOOOOO; ;@@@@@@@o;@@`,
            _______/@@@@@@@@@)ooOOOOOO) oOOOOOOOOOo; ;[email protected]@@@@o;@@@:
           /######)@@@@@@@@@@( _______ ( oOOOOOOOOOOo [email protected]@@@@@`@@@`;
          <######)@@@@@@@@@@@@(######/  `,;;;  oOOOOOo @@@@@@o,\@@;
               `\@@@@@@@@@@@@(######/ oO (@@@@\ oOOOOO;@@@@@@@, \@`,
                ))@@@@@@@@@@(       [email protected]@@@@@: ;;oo,`[email protected]@@@@;   (@)
                )  `@@@@@@@( (  ooOOOOOoo:@@@@@: ,' /###[email protected]@@@;
                ( (0)     (0) ) ooooooo /@@@@@/,`  :####[email protected]@@@;
                 )           ( `'`'`'`'/@@@@@/     /###/:@@@@;
                  `,       ,'     /###/@@@@@/     :###; :@@@@@;
                    \_`_'_/      /###/@@@@/       :###; :@@@@@;
                     ~~~~~      ;###;@@@@/        :##;  `:@@@@;
                                ;###;@@@@;       /  /    :@@@;
                               /~~~~;@@@@;      `-^-'    /   \
        Wool Token + LMS       `-^--;@@@@/               `-^--'
         by Degen Protocol          :~~~~:   v1.0.0
                                    \/\_/
*/

contract WoolToken is ERC20, Whitelist {
    using SafeMath for uint256;

    struct StatInfo {
        uint256 txs;
        uint256 minted;
    }

    struct UserInfo {
        uint256 pending;
        uint256 total;

        uint256 lastBlock;
        uint256 lastTimestamp;
    }

    ///////////////////////////////
    // CONFIGURABLES & VARIABLES //
    ///////////////////////////////

    bool public initialSupplyMinted;

    address[] public excludedFromFees;

    address public feeRecipient;
    address public initialMintRecipient;

    uint8 public feePercent = 10; // 10% tax on transfers

    uint256 public totalTxs;
    uint256 public players;

    uint256 public initialSupplyAmount;

    //////////////////
    // DATA MAPPING //
    //////////////////

    mapping(address => StatInfo) private stats;
    mapping(address => UserInfo) private users;

    mapping (address => uint8) private _customTaxRate;
    
    mapping (address => bool) private _hasCustomTax;
    mapping (address => bool) private _isExcluded;

    mapping (address => bool) private _blacklisted;

    mapping (address => bool) private _dexRouter;
    mapping (address => bool) private _permitted;

    /////////////////////
    // CONTRACT EVENTS //
    /////////////////////

    event onTaxPayed(address indexed _from, address _to, uint256 _amount);

    event onSetBlacklist(address indexed _caller, bool _setting, uint256 _timestamp);
    event onMintInitialSupply(address indexed _caller, uint256 _amount, uint256 _timestamp);

    ////////////////////////////
    // CONSTRUCTOR & FALLBACK //
    ////////////////////////////

    constructor(address _feeRecipient) ERC20("Degen Protocol Wool", "WOOL") Ownable() {
        address _operator = msg.sender;

        addAddressToWhitelist(_operator);
        
        feeRecipient = _feeRecipient;
        initialSupplyAmount = 1000000 * (10**18);

        initialSupplyMinted = false;
        
        removeAddressFromWhitelist(_operator);
    }

    ////////////////////////////
    // PUBLIC WRITE FUNCTIONS //
    ////////////////////////////

    // Transfers
    function transfer(address _to, uint256 _value) public override returns (bool) {

        (uint256 adjustedValue, uint256 taxAmount) = calculateTransferTaxes(msg.sender, _value);

        if (taxAmount > 0){
            require(super.transfer(feeRecipient, taxAmount));
            emit onTaxPayed(msg.sender, feeRecipient, taxAmount);
        }
        require(super.transfer(_to, adjustedValue));

        return true;
    }

    // Transfers (using transferFrom)
    function transferFrom(address _from, address _to, uint256 _value) public override returns (bool) {

        (uint256 adjustedValue, uint256 taxAmount) = calculateTransferTaxes(_from, _value);

        if (taxAmount > 0){
            require(super.transferFrom(_from, feeRecipient, taxAmount));
            emit onTaxPayed(_from, feeRecipient, taxAmount);
        }
        require(super.transferFrom(_from, _to, adjustedValue));

        return true;
    }

    ///////////////////////////
    // PUBLIC VIEW FUNCTIONS //
    ///////////////////////////

    // stats of player, (txs, minted)
    function statsOf(address player) public view returns (uint256, uint256){
        return (stats[player].minted, stats[player].txs);
    }

    // Check if an address is recognized as a DEX
    function isDEX(address _addr) public view returns (bool) {
        return _dexRouter[_addr];
    }

    // Check if an address is permitted to handle liquidity
    function isPermitted(address _addr) public view returns (bool) {
        return _permitted[_addr];
    }

    // Check if an address is exempt from transfer taxes or not
    function isExcluded(address account) public view returns (bool) {
        return _isExcluded[account];
    } 

    // Calculate transfer taxes for WOOL
    function calculateTransferTaxes(address _from, uint256 _value) public view returns (uint256 adjustedValue, uint256 taxAmount){
        adjustedValue = _value;
        taxAmount = 0;

        if (!_isExcluded[_from]) {
            uint8 taxPercent = feePercent; // set to default tax 10%

            // set custom tax rate if applicable
            if (_hasCustomTax[_from]){
                taxPercent = _customTaxRate[_from];
            }

            (adjustedValue, taxAmount) = calculateTransactionTax(_value, taxPercent);
        }
        return (adjustedValue, taxAmount);
    }

    // Tokens available to mint
    function available(address _user)  external view returns (uint256) {
        if (users[_user].pending > 0 && block.number > users[_user].lastBlock.add(2)){
            return users[_user].pending;
        } else {
            return 0;
        }
    }

    // Mint readiness of an address (block cooldown)
    function ready(address _user)  external view  returns (bool) {
        return block.number > users[_user].lastBlock.add(2);
    }

    // Pending mintable tokens of an address
    function pending(address _user)  external view returns (uint256) {
        return users[_user].pending;
    } 

    // Last mint timestamp of an address
    function lastMint(address _user)  external view returns (uint256 lastBlock, uint256 lastTimestamp) {
        lastBlock = users[_user].lastBlock;
        lastTimestamp = users[_user].lastTimestamp;
    }

    ////////////////////////////////
    // OWNER-ONLY WRITE FUNCTIONS //
    ////////////////////////////////

    function initialMint(address _recipient) external onlyOwner() {
        require(initialSupplyMinted == false, "ALREADY_MINTED");

        initialMintRecipient = _recipient;

        _mint(initialMintRecipient, initialSupplyAmount);

        initialSupplyMinted = true;

        emit onMintInitialSupply(msg.sender, initialSupplyAmount, block.timestamp);
    }

    function setFeeRecipient(address _addr) external onlyOwner() {
        feeRecipient = _addr;
    }

    function setAccountCustomTax(address account, uint8 taxRate) external onlyOwner() {
        require(taxRate >= 0 && taxRate <= 100, "Invalid tax amount");
        _hasCustomTax[account] = true;
        _customTaxRate[account] = taxRate;
    }

    function removeAccountCustomTax(address account) external onlyOwner() {
        _hasCustomTax[account] = false;
    }

    function excludeAccount(address account) external onlyOwner() {
        require(!_isExcluded[account], "Account is already excluded");
        _isExcluded[account] = true;
        excludedFromFees.push(account);
    }

    function includeAccount(address account) external onlyOwner() {
        require(_isExcluded[account], "Account is already excluded");
        for (uint256 i = 0; i < excludedFromFees.length; i++) {
            if (excludedFromFees[i] == account) {
                excludedFromFees[i] = excludedFromFees[excludedFromFees.length - 1];
                _isExcluded[account] = false;
                delete excludedFromFees[excludedFromFees.length - 1];
                break;
            }
        }
    }

    ////////////////////////////////
    // RESTRICTED WRITE FUNCTIONS //
    ////////////////////////////////

    function claim() external returns (bool) {

        address _user = msg.sender;
        uint256 _amount = users[_user].pending;

        bool _minted = _mintTokens(_user, _amount);
        require(_minted == true, "FAILED_TO_MINT");

        settle(_user);

        return true;
    }

    function print(uint256 _amount) external onlyWhitelisted() returns (bool) {
        users[feeRecipient].total += _amount;
        users[feeRecipient].lastBlock = block.number;
        users[feeRecipient].lastTimestamp = block.timestamp;

        bool _minted = _mintTokens(feeRecipient, _amount);
        require(_minted == true, "FAILED_TO_MINT");

        return true;
    }

    function credit(address _user, uint256 _amount) public onlyWhitelisted() {
        users[_user].pending += _amount;
        users[_user].total += _amount;
        users[_user].lastBlock = block.number;
        users[_user].lastTimestamp = block.timestamp;
    }
    
    function settle(address _user) public onlyWhitelisted() {
        users[_user].pending = 0;
        users[_user].lastBlock = block.number;
        users[_user].lastTimestamp = block.timestamp;
    }

    function touch(address _user) public onlyWhitelisted() {
        users[_user].lastBlock = block.number;
        users[_user].lastTimestamp = block.timestamp;
    }

    //////////////////////////
    // OWNER-ONLY FUNCTIONS //
    //////////////////////////

    function toggleDEX(address _addr, bool _status) external onlyOwner() {
        _dexRouter[_addr] = _status;
    }

    function togglePermitted(address _addr, bool _status) external onlyOwner() {
        _permitted[_addr] = _status;
    }

    function toggleBlacklisted(address _addr, bool _bool) onlyOwner() public returns (bool) {
        require(_addr != address(0), "INVALID_ADDRESS");
        
        _blacklisted[_addr] = _bool;

        emit onSetBlacklist(msg.sender, _bool, block.timestamp);
        return true;
    }

    ///////////////////////////////////////
    // INTERNAL / PRIVATE VIEW FUNCTIONS //
    ///////////////////////////////////////

    function calculateTransactionTax(uint256 _value, uint8 _tax) internal pure returns (uint256 adjustedValue, uint256 taxAmount){
        taxAmount = _value.mul(_tax).div(100);
        adjustedValue = _value.mul(SafeMath.sub(100, _tax)).div(100);
        return (adjustedValue, taxAmount);
    }

    function _mintTokens(address _user, uint256 _amount) internal returns (bool) {

        // Blacklisted addresses get no minted tokens
        if (_blacklisted[_user]) {
            return false;
        }

        //Mint Tokens to user
        _mint(_user, _amount);

        return true;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override {
        
        // If token is from a DEX pair, 
        if(isDEX(from)) {

            // Require that the recipient is permitted to interact with pair
            require(isPermitted(to), "NOT_PERMITTED_TO_SWAP_WITH_DEX");
        }

        // If token is being sent to a DEX pair,
        if(isDEX(to)) {

            // Require that the sender is permitted to interact with pair
            require(isPermitted(from), "NOT_PERMITTED_TO_SWAP_WITH_DEX");
        }

        // Count fresh addresses in stats
        if (stats[to].txs == 0) {
            players += 1;
        }

        if (from == address(0)) {
            stats[to].minted += amount;
        }

        // Count user Txs
        stats[to].txs += 1;
        stats[from].txs += 1;

        // Count total Txs
        totalTxs += 1;
    }
}