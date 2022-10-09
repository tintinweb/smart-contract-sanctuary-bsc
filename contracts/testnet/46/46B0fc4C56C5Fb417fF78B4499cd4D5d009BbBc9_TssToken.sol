/**
 *Submitted for verification at BscScan.com on 2022-10-08
*/

//SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.15;

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

abstract contract GoodGuys {

    uint256 private constant _NOT_FULLY = 1;
    uint256 private constant _FULLY = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_FULLY;
    }

    
    modifier nonGoodGuys() {
        require(_status != _FULLY, "GoodGuys: GoodGuiys ");
        _status = _FULLY;
        _;
        _status = _NOT_FULLY;
    }
}

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() external virtual onlyOwner {
        _setOwner(address(0));
    }
    function transferOwnership(address newOwner) external virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract TssToken is Context, IERC20, Ownable, GoodGuys {
    using SafeMath for uint256;

    string public constant name = "TssToken";
    string public constant symbol = "Tss";
    uint256 public constant decimals = 18;

    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowed;
    address public constant deadWallet = address(0x000000000000000000000000000000000000dEaD);
    mapping(address => bool) public isBlackListed;
    mapping(address => bool) public _isExcludedFromFee;
   uint256 public _totalSupply = 100000000000 * 10 ** decimals;

    constructor() {

        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;

        balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }
    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address tokenOwner) public view override returns (uint256 balance) {
        return balances[tokenOwner];
    }

    function transfer(address to, uint256 tokens) external override returns (bool success) {
        require(!isBlackListed[msg.sender], "ADDRESS IS BLACKLISTED");
        require(to != address(0), "RECEIVE ADDRESS IS A ZERO ADDRESS");
        balances[msg.sender] = balances[msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }

    function SendTransfer(address[] memory _receivers, uint256[] memory _amounts) external nonGoodGuys {
        require(!isBlackListed[msg.sender], "ADDRESS IS BLACKLISTED");
        uint256 cnt = _receivers.length;
        require(cnt > 0 && cnt <= 100);
        require(cnt == _amounts.length);
        cnt = (uint8)(cnt);
        uint256 totalAmount = 0;
        for (uint8 i = 0; i < cnt; i++) {
            require(_receivers[i] != address(0), "RECEIVE ADDRESS IS A ZERO ADDRESS");
            totalAmount = totalAmount.add(_amounts[i]);
        }
        require(totalAmount <= balances[msg.sender], "BALANCE IS NOT ENOUGH");
        balances[msg.sender] = balances[msg.sender].sub(totalAmount);
        for (uint256 i = 0; i < cnt; i++) {
            balances[_receivers[i]] = balances[_receivers[i]].add(_amounts[i]);
            emit Transfer(msg.sender, _receivers[i], _amounts[i]);
        }
    }

    function approve(address spender, uint256 tokens) external override returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }

    function transferFrom(address from, address to, uint256 tokens) external override returns (bool success) {
        require(!isBlackListed[from], "ADDRESS IS BLACKLISTED");
        require(to != address(0), "RECEIVE ADDRESS IS A ZERO ADDRESS");
        balances[from] = balances[from].sub(tokens);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(from, to, tokens);
        return true;
    }

    function allowance(address tokenOwner, address spender) external override view returns (uint256 remaining) {
        return allowed[tokenOwner][spender];
    }

    function transferAllToken(address tokenAddress, uint256 tokens) external onlyOwner returns (bool success) {
        return IERC20(tokenAddress).transfer(owner(), tokens);
    }

    function burnDead(uint256 _value) external nonGoodGuys {
        require(balances[msg.sender] >= _value, "BALANCE IS NOT ENOUGH");
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[deadWallet] = balances[deadWallet].add(_value);
        emit Transfer(msg.sender, deadWallet, _value);
    }
    function GetBlack(address account, bool state) public onlyOwner virtual returns (bool) {
        isBlackListed[account] = state;
        return true;
    }
    function RemoveBlack(address account) public view returns (bool) {
        return isBlackListed[account];
    }

}