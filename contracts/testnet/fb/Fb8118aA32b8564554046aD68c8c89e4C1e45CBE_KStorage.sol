/**
 *Submitted for verification at BscScan.com on 2022-11-28
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library SafeMath {
    function tryAdd(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }

    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        return (a / 2) + (b / 2) + (((a % 2) + (b % 2)) / 2);
    }
}

abstract contract Ownable {
    address private _owner;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    // function renounceOwnership() public virtual onlyOwner {
    //     emit OwnershipTransferred(_owner, address(0));
    //     _owner = address(0);
    // }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract KStorage is Ownable {
    using SafeMath for uint256;

    struct Record {
        uint256 stake;
        uint256 expire;
    }

    uint256 public lockTime = 8640000;
    mapping(address => Record[]) public userRecordMap;
    mapping(address => uint256) public tokenRecords;
    address[] public userList;
    mapping(address => bool) public userState;

    IERC20 public lpToken;
    address public operator;

    uint256 _totalSupply;
    mapping(address => uint256) _balances;

    event GovWithdrawToken(address indexed to, uint256 value);
    event Stake(address indexed from, uint256 amount);

    constructor(address _lpToken) {
        lpToken = IERC20(_lpToken);
    }

    modifier onlyOperator() {
        require(operator == msg.sender, "Caller is not the operator");
        _;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function stakeFor(
        address _from,
        address _to,
        uint256 _value
    ) public onlyOperator returns (uint256) {
        uint256 allowed = lpToken.allowance(_from, address(this));
        uint256 balanced = lpToken.balanceOf(_from);
        require(allowed >= _value, "!allowed");
        require(balanced >= _value, "!balanced");
        lpToken.transferFrom(_from, address(this), _value);
        _totalSupply = _totalSupply.add(_value);
        _balances[_to] = _balances[_to].add(_value);
        uint256 expire = block.timestamp + lockTime;
        userRecordMap[_to].push(Record(_value, expire));
        addCount(_to);
        emit Stake(_to, _value);
        return _value;
    }

    function addCount(address _addr) private {
        if (!userState[_addr]) {
            userList.push(_addr);
            userState[_addr] = true;
        }
    }

    function withdraw(address account, uint256 _index) public onlyOperator {
        Record storage record = userRecordMap[account][_index];
        require(record.expire < block.timestamp, "not expired");
        uint256 _value = record.stake;

        userRecordMap[account][_index] = userRecordMap[account][
            getUserStakeLength(account) - 1
        ];
        userRecordMap[account].pop();

        lpToken.transfer(account, _value);
        _totalSupply = _totalSupply.sub(_value);
        _balances[account] = _balances[account].sub(_value);
    }

    function getUserStake(address _addr) public view returns (uint256) {
        return balanceOf(_addr);
    }

    function getUserStakeList(address _addr)
        public
        view
        returns (Record[] memory)
    {
        return userRecordMap[_addr];
    }

    function getUserStakeLength(address _addr) public view returns (uint256) {
        return userRecordMap[_addr].length;
    }

    function setTokens(address _lpToken) public onlyOwner {
        lpToken = IERC20(_lpToken);
    }

    function setOperator(address _operator) public onlyOwner {
        operator = _operator;
    }

    function govWithdrawToken(address _to, uint256 _amount) public onlyOwner {
        require(_amount > 0, "!zero input");
        lpToken.transfer(_to, _amount);
        emit GovWithdrawToken(_to, _amount);
    }

    function withdrawForeignTokens(
        address token,
        address to,
        uint256 amount
    ) public onlyOwner returns (bool) {
        require(token != address(lpToken), "Wrong token!");
        return IERC20(token).transfer(to, amount);
    }

    function changeLockTime(uint256 _lockTime) public onlyOwner {
        lockTime = _lockTime;
    }
}