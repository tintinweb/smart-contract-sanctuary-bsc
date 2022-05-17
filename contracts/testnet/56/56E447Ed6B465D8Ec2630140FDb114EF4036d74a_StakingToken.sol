/**
 *Submitted for verification at BscScan.com on 2022-05-17
*/

/**
 *Submitted for verification at cronoscan.com on 2022-05-11
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success, ) = recipient.call{ value: amount }("");
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
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
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
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

library SafeERC20 {
    using SafeMath for uint256;
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
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
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

interface IHourglass {
    function myTokens() external view returns(uint256);
    function balanceOf(address _customerAddress) view external returns(uint256);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
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
        require(whitelist[msg.sender], 'no whitelist');
        _;
    }

    function addAddressToWhitelist(address addr) onlyOwner public returns(bool success) {
        if (!whitelist[addr]) {
            whitelist[addr] = true;
            emit WhitelistedAddressAdded(addr);
            success = true;
        }
    }

    function addAddressesToWhitelist(address[] memory addrs) onlyOwner public returns(bool success) {
        for (uint256 i = 0; i < addrs.length; i++) {
            if (addAddressToWhitelist(addrs[i])) {
                success = true;
            }
        }
        return success;
    }

    function removeAddressFromWhitelist(address addr) onlyOwner public returns(bool success) {
        if (whitelist[addr]) {
            whitelist[addr] = false;
            emit WhitelistedAddressRemoved(addr);
            success = true;
        }
        return success;
    }

    function removeAddressesFromWhitelist(address[] memory addrs) onlyOwner public returns(bool success) {
        for (uint256 i = 0; i < addrs.length; i++) {
            if (removeAddressFromWhitelist(addrs[i])) {
                success = true;
            }
        }
        return success;
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

    constructor (string memory name_, string memory symbol_) public {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    function name() public view virtual returns (string memory) {
        return _name;
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {
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
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
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

    function _setupDecimals(uint8 decimals_) internal virtual {
        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}

contract StakingToken is ERC20, Whitelist {
    using Address for address;
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    ////////////////
    // INTERFACES //
    ////////////////

    IERC20 public token;
    IHourglass public glass;

    ///////////////////////////////
    // CONFIGURABLES & VARIABLES //
    ///////////////////////////////

    address public feeSplitter;

    uint256 public totalStakers;
    uint256 public allTimeStaked;
    uint256 public allTimeUnstaked;

    uint256 public totalFees;

    uint256 public requiredBalance;
    uint256 public unstakeFeePercent;

    //////////////////
    // DATA STRUCTS //
    //////////////////

    struct AddressRecords {
        uint256 totalStaked;
        uint256 totalUnstaked;
    }

    ///////////////////
    // DATA MAPPINGS //
    ///////////////////

    mapping(address => AddressRecords) public userData;

    /////////////////////////////
    // MODIFIERS & RESTRICTORS //
    /////////////////////////////

    /////////////////////
    // CONTRACT EVENTS //
    /////////////////////

    event onStakeTokens(address indexed _caller, uint256 _amount, uint256 _timestamp);
    event onUnstakeTokens(address indexed _caller, uint256 _amount, uint256 _timestamp);

    event onSetFeeSplitter(address indexed _caller, address oldOne, address newOne, uint256 timestamp);
    event onSetImmunityToken(address indexed _caller, address oldOne, address newOne, uint256 timestamp);

    event onSetWithdrawalFee(address indexed _caller, uint256 oldAmount, uint256 newAmount, uint256 timestamp);
    event onSetRequiredBalance(address indexed _caller, uint256 oldAmount, uint256 newAmount, uint256 timestamp);

    ////////////////////////////
    // CONSTRUCTOR & FALLBACK //
    ////////////////////////////

    constructor(
        string memory _xName, 
        string memory _xSymbol, 
        IERC20 _baseToken, 
        address _feeSplitter, 
        address _hourglass
    ) public ERC20(_xName, _xSymbol) {
        
        token = _baseToken;
        glass = IHourglass(_hourglass);

        feeSplitter = _feeSplitter;

        requiredBalance = 50000000000000000000000;
        unstakeFeePercent = 0;
    }

    ///////////////////////////
    // PUBLIC VIEW FUNCTIONS //
    ///////////////////////////

    // User is immune to unstake fees when holding an item
    function checkImmunity(address _user) public view returns (bool _isImmune) {
        uint256 _x = glass.balanceOf(_user);
        if (_x > requiredBalance) {
            return true;
        }
        return false;
    }

    // Total staked and unstaked, of an address
    function statsOf(address _user) public view returns (uint256 _totalStaked, uint256 _totalUnstaked) {
        return (userData[_user].totalStaked, userData[_user].totalUnstaked);
    }

    // Find how many xTokens will result from staking _amount
    function baseToStaked(uint256 _amount) public view returns (uint256 _stakedAmount) {
        uint256 totalBase = token.balanceOf(address(this));
        uint256 totalStaked = this.totalSupply();

        if (totalStaked == 0 || totalBase == 0) {
            return _amount;
        } else {
            return _amount.mul(totalStaked).div(totalBase);
        }
    }

    // Find how many tokens will result from unstaking _amount
    function stakedToBase(uint256 _amount) public view returns (uint256 _baseAmount) {

        // Find the staking ratio from supply and balance
        uint256 totalxSupply = this.totalSupply();
        uint256 tokenBalance = token.balanceOf(address(this));

        // Find tokens from xTokens before any action
        uint256 _tokens = _amount.mul(tokenBalance).div(totalxSupply);

        // Then do so, and return the result
        return (_tokens);
    }

    // Calculate the fee to take for unstaking
    function calculateFee(uint256 _amount) public view returns (uint256) {
        return (_amount.mul(unstakeFeePercent).div(10000));
    }

    ////////////////////////////
    // PUBLIC WRITE FUNCTIONS //
    ////////////////////////////

    // Stake token, get staking shares
    function stake(uint256 amount) public {

        // Get balance and supply
        uint256 totalBase = token.balanceOf(address(this));
        uint256 totalStaked = this.totalSupply();

        // If the caller has no staked tokens recorded, add them to the count
        if (userData[msg.sender].totalStaked == 0) {
            totalStakers += 1;
        }

        // If there are no tokens staked, or if there's no token held
        if (totalStaked == 0 || totalBase == 0) {

            // Just mint the tokens (1:1 ratio)
            _mint(msg.sender, amount);

        // Otherwise...
        } else {

            // Find xToken ratio from balance and supply
            uint256 mintAmount = amount.mul(totalStaked).div(totalBase);

            // and mint the right amount of tokens
            _mint(msg.sender, mintAmount);
        }

        // Collect the token token to the staking contract
        token.transferFrom(msg.sender, address(this), amount);

        // Update stats
        userData[msg.sender].totalStaked += amount;
        allTimeStaked += amount;

        // Tell the network, successful function
        emit onStakeTokens(msg.sender, amount, block.timestamp);
    }

    // Unstake shares, claim back token
    function unstake(uint256 amount) public {

        // Get immunity status of address
        bool _isImmune = checkImmunity(msg.sender);

        // Calculate Unstake value
        uint256 _baseAmount = stakedToBase(amount);

        // Calculate the potential fee
        uint256 _fee = calculateFee(_baseAmount);

        // Initialise output amount
        uint256 _outputAmount;

        // If the caller is immune
        if (_isImmune == true) {

            // Output amount = full amount
            _outputAmount = (_baseAmount);

        // Otherwise,
        } else {

            // Output amount = full, minus fee
            _outputAmount = (_baseAmount.sub(_fee));

            // Add fee to total count
            totalFees += _fee;

            // Transfer fee to recipient
            token.transfer(feeSplitter, _fee);

        }

        // Burn the stake token
        _burn(msg.sender, amount);

        // Transfer the unstaked tokens and the fees
        token.transfer(msg.sender, _outputAmount);

        // Update stats
        userData[msg.sender].totalUnstaked += amount;
        allTimeUnstaked += amount;

        // Tell the network
        emit onUnstakeTokens(msg.sender, amount, block.timestamp);
    }

    //////////////////////////
    // RESTRICTED FUNCTIONS //
    //////////////////////////

    // Set the FeeSplitter for this token
    function setRequiredBalance(uint256 amount) public onlyOwner() returns (bool _success) {
        require(amount >= 0, "INVALID_AMOUNT");
        
        uint256 _old = requiredBalance;
        requiredBalance = amount;

        emit onSetRequiredBalance(msg.sender, _old, amount, block.timestamp);
        return true;
    }

    // Set withdrawal fee percentage
    function setunstakeFeePercentage(uint256 _percent) public onlyWhitelisted() returns (bool _success) {

        // 10% max fee
        require(_percent < 1001, "INVALID_VALUE");

        uint256 oldValue = unstakeFeePercent;
        unstakeFeePercent = _percent;

        emit onSetWithdrawalFee(msg.sender, oldValue, unstakeFeePercent, block.timestamp);
        return true;
    }

    //////////////////////////
    // OWNER-ONLY FUNCTIONS //
    //////////////////////////

    // Set the FeeSplitter for this token
    function setFeeSplitter(address _splitter) public onlyOwner() returns (bool _success) {
        require(Address.isContract(_splitter), "INVALID_ADDRESS");
        
        address oldSplitter = feeSplitter;
        feeSplitter = _splitter;

        emit onSetFeeSplitter(msg.sender, oldSplitter, feeSplitter, block.timestamp);
        return true;
    }

    // Set the immunity token contract for this xToken
    function setImmunityToken(address _contract) public onlyOwner() returns (bool _success) {
        require(Address.isContract(_contract), "INVALID_ADDRESS");
        
        address oldContract = address(glass);
        glass = IHourglass(_contract);

        emit onSetImmunityToken(msg.sender, oldContract, _contract, block.timestamp);
        return true;
    }
}