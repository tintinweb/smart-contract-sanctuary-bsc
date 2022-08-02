/**
 *Submitted for verification at BscScan.com on 2022-08-02
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

interface ITracker {    
    function shareDividends(uint256 tokenAmount) external;
}

interface IERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);


    

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return (msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; 
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;
    mapping (address => bool) internal authorizations;


    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
     constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        authorizations[_owner] = true;
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
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    //Locks the contract for owner for the amount of time provided (seconds)
    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = block.timestamp + time;
        emit OwnershipTransferred(_owner, address(0));
    }
    
    //Unlocks the contract for owner when _lockTime is exceeds
    function unlock() public virtual {
        require(_previousOwner == msg.sender, "You don't have permission to unlock");
        require(block.timestamp> _lockTime , "Contract is still locked");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }

     //Modifier to require caller to be authorized
    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
    }

    //Authorize address.
    function authorize(address account) public onlyOwner {
        authorizations[account] = true;
    }

    // Remove address' authorization.
    function unauthorize(address account) public onlyOwner {
        authorizations[account] = false;
    }

    /**
     * Return address' authorization status
     */
    function isAuthorized(address account) public view returns (bool) {
        return authorizations[account];
    }
}

interface IUniswapV2Router01 {
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



// pragma solidity >=0.6.2;

interface IUniswapV2Router02 is IUniswapV2Router01 {
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
contract SaviorSwap is Ownable{
    
    address public karmaToken = 0x998A2458EB987cAB114ff13a47d05E78Dc950CB0;
    uint8 public karmaDecimals = 18;
    address public karmaTracker = 0xa75485196ca5dB8E32a771AbD4E493C7865730eA; 
    address public sgcToken = 0x6E2bA8115392fA84A80daEDa8bcB8a6172beb009;

    address constant private  DEAD = 0x000000000000000000000000000000000000dEaD;
    address private constant BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;

    // Distributions
    uint8 marketingDistribution = 10;
    uint8 sgcDistribution = 50;
    uint8 karmaBurnDistribution = 15;
    uint8 karmaBuyBackDistribution = 15;
    uint8 karmaAddLiquidityDistribution = 10;

    IUniswapV2Router02 public uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);



    mapping(address => mapping(address => uint256)) public tokenBalances; // Nbr Karmas sent by wallet address by token address
    mapping(address => uint256) public totalTokensReceived; // Nbr tokens received by token address
    mapping(address => uint256) public totalKarmaTokensSent; // Nbr total Karmas sent by token address
    uint256 public totalSgcDistributed;
    uint256 public totalKarmaBurnt;
    uint256 public totalKarmaBuybacked;
    uint256 public minContribution = 1;
    uint256 public maxContribution = 10**8*10**18; // 100M KARMAs
    uint256 public hardcap = 10**8*10**18; // 100M KARMAs

    address public tokenOfTheWeek;
    string public tokenOfTheWeekLogoUrl;
    uint256 public rate; // 1MM = 1 KARMA

    address payable marketingWallet = payable(0x99850e192D01BE4eE8D9614Be5295310ffC39aF7);

    bool private _isPaused = false;
    bool private _isSelling = false;

    event UniswapV2RouterUpdated(address indexed newAddress, address indexed oldAddress);
    event Swap(address indexed sender, address indexed tokenOfTheWeek, uint256 tokenAmountReceived, uint256 karmaTokenAmountSent);
    event ChangeTokenOfTheWeek(address indexed newToken, address indexed oldToken);
    event Paused();
    event Unpaused();
    event MarketingWalletUpdated(address indexed newMarketingWallet, address indexed oldMarketingWallet);
    event Burn(uint256 amount);



    function exchange(uint256 amount) external {
        require(!_isPaused, "Savior: The exchange system is currently paused");
        require(!_isSelling, "Savior: The contract is selling and distributing. Please, retry in few seconds");
        address sender = _msgSender();
        uint8 tokenOfTheWeekDecimals = IERC20(tokenOfTheWeek).decimals();

        uint256 karmaAmountToSend = amount*rate*10**karmaDecimals/10**tokenOfTheWeekDecimals/1_000_000_000; //amount/tokenOfTheWeekDecimals * rate/1_000_000_000 * karmaDecimals;
        require(tokenBalances[sender][tokenOfTheWeek]+karmaAmountToSend >= minContribution,"Savior: You don't reach the minimum contribution limit. Please send more tokens");
        require(tokenBalances[sender][tokenOfTheWeek]+karmaAmountToSend <= maxContribution, "Savior: You have reached the maximum contribution limit. Please wait for the next token");
        require(totalKarmaTokensSent[tokenOfTheWeek] + karmaAmountToSend <= hardcap, "Savior: The hardcap has been reached. Please wait the next token");

        tokenBalances[sender][tokenOfTheWeek]+=karmaAmountToSend;
        totalTokensReceived[tokenOfTheWeek]+=amount;
        totalKarmaTokensSent[tokenOfTheWeek]+=karmaAmountToSend;

        IERC20(tokenOfTheWeek).transferFrom(sender,address(this),amount);
        IERC20(karmaToken).transfer(sender, karmaAmountToSend);

        emit Swap(sender,tokenOfTheWeek,amount,karmaAmountToSend);

    }
        receive() external payable {
  	}
    
    function updateKarmaToken(address newKarmaToken) external onlyOwner {
        require(karmaToken != newKarmaToken, "Savior: The new address is the same as the old one");
        karmaToken = newKarmaToken;
    }

    function updateSgcToken(address newSgcToken) external onlyOwner {
        require(sgcToken != newSgcToken, "Savior: The new address is the same as the old one");
        sgcToken = newSgcToken;
    }
    function updateKarmaTracker(address newTracker) external onlyOwner {
        require(karmaTracker != newTracker, "Savior: The new address is the same as the old one");
        karmaTracker = newTracker;
    }

    function updateKarmaDecimals(uint8 newKarmaDecimals) external onlyOwner {
        require(karmaDecimals != newKarmaDecimals, "Savior: The new decimals are the same as the old ones");
        karmaDecimals = newKarmaDecimals;
    }

    function updateTokenOfTheWeek(address newTokenAddress, uint256 newRate, string memory newTokenOfTheWeekLogoUrl ) external onlyOwner {
        require(tokenOfTheWeek != newTokenAddress, "Savior: The new address is the same as the old one");
        require(newRate > 0, "Savior: The new rate must be greater than 0");
        emit ChangeTokenOfTheWeek(newTokenAddress,tokenOfTheWeek);
        tokenOfTheWeek = newTokenAddress;
        rate = newRate;
        tokenOfTheWeekLogoUrl = newTokenOfTheWeekLogoUrl;
    }

    function updateRate(uint256 newRate) external onlyOwner {
        require(rate != newRate, "Savior: The new rate is the same as the old one");
        require(newRate > 0, "Savior: The new rate must be greater than 0");
        rate = newRate;
    }

    function updateTokenOfTheWeekLogoUrl(string memory newTokenOfTheWeekLogoUrl) external onlyOwner {
        require(keccak256(bytes(tokenOfTheWeekLogoUrl)) != keccak256(bytes(newTokenOfTheWeekLogoUrl)), "Savior: The new logo url is the same as the old one");
        tokenOfTheWeekLogoUrl = newTokenOfTheWeekLogoUrl;
    }

    function updateMinContribution(uint256 newMinContribution) external onlyOwner {
        require(minContribution != newMinContribution, "Savior: The new min contribution is the same as the old one");
        require(newMinContribution <= maxContribution, "Savior: The new min contribution must be lower than the max contribution");
        minContribution = newMinContribution;
    }

    function updateMaxContribution(uint256 newMaxContribution) external onlyOwner {
        require(maxContribution != newMaxContribution, "Savior: The new max contribution is the same as the old one");
        require(newMaxContribution >= minContribution, "Savior: The new max contribution mist be greater than the min contribution");
        maxContribution = newMaxContribution;
    }

    function updateHardcap(uint256 newHardcap) external onlyOwner {
        require(hardcap != newHardcap, "Savior: The new hardcap is the same as the old one");
        hardcap = newHardcap;
    }

    function updateUniswapV2Router(address newAddress) external onlyOwner {
        require(newAddress != address(uniswapV2Router), "Savior: The router has already that address");
        emit UniswapV2RouterUpdated(newAddress, address(uniswapV2Router));
        uniswapV2Router = IUniswapV2Router02(newAddress);
    }

    function updateMarketingWallet(address payable newWallet) external onlyOwner {
        require(newWallet != marketingWallet, "Savior: The marketing wallet has already that address");
        emit MarketingWalletUpdated(newWallet,marketingWallet);
         marketingWallet = newWallet;
    }

    function updateDistributionPercents(uint8 newMarketingDistribution, uint8 newSgcDistribution, uint8 newKarmaBurnDistribution,
    uint8 newKarmaBuyBackDistribution, uint8 newKarmaAddLiquidityDistribution) external onlyOwner {
    require(newMarketingDistribution + newSgcDistribution + newKarmaBurnDistribution + newKarmaBuyBackDistribution + newKarmaAddLiquidityDistribution == 100, "Savior: Total percents must be equal to 100");
     marketingDistribution = newMarketingDistribution;
     sgcDistribution = newSgcDistribution;
     karmaBurnDistribution = newKarmaBurnDistribution;
     karmaBuyBackDistribution = newKarmaBuyBackDistribution;
     karmaAddLiquidityDistribution = newKarmaAddLiquidityDistribution;
    }

    function getStuckBNBs(address payable to) external onlyOwner {
        require(address(this).balance > 0, "Savior: There are no BNBs in the contract");
        to.transfer(address(this).balance);
    } 

    function getStuckTokens(address to, address tokenAddress, uint256 amount) external onlyOwner {
        require(IERC20(tokenAddress).balanceOf(address(this)) > 0, "Savior: There are no tokens in the contract");
        IERC20(tokenAddress).transfer(to,amount);
    }

    // BNB = 0
    // BUSD = 1
    function sellAndDistribute(address tokenAddress, uint8 sellingPercent, uint8 tokenPairedCode) external onlyOwner{
        _isSelling = true;
        uint256 tokenAmount = IERC20(tokenAddress).balanceOf(address(this));
        require(tokenAmount > 0, "Savior: There are no tokens in the contract");

        //1. Get BNBs based on tokens received
        uint256 tokenAmountToSell = tokenAmount * sellingPercent / 100;
        uint256 initialBnbBalance = address(this).balance;
        swapTokensForBNBOrBUSD(tokenAddress,tokenAmountToSell,tokenPairedCode);
        uint256 newBnbBalance = address(this).balance - initialBnbBalance;

        // 2. Buy and distribute SGCs
        uint256 sgcAmount = newBnbBalance * sgcDistribution / 100;
        if(sgcAmount > 0) {
        uint256 initialSgcBalance = IERC20(sgcToken).balanceOf(address(this));
        swapBNBForTokens(sgcAmount,sgcToken);
        uint256 newSgcBalance = IERC20(sgcToken).balanceOf(address(this)) - initialSgcBalance;

        (bool success) = IERC20(sgcToken).transfer(address(karmaTracker), newSgcBalance);
        if(success) {
            ITracker(karmaToken).shareDividends(newSgcBalance);
        }
        else require(false, "Something went wrong while sending SGCs to tracker");
        }
        // 3. Add liquidity to karma pool
        uint256 liquidityAmount = newBnbBalance * karmaAddLiquidityDistribution / 100;
        if(liquidityAmount > 0) addLiquidity(liquidityAmount);

        // 4. Buy and burn Karmas
        uint8 totalKarmaDistribution = karmaBurnDistribution + karmaBuyBackDistribution;
        uint256 karmaAmount = newBnbBalance * totalKarmaDistribution / 100;
        if(karmaAmount > 0) {
        uint256 initialKarmaBalance = IERC20(karmaToken).balanceOf(address(this));
        swapBNBForTokens(karmaAmount,karmaToken);
        uint256 newKarmaBalance = IERC20(karmaToken).balanceOf(address(this)) - initialKarmaBalance;
        uint256 burntKarmaAmount = newKarmaBalance * karmaBurnDistribution / totalKarmaDistribution;
        IERC20(karmaToken).transfer(DEAD, burntKarmaAmount);
        emit Burn(burntKarmaAmount);
        }

        // The rest of the Karma tokens are kept in contract

        // 5. Send BNBs to marketing
        uint256 marketingAmount = address(this).balance - initialBnbBalance;
        if(marketingAmount > 0) marketingWallet.transfer(marketingAmount);
        _isSelling = false;

    }

    function addLiquidity(uint256 bnbAmount) private {
        // approve token transfer to cover all possible scenarios
        IERC20(karmaToken).approve(address(uniswapV2Router), IERC20(karmaToken).totalSupply());

        // add the liquidity
        uniswapV2Router.addLiquidityETH{value: bnbAmount}(
            karmaToken,
            IERC20(karmaToken).balanceOf(address(this)),
            0,
            0, 
            owner(),
            block.timestamp
        );
        
    }

    function swapTokensForBNBOrBUSD(address tokenAddress, uint256 tokenAmount,uint8 tokenPairedCode) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = tokenAddress;
        path[1] = tokenPairedCode == 0 ? uniswapV2Router.WETH() : BUSD;

        IERC20(tokenAddress).approve(address(uniswapV2Router), tokenAmount);

        // If BNB
        if(tokenPairedCode == 0) uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(tokenAmount,0,path,address(this),block.timestamp);
        // Else take BUSD and exchange it for some BNBs
        else {
        uint256 initialBusdBalance = IERC20(BUSD).balanceOf(address(this));
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(tokenAmount,0,path,address(this),block.timestamp);
        uint256 newBusdBalance = IERC20(BUSD).balanceOf(address(this)) - initialBusdBalance;
        swapTokensForBNBOrBUSD(BUSD,newBusdBalance,0);
        }
    }

    function swapBNBForTokens(uint256 bnbAmount, address tokenAddress) private {
        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = tokenAddress;

        IERC20(uniswapV2Router.WETH()).approve(address(uniswapV2Router), bnbAmount);

        uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: bnbAmount}(
        0,
        path,
        address(this),
        block.timestamp); 
    }


    function pause() external {
        require(!_isPaused, "Savior: The contract is already paused");
        _isPaused = true;
        emit Paused();
    }

    function unpause() external {
        require(_isPaused, "Savior: The contract is already unpaused");
        _isPaused = false;
        emit Unpaused();
    }

    // Read functions

    function getNbrKarmaSentByWalletAndByToken(address wallet, address token) external view returns(uint256){
        return tokenBalances[wallet][token];
    }

    function getTotalTokensReceived(address token) external view returns(uint256) {
        return totalTokensReceived[token];
    }

    function getTotalKarmaSentByToken(address token) external view returns(uint256) {
        return totalKarmaTokensSent[token];
    }

    function isPaused() external view returns (bool) {
        return _isPaused;
    }

    function getTokenOfTheWeekDecimals() external view returns (uint8) {
        return IERC20(tokenOfTheWeek).decimals();
    }


    function getTokenOfTheWeekSymbol() external view returns (string memory) {
        return IERC20(tokenOfTheWeek).symbol();
    }

    function getTokenOfTheWeekName() external view returns (string memory) {
        return IERC20(tokenOfTheWeek).name();
    }

}