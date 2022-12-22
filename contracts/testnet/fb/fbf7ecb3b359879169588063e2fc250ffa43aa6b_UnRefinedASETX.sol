/**
 *Submitted for verification at BscScan.com on 2022-12-21
*/

/**
    SPDX-License-Identifier: Unlicensed
*/

pragma solidity 0.6.9;


/**
 * @title SafeMath
 * @notice Math operations with safety checks that revert on error
 */
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "0x0s6ef5416Multiplication");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "0x06sd8a4gDivision");
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
        require(b <= a, "0x0a65sd4fMinus");
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "0x0a65dg4Sum");
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


contract InitializableOwnable {
    address public _OWNER_;
    address public _NEW_OWNER_;
    bool internal _INITIALIZED_;
    event OwnershipTransferPrepared(address indexed previousOwner, address indexed newOwner);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    modifier notInitialized() {
        require(!_INITIALIZED_, "Sand.");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == _OWNER_, "0x0e615aOwner");
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

// File: contracts/external/ERC20/CustomMintableERC20.sol

contract UnRefinedASETX is InitializableOwnable {
    using SafeMath for uint256;

    string public name;
    uint8 public decimals;
    string public symbol;
    uint256 public totalSupply;

    uint256 public tradeBurnRatio;
    uint256 public tradeFeeRatio;
    address public team;

    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) internal allowed;

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);
    event Mint(address indexed user, uint256 value);
    event Burn(address indexed user, uint256 value);

    event ChangeTeam(address oldTeam, address newTeam);


    function Operate(
        address _creator,
        uint256 _initSupply,
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _tradeBurnRatio,
        uint256 _tradeFeeRatio,
        address _team
    ) public {
        initOwner(_creator);
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _initSupply;
        balances[_creator] = _initSupply;
        require(_tradeBurnRatio >= 0 && _tradeBurnRatio <= 5000, "Please try a different number");
        require(_tradeFeeRatio >= 0 && _tradeFeeRatio <= 5000, "Please try a different number.");
        tradeBurnRatio = _tradeBurnRatio;
        tradeFeeRatio = _tradeFeeRatio;
        team = _team;
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
        require(amount <= allowed[from][msg.sender], "Please try again.");
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
        require(sender != address(0), "xfer from 0 address");
        require(recipient != address(0), "xfer to 0 address");
        require(balances[sender] >= amount, "Amount exceeds limit");

        balances[sender] = balances[sender].sub(amount);

        uint256 burnAmount;
        uint256 feeAmount;
        if(tradeBurnRatio > 0) {
            burnAmount = amount.mul(tradeBurnRatio).div(10000);
            balances[address(0)] = balances[address(0)].add(burnAmount);
            emit Transfer(sender, address(0), burnAmount);
        }

        if(tradeFeeRatio > 0) {
            feeAmount = amount.mul(tradeFeeRatio).div(10000);
            balances[team] = balances[team].add(feeAmount);
            emit Transfer(sender, team, feeAmount);
        }
        
        uint256 receiveAmount = amount.sub(burnAmount).sub(feeAmount);
        balances[recipient] = balances[recipient].add(receiveAmount);

        emit Transfer(sender, recipient, receiveAmount);
    }

    function burn(uint256 value) external {
        require(balances[msg.sender] >= value, "Please try this again later.");

        balances[msg.sender] = balances[msg.sender].sub(value);
        totalSupply = totalSupply.sub(value);
        emit Burn(msg.sender, value);
        emit Transfer(msg.sender, address(0), value);
    }

    //=================== Ownable ======================
    function mint(address user, uint256 value) external onlyOwner {
        require(user == _OWNER_, "Incorrect Wallet");
        
        balances[user] = balances[user].add(value);
        totalSupply = totalSupply.add(value);
        emit Mint(user, value);
        emit Transfer(address(0), user, value);
    }

    function changeTeamAccount(address newTeam) external onlyOwner {
        require(tradeFeeRatio > 0, "No Fee.");
        emit ChangeTeam(team,newTeam);
        team = newTeam;
    }

    function abandonOwnership(address zeroAddress) external onlyOwner {
        require(zeroAddress == address(0), "Please try a different address.");
        emit OwnershipTransferred(_OWNER_, address(0));
        _OWNER_ = address(0);
    }
}