/**
 *Submitted for verification at BscScan.com on 2022-07-11
*/

/**
 *Submitted for verification at BscScan.com on 2022-07-11
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
interface IBEP20 {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function getOwner() external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address _owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface IWETH is IBEP20 {
    function deposit() external payable;

    function withdraw(uint256) external;
}

interface IDEXFactory {
    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);
}


interface IDEXRouter {
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

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

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

abstract contract Ownable {
    address internal _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract MEMESWAP is Ownable {
    uint16 constant DENOMINATOR = 10000;

    bool _lock;
    modifier lock() {
        require(!_lock);
        _lock = true;
        _;
        _lock = false;
    }


    function setFeeReceiver(address receiver) external onlyOwner{
        FeeWallet=receiver;
    }
    uint constant FEE=80;

    address public FeeWallet;
    function deductFee() private{
        (bool sent,)=FeeWallet.call{value:(address(this).balance * FEE) / DENOMINATOR}("");
        sent=true;
    }


    address[] public allTokens;
    mapping(address=>ListedToken) ListedTokens;
    struct ListedToken{
        address Token;
        address Router;
        uint BuyTax;
        uint SellTax;
        address TaxReceiver;
    }
    //Buy and sell tax need to be at least FEE
    function ListToken(address token, address router, uint buyTax,uint sellTax, address taxReceiver) external{
        require(msg.sender==owner()||msg.sender==Ownable(token).owner(),"MEMESWAP: Not Permitted");
        if(ListedTokens[token].Token==address(0))
            allTokens.push(token);
        ListedTokens[token]=ListedToken(token,router,buyTax-FEE,sellTax-FEE,taxReceiver);
    }



    function getTokenAmountOut(address token,uint BNBIn) public view returns (uint tokenOut){
        IBEP20 Token = IBEP20(token);
        ListedToken memory data=ListedTokens[token];
        IDEXRouter router=IDEXRouter(data.Router);
        address Pair=IDEXFactory(router.factory()).getPair(router.WETH(),token);
        IWETH wbnb=IWETH(router.WETH());
        uint TokenBalance=Token.balanceOf(Pair);
        uint wbnbBalance=wbnb.balanceOf(Pair);
        uint fee=BNBIn*FEE/DENOMINATOR;
        BNBIn-=fee;
        uint tax=BNBIn*data.BuyTax/DENOMINATOR;
        BNBIn-=tax;
        tokenOut=router.getAmountOut(BNBIn, wbnbBalance, TokenBalance);
    }

    function getETHAmountOut(address token,uint TokenIn) public view returns (uint bnbOut){
        IBEP20 Token = IBEP20(token);
        ListedToken memory data=ListedTokens[token];
        IDEXRouter router=IDEXRouter(data.Router);
        IWETH wbnb=IWETH(router.WETH());

        address Pair=IDEXFactory(router.factory()).getPair(router.WETH(),token);
        uint TokenBalance=Token.balanceOf(Pair);
        uint wbnbBalance=wbnb.balanceOf(Pair);
        bnbOut=router.getAmountOut(TokenIn, TokenBalance, wbnbBalance);
        uint fee=bnbOut*FEE/DENOMINATOR;
        bnbOut-=fee;
        uint tax=bnbOut*data.BuyTax/DENOMINATOR;
        bnbOut-=tax;
    }

    event OnSellTokens(address token, address seller, uint sold, uint received);
    event OnBuyTokens(address token, address seller, uint buy, uint received);
    function SellTokens(address token, uint amount, uint minOut) external lock{
        ListedToken memory data=ListedTokens[token];
        IBEP20 Token = IBEP20(token);
        Token.transferFrom(msg.sender,address(this), amount);
        _swapTokensForETH(Token, IDEXRouter(data.Router), amount);
        deductFee();
        (bool sent,)=data.TaxReceiver.call{value:address(this).balance*data.SellTax/DENOMINATOR}("");
        uint received=address(this).balance;
        require(received>=minOut,"MEMESWAP: Slippage too low");
        (sent,)=msg.sender.call{value:received}("");
        require(sent,"MEMESWAP: Receiving ETH failed");
        emit OnSellTokens(token, msg.sender, amount, received);
    }
    function BuyTokens(address token, uint minOut) external payable lock{
        ListedToken memory data=ListedTokens[token];
        IBEP20 Token = IBEP20(token);
        deductFee();
        (bool sent,)=data.TaxReceiver.call{value:address(this).balance*data.SellTax/DENOMINATOR}("");
        sent=true;
        _swapETHForTokens(Token, IDEXRouter(data.Router),address(this).balance);
        uint received=Token.balanceOf(address(this));
        require(received>=minOut,"MEMESWAP: Slippage too low");
        Token.transfer(msg.sender,received); 
        emit OnBuyTokens(token, msg.sender, msg.value, received);
    }
    






    function _swapTokensForETH(
        IBEP20 Token,
        IDEXRouter router,
        uint256 amount
    ) private {
        Token.approve(address(router), type(uint256).max);
        address[] memory path = new address[](2);
        path[0] = address(Token);
        path[1] = router.WETH();
        router.swapExactTokensForETH(
            amount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function _swapETHForTokens(
        IBEP20 Token,
        IDEXRouter router,
        uint256 amount
    ) private {
        address[] memory path = new address[](2);
        path[1] = address(Token);
        path[0] = router.WETH();
        router.swapExactETHForTokensSupportingFeeOnTransferTokens{
            value: amount
        }(0, path, address(this), block.timestamp);
    }

}