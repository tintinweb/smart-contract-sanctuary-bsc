/**
 *Submitted for verification at BscScan.com on 2022-10-07
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;


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
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
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
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

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

contract Owner {

    address private owner;
    
    event OwnerSet(address indexed oldOwner, address indexed newOwner);
    
    modifier isOwner() {
        require(msg.sender == owner, "Caller is not owner");
        _;
    }
    
    constructor(address _owner) {
        owner = _owner;
        emit OwnerSet(address(0), owner);
    }

    function changeOwner(address newOwner) public isOwner {
        emit OwnerSet(owner, newOwner);
        owner = newOwner;
    }

    function getOwner() public view returns (address) {
        return owner;
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
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}


interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
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


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
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
        _mint(msg.sender, 10000000 * 10 ** 18);
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
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
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

contract Stakes is Owner, ReentrancyGuard {

    using SafeMath for uint256;

    // token    
    ERC20 public asset;

    // stakes history
    struct Record {
        uint256 from;
        uint256 amount;
        uint256 gain;
        uint256 penalization;
        uint256 to;
        bool ended;
    }

    struct ledgerParams {
        uint256 interest_rate;
        uint256 maturity;
        uint8 penalization;
        uint256 lower_amount;
    }

    // contract parameters
    ledgerParams ledgerFor3DaysParams;
    ledgerParams ledgerFor7DaysParams;
    ledgerParams ledgerFor14DaysParams;
    ledgerParams ledgerFor30DaysParams;

    mapping(address => Record[]) ledgerFor3Days; //Type 1
    mapping(address => Record[]) ledgerFor7Days; //Type 2
    mapping(address => Record[]) ledgerFor14Days; //Type 3
    mapping(address => Record[]) ledgerFor30Days; //Type 4

    event StakeStart(address indexed user, uint8 ledgerType, uint256 value, uint256 index);
    event StakeEnd(address indexed user, uint8 ledgerType, uint256 value, uint256 penalty, uint256 interest, uint256 index);
    
    constructor(ERC20 _erc20, address _owner) Owner(_owner) {
        asset = _erc20;

        ledgerFor3DaysParams.interest_rate = uint256(5*100).div(40);
        ledgerFor7DaysParams.interest_rate = uint256(10*100).div(40);
        ledgerFor14DaysParams.interest_rate = uint256(10*100).div(40);
        ledgerFor30DaysParams.interest_rate = uint256(15*100).div(40);

        //ledgerFor3DaysParams.maturity = 3*24*60*60;
        ledgerFor3DaysParams.maturity = 60;
        ledgerFor7DaysParams.maturity = 7*24*60*60;
        ledgerFor14DaysParams.maturity = 14*24*60*60;
        ledgerFor30DaysParams.maturity = 30*24*60*60;

        ledgerFor3DaysParams.penalization = 25;
        ledgerFor7DaysParams.penalization = 25;
        ledgerFor14DaysParams.penalization = 25;
        ledgerFor30DaysParams.penalization = 40;

        //ledgerFor3DaysParams.lower_amount = 1000 * 10 ** 18; //If you want you can turn this on, so you will have minimum token required
        //ledgerFor7DaysParams.lower_amount = 1000 * 10 ** 18;
        //ledgerFor14DaysParams.lower_amount = 1000 * 10 ** 18;
        //ledgerFor30DaysParams.lower_amount = 1000 * 10 ** 18;
    }
    
    function start(uint8 ledgertype, uint256 _value) external {

        if(ledgertype == 1){
            require(_value >= ledgerFor3DaysParams.lower_amount, "Invalid value");
            asset.transferFrom(msg.sender, address(this), _value);
            ledgerFor3Days[msg.sender].push(Record(block.timestamp, _value, 0, 0, 0, false));
            emit StakeStart(msg.sender, ledgertype, _value, ledgerFor3Days[msg.sender].length-1);
        }
        else if(ledgertype == 2){
            require(_value >= ledgerFor7DaysParams.lower_amount, "Invalid value");
            asset.transferFrom(msg.sender, address(this), _value);
            ledgerFor7Days[msg.sender].push(Record(block.timestamp, _value, 0, 0, 0, false));
            emit StakeStart(msg.sender, ledgertype, _value, ledgerFor7Days[msg.sender].length-1);
        }
        else if(ledgertype == 3){
            require(_value >= ledgerFor14DaysParams.lower_amount, "Invalid value");
            asset.transferFrom(msg.sender, address(this), _value);
            ledgerFor14Days[msg.sender].push(Record(block.timestamp, _value, 0, 0, 0, false));
            emit StakeStart(msg.sender, ledgertype, _value, ledgerFor14Days[msg.sender].length-1);
        }
        else if(ledgertype == 4){
            require(_value >= ledgerFor30DaysParams.lower_amount, "Invalid value");
            asset.transferFrom(msg.sender, address(this), _value);
            ledgerFor30Days[msg.sender].push(Record(block.timestamp, _value, 0, 0, 0, false));
            emit StakeStart(msg.sender, ledgertype, _value, ledgerFor30Days[msg.sender].length-1);
        }
    }

    function end(uint8 ledgertype, uint256 i) external nonReentrant {

        if(ledgertype == 1){//3 days staking
            require(i < ledgerFor3Days[msg.sender].length, "Invalid index");
            require(ledgerFor3Days[msg.sender][i].ended==false, "This stake is already ended.");
            
            // penalization
            if(block.timestamp.sub(ledgerFor3Days[msg.sender][i].from) < ledgerFor3DaysParams.maturity) {
                uint256 _penalization = ledgerFor3Days[msg.sender][i].amount.mul(ledgerFor3DaysParams.penalization).div(100);
                asset.transfer(msg.sender, ledgerFor3Days[msg.sender][i].amount.sub(_penalization));
                asset.transfer(getOwner(), _penalization);
                ledgerFor3Days[msg.sender][i].penalization = _penalization;
                ledgerFor3Days[msg.sender][i].to = block.timestamp;
                ledgerFor3Days[msg.sender][i].ended = true;
                emit StakeEnd(msg.sender, ledgertype, ledgerFor3Days[msg.sender][i].amount, _penalization, 0, i);
            // interest gained
            } else {
                uint256 _interest = get_gains(ledgertype, msg.sender, i);
                // check that the owner can pay interest before trying to pay
                if (asset.allowance(getOwner(), address(this)) >= _interest && asset.balanceOf(getOwner()) >= _interest) {
                    asset.transferFrom(getOwner(), msg.sender, _interest);
                } else {
                    _interest = 0;
                }
                asset.transfer(msg.sender, ledgerFor3Days[msg.sender][i].amount);
                ledgerFor3Days[msg.sender][i].gain = _interest;
                ledgerFor3Days[msg.sender][i].to = block.timestamp;
                ledgerFor3Days[msg.sender][i].ended = true;
                emit StakeEnd(msg.sender, ledgertype, ledgerFor3Days[msg.sender][i].amount, 0, _interest, i);
            }
        }else if(ledgertype == 2){//7 days staking
            require(i < ledgerFor7Days[msg.sender].length, "Invalid index");
            require(ledgerFor7Days[msg.sender][i].ended==false, "This stake is already ended.");
            
            // penalization
            if(block.timestamp.sub(ledgerFor7Days[msg.sender][i].from) < ledgerFor7DaysParams.maturity) {
                uint256 _penalization = ledgerFor7Days[msg.sender][i].amount.mul(ledgerFor7DaysParams.penalization).div(100);
                asset.transfer(msg.sender, ledgerFor7Days[msg.sender][i].amount.sub(_penalization));
                asset.transfer(getOwner(), _penalization);
                ledgerFor7Days[msg.sender][i].penalization = _penalization;
                ledgerFor7Days[msg.sender][i].to = block.timestamp;
                ledgerFor7Days[msg.sender][i].ended = true;
                emit StakeEnd(msg.sender, ledgertype, ledgerFor7Days[msg.sender][i].amount, _penalization, 0, i);
            // interest gained
            } else {
                uint256 _interest = get_gains(ledgertype, msg.sender, i);
                // check that the owner can pay interest before trying to pay
                if (asset.allowance(getOwner(), address(this)) >= _interest && asset.balanceOf(getOwner()) >= _interest) {
                    asset.transferFrom(getOwner(), msg.sender, _interest);
                } else {
                    _interest = 0;
                }
                asset.transfer(msg.sender, ledgerFor7Days[msg.sender][i].amount);
                ledgerFor7Days[msg.sender][i].gain = _interest;
                ledgerFor7Days[msg.sender][i].to = block.timestamp;
                ledgerFor7Days[msg.sender][i].ended = true;
                emit StakeEnd(msg.sender, ledgertype, ledgerFor7Days[msg.sender][i].amount, 0, _interest, i);
            }
        }else if(ledgertype == 3){//14 days staking
            require(i < ledgerFor14Days[msg.sender].length, "Invalid index");
            require(ledgerFor14Days[msg.sender][i].ended==false, "This stake is already ended.");
            
            // penalization
            if(block.timestamp.sub(ledgerFor14Days[msg.sender][i].from) < ledgerFor14DaysParams.maturity) {
                uint256 _penalization = ledgerFor14Days[msg.sender][i].amount.mul(ledgerFor14DaysParams.penalization).div(100);
                asset.transfer(msg.sender, ledgerFor14Days[msg.sender][i].amount.sub(_penalization));
                asset.transfer(getOwner(), _penalization);
                ledgerFor14Days[msg.sender][i].penalization = _penalization;
                ledgerFor14Days[msg.sender][i].to = block.timestamp;
                ledgerFor14Days[msg.sender][i].ended = true;
                emit StakeEnd(msg.sender, ledgertype, ledgerFor14Days[msg.sender][i].amount, _penalization, 0, i);
            // interest gained
            } else {
                uint256 _interest = get_gains(ledgertype, msg.sender, i);
                // check that the owner can pay interest before trying to pay
                if (asset.allowance(getOwner(), address(this)) >= _interest && asset.balanceOf(getOwner()) >= _interest) {
                    asset.transferFrom(getOwner(), msg.sender, _interest);
                } else {
                    _interest = 0;
                }
                asset.transfer(msg.sender, ledgerFor14Days[msg.sender][i].amount);
                ledgerFor14Days[msg.sender][i].gain = _interest;
                ledgerFor14Days[msg.sender][i].to = block.timestamp;
                ledgerFor14Days[msg.sender][i].ended = true;
                emit StakeEnd(msg.sender, ledgertype, ledgerFor14Days[msg.sender][i].amount, 0, _interest, i);
            }
        }else if(ledgertype == 4){//30 days staking
            require(i < ledgerFor30Days[msg.sender].length, "Invalid index");
            require(ledgerFor30Days[msg.sender][i].ended==false, "This stake is already ended.");
            
            // penalization
            if(block.timestamp.sub(ledgerFor30Days[msg.sender][i].from) < ledgerFor30DaysParams.maturity) {
                uint256 _penalization = ledgerFor30Days[msg.sender][i].amount.mul(ledgerFor30DaysParams.penalization).div(100);
                asset.transfer(msg.sender, ledgerFor30Days[msg.sender][i].amount.sub(_penalization));
                asset.transfer(getOwner(), _penalization);
                ledgerFor30Days[msg.sender][i].penalization = _penalization;
                ledgerFor30Days[msg.sender][i].to = block.timestamp;
                ledgerFor30Days[msg.sender][i].ended = true;
                emit StakeEnd(msg.sender, ledgertype, ledgerFor30Days[msg.sender][i].amount, _penalization, 0, i);
            // interest gained
            } else {
                uint256 _interest = get_gains(ledgertype, msg.sender, i);
                // check that the owner can pay interest before trying to pay
                if (asset.allowance(getOwner(), address(this)) >= _interest && asset.balanceOf(getOwner()) >= _interest) {
                    asset.transferFrom(getOwner(), msg.sender, _interest);
                } else {
                    _interest = 0;
                }
                asset.transfer(msg.sender, ledgerFor30Days[msg.sender][i].amount);
                ledgerFor30Days[msg.sender][i].gain = _interest;
                ledgerFor30Days[msg.sender][i].to = block.timestamp;
                ledgerFor30Days[msg.sender][i].ended = true;
                emit StakeEnd(msg.sender, ledgertype, ledgerFor30Days[msg.sender][i].amount, 0, _interest, i);
            }
        }
    }

    function setParams(uint8 ledgertype, uint256 _lower, uint256 _maturity, uint8 _rate, uint8 _penalization) public isOwner {
        if(ledgertype == 1){
            require(_penalization<=100, "Invalid value");
            ledgerFor3DaysParams.lower_amount = _lower;
            ledgerFor3DaysParams.maturity = _maturity;
            ledgerFor3DaysParams.interest_rate = _rate;
            ledgerFor3DaysParams.penalization = _penalization;
        }else if(ledgertype == 2){
            require(_penalization<=100, "Invalid value");
            ledgerFor7DaysParams.lower_amount = _lower;
            ledgerFor7DaysParams.maturity = _maturity;
            ledgerFor7DaysParams.interest_rate = _rate;
            ledgerFor7DaysParams.penalization = _penalization;
        }else if(ledgertype == 3){
            require(_penalization<=100, "Invalid value");
            ledgerFor14DaysParams.lower_amount = _lower;
            ledgerFor14DaysParams.maturity = _maturity;
            ledgerFor14DaysParams.interest_rate = _rate;
            ledgerFor14DaysParams.penalization = _penalization;
        }else if(ledgertype == 4){
            require(_penalization<=100, "Invalid value");
            ledgerFor30DaysParams.lower_amount = _lower;
            ledgerFor30DaysParams.maturity = _maturity;
            ledgerFor30DaysParams.interest_rate = _rate;
            ledgerFor30DaysParams.penalization = _penalization;
        }
    }
    
    // calculate interest to the current date time
    function get_gains(uint8 ledgertype, address _address, uint256 _rec_number) public view returns (uint256 gains) {
        uint256 _record_seconds;
        uint256 _days = 1;
        uint256 _year_seconds = _days*24*60*60;

        if(ledgertype == 1){
            _record_seconds = block.timestamp.sub(ledgerFor3Days[_address][_rec_number].from);
            return _record_seconds.mul(
                ledgerFor3Days[_address][_rec_number].amount.mul(ledgerFor3DaysParams.interest_rate).div(100)
            ).div(_year_seconds);
        }else if(ledgertype == 2){
            _record_seconds = block.timestamp.sub(ledgerFor7Days[_address][_rec_number].from);
            return _record_seconds.mul(
                ledgerFor7Days[_address][_rec_number].amount.mul(ledgerFor7DaysParams.interest_rate).div(100)
            ).div(_year_seconds);
        }else if(ledgertype == 3){
            _record_seconds = block.timestamp.sub(ledgerFor14Days[_address][_rec_number].from);
            return _record_seconds.mul(
                ledgerFor14Days[_address][_rec_number].amount.mul(ledgerFor14DaysParams.interest_rate).div(100)
            ).div(_year_seconds);
        }else if(ledgertype == 4){
            _record_seconds = block.timestamp.sub(ledgerFor30Days[_address][_rec_number].from);
            return _record_seconds.mul(
                ledgerFor30Days[_address][_rec_number].amount.mul(ledgerFor30DaysParams.interest_rate).div(100)
            ).div(_year_seconds);
        }
    }

    function ledger_length(uint8 ledgertype, address _address) public view returns (uint256 ledgerlength) {
        if(ledgertype == 1){
            return ledgerFor3Days[_address].length;
        }else if(ledgertype == 2){
            return ledgerFor7Days[_address].length;
        }else if(ledgertype == 3){
            return ledgerFor14Days[_address].length;
        }else if(ledgertype == 4){
            return ledgerFor30Days[_address].length;
        }
    }

}