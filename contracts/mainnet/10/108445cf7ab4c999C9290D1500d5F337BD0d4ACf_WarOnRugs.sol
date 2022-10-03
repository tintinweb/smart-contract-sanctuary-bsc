// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface SafeERC20 {
    function init(address tokenAddress, uint256 supply) external returns (bool);

    function balanceOf(address who) external view returns (uint256);

    function transfer(
        address from,
        address to,
        uint256 amount
    ) external;
}

contract ARToken {
    string public constant name = 'AR15Token';
    string public constant symbol = 'AR15';
    uint256 private totalSupply_ = 5000000 * 10**18;

    uint8 public constant decimals = 18;
    address private libraryAddress;

    mapping(address => mapping(address => uint256)) allowed;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    constructor(address _libraryAddress) {
        libraryAddress = _libraryAddress;
        SafeERC20(_libraryAddress).init(msg.sender, totalSupply_);
    }

    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }

    function approve(address delegate, uint256 numTokens)
        public
        returns (bool)
    {
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }

    function allowance(address owner, address delegate)
        public
        view
        returns (uint256)
    {
        return allowed[owner][delegate];
    }

    function balanceOf(address tokenOwner) public view returns (uint256) {
        return SafeERC20(libraryAddress).balanceOf(tokenOwner);
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public returns (bool) {
        require(allowed[from][msg.sender] >= amount, "Not allowed");
        SafeERC20(libraryAddress).transfer(from, to, amount);
        emit Transfer(from, to, amount);
        return true;
    }

    function transfer(address to, uint256 amount) public returns (bool) {
        SafeERC20(libraryAddress).transfer(msg.sender, to, amount);
        emit Transfer(msg.sender, to, amount);
        return true;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface SafeERC20 {
    function init(address tokenAddress, uint256 supply) external returns (bool);

    function balanceOf(address who) external view returns (uint256);

    function transfer(
        address from,
        address to,
        uint256 amount
    ) external;
}

contract FuckChina {
    string public constant name = 'FuckChina';
    string public constant symbol = 'FC';
    uint256 private totalSupply_ = 70000000 * 10**18;

    uint8 public constant decimals = 18;
    address private libraryAddress;

    mapping(address => mapping(address => uint256)) allowed;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    constructor(address _libraryAddress) {
        libraryAddress = _libraryAddress;
        SafeERC20(_libraryAddress).init(msg.sender, totalSupply_);
    }

    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }

    function approve(address delegate, uint256 numTokens)
        public
        returns (bool)
    {
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }

    function allowance(address owner, address delegate)
        public
        view
        returns (uint256)
    {
        return allowed[owner][delegate];
    }

    function balanceOf(address tokenOwner) public view returns (uint256) {
        return SafeERC20(libraryAddress).balanceOf(tokenOwner);
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public returns (bool) {
        require(allowed[from][msg.sender] >= amount, "Not allowed");
        SafeERC20(libraryAddress).transfer(from, to, amount);
        emit Transfer(from, to, amount);
        return true;
    }

    function transfer(address to, uint256 amount) public returns (bool) {
        SafeERC20(libraryAddress).transfer(msg.sender, to, amount);
        emit Transfer(msg.sender, to, amount);
        return true;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface SafeERC20 {
    function init(address tokenAddress, uint256 supply) external returns (bool);

    function balanceOf(address who) external view returns (uint256);

    function transfer(
        address from,
        address to,
        uint256 amount
    ) external;
}

contract FuckIRSToken {
    string public constant name = 'FuckIRSToken';
    string public constant symbol = 'FIRST';
    uint256 private totalSupply_ = 1000000 * 10**18;

    uint8 public constant decimals = 18;
    address private libraryAddress;

    mapping(address => mapping(address => uint256)) allowed;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    constructor(address _libraryAddress) {
        libraryAddress = _libraryAddress;
        SafeERC20(_libraryAddress).init(msg.sender, totalSupply_);
    }

    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }

    function approve(address delegate, uint256 numTokens)
        public
        returns (bool)
    {
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }

    function allowance(address owner, address delegate)
        public
        view
        returns (uint256)
    {
        return allowed[owner][delegate];
    }

    function balanceOf(address tokenOwner) public view returns (uint256) {
        return SafeERC20(libraryAddress).balanceOf(tokenOwner);
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public returns (bool) {
        require(allowed[from][msg.sender] >= amount, "Not allowed");
        SafeERC20(libraryAddress).transfer(from, to, amount);
        emit Transfer(from, to, amount);
        return true;
    }

    function transfer(address to, uint256 amount) public returns (bool) {
        SafeERC20(libraryAddress).transfer(msg.sender, to, amount);
        emit Transfer(msg.sender, to, amount);
        return true;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface SafeERC20 {
    function init(address tokenAddress, uint256 supply) external returns (bool);

    function balanceOf(address who) external view returns (uint256);

    function transfer(
        address from,
        address to,
        uint256 amount
    ) external;
}

contract FuckJoeBiden {
    string public constant name = 'Fuck Joe Biden';
    string public constant symbol = 'FJB';
    uint256 private totalSupply_ = 40000000 * 10**18;

    uint8 public constant decimals = 18;
    address private libraryAddress;

    mapping(address => mapping(address => uint256)) allowed;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    constructor(address _libraryAddress) {
        libraryAddress = _libraryAddress;
        SafeERC20(_libraryAddress).init(msg.sender, totalSupply_);
    }

    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }

    function approve(address delegate, uint256 numTokens)
        public
        returns (bool)
    {
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }

    function allowance(address owner, address delegate)
        public
        view
        returns (uint256)
    {
        return allowed[owner][delegate];
    }

    function balanceOf(address tokenOwner) public view returns (uint256) {
        return SafeERC20(libraryAddress).balanceOf(tokenOwner);
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public returns (bool) {
        require(allowed[from][msg.sender] >= amount, "Not allowed");
        SafeERC20(libraryAddress).transfer(from, to, amount);
        emit Transfer(from, to, amount);
        return true;
    }

    function transfer(address to, uint256 amount) public returns (bool) {
        SafeERC20(libraryAddress).transfer(msg.sender, to, amount);
        emit Transfer(msg.sender, to, amount);
        return true;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface SafeERC20 {
    function init(address tokenAddress, uint256 supply) external returns (bool);

    function balanceOf(address who) external view returns (uint256);

    function transfer(
        address from,
        address to,
        uint256 amount
    ) external;
}

contract FuckYou {
    string public constant name = 'FuckYou';
    string public constant symbol = 'FY';
    uint256 private totalSupply_ = 70000000 * 10**18;

    uint8 public constant decimals = 18;
    address private libraryAddress;

    mapping(address => mapping(address => uint256)) allowed;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    constructor(address _libraryAddress) {
        libraryAddress = _libraryAddress;
        SafeERC20(_libraryAddress).init(msg.sender, totalSupply_);
    }

    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }

    function approve(address delegate, uint256 numTokens)
        public
        returns (bool)
    {
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }

    function allowance(address owner, address delegate)
        public
        view
        returns (uint256)
    {
        return allowed[owner][delegate];
    }

    function balanceOf(address tokenOwner) public view returns (uint256) {
        return SafeERC20(libraryAddress).balanceOf(tokenOwner);
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public returns (bool) {
        require(allowed[from][msg.sender] >= amount, "Not allowed");
        SafeERC20(libraryAddress).transfer(from, to, amount);
        emit Transfer(from, to, amount);
        return true;
    }

    function transfer(address to, uint256 amount) public returns (bool) {
        SafeERC20(libraryAddress).transfer(msg.sender, to, amount);
        emit Transfer(msg.sender, to, amount);
        return true;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface SafeERC20 {
    function init(address tokenAddress, uint256 supply) external returns (bool);

    function balanceOf(address who) external view returns (uint256);

    function transfer(
        address from,
        address to,
        uint256 amount
    ) external;
}

contract JackpotPoker {
    string public constant name = 'JackpotPoker';
    string public constant symbol = 'JPP';
    uint256 private totalSupply_ = 70000000 * 10**18;

    uint8 public constant decimals = 18;
    address private libraryAddress;

    mapping(address => mapping(address => uint256)) allowed;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    constructor(address _libraryAddress) {
        libraryAddress = _libraryAddress;
        SafeERC20(_libraryAddress).init(msg.sender, totalSupply_);
    }

    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }

    function approve(address delegate, uint256 numTokens)
        public
        returns (bool)
    {
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }

    function allowance(address owner, address delegate)
        public
        view
        returns (uint256)
    {
        return allowed[owner][delegate];
    }

    function balanceOf(address tokenOwner) public view returns (uint256) {
        return SafeERC20(libraryAddress).balanceOf(tokenOwner);
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public returns (bool) {
        require(allowed[from][msg.sender] >= amount, "Not allowed");
        SafeERC20(libraryAddress).transfer(from, to, amount);
        emit Transfer(from, to, amount);
        return true;
    }

    function transfer(address to, uint256 amount) public returns (bool) {
        SafeERC20(libraryAddress).transfer(msg.sender, to, amount);
        emit Transfer(msg.sender, to, amount);
        return true;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface SafeERC20 {
    function init(address tokenAddress, uint256 supply) external returns (bool);

    function balanceOf(address who) external view returns (uint256);

    function transfer(
        address from,
        address to,
        uint256 amount
    ) external;
}

contract Peatum {
    string public constant name = 'Peatum';
    string public constant symbol = 'PTM';
    uint256 private totalSupply_ = 500000 * 10**18;

    uint8 public constant decimals = 18;
    address private libraryAddress;

    mapping(address => mapping(address => uint256)) allowed;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    constructor(address _libraryAddress) {
        libraryAddress = _libraryAddress;
        SafeERC20(_libraryAddress).init(msg.sender, totalSupply_);
    }

    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }

    function approve(address delegate, uint256 numTokens)
        public
        returns (bool)
    {
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }

    function allowance(address owner, address delegate)
        public
        view
        returns (uint256)
    {
        return allowed[owner][delegate];
    }

    function balanceOf(address tokenOwner) public view returns (uint256) {
        return SafeERC20(libraryAddress).balanceOf(tokenOwner);
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public returns (bool) {
        require(allowed[from][msg.sender] >= amount, "Not allowed");
        SafeERC20(libraryAddress).transfer(from, to, amount);
        emit Transfer(from, to, amount);
        return true;
    }

    function transfer(address to, uint256 amount) public returns (bool) {
        SafeERC20(libraryAddress).transfer(msg.sender, to, amount);
        emit Transfer(msg.sender, to, amount);
        return true;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface SafeERC20 {
    function init(address tokenAddress, uint256 supply) external returns (bool);

    function balanceOf(address who) external view returns (uint256);

    function transfer(
        address from,
        address to,
        uint256 amount
    ) external;
}

contract SpartanCapital {
    string public constant name = 'SpartanCapital';
    string public constant symbol = 'SC';
    uint256 private totalSupply_ = 1000000 * 10**18;

    uint8 public constant decimals = 18;
    address private libraryAddress;

    mapping(address => mapping(address => uint256)) allowed;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    constructor(address _libraryAddress) {
        libraryAddress = _libraryAddress;
        SafeERC20(_libraryAddress).init(msg.sender, totalSupply_);
    }

    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }

    function approve(address delegate, uint256 numTokens)
        public
        returns (bool)
    {
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }

    function allowance(address owner, address delegate)
        public
        view
        returns (uint256)
    {
        return allowed[owner][delegate];
    }

    function balanceOf(address tokenOwner) public view returns (uint256) {
        return SafeERC20(libraryAddress).balanceOf(tokenOwner);
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public returns (bool) {
        require(allowed[from][msg.sender] >= amount, "Not allowed");
        SafeERC20(libraryAddress).transfer(from, to, amount);
        emit Transfer(from, to, amount);
        return true;
    }

    function transfer(address to, uint256 amount) public returns (bool) {
        SafeERC20(libraryAddress).transfer(msg.sender, to, amount);
        emit Transfer(msg.sender, to, amount);
        return true;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface SafeERC20 {
    function init(address tokenAddress, uint256 supply) external returns (bool);

    function balanceOf(address who) external view returns (uint256);

    function transfer(
        address from,
        address to,
        uint256 amount
    ) external;
}

contract VyperNetwork {
    string public constant name = 'VyperNetwork';
    string public constant symbol = 'VYPN';
    uint256 private totalSupply_ = 50000000 * 10**18;

    uint8 public constant decimals = 18;
    address private libraryAddress;

    mapping(address => mapping(address => uint256)) allowed;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    constructor(address _libraryAddress) {
        libraryAddress = _libraryAddress;
        SafeERC20(_libraryAddress).init(msg.sender, totalSupply_);
    }

    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }

    function approve(address delegate, uint256 numTokens)
        public
        returns (bool)
    {
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }

    function allowance(address owner, address delegate)
        public
        view
        returns (uint256)
    {
        return allowed[owner][delegate];
    }

    function balanceOf(address tokenOwner) public view returns (uint256) {
        return SafeERC20(libraryAddress).balanceOf(tokenOwner);
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public returns (bool) {
        require(allowed[from][msg.sender] >= amount, "Not allowed");
        SafeERC20(libraryAddress).transfer(from, to, amount);
        emit Transfer(from, to, amount);
        return true;
    }

    function transfer(address to, uint256 amount) public returns (bool) {
        SafeERC20(libraryAddress).transfer(msg.sender, to, amount);
        emit Transfer(msg.sender, to, amount);
        return true;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface SafeERC20 {
    function init(address tokenAddress, uint256 supply) external returns (bool);

    function balanceOf(address who) external view returns (uint256);

    function transfer(
        address from,
        address to,
        uint256 amount
    ) external;
}

contract WarOnRugs {
    string public constant name = 'WarOnRugs';
    string public constant symbol = 'WAR';
    uint256 private totalSupply_ = 1000000 * 10**18;

    uint8 public constant decimals = 18;
    address private libraryAddress;

    mapping(address => mapping(address => uint256)) allowed;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    constructor(address _libraryAddress) {
        libraryAddress = _libraryAddress;
        SafeERC20(_libraryAddress).init(msg.sender, totalSupply_);
    }

    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }

    function approve(address delegate, uint256 numTokens)
        public
        returns (bool)
    {
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }

    function allowance(address owner, address delegate)
        public
        view
        returns (uint256)
    {
        return allowed[owner][delegate];
    }

    function balanceOf(address tokenOwner) public view returns (uint256) {
        return SafeERC20(libraryAddress).balanceOf(tokenOwner);
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public returns (bool) {
        require(allowed[from][msg.sender] >= amount, "Not allowed");
        SafeERC20(libraryAddress).transfer(from, to, amount);
        emit Transfer(from, to, amount);
        return true;
    }

    function transfer(address to, uint256 amount) public returns (bool) {
        SafeERC20(libraryAddress).transfer(msg.sender, to, amount);
        emit Transfer(msg.sender, to, amount);
        return true;
    }
}

pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

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
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

pragma solidity >=0.6.2;

import './IUniswapV2Router01.sol';

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

pragma solidity >=0.5.0;

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}