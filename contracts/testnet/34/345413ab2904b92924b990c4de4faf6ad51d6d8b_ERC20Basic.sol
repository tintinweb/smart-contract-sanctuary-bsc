/**
 *Submitted for verification at BscScan.com on 2022-09-17
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.15;
pragma experimental ABIEncoderV2;

// Dex Factory contract interface
interface IDexFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

// Dex Router02 contract interface
interface IDexRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
     )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );
        function swapExactTokensForETH(uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline)
        external
       returns (uint[] memory amounts);

}

interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract ERC20Basic is IERC20{
 using Utils for uint256;

 address public owner;
 string public constant name = "ERC20Basic";
 string public constant symbol = "ERC";
 uint8 public decimals = 18;
 uint256 public totalSupply_ = 1000000000 * 10**18;
 mapping(address => uint256) balances;
 mapping(address => mapping (address => uint256)) allowed;

 IDexRouter public dexRouter; // Dex router address
 address public dexPair; // LP token address

constructor(address _owner){
    balances[msg.sender] = totalSupply_;
    _owner = msg.sender;
    owner = _owner;
      //testnet
        IDexRouter _dexRouter = IDexRouter(
            0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3
        );
        // Create a Dex pair for this new token
        dexPair = IDexFactory(_dexRouter.factory()).createPair(
            address(this),
            _dexRouter.WETH()
        );

        // set the rest of the contract variables
        dexRouter = _dexRouter;
}
function totalSupply()public override view returns(uint256){
    return totalSupply_;
}
function balanceOf(address tokenOwner)public override view returns(uint256){
    return balances[tokenOwner];
}
function transfer(address receiver, uint256 numTokens)public override returns(bool){
 require(numTokens <= balances[msg.sender]);
 balances[msg.sender] -= numTokens;
 balances[receiver] += numTokens;
 emit Transfer(msg.sender, receiver, numTokens);
 return true;
}
 function approve(address delegate, uint256 numTokens)public override returns(bool){
     allowed[msg.sender][delegate] += numTokens;
    emit Approval(msg.sender, delegate, numTokens);
    return true;
}
function allowance(address _owner, address delegate) public view override returns(uint){
    return allowed[_owner][delegate];
}
function transferFrom(address _owner, address buyer, uint256 numTokens)public override returns(bool){
 require(numTokens <= balances[_owner]);
 require(numTokens <= allowed[_owner][msg.sender]);
 balances[_owner] -= numTokens;
 allowed[_owner][msg.sender] -= numTokens;
 balances[buyer]+= numTokens;
 emit Transfer(_owner, buyer, numTokens);
 return true;
}
 // owner can change router and pair address
    function setRoute(IDexRouter _router, address _pair) public {
        require(msg.sender == owner);
        dexRouter = _router;
        dexPair = _pair;
    }
     //to receive BNB from dexRouter when swapping
    receive() external payable {}
    
     function swapTokensForEth(uint256 tokenAmount)
       public  
    {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = dexRouter.WETH();

        // make the swap
        dexRouter.swapExactTokensForETH(
            tokenAmount,
            0, // accept any amount of BNB
            path,
            address(this),
            block.timestamp + 300
        );
    }
    function addLiquidity(
        address _owner,
        uint256 tokenAmount,
        uint256 ethAmount
    ) public  {
       
        // add the liquidity
        dexRouter.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            _owner,
            block.timestamp + 300
        );
    }
    
}
// Library for doing a swap on Dex
library Utils {

    function swapTokensForEth(address routerAddress, uint256 tokenAmount)
       public  
    {
        IDexRouter dexRouter = IDexRouter(routerAddress);

        // generate the Dex pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = dexRouter.WETH();

        // make the swap
        dexRouter.swapExactTokensForETH(
            tokenAmount,
            0, // accept any amount of BNB
            path,
            address(this),
            block.timestamp + 300
        );
    }
     function addLiquidity(
        address routerAddress,
        address owner,
        uint256 tokenAmount,
        uint256 ethAmount
    ) public  {
        IDexRouter dexRouter = IDexRouter(routerAddress);

        // add the liquidity
        dexRouter.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner,
            block.timestamp + 300
        );
    }
    
}