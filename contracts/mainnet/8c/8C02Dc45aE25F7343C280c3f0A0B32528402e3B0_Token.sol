pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./IBEP20.sol";

contract Token is Ownable, IBEP20
{

    uint internal constant PRECISION = 1000000;
    uint internal constant REFLECTION_FEE_PROP = 50 * PRECISION;
    uint internal constant BURN_FEE_PROP = 50 * PRECISION;
    uint internal constant FEE_DIV_BASE = 100 * PRECISION;
    uint internal constant MAX = ~uint(0);
    string internal constant NAME = "Usuku 24h Token Round #1";
    string internal constant SYMBOL = "Usuku #1";
    
    uint internal constant POW_FACTOR = 10;

    mapping (address => uint) private _balances;
    mapping (address => mapping (address => uint)) private _allowances;
    uint private _tTotal;
    uint private _rTotal;
    uint public genesisBlock;
    uint public finalBlock;
    bool public started;

    event Started();
    event Finished();
    
    constructor()
        Ownable()
    {
        uint total = 20 * 1e6 * 10 ** 9;
        _tTotal = total;
        uint rTotal = MAX - (MAX % total);
        _rTotal = rTotal;
        _balances[_msgSender()] = rTotal;
        emit Transfer(address(0), address(this), total);
    }

    receive()
        external payable
    {

    }

    function start()
        external 
        onlyOwner
    {
        started = true;
        genesisBlock = block.number;
        finalBlock = block.number + 60 * 60 * 24 / 3; // BSC: 1 block every 3 seconds
        renounceOwnership();

        emit Started();
    }

    function finish()
        external
    {
        uint maxBlock = finalBlock;
        require(maxBlock > 0 && _getBlocksToEnd(maxBlock) == 0, "Available after 24H from start");
        started = false;
      
        
        emit Finished();
    }

    function getBlocksToEnd()
        external view 
        returns(uint)
    {
        return _getBlocksToEnd(finalBlock);
    }

    function _getBlocksToEnd(uint pFinalBlock)
        internal view 
        returns(uint)
    {
        if(block.number >= pFinalBlock) { return 0; }

        return pFinalBlock - block.number;
    }

    function getOwner() external override pure returns (address) { return address(0); }

    function name() public override pure returns (string memory) { return NAME; }

    function symbol() public override pure returns (string memory) { return SYMBOL; }

    function decimals() public override pure returns (uint8) { return 9; }

    function totalSupply() public override view returns (uint) { return _tTotal; }

    function balanceOf(address account) public override view returns (uint) { return _tokenFromReflection(_balances[account]); }

    function transfer(address recipient, uint amount) external override returns (bool) {
        _transfer(_msgSender(), recipient, amount);

        return true;
    }

    function allowance(address owner, address spender) external override view returns (uint) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint amount) external override returns (bool) {
        _approve(_msgSender(), spender, amount);

        return true;
    }

    function transferFrom(address sender, address recipient, uint amount) external override returns (bool) {
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()] - amount);
        _transfer(sender, recipient, amount);

        return true;
    }

    function increaseAllowance(address spender, uint addedValue) external virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);

        return true;
    }

    function decreaseAllowance(address spender, uint subtractedValue) external virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] - subtractedValue);

        return true;
    }

    function _tokenFromReflection(uint rAmount) private view returns(uint) { return rAmount / _getRate(); }

    function calculateFee()
        public view 
        returns (uint)
    {
        if(!started)
        {
            return 0;
        }
        uint minFee = 1 * PRECISION;
        uint maxFee = 100 * PRECISION;
        uint maxBlock = finalBlock;
        if(_getBlocksToEnd(maxBlock) == 0)
        {
            return maxFee;
        }
        uint minBlock = genesisBlock;
        if(minBlock == 0 || maxBlock == 0)
        {
            return minFee;
        }
        minBlock = minBlock ** POW_FACTOR;
        return minFee + (block.number ** POW_FACTOR - minBlock) * (maxFee - minFee) / (maxBlock ** POW_FACTOR - minBlock);
    }

    function getFeeBase() 
        external pure 
        returns (uint)
    {
        return FEE_DIV_BASE;
    }

    function _transfer(address sender, address recipient, uint amount) private {
        require(sender != address(0), "ERC20: transfer route the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        (
            uint rAmount, 
            uint rTransferAmount, 
            uint rReflectionFee, 
            uint rBurnFee,
            uint tTransferAmount, 
            /*uint tReflectionFee*/,
            uint tBurnFee
        ) = _getValues(amount);        
        _balances[sender] -= rAmount;
        _balances[recipient] += rTransferAmount;
        _rTotal -= rReflectionFee + rBurnFee;
        _tTotal -= tBurnFee;
        emit Transfer(sender, recipient, tTransferAmount);
    }


    function _approve(address owner, address spender, uint amount) private {
        require(owner != address(0), "ERC20: approve route the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;

        emit Approval(owner, spender, amount);
    }

    function _getValues(uint tAmount) 
        private view 
        returns (uint rAmount, uint rTransferAmount, uint rReflectionFee, uint rBurnFee, uint tTransferAmount, uint tReflectionFee, uint tBurnFee) 
    {
        (tTransferAmount, tReflectionFee, tBurnFee) = _getTValues(tAmount);
        (rAmount, rTransferAmount, rReflectionFee, rBurnFee) = _getRValues(tAmount, tReflectionFee, tBurnFee, _getRate());

        return (rAmount, rTransferAmount, rReflectionFee, rBurnFee, tTransferAmount, tReflectionFee, tBurnFee);
    }

    function _getTValues(uint tAmount) private view 
        returns (uint tTransferAmount, uint tReflectionFee, uint tBurnFee) 
    {
		uint fee = tAmount * calculateFee() / FEE_DIV_BASE;
		tReflectionFee = fee * REFLECTION_FEE_PROP / FEE_DIV_BASE;
        tBurnFee = fee * BURN_FEE_PROP / FEE_DIV_BASE;
        tTransferAmount = tAmount - tReflectionFee - tBurnFee;
    }

    function _getRate() private view returns(uint) {
        return _rTotal / _tTotal;
    }

    function _getRValues(uint tAmount, uint tReflectionFee, uint tBurnFee, uint currentRate) private pure returns (
        uint rAmount,
        uint rTransferAmount,
        uint rReflectionFee,
        uint rBurnFee
    ) {
        rAmount = tAmount * currentRate;
        rReflectionFee = tReflectionFee * currentRate;
        rBurnFee = tBurnFee * currentRate;
        rTransferAmount = rAmount - rReflectionFee - rBurnFee;
    }
}

pragma solidity ^0.8.0;

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

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
    function allowance(address _owner, address spender) external view returns (uint256);

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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