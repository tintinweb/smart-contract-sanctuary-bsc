/**
 *Submitted for verification at BscScan.com on 2023-03-08
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

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

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
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

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
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
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

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

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
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

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract PreSaleXYT is Ownable{
    using SafeMath for uint256;

    uint256 public constant VERSION = 1;
    address public constant XYTToken = 0x7c5c1A274E7c297db988910C1446B9EEE763e26F;
    address public constant USDToken = 0x55d398326f99059fF775485246999027B3197955;
    uint256 public myChainId;
    uint256 public price; // usdt
    uint256 public minUsdtAmount; // usdt
    uint256 public maxUsdtAmount; // usdt
    uint256 public targetXytAmount; // xyt
    uint256 public starttime;
    uint256 public endtime;
    uint256 public invitorPercent;
    uint256 public sendtime;
    uint256 public sendPercent; // Proportion of each withdrawal
    uint256 public sendInterval; // Interval between two withdrawals (seconds)
    mapping(address => uint256) private usdtMap;
    mapping(address => uint256) private xytMap;
    mapping(address => uint256) private sendXytMap;
    mapping(address => address) private invitorMap;
    mapping(address => uint256) private teamIdMap;
    mapping(uint256 => address) private teamMarks;
    mapping(uint256 => uint256) private teamTotal;
    uint256 private sumUsdtAmount; //  Total USDT Amount of users 
    uint256 private sumXytAmount; // Total XYT Amount of users
    uint256 private sumSendXytAmount; // Total XYT Amount withdrawn by users
    address private manageAddr;
    uint256 private paykey;

    constructor(uint256 _paykey, uint256 _myChainId){
        paykey = _paykey;
        myChainId = _myChainId;
    }

    function configPreSale(
        uint256 _price,
        uint256 _minUsdtAmount,
        uint256 _maxUsdtAmount,
        uint256 _targetXytAmount, 
        uint256 _starttime,
        uint256 _endtime,
        uint256 _invitorPercent
    ) public onlyOwner {
        price = _price;
        minUsdtAmount = _minUsdtAmount;
        maxUsdtAmount = _maxUsdtAmount;
        targetXytAmount = _targetXytAmount;
        starttime = _starttime;
        endtime = _endtime;
        invitorPercent = _invitorPercent;
    }

    function configSendParams(
        uint256 _sendtime,
        uint256 _sendPercent,
        uint256 _sendInterval
    ) public onlyOwner{
        sendtime = _sendtime;
        sendPercent = _sendPercent;
        sendInterval = _sendInterval;  
    }

    function configManager (address _manageAddr) public onlyOwner {
        require(_manageAddr != address(0), "The manageAddr is invalid");
        manageAddr = _manageAddr;
        usdtMap[manageAddr] = usdtMap[manageAddr].add(1);
        xytMap[manageAddr] = xytMap[manageAddr].add(1);
    }

    function configTeamMark(uint256 _teamId, address _teamAddr) public onlyOwner {
        require(_teamId > 1000, "teamId is invalid");
        require(_teamAddr != address(0), "teamAddr is invalid");
        teamMarks[_teamId] = _teamAddr;
    }

    function getTeamInfoById(uint256 _teamId) public view returns(address _teamAddr, uint256 _usdtAmount){
        return (teamMarks[_teamId], teamTotal[_teamId]);
    }

    function preSale(address _invitor, uint256 _teamId, uint256 _usdtAmount) external returns(bool) {
        // check time
        require(block.timestamp >= starttime, "The activity has not started yet");
        require(block.timestamp <= endtime, "The activity has ended!");
        // check teamId
        require(teamMarks[_teamId] != address(0), "The teamId is error!");
        // check _usdtAmount
        require(_usdtAmount >= minUsdtAmount && _usdtAmount <= maxUsdtAmount, "The payment amount is not within the specified range");
        // check invitor
        require(_invitor!=address(0), "The invitor is invalid");
        require(usdtMap[_invitor] > 0, "The amount of the inviter cannot be Zero");
        // check targetXytAmount
        require(targetXytAmount > sumXytAmount, "The target of this activity has been achieved");
        // check msg.sender
        require(usdtMap[msg.sender] == 0, "Each address can only be paid once");
        // transfer usdt and bnb
        IERC20(USDToken).transferFrom(msg.sender, address(this), _usdtAmount);
        // calculate XYT Number
        usdtMap[msg.sender] = _usdtAmount;
        xytMap[msg.sender] = _usdtAmount.mul(10 ** 18).div(price);
        // calculate invitor's reward
        uint256 inviteReward = xytMap[msg.sender].mul(invitorPercent).div(10000);
        xytMap[_invitor] = xytMap[_invitor].add(inviteReward);
        invitorMap[msg.sender] = _invitor;
        // calculate team's amount
        teamIdMap[msg.sender] = _teamId;
        teamTotal[_teamId] = teamTotal[_teamId].add(_usdtAmount);
        // calculate sum data
        sumUsdtAmount = sumUsdtAmount.add(usdtMap[msg.sender]);
        sumXytAmount = sumXytAmount.add(xytMap[msg.sender] + inviteReward);
        return true;
    }

    function getTotalData() public view onlyOwner returns(
        address _manageAddr, 
        uint256 _sumUSDT, 
        uint256 _sumXYT, 
        uint256 _sumSendXYT,
        uint256 _sendtime,
        uint256 _endtime,
        uint256 _sendPercent,
        uint256 _sendInterval
    ) {
        require(owner() == msg.sender, "You are not the owner");
        return (
            manageAddr, 
            sumUsdtAmount, 
            sumXytAmount, 
            sumSendXytAmount,
            sendtime,
            endtime,
            sendPercent,
            sendInterval
        );
    }

    function getUserRemainWithdraw() public view returns(uint256){
        require(block.timestamp > sendtime, "The withdrawal time has not arrived");
        uint256 perAmount = xytMap[msg.sender].mul(sendPercent).div(10000);
        uint256 times = (block.timestamp - sendtime).div(sendInterval);
        uint256 shouldSendAmont = perAmount.mul(times);
        if (shouldSendAmont >= xytMap[msg.sender]) {
            shouldSendAmont = xytMap[msg.sender];
        }
        return shouldSendAmont.sub(sendXytMap[msg.sender]);
    }

    function getUserInfoOwner(address _user) public view onlyOwner returns(
        uint256 _usdtAmount,
        uint256 _xytAmount, 
        uint256 _sendXytAmount, 
        address _invitor,
        uint256 _teamId
    ) {
        require(_user != address(0),"address is invalid");
        return _getUserInfo(_user);
    }

    function getUserInfoSender() public view returns(
        uint256 _usdtAmount, 
        uint256 _xytAmount, 
        uint256 _sendXytAmount, 
        address _invitor,
        uint256 _teamId
    ) {
        return _getUserInfo(msg.sender);
    }

    function _getUserInfo(address _user) internal view returns(
        uint256 _usdtAmount, 
        uint256 _xytAmount, 
        uint256 _sendXytAmount, 
        address _invitor,
        uint256 _teamId
    ) {
        return (usdtMap[_user], xytMap[_user], sendXytMap[_user], invitorMap[_user], teamIdMap[_user]);
    }

    function userWithdraw() public returns(bool) {
        uint256 remainWithdraw = getUserRemainWithdraw();
        require(remainWithdraw > 0, "Your XYT Balance is Zero");
        // transfer XYT to user
        IERC20(XYTToken).transfer(msg.sender, remainWithdraw);
        sendXytMap[msg.sender] = sendXytMap[msg.sender].add(remainWithdraw);
        // total send XYT amount
        sumSendXytAmount = sumSendXytAmount.add(remainWithdraw);
        return true;
    }

    function teamWithdraw(address _token, uint256 _amount, uint256 _paykey) public onlyOwner {
        require(manageAddr != address(0), "manageAddr is invalid");
        require(paykey == _paykey, "paykey is wrong");
        uint256 bal = IERC20(_token).balanceOf(address(this));
        require(_amount <= bal, "The contract balance is insufficient");
        IERC20(_token).transfer(manageAddr, _amount);
    }

    function withdrawAll(address payable _to, uint256 _paykey) public onlyOwner {
        require(paykey == _paykey, "paykey is wrong");
        require(owner() == _to, "only owner can operate");
        _to.transfer(address(this).balance);
    }

}