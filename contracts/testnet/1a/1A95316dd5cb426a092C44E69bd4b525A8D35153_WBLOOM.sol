/**
 *Submitted for verification at BscScan.com on 2022-03-09
*/

// File: contracts/libs/Auth.sol

pragma solidity ^0.8.0;
abstract contract Auth {
    address internal owner;
    mapping (address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    /**
     * Function modifier to require caller to be contract owner
     */
    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    /**
     * Function modifier to require caller to be authorized
     */
    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
    }

    /**
     * Authorize address. Owner only
     */
    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    /**
     * Remove address' authorization. Owner only
     */
    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }

    /**
     * Check if address is owner
     */
    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    /**
     * Return address' authorization status
     */
    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    /**
     * Transfer ownership to new address. Caller must be owner. Leaves old owner authorized
     */
    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}

// File: contracts/libs/Safemath.sol

pragma solidity ^0.8.0;

/**
 * SAFEMATH LIBRARY
 */
library SafeMath {
    
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

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

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

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

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}
// File: contracts/libs/ITOKEN2.sol


pragma solidity ^0.8.0;
interface ITOKEN2 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function setIsFeeExempt(address holder, bool exempt) external;
    function wrap(address sender, address recipient, uint256 amount) external returns (bool);
    function unwrap(address sender, address recipient, uint256 amount) external returns (bool);
    function setIsDividendExempt(address holder, bool exempt) external;
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: contracts/libs/iToken.sol


pragma solidity ^0.8.0;
interface ITOKEN {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function setIsFeeExempt(address holder, bool exempt) external;
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: contracts/WrappedBloom.sol

/*
::::::::::TODOS:::::::::::::::
 1-> Add an externally accessible mint function for authorized address(es)
 2-> Check every function and whole contract for vulnerability or bug
 3-> Before live deployment, exempt this contract address from fees in the main bloom contract
 4-> The mininum period variable is for the 24hours period declaration. Set it to 86400(24hours) for live deployment
*/
//SPDX-License-Identifier: MIT
pragma solidity 0.8 .11;





contract WBLOOM is ITOKEN, Auth {
    using SafeMath
    for uint256;

    address public bloomAddress = 0x6AE21FC9581c3278bbBC3E24C9A4b6FA8c6E792b;
    ITOKEN2 bloom = ITOKEN2(bloomAddress);
    string _name = "Wrapped Bloom";
    string _symbol = "WBLOOM";
    uint8 _decimals = 6;
    uint256 _totalSupply;
    address _owner;
    address _token;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;

    //record user deposits
    mapping(address => uint256) public deposits;
    //check if first deposit
    mapping(address => uint256) public isFirstDeposit;
    //last deposit Time
    mapping(address => uint256) public lastDepositTime;
    //24hour toggle
    mapping(address => bool) _24HourCycle;
    //store 24hour balance
    mapping(address => uint256) public _24hourBalance;
    //toggle early withdrawal tax
    bool tToggle = true;
    //minimum unwrap period
    uint256 public minPeriod = 30;
    //tax for early unwrap
    uint256 public perce = 30;
    uint256 public perceDen = 100;
    //tax address
    address public tAddress = 0xd86aC952724Cb84143B45c7dBf3e3144B65541CC;

    constructor() Auth(msg.sender) {
        _token = address(this);
        bloom.approve(address(this), 100000 * 10 ** bloom.decimals());
    }

    function name() external view returns(string memory) {
        return _name;
    }


    function symbol() external view override returns(string memory) {
        return _symbol;
    }

    function decimals() external view returns(uint8) {
        return _decimals;
    }

    function totalSupply() external view override returns(uint256) {
        return _totalSupply;
    }

    function balanceOf(address _address) external view returns(uint256) {
        return _balances[_address];
    }

    function allowance(address _holder, address _spender) external view returns(uint256) {
        return _allowances[_holder][_spender];
    }

    function getOwner() external view returns(address) {
        return _owner;
    }

    function approve(address _spender, uint256 _amount) external returns(bool) {
        require(_balances[msg.sender] >= _amount, "Insufficient balance");
        _allowances[msg.sender][_spender] = _allowances[msg.sender][_spender].add(_amount);
        return true;
    }

    function transfer(address _receiver, uint256 _amount) external returns(bool) {
        return _transfer(msg.sender, _receiver, _amount);
    }

    function transferFrom(address _sender, address _receiver, uint256 _amount) external returns(bool) {
        _allowances[_sender][msg.sender] = _allowances[_sender][msg.sender].sub(_amount, "Insufficient allowance");
        return _transfer(_sender, _receiver, _amount);
    }

    function _transfer(address owner_, address _receiver, uint256 _amount) internal returns(bool) {
        _balances[owner_] = _balances[owner_].sub(_amount, "Insufficient balance");
        _balances[_receiver] = _balances[_receiver].add(_amount);
        return true;
    }

    function _mint(address _address, uint256 _amount) internal returns(bool) {
        _balances[_address] += _amount;
        _totalSupply = _totalSupply.add(_amount);
        emit Transfer(address(0), _address, _amount);
        return true;
    }

    function _burn(uint256 _amount) internal returns(bool) {
        _balances[msg.sender] = _balances[msg.sender].sub(_amount, "Insufficient balance");
        _totalSupply = _totalSupply.sub(_amount);
        emit Transfer(_owner, address(0), _amount);
        return true;
    }


    function _burnFrom(uint256 _amount) internal returns(bool) {
        _totalSupply = _totalSupply.sub(_amount);
        emit Transfer(msg.sender, address(0), _amount);
        return true;
    }

    function wrap(uint256 _amount) external returns(bool) {

        require(bloom.balanceOf(msg.sender) >= _amount, "Insufficient Bloom balance");

        require(bloom.allowance(msg.sender, address(this)) >= _amount, "Insufficient allowance!");

        bloom.setIsFeeExempt(msg.sender, true);

        bloom.setIsDividendExempt(msg.sender, true);

        bloom.transferFrom(msg.sender, address(this), _amount * 10 ** bloom.decimals());

        dailyBalanceManager(_amount);

        bloom.setIsDividendExempt(msg.sender, false);

        bloom.setIsFeeExempt(msg.sender, false);

        return _mint(msg.sender, _amount * 10 ** _decimals);
    }

    function unwrap(uint256 _amount) external returns(bool) {

        uint256 amountReceived;

        _balances[msg.sender].sub(_amount, "Insufficient Wrapped Bloom balance");

        if (_amount > _24hourBalance[msg.sender] || _24hourBalance[msg.sender] == 0) {
            amountReceived = tToggle ? checkSendAmount(tToggle, _amount) : _amount;
            _24hourBalance[msg.sender] = 0;
        } else {
            amountReceived =  _amount;
            _24hourBalance[msg.sender] -= _amount;
        }

        dailyBalanceManagerUnwrap();

        bloom.transferFrom(address(this), msg.sender, amountReceived * 10 ** bloom.decimals());

        return _burn(amountReceived * 10 ** _decimals);
    }

    function dailyBalanceManager(uint256 _amount) internal {
        //record every wrap(deposit) by an address
        deposits[msg.sender] += _amount;

        //check if it's their first deposit or if the first deposit has been reset
        if (isFirstDeposit[msg.sender] == 0) {

            //if it's the first wrap, change value to 1
            isFirstDeposit[msg.sender] = 1;

            //store last deposit time as the time of the first transaction
            lastDepositTime[msg.sender] = block.timestamp;

            //toggle 24 hour cycle indicator to false
            /* this variable is used to indicate if a 24 hour cycle has been reached
            This is done by checking if the difference between current timestamp and 
            last deposit time is above mininum period(eg 24hours) */
            _24HourCycle[msg.sender] = false;
        }
        
        //check if the difference between current timestamp and 
        //last deposit time is above mininum period(eg 24hours)
        if (block.timestamp - lastDepositTime[msg.sender] > minPeriod) {
            _24HourCycle[msg.sender] = true;
            lastDepositTime[msg.sender] = block.timestamp;
        }

        if (_24HourCycle[msg.sender] == true) {
            _24hourBalance[msg.sender] += deposits[msg.sender] - _amount;
            deposits[msg.sender] = _amount;
            _24HourCycle[msg.sender] = false;
            lastDepositTime[msg.sender] = block.timestamp;
        }

    }

    function dailyBalanceManagerUnwrap() internal {

         //check if the difference between current timestamp and 
        //deposit time is above mininum period(eg 24hours)
        if (block.timestamp - lastDepositTime[msg.sender] > minPeriod) {
            //toggle 24hour cycle variable on
            _24HourCycle[msg.sender] = true;
            //change last dep
            lastDepositTime[msg.sender] = block.timestamp;
        }
        
        //if 24hour cycle is true
        //reset daily balance variables
        if (_24HourCycle[msg.sender] == true) {
            _24hourBalance[msg.sender] += deposits[msg.sender];
            deposits[msg.sender] = 0;
            _24HourCycle[msg.sender] = false;
            lastDepositTime[msg.sender] = 0;
            isFirstDeposit[msg.sender] = 0;
        }
    }

    function checkSendAmount(bool _chargeTax, uint256 _amount) internal returns(uint256) {
        uint256 taxAmount = perce;
        uint256 taxAmountDen = perceDen;
        if (_chargeTax) {
            uint256 _taxedAmount = _amount.mul(taxAmount).div(taxAmountDen);
            uint256 _amountToSend = _amount.sub(_taxedAmount);
            _transfer(msg.sender, address(this), _taxedAmount*10**_decimals);
            _transfer(address(this), tAddress, _taxedAmount*10**_decimals);
            return _amountToSend;
        } else {
            uint256 _amountToSend = _amount;
            return _amountToSend;
        }
    }

    function manageSettings(bool _tToggle, uint256 _minPeriod, uint256 _perce, uint256 _perceDen, address _tAddress) external authorized {
        //toggle early withdrawal tax
        tToggle = _tToggle;
        //minimum unwrap period
        minPeriod = _minPeriod;
        //tax for early unwrap
        perce = _perce;
        perceDen = _perceDen;
        //tax address
        tAddress = _tAddress;
    }

    function setIsFeeExempt(address holder, bool exempt) external {}

    event LogBurn(uint256 _amount);

}