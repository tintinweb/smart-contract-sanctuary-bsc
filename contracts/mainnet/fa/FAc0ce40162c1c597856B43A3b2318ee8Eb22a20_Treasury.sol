/**
 *Submitted for verification at BscScan.com on 2022-08-13
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

interface IERC20 {
    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface ISwapRouter {
    function factory() external pure returns (address);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

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
interface ISwapFactory {
    function getPair(address tokenA, address tokenB) external returns (address pair);
}


abstract contract Ownable {
    address internal _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "!owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "new is 0");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface INFTDividend {
    function addTokenReward(uint256 property, uint256 rewardAmount) external;
}

interface IPresale {
    function invitors(address account) external view returns (address);
}

 contract Treasury is Ownable {


    ISwapRouter public _swapRouter;
    address public USDTAddress = address(0x55d398326f99059fF775485246999027B3197955);

    address public HYAddress;
    address public YDAddress;
    address public NLAddress;

    address public NLPair;



    uint256 private constant MAX = ~uint256(0);

    address public _nftAddress;


   

    constructor (
        address RouterAddress,
        address hyAddress, address ydAddress  , address nlAddress
    ) {
        HYAddress = hyAddress;
        YDAddress = ydAddress;
        NLAddress = nlAddress;


        ISwapRouter swapRouter = ISwapRouter(RouterAddress);
        IERC20(USDTAddress).approve(RouterAddress, MAX);
        IERC20(HYAddress).approve(RouterAddress, MAX);
        IERC20(YDAddress).approve(RouterAddress, MAX);
        IERC20(NLAddress).approve(RouterAddress, MAX);
        _swapRouter = swapRouter;

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        NLPair = swapFactory.getPair(NLAddress, USDTAddress);


    }

    function setNFTAddress(address nftAddress) external onlyOwner{
        _nftAddress = nftAddress;
    }


    function claimToken() public {
        uint256 HYBalance = IERC20(HYAddress).balanceOf(address(this));
        uint256 HYDecimal = IERC20(HYAddress).decimals();
        uint256 YDBalance = IERC20(YDAddress).balanceOf(address(this));
        uint256 YDDecimal = IERC20(YDAddress).decimals();
        uint256 NLBalance = IERC20(NLAddress).balanceOf(address(this));
        uint256 NLDecimal = IERC20(NLAddress).decimals();
        //最大执行量
        if(HYBalance> 100*10**HYDecimal){
            address[] memory path = new address[](2);
            path[0] = HYAddress;
            path[1] = USDTAddress;
            
            _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                HYBalance,
                0,
                path,
                address(this),
                block.timestamp+1800
            );
            uint256 usdtAmount = IERC20(USDTAddress).balanceOf(address(this));

            //1:2:2
            if(usdtAmount > 0){
                uint256 HJAmount = usdtAmount * 50  /300;
                uint256 ZSAmount = usdtAmount * 100 /300;
                uint256 ZZAmount = usdtAmount * 150 /300;
                IERC20(USDTAddress).transfer(_nftAddress,usdtAmount);
                INFTDividend(_nftAddress).addTokenReward(1, HJAmount);
                INFTDividend(_nftAddress).addTokenReward(2, ZSAmount);
                INFTDividend(_nftAddress).addTokenReward(3, ZZAmount);
                }

        }

         if(YDBalance> 1*10**YDDecimal){
            address[] memory path = new address[](2);
            path[0] = YDAddress;
            path[1] = USDTAddress;
            
            _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                YDBalance,
                0,
                path,
                address(this),
                block.timestamp
            );
            uint256 usdtAmount = IERC20(USDTAddress).balanceOf(address(this));
            //1:3:4
            if(usdtAmount > 0){
                uint256 HJAmount = usdtAmount * 125 /1000;
                uint256 ZSAmount = usdtAmount * 375 /1000;
                uint256 ZZAmount = usdtAmount * 500 /1000;
                IERC20(USDTAddress).transfer(_nftAddress,usdtAmount);
                INFTDividend(_nftAddress).addTokenReward(1, HJAmount);
                INFTDividend(_nftAddress).addTokenReward(2, ZSAmount);
                INFTDividend(_nftAddress).addTokenReward(3, ZZAmount);
                }

        }

        //最大执行量
        if(NLBalance> 10*10**NLDecimal){
            address[] memory path = new address[](2);
            path[0] = NLAddress;
            path[1] = USDTAddress;
            
            _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                NLBalance,
                0,
                path,
                address(this),
                block.timestamp
            );
            uint256 usdtAmount = IERC20(USDTAddress).balanceOf(address(this));
            //3:4:1:2
            if(usdtAmount > 0){
                uint256 HJAmount = usdtAmount * 10 /100;
                uint256 ZSAmount = usdtAmount * 30 /100;
                uint256 ZZAmount = usdtAmount * 40 /100;
                uint256 PairAmount = usdtAmount * 20 /100;
                IERC20(USDTAddress).transfer(_nftAddress,usdtAmount-PairAmount);
                IERC20(USDTAddress).transfer(NLPair,PairAmount);
                INFTDividend(_nftAddress).addTokenReward(1, HJAmount);
                INFTDividend(_nftAddress).addTokenReward(2, ZSAmount);
                INFTDividend(_nftAddress).addTokenReward(3, ZZAmount);
                }

        }
    }

    receive() external payable {}

   
}