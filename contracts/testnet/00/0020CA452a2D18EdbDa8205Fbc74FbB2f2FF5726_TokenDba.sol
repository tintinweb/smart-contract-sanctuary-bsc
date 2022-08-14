// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@uniswap/lib/contracts/libraries/TransferHelper.sol';
import '../lib/dxba.sol';
import '@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol';
import '@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol';
import '@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol';
contract TokenDba is ERC20{
    address public owner;
    address public devops;
    address public outSideFeeWallet;
    address public dailyRecv1399Wallet;
    address public swapFeeWallet;
    address public removeLpFeeWallet;
    address public transferFeeWallet;
    address public nftDbaWallet;
    address usdt;
    LibDXba.Lock public lockMessage; 
    LibDXba.fee public moreFee;
    uint constant tokenAmount = 1399 ether;
    uint constant lockAmount = 2500000 ether;
    address constant public _routerAddr = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1;
    IUniswapV2Router02 constant router = IUniswapV2Router02(_routerAddr);
    address public pair;
    bool inSolidity;
    bool isOpen;
    mapping(uint=>mapping(uint=>mapping(uint=>bool))) dailyUse;
    mapping(address=>bool) whiteList;
    mapping(address=>bool) allowList;
    modifier _owner {
        require(owner == msg.sender, "You are no owner");
        _;
    }
    modifier _devops {
        require(owner == msg.sender || devops == msg.sender, "You are no devops");
        _;
    }
    modifier dailyTrigger {
        uint[3] memory date = LibDXba.getDate(block.timestamp);
        require(!dailyUse[date[0]][date[1]][date[2]],"can not trigger mint, please wait tomorrow");
        _;
    }
    modifier allowTransaction {
        if(isOpen && !allowList[msg.sender] && msg.sender != _routerAddr && msg.sender != pair && msg.sender != address(this) ){ revert("The deal hasn't opened yet."); }
        _;
    }
    constructor(LibDXba.Init memory _init) ERC20(_init.name,_init.symbol) {
        
        _mint(address(this),_init.total * 1 ether);
        uint day = LibDXba.getDay(block.timestamp, 1646006400);
        
        _transfer(address(this), _init.grantsPurse, day * 1399 ether);
        _transfer(address(this),_init.institutionWallet,_init.institution * 1 ether);
        owner = msg.sender;
        devops = _init.devops;
        outSideFeeWallet = _init.outSideFeeWallet;
        dailyRecv1399Wallet = _init.dailyRecv1399Wallet;
        swapFeeWallet = _init.swapFeeWallet;
        removeLpFeeWallet = _init.removeLpFeeWallet;
        transferFeeWallet = _init.transferFeeWallet;
        nftDbaWallet = _init.nftDbaWallet;
        usdt = _init.usdt;
        pair = IUniswapV2Factory(router.factory()).createPair(address(this),usdt); 
        moreFee.poundage = 2;
        moreFee.removeLiquidity = 6;
        moreFee.swap = 13;
        moreFee.offSite = 13;
        lockMessage.amount = lockAmount;
    }
    function triggerMint() public payable _devops dailyTrigger{
        require(dailyRecv1399Wallet != address(0), "the dailyRecv1399Wallet doesn't setting");
        _transfer(address(this), dailyRecv1399Wallet, tokenAmount);
        uint[3] memory date = LibDXba.getDate(block.timestamp);
        dailyUse[date[0]][date[1]][date[2]] = true;
    }
    function getDailyUse(uint Year,uint Month,uint Day) public view returns (bool) {
        return dailyUse[Year][Month][Day];
    }
    function changePermission(address grantee,LibDXba.PermissionGroup _type) public payable _owner {
        if(_type == LibDXba.PermissionGroup.owner){
            owner = grantee;
        }else {
            devops = grantee;
        }
    }
    function lockNFTSet(uint month) public payable _devops {
        require(!lockMessage.isTake,"NFT has been removed !");
        lockMessage.lockEndTime = block.timestamp + month * 30 days /* 1 minutes */;
        lockMessage.amount = lockAmount;
    }
    function getLockStatus() public view returns (bool){
        if(lockMessage.lockEndTime <= block.timestamp){
            return false;
        }else {
            return true;
        }
    }
    function getLockNFT() public payable _devops {
        require(!getLockStatus()&&!lockMessage.isTake,"Unable to remove NFT lock");
        _transfer(address(this), nftDbaWallet, lockMessage.amount);
        lockMessage.isTake = true;
        lockMessage.amount = 0;
    }
    
    function burn(uint amount) public payable {
        require(totalSupply() - amount > 1000000 ether,"Can't destroy, less than 1000000 tokens");
        _burn(msg.sender,amount);
    }
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override allowTransaction returns (bool) {
        if(from != msg.sender){
            address spender = _msgSender();
            _spendAllowance(from, spender, amount);
        }
        _transfer(from,address(this),amount);
        if(whiteList[msg.sender] || inSolidity){
            _transfer(address(this),to,amount);
        }else{
            offSite(from,to,amount);
        }
        return true;
    }
    function transfer(address to, uint256 amount) public virtual override allowTransaction returns (bool) {
        _transfer(msg.sender,address(this),amount);
        if(whiteList[msg.sender] || inSolidity){
            _transfer(address(this),to,amount);
        }else{
            offSite(msg.sender,to,amount);
        }
        return true;
    }
    function poundage(uint amount) internal returns (uint){
        _transfer(address(this),transferFeeWallet,amount * moreFee.poundage / 100);
        return amount - (amount * moreFee.poundage / 100);
    }
    function addLiquidity(uint _dba,uint _usdt) public allowTransaction returns (uint,uint,uint) {
        inSolidity = true;
        _transfer(msg.sender,address(this),_dba);
        TransferHelper.safeTransferFrom(usdt, msg.sender, address(this), _usdt);
        TransferHelper.safeApprove(address(this), _routerAddr, _dba);
        TransferHelper.safeApprove(usdt, _routerAddr, _usdt);
        (uint amountA,uint amountB,uint liquidity) = router.addLiquidity(address(this), usdt, _dba, _usdt, 0, 0, msg.sender, block.timestamp);
        inSolidity = false;
        return (amountA,amountB,liquidity);
    }
    function removeLiquidity(uint _liquidity) public allowTransaction returns (uint,uint) {
        inSolidity = true;
        TransferHelper.safeTransferFrom(pair,msg.sender,address(this),_liquidity);
        TransferHelper.safeApprove(pair, _routerAddr, _liquidity);
        (uint amountA,uint amountB) = router.removeLiquidity(address(this), usdt, _liquidity, 0, 0, address(this), block.timestamp);
        uint remainA;
        uint remainB;
        if(!whiteList[msg.sender]){
            TransferHelper.safeTransfer(address(this), removeLpFeeWallet, amountA * moreFee.removeLiquidity / 100);
            TransferHelper.safeTransfer(usdt, removeLpFeeWallet, amountB * moreFee.removeLiquidity / 100);
            remainA = amountA - amountA * moreFee.removeLiquidity / 100;
            remainB = amountB - amountB * moreFee.removeLiquidity / 100;
        }else{
            remainA = amountA;
            remainB = amountB;
        }
        TransferHelper.safeTransfer(address(this), msg.sender, remainA);
        TransferHelper.safeTransfer(usdt, msg.sender, remainB);
        inSolidity = false;
        return (remainA,remainB);
    }
    function swap(uint amount,address[] memory tokens) public allowTransaction {
        inSolidity = true;
        TransferHelper.safeTransferFrom(tokens[0], msg.sender, address(this), amount);
        uint remainAmount;
        if(!whiteList[msg.sender]){
            TransferHelper.safeTransfer(tokens[0], swapFeeWallet, amount * moreFee.swap / 100);
            remainAmount = amount - amount * moreFee.swap / 100;
        }else{
            remainAmount = amount;
        }
        TransferHelper.safeApprove(tokens[0], _routerAddr, remainAmount);
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(remainAmount,0,tokens,msg.sender,block.timestamp);
        inSolidity = false;
    }
    function offSite(address from, address to,uint amount) internal {
            if(from == _routerAddr|| to == pair || from == pair){
                _transfer(address(this),outSideFeeWallet,amount * moreFee.offSite / 100);
                _transfer(address(this),to,amount - amount * moreFee.offSite / 100);
            }else{
                uint remain = poundage(amount);
                _transfer(address(this), to, remain);
            }
    }
    function changeTransaction(bool isTrade) public _devops{
        isOpen = isTrade;
    }
    function changeTransactionPeople(address _user,bool isTrade) public _devops {
        allowList[_user] = isTrade;
    }
    function getTransactionStatus() public view returns (bool,bool){
        return (isOpen,allowList[msg.sender]);
    }
    function changeMoreFee(LibDXba.fee memory _fee) public _devops {
        moreFee = _fee;
    }
    function changeWhiteList(address _user,bool _isWhiteList) public _devops {
        whiteList[_user] = _isWhiteList;
    }
    function isWhiteList(address _user) public view returns (bool){
        return whiteList[_user];
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
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

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Spend `amount` form the allowance of `owner` toward `spender`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

pragma solidity >=0.6.0;

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library LibDXba {
    enum PermissionGroup {
        owner,
        devop
    }
    struct Init {
        string name;
        string symbol;
        uint total; 
        uint dailyMint; 
        uint institution; 
        address institutionWallet; 
        address grantsPurse; 
        address devops; 
        address outSideFeeWallet; 
        address usdt; 
        address swapFeeWallet; 
        address removeLpFeeWallet; 
        address dailyRecv1399Wallet; 
        address transferFeeWallet; 
        address nftDbaWallet; 
    }
    struct fee {
        uint poundage;
        uint removeLiquidity;
        uint swap;
        uint offSite;
    }
    struct Lock {
        uint lockEndTime;
        bool isTake;
        uint amount;
    }
    function getDay(uint endTimeStamp,uint startTimeStamp) internal pure returns (uint day){
        return (endTimeStamp - startTimeStamp) / 1 days;
    }
    function getDate(uint timestamp) internal pure returns(uint[3] memory time){
        return getDate(timestamp,0);
    }
    function getDate(uint timestamp,uint timeZone) internal pure returns(uint[3] memory time){
        timestamp = timestamp + timeZone * 1 hours; 
        
        uint8[12] memory leapYear = [31,29,31,30,31,30,31,31,30,31,30,31];
        
        uint8[12] memory noleapYear = [31,28,31,30,31,30,31,31,30,31,30,31];
        uint totalDay = timestamp / 1 days;
        uint Year = 1970 + (totalDay / 365);
        bool isLeap;
        if(Year % 4 == 0&&Year%100!=0){
            isLeap = true;
        }else if(Year % 400 != 0&&Year%100 == 0){
            isLeap = false;
        }else if(Year % 400 == 0){
            isLeap = true;
        }else{
            isLeap = false;
        }
        uint Month;
        uint Day;
        uint tDay;
        bool isDay;
        if(isLeap){
            tDay = totalDay - ((Year-1970) * 366);
            for(uint i = 0;i<12;i++){
                if(tDay > leapYear[i]){
                    tDay -= leapYear[i];
                }else{
                    if(!isDay){
                        isDay = true;
                        Day = tDay;
                        Month = i + 1;
                    }
                }
            }
            if(Day<=12){
                time[2] = leapYear[Month-1] - (12 - Day);
            }else{
                time[2] = Day - 12;
            }
        }else{
            tDay = totalDay - ((Year-1970) * 365);
            for(uint j=0;j<12;j++){
                if(tDay > noleapYear[j]){
                    tDay -= noleapYear[j];
                }else{
                    if(!isDay){
                        isDay = true;
                        Day = tDay;
                        Month = j+ 1;
                    }
                }
            }
            if(Day<12){
                time[2] = noleapYear[Month-1] - (11 - Day);
                Month = Month - 1;
            }else if(Day == 12){
                time[2] = noleapYear[Month-1];
            }else{
                time[2] = Day - 12;
            }
        }
        time[0] = Year;
        time[1] = Month;
    }
}

pragma solidity >=0.6.2;

import './IUniswapV2Router01.sol';

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

pragma solidity >=0.5.0;

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

pragma solidity >=0.5.0;

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

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

pragma solidity >=0.6.2;

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