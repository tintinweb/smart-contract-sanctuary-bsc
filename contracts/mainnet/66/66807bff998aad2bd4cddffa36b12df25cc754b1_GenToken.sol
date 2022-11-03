/**
 *Submitted for verification at BscScan.com on 2022-11-03
*/

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol
// SPDX-License-Identifier: MIT

// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Context.sol


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

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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

// File: gen.sol


pragma solidity 0.8.17;

interface IERC20 {
   
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount)external returns (bool);
    function allowance(address owner, address spender)external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender,address recipient,uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner,address indexed spender,uint256 value);
}



contract GenToken is IERC20, Ownable {
    
    using SafeMath for uint256;

    string private _name = "BattleStakes";
    string private _symbol = "GEN";
    uint8 private _decimals = 18;

    address public contractAddress;
    
    mapping(address => uint256) internal _balances;
    mapping(address => mapping(address => uint256)) internal _allowances;
    
    uint256 internal _totalSupply = 100000 *10**18; //  100k _totalSupply
    
    mapping(address => bool) isExcludedFromFee;
    mapping(address => bool) public blackListed;
    mapping(address => bool) public whiteListed;

    
    uint256 public _arenaFee = 200; // 200 = 2.00%
    uint256 public _winnerFee = 100; // 100 = 1.00%
    uint256 public _burningFee = 200; // 200 = 2.0%
    uint256 public _lpFee = 400; // 400 = 4%
    uint256 public _insuranceFee = 400; // 400 = 4%
    uint256 public _treasuryFee = 200; // 200 = 2%
    uint256 public _referalFee = 100; // 100 = 1%
    uint256 public _selltreasuryFee = 300; // 300 = 3%
    uint256 public _sellinsuranceFee = 500; // 500 = 5%
    uint256 public _inbetweenFee_ = 4000; // 4000 = 40%

    
    uint256 public _arenaFeeTotal;
    uint256 public _winnerFeeTotal;
    uint256 public _burningFeeTotal;
    uint256 public _lpFeeTotal;
    uint256 public _insuranceFeeTotal;
    uint256 public _sellinsuranceFeeTotal;
    uint256 public _selltreasuryFeeTotal;
    uint256 public _treasuryFeeTotal;
    uint256 public _referalFeeTotal;
    uint256 public _inbetweenFeeTotal;

    address public arenaAddress  = 0x2501E79052e090de1529F9bc2EE761A89F62d82e;      // arenaAddress !
    address public winnerAddress  = 0x79F1f75afEaed3494db6eC37683Bf9420F29e7A6;      // winnerCircleAddress !
    address public burningAddress = 0x0000000000000000000000000000000000000000;  // Burning Address add after deployment !
    address public lpAddress = 0x3e4993839f7B99C0Ac66048c3dFD58e0af548FD4;          // lpAddress liquidity pool !
    address public insuranceAddress = 0xEBFe69037B45bDd21aDbb6DCD2E11e1f05C29d18;      // insuranceAddress !
    address public treasuryAddress = 0x9Fe316f151F1Cb2022bc376B1073751f1B1a2414;      // treasuryAddress !
    address public referalAddress = 0x46BADB2c0c352E05fDb58f8F84751210325A3DA5;      // referalAddress /Markiting /Development Fund !
    address public inbetweenAddress = 0x46BADB2c0c352E05fDb58f8F84751210325A3DA5;      // inbetweenAddress !
    
    

    constructor() {

        isExcludedFromFee[msg.sender] = true;
        isExcludedFromFee[address(this)] = true;
        _balances[msg.sender] = _totalSupply;
                
        emit Transfer(address(0), msg.sender, _totalSupply);


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

    function totalSupply() public override view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public override view returns (uint256) {
         return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override virtual returns (bool) {
       _transfer(msg.sender,recipient,amount);
        return true;
    }

    function allowance(address owner, address spender) public override view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override virtual returns (bool) {
        _transfer(sender,recipient,amount);       
        _approve(sender,msg.sender,_allowances[sender][msg.sender].sub( amount,"ERC20: transfer amount exceeds allowance"));
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

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }


    function _transfer(address sender, address recipient, uint256 amount) private {

        require(!blackListed[sender], "You are blacklisted so you can not Transfer Gen tokens.");
        require(!blackListed[recipient], "blacklisted address canot be able to recieve Gen tokens.");
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        
        uint256 transferAmount = amount;

        if(isExcludedFromFee[sender] && recipient == contractAddress){
            transferAmount = collectFee(sender,amount);     
        }
        else if(whiteListed[sender] || whiteListed[recipient]){
            transferAmount = amount;     
        }
        else{

            if(isExcludedFromFee[sender] && isExcludedFromFee[recipient]){
                transferAmount = amount;
            }
            if(!isExcludedFromFee[sender] && !isExcludedFromFee[recipient]){
                transferAmount = betweencollectFee(sender,amount);
            }
            if(isExcludedFromFee[sender] && !isExcludedFromFee[recipient]){
                transferAmount = collectFee(sender,amount);
            }
            if(!isExcludedFromFee[sender] && isExcludedFromFee[recipient]){
                transferAmount = SellcollectFee(sender,amount);
            }
        }   

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(transferAmount);
        
        emit Transfer(sender, recipient, transferAmount);
    }

    function decreaseTotalSupply(uint256 amount) public onlyOwner {
        _totalSupply =_totalSupply.sub(amount);

    }

    function setContractAddress(address _contractAddress) public onlyOwner{
            contractAddress = _contractAddress;
    }

    function mint(address account, uint256 amount) public onlyOwner {
       
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply += amount;
        _balances[account] += amount;
    }
    
    function burn(address account, uint256 amount) public onlyOwner {
        require(account != address(0), "ERC20: burn from the zero address");

        uint256 accountBalance = _balances[account];
            _balances[account] = accountBalance - amount;
            _totalSupply -= amount;
    }
    
    
    function collectFee(address account, uint256 amount/*, uint256 rate*/) private returns (uint256) {
        
        uint256 transferAmount = amount;
        
        uint256 arenaFee = amount.mul(_arenaFee).div(10000);
        uint256 winnerFee = amount.mul(_winnerFee).div(10000);
        uint256 burningFee = amount.mul(_burningFee).div(10000);
        uint256 lpFee = amount.mul(_lpFee).div(10000);
        uint256 insuranceFee = amount.mul(_insuranceFee).div(10000);
        uint256 treasuryFee = amount.mul(_treasuryFee).div(10000);
        uint256 referalFee = amount.mul(_referalFee).div(10000);

        if (burningFee > 0){
            transferAmount = transferAmount.sub(burningFee);
            _balances[burningAddress] = _balances[burningAddress].add(burningFee);
            _burningFeeTotal = _burningFeeTotal.add(burningFee);
            emit Transfer(account,burningAddress,burningFee);
        }
        
        if (lpFee > 0){
            transferAmount = transferAmount.sub(lpFee);
            _balances[lpAddress] = _balances[lpAddress].add(lpFee);
            _lpFeeTotal = _lpFeeTotal.add(lpFee);
            emit Transfer(account,lpAddress,lpFee);
        }

        if(arenaFee > 0){
            transferAmount = transferAmount.sub(arenaFee);
            _balances[arenaAddress] = _balances[arenaAddress].add(arenaFee);
            _arenaFeeTotal = _arenaFeeTotal.add(arenaFee);
            emit Transfer(account,arenaAddress,arenaFee);
        }
     
        if(winnerFee > 0){
            transferAmount = transferAmount.sub(winnerFee);
            _balances[winnerAddress] = _balances[winnerAddress].add(winnerFee);
            _winnerFeeTotal = _winnerFeeTotal.add(winnerFee);
            emit Transfer(account,winnerAddress,winnerFee);
        }
        if(insuranceFee > 0){
            transferAmount = transferAmount.sub(insuranceFee);
            _balances[insuranceAddress] = _balances[insuranceAddress].add(insuranceFee);
            _insuranceFeeTotal = _insuranceFeeTotal.add(insuranceFee);
            emit Transfer(account,insuranceAddress,insuranceFee);
        }
        if(treasuryFee > 0){
            transferAmount = transferAmount.sub(treasuryFee);
            _balances[treasuryAddress] = _balances[treasuryAddress].add(treasuryFee);
            _treasuryFeeTotal = _treasuryFee.add(treasuryFee);
            emit Transfer(account,treasuryAddress,treasuryFee);
        }
        if(referalFee > 0){
            transferAmount = transferAmount.sub(referalFee);
            _balances[referalAddress] = _balances[referalAddress].add(referalFee);
            _referalFeeTotal = _referalFee.add(referalFee);
            emit Transfer(account,referalAddress,referalFee);
        }
        
       
        return transferAmount;
    }


    function SellcollectFee(address account, uint256 amount/*, uint256 rate*/) private  returns (uint256) {
        
        uint256 transferAmount = amount;
        
        uint256 arenaFee = amount.mul(_arenaFee).div(10000);
        uint256 winnerFee = amount.mul(_winnerFee).div(10000);
        uint256 burningFee = amount.mul(_burningFee).div(10000);
        uint256 lpFee = amount.mul(_lpFee).div(10000);
        uint256 sellinsuranceFee = amount.mul(_sellinsuranceFee).div(10000);
        uint256 selltreasuryFee = amount.mul(_selltreasuryFee).div(10000);
        uint256 referalFee = amount.mul(_referalFee).div(10000);

        if (burningFee > 0){
            transferAmount = transferAmount.sub(burningFee);
            _balances[burningAddress] = _balances[burningAddress].add(burningFee);
            _burningFeeTotal = _burningFeeTotal.add(burningFee);
            emit Transfer(account,burningAddress,burningFee);
        }

        if (lpFee > 0){
            transferAmount = transferAmount.sub(lpFee);
             _balances[lpAddress] = _balances[lpAddress].add(lpFee);
            _lpFeeTotal = _lpFeeTotal.add(lpFee);
            emit Transfer(account,lpAddress,lpFee);
        }

        if(arenaFee > 0){
            transferAmount = transferAmount.sub(arenaFee);
             _balances[arenaAddress] = _balances[arenaAddress].add(arenaFee);
            _arenaFeeTotal = _arenaFeeTotal.add(arenaFee);
            emit Transfer(account,arenaAddress,arenaFee);
        }
        
        //@dev BuyBackv2 fee
        if(winnerFee > 0){
            transferAmount = transferAmount.sub(winnerFee);
            _balances[winnerAddress] = _balances[winnerAddress].add(winnerFee);
            _winnerFeeTotal = _winnerFeeTotal.add(winnerFee);
            emit Transfer(account,winnerAddress,winnerFee);
        }
        if(sellinsuranceFee > 0){
            transferAmount = transferAmount.sub(sellinsuranceFee);
            _balances[insuranceAddress] = _balances[insuranceAddress].add(sellinsuranceFee);
            _sellinsuranceFeeTotal = _sellinsuranceFeeTotal.add(sellinsuranceFee);
            emit Transfer(account,insuranceAddress,sellinsuranceFee);
        }
        if(selltreasuryFee > 0){
            transferAmount = transferAmount.sub(selltreasuryFee);
            _balances[treasuryAddress] = _balances[treasuryAddress].add(selltreasuryFee);
            _selltreasuryFeeTotal = _selltreasuryFeeTotal.add(selltreasuryFee);
            emit Transfer(account,treasuryAddress,selltreasuryFee);
        }
        if(referalFee > 0){
            transferAmount = transferAmount.sub(referalFee);
            _balances[referalAddress] = _balances[referalAddress].add(referalFee);
            _referalFeeTotal = _referalFee.add(referalFee);
            emit Transfer(account,referalAddress,referalFee);
        }
        
        return transferAmount;
    }


 function betweencollectFee(address account, uint256 amount) private  returns (uint256) {
        
        uint256 transferAmount = amount;
       
        uint256 _inbetweenFee = amount.mul(_inbetweenFee_).div(10000);

        if (_inbetweenFee > 0){
            transferAmount = transferAmount.sub(_inbetweenFee);
            _balances[inbetweenAddress] = _balances[inbetweenAddress].add(_inbetweenFee);
            _inbetweenFeeTotal = _inbetweenFeeTotal.add(_inbetweenFee);
            emit Transfer(account,inbetweenAddress,_inbetweenFee);
        }
       
        return transferAmount;
    }

    
    function addInBlackList(address account, bool) public onlyOwner {
        blackListed[account] = true;
    }
    
    function removeFromBlackList(address account, bool) public onlyOwner {
        blackListed[account] = false;
    }

    function isBlackListed(address _address) public view returns( bool _blacklisted){
        
        if(blackListed[_address] == true){
            return true;
        }
        else{
            return false;
        }
    }

    function addInWhiteList(address account, bool) public onlyOwner {
        whiteListed[account] = true;
    }

    function removeFromWhiteList(address account, bool) public onlyOwner {
        whiteListed[account] = false;
    }

    function isWhiteListed(address _address) public view returns( bool _whitelisted){
        
        if(whiteListed[_address] == true){
            return true;
        }
        else{
            return false;
        }
    }
   
    function ExcludedFromFee(address account, bool) public onlyOwner {
        isExcludedFromFee[account] = true;
    }
    
    function IncludeInFee(address account, bool) public onlyOwner {
        isExcludedFromFee[account] = false;
    }
     
    function setWinnerFee(uint256 fee) public onlyOwner {
        _winnerFee = fee;
    }
    
    function setarenaFee(uint256 fee) public onlyOwner {
        _arenaFee = fee;
    }
    
     function setBurningFee(uint256 fee) public onlyOwner {
        _burningFee = fee;
    }
    
     function setlpFee(uint256 fee) public onlyOwner {
        _lpFee = fee;
    }
    function setinsuranceFee(uint256 fee) public onlyOwner {
        _insuranceFee = fee;
    }
    function settreasuryFee(uint256 fee) public onlyOwner {
        _treasuryFee = fee;
    }
    function setselltreasuryFee(uint256 fee) public onlyOwner {
        _selltreasuryFee = fee;
    }
    function setsellinsuranceFee(uint256 fee) public onlyOwner {
        _sellinsuranceFee = fee;
    }
     function inbetweenFee(uint256 fee) public onlyOwner {
        _inbetweenFee_ = fee;
    }
    function setArenaAddress(address _Address) public onlyOwner {
        require(_Address != arenaAddress);
        
        arenaAddress = _Address;
    }
    function setinbetweenAddress(address _Address) public onlyOwner {
        require(_Address != inbetweenAddress);
        
        inbetweenAddress = _Address;
    }

    
    function setWinnerAddress(address _Address) public onlyOwner {
        require(_Address != winnerAddress);
        
        winnerAddress = _Address;
    }
    
    function setBurningAddress(address _Address) public onlyOwner {
        require(_Address != burningAddress);
        
        burningAddress = _Address;
    }
    
     function setLPAddress(address _Address) public onlyOwner {
        require(_Address != lpAddress);
        
        lpAddress = _Address;
    }
    function setInsuranceAddress(address _Address) public onlyOwner {
        require(_Address != insuranceAddress);
        
        insuranceAddress = _Address;
    }
    
    function settreasuryAddress(address _Address) public onlyOwner {
        require(_Address != treasuryAddress);
        
        treasuryAddress = _Address;
    }
     
    function setReferalAddress(address _Address) public onlyOwner {
        require(_Address != referalAddress);
        
        referalAddress = _Address;
    }

    // function to allow admin to transfer ETH from this contract
    function TransferETH(address payable recipient, uint256 amount) public onlyOwner {
        recipient.transfer(amount);
    }
    
    
    receive() external payable {}
}