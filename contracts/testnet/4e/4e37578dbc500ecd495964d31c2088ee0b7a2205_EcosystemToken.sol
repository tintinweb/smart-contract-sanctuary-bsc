/**
 *Submitted for verification at BscScan.com on 2022-12-21
*/

/*
    SPDX-License-Identifier: Unlicensed
*/
pragma solidity 0.8.17;
pragma experimental ABIEncoderV2;

library AllSafe {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "Error.");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "Error.");
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
        require(b <= a, "Error.");
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "Error.");
        return c;
    }

    function root(uint256 x) internal pure returns (uint256 y) {
        uint256 z = x / 2 + 1;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }
}

contract Creation {
    address public _OWNER_;
    address public _NEW_OWNER_;
    bool internal _INITIALIZED_;
    event OwnershipTransferPrepared(address indexed previousOwner, address indexed newOwner);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    modifier notInitialized() {
        require(!_INITIALIZED_, "Action Triggered.");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == _OWNER_, "Invalid Wallet.");
        _;
    }

    // ============ Functions ============

    function SetOwner(address newOwner) public notInitialized {
        _INITIALIZED_ = true;
        _OWNER_ = newOwner;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        emit OwnershipTransferPrepared(_OWNER_, newOwner);
        _NEW_OWNER_ = newOwner;
    }

    function claimOwnership() public {
        require(msg.sender == _NEW_OWNER_, "Claim failed.");
        emit OwnershipTransferred(_OWNER_, _NEW_OWNER_);
        _OWNER_ = _NEW_OWNER_;
        _NEW_OWNER_ = address(0);
    }
}

contract EcosystemToken is Creation {
    using AllSafe for uint256;

    string public name;
    uint8 public decimals;
    string public symbol;
    uint256 public totalSupply;

    uint256 public tradeBurnRatio;
    uint256 public tradeFeeRatio;
    address public team;
    bool public isMintable;

    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) internal allowed;

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);
    event Mint(address indexed user, uint256 value);
    event Burn(address indexed user, uint256 value);

    event ChangeTeam(address oldTeam, address newTeam);

    function CreateEcosystemToken(
        address _creator,
        uint256 _initSupply,
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _tradeBurnRatio,
        uint256 _tradeFeeRatio,
        address _team,
        bool _isMintable
    ) public {
        SetOwner(_creator);
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _initSupply;
        balances[_creator] = _initSupply;
        require(_tradeBurnRatio >= 0 && _tradeBurnRatio <= 5000, "Please use a different number.");
        require(_tradeFeeRatio >= 0 && _tradeFeeRatio <= 5000, "Please use a different number");
        tradeBurnRatio = _tradeBurnRatio;
        tradeFeeRatio = _tradeFeeRatio;
        team = _team;
        isMintable = _isMintable;
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
        require(amount <= allowed[from][msg.sender], "First, increase allowance.");
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
        require(sender != address(0), "Transfer from the zero address.");
        require(recipient != address(0), "Transfer to the zero address.");
        require(balances[sender] >= amount, "Transfer amount exceeds balance.");

        balances[sender] = balances[sender].sub(amount);

        uint256 burnAmount;
        uint256 feeAmount;
        if(tradeBurnRatio > 0) {
            burnAmount = amount.mul(tradeBurnRatio).div(10000);
            balances[address(0)] = balances[address(0)].add(burnAmount);
        }

        if(tradeFeeRatio > 0) {
            feeAmount = amount.mul(tradeFeeRatio).div(10000);
            balances[team] = balances[team].add(feeAmount);
        }

        balances[recipient] = balances[recipient].add(amount.sub(burnAmount).sub(feeAmount));

        emit Transfer(sender, recipient, amount);
    }

    function burn(uint256 value) external {
        require(isMintable, "Unable to continue.");
        require(balances[msg.sender] >= value, "Please try again.");

        balances[msg.sender] = balances[msg.sender].sub(value);
        totalSupply = totalSupply.sub(value);
        emit Burn(msg.sender, value);
        emit Transfer(msg.sender, address(0), value);
    }

    //=================== Ownable ======================
    function mint(address user, uint256 value) external onlyOwner {
        require(isMintable, "Unable to Mint beyond established Total Supply.");
        require(user == _OWNER_, "Invalid Wallet.");
        
        balances[user] = balances[user].add(value);
        totalSupply = totalSupply.add(value);
        emit Mint(user, value);
        emit Transfer(address(0), user, value);
    }

    function changeTeamAccount(address newTeam) external onlyOwner {
        require(tradeFeeRatio > 0, "Invalid.");
        emit ChangeTeam(team,newTeam);
        team = newTeam;
    }
}