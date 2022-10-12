/**
 *Submitted for verification at BscScan.com on 2022-10-12
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IDRAC {
    event Transfer(address indexed from, address indexed to, uint256 value);   
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    function totalSupply() external view returns (uint256);   
    function balanceOf(address account) external view returns (uint256);   
    function transfer(address to, uint256 amount) external returns (bool);   
    function allowance(address owner, address spender) external view returns (uint256);   
    function approve(address spender, uint256 amount) external returns (bool);   
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

interface IPancakeSwapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IPancakeSwapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
}


contract DRAC is IDRAC {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    IPancakeSwapV2Router01 public uniswapV2Router;
    address public uniswapV2Pair;

    address private _owner;
    address public MarketAddress;
    bool public TaxEnable;
    bool public addLiquidityEnable; 
    address[] public WhiteLists; 
    mapping(address => bool) private WhiteList;
    mapping(address => bool) private Pair;

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    constructor() {
        _name = "DRAC Token";
        _symbol = "DRAC";
        _owner = address(0x8c4c81CED567533BA2909a6952395FA5367Aa38F);
        MarketAddress = address(0xF3412cFEf2C0140C72cDc8E2F7C76E305fFC11FE);
        _mint(_owner, 1 * 1e8 * 1e18);
        IPancakeSwapV2Router01 _uniswapV2Router = IPancakeSwapV2Router01(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        uniswapV2Pair = IPancakeSwapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;
        Pair[address(uniswapV2Pair)] = true;
        _approve(_owner, address(uniswapV2Router), type(uint256).max);
    }

    function addPair(address _pair) external onlyOwner {
        Pair[_pair] = !Pair[_pair];
    }

    function switchTaxEnable() external onlyOwner {
        TaxEnable = !TaxEnable;
    }

    function switchAddLiquidityEnable() external onlyOwner {
        addLiquidityEnable = !addLiquidityEnable;
    }

    function addWhiteList(address account) external onlyOwner{
        WhiteList[account] = !WhiteList[account];
        WhiteLists.push(account);
    }

    function getWhiteList() external view returns(address[] memory, bool[] memory) {
        address[] memory _whiteList = new address[](WhiteLists.length);
        bool[] memory _whiteListEnable = new bool[](WhiteLists.length);
        for (uint i = 0; i < WhiteLists.length; i++) {
            _whiteList[i] = WhiteLists[i];
            _whiteListEnable[i] = WhiteList[WhiteLists[i]];
        }
        return (_whiteList, _whiteListEnable);
    }

    function _msgSender() internal view returns (address) {
        return msg.sender;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function _checkOwner() internal view {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    function renounceOwnership() external onlyOwner {
        address oldOwner = _owner;
        _owner = address(0);
        addLiquidityEnable = true;
        emit OwnershipTransferred(oldOwner, _owner);
    }

    function name() public view virtual returns (string memory) {
        return _name;
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function allowance(address from, address spender) public view virtual override returns (uint256) {
        return _allowances[from][spender];
    }
   
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        require(addLiquidityEnable, "AddLiquidity Prohibited");
        address from = _msgSender();
        _approve(from, spender, amount);
        return true;
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {

        address from = _msgSender();

        if ( !TaxEnable ) { 
            _transfer(from, to, amount);
            return true;
        }

        if ( WhiteList[_msgSender()] || WhiteList[to]) { 
            _transfer(from, to, amount);
            return true;
        }

        if ( Pair[_msgSender()] || Pair[to]) { 
            _burn(_msgSender(), amount / 50 );
            amount = amount * 98 / 100;
        }
        _transfer(from, to, amount);
        return true;

    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        
        address spender = _msgSender();

        if ( !TaxEnable ) { 
             _spendAllowance(from, spender, amount);
            _transfer(from, to, amount);
            return true;
        }

        if ( WhiteList[from] ) { 
            
            _spendAllowance(from, spender, amount);
            _transfer(from, to, amount);
            return true;
        }

        if (Pair[to]) {
            
            _spendAllowance(from, spender, amount);
            _transfer(from, MarketAddress, amount / 50 );
            _transfer(from, to, amount * 98 / 100);
            return true;
        }

        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address from = _msgSender();
        _approve(from, spender, allowance(from, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address from = _msgSender();
        uint256 currentAllowance = allowance(from, spender);
        require(currentAllowance >= subtractedValue, "DRAC: decreased allowance below zero");
        unchecked {
            _approve(from, spender, currentAllowance - subtractedValue);
        }
       return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "DRAC: transfer from the zero address");
        require(to != address(0), "DRAC: transfer to the zero address");
       uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "DRAC: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;
       emit Transfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "DRAC: mint to the zero address");
        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "DRAC: burn from the zero address");
        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "DRAC: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;
       emit Transfer(account, address(0), amount);
       
    }

    function _approve(
        address from,
        address spender,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "DRAC: approve from the zero address");
        require(spender != address(0), "DRAC: approve to the zero address");
       _allowances[from][spender] = amount;
        emit Approval(from, spender, amount);
    }

    function _spendAllowance(
        address from,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(from, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "DRAC: insufficient allowance");
            unchecked {
                _approve(from, spender, currentAllowance - amount);
            }
        }
    }

    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public virtual {
        _spendAllowance(account, _msgSender(), amount);
        _burn(account, amount);
    }

}