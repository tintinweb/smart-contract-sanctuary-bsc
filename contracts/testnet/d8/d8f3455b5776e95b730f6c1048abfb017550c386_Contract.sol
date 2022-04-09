/**
 *Submitted for verification at BscScan.com on 2022-04-09
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
interface IERC165 {
    
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
abstract contract ERC165 is IERC165 {
    
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    
    function toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
    
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }
    
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}
interface IAccessControl {
    
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);
    
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);
    
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);
    
    function hasRole(bytes32 role, address account) external view returns (bool);
    
    function getRoleAdmin(bytes32 role) external view returns (bytes32);
    
    function grantRole(bytes32 role, address account) external;
    
    function revokeRole(bytes32 role, address account) external;
    
    function renounceRole(bytes32 role, address account) external;
}
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }
    mapping(bytes32 => RoleData) private _roles;
    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;
    
    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }
    
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }
    
    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }
    
    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }
    
    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
        return _roles[role].adminRole;
    }
    
    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }
    
    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }
    
    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");
        _revokeRole(role, account);
    }
    
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }
    
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }
    
    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }
    
    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}
abstract contract Pausable is Context {
    
    event Paused(address account);
    
    event Unpaused(address account);
    bool private _paused;
    
    constructor() {
        _paused = false;
    }
    
    function paused() public view virtual returns (bool) {
        return _paused;
    }
    
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }
    
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }
    
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }
    
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}
interface IERC20 {
    
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
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    
    event Approval(address indexed owner, address indexed spender, uint256 value);
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
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }
    
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
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
abstract contract ERC20Pausable is ERC20, Pausable {
    
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);
        require(!paused(), "ERC20Pausable: token transfer while paused");
    }
}

// pragma solidity ^0.8.7;

// import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
// import "@openzeppelin/contracts/access/AccessControl.sol";

contract Contract is ERC20Pausable, AccessControl {

    address private _owner;
    uint256 private _marketingFee;
    uint256 private _liquidityFee;
    uint256 private _developFee;
    uint256 private _totalFee;
    uint256 private _denominator;
    address private _rewardWallet;
    address private _router;
    address private _pair;

    mapping (address => bool) private _isExcludeFromFee;
    
    constructor() ERC20("TokenName", "SBL") {
        _mint(msg.sender, 1_000_000_000 * 10 ** decimals());
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _rewardWallet = msg.sender;
        _marketingFee = 4;
        _liquidityFee = 4;
        _developFee = 2;
        _denominator = 100;
        _totalFee = _marketingFee + _liquidityFee + _developFee;
        _owner = msg.sender;
    }

    function owner() view public returns (address) {
        return _owner;
    }

    function renounceOwnership() external {
        require(msg.sender == _owner, "AccessControl: you are not owner!");
        _owner = address(0);
    }

    function changeTradingStatus() external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (!paused()) {
            _pause();
        } else if (paused()) {
            _unpause();
        }
    }

    function burn(address adr, uint256 amount) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _burn(adr, amount);
    }

    function setFee(uint256 marketingFee, uint256 liquidityFee, uint256 developFee, uint256 denominator) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _marketingFee = marketingFee;
        _liquidityFee = liquidityFee;
        _denominator = denominator;
        _developFee = developFee;
        _totalFee = _marketingFee + _liquidityFee + _developFee;
    }

    function setRewardWallet(address newRewardWallet) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _rewardWallet = newRewardWallet;
    }

    function totalFee() view public returns (uint256, uint256, uint256, uint256) {
        return (_marketingFee, _liquidityFee, _developFee, _denominator);
    }
    
    function rewardWallet() view public returns (address) {
        return _rewardWallet;
    }

    function removeFee(address adr) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(!_isExcludeFromFee[adr], "Error: already excluded from fees");
        _isExcludeFromFee[adr] = true;
    }

    function chargeFee(address adr) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(_isExcludeFromFee[adr], "Error: already included in fees");
        _isExcludeFromFee[adr] = false;
    }

    function isExcludeFromFee(address adr) view public returns (bool) {
        return _isExcludeFromFee[adr];
    }

    function _grantRole(bytes32 role, address account) internal override {   
        super._grantRole(role, account);
        _isExcludeFromFee[account] = true;
    }

    function setRouterAndPair(address newRouter, address newPair) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _router = newRouter;
        _pair = newPair;
        _isExcludeFromFee[_router] = true;
        _isExcludeFromFee[_pair] = true;
    }

    function router() view public returns (address) {
        return _router;
    }
    function pair() view public returns (address) {
        return _pair;
    }

    function _transfer(address from, address to, uint256 amount) internal override {
        if (!_isExcludeFromFee[from]) {
            uint256 feeAmount = amount * _totalFee / _denominator;
            uint256 transferAmount = amount - feeAmount;
            super._transfer(from, _rewardWallet, feeAmount);
            super._transfer(from, to, transferAmount);
        } else if (_isExcludeFromFee[from]) {
            super._transfer(from, to, amount);
        }
    }
}