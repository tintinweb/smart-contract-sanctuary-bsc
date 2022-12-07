/**
 *Submitted for verification at BscScan.com on 2022-12-07
*/

pragma solidity ^0.8.7;

// SPDX-License-Identifier: Unlicensed

/**
 * Standard SafeMath
 */
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
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }
}


interface IDEXRouter {
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

interface Token {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function decimals() external pure returns (uint8);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
 }

contract CompetitionManager {
    using SafeMath for uint256;

    address internal owner;
    mapping (address => bool) internal authorizations;
    mapping (address => bool) internal processedTokens;
    bool inSwap;
    //address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    /**
     * Function modifier to require caller to be contract owner
     */
    modifier onlyOwner() {
        require(owner == msg.sender, "!OWNER"); _;
    }

    /**
     * Function modifier to require caller to be authorized
     */
    modifier authorized() {
        require(authorizations[msg.sender], "!AUTHORIZED"); _;
    }

    modifier lockTheSwap() { 
        inSwap = true; 
        _; inSwap = false;    
    }

    /**
     * Remove address' authorization. Owner only
     */
    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }

    /**
     * Authorize address. Owner only
     */
    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }


   // This function is required so that the contract can receive BNB from pancakeswap
    receive() external payable {}

    constructor (){
       owner = msg.sender; 
       authorizations[owner] = true;
    }

    function buyAndBurn(address routerAddress, address [] memory path,address tokenIn, address tokenOut, uint256 amountIn) public authorized lockTheSwap returns (bool) {
        
        IDEXRouter router  = IDEXRouter(routerAddress); 
        //address eth = router.WETH();
        //address[] memory path = new address[](2);
        
        //check BNB allowance.
        Token weth = Token(tokenIn);
        uint256 myAllowee = weth.allowance(address(this), routerAddress);
        if(myAllowee < amountIn){
        weth.approve(routerAddress, amountIn);
        }

        //buys token on the dex supplied.
        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amountIn}(
            0,
            path,
            address(this),
            (block.timestamp + (1000 *60 *5))
        );
           
        //now we transfer our tokens to the burn address.
        Token token = Token(tokenOut);
        uint256 myBal = token.balanceOf(address(this));
        token.transfer(DEAD, myBal);
        
        return true;
     }

    /**
     * Views BNB / ETH Balance sc.
     */     
    function getBalance() external view returns(uint256){
        return address(this).balance;
    }

    /**
     * Views BNB / ETH Balance sc.
     */     
    function getBalanceOfToken(address contractAddress) external view returns(uint256){
        Token token = Token(contractAddress);
        uint256 myBal = token.balanceOf(address(this));
        uint256 _decimals = token.decimals();
        return (myBal.div(10**_decimals));
    }

    /**
     * Checks if wallet is authorised. Owner only
     */
    function isAuthorize(address adr) public view authorized returns(bool){
        return authorizations[adr];
    }

    /**
     * checks Owner
     */
    function getOwner() public view authorized returns(address){
        return owner;
    }

    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(owner).transfer(amountBNB * amountPercentage / 100);
    }

}