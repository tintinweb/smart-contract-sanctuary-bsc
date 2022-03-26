/**
 *Submitted for verification at BscScan.com on 2022-03-26
*/

/**
    Just For Fun. 
    Initial Liquidity near 0.1 BNB. 
    10% Tax Fee: All Add to Liquidity. 
    After Liquidity Hit 4200 BNB, All Tax Fee Will Be Auto Removed Forever.
**/

//SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.0 <0.9.0;

interface IRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH( address token, uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable;
}
interface IFactory {
    function createPair(address tokenA, address tokenB) external returns (address uniswapPair);
}
interface IPair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function token0() external view returns (address);
    function token1() external view returns (address);
}
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {return msg.sender;}
    function _msgData() internal view virtual returns (bytes calldata) {this;return msg.data;}
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
interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    constructor (string memory name_, string memory symbol_) {_name = name_;_symbol = symbol_;}
    function name() public view virtual override returns (string memory) {return _name;}
    function symbol() public view virtual override returns (string memory) {return _symbol;}
    function decimals() public view virtual override returns (uint8) {return 18;}
    function totalSupply() public view virtual override returns (uint256) {return _totalSupply;}
    function balanceOf(address account) public view virtual override returns (uint256) {return _balances[account];}
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {_transfer(_msgSender(), recipient, amount);return true;}
    function allowance(address owner, address spender) public view virtual override returns (uint256) {return _allowances[owner][spender];}
    function approve(address spender, uint256 amount) public virtual override returns (bool) {_approve(_msgSender(), spender, amount);return true;}
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {_transfer(sender, recipient, amount);uint256 currentAllowance = _allowances[sender][_msgSender()];require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");_approve(sender, _msgSender(), currentAllowance - amount);return true;}
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {_approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);return true;}
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {uint256 currentAllowance = _allowances[_msgSender()][spender];require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");_approve(_msgSender(), spender, currentAllowance - subtractedValue);return true;}
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {require(sender != address(0), "ERC20: transfer from the zero address");require(recipient != address(0), "ERC20: transfer to the zero address");_beforeTokenTransfer(sender, recipient, amount);_move(sender, recipient, amount);_afterTokenTransfer(sender, recipient, amount);}
    function _move(address sender, address recipient, uint256 amount) internal virtual {uint256 senderBalance = _balances[sender];require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");_balances[sender] = senderBalance - amount;_balances[recipient] += amount;emit Transfer(sender, recipient, amount);}
    function _mint(address account, uint256 amount) internal virtual {require(account != address(0), "ERC20: mint to the zero address");_beforeTokenTransfer(address(0), account, amount);_totalSupply += amount;_balances[account] += amount;emit Transfer(address(0), account, amount);}
    function _burn(address account, uint256 amount) internal virtual {require(account != address(0), "ERC20: burn from the zero address");_beforeTokenTransfer(account, address(0), amount);uint256 accountBalance = _balances[account];require(accountBalance >= amount, "ERC20: burn amount exceeds balance");_balances[account] = accountBalance - amount;_totalSupply -= amount;emit Transfer(account, address(0), amount);}
    function _approve(address owner, address spender, uint256 amount) internal virtual {require(owner != address(0), "ERC20: approve from the zero address");require(spender != address(0), "ERC20: approve to the zero address");_allowances[owner][spender] = amount;emit Approval(owner, spender, amount);}
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}
    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}
    receive() external payable {}
}

contract ElonBuyTwitter is ERC20 {
    bool private _TaxFeeRemoved;
    address private _owner;

    IRouter public router;
    address public uniswapPair;
    address private _pcsRouterAddress = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);

    constructor() ERC20("Elon Buy Twitter", "EBT") {
        _owner = _msgSender();
        router = IRouter(_pcsRouterAddress);
        uniswapPair = IFactory(router.factory()).createPair(address(this), router.WETH());
        
        super._mint(_owner, 21000000 * 10 ** 18); 
    }
    function _transfer(address _from, address _to, uint256 _amount) internal virtual override {
        require (_from!=address(0), "Can't transfer to address 0");
        require (_to!=address(0), "Can't transfer to address 0");
        require (_amount>0 && balanceOf(_from) >= _amount, "Balance not enough");
        if (_TaxFeeRemoved) {
            super._transfer(_from, _to, _amount);
            return ;
        }
        else {
            uint256 taxFee = _amount / 10;
            if(taxFee == 0 || (uniswapPair!=_from && uniswapPair!=_to) || (_from==address(this) || _to==address(this)) || (_from==_owner || _to==_owner)) {
                super._transfer(_from, _to, _amount);
            } else {
                _handleLP();
                super._transfer(_from, _to, taxFee);
                super._transfer(_from, _to, _amount - taxFee);
            }
        }
    }
    function getPoolInfo() public view returns (uint256 WETHAmount, uint256 TOKENAmount) {
        uint112 WETHAmount_;
        uint112 TOKENAmount_;
        (uint112 _reserve0, uint112 _reserve1,) = IPair(uniswapPair).getReserves();
        WETHAmount_ = _reserve1;
        TOKENAmount_ = _reserve0;
        if (IPair(uniswapPair).token0() == router.WETH()) {
            WETHAmount_ = _reserve0;
            TOKENAmount_ = _reserve1;
        }
        (WETHAmount, TOKENAmount) = (uint256(WETHAmount_), uint256(TOKENAmount_));
    }
    function _handleLP() private {
        if (balanceOf(address(this)) == 0) { return ;}
        uint256 tokenBalance = balanceOf(address(this));
        (, uint256 TOKENAmount) = getPoolInfo();
        if (tokenBalance * 20 < TOKENAmount) { return ;}
        if (tokenBalance > TOKENAmount) { tokenBalance = TOKENAmount / 5; }
        uint256 half = tokenBalance / 2;
        uint256 otherHalf = tokenBalance - half;
        uint256 initialBalance = address(this).balance;
        _swapTokensForEth(half);
        uint256 newBalance = address(this).balance;
        uint256 gottonBalance = newBalance - initialBalance;
        _addLiquidity(otherHalf, gottonBalance);
        _check4200();
    }
    function _check4200() private {
        (uint256 WETHAmount,) = getPoolInfo();
        if (WETHAmount >= 4200 * 1e18) {_TaxFeeRemoved = true;}
    }
    function _swapTokensForEth(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();
        _approve(address(this), address(router), tokenAmount);
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(tokenAmount, 0, path, address(this), block.timestamp);
    }
    function _addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        _approve(address(this), address(router), tokenAmount);
        router.addLiquidityETH { value: ethAmount } (
            address(this),
            tokenAmount,
            0,
            0,
            address(0x000000000000000000000000000000000000dEaD),
            block.timestamp
        );
    }
    function _renounceOwnership() external {
        require(_msgSender() == _owner, "not permit");
        _owner = address(0);
    }
}