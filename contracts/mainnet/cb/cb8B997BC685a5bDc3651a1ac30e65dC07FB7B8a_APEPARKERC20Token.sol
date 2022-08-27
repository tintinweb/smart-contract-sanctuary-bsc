// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.7.5;

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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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

library SafeMath {

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
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }

    function sqrrt(uint256 a) internal pure returns (uint c) {
        if (a > 3) {
            c = a;
            uint b = add( div( a, 2), 1 );
            while (b < c) {
                c = b;
                b = div( add( div( a, b ), b), 2 );
            }
        } else if (a != 0) {
            c = 1;
        }
    }

    function percentageAmount( uint256 total_, uint8 percentage_ ) internal pure returns ( uint256 percentAmount_ ) {
        return div( mul( total_, percentage_ ), 1000 );
    }

    function substractPercentage( uint256 total_, uint8 percentageToSub_ ) internal pure returns ( uint256 result_ ) {
        return sub( total_, div( mul( total_, percentageToSub_ ), 1000 ) );
    }

    function percentageOfTotal( uint256 part_, uint256 total_ ) internal pure returns ( uint256 percent_ ) {
        return div( mul(part_, 100) , total_ );
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }

    function quadraticPricing( uint256 payment_, uint256 multiplier_ ) internal pure returns (uint256) {
        return sqrrt( mul( multiplier_, payment_ ) );
    }

    function bondingCurve( uint256 supply_, uint256 multiplier_ ) internal pure returns (uint256) {
        return mul( multiplier_, supply_ );
    }
}

abstract contract ERC20 is IERC20 {

    using SafeMath for uint256;

    // TODO comment actual hash value.
    bytes32 constant private ERC20TOKEN_ERC1820_INTERFACE_ID = keccak256( "ERC20Token" );

    // Present in ERC777
    mapping (address => uint256) internal _balances;

    // Present in ERC777
    mapping (address => mapping (address => uint256)) internal _allowances;

    // Present in ERC777
    uint256 internal _totalSupply;

    // Present in ERC777
    string internal _name;

    // Present in ERC777
    string internal _symbol;

    // Present in ERC777
    uint8 internal _decimals;

    constructor (string memory name_, string memory symbol_, uint8 decimals_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
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

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }



    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account_, uint256 amount_) internal virtual {
        require(account_ != address(0), "ERC20: mint to the zero address");
        _beforeTokenTransfer(address( this ), account_, amount_);
        _totalSupply = _totalSupply.add(amount_);
        _balances[account_] = _balances[account_].add(amount_);
        emit Transfer(address( this ), account_, amount_);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer( address from_, address to_, uint256 amount_ ) internal virtual { }
}


interface IOwnable {
    function owner() external view returns (address);

    function renounceOwnership() external;

    function transferOwnership( address newOwner_ ) external;
}

contract Ownable is IOwnable {

    address internal _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        _owner = msg.sender;
        emit OwnershipTransferred( address(0), _owner );
    }

    function owner() public view override returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require( _owner == msg.sender, "Ownable: caller is not the owner" );
        _;
    }

    function renounceOwnership() public virtual override onlyOwner() {
        emit OwnershipTransferred( _owner, address(0) );
        _owner = address(0);
    }

    function transferOwnership( address newOwner_ ) public virtual override onlyOwner() {
        require( newOwner_ != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred( _owner, newOwner_ );
        _owner = newOwner_;
    }
}

contract VaultOwned is Ownable {

    address internal _vault;

    function setVault( address vault_ ) external onlyOwner() returns ( bool ) {
        _vault = vault_;

        return true;
    }

    function vault() public view returns (address) {
        return _vault;
    }

    modifier onlyVault() {
        require( _vault == msg.sender, "VaultOwned: caller is not the Vault" );
        _;
    }
}

interface IDEXRouter {

    function factory() external pure returns (address);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    
}

interface IDEXFactory {
    function createPair(address tokenA, address tokenB)
    external
    returns (address pair);
}

interface ISupport {
    function updateStakingTeam(address _user, uint _amount) external;
}

contract APEPARKERC20Token is ERC20,VaultOwned {

    using SafeMath for uint256;

    uint256 public DAOFee = 1000;
    uint256 public bonusFee = 500;
    uint256 public totalFee = DAOFee.add(bonusFee);
    uint256 public feeDenominator = 10000;

    address public USDT;
    IDEXRouter public router;

    address public DAOAddress;
    address public bonusAddress;

    address public pair;


    mapping(address => bool) public _isFeeExempt;

    constructor() ERC20("APEPARK DAO", "APD", 9) {
        router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        USDT = 0x55d398326f99059fF775485246999027B3197955;
        pair = IDEXFactory(router.factory()).createPair(
            USDT,
            address(this)
        );
        _allowances[address(this)][address(router)] = uint256(-1);
        _isFeeExempt[msg.sender] = true;
        _isFeeExempt[address(this)] = true;

        DAOAddress = 0xD4eC24Ae7088A434166b95FE3c9AF6Af324206A7;
    }

    function setFeeExemptListed(address _feeExempt,bool _isFee) external onlyOwner() {
        _isFeeExempt[_feeExempt] = _isFee;
    }

    function setDAOAddress(address _DAOAddress) external onlyOwner() {
        DAOAddress = _DAOAddress;
    }

    function setBonusAddress(address _bonusAddress) external onlyOwner() {
        bonusAddress = _bonusAddress;
    }

    function setFeeRate(uint256 _DAOFee,uint256 _bonusFee) external onlyOwner() {
        require(_DAOFee.add(_bonusFee) < feeDenominator.div(5),"fee error");
        DAOFee = _DAOFee;
        bonusFee = _bonusFee;
        totalFee = DAOFee.add(bonusFee);
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transferFrom(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transferFrom(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");

        uint256 amountReceived = shouldTakeFee(sender, recipient)
        ? takeFee(sender, amount)
        : amount;

        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
    }

    function mint(address account_, uint256 amount_) external onlyVault() {
        _mint(account_, amount_);
    }

    function burn(uint256 amount) public virtual {
        _burn(msg.sender, amount);
    }

    function burnFrom(address account_, uint256 amount_) public virtual {
        _burnFrom(account_, amount_);
    }

    function _burnFrom(address account_, uint256 amount_) public virtual {
        uint256 decreasedAllowance_ =
        allowance(account_, msg.sender).sub(
            amount_,
            "ERC20: burn amount exceeds allowance"
        );

        _approve(account_, msg.sender, decreasedAllowance_);
        _burn(account_, amount_);
    }

    function shouldTakeFee(address from, address to) internal view returns (bool) {
        return pair == to && !_isFeeExempt[from];
    }

    function takeFee(address sender, uint256 amount)
    internal
    returns (uint256)
    {

        uint256 feeAmount = amount.mul(totalFee).div(feeDenominator);
        _swap(sender,feeAmount);
        return amount.sub(feeAmount);
    }

    function _swap(address sender,uint256 amount) internal{
        _balances[address(this)] = _balances[address(this)].add(amount);
        emit Transfer(sender,address(this),amount);
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = USDT;
        
        uint256 DAOAmount = amount.mul(DAOFee).div(totalFee);
        if(DAOFee > 0 ){
            router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
              DAOAmount,
              0,
              path,
              DAOAddress,
              block.timestamp
            );
        }
        
        if(bonusFee > 0){
          uint256 bonusAmount = amount.mul(bonusFee).div(totalFee);
          router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
              bonusAmount,
              0,
              path,
              bonusAddress,
              block.timestamp
          );
        }
    }
}