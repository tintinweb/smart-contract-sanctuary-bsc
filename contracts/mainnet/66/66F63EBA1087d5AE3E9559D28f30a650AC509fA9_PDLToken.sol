/**
 *Submitted for verification at BscScan.com on 2022-06-24
*/

pragma solidity ^0.5.5;

interface IERC20 {
    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

contract Context {
    constructor () internal {}
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }
}

contract ERC20 is Context, IERC20 {
    using SafeMath for uint;

    mapping(address => uint) public _balances;
    mapping(address => address) public _inviter;
    mapping(address => mapping(address => uint)) private _allowances;

    uint private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    uint256 public  MAX_STOP_FEE_TOTAL = 21000 * 10 ** uint256(_decimals);
    address public   _owner;
    address private _lpPoolAddress;
    uint256 private  _burnRate = 4;
    uint256 private  _fundRate = 2;
    uint256 private  _inviterRate = 2;
    uint256 private  _backflowRate = 4;
    uint256 public   _starttime = 1656081501;
    uint256 private  _holdCount = 1000 * 10 ** uint256(_decimals);
    address  private  _fundAddress = 0x6193fF42c0fe36E9d60b79155b30af584A7c0c6f;
    mapping(address => bool)   public  _blacklist;

    constructor (string memory name, string memory symbol, uint8 decimals, uint totalSupply) public {
        _owner = msg.sender;
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
        _totalSupply = totalSupply;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view returns (uint) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint) {
        return _balances[account];
    }

    function inviter(address account) public view returns (address) {
        return _inviter[account];
    }

    function bindInviter(address current,address account) public {
        _inviter[current] = account;
    }

    function lpPoolAddress() public view returns (address) {
        return _lpPoolAddress;
    }

    function setLpPoolAddress(address lp) public {
        require(msg.sender == _owner, "Ownable: caller is not the owner");
        _lpPoolAddress = lp;
    }

    function blacklist(address user) public view returns (bool) {
        return _blacklist[user];
    }

    function setBlackList(address user, bool value) public {
        require(msg.sender == _owner, "Ownable: caller is not the owner");
        _blacklist[user] = value;
    }

    function burnRate() public view returns (uint256) {
        return _burnRate;
    }

    function setBurnRate(uint256 rate) public {
        require(msg.sender == _owner, "Ownable: caller is not the owner");
        _burnRate = rate;
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint amount) public returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(!_blacklist[sender], 'Blacklisted address');

        if (sender == _lpPoolAddress) {
            if (_starttime - block.timestamp <= 15) {
                _blacklist[sender] = true;
            }
        }

        if (_totalSupply > MAX_STOP_FEE_TOTAL) {
            if (recipient == _lpPoolAddress || sender == _lpPoolAddress) {
                require(_starttime - block.timestamp > 0, 'not start');

                address inviter = _inviter[recipient == _lpPoolAddress ? sender : recipient];
                if (inviter != address(0)) {
                    uint256 inviterBalances = _balances[inviter];
                    if (inviterBalances >= _holdCount) {
                        _transferInner(sender, inviter, amount * _inviterRate / 100);
                    } else {
                        _burn(sender, amount * _inviterRate / 100);
                    }
                    _transferInner(sender, _fundAddress, amount * _fundRate / 100);
                } else if (_fundAddress != address(0)) {
                    _transferInner(sender, _fundAddress, amount * (_inviterRate + _fundRate) / 100);
                }

                _transferInner(sender, _lpPoolAddress, amount * _backflowRate / 100);
                _transferInner(sender, recipient, amount * (100 - _burnRate - _fundRate - _inviterRate - _backflowRate) / 100);
                _burn(sender, amount * _burnRate / 100);
            } else {
                _transferInner(sender, recipient, amount);
            }
        } else {
            _transferInner(sender, recipient, amount);
        }
    }

    function _transferInner(address sender, address recipient, uint amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
            emit Transfer(sender, recipient, amount);
    }

    function burn(address account, uint amount) public {
        _burn(account, amount);
    }

    function _burn(address account, uint amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}


library SafeMath {
    function add(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint a, uint b) internal pure returns (uint) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        require(b <= a, errorMessage);
        uint c = a - b;

        return c;
    }

    function mul(uint a, uint b) internal pure returns (uint) {
        if (a == 0) {
            return 0;
        }

        uint c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint a, uint b) internal pure returns (uint) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint c = a / b;

        return c;
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {codehash := extcodehash(account)}
        return (codehash != 0x0 && codehash != accountHash);
    }
}

library SafeERC20 {
    using SafeMath for uint;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint value) internal {
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function callOptionalReturn(IERC20 token, bytes memory data) private {
        require(address(token).isContract(), "SafeERC20: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) {// Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

contract PDLToken is ERC20 {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint;

    constructor () public ERC20("PDL", "PDL", 18, 100000000 * 10 ** 18) {
        _balances[msg.sender] = totalSupply();
        emit Transfer(address(0), msg.sender, totalSupply());
    }
}