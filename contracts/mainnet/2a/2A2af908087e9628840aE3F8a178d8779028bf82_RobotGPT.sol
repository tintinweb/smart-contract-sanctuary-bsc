/**
 *Submitted for verification at BscScan.com on 2023-04-01
*/

/**
 *Submitted for verification at Etherscan.io on 2023-04-01
*/

// SPDX-License-Identifier: UNLICENSED
// Made with ❤ by the RobotGPT Team

pragma solidity ^0.8.0;

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract RobotGPT is IBEP20 {
    string public constant name = "RobotGPT";
    string public constant symbol = "RGPT";
    uint8 public constant decimals = 18;
    uint256 private constant MAX = ~uint256(0);
    uint256 private constant _totalSupply = 1000000 * 10**decimals;
    uint256 private _totalBurnt;
    uint256 private _totalDistributed;
    uint256 private _teamWalletAmount = (_totalSupply * 5) / 100; //5% for Teamwallet
    uint256 private _devWalletAmount = (_totalSupply * 25) / 1000; //2.5% for Devwallet
    uint256 private _dexWalletAmount = (_totalSupply * 5) / 100; //5% for DEXwallet
    uint256 private _autoCompoundingBalance;
    uint256 private _transactionCounter;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private _isExcludedFromAutoCompounding;
    mapping(address => uint256) private _lastTransaction;
    address private _teamWallet;
    address private _devWallet;
    address private _dexWallet;

    constructor() {
        _teamWallet = address(0x1DdF0bc0f6823e03639dd782FB9Bcc5124ee08c4);
        _devWallet = address(0x346a4f6D03612599Fb67366cb16787dfFa3fF043);
        _dexWallet = address(0x932D6A7EaAB9b3985758014f574E0FCB4a9f3439);
        _balances[_teamWallet] = _teamWalletAmount;
        _balances[_devWallet] = _devWalletAmount;
        _balances[_dexWallet] = _dexWalletAmount;
        _balances[msg.sender] = _totalSupply - _teamWalletAmount - _devWalletAmount - _dexWalletAmount;
        emit Transfer(address(0), _teamWallet, _teamWalletAmount);
        emit Transfer(address(0), _devWallet, _devWalletAmount);
        emit Transfer(address(0), _dexWallet, _dexWalletAmount);
        emit Transfer(address(0), msg.sender, _balances[msg.sender]);
        _isExcludedFromFee[_teamWallet] = true;
        _isExcludedFromFee[_devWallet] = true;
        _isExcludedFromFee[_dexWallet] = true;
        _isExcludedFromAutoCompounding[address(this)] = true;
        _isExcludedFromAutoCompounding[msg.sender] = true;
    }

    function totalSupply() public pure override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool)
    {
        // Check if the recipient address is not zero address
        require(recipient != address(0), "BEP20: transfer to the zero address");

        // Check if the sender has enough balance
        require(_balances[msg.sender] >= amount, "BEP20: transfer amount exceeds balance");

        // Calculate the auto-compounding reward amount
        uint256 autoCompoundingAmount = calculateAutoCompoundingAmount(msg.sender);

        // Calculate the burn amount
        uint256 burnAmount = calculateBurnAmount(amount);

        // Update the balances
        _balances[msg.sender] -= amount;
        _balances[recipient] += amount - autoCompoundingAmount - burnAmount;
        _balances[address(this)] += autoCompoundingAmount;
        _totalBurnt += burnAmount;
        _totalDistributed += autoCompoundingAmount;

        // Update the last transaction timestamp
        _lastTransaction[msg.sender] = block.timestamp;

        // Emit Transfer event
        emit Transfer(msg.sender, recipient, amount - autoCompoundingAmount - burnAmount);

        // If the recipient address is excluded from auto-compounding, do not add the reward amount to auto-compounding balance
        if (!_isExcludedFromAutoCompounding[recipient]) {
            _autoCompoundingBalance += autoCompoundingAmount;
        }

        // If the sender address is excluded from fee, do not deduct the fee from the transaction amount
        if (!_isExcludedFromFee[msg.sender]) {
            uint256 feeAmount = amount * 5 / 1000; //0.5% fee
            _balances[address(this)] += feeAmount;
            emit Transfer(msg.sender, address(this), feeAmount);
        }

        // If the transaction counter reaches 100, trigger the monthly auto-burn function
        _transactionCounter++;
        if (_transactionCounter == 100) {
            autoBurn();
            _transactionCounter = 0;
        }

        // If the sender has traded a lot, trigger the trading volume airdrop function
        if (amount >= 1000 * 10**decimals) {
            tradingVolumeAirdrop(msg.sender, amount);
        }

        return true;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        require(_allowances[sender][msg.sender] >= amount, "BEP20: transfer amount exceeds allowance");

        _allowances[sender][msg.sender] -= amount;
        transfer(recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    // Calculate the auto-compounding reward amount for the specified address
    function calculateAutoCompoundingAmount(address account) private view returns (uint256) {
        if (_balances[account] < 500 * 10**decimals || _isExcludedFromAutoCompounding[account]) {
            return 0;
        }
        uint256 timeSinceLastTransaction = block.timestamp - _lastTransaction[account];
        uint256 autoCompoundingAmount = (_balances[account] * timeSinceLastTransaction * 5) / (365 * 24 * 60 * 60); //5% APR
        if (_autoCompoundingBalance < _totalDistributed / 2) {
            return autoCompoundingAmount;
        } else {
            return autoCompoundingAmount / 2;
        }
    }

        // Trigger the monthly auto-burn function
    function autoBurn() private {
        uint256 burnAmount = _totalSupply * 1 / 1000; //0.1% of total supply
        _balances[address(this)] += burnAmount;
        _totalBurnt += burnAmount;
        emit Transfer(address(0), address(this), burnAmount);
    }

    // Trigger the trading volume airdrop function
    function tradingVolumeAirdrop(address account, uint256 amount) private {
        uint256 airdropAmount = amount * 1 / 100; //1% of transaction amount
        _balances[account] += airdropAmount;
        _balances[address(this)] -= airdropAmount;
        emit Transfer(address(this), account, airdropAmount);
    }

    // Calculate the burn amount for the specified transfer amount
    function calculateBurnAmount(uint256 amount) private view returns (uint256) {
        uint256 burnAmount = amount * 1 / 1000; //0.1% of transfer amount
        if (_totalBurnt + burnAmount > _totalSupply / 2) {
            return 0;
        } else {
            return burnAmount;
        }
    }

    // Add the specified address to the excluded list for auto-compounding or fee
    function excludeFrom(address account, string memory list) public {
        require(msg.sender == _teamWallet, "BEP20: only the team wallet can perform this action");
        if (keccak256(bytes(list)) == keccak256(bytes("fee"))) {
            _isExcludedFromFee[account] = true;
        } else if (keccak256(bytes(list)) == keccak256(bytes("autocompounding"))) {
            _isExcludedFromAutoCompounding[account] = true;
        }
    }

        // Remove the specified address from the excluded list for auto-compounding or fee
    function includeIn(address account, string memory list) public {
        require(msg.sender == _teamWallet, "BEP20: only the team wallet can perform this action");
        if (keccak256(bytes(list)) == keccak256(bytes("fee"))) {
            _isExcludedFromFee[account] = false;
        } else if (keccak256(bytes(list)) == keccak256(bytes("autocompounding"))) {
            _isExcludedFromAutoCompounding[account] = false;
            // Add the auto-compounding reward to the current balance
            uint256 autoCompoundingAmount = calculateAutoCompoundingAmount(account);
            _balances[account] += autoCompoundingAmount;
            _balances[address(this)] -= autoCompoundingAmount;
            emit Transfer(address(this), account, autoCompoundingAmount);
        }
    }
}