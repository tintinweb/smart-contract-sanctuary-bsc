/**
 *Submitted for verification at BscScan.com on 2022-02-15
*/

/*

    Copyright 2020 Charity Token.
    SPDX-License-Identifier: Apache-2.0

*/

pragma solidity 0.8.11;
pragma experimental ABIEncoderV2;


/**
 * @title SafeMath
 * @author Charity Token
 *
 * @notice Math operations with safety checks that revert on error
 */
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "MUL_ERROR");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "DIVIDING_ERROR");
        return a / b;
    }

    function divCeil(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 quotient = div(a, b);
        uint256 remainder = a - quotient * b;
        if (remainder > 0) {
            return quotient + 1;
        } else {
            return quotient;
        }
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SUB_ERROR");
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "ADD_ERROR");
        return c;
    }

    function sqrt(uint256 x) internal pure returns (uint256 y) {
        uint256 z = x / 2 + 1;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }
}

/**
 * @title Ownable
 * @author Charity Token
 *
 * @notice Ownership related functions
 */
contract InitializableOwnable {
    address public _OWNER_;
    address public _NEW_OWNER_;
    bool internal _INITIALIZED_;

    // ============ Events ============

    event OwnershipTransferPrepared(address indexed previousOwner, address indexed newOwner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    // ============ Modifiers ============

    modifier notInitialized() {
        require(!_INITIALIZED_, "CTY_INITIALIZED");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == _OWNER_, "NOT_OWNER");
        _;
    }

    // ============ Functions ============

    function initOwner(address newOwner) public notInitialized {
        _INITIALIZED_ = true;
        _OWNER_ = newOwner;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        emit OwnershipTransferPrepared(_OWNER_, newOwner);
        _NEW_OWNER_ = newOwner;
    }

    function claimOwnership() public {
        require(msg.sender == _NEW_OWNER_, "INVALID_CLAIM");
        emit OwnershipTransferred(_OWNER_, _NEW_OWNER_);
        _OWNER_ = _NEW_OWNER_;
        _NEW_OWNER_ = address(0);
    }
}

// File: contracts/external/ERC20/CustomERC20.sol


contract CharityToken is InitializableOwnable {
    using SafeMath for uint256;

    string public name;
    uint8 public decimals;
    string public symbol;
    uint256 public totalSupply;

    uint256 public tradeBurnRatio = 5;
    uint256 public tradeFeeRatio = 10;
    address public charity;

    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) internal allowed;

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);
    event Burn(address indexed user, uint256 value);

    event ChangeCharity(address oldCharity, address newCharity);


    function init(
        address _creator,
        uint256 _initSupply,
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        address _charity
    ) public {
        initOwner(_creator);
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _initSupply;
        balances[_creator] = _initSupply;
        charity = _charity;
        emit Transfer(address(0), _creator, _initSupply);
    }

    function transfer(address to, uint256 amount) public returns (bool) {
        _transfer(msg.sender,to,amount);
        return true;
    }

    function balanceOf(address owner) public view returns (uint256 balance) {
        return balances[owner];
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public returns (bool) {
        require(amount <= allowed[from][msg.sender], "ALLOWANCE_NOT_ENOUGH");
        _transfer(from,to,amount);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(amount);
        return true;
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        allowed[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return allowed[owner][spender];
    }


    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(balances[sender] >= amount, "ERC20: transfer amount exceeds balance");

        balances[sender] = balances[sender].sub(amount);

        uint256 burnAmount;
        uint256 feeAmount;

        burnAmount = amount.mul(tradeBurnRatio).div(10000);
        balances[address(0)] = balances[address(0)].add(burnAmount);

        feeAmount = amount.mul(tradeFeeRatio).div(10000);
        balances[charity] = balances[charity].add(feeAmount);

        balances[recipient] = balances[recipient].add(amount.sub(burnAmount).sub(feeAmount));

        emit Transfer(sender, recipient, amount);
    }

    function burn(uint256 value) external {
        require(balances[msg.sender] >= value, "VALUE_NOT_ENOUGH");

        balances[msg.sender] = balances[msg.sender].sub(value);
        totalSupply = totalSupply.sub(value);
        emit Burn(msg.sender, value);
        emit Transfer(msg.sender, address(0), value);
    }

    function changeCharityAccount(address newCharity) external onlyOwner {
        emit ChangeCharity(charity,newCharity);
        charity = newCharity;
    }
}