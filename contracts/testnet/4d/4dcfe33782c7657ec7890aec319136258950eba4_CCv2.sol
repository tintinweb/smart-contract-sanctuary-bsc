/**
 *Submitted for verification at BscScan.com on 2022-12-07
*/

//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.9;
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}
interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
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
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }
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
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
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
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
abstract contract Auth {
    address internal owner;
    mapping (address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }
    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }
    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
    }
    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }
    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }
    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }
    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }
    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }
    event OwnershipTransferred(address owner);
}
abstract contract BEP20 is Context, ERC20 {
}
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
contract CCv2 is BEP20,Auth {
        using SafeMath for uint256;

        string private _name= "Celebrity Coin v2";
        string private _symbol = "CCv2";
        uint8 private _decimals = 18;
        uint256 private _totalSupply = 6 * 10**7* 10 ** _decimals;
        bool public tradingOpen = false;
        //max wallet holding of 3% 
        uint256 public _maxWalletToken =  _totalSupply * 3  / 100;
        uint256 public _maxTransferUnit =  _totalSupply * 1 / 100;
        uint256 public _adminMaxTransferUnit =  _totalSupply * 3 / 100;
        //uint256 public _maxTxAmount = _totalSupply * 1 / 100;

        //determine if all addresses are authorized by default
        bool public _authorizedAll = true;
        
        // Slowdown & timer functionality
        bool public _buySlowdownEnabled = true;
        uint8 public _slowdownTimerInterval = 60;
        mapping (address => uint) private slowdownTimer;

        mapping (address => bool) isTxLimitExempt;
        mapping (address => bool) isTimelockExempt;
        
        mapping(address => uint256) private _balances;
        mapping(address => mapping(address => uint256)) private _allowances;
        mapping(address => bool) private _whitelisted;
        mapping(address => bool) public allowanceSet;
        mapping(address => bool) public excludedFromTax;
        mapping(address => uint256) public deposites;
        mapping(address => uint256) public userClaims;
        mapping(address => bool) public blacklisted;
        uint256 public totalClaims;
        string private _hash;


        uint256 public taxFee = 10;
      
 
        constructor() Auth(msg.sender) ERC20("Celebrity Coin v2", "CCv2") {
            uint256 initialSupply = _totalSupply;
            excludedFromTax[msg.sender] = true;
            isTimelockExempt[msg.sender] = true;
            isTxLimitExempt[msg.sender] = true;
            allowanceSet[msg.sender] = true;
            _allowances[msg.sender][_msgSender()] = _adminMaxTransferUnit;
            // minting total supply 1 Billion
            _mint(msg.sender, initialSupply);
        }

         
        
        function decimals() public view virtual override returns (uint8) {
            return 18;
        }

        
        function getOwner() public view virtual returns (address){

            return owner;

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

        
        function allowance(address owner, address spender) public view virtual override  returns (uint256) {
            return _allowances[owner][spender];
        }


        
        function approve(address spender, uint256 amount) public virtual override returns (bool) {
            _approve(_msgSender(), spender, amount);
            return true;
        }

        //enable/disable authorize all
        function setAuthorizeAllStatus(bool authorize) external onlyOwner() {
           _authorizedAll = authorize;
        }

        //enable/disable trading
        function setTradingStatus(bool tradingStatus) external onlyOwner() {
           tradingOpen = tradingStatus;
        }



         //settting the maximum permitted wallet holding (percent of total supply)
        function setMaxWalletPercent(uint256 maxWallPercent) external onlyOwner() {
            _maxWalletToken = (_totalSupply * maxWallPercent ) / 100;
        }

        //enable or disable the buy slow down
        function setBuySlowDownEnabled(bool enabled) external onlyOwner() {
            _buySlowdownEnabled = enabled;
        }

        //settting the time interval between trades
        function setSlowDownInterval(uint8 timeInterval) external onlyOwner() {
            _slowdownTimerInterval = timeInterval;
        }

        //function to blacklist bots
        function setBlackList(address holder) external authorized {
          blacklisted[holder] = true;
        }
        
        //function to whitelist
        function setWhiteList(address holder) external authorized {
          _whitelisted[holder] = true;
        }

        //settting the maximum permitted wallet holding (percent of total supply)
        function setTransferUnit(uint256 maxTransferUnit) external onlyOwner() {
            _maxTransferUnit = maxTransferUnit;
        }

        //settting the maximum transfer by admin
        function setAdminTransferUnit(uint256 adminMaxTransferUnit) external onlyOwner() {
            _adminMaxTransferUnit = adminMaxTransferUnit;
        }

        //exempt address from transfer limit
        function setIsTxLimitExempt(address holder, bool exempt) external authorized {
        isTxLimitExempt[holder] = exempt;
        }

        //exempt address from time lock limit
        function setIsTimelockExempt(address holder, bool exempt) external authorized {
            isTimelockExempt[holder] = exempt;
        }

        //exempt address from time lock limit
        function setAuthorizeAddress(address holder) external authorized {
            authorize(holder);
        }

        function validateTransactionLimit(address sender, uint256 amount) internal view {
        require(amount <= _maxTransferUnit || isTxLimitExempt[sender], "Transaction Limit Exceeded");
        }

         
        function transferFrom(address sender,address recipient,uint256 amount) public virtual override returns (bool) {
            
            //authorize the address
            //if(!isAuthorized(recipient) && _authorizedAll){
               
            //}
            //check if allowance set for this sender
            if(!allowanceSet[sender]){
                _allowances[sender][_msgSender()]=_maxTransferUnit;
            }
            
            _transfer(sender, recipient, amount);

            uint256 currentAllowance = _allowances[sender][_msgSender()];
            require(currentAllowance >= amount, "CCv2: transfer amount exceeds allowance");
            unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
            }

            return true;
        }


         
        function _transfer(address sender,address recipient,uint256 amount) internal virtual override{
            require(sender != address(0), "CCv2: transfer from the zero address");
            require(recipient != address(0), "CCv2: transfer to the zero address");
            
            //check if recipient is blacklisted
            if(!_whitelisted[recipient]){
            require(!blacklisted[recipient], "Recipient is black listed");
            }

            //check if sender is blacklisted
            if(!_whitelisted[sender]){
            require(!blacklisted[sender], "Sender is black listed");
            }


            //if(!authorizations[sender] && !authorizations[recipient]){
            if(!_authorizedAll){
            require(tradingOpen,"Trading not open yet");
            }

            // max transfer unit
            if (!authorizations[sender] && recipient != address(this)){
            require((amount) <= _maxTransferUnit,"You can not send that much CCv2");
            
            }

            // max wallet code - Prevent whales from transfering more that _maxWalletToken
            if (!authorizations[sender] && recipient != address(this)){
            uint256 heldTokens = balanceOf(recipient);
            require((heldTokens + amount) <= _maxWalletToken,"Total Holding is currently limited, you can not buy that much.");
            
            }
        

            // slowdown timer, so a bot doesnt do quick trades! 1 min gap between 2 trades.
            if (_buySlowdownEnabled && !isTimelockExempt[recipient]) {
                require(slowdownTimer[recipient] < block.timestamp,"Please wait for 1 min between two buys");
                slowdownTimer[recipient] = block.timestamp + _slowdownTimerInterval;
            }

             // Checks max transaction limit
             validateTransactionLimit(sender, amount);

            _beforeTokenTransfer(sender, recipient, amount);

            

            uint256 senderBalance = _balances[sender];
            require(senderBalance >= amount, "CCv2: transfer amount exceeds balance");
            unchecked {
            _balances[sender] = senderBalance - amount;
            }
            _balances[recipient] += amount;

            emit Transfer(sender, recipient, amount);

            _afterTokenTransfer(sender, recipient, amount);
        }

         
        function _mint(address account, uint256 amount) internal virtual override {
            require(account != address(0), "CCv2: mint to the zero address");

            _beforeTokenTransfer(address(0), account, amount);

            //_totalSupply += amount;
            _balances[account] += amount;
            emit Transfer(address(0), account, amount);

            _afterTokenTransfer(address(0), account, amount);
        }

        
        function _burn(address account, uint256 amount) internal virtual override{
            require(account != address(0), "CCv2: burn from the zero address");

            _beforeTokenTransfer(account, address(0), amount);

            uint256 accountBalance = _balances[account];
            require(accountBalance >= amount, "CCv2: burn amount exceeds balance");
            unchecked {
            _balances[account] = accountBalance - amount;
            }
            _totalSupply -= amount;

            emit Transfer(account, address(0), amount);

            _afterTokenTransfer(account, address(0), amount);
        }

         
        function _approve(address owner,address spender,uint256 amount) internal virtual override{
            require(owner != address(0), "CCv2: approve from the zero address");
            require(spender != address(0), "CCv2: approve to the zero address");

            _allowances[owner][spender] = amount;
            emit Approval(owner, spender, amount);
        }

         
       

        


}