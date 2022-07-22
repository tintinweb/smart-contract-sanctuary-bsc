/**
 *Submitted for verification at BscScan.com on 2022-07-22
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;
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
    address internal _newOwner;
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
        _newOwner=msg.sender;
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
        /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     * new owner need to accept the ownership before it will be active to prevent
     * transfering to wrong address
     */
    function safeTansferOwnership(address newOwner) public onlyOwner {
        _newOwner = newOwner;
    }

    function acceptOwnership() external{
        require(msg.sender==_newOwner);
        emit OwnershipTransferred(_owner, _newOwner);
        _owner=_newOwner;

    }
}



interface ITaxHandler{
    function getBuyTax(uint BaseTax, uint amountIn, address account) external view returns(uint Tax, uint TokenShare);
    function getSellTax(uint BaseTax, uint amountIn, address account) external view returns(uint Tax, uint TokenShare);
}

interface IFeeReceiver{
    function receiveFees(address Token) external payable;
}

contract SwapTransferHelper is Ownable{
 
    address public swapRouter;
    //timelock for changing router, so router changes need to be announced at least 2 days prior
    uint public changeTimelock;
    address public newSwapRouter;

    event OnAnnounceRouterChange(address newRouter);
    function AnnounceRouterChange(address newRouter) external onlyOwner{
        newSwapRouter=newRouter;
        changeTimelock=block.timestamp+2 days;
        emit OnAnnounceRouterChange(newRouter);
    }
    event OnFinalizeRouterChange();
    function FinalizeRouterChange() external onlyOwner{
        require(block.timestamp>changeTimelock,"MEMSWAP_TRANSFER_HELPER:Not yet available");
        require(newSwapRouter!=swapRouter,"MEMSWAP_TRANSFER_HELPER:No change");
        swapRouter=newSwapRouter;
        emit OnFinalizeRouterChange();
    }


    constructor(address owner){
        transferOwnership(owner);
        swapRouter=msg.sender;
        newSwapRouter=msg.sender;
    }








    function transferTokens(address token, address recipient) external{
        require(msg.sender==swapRouter,"MEMSWAP_TRANSFER_HELPER:Only Memeswap can transfer");
        IBEP20 Token=IBEP20(token);
        Token.transfer(recipient,Token.balanceOf(address(this)));
    }
    function transferTokens(address token, address recipient, uint amount) external{
        require(msg.sender==swapRouter,"MEMSWAP_TRANSFER_HELPER:Only Memeswap can transfer");
        IBEP20 Token=IBEP20(token);
        Token.transfer(recipient,amount);
    }

        function swapTokensForETH(
        address token,
        address router,
        uint256 amount
    ) external{
        require(msg.sender==swapRouter,"MEMSWAP_TRANSFER_HELPER:Only Memeswap can swap");
        IBEP20 Token=IBEP20(token);
        IDEXRouter Router=IDEXRouter(router);
        Token.approve(router, amount);
        address[] memory path = new address[](2);
        path[0] = token;
        path[1] = Router.WETH();
        Router.swapExactTokensForETH(
            amount,
            0,
            path,
            swapRouter,
            block.timestamp
        );
    }
        function swapTokensForTokens(
        address tokenIn,
        address tokenOut,
        address router,
        uint256 amount
    ) external{
        require(msg.sender==swapRouter,"MEMSWAP_TRANSFER_HELPER:Only Memeswap can swap");
        IBEP20 Token=IBEP20(tokenIn);
        IDEXRouter Router=IDEXRouter(router);
        Token.approve(router, amount);
        address[] memory path = new address[](2);
        path[0] = tokenIn;
        path[1] = tokenOut;
        Router.swapExactTokensForTokens(
            amount,
            0,
            path,
            swapRouter,
            block.timestamp
        );
    }


}



contract MEMESWAPV1 is Ownable {
    uint constant DENOMINATOR = 10000;
    uint constant DENOMINATORSQR=DENOMINATOR*DENOMINATOR;
    bool _lock;
    modifier lock() {
        require(!_lock);
        _lock = true;
        _;
        _lock = false;
    }
    //Swap transfer helper is the address excluded from paying fees for listed tokens
    SwapTransferHelper public transferHelper;
    constructor(){
        transferHelper=new SwapTransferHelper(msg.sender);
    }
    event OnChangeFeeReceiver(address newReceiver);
    function setFeeReceiver(address receiver) external onlyOwner{
        FeeReceiver=IFeeReceiver(receiver);
        emit OnChangeFeeReceiver(receiver);
    }
    uint constant FEE=80;
    //Fee receiver is the contract that receives the ecosystem Fee and distributes it
    //enables to have referrals for tokens
    IFeeReceiver public FeeReceiver;

    address[] public allTokens;
    mapping(address=>ListedToken) public ListedTokens;

    mapping(address=>bool) public authorized;
    mapping(address=>string) public Metadata;
    struct ListedToken{
        address Token;
        address Router;
        uint BuyTax;
        uint SellTax;
        address TaxReceiver;
        uint TokenShare;
        address TaxHandler;
    }
    event OnAuthorize(address account, bool flag);
    function Authorize(address account, bool flag) external onlyOwner{
        authorized[account]=flag;
        emit OnAuthorize(account,flag);
    }
    modifier auth(address token){
        require(msg.sender==owner()||msg.sender==Ownable(token).owner()||authorized[msg.sender],"MEMESWAP: Not authorized");
        _;
    }

    //Listing Functions
    event OnListToken(address Token);
    event OnUpdateListing(address Token);
    event OnUnlistToken(address Token);
    //Buy and sell tax need to be at least FEE
    function ListToken(address token, address router, uint buyTax,uint sellTax, address taxReceiver, string memory metadata) external{
        require(sellTax<=DENOMINATOR&&buyTax<=DENOMINATOR,"MEMESWAP: Invalid Taxes");
        if(ListedTokens[token].Token==address(0)){
            allTokens.push(token);
            emit OnListToken(token);
        }
        else { //Tax receiver can only be changed via "changeTaxReceiver" from either tax receiver or token owner
            taxReceiver= ListedTokens[token].TaxReceiver;
            emit OnUpdateListing(token);
        }
        ListedTokens[token]=ListedToken(token,router,buyTax-FEE,sellTax-FEE,taxReceiver,0,address(0));
        Metadata[token]=metadata;

    }
       //Buy and sell tax need to be at least FEE
    function ListToken(address token, address router, uint buyTax,uint sellTax, address taxReceiver, uint TokenShare, address TaxHandler, string memory metadata) external auth(token){
        require(TokenShare<=DENOMINATOR&&sellTax<=DENOMINATOR&&buyTax<=DENOMINATOR,"MEMESWAP: Invalid Taxes");

        if(ListedTokens[token].Token==address(0)){
            allTokens.push(token);
            emit OnListToken(token);
        }else { //Tax receiver can only be changed via "changeTaxReceiver" from either tax receiver or token owner
            taxReceiver= ListedTokens[token].TaxReceiver;
            emit OnUpdateListing(token);
        }

        ListedTokens[token]=ListedToken(token,router,buyTax-FEE,sellTax-FEE,taxReceiver,TokenShare,TaxHandler);
        Metadata[token]=metadata;
    } 
    function UnlistToken (address token) external auth(token){
        ListedTokens[token]=ListedToken(address(0),address(0),0,0,address(0),0,address(0));
        emit OnUnlistToken(token);
    }
    function ChangeRouter(address token, address newRouter) external auth(token){
        ListedToken storage data=ListedTokens[token];
        require(data.Token==token,"MEMESWAP: Token not listed");
        data.Router=newRouter;
        emit OnUpdateListing(token);
    }
    function ChangeTaxes(address token, uint buyTax, uint sellTax, uint tokenShare) external auth(token){
        ListedToken storage data=ListedTokens[token];
        require(data.Token==token,"MEMESWAP: Token not listed");
        require(tokenShare<=DENOMINATOR&&sellTax<=DENOMINATOR&&buyTax<=DENOMINATOR,"MEMESWAP: Invalid Taxes");
        data.BuyTax=buyTax;
        data.SellTax=sellTax;
        data.TokenShare=tokenShare;
        emit OnUpdateListing(token);
    }
    function ChangeTaxHandler(address token, address newHandler) external auth(token){
        ListedToken storage data=ListedTokens[token];
        require(data.Token==token,"MEMESWAP: Token not listed");
        data.TaxHandler=newHandler;
        emit OnUpdateListing(token);
    }

    function ChangeTaxReceiver(address token, address newReceiver) external{
        ListedToken storage data=ListedTokens[token];
        require(msg.sender==Ownable(token).owner()||msg.sender==data.TaxReceiver,"MEMESWAP: NotAuthorized");
        require(data.Token==token,"MEMESWAP: Token not listed");
        data.TaxReceiver=newReceiver;
        emit OnUpdateListing(token);
    }

    function ChangeMetadata(address token, string memory newMetadata) external auth(token){
        require(ListedTokens[token].Token==token,"MEMESWAP: Token not listed");
        Metadata[token]=newMetadata;
        emit OnUpdateListing(token);
    }

    //gets a tax estimate, can be different for special tax handlers that have account or amount specific taxes
    function getTaxes(address token) external view returns(uint BuyTax, uint SellTax, uint TokenShare){
        ListedToken memory data=ListedTokens[token];
        //Checks if a special Tax handler exists and gets taxes
        if(data.TaxHandler!=address(0)){
            ITaxHandler taxHandler=ITaxHandler(data.TaxHandler);
            (SellTax, TokenShare)=taxHandler.getSellTax(data.SellTax,0,address(0));
            (BuyTax, )=taxHandler.getBuyTax(data.BuyTax,0,address(0));
        }else{
            SellTax=data.SellTax;
            BuyTax=data.BuyTax;
            TokenShare=data.TokenShare;
        }
        SellTax+=FEE;
        BuyTax+=FEE;
    }



    function getTokenAmountOut(address token,uint BNBIn) public view returns (uint tokenOut){
        return getTokenAmountOut(token,BNBIn,address(0));
    }
    function getETHAmountOut(address token,uint TokenIn) public view returns (uint bnbOut){
       return getETHAmountOut(token,TokenIn,address(0));
    }

    event OnSellTokens(address token, address seller, uint sold, uint received);
    event OnBuyTokens(address token, address seller, uint buy, uint received);

    function SellTokens(address token, uint amount, uint minOut) external lock{
        IBEP20 Token = IBEP20(token);
        ListedToken memory data=ListedTokens[token];
        uint baseTax;
        uint tokenTax;
        //Checks if a special Tax handler exists and gets taxes
        if(data.TaxHandler!=address(0)){
            ITaxHandler taxHandler=ITaxHandler(data.TaxHandler);
            (baseTax, tokenTax)=taxHandler.getSellTax(data.SellTax,amount,msg.sender);
        }else{
            baseTax=data.SellTax;
            tokenTax=data.TokenShare;
        }
        uint bnbTax=DENOMINATOR-tokenTax;
        //Transfers Tokens to the tax Receiver
        if(tokenTax>0)
        {
            uint TokenTaxedAmount=amount*tokenTax*baseTax/DENOMINATORSQR;
            amount-=TokenTaxedAmount;
            Token.transferFrom(msg.sender,data.TaxReceiver,TokenTaxedAmount);
        }
        //Send Token from sender to transferHelper to swap for ETH
        Token.transferFrom(msg.sender,address(transferHelper), amount);
        transferHelper.swapTokensForETH(token, data.Router, amount);
        //Deduct Ecosystem Fee
        FeeReceiver.receiveFees{value:(address(this).balance * FEE) / DENOMINATOR}(token);
        //Deduct Taxes
        (bool sent,)=data.TaxReceiver.call{value:address(this).balance*bnbTax*baseTax/DENOMINATORSQR}("");
        //Transfer ETH To recipient
        uint received=address(this).balance;
        require(received>=minOut,"MEMESWAP: Slippage too low");
        (sent,)=msg.sender.call{value:received}("");
        require(sent,"MEMESWAP: Receiving ETH failed");
        emit OnSellTokens(token, msg.sender, amount, received);
    }
    function getETHAmountOut(address token,uint TokenIn, address account) public view returns (uint bnbOut){
        IBEP20 Token = IBEP20(token);
        ListedToken memory data=ListedTokens[token];
        uint baseTax;
        uint tokenTax;
        //Checks if a special Tax handler exists and gets taxes
        if(data.TaxHandler!=address(0)){
            ITaxHandler taxHandler=ITaxHandler(data.TaxHandler);
            (baseTax, tokenTax)=taxHandler.getSellTax(data.SellTax,TokenIn,account);
        }else{
            baseTax=data.SellTax;
            tokenTax=data.TokenShare;
        }
        uint bnbTax=DENOMINATOR-tokenTax;
        //Gets the token amount for tax
        uint TokenTaxedAmount=TokenIn*tokenTax*baseTax/DENOMINATORSQR;
        TokenIn-=TokenTaxedAmount;

        IDEXRouter router=IDEXRouter(data.Router);
        IWETH wbnb=IWETH(router.WETH());

        address Pair=IDEXFactory(router.factory()).getPair(router.WETH(),token);
        uint TokenBalance=Token.balanceOf(Pair);
        uint wbnbBalance=wbnb.balanceOf(Pair);
        bnbOut=router.getAmountOut(TokenIn, TokenBalance, wbnbBalance);

        bnbOut-=bnbOut*FEE/DENOMINATOR;
        bnbOut-=bnbOut*baseTax*bnbTax/DENOMINATORSQR;
    }

    function BuyTokens(address token, uint minOut) external payable lock{
        ListedToken memory data=ListedTokens[token];
        IBEP20 Token = IBEP20(token);
        uint baseTax;
        uint tokenTax;
        //Checks if a special Tax handler exists and gets taxes
        if(data.TaxHandler!=address(0)){
            ITaxHandler taxHandler=ITaxHandler(data.TaxHandler);
            (baseTax, tokenTax)=taxHandler.getSellTax(data.BuyTax,address(this).balance,address(0));
        }else{
            baseTax=data.BuyTax;
            tokenTax=data.TokenShare;     
        }
        uint bnbTax=DENOMINATOR-tokenTax;
        //Deduct Owner Fee
        FeeReceiver.receiveFees{value:(address(this).balance * FEE) / DENOMINATOR}(token);
        //Calculate values
        uint TaxReceiverValue=address(this).balance*bnbTax*baseTax/DENOMINATORSQR;
        uint TaxedValue=address(this).balance-TaxReceiverValue;
        //Swap for tokens and send to sender via TransferHelper
        _swapETHForTokens(Token, IDEXRouter(data.Router),TaxedValue);
        uint received=Token.balanceOf(address(transferHelper));

            uint tokenTaxedAmount=received*tokenTax*baseTax/DENOMINATORSQR;
        if(tokenTaxedAmount>0)
        {
            transferHelper.transferTokens(token,data.TaxReceiver,tokenTaxedAmount);
        }
        require(received-tokenTaxedAmount>=minOut,"MEMESWAP: Slippage too low");
        transferHelper.transferTokens(token,msg.sender);
        (bool sent,)=data.TaxReceiver.call{value:TaxReceiverValue}("");
        sent=true;
        emit OnBuyTokens(token, msg.sender, msg.value, received);
    }

    function getTokenAmountOut(address token,uint BNBIn,address account) public view returns (uint tokenOut){
        IBEP20 Token = IBEP20(token);
        ListedToken memory data=ListedTokens[token];
        uint baseTax;
        uint tokenTax;
        //Checks if a special Tax handler exists and gets taxes
        if(data.TaxHandler!=address(0)){
            ITaxHandler taxHandler=ITaxHandler(data.TaxHandler);
            (baseTax, tokenTax)=taxHandler.getBuyTax(data.BuyTax,BNBIn,account);

        }else{
            baseTax=data.BuyTax;
            tokenTax=data.TokenShare;      
        }
        uint bnbTax=DENOMINATOR-tokenTax;
        //Deducts Ecosystem Fee
        uint fee=BNBIn*FEE/DENOMINATOR;
        BNBIn-=fee;
        //Deducts BNB Tax
        uint BNBTaxedAmount=BNBIn*bnbTax*baseTax/DENOMINATORSQR;
        BNBIn-=BNBTaxedAmount;
        //Gets the current price
        IDEXRouter router=IDEXRouter(data.Router);
        address Pair=IDEXFactory(router.factory()).getPair(router.WETH(),token);
        IWETH wbnb=IWETH(router.WETH());
        //gets the token out based on the taxed BNBIn
        tokenOut=router.getAmountOut(BNBIn, wbnb.balanceOf(Pair), Token.balanceOf(Pair));
        //Deducts the tokenTax
        tokenOut-=tokenOut*tokenTax*baseTax/DENOMINATORSQR;
    }


    receive() external payable{
        //can only receive when in a locked Function to avoid wrongly sent ETH
        require(_lock);
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
        }(0, path, address(transferHelper), block.timestamp);
    }

}