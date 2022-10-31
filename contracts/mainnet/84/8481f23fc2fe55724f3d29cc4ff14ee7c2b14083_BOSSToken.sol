// SPDX-License-Identifier: MIT
pragma solidity  ^0.6.0;
import './SafeMath.sol';
import './IERC20.sol';
import './ERC20.sol';
import './Context.sol';
import './Ownable.sol';

interface IIdo {
    function  idoback(uint256 token0Amt , address wal) external   returns (uint256);
    function  getStartSellingTime() external view  returns (uint256);
    function  getTradeCooldown() external view  returns (uint256);
    function  getBuyburnRate() external view  returns (uint256);
    function  getSellburnRate() external view  returns (uint256);
    function  getTranburnRate() external view  returns (uint256);
    function  getFundAddress() external  view returns (address);
    function  getBwl(address _address) external  view returns (bool);
}
interface INftEx {

    function  getnft(uint256 token0Amt , address wal) external   returns (uint256);
}


interface IBossDao{
    function getRelations(address _address) external view returns(address[] memory);

}
interface IPancakeSwapRouter{
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

interface IPancakeSwapFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

contract  BOSSToken is ERC20("BOSS", "BOSS"), Ownable{
    using SafeMath for uint256;
    uint256 public constant maxSupply =  10**18 *21000000;

    uint256 public startSellingTime;

    uint256 public burnRate = 500;

    mapping(address => bool) public MarketMakerPairs;
    mapping(address => uint256) private lastTrade;
    uint256 public tradeCooldown = 1;
    address public pair;
    address public BACKADDR = 0x000000000000000000000000000000000000eFef;
    address public GETNFTADDR = 0x00000000000000000000000000000000000000Af;
    address public BOSS001;
    address public IDOBACK;
    address public INFT;
    IPancakeSwapRouter public router;
    address public    WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;


    constructor(address _IDOBACK,address _INFT,address _router,address _BOSS001) public  {

        router = IPancakeSwapRouter( _router);
        pair = IPancakeSwapFactory(router.factory()).createPair(
            WBNB,
            address(this)
        );
        MarketMakerPairs[pair] = true;
        IDOBACK = _IDOBACK;
        BOSS001 = _BOSS001;
        INFT = _INFT;

    }

    function mint(address _to, uint256 _amount) external  onlyOwner returns (bool) {

        if (_amount.add(totalSupply()) > maxSupply) {
            return false;
        }
        _mint(_to, _amount);
        return true;

    }



    function _transfer(address sender, address recipient, uint256 amount) internal virtual override {

        startSellingTime = IIdo(IDOBACK).getStartSellingTime();

        uint256 burnRate =  IIdo(IDOBACK).getTranburnRate();

        if(MarketMakerPairs[sender] && recipient!=IDOBACK && recipient!=owner())//buy
        {
            tradeCooldown =  IIdo(IDOBACK).getTradeCooldown();
            burnRate =  IIdo(IDOBACK).getBuyburnRate();
            require(startSellingTime>0&&block.timestamp>=startSellingTime, "can not buy now!");

        }

        if(MarketMakerPairs[recipient] && sender!=IDOBACK && sender!=owner())//sell
        {

             require(startSellingTime>0&&block.timestamp>=startSellingTime,"can not sell now!");
             require(lastTrade[sender] < (block.timestamp - tradeCooldown), string("No consecutive sells allowed. Please wait."));
             lastTrade[sender] = block.timestamp;
             burnRate =  IIdo(IDOBACK).getSellburnRate();
        }
        if(MarketMakerPairs[recipient] && sender==IDOBACK )//sell
        {
            burnRate = 0;

        }
        if(MarketMakerPairs[sender] && recipient==IDOBACK )//buy
        {
            burnRate = 0;
        }
        if(IIdo(IDOBACK).getBwl(sender) || IIdo(IDOBACK).getBwl(recipient))
        {
            burnRate = 0;
        }



        address _to = recipient;
        if(recipient ==  BACKADDR)//ido back
        {


            _to = IDOBACK;
            IIdo(IDOBACK).idoback(amount,sender);

        }
         if(recipient ==  GETNFTADDR)//get nfts
        {


            _to = INFT;
            INftEx(INFT).getnft(amount,sender);

        }
        uint256  burnAmt = amount.mul(burnRate).div(10000);

        if(MarketMakerPairs[sender])
        {
            super._transfer(sender, _to, amount);
        }
        else
        {
             amount = amount.sub(burnAmt);
             super._transfer(sender, _to, amount);

        }


        if(burnAmt>0)
        {

            //40 nft,60 ref
            address fundAddress =  IIdo(IDOBACK).getFundAddress();
            address user = sender;
            if(MarketMakerPairs[sender])
            {
               user = recipient;
            }
            address[] memory _parents = IBossDao(BOSS001).getRelations(user);
            uint256 _parentFee =   burnAmt.mul(60).div(100).div(30);
            for (uint8 i=0;i<_parents.length;i++){
                _parentFee =   burnAmt.mul(60).div(100).div(30);

                if(_parents[i] == address(0))
                {
                    _parents[i] = fundAddress;
                }

                if (i==0){
                    _parentFee =  burnAmt.mul(60).div(100).mul(50).div(100);

                }
                if(i==1){
                    _parentFee =  burnAmt.mul(60).div(100).div(6);
                }
                if(i==2){
                    _parentFee =  burnAmt.mul(60).div(100).div(10);
                }
                if(MarketMakerPairs[sender])
                {
                    super._transfer(_to, _parents[i], _parentFee);
                }
                else
                {
                     super._transfer(sender, _parents[i], _parentFee);
                }

            }
            if(MarketMakerPairs[sender])
            {
                super._transfer(_to, fundAddress, burnAmt.mul(40).div(100));
            }
            else
            {
                super._transfer(sender, fundAddress, burnAmt.mul(40).div(100));
            }
        }

    }

}