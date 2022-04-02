//import {SafeERC20, SafeMath, IERC20, Address} from "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
//import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
//import "@openzeppelin/contracts/utils/math/SafeMath.sol";
//import {Math} from "@openzeppelin/contracts/math/Math.sol";
import "./SafeMath.sol";
import "./IERC20.sol";
import "./IUniswapV2Router01.sol";
import "./ERC3156FlashBorrowerInterface.sol";
import "./ERC3156FlashLenderInterface.sol";
import "./IValas.sol";

interface Comptroller {
    function isMarketListed(address cTokenAddress) external view returns (bool);
}


contract borrow is ERC3156FlashBorrowerInterface {
    using SafeMath for uint256;

    /**
     * @notice C.R.E.A.M. comptroller address
     */
    address public comptroller;
    constructor(address _comptroller) {
        comptroller = _comptroller;
    }

    IERC20 constant valas = IERC20(0xB1EbdD56729940089Ecc3aD0BBEEB12b6842ea6F);
    address constant wbnb = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    IUniswapV2Router01 constant router = IUniswapV2Router01(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    IValas constant gauge = IValas(0x6925E78E906a9c226f0B1134DfD257E9818B921d);

    //Declare an Event
    event Profit(uint256 indexed profit);

    
    function getTokenOutPathV2(address _tokenIn, address _tokenOut) internal pure returns (address[] memory _path) {
        _path = new address[](2);
        _path[0] = _tokenIn;
        _path[1] = _tokenOut;
    }

    //WARNING. manipulatable and simple routing. Only use for safe functions
    function priceCheck(
        address start,
        address end,
        uint256 _amount
    ) public view returns (uint256) {
        if (_amount == 0) {
            return 0;
        }
        if (start == end) {
            return _amount;
        }
        uint256[] memory amounts = router.getAmountsOut(_amount, getTokenOutPathV2(start, end));
        return amounts[amounts.length - 1];
    }

    function _swapFromWithAmount(
        address _from,
        address _to,
        uint256 _amountIn,
        uint256 _amountOut
    ) internal returns (uint256) {
        IERC20(_from).approve(address(router), _amountIn);

        uint256[] memory amounts = router.swapExactTokensForTokens(
            _amountIn,
            _amountOut,
            getTokenOutPathV2(_from, _to),
            address(this),
            block.timestamp
        );

        return amounts[amounts.length - 1];
    }

    function _swapFrom(
        address _from,
        address _to,
        uint256 _amountIn
    ) internal returns (uint256) {
        uint256 amountOut = priceCheck(_from, _to, _amountIn);

        return _swapFromWithAmount(_from, _to, _amountIn, amountOut);
    }

    function _addLiquidity(
        uint256 minAmountValas, 
        uint256 minAmountEth
      ) internal returns (uint amountToken, uint amountETH, uint liquidity){
        return router.addLiquidityETH(address(valas), minAmountValas, minAmountValas, minAmountEth, address(this), 0);
      }

    function onFlashLoan(
        address initiator,
        address token,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) public override returns (bytes32){
        require(Comptroller(comptroller).isMarketListed(msg.sender), "untrusted message sender");
        require(initiator == address(this), "FlashBorrower: Untrusted loan initiator");
        (address borrowToken, uint256 borrowAmount) = abi.decode(data, (address, uint256));
        require(borrowToken == token, "encoded data (borrowToken) does not match");
        require(borrowAmount == amount, "encoded data (borrowAmount) does not match");
        uint256 totalDebt = amount.add(fee);
        IERC20(token).approve(msg.sender, totalDebt);

        //uint256 cost = priceCheck(token, address(valas), amount.div(2));
        _swapFrom(token, address(valas), amount.div(2));
        uint256 valBal = valas.balanceOf(address(this));
        uint256 bnbBal = address(this).balance;
        (uint amountToken, uint amountETH, uint liquidity) = _addLiquidity(valBal, bnbBal);

        uint256 buy = amountETH.mul(2);
        uint256 profit = gauge.buyBNB(buy);
        emit Profit(profit);
        return keccak256("ERC3156FlashBorrowerInterface.onFlashLoan");
    }

}