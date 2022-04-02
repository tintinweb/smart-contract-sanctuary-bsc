/**
 *Submitted for verification at BscScan.com on 2022-04-02
*/

/**
 *Submitted for verification at BscScan.com on 2022-04-02
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-30
*/

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)
pragma solidity >=0.8.13;

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}


interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WHT() external pure returns (address);

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


interface Irewards{
    function reward(uint256 amount) external;
}

contract rewards {

    address public token = 0x0d9F8DB4a0f696f6c4dF910A1A2Ada9f0cdFC6fd;
    address public parents_token = 0x5EfD0b376c50B6C9f67549c9b37Ca24B5920C2D3;
    address payable public owner;

    

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapPair;
    

    address public parents_address = 0x226CB6569776A3A3ac1F1507010f4637bAa4843c;//母币不销毁，母币购买后放入
    address public usdt_address = 0x55d398326f99059fF775485246999027B3197955;
    address public burnAddress = 0x000000000000000000000000000000000000dEaD;
    uint256 public max_reward = 100 * 1e18;


    constructor() {
        owner = payable(msg.sender);
        uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);

        IERC20(token).approve(address(uniswapV2Router),type(uint256).max);
        IERC20(usdt_address).approve(address(uniswapV2Router),type(uint256).max);
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "only owner");
        _;
    }

    function set_owner(address _owner) public onlyOwner {
        owner = payable(_owner);
    }

    function set_token(address _token) public onlyOwner {
        token = _token;
        IERC20(token).approve(address(uniswapV2Router),type(uint256).max);
    }


    function set_max_reward(uint256 _amount) public onlyOwner {
        max_reward = _amount;
    }

    function rewards2token() public {
        uint256 token_balance = IERC20(token).balanceOf(address(this));
        if(token_balance > max_reward)
            token_balance = max_reward;
        address[] memory path = new address[](3);
        path[0] = token;
        path[1] = usdt_address;
        path[2] = parents_token;

        // 购买母币
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            token_balance*2/5,
            0, // accept any amount of usdt
            path,
            parents_address,
            block.timestamp
        );



        address[] memory path2 = new address[](2);
        path2[0] = token;
        path2[1] = usdt_address;

        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            token_balance*3/10,
            0, // accept any amount of usdt
            path2,
            address(this),
            block.timestamp
        );

        uint256 usdt_balance = IERC20(usdt_address).balanceOf(address(this));
        uniswapV2Router.addLiquidity(
            token,
            usdt_address,
            token_balance*3/10,
            usdt_balance,
            0,
            0,
            address(0),
            block.timestamp
        );

    }

    function burn(uint256 amount) public onlyOwner{
        IERC20(usdt_address).transfer(burnAddress,amount);
    }
}