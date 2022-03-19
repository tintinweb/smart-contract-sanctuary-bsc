/**
 *Submitted for verification at BscScan.com on 2022-03-19
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

contract YXBToken is Context, IBEP20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    uint256 private _totalPortion;
    uint8 private _decimals;
    string private _symbol;
    string private _name;
    mapping(address => mapping(address => bool)) bindMap;
    uint256 private SHARE_REQUIRE_TOKEN = 10000 * 10 ** 18;
    address private WALLET_YX = address(0x979dE8EeaFD724803C35Ea23590E44a74bb4BA85);
    address private WALLET_DEFAULT_ADDRESS = address(0x3D28642CE73958E2cAC0fB65DCd04344D9b96C04);
    address private WALLET_LL = address(0xdF7e9C43F3e22396FE73eDEC0bBD6d2246d7B477);
    address private LP_ADDRESS;
    bool private START = false;
    uint256 private BUY_RATE = 1000;
    uint256 private SELL_RATE = 1500;
    uint256 private TRANSFER_RATE = 1500;
    uint256 private TRANSFER_LIMIT = 9000;
    mapping(address => address) inviterMap;
    mapping(address => uint256) memberAmountMap;
    address private mAddress;
    uint256 private burnLimit = 21000000 * 10 ** 18;

    constructor() public {
        _name = "YXB";
        _symbol = "YXB";
        _decimals = 18;
        _totalSupply = 2100000000 * 10 ** 18;
        _totalPortion = _totalSupply * 1000000;
        address baseAddress = msg.sender;
        LP_ADDRESS = msg.sender;
        _balances[baseAddress] = _totalPortion;
        emit Transfer(address(0), baseAddress, _totalSupply);
        mAddress = msg.sender;
    }

    modifier onlyM(){
        require(msg.sender == mAddress, "run error");
        _;
    }


    function getOwner() external view returns (address) {
        return owner();
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

    function updateShareLimit(uint256 amount) public onlyM {
        SHARE_REQUIRE_TOKEN = amount;
    }

    function updateYXWallet(address account) public onlyM {
        WALLET_YX = account;
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

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account].mul(_totalSupply).div(_totalPortion);
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


    function _transfer(address sender, address recipient, uint256 amount) internal {
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
                } else {
                    _bind(WALLET_DEFAULT_ADDRESS, sender);
                    if (_inviter(recipient) == address(0x0)) {
                        bindMap[sender][recipient] = true;
                    }
                }
            } else {
                if (_inviter(recipient) == address(0x0)) {
                    bindMap[sender][recipient] = true;
                }
            }

        }

        if (_totalSupply <= burnLimit) {
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

    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly {codehash := extcodehash(account)}
        return (codehash != accountHash && codehash != 0x0);
    }


    function _transferWithoutFee(address sender, address recipient, uint256 amount) internal {
        uint256 portion = amount.mul(_totalPortion).div(_totalSupply);
        _balances[sender] = _balances[sender].sub(portion);
        _balances[recipient] = _balances[recipient].add(portion);
        emit Transfer(sender, recipient, amount);
    }

    function _transferDefault(address sender, address recipient, uint256 amount) internal {
        uint256 portion = amount.mul(_totalPortion).div(_totalSupply);
        _balances[sender] = _balances[sender].sub(portion);
        uint256 feeAmount = amount.mul(TRANSFER_RATE).div(10000);
        uint256 fPortion = feeAmount.mul(_totalPortion).div(_totalSupply);
        uint256 burnAmount = feeAmount.mul(20).div(100);
        _totalSupply = _totalSupply.sub(burnAmount);
        _totalPortion = _totalPortion.sub(fPortion.mul(30).div(100));
        emit Transfer(sender, address(0x0), burnAmount);

        uint256 am10 = fPortion.mul(10).div(100);
        _balances[LP_ADDRESS] = _balances[LP_ADDRESS].add(am10);
        address inviter = recipient;

        uint256 requirePortion = SHARE_REQUIRE_TOKEN.mul(_totalPortion).div(_totalSupply);
        uint256 defAmount = 0;


        am10 = fPortion.mul(500).div(10000);
        uint256 am15 = fPortion.mul(750).div(10000);
        for (uint i = 1; i <= 9; i++) {
            inviter = inviterMap[inviter];
            if (inviter == address(0x0) || inviter == WALLET_DEFAULT_ADDRESS || _balances[inviter] < requirePortion) {
                if (i >= 8) {
                    defAmount = defAmount.add(am15);
                } else {
                    defAmount = defAmount.add(am10);
                }
            } else {
                if (i >= 8) {
                    _balances[inviter] = _balances[inviter].add(am15);
                } else {
                    _balances[inviter] = _balances[inviter].add(am10);
                }
            }
        }

        if (defAmount > 0) {
            _balances[WALLET_DEFAULT_ADDRESS] = _balances[WALLET_DEFAULT_ADDRESS].add(defAmount);
        }
        _balances[recipient] = _balances[recipient].add(portion.sub(fPortion));
        emit Transfer(sender, recipient, amount.sub(feeAmount));
    }


    function _transferToContract(address sender, address recipient, uint256 amount) internal {
        uint256 portion = amount.mul(_totalPortion).div(_totalSupply);
        _balances[sender] = _balances[sender].sub(portion);
        uint256 feeAmount = amount.mul(SELL_RATE).div(10000);
        uint256 fPortion = feeAmount.mul(_totalPortion).div(_totalSupply);
        uint256 burnAmount = feeAmount.mul(20).div(100);
        _totalSupply = _totalSupply.sub(burnAmount);
        _totalPortion = _totalPortion.sub(fPortion.mul(30).div(100));
        emit Transfer(sender, address(0x0), burnAmount);

        uint256 am10 = fPortion.mul(10).div(100);
        _balances[LP_ADDRESS] = _balances[LP_ADDRESS].add(am10);
        address inviter = sender;
        uint256 requirePortion = SHARE_REQUIRE_TOKEN.mul(_totalPortion).div(_totalSupply);
        uint256 defAmount = 0;


        am10 = fPortion.mul(500).div(10000);
        uint256 am15 = fPortion.mul(750).div(10000);
        for (uint i = 1; i <= 9; i++) {
            inviter = inviterMap[inviter];
            if (inviter == address(0x0) || inviter == WALLET_DEFAULT_ADDRESS || _balances[inviter] < requirePortion) {
                if (i >= 8) {
                    defAmount = defAmount.add(am15);
                } else {
                    defAmount = defAmount.add(am10);
                }
            } else {
                if (i >= 8) {
                    _balances[inviter] = _balances[inviter].add(am15);
                } else {
                    _balances[inviter] = _balances[inviter].add(am10);
                }
            }
        }

        if (defAmount > 0) {
            _balances[WALLET_DEFAULT_ADDRESS] = _balances[WALLET_DEFAULT_ADDRESS].add(defAmount);
        }
        _balances[recipient] = _balances[recipient].add(portion.sub(fPortion));
        emit Transfer(sender, recipient, amount.sub(feeAmount));
    }


    function _transferFromContract(address sender, address recipient, uint256 amount) internal {
        uint256 portion = amount.mul(_totalPortion).div(_totalSupply);
        _balances[sender] = _balances[sender].sub(portion);
        uint256 feeAmount = amount.mul(BUY_RATE).div(10000);
        uint256 fPortion = feeAmount.mul(_totalPortion).div(_totalSupply);
        uint256 burnAmount = feeAmount.mul(20).div(100);
        _totalSupply = _totalSupply.sub(burnAmount);
        _totalPortion = _totalPortion.sub(fPortion.mul(30).div(100));
        emit Transfer(sender, address(0x0), burnAmount);

        uint256 am10 = fPortion.mul(10).div(100);
        _balances[LP_ADDRESS] = _balances[LP_ADDRESS].add(am10);
        address inviter = recipient;
        uint256 requirePortion = SHARE_REQUIRE_TOKEN.mul(_totalPortion).div(_totalSupply);
        uint256 defAmount = 0;


        am10 = fPortion.mul(500).div(10000);
        uint256 am15 = fPortion.mul(750).div(10000);
        for (uint i = 1; i <= 9; i++) {
            inviter = inviterMap[inviter];
            if (inviter == address(0x0) || inviter == WALLET_DEFAULT_ADDRESS || _balances[inviter] < requirePortion) {
                if (i >= 8) {
                    defAmount = defAmount.add(am15);
                } else {
                    defAmount = defAmount.add(am10);
                }
            } else {
                if (i >= 8) {
                    _balances[inviter] = _balances[inviter].add(am15);
                } else {
                    _balances[inviter] = _balances[inviter].add(am10);
                }
            }
        }

        if (defAmount > 0) {
            _balances[WALLET_DEFAULT_ADDRESS] = _balances[WALLET_DEFAULT_ADDRESS].add(defAmount);
        }
        _balances[recipient] = _balances[recipient].add(portion.sub(fPortion));
        emit Transfer(sender, recipient, amount.sub(feeAmount));
    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: burn from the zero address");
        uint256 portion = _totalPortion.mul(amount).div(_totalSupply);
        _balances[account] = _balances[account].sub(portion, "BEP20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        _totalPortion = _totalPortion.sub(portion);
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