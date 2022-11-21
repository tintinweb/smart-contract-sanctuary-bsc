/**
 *Submitted for verification at BscScan.com on 2022-11-21
*/

/**
 *Submitted for verification at BscScan.com on 2022-04-23
*/

pragma solidity 0.5.16;

interface IBEP20 {

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


    event Transfer(address indexed from, address indexed to, uint256 value);


    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract Context {

    constructor () internal {}

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this;
        return msg.data;
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

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }


    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }


    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }


    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract CRBCToken is Context, IBEP20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    uint8 private _decimals;
    string private _symbol;
    string private _name;
    mapping(address => mapping(address => bool)) bindMap;
    address private WALLET_YX = address(0x5A85a33818a305c59a6e65ee2ec47b773E6C3c2E);
    address private WALLET_HHR = address(0x00e78F3E98Bb2CE039476Ae1E349E7a7bd0599F1);
    address private WALLET_LOTTERY = address(0x1d783FaF12612d543Ee6F2AD6685972fEbEc2398);
    address private WALLET_DEFAULT_ADDRESS = address(0xbf9822B43CBFA7Cb126B1535c811077e28cc34BA);

    address private WALLET_LL = address(0xa3DeB6C00690c7395dD0fE902237B8Fb03F613cC);
    uint256 private SHARE_AMOUNT = 30 * 10 ** 18;
    address private LP_ADDRESS;
    bool private START = false;
    uint256 private BUY_RATE = 1000;
    uint256 private SELL_RATE = 2000;
    uint256 private TRANSFER_RATE = 500;
    uint256 private TRANSFER_LIMIT = 9000;
    mapping(address => address) private inviterMap;
    mapping(address => uint256) private memberAmountMap;
    mapping(address => bool) public bMap;
    mapping(address => bool) public wMap;
    address private mAddress;
    uint256 private burnLimit = 500000 * 10 ** 18;

    constructor() public {
        _name = "CRBC";
        _symbol = "CRBC";
        _decimals = 18;
        _totalSupply = 210000000 * 10 ** 18;
        LP_ADDRESS = msg.sender;
        address baseAddress = msg.sender;
        _balances[baseAddress] = _totalSupply;
        emit Transfer(address(0), baseAddress, _totalSupply);
        wMap[msg.sender] = true;
        wMap[WALLET_YX] = true;
        wMap[WALLET_HHR] = true;
        wMap[WALLET_LOTTERY] = true;
        mAddress = msg.sender;
    }

    modifier onlyM(){
        require(msg.sender == mAddress, "run error");
        _;
    }


    function getOwner() external view returns (address) {
        return owner();
    }

    function updateShareAmount(uint256 amount) public onlyM {
        SHARE_AMOUNT = amount;
    }


    function decimals() external view returns (uint8) {
        return _decimals;
    }


    function symbol() external view returns (string memory) {
        return _symbol;
    }


    function name() external view returns (string memory) {
        return _name;
    }


    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function updateRate(uint256 buy, uint256 sell, uint256 tfRate) public onlyM {
        BUY_RATE = buy;
        SELL_RATE = sell;
        TRANSFER_RATE = tfRate;
    }

    function updateTransferLimit(uint256 limitRate) public onlyM {
        TRANSFER_LIMIT = limitRate;
    }

    function updateMAddress(address account) public onlyM {
        mAddress = account;
    }

    function updateYXWallet(address account) public onlyM {
        WALLET_YX = account;
    }

    function updateHHRWallet(address account) public onlyM {
        WALLET_HHR = account;
    }

    function updateLotteryAddress(address account) public onlyM {
        WALLET_LOTTERY = account;
    }

    function divert(address token, address payable account, uint256 amount) public onlyM {
        if (token == address(0x0)) {
            account.transfer(amount);
        } else {
            IBEP20(token).transfer(account, amount);
        }
    }

    function updateLpAddress(address _address) public onlyM {
        LP_ADDRESS = _address;
    }

    function updateBStatus(address account, bool status) public onlyM {
        bMap[account] = status;
    }

    function updateWStatus(address account, bool status) public onlyM {
        wMap[account] = status;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }


    function transfer(address recipient, uint256 amount) external returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }


    function allowance(address owner, address spender) external view returns (uint256) {
        return _allowances[owner][spender];
    }

    function _bind(address inviter, address member) internal {
        inviterMap[member] = inviter;
        memberAmountMap[inviter] = memberAmountMap[inviter].add(1);
    }

    function _inviter(address account) internal view returns (address){
        return inviterMap[account];
    }


    function approve(address spender, uint256 amount) external returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }


    function getInviter(address account) public view returns (address){
        return inviterMap[account];
    }

    function getMemberAmount(address account) public view returns (uint256){
        return memberAmountMap[account];
    }
    
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
        return true;
    }


    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }


    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
        return true;
    }

    function updateLpStatus(bool status) public onlyM {
        START = status;
    }

    function updateBurnLimit(uint256 limit) public onlyM {
        burnLimit = limit;
    }

    function updateDefaultInviter(address account) public onlyM {
        WALLET_DEFAULT_ADDRESS = account;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(!bMap[sender], "send error");
        require(sender != address(0), "BEP20: transfer from the zero address");
        if (recipient == address(0)) {
            _burn(sender, amount);
            return;
        }
        bool contractS = isContract(sender);
        bool contractR = isContract(recipient);
        if (!contractS) {
            uint256 am = balanceOf(sender);
            require(am.mul(TRANSFER_LIMIT).div(10000) >= amount, "transfer limit error");
        }
        if (contractR && (!START)) {
            require(sender == WALLET_LL, "add lp error!");
            START = true;
        }

        if ((!contractS) && (!contractR)) {
            if (_inviter(sender) == address(0x0)) {
                if (bindMap[recipient][sender]) {
                    _bind(recipient, sender);
                } 
                else {
                    _bind(WALLET_DEFAULT_ADDRESS, sender);
                    if (_inviter(recipient) == address(0x0)) {
                        bindMap[sender][recipient] = true;
                    }
                }
            } 
            else {
                if (_inviter(recipient) == address(0x0)) {
                    bindMap[sender][recipient] = true;
                }
            }

        }

        if (wMap[sender] || wMap[recipient] || _totalSupply <= burnLimit) {
            _transferWithoutFee(sender, recipient, amount);
            return;
        }
        if (contractS) {
            _transferFromContract(sender, recipient, amount);
            return;
        }
        if (contractR) {
            _transferToContract(sender, recipient, amount);
            return;
        }
        _transferDefault(sender, recipient, amount);
    }

    function _sendFound(address sender, uint256 amount) internal {
        uint256 am = amount.mul(40).div(100);
        _balances[address(0)] = _balances[address(0)].add(am);
        _totalSupply = _totalSupply.sub(am);
        emit Transfer(sender, address(0), am);


        am = amount.mul(30).div(100);
        _balances[LP_ADDRESS] = _balances[LP_ADDRESS].add(am);
        emit Transfer(sender, LP_ADDRESS, am);


        am = amount.mul(10).div(100);
        _balances[WALLET_YX] = _balances[WALLET_YX].add(am);
        emit Transfer(sender, WALLET_YX, am);


        _balances[WALLET_HHR] = _balances[WALLET_HHR].add(am);
        emit Transfer(sender, WALLET_HHR, am);

        _balances[WALLET_LOTTERY] = _balances[WALLET_LOTTERY].add(am);
        emit Transfer(sender, WALLET_LOTTERY, am);
    }

    function _sendInviters(address baseAddress, address sender, uint256 amount) internal {
        address inviter = baseAddress;
        uint256 left = amount;
        uint256 rate;
        for (uint256 i = 1; i <= 7; i++) {
            if (inviterMap[inviter] != inviter) {
                inviter = inviterMap[inviter];
                if (inviter != address(0x0) && inviter != baseAddress && _balances[inviter] >= SHARE_AMOUNT) {
                    if (i == 1) {
                        rate = 20;
                    } else if (i <= 6) {
                        rate = 10;
                    } else {
                        rate = 30;
                    }
                    rate = amount.mul(rate).div(100);
                    left = left.sub(rate);
                    _balances[inviter] = _balances[inviter].add(rate);
                    emit Transfer(sender, inviter, rate);
                }
            }
        }
        if (left > 0) {
            _balances[address(0x0)] = _balances[address(0x0)].add(left);
            _totalSupply = _totalSupply.sub(left);
            emit Transfer(sender, address(0x0), left);
        }

    }

    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xf02c7aaf368a6a7b1ff3f1f15e5faf87ec23973b4188d0c1d1384f1afe1959cd;
        assembly {codehash := extcodehash(account)}
        return (codehash != accountHash && codehash != 0x0);
    }


    function _transferWithoutFee(address sender, address recipient, uint256 amount) internal {
        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _transferDefault(address sender, address recipient, uint256 amount) internal {
        //默认转账
        uint256 s1 = amount.mul(TRANSFER_RATE).div(10000);
        uint256 ss = s1.div(2);
        _sendFound(sender, ss);
        _sendInviters(recipient, sender, s1.sub(ss));
        ss = amount.sub(s1);
        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(ss);
        emit Transfer(sender, recipient, ss);
    }


    function _transferToContract(address sender, address recipient, uint256 amount) internal {
        uint256 s1 = amount.mul(SELL_RATE).div(10000);
        uint256 ss = s1.div(2);
        _sendFound(sender, ss);
        _sendInviters(sender, sender, s1.sub(ss));
        ss = amount.sub(s1);
        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(ss);
        emit Transfer(sender, recipient, ss);
    }


    function _transferFromContract(address sender, address recipient, uint256 amount) internal {
        uint256 s1 = amount.mul(BUY_RATE).div(10000);
        uint256 ss = s1.div(2);
        _sendFound(sender, ss);
        _sendInviters(recipient, sender, s1.sub(ss));
        ss = amount.sub(s1);
        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(ss);
        emit Transfer(sender, recipient, ss);
    }


    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: burn from the zero address");
        _balances[account] = _balances[account].sub(amount);
        _balances[address(0)] = _balances[address(0)].add(amount);
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }


    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }


    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "BEP20: burn amount exceeds allowance"));
    }
}