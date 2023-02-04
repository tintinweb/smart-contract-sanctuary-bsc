/**
 *Submitted for verification at BscScan.com on 2023-02-04
*/

// SPDX-License-Identifier: MIT
/*

   _________      __________    ___________
  /_____   /     |    ___   |  |____    ___|
       /  /      |   |___|  |       |  |
      /  /       |   ____   |       |  |
     /  /        |  |    |  |       |  |
    /  /         |  |    |  |   ____|  |___
   /__/          |__|    |__|  |___________|

*/

pragma solidity ^0.8.10;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
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
        return c;
    }

}

contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

}

contract myAdjustmentToken is Context, IERC20, Ownable {
    using SafeMath for uint256;
    address immutable WETH;
    address constant ZERO = 0x0000000000000000000000000000000000000000;

    mapping (address => uint256) private tokenBalance;
    mapping (address => mapping (address => uint256)) private tokenAllowance;
    mapping (address => bool) private _isExcludedFromFeeAndLimit;
    address constant public taxCollectorWallet = 0x000000000000000000000000000000000000dEaD;
    uint256 public constant totalTaxes = 7;

    uint8 private constant tokenDecimal = 9;
    uint256 private constant tokenTotalSupply = 100_000_000 * 10**tokenDecimal;
    string private constant _name = unicode"Fifth Attempt Token";
    string private constant _symbol = unicode"FAT";
    uint256 public constant _maxWalletSize = tokenTotalSupply * 2 / 100;
    IDEXRouter private router;
    address private immutable pair;

    constructor () {
        router = IDEXRouter(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
        WETH = router.WETH();
        pair = IDEXFactory(router.factory()).createPair(WETH, address(this));

        tokenBalance[_msgSender()] = tokenTotalSupply;

        _isExcludedFromFeeAndLimit[msg.sender] = true;
        _isExcludedFromFeeAndLimit[address(this)] = true;
        _isExcludedFromFeeAndLimit[taxCollectorWallet] = true;
        _isExcludedFromFeeAndLimit[ZERO] = true;

        emit Transfer(address(0), _msgSender(), tokenTotalSupply);
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return tokenDecimal;
    }

    function totalSupply() public pure override returns (uint256) {
        return tokenTotalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return tokenBalance[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return tokenAllowance[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        tokenAllowance[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 taxAmount=0;
        if (from != owner()) {
              taxAmount = amount.mul(totalTaxes).div(100);

            if (!_isExcludedFromFeeAndLimit[from] && !_isExcludedFromFeeAndLimit[to] && to != pair) {
                require(tokenBalance[to] + amount <= _maxWalletSize, "Exceeds the maxWalletSize.");
            }
        }

        tokenBalance[from]=tokenBalance[from].sub(amount);
        tokenBalance[to]=tokenBalance[to].add(amount.sub(taxAmount));
        emit Transfer(from, to, amount.sub(taxAmount));
        if(taxAmount>0){
          tokenBalance[taxCollectorWallet]=tokenBalance[taxCollectorWallet].add(taxAmount);
          emit Transfer(from, taxCollectorWallet, taxAmount);
        }
    }

    receive() external payable {}
    fallback() external payable {}
}