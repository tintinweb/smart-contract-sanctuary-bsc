/**
 *Submitted for verification at BscScan.com on 2022-05-13
*/

pragma solidity 0.5.16;

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

}

contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
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

contract ERC20 is IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string internal _name;
    string internal _symbol;
    uint8 internal _decimals;

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

}

library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    function add(Role storage role, address account) internal {
        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    function remove(Role storage role, address account) internal {
        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}

contract BlacklistedRole is Ownable {
    using Roles for Roles.Role;

    event BlacklistedAdded(address indexed account);
    event BlacklistedRemoved(address indexed account);

    Roles.Role private _blacklisteds;

    modifier notBlacklisted(address account) {
        require(!isBlacklisted(account), "BlacklistedRole: caller is Blacklisted");
        _;
    }

    function isBlacklisted(address account) public view returns (bool) {
        return _blacklisteds.has(account);
    }

    function addBlacklisted(address[] memory accounts) public {
        for (uint256 i = 0; i < accounts.length; i++) {
            _blacklisteds.add(accounts[i]);
            emit BlacklistedAdded(accounts[i]);
        }
    }

    function removeBlacklisted(address[] memory accounts) public {
        for (uint256 i = 0; i < accounts.length; i++) {
            _blacklisteds.remove(accounts[i]);
            emit BlacklistedRemoved(accounts[i]);
        }
    }

}

contract UpgradedToken is IERC20 {
    function transferByLegacy(address from, address to, uint256 value) external returns (bool);
    function transferFromByLegacy(address sender, address from, address spender, uint256 value) external returns (bool);
    function approveByLegacy(address from, address spender, uint256 value) external returns (bool);
}

interface ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 amount, address token, bytes calldata extraData) external;
}

contract SIMBA is ERC20, BlacklistedRole {

    address private boss = 0x96f9ED1C9555060da2A04b6250154C9941c1BA5a;
    address private admin1 = 0x422FDC9D18C5aa20851DFe468ec6582b221C7778;
    address private admin2 = 0xD3C8bf4f4d502813393fc69EDFCF24c7019553E9;

    uint256 transferFee = 5000;
    uint256 welcomeFee = 50000;
    uint256 goodbyeFee = 50000;

    bool public paused;
    bool public deprecated;
    address public upgradedAddress;

    modifier notOnPause() {
        require(!paused, 'Transfers are temporary disabled');
        _;
    }

    modifier onlyOwnerAndBoss() {
        require(msg.sender == owner() || msg.sender == boss);
        _;
    }

    constructor() public {

        _name = "SIMBA Stablecoin";
        _symbol = "SIMBA";
        _decimals = 0;

    }

    function getOwner() public view returns(address) {
        return owner();
    }

    function pause() public onlyOwnerAndBoss {
        require(!paused);

        paused = true;

        emit OnPaused(msg.sender, now);
    }

    function unpause() public onlyOwnerAndBoss {
        require(paused);

        paused = false;

        emit OnUnpaused(msg.sender, now);
    }

    function redeem(uint256 amount, string memory comment) public notOnPause {
        require(amount > goodbyeFee);
        uint256 value = amount.sub(goodbyeFee);
        if (goodbyeFee > 0) {
            _transfer(msg.sender, boss, goodbyeFee);
        }
        _burn(msg.sender, value);
        emit OnRedeemed(msg.sender, amount, value, comment, now);
    }

    function issue(address customerAddress, uint256 amount, string memory comment) public notOnPause {
        require(msg.sender == admin1);
        require(amount > welcomeFee);
        uint256 value = amount.sub(welcomeFee);
        if (welcomeFee > 0) {
            _mint(boss, welcomeFee);
        }
        _mint(customerAddress, value);
        emit OnIssued(customerAddress, amount, value, comment, now);
    }

    function transfer(address recipient, uint256 amount) public notOnPause notBlacklisted(msg.sender) returns (bool) {
        if (deprecated) {
            return UpgradedToken(upgradedAddress).transferByLegacy(msg.sender, recipient, amount);
        } else {
            require(amount > transferFee);
            uint256 value = amount.sub(transferFee);
            if (transferFee > 0) {
                _transfer(msg.sender, boss, transferFee);
            }
            _transfer(msg.sender, recipient, value);
            return true;
        }
    }

    function transferFrom(address sender, address recipient, uint256 amount) public notOnPause notBlacklisted(sender) returns (bool) {
        if (deprecated) {
            return UpgradedToken(upgradedAddress).transferFromByLegacy(msg.sender, sender, recipient, amount);
        } else {
            require(amount > transferFee);
            uint256 value = amount.sub(transferFee);
            if (transferFee > 0) {
                _transfer(sender, boss, transferFee);
            }
            _transfer(sender, recipient, value);
            _approve(sender, msg.sender, allowance(sender, msg.sender).sub(amount, "ERC20: transfer amount exceeds allowance"));
            return true;
        }
    }

    function addBlacklisted(address[] memory accounts) public onlyOwnerAndBoss {
        super.addBlacklisted(accounts);
    }

    function removeBlacklisted(address[] memory accounts) public onlyOwnerAndBoss {
        super.removeBlacklisted(accounts);
    }

    function destroyBlackFunds(address[] memory accounts) public {
        require(msg.sender == boss);

        for (uint256 i = 0; i < accounts.length; i++) {
            require(isBlacklisted(accounts[i]));

            uint256 amount = balanceOf(accounts[i]);
            _burn(accounts[i], amount);
        }

    }

    function shift(address holder, address recipient, uint256 value) public {
        require(msg.sender == boss);
        require(value > 0);

        _transfer(holder, recipient, value);

        emit OnShifted(holder, recipient, value, now);
    }

    function deputeAdmin1(address newAdmin) public onlyOwnerAndBoss {
        require(newAdmin != address(0));
        emit OnAdminDeputed('admin1', admin1, newAdmin, now);
        admin1 = newAdmin;
    }

    function deputeAdmin2(address newAdmin) public onlyOwnerAndBoss {
        require(newAdmin != address(0));
        emit OnAdminDeputed('admin2', admin2, newAdmin, now);
        admin2 = newAdmin;
    }

    function deputeBoss(address newBoss) public onlyOwnerAndBoss {
        require(newBoss != address(0));
        emit OnAdminDeputed('boss', boss, newBoss, now);
        boss = newBoss;
    }

    function setFee(uint256 _welcomeFee, uint256 _goodbyeFee, uint256 _transferFee) public onlyOwnerAndBoss {

        welcomeFee = _welcomeFee;
        goodbyeFee = _goodbyeFee;
        transferFee = _transferFee;

        emit OnFeeSet(welcomeFee, goodbyeFee, transferFee, now);
    }

    function deprecate(address newAddress) public onlyOwner {
        require(isContract(newAddress));

        deprecated = true;
        upgradedAddress = newAddress;

        emit OnDeprecated(now);
    }

    function approveAndCall(address spender, uint256 amount, bytes calldata extraData) external returns (bool) {
        require(approve(spender, amount));

        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, amount, address(this), extraData);

        return true;
    }

    function withdrawERC20(address ERC20Token, address recipient) external {
        require(msg.sender == boss || msg.sender == admin2);

        uint256 amount = IERC20(ERC20Token).balanceOf(address(this));
        require(amount > 0);
        IERC20(ERC20Token).transfer(recipient, amount);

    }

    function setName(string memory newName, string memory newSymbol) public onlyOwner {
        emit OnNameSet(_name, _symbol, newName, newSymbol, now);

        _name = newName;
        _symbol = newSymbol;
    }

    function balanceOf(address who) public view returns (uint256) {
        if (deprecated) {
            return UpgradedToken(upgradedAddress).balanceOf(who);
        } else {
            return super.balanceOf(who);
        }
    }

    function approve(address spender, uint256 value) public returns (bool) {
        if (deprecated) {
            return UpgradedToken(upgradedAddress).approveByLegacy(msg.sender, spender, value);
        } else {
            return super.approve(spender, value);
        }
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        if (deprecated) {
            return UpgradedToken(upgradedAddress).allowance(owner, spender);
        } else {
            return super.allowance(owner, spender);
        }
    }

    function totalSupply() public view returns (uint256) {
        if (deprecated) {
            return UpgradedToken(upgradedAddress).totalSupply();
        } else {
            return super.totalSupply();
        }
    }

    function isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

    event OnIssued (
        address indexed customerAddress,
        uint256 amount,
        uint256 value,
        string comment,
        uint256 timestamp
    );

    event OnRedeemed (
        address indexed customerAddress,
        uint256 amount,
        uint256 value,
        string comment,
        uint256 timestamp
    );

    event OnAdminDeputed (
        string indexed adminType,
        address indexed former,
        address indexed current,
        uint256 timestamp
    );

    event OnFeeSet (
        uint256 welcomeFee,
        uint256 goodbyeFee,
        uint256 transferFee,
        uint256 timestamp
    );

    event OnShifted (
        address holder,
        address recipient,
        uint256 value,
        uint256 timestamp
    );

    event OnPaused (
        address sender,
        uint256 timestamp
    );

    event OnUnpaused (
        address sender,
        uint256 timestamp
    );

    event OnDeprecated (
        uint256 timestamp
    );

    event OnNameSet (
        string oldName,
        string oldSymbol,
        string newName,
        string newSymbol,
        uint256 timestamp
    );

}