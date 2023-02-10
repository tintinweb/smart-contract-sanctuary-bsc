/**
 *Submitted for verification at BscScan.com on 2023-02-09
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;


// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }
}


// Interface of the ERC20 standard as defined in the EIP.
interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address from, address to) external view returns (uint256);
    function approve(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}


// safe transfer
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
        // (bool success,) = to.call.value(value)(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}


// crystal interface
interface ICrystal {
    function crystalPriceUSDT() external view returns (uint256);
    function mintCrystal(address account, uint256 amount) external returns (bool);
    function burnCrystal(address account, uint256 amount) external returns (bool);
}


// owner
abstract contract Ownable {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, 'owner error');
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }
}


// admin
abstract contract Adminable is Ownable {
    mapping(address => bool) public isAdmin;

    constructor() {}

    modifier onlyAdmin {
        require(isAdmin[msg.sender], "admin error");
        _;
    }

    function addAdmin(address account) external onlyOwner {
        require(account != address(0), "0 address error");
        isAdmin[account] = true;
    }

    function removeAdmin(address account) external onlyOwner {
        require(account != address(0), "0 address error");
        isAdmin[account] = false;
    }
}


contract Crystal is IERC20, ICrystal, Adminable {
    string private _name = "Crystal Token";
    string private _symbol = "Crystal";
    uint8 private _decimals = 18;
    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    // crystals price to usdt, 1e18 crystals = ? crystalPriceUSDT USDT, default 1e18 USDT.
    uint256 public _crystalPriceUSDT = 1e18;


    constructor() {}

    function name() public view override returns (string memory) {
        return _name;
    }

    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    function decimals() public view override returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function _transfer(address from, address to, uint256 amount) private {
        _balances[from] = SafeMath.sub(_balances[from], amount);
        _balances[to] = SafeMath.add(_balances[to], amount);
        emit Transfer(from, to, amount);
    }

    function transfer(address to, uint256 amount) public override returns (bool) {
        require(_balances[msg.sender] >= amount, 'balance error');
        _transfer(msg.sender, to, amount);
        return true;
    }

    function allowance(address from, address to) public override view returns (uint256) {
        return _allowances[from][to];
    }

    function approve(address to, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][to] = amount;
        emit Approval(msg.sender, to, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public override returns (bool) {
        require(_balances[from] >= amount, 'balance error');
        require(_allowances[from][msg.sender] >= amount, 'approve error');
        _allowances[from][msg.sender] = SafeMath.sub(_allowances[from][msg.sender], amount);
        _transfer(from, to, amount);
        return true;
    }

    event MintCrystal(address account, uint256 amount);
    event BurnCrystal(address account, uint256 amount);

    function crystalPriceUSDT() public override view returns(uint256) {
        return _crystalPriceUSDT;
    }

    function setCrystalPriceUSDT(uint256 newCrystalPriceUSDT) public onlyOwner {
        require(newCrystalPriceUSDT > 0, "crystal price error");
        _crystalPriceUSDT = newCrystalPriceUSDT;
    }

    function mintCrystal(address account, uint256 amount) public override onlyAdmin returns (bool) {
        _balances[account] = SafeMath.add(_balances[account], amount);
        _totalSupply = SafeMath.add(_totalSupply, amount);
        emit MintCrystal(account, amount);
        return true;
    }

    function burnCrystal(address account, uint256 amount) public override onlyAdmin returns (bool) {
        require(_balances[account] >= amount, "balance error");
        _balances[account] = SafeMath.sub(_balances[account], amount);
        _totalSupply = SafeMath.sub(_totalSupply, amount);
        emit BurnCrystal(account, amount);
        return true;
    }

    // take token
    function takeToken(address token, address to, uint256 value) external onlyOwner {
        require(to != address(0), "zero address error");
        require(value > 0, "value zero error");
        TransferHelper.safeTransfer(token, to, value);
    }


}