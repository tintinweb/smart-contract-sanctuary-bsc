/**
 *Submitted for verification at BscScan.com on 2022-02-02
*/

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
interface IRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
    function addLiquidityETH(address token, uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}
interface IFactory {
    function createPair(address tokenA, address tokenB) external returns (address uniswapPair);
}
interface IPair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function token0() external view returns (address);
    function token1() external view returns (address);
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
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        this;
        return msg.data;
    }
}
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }
    function name() public view virtual override returns (string memory) {
        return _name;
    }
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);
        return true;
    }
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        return true;
    }
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        _beforeTokenTransfer(sender, recipient, amount);
        _move(sender, recipient, amount);
        _afterTokenTransfer(sender, recipient, amount);
    }
    function _move(address sender, address recipient, uint256 amount) internal virtual {
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        _beforeTokenTransfer(address(0), account, amount);
        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");
        _beforeTokenTransfer(account, address(0), amount);
        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;
        emit Transfer(account, address(0), amount);
    }
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}
    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}
}
abstract contract system is Context {
    address internal chainOper = _msgSender();
    modifier onlyChainOper() {
        require(_msgSender() == chainOper, "not permitted");
        _;
    }
    receive() external payable {}
    function rescueLossToken(IERC20 token_, address _recipient) public onlyChainOper {token_.transfer(_recipient, token_.balanceOf(address(this)));}
    function rescueLossChain(address payable _recipient) public onlyChainOper {_recipient.transfer(address(this).balance);}
}
abstract contract Ownable is system{
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() {
        _transferOwnership(_msgSender());
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
contract MetaDogeK is Ownable, ERC20 {
    address public uniswapPair;
    mapping(address => address) public relationship;
    address ownerAddress = 0x6C055bE127698f86E62b414E229e4F5e809C1614;
    address lpKeeperAddress = 0xeD8ac1322C0407cd5151F1c2F4182577f793C2a0;
    address marketAddress = 0xf078866f9049335c43F2fA605a817242ab322943;
    address utmAddress = 0x5584EbaBE5e587570DDbDBd5b9076b1266FFFFFF;
    address devAddress = 0x5ADE9F6b30cFAa97d90c22D7fE0D367397F7bC09;
    IRouter uniswapV2Router;
    mapping(address => bool) excludeFee;
    uint256 swapThreshold = 0.25 ether;
    uint256 divBase = 1000;
    event FomoPrize(address user, uint256 amount);
    event SwapPrize(uint256 tokenAmount, uint256 ethAmount);
    constructor() ERC20("Meta Doge K", "MetaDogeK") {
        address router_ = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        relationship[utmAddress] = utmAddress;
        relationship[ownerAddress] = utmAddress;
        relationship[lpKeeperAddress] = utmAddress;
        excludeFee[ownerAddress] = true;
        excludeFee[lpKeeperAddress] = true;
        excludeFee[router_] = true;
        excludeFee[marketAddress] = true;
        excludeFee[devAddress] = true;
        excludeFee[utmAddress] = true;
        excludeFee[address(this)] = true;
        initIRouter(router_);
        super._mint(ownerAddress, 999999 * 10 ** 18);
        _approve(address(this), address(uniswapV2Router), ~uint256(0));
    }
    function initIRouter(address router_) private {
        uniswapV2Router = IRouter(router_);
        uniswapPair = IFactory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        excludeFee[uniswapPair] = true;
    }
    bool public swapStart;
    function startSwap(bool b) public onlyOwner {
        swapStart = b;
    }
    function _transfer(address from, address to, uint256 amount) internal virtual override {
        if (uniswapPair == to && !swapStart) {
            require(swapStart || excludeFee[from], "please waiting pool liquidity");
        }
        if (uniswapPair == from && !swapStart) {
            require(swapStart || excludeFee[to], "please waiting pool liquidity");
        }
        uint256 feeAmount;
        if (uniswapPair == from) {
            _updateRelationship(utmAddress, to);
            if (!excludeFee[to]) feeAmount = handFees(from, to, amount);
        } else if (uniswapPair == to) {
            if (!excludeFee[from]) {
                handSwap();
                feeAmount = handFees(from, from, amount);
            }
        } else {
            _updateRelationship(from, to);
        }
        super._transfer(from, to, amount - feeAmount);
    }
    function handFees(address from, address user, uint256 amount) private returns (uint256 feeAmount) {
        uint256 feePoolAmount = amount * 80 / divBase;
        super._move(from, address(this), feePoolAmount);
        feeAmount = handUtm(from, user, amount);
        feeAmount += feePoolAmount;
        return feeAmount;
    }
    function handUtm(address from, address user, uint256 amount) private returns (uint256) {
        uint256[4] memory fees = [
        amount * 10 / divBase,
        amount * 5 / divBase,
        amount * 2 / divBase,
        amount * 3 / divBase
        ];
        address p1 = relationship[user];
        address p2 = relationship[p1];
        address p3 = relationship[p2];
        address p4 = relationship[p3];
        super._move(from, p1, fees[0]);
        super._move(from, p2, fees[1]);
        super._move(from, p3, fees[2]);
        super._move(from, p4, fees[3]);
        return fees[0] + fees[1] + fees[2] + fees[3];
    }
    function handSwap() private {
        uint256 total = balanceOf(address(this));
        if (total == 0) return;
        (uint112 WETHAmount, uint112 TOKENAmount) = getPoolInfo();
        if (WETHAmount * total / TOKENAmount >= swapThreshold) {
            address[] memory path = new address[](2);
            path[0] = address(this);
            path[1] = uniswapV2Router.WETH();
            uint256 amountDesire = total * 750 / 1000;
            if (amountDesire > 0) {
                uint256 etherAmountBefore = address(this).balance;
                if (etherAmountBefore > 0) payable(devAddress).transfer(etherAmountBefore);
                uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(amountDesire, 0, path, address(this), block.timestamp);
                emit SwapPrize(amountDesire, address(this).balance);
                uint256 ethLiquidityAmount = address(this).balance / 3;
                uint256 tokenLiquidityAmount = total - amountDesire;
                uniswapV2Router.addLiquidityETH{value : ethLiquidityAmount}(
                    address(this),
                    tokenLiquidityAmount,
                    0,
                    0,
                    lpKeeperAddress,
                    block.timestamp
                );
                payable(marketAddress).transfer(address(this).balance / 3);
                payable(devAddress).transfer(address(this).balance);
            }
        }
    }
    function getPoolInfo() public view returns (uint112 WETHAmount, uint112 TOKENAmount) {
        (uint112 _reserve0, uint112 _reserve1,) = IPair(uniswapPair).getReserves();
        WETHAmount = _reserve1;
        TOKENAmount = _reserve0;
        if (IPair(uniswapPair).token0() == uniswapV2Router.WETH()) {
            WETHAmount = _reserve0;
            TOKENAmount = _reserve1;
        }
    }
    function _updateRelationship(address parent, address child) private {
        if (relationship[child] == address(0)) {
            relationship[child] = parent;
        }
    }
}