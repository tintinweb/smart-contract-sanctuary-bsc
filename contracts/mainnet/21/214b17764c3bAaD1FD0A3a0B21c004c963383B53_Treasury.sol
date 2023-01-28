/**
 *Submitted for verification at BscScan.com on 2023-01-28
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.4;

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

    function min(uint x, uint y) internal pure returns (uint z) {
        z = x < y ? x : y;
    }

    function abs(uint x, uint y) internal pure returns (uint) {
        return x >= y ? x - y : y - x;
    }

    function sqrt(uint y) internal pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
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
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
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
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

library EnumerableSet {
    struct Set {
        bytes32[] _values;
        mapping (bytes32 => uint256) _indexes;
    }

    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;
            bytes32 lastvalue = set._values[lastIndex];

            set._values[toDeleteIndex] = lastvalue;
            set._indexes[lastvalue] = toDeleteIndex + 1;
            set._values.pop();

            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(value)));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(value)));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(value)));
    }

    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint256(_at(set._inner, index)));
    }


    // UintSet

    struct UintSet {
        Set _inner;
    }

    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }
}

interface IOwned {
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function owner() external view returns (address);

    function transferOwnership(address newOwner) external;
    function claimOwnership() external;
}

interface IERC20 {
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    function totalSupply() external view returns (uint256);
    function balanceOf(address _account) external view returns (uint256);
    function transfer(address _recipient, uint256 _amount) external returns (bool);
    function allowance(address _owner, address _spender) external view returns (uint256);
    function approve(address _spender, uint256 _amount) external returns (bool);
    function transferFrom(address _sender, address _recipient, uint256 _amount) external returns (bool);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

interface IMintable is IERC20 {
    function mint(address to, uint256 amount) external returns (bool);
    function destroy(uint256 amount) external returns (bool);
}

interface ITreasury {
    function mintDollars(uint256 dollarAmount) external returns (uint256 mintAmount);
    function borrow(uint256 dollarAmount) external returns (bool);
    function settle(uint256 settleAmount) external returns (bool);
    function income(uint256 dollarAmount) external;
}

interface ITokensRecoverable {
    function recoverTokens(IERC20 token) external;
}

abstract contract ERC20 is IERC20 {
    using SafeMath for uint256;

    string public override name;
    string public override symbol;
    
    uint8 public override decimals = 18;

    uint256 public override totalSupply;

    mapping (address => uint256) internal _balanceOf;
    mapping (address => mapping (address => uint256)) public override allowance;

    constructor (string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
    }

    function balanceOf(address a) public virtual override view returns (uint256) { return _balanceOf[a]; }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        uint256 oldAllowance = allowance[sender][msg.sender];
        if (oldAllowance != uint256(-1)) {
            _approve(sender, msg.sender, oldAllowance.sub(amount, "ERC20: transfer amount exceeds allowance"));
        }
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, allowance[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, allowance[msg.sender][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balanceOf[sender] = _balanceOf[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balanceOf[recipient] = _balanceOf[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        totalSupply = totalSupply.add(amount);
        _balanceOf[account] = _balanceOf[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balanceOf[account] = _balanceOf[account].sub(amount, "ERC20: burn amount exceeds balance");
        totalSupply = totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        allowance[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 _decimals) internal {
        decimals = _decimals;
    }

    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
        uint256 currentAllowance = allowance[owner][spender];
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            _approve(owner, spender, currentAllowance - amount);
        }
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}

abstract contract Owned is IOwned {
    address public override owner = msg.sender;
    address internal pendingOwner;

    modifier ownerOnly() {
        require (msg.sender == owner, "Owner only");
        _;
    }

    function transferOwnership(address newOwner) public override ownerOnly() {
        pendingOwner = newOwner;
    }

    function claimOwnership() public override {
        require (pendingOwner == msg.sender);
        pendingOwner = address(0);
        emit OwnershipTransferred(owner, msg.sender);
        owner = msg.sender;
    }
}

contract Whitelist is Owned {

    modifier onlyWhitelisted() {
        if(active){
            require(whitelist[msg.sender], 'not whitelisted');
        }
        _;
    }

    bool active = true;

    mapping(address => bool) public whitelist;

    event WhitelistedAddressAdded(address addr);
    event WhitelistedAddressRemoved(address addr);

    function activateDeactivateWhitelist() public ownerOnly() {
        active = !active;
    }

    function addAddressToWhitelist(address addr) public ownerOnly() returns(bool success) {
        if (!whitelist[addr]) {
            whitelist[addr] = true;
            emit WhitelistedAddressAdded(addr);
            success = true;
        }
    }

    function addAddressesToWhitelist(address[] calldata addrs) public ownerOnly() returns(bool success) {
        for (uint256 i = 0; i < addrs.length; i++) {
            if (addAddressToWhitelist(addrs[i])) {
                success = true;
            }
        }
    }

    function removeAddressFromWhitelist(address addr) ownerOnly() public returns(bool success) {
        if (whitelist[addr]) {
            whitelist[addr] = false;
            emit WhitelistedAddressRemoved(addr);
            success = true;
        }
    }

    function removeAddressesFromWhitelist(address[] calldata addrs) ownerOnly() public returns(bool success) {
        for (uint256 i = 0; i < addrs.length; i++) {
            if (removeAddressFromWhitelist(addrs[i])) {
                success = true;
            }
        }
    }
}

abstract contract TokensRecoverable is Owned, ITokensRecoverable {
    using SafeERC20 for IERC20;

    function recoverTokens(IERC20 token) public override ownerOnly() {
        require (canRecoverTokens(token));
        token.safeTransfer(msg.sender, token.balanceOf(address(this)));
    }

    function canRecoverTokens(IERC20 token) internal virtual view returns (bool) { 
        return address(token) != address(this); 
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
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        _status = _NOT_ENTERED;
    }

    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }
}

contract MintableToken is ERC20, Whitelist, IMintable {

    constructor(string memory _name, string memory _symbol) ERC20(_name, _symbol) {}

    function mint(address to, uint256 amount) external override onlyWhitelisted() returns (bool) {
        _mint(to, amount);
        return true;
    }

    function destroy(uint256 amount) external override onlyWhitelisted() returns (bool){
        _burn(msg.sender, amount);
        return true;
    }
}

contract Treasury is Whitelist, ITreasury, TokensRecoverable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address public distributor;

    uint256 public totalFunds;

    uint256 public bondMintPrice;
    uint256 public bondRedeemValue;

    IMintable public dollar;
    IMintable public bond;

    IERC20 public constant busd = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);

    mapping(address => uint) public currentDebt;

    event DepositCollateral(address indexed user, uint256 dollarAmount, uint256 timestamp);
    event WithdrawCollateral(address indexed user, uint256 dollarAmount, uint256 timestamp);
    event DepositIncome(address indexed user, uint256 dollarAmount, uint256 timestamp);
    event MintDollars(address indexed user, uint256 dollarAmount, uint256 timestamp);

    event UpdateBondPrices(address indexed user, uint256 bondMintPrice, uint256 bondRedeemValue);

    ////////////////////////////
    // CONSTRUCTOR & FALLBACK //
    ////////////////////////////

    constructor(address _dollar, address _bond, address _distributor) {
        
        dollar = IMintable(_dollar);
        bond = IMintable(_bond);

        distributor = _distributor;

        bondMintPrice = 1 ether;
        bondRedeemValue = 0.9 ether;
    }

    ////////////////////
    // VIEW FUNCTIONS //
    ////////////////////

    function withdrawable() public view returns (uint256) {
        uint256 circulatingSupply = dollar.totalSupply();
        return totalFunds.sub(circulatingSupply);
    }

    /////////////////////
    // WRITE FUNCTIONS //
    /////////////////////

    function deposit(uint256 dollarAmount) external nonReentrant() {
        busd.safeTransferFrom(msg.sender, address(this), dollarAmount);
        totalFunds = totalFunds.add(dollarAmount);
        uint256 bondsAmount = dollarAmount.mul(1 ether).div(bondMintPrice);
        bool success = bond.mint(msg.sender, bondsAmount);
        require(success, "MINTING FAILED");
        emit DepositCollateral(msg.sender, dollarAmount, block.timestamp);
    }

    function withdraw(uint256 bondsAmount) external nonReentrant() {
        uint256 dollarAmount = bondsAmount.mul(bondRedeemValue).div(1 ether);
        require(withdrawable() >= dollarAmount, "INSUFFICIENT FUNDS");
        busd.safeTransfer(msg.sender, dollarAmount);
        totalFunds = totalFunds.sub(dollarAmount);
        IERC20(bond).safeTransferFrom(msg.sender, address(this), bondsAmount);
        bool success = bond.destroy(bondsAmount);
        require(success, "BURNING FAILED"); //insufficient bonds balance
        emit WithdrawCollateral(msg.sender, dollarAmount, block.timestamp);
    }

    function income(uint256 dollarAmount) external override nonReentrant() {
        busd.safeTransferFrom(msg.sender, address(this), dollarAmount);
        totalFunds = totalFunds.add(dollarAmount);
        emit DepositIncome(msg.sender, dollarAmount, block.timestamp);
    }

    //////////////////////////
    // RESTRICTED FUNCTIONS //
    //////////////////////////

    function borrow(uint256 dollarAmount) external override onlyWhitelisted() returns (bool) {
        IERC20(dollar).safeTransferFrom(msg.sender, address(this), dollarAmount);
        busd.safeTransfer(msg.sender, dollarAmount);
        return true;
    }

    function settle(uint256 settleAmount) external override onlyWhitelisted() returns (bool) {
        require(currentDebt[msg.sender] >= settleAmount, "INVALID AMOUNT");
        busd.safeTransferFrom(msg.sender, address(this), settleAmount);
        IERC20(dollar).safeTransfer(msg.sender, settleAmount);
        currentDebt[msg.sender] = currentDebt[msg.sender] - (settleAmount);
        return true;
    }

    function mintDollars(uint256 dollarAmount) external override onlyWhitelisted() returns (uint256 mintAmount) {
        uint256 balance = withdrawable();
        if (balance < dollarAmount) {
            mintAmount = Math.min(balance, dollarAmount);
        }else{
            mintAmount = dollarAmount;
        }
        if(mintAmount > 0){
            bool success = dollar.mint(distributor, mintAmount);
            require(success, "MINTING FAILED");
        }

        emit MintDollars(msg.sender, mintAmount, block.timestamp);
        return mintAmount;
    }

    //////////////////////////
    // OWNER-ONLY FUNCTIONS //
    //////////////////////////

    function setDistributor(address _distributor) external ownerOnly() {
        distributor = _distributor;
    }

    function updateBondPrices(uint256 _bondMintPrice, uint256 _bondRedeemValue) external ownerOnly() {
        bondMintPrice = _bondMintPrice;
        bondRedeemValue = _bondRedeemValue;

        emit UpdateBondPrices(msg.sender, _bondMintPrice, _bondRedeemValue);
    }
}