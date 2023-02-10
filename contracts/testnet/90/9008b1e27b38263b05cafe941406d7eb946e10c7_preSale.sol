/**
 *Submitted for verification at BscScan.com on 2023-02-10
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;




interface IBEP20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external;
    function transfer(address to, uint value) external;
    function transferFrom(address from, address to, uint value) external;
    function burn(uint256 amount) external;
}

interface IPreSale{

    // function owner() external view returns(address);
    function tokenOwner() external view returns(address);
    // function deployer() external view returns(address);
    function token() external view returns(address);
    // function busd() external view returns(address);

    function tokenPrice() external view returns(uint256);
    function preSaleTime() external view returns(uint256);
    function claimTime() external view returns(uint256);
    // function minAmount() external view returns(uint256);
    // function maxAmount() external view returns(uint256);
    // function softCap() external view returns(uint256);
    // function hardCap() external view returns(uint256);
    // function listingPrice() external view returns(uint256);
    // function liquidityPercent() external view returns(uint256);

    // function allow() external view returns(bool);

    function initialize(
       uint256 _tokenPrice,
        uint256 _presaleStartTime,
        uint256 _presaleEndTime,
        address _routerAddress
    ) external ; 
}


interface IPancakeRouter01 {
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
}

interface IPancakeRouter02 is IPancakeRouter01 {
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
     function swapTokensForETH(uint amountOut, 
     uint amountInMax, 
     address[] calldata path, 
     address to, 
     uint deadline)
    external
    returns (uint[] memory amounts);
}


abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    modifier isHuman() {
        require(tx.origin == msg.sender, "sorry humans only");
        _;
    }
}





interface IPancakeswapV2Factory {
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

contract preSale is ReentrancyGuard {

    // address payable public admin;
    address payable public tokenOwner;
    address public marketingAddress;

    IBEP20 public pair;
    
    IBEP20 public token;
    IPancakeRouter02 public routerAddress;

    
    uint256 public tokenPrice;
    uint256 public preSaleStartTime;
    uint256 public preSaleEndTime;
   
    uint256 public soldTokens;
    uint256 public totalUsers;
    uint256 public amountRaised;

    uint256 public buyTaxFee = 5; // 5 percent of the total buying amount
    uint256 public sellTaxFee = 5; // 5 percent of the total selling amount
    uint256 public marketingFee = 70; //70 percent of the transfer fee
    uint256 public lpFee = 10; //10 percent of the transfer fee
    uint256 public burnFee = 10; //10 percent of the transfer fee
    uint256 private liquidity;
    uint256 public totalTax;
    uint256 public buyTax;
    uint256 public sellTax;
    uint256 public percentDivider = 100;

    // uint256 public totalSupply = token.totalSupply();
    // uint256 public stage1Supply;
    // uint256 public stage2Supply;
    // uint256 public stage3Supply;
    // uint256 public stage4Supply;
    // uint256 public stage1Price;
    // uint256 public stage2Price;
    // uint256 public stage3Price;
    // uint256 public stage4Price;
    bool public tradingEnabled = false;
    bool public swapEnabled = false;
    bool public allow;
    bool public canClaim;

    mapping(address => uint256) public tokenBalance;
    mapping(address => uint256) public bnbBalance;
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private _isWhitelisted;


    modifier onlyTokenOwner() {
        require(msg.sender == tokenOwner, "Not a token owner");
        _;
    }
    modifier allowed() {
        require(allow == true, "MetaStarter: Not allowed");
        _;
    }

    event tokenBought(
        address indexed user,
        uint256 indexed numberOfTokens,
        uint256 indexed amountBusd
    );

    event tokenClaimed(address indexed user, uint256 indexed numberOfTokens);

    event bnbClaimed(address indexed user, uint256 indexed balance);

    event tokenUnSold(address indexed user, uint256 indexed numberOfTokens);
    event TOKEN_SOLD(address indexed user, uint256 amount, address _token);

    constructor(address _marketingAddress) {
        allow = true;
        tokenOwner = payable(msg.sender);
        marketingAddress = _marketingAddress;
        _isExcludedFromFee[tokenOwner] = true;
        _isExcludedFromFee[address(this)] = true;
        _isWhitelisted[tokenOwner] = true;
        _isWhitelisted[address(this)] = true;
    }

    // called once by the deployer contract at time of deployment
    function initializePresale(
        IBEP20 _token,
        uint256 _tokenPrice,
        // uint256[8] memory values,
        // uint256 _presaleStartTime,
        uint256 _presaleEndTime,
        address _routerAddress
    ) external onlyTokenOwner {
        
        token = _token;
        tokenPrice = _tokenPrice;
        preSaleStartTime = block.timestamp;
        preSaleEndTime = _presaleEndTime +block.timestamp;
        routerAddress = IPancakeRouter02(_routerAddress);
        // stage1Supply = values[0];
        // stage2Supply = values[1];
        // stage3Supply = values[2];
        // stage4Supply = values[3];
        // stage1Price = values[4];
        // stage2Price = values[5];
        // stage3Price = values[6];
        // stage4Price = values[7];

    }

    receive() external payable {}

    // to buy token during preSale time

    function buyToken() public payable allowed isHuman{
        require(tradingEnabled, "Contact owner : Trading not enabled yet");
        require(block.timestamp < preSaleEndTime, "Presale Time over"); // time check
        require(
            block.timestamp > preSaleStartTime,
            "Presale Time not Started yet"
        ); 
        uint256 numberOfTokens = bnbToToken(msg.value);
        
        if (tokenBalance[msg.sender] == 0) {
            totalUsers++;
        } 
        if(_isExcludedFromFee[msg.sender]){
           tokenBalance[msg.sender] = tokenBalance[msg.sender] + (numberOfTokens);
           bnbBalance[msg.sender] = bnbBalance[msg.sender]+(
            msg.value); 
        }
        else{
            uint256 tokensToTransfer =  numberOfTokens - ((numberOfTokens * buyTaxFee)/percentDivider);
            tokenBalance[msg.sender] = tokenBalance[msg.sender] + tokensToTransfer;
            bnbBalance[msg.sender] = bnbBalance[msg.sender] + (
            msg.value);
            buyTax += (numberOfTokens * buyTaxFee)/percentDivider;
            totalTax += buyTax;
            // uint256 tax = (numberOfTokens * buyTaxFee)/percentDivider;
            // token.transfer(marketingAddress, ((tax * marketingFee)/percentDivider));
            // token.transfer(address(0), ((tax * burnFee)/percentDivider));
            // liquidity += (tax * lpFee)/percentDivider;

        }
        
        soldTokens = soldTokens + (numberOfTokens);
        amountRaised = amountRaised + (msg.value);

        emit tokenBought(msg.sender, numberOfTokens, msg.value);
    }
       // to sell token during POOL time with BNB

    function sellToken(uint256 _amount) public allowed isHuman {
        // require(CanSell == true, "POOL: Can't sell token");
        
        token.transferFrom(msg.sender, address(this), _amount);
        if(_isExcludedFromFee[msg.sender]){
        uint256 amount = tokenToBnb(_amount);
        require(amount <= address(this).balance, "POOL: Not enough BNB");
        payable(msg.sender).transfer(amount);
        bnbBalance[msg.sender] = bnbBalance[msg.sender]  - amount;
        
        }
        else{
            uint256 _tokensToSell = _amount - ((_amount * sellTaxFee)/percentDivider);
            uint256 amount = tokenToBnb(_tokensToSell);
            require(amount <= address(this).balance, "POOL: Not enough BNB");
            payable(msg.sender).transfer(amount);
            sellTax += (_amount * sellTaxFee)/percentDivider;
            totalTax += sellTax;
            bnbBalance[msg.sender] = bnbBalance[msg.sender]  - amount;

            // uint256 tax = (_amount * sellTaxFee)/percentDivider;
            // token.transfer(marketingAddress, ((tax * marketingFee)/percentDivider));
            // token.transfer(address(0), ((tax * burnFee)/percentDivider));
            // liquidity += (tax * lpFee)/percentDivider;
        }
        
       tokenBalance[msg.sender] = tokenBalance[msg.sender] - _amount;
            // bnbBalance[msg.sender] = bnbBalance[msg.sender] - (
            // tokenToBnb(_amount));

        emit TOKEN_SOLD(msg.sender, _amount, address(token));
    }


    function claimTokens() public allowed isHuman {
        require(
            block.timestamp > preSaleEndTime,
            "Presale not over yet"
        );
        require(canClaim == true, "Pool not initialized yet");
 
            uint256 numberOfTokens = tokenBalance[msg.sender];
            require(numberOfTokens > 0, " Zero balance");

            token.transfer(msg.sender, numberOfTokens);
            tokenBalance[msg.sender] = 0;
            emit tokenClaimed(msg.sender, numberOfTokens);
        
    }

    function initializePool() public onlyTokenOwner allowed isHuman {
        require(
            block.timestamp > preSaleEndTime,
            "PreSale not over yet"
        );
            // totalTax += (buyTax + sellTax);
            // token.transfer(marketingAddress, ((totalTax * marketingFee)/percentDivider));
            // token.transfer(address(0), ((totalTax * burnFee)/percentDivider));
            liquidity += (totalTax * lpFee)/percentDivider;
        // if (amountRaised > softCap) {
            uint256 bnbAmountForLiquidity = (amountRaised * lpFee)/percentDivider;
            uint256 tokenAmountForLiquidity = liquidity;
            uint256 fee = (amountRaised *  marketingFee)/percentDivider;
            token.approve(address(routerAddress), tokenAmountForLiquidity);
            addLiquidity(tokenAmountForLiquidity, bnbAmountForLiquidity);
            pair = IBEP20(
                IPancakeswapV2Factory(address(routerAddress.factory())).getPair(
                    address(token),
                    routerAddress.WETH()
                )
            );
            // liquidityunLocktime = block.timestamp.add(liquiditylockduration);
            payable(marketingAddress).transfer(fee);
            amountRaised -= (bnbAmountForLiquidity + fee);
            buyTokens(amountRaised, address(this));
            token.transfer(marketingAddress, ((totalTax * marketingFee)/percentDivider));
            token.transfer(address(0), ((totalTax * burnFee)/percentDivider));
            canClaim = true;
            // nativetoken.burn(nativetoken.balanceOf(address(this)));
            // admin.transfer(amountRaised.mul(adminFeePercent).div(100));
            // tokenOwner.transfer(getContractBnbBalance().sub(refamountRaised));
            // uint256 refund = getContractTokenBalance().sub(soldTokens);
           
        // } else {
        //     canClaim = true;
        //     token.transfer(tokenOwner, getContractTokenBalance());

        //     emit tokenUnSold(tokenOwner, getContractBnbBalance());
        // }
    }
      function swapTokensForEth( uint256 tokenAmount)
        external onlyTokenOwner allowed isHuman
    {
        require(swapEnabled, "Swap doesn't enabled yet");
        IPancakeRouter02 pancakeRouter = IPancakeRouter02(routerAddress);

        // generate the Dex pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(token);
        path[1] = pancakeRouter.WETH();

        // make the swap
        pancakeRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of BNB
            path,
            address(this),
            block.timestamp + 360
        );
    }
    //   function swapEthForExactTokens()
    //     external payable onlyTokenOwner
    // {
    //     IDexRouter dexRouter = IDexRouter(routerAddress);

    //     // generate the Dex pair path of token -> weth
    //     address[] memory path = new address[](2);
    //     path[0] = dexRouter.WETH();
    //     path[1] = token;

    //     // make the swap
    //     dexRouter.swapExactETHForTokensSupportingFeeOnTransferTokens(
    //         0, // accept any amount of token
    //         path,
    //         address(this),
    //         block.timestamp + 300
    //     );
    // }
    function enableTradingAndSwapping(bool _enable)external  onlyTokenOwner{
           tradingEnabled = _enable;
           swapEnabled = _enable;

    }
     function updateSwapEnabled(bool enabled) external onlyTokenOwner {
        swapEnabled = enabled;
    }


    function unlocklptokens() external onlyTokenOwner {
        // require(
        //     block.timestamp > liquidityunLocktime,
        //     "MetaStarter: Liquidity lock not over yet"
        // );
        pair.transfer(tokenOwner, pair.balanceOf(address(this)));
    }

    function addLiquidity(uint256 tokenAmount, uint256 bnbAmount) internal {
        IPancakeRouter02 pancakeRouter = IPancakeRouter02(routerAddress);

        // add the liquidity
        pancakeRouter.addLiquidityETH{value: bnbAmount}(
            address(token),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(this),
            block.timestamp + 360
        );
    }

    function buyTokens(uint256 amount, address to) internal {
        address[] memory path = new address[](2);
        path[0] = routerAddress.WETH();
        path[1] = address(token);

        routerAddress.swapExactETHForTokensSupportingFeeOnTransferTokens{
            value: amount
        }(0, path, to, block.timestamp);
    }

    // to check number of token for buying
    function bnbToToken(uint256 _amount) public view returns (uint256) {
        uint256 numberOfTokens = (_amount * tokenPrice * percentDivider)/ 1 ether;
        // uint256 numberOfTokens = _amount.mul(tokenPrice).mul(1000).div(1 ether);
        return (numberOfTokens * 10**(token.decimals())) / percentDivider;
    }
     // to check number of token for given TOKEN
    function tokenToBnb(uint256 _amount) public view returns (uint256) {
        uint256 _tokenToBnb = (_amount * (1 ether)) /
            (tokenPrice) / 10**(token.decimals());
        return _tokenToBnb;
    }

    // to calculate number of tokens for listing price
    // function listingTokens(uint256 _amount) public view returns (uint256) {
    //     uint256 numberOfTokens = _amount.mul(listingPrice).mul(1000).div(
    //         1 ether
    //     );
    //     return numberOfTokens.mul(10**(token.decimals())).div(1000);
    // }

     function excludeFromFee(address account) external onlyTokenOwner {
        _isExcludedFromFee[account] = true;
    }

    function whiteList(address[] memory accounts) external onlyTokenOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            _isWhitelisted[accounts[i]] = true;
        }
    }
     function removeWhitelist(address[] memory accounts) external onlyTokenOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            _isWhitelisted[accounts[i]] = false;
        }
    }

    function includeInFee(address account) external onlyTokenOwner {
        _isExcludedFromFee[account] = false;
    }
    function changeMarketingAddress(address _newMarketingAddress) external onlyTokenOwner{
        marketingAddress = _newMarketingAddress;
    }
    function changeMarketingFee(uint256 _newMarketingFee)external onlyTokenOwner{
        marketingFee = _newMarketingFee;
    }
    function changeLpFee(uint256 _newLpFee)external onlyTokenOwner{
        lpFee = _newLpFee;
    }
    function changeBurnFee(uint256 _newBurnFee)external onlyTokenOwner{
        burnFee = _newBurnFee;
    }
    // to check contribution
    function userContribution(address _user) public view returns (uint256) {
        return bnbBalance[_user];
    }
    function withdrawStuckBalance()external onlyTokenOwner{
        require(address(this).balance > 0, "Not enough balance to withdraw");
        payable(msg.sender).transfer(address(this).balance);
        emit bnbClaimed(msg.sender, address(this).balance);
    }
    function withdrawStuckTokens()external onlyTokenOwner{
        require(token.balanceOf(address(this)) > 0, "Not enough balance to withdraw");
        token.transfer(msg.sender,token.balanceOf(address(this)));
        emit tokenUnSold(tokenOwner,token.balanceOf(address(this)));

    }

    // to check token balance of user
    function userTokenBalance(address _user) public view returns (uint256) {
        return tokenBalance[_user];
    }
    function getContractBnbBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getContractTokenBalance() public view returns (uint256) {
        return token.balanceOf(address(this));
    }
}