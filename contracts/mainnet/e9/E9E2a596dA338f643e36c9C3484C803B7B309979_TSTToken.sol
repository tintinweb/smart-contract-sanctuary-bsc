// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IWhiteList {
    function confirm(address, uint) external returns (bool);
}
interface IUniswapFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}
interface IUniSwapRouter {
    function factory() external pure returns (address);
}

contract TSTToken is IERC20, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    string private _name;
    string private _symbol;
    uint256 private _totalSupply;
    uint256 public constant MaxTotalAmount = 100_0000 * 10**18;

    address private tstPair;
    address private treasury = 0x9a78ae861A012a7456ba309d92Ee9d129C3af2F9;
    address private lottery = 0x4f545Bc31C3295ADc24Fe3612b4cc8A934f5D4Ea;
    address private whiteList = 0xDB582d9023Ef901655E0BE8F02ba44D4F87a8b7d;
    address private LPDividend = 0xdF60201b6C2A67804AC3F876dDC6a9deD329c65b;

    uint8[3] public feeSetting = [3, 6, 1];

    bool public feeOn;
    bool public whitelistSwitch = true;

    uint256 public DividendTotalAmount;

    mapping (address => bool) private controller;
    mapping (address => bool) private _isExcludedFee;

    modifier onlyController () {
        require(controller[_msgSender()] , "TriangleNFT: only by controller.");
        _;
    }

    constructor() {
        _name = "TriangleToken";
        _symbol = "TST";
        controller[_msgSender()] = true;
        _isExcludedFee[address(this)] = true;

        tstPair = IUniswapFactory(IUniSwapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E).factory())
        // .createPair(address(this), 0x64e874B794c7823d6cF7Fad5C9c56d36cc4698b0);
        .createPair(address(this), 0x55d398326f99059fF775485246999027B3197955);

        address fund = 0x891155a00286f3Cda777B782D48F14Facda2c179;
        _mint(fund, MaxTotalAmount);
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
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function getPairAddr() external view returns(address){
        return tstPair;
    }

    function setPairAddr(address tstPairAddr_) external onlyController {
        tstPair = tstPairAddr_;
    }

    function getLPDividend() external view returns(address){
        return LPDividend;
    }

    function setLPDividend(address dividendAddr_) external onlyController {
        LPDividend = dividendAddr_;
    }

    function setTreasury(address treasuryAddr_) external onlyController {
        treasury = treasuryAddr_;
    }

    function getTreasury() external view returns(address){
        return treasury;
    }

    function setLottery(address lotteryAddr_) external onlyController {
        lottery = lotteryAddr_;
    }

    function getLottery() external view returns(address) {
        return lottery;
    }

    function setController(address addr_,bool switch_) external onlyController {
        controller[addr_] = switch_;
    }

    function setFee(uint8 buyFee_, uint8 sellFee_, uint8 transferFee_) external onlyController {
        require(buyFee_ + sellFee_ + transferFee_ <= 100, "invaild fee");
        feeSetting[0] = buyFee_;
        feeSetting[1] = sellFee_;
        feeSetting[2] = transferFee_;
    }

    function getFee() external view returns(uint8[3] memory feeArray) {
        feeArray = feeSetting;
    }

    function setWhiteListAddr(address addr_) external onlyController{
        whiteList = addr_;
    }

    function setWhitelistSwitch(bool switch_) external onlyController{
        whitelistSwitch = switch_;
    }

    function excludeFeeSwitch(address[] calldata accounts, bool _switch) public onlyController {

        for(uint256 i = 0; i < accounts.length; i ++) {
            _isExcludedFee[accounts[i]] = _switch;
        }
    }

    function setfeeOn(bool flag_) external onlyController {
        feeOn = flag_;
    }

    function transfer(address to, uint256 amount) public override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
    unchecked {
        _approve(owner, spender, currentAllowance - subtractedValue);
    }
        return true;
    }


    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(from != to, "ERC20: from = to");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");

        unchecked {
            _balances[from] = fromBalance - amount;
        }

        if(feeOn && !(_isExcludedFee[from] || _isExcludedFee[to])){
            uint256 fee = amount * feeSetting[2] / 100;

            if(from == tstPair || to == tstPair){
                if(from == tstPair){
                    fee = amount * feeSetting[0] / 100;
                }else if(to == tstPair){
                    fee = amount * feeSetting[1] / 100;
                }
            }
            amount -= fee;
            handleTakeFee(from, fee);
        }

        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function handleTakeFee(address from_, uint256 fee_) internal {
        uint256 LPShare = fee_ * 3 / 10;
        uint256 lotteryShare = fee_ / 5;

        _balances[LPDividend] += LPShare;
        _balances[lottery] += lotteryShare;
        _balances[treasury] += (fee_ - LPShare - lotteryShare);

        DividendTotalAmount += LPShare;

        emit Transfer(from_, LPDividend, LPShare);
        emit Transfer(from_, lottery, lotteryShare);
        emit Transfer(from_, treasury, (fee_ - LPShare - lotteryShare));
    }

    function _mint(address account, uint256 amount) private {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) private {
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

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
        unchecked {
            _approve(owner, spender, currentAllowance - amount);
        }
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal {
        if(whitelistSwitch && from == tstPair){
            require(IWhiteList(whiteList).confirm(to, amount), "ERC20: insufficient allowance.");
        }
    }

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal {}

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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