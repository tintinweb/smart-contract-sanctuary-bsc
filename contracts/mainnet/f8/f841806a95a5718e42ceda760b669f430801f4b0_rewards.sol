/**
 *Submitted for verification at BscScan.com on 2022-03-21
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

    address public token;
    address payable public owner;

    

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapPair;
    

    address public marketing_address = 0x0Fc75d3408Df27eFf1FbF38aeAc2E1D749631236;
    address public buyer_address = 0x787E515DeFCD20fB2629d339a2a6B92771350Bb0;
    address public rewards_address;
    address public usdt_address = 0x55d398326f99059fF775485246999027B3197955;
    address public burnAddress = 0x000000000000000000000000000000000000dEaD;


    constructor(address _token) {
        owner = payable(msg.sender);
        token = _token;
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
    }

    
    function set_rewards_address(address account) public onlyOwner {
        rewards_address = account;
        IERC20(usdt_address).approve(rewards_address,type(uint256).max);
    }

    function rewards2token() public {
        uint256 token_balance = IERC20(token).balanceOf(address(this));
        address[] memory path = new address[](2);
        path[0] = token;
        path[1] = usdt_address;

        // make the swap
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            token_balance*9/10,
            0, // accept any amount of usdt
            path,
            address(this),
            block.timestamp
        );

        
        
        uint256 usdt_balance = IERC20(usdt_address).balanceOf(address(this));
        token_balance = IERC20(token).balanceOf(address(this));
        uniswapV2Router.addLiquidity(
            token,
            usdt_address,
            token_balance,
            usdt_balance,
            0,
            0,
            address(0),
            block.timestamp
        );

        usdt_balance = IERC20(usdt_address).balanceOf(address(this));
        IERC20(usdt_address).transfer(buyer_address,usdt_balance *40/100);
        IERC20(usdt_address).transfer(marketing_address,usdt_balance * 20/100);
        swap2rewards();
    }

    

    function swap2rewards() public {
        Irewards(rewards_address).reward(IERC20(usdt_address).balanceOf(address(this)));
    }
}