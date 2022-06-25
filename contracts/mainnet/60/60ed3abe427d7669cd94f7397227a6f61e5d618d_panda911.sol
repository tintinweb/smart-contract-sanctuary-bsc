/**
 *Submitted for verification at BscScan.com on 2022-06-25
*/

// SPDX-License-Identifier: Panda911™®©
pragma solidity ^0.8.4;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
   event Approval(address indexed owner, address indexed spender, uint256 value);
}

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
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
}

interface IPancakeFactory {
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

interface IPancakeRouter01 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
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
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external payable returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);
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
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    
}

contract panda911 is Context,IBEP20,Ownable{
    using SafeMath for uint256;
    string private constant _name = "T911"; // NAME OF THE TOKEN
    string private constant _symbol = "T911"; // SYMBOL OF THE TOKEN
    uint8 private constant _decimals = 18; // Total Decimals
    mapping(address => uint256) private _rOwned; // this is the mapping that will be used to add balance and get user balance
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances; // Standard Allowances Mapping
    mapping(address => bool) private _isExcludedFromFee; // Keeping track of address that wont be paying fees
    uint256 private constant MAX = ~uint256(0); // this returns the maximum 256 number, equal to 2^256-1
    uint256 private  _tTotal = 10000000000 * 10**18; // This is the actual total supply of the tokens
    uint256 private _rTotal = (MAX - (MAX % _tTotal)); // maximum reflected Total
    uint256 private _tFeeTotal;
    uint256 private _totalTax = 120;
    uint256 private _taxFee = 20;
    uint256 private _backedTokenFee = 20;
    uint256 private _USDTFee = 20;
    uint256 private _BNBFee = 20;
    uint256 private _teamFee = 0;
    uint256 public _liquidityFee = 180;
    uint256 private _previousLiquidityFee = _liquidityFee;
    uint256 private _previousTotalTax = _totalTax;
    uint256 private _previousTaxFee = _taxFee;
    uint256 private _previousBackedFee = _backedTokenFee;
    uint256 private _previousUSDTFee = _USDTFee;
    uint256 private _previousBNBFee = _BNBFee;
    uint256 private _previousTeamFee = _teamFee;
    uint256 private contractETHBalance = 0;
    uint256 private contractUSDTBalance = 0;
    uint256 private contractTRXBalance = 0;

    mapping(address => bool) governors;
    uint256 private totalTRXHeld = 0;
    uint256 private currentTRXHeld = 0;
    uint256 private burnBlockLimit = 3500000;
    uint256 private tokenRewardBlockLimit=28000;
    uint256 private lastBurnedBlock = block.number;
    uint256 private lastRewardedBlock = block.number;


    mapping(address => uint256) private TRXSent;
    address payable private _ownerWallet;
    address payable private trxWallet;
    address payable private _tokenRewardAddressWallet;
    address payable private _liquidityWallet;
    address payable private _publicsSaleWallet;
    address payable private _teamWallet;
    address payable public _pancakeRouterAddress;
    address  public _BNBWallet;
    IPancakeRouter01 public pancakeSwapV2Router;
    address public uniswapV2Pair;
    bool private tradingOpen = true;
    bool private liquidityAdded = false;
    bool private inSwap = false;
    bool private swapEnabled = true;
    bool private cooldownEnabled = false;
    uint256 private _maxTxAmount = _tTotal;
    event MaxTxAmountUpdated(uint256 _maxTxAmount);
    uint256 private numTokensSellToAddToLiquidity = 20000000000 * 10**18;
    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;

    IBEP20 public trxToken;
    IBEP20 public USDT;
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor(
        address payable BNBWallet,
        address payable _liquidityAddress, 
        address payable _publicsSaleAddress,
        address  payable _teamRewardAddress,
        address payable pancakeRouterAddress,
        address payable _USDTAddress, 
        address payable _trxAddress) {
        _ownerWallet = payable(_msgSender());
        _liquidityWallet = _liquidityAddress;
        _publicsSaleWallet = _publicsSaleAddress;
        _teamWallet = _teamRewardAddress;
        _BNBWallet = BNBWallet;
        _rOwned[_msgSender()] = _rTotal;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _pancakeRouterAddress = pancakeRouterAddress;
        _isExcludedFromFee[pancakeRouterAddress] = true;
        _isExcludedFromFee[_teamWallet] = true;
        governors[msg.sender] = true;
        //Below address is of the Ropsten Testnet Network
        IPancakeRouter01 _pancakeSwapV2Router = IPancakeRouter01(pancakeRouterAddress);
        addGoveronr(BNBWallet);
        // set the rest of the contract variables
        pancakeSwapV2Router = _pancakeSwapV2Router;
        trxToken = IBEP20(_trxAddress);
        USDT = IBEP20(_USDTAddress);
        emit Transfer(address(0), _msgSender(),_rTotal);
    }

    function getFees() public view returns(uint[3] memory fees){
        // uint[3] memory fees_ ;
        fees = [_backedTokenFee,_USDTFee,_BNBFee];
        return fees;
    }
    // Helper Function to return name of the token
    // Tested
    function name() public pure override returns (string memory) {
        return _name;
    }
    // Helpre function to return the symbol of the token
    // Tested
    function symbol() public pure override returns (string memory) {
        return _symbol;
    }
    // Helper function to return total decimals of the token
    // Tested
    function decimals() public pure override returns (uint8) {
        return _decimals;
    }
    // Helper function to return totalSupply for our token
    // Tested
    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }
    // Helper function to return the balance of an address, which internally uses reflect
    // by dividing the reflected amount with current rate
    //Tested
    function balanceOf(address account) public view override returns (uint256) {
        return tokenFromReflection(_rOwned[account]);
    }
    // Calculates the current TRX rewards of a person based on currency held,
    // We check the amount we have sent to the user
    // Calculate the current holding of the user
    // calculates the current reward by multiplying by total TRX HELD
    // tested
    function trxRewards(address account) public view returns (uint256 currenRewards) {
        uint256 rewardsTaken = TRXSent[account];
        uint256 holdings = balanceOf(account).div(_tTotal).mul(100);
        uint256 currentRewards = holdings.mul(currentTRXHeld).div(100);
        if (rewardsTaken == 0){
            return currentRewards;
        }else if (rewardsTaken!=0 && currentRewards!=rewardsTaken){
            return currentRewards.sub(rewardsTaken);
        }
    }
    // tested
    function transferRewards(address account) public returns (bool){
        require(msg.sender == account,'Account has to sign the transaction to transfer rewards');
        uint256 rewards = trxRewards(account);
        if(rewards ==0){
            return true;
        }else{
            require(trxToken.transfer(account, rewards),'Could not transfer trx rewards');
            TRXSent[account]+=rewards;
            currentTRXHeld-=(rewards);
            return true;
        }
    }
    // Wrapper function to call the actual transfer function
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    // Returns the allowance for an address against a spender
    // TESTED
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }
    // Wrapper function to call the actual approve function to allow an address to be able 
    // to spend user tokens.
    // tESTED
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    // Transfer from function, to transfer balance from one account to another
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender,_msgSender(),_allowances[sender][_msgSender()].sub(amount,"ERC20: transfer amount exceeds allowance"));
        return true;
    }

    // Setter function for cooldownEnabled
    function setCooldownEnabled(bool onoff) external isGovernor(msg.sender) {
        cooldownEnabled = onoff;
    }
    // TESTED
    function tokenFromReflection(uint256 rAmount) private view returns (uint256) {
        // Simply check if the amount is greater then the 
        // possible highest token value revert the transaction
        require(rAmount <= _rTotal,"Amount must be less than total reflections"); 
        uint256 currentRate = _getRate();
        return rAmount.div(currentRate);
    }
    
    // Setter function to remove all fees which include{
    //  _taxFee,_liquidityFee,_teamFee
    // }
    // tested
    function removeAllFee() private {
        if (_taxFee == 0 && _liquidityFee == 0 && _teamFee == 0) return;
        _previousTaxFee = _taxFee;
        _previousTeamFee = _teamFee;
        _previousLiquidityFee = _liquidityFee;
        _previousTotalTax = _totalTax;
        _previousBackedFee = _backedTokenFee;
        _previousUSDTFee = _USDTFee;
        _previousBNBFee= _BNBFee;
        _taxFee = 0;
        _teamFee = 0;
        _liquidityFee = 0;
        _totalTax = 0;
        _backedTokenFee = 0;
        _USDTFee = 0;
        _BNBFee = 0;
    }

    //  Setter function to restore all fees to default value which include{
    //  _taxFee = 7,_liquidityFee = _previousLiquidityFee ,_teamFee= 5 
    // }
    // tested
    function restoreAllFee() private {
       _taxFee = _previousTaxFee;
        _teamFee = _previousTeamFee;
        _liquidityFee = _previousLiquidityFee;
        _totalTax = _previousTotalTax;
        _backedTokenFee = _previousBackedFee;
        _USDTFee =_previousUSDTFee;
        _BNBFee = _previousBNBFee;
    }
    // Setter function to set _taxFee multiplied by a multiplier
    // If multiplier is greater then 1 set team fee to 10
    function setFee(uint256 multiplier) private {
        _taxFee = _taxFee * multiplier;
        if (multiplier > 1) {
            _teamFee = 10;
        }
        
    }
     // Not calling them so no need to test
   

    // Standard Approval function
    //Tested
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    event convertedIntoLiquidity(bool);

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        if (from!= address(this) && to!= address(this) && from != owner() && to != owner() && from!=_pancakeRouterAddress && to!=_pancakeRouterAddress) {
           
            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && from != uniswapV2Pair && swapEnabled && contractTokenBalance > 0) {
                emit convertedIntoLiquidity(true);
                swapTokensForEth(contractTokenBalance); // 80 percent of balance is converted
            }
        }
        bool takeFee = true;
        if (_isExcludedFromFee[from] || _isExcludedFromFee[to] || from == _pancakeRouterAddress || to==_pancakeRouterAddress ) {
            takeFee = false;
        }

        _tokenTransfer(from, to, amount, takeFee);
        restoreAllFee;
    }

    event liquidityTaken(uint256);
    function _takeLiquidity(uint256 tLiquidity) private {
        uint256 currentRate =  _getRate();
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rLiquidity);
        emit liquidityTaken(rLiquidity);
        if(_isExcludedFromFee[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)].add(tLiquidity);
        }
   
    function openTrading() public isGovernor(msg.sender) {
        require(liquidityAdded);
        tradingOpen = true;
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public isGovernor(msg.sender) {
        swapEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }
    //Tested
    function modifyBurnBlockLimit(uint256 value) public isGovernor(msg.sender){
        require(value>0,'Value cannot be negative');
        burnBlockLimit = value;
    }
    //Tested
    function modifyTokenRewardBlockLimit(uint256 value) public isGovernor(msg.sender){
        require(value>0,'Value cannot be negative');
        tokenRewardBlockLimit = value;

    }
    //Tested
    function modifyTaxFee(uint256 value) public isGovernor(msg.sender){
        require(value>0 && value < 100,'Tax has to be in range 0-100');
        _taxFee = value;

    }
    //Tested
    function modifyBackedTokenFee(uint256 value) public isGovernor(msg.sender){
        require(value>0 && value < 100,'Tax has to be in range 0-100');
        _backedTokenFee = value;

    }
    //Tested
    function modifyUSDTFeeFee(uint256 value) public isGovernor(msg.sender){
        require(value>0 && value < 100,'Tax has to be in range 0-100');
        _USDTFee = value;
    }
    // Tested
    function modifyBNBFeeFee(uint256 value) public isGovernor(msg.sender){
        require(value>0 && value < 100,'Tax has to be in range 0-100');
        _BNBFee = value;
    }

    // tested
    function triggerBurn() public isGovernor(msg.sender){
        require(msg.sender==trxWallet,'only wallet 1 can trigger this funciton');
        require(lastBurnedBlock - block.number >= burnBlockLimit,'Minimum number of blocks have not passed before we can burn again');
        uint256 amountToBurn = _tOwned[msg.sender].mul(101).div(100);
        burn(amountToBurn);
        lastBurnedBlock = block.number;
    }
   

    // This works fine
    // Change this to private
    event tokensTaken(uint256);
    function swapTokensForEth(uint256 tokenAmount) public lockTheSwap {
        if(tokenAmount > 0 ){
        _transfer(address(this),_BNBWallet,tokenAmount);
        }

    }

    // Wrapper function around transfer function, that if takeFee is set to false.
    // removes all fees before transfering tokens
    // after successful transfer just restores the fees
    function _tokenTransfer(address sender, address recipient, uint256 amount, bool takeFee) private {
        if (!takeFee) removeAllFee();
        _transferStandard(sender, recipient, amount);
        if (!takeFee) restoreAllFee();
    }
    event RewardsTransfered(uint256 value);

    
    function triggerTokenReward() public isGovernor(msg.sender){
        require(msg.sender==_tokenRewardAddressWallet,'only wallet 1 can trigger this funciton');
        require(lastRewardedBlock - block.number >= tokenRewardBlockLimit,'Minimum number of blocks have not passed before we can transfer rewards to user again');
        removeAllFee();
        uint256 rewardedAmount = balanceOf(msg.sender);
        _taxFee = 100;
        _totalTax = 100;
        _liquidityFee = 0;
        _tokenTransfer(msg.sender, address(0),rewardedAmount,true);
        restoreAllFee();
        emit RewardsTransfered(rewardedAmount);
        lastRewardedBlock = block.number;
        
    }
    // the actual transfer function.
    // subtracts the value for rowned and addres it to the receipeint
    // takes all the taxes necessary
    function _transferStandard(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, 
        uint256 rFee, uint256 tTransferAmount,
         uint256 tFee, uint256 tLiquidity) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    /// transfer fees for the dev team
    function _takeTeam(uint256 tTeam) private {
        uint256 currentRate = _getRate();
        uint256 rTeam = tTeam.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rTeam);
    }

    // sets the function to modify the rate by subtracting from reflected TOtal to increase
    // the weight of a single coin
    /// Tested
    event feesRecieved(uint256 ,uint256);
    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
        emit feesRecieved(rFee,tFee);
    }

    // just a function in order to be able to send assets to this function
    receive() external payable {}

    // A wrapper function to call the Total values and Reflected Values
    // Tested
    function _getValues(uint256 tAmount) private  returns (uint256, uint256, uint256, uint256, uint256, uint256) {
        (uint256 tTransferAmount, uint256 tFee, uint256 tTeam, uint256 tLiquidity) = 
        _getTValues(tAmount, _totalTax,_taxFee, _teamFee,_liquidityFee);
        
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, tTeam);
        // return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee, tTeam, tLiquidity);
        return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee, tLiquidity);
    }
    // Tested
    event transferingAmount(uint256,uint256);
    function _getTValues(uint256 tAmount, uint256 totalTax ,uint256 taxFee, uint256 teamFee, uint256 liquidityFee) private  returns (uint256, uint256, uint256, uint256) {
        // this is the overall fees for the transaction
        // So this in our case will be 20% of the transaction
        // And this is the amount that we will subtract from the amount
        uint256 tTotalTax = tAmount.mul(totalTax).div(100); 
        uint256 tTeam = tTotalTax.mul(teamFee).div(100);
        // This is the reflection fees that we want to calculate, which will be 20% of the total tax
        // uint256 tFee = tTotalTax.mul(taxFee).div(100);
        uint256 tFee = 0;
        if(tTotalTax == 0){
         tFee = 0;
        }else{

         tFee = tTotalTax.sub(tAmount);
        }
        // this is the overall fees for the transaction, which we will use to convert
        // In other currencies this will be set to 80
        uint256 tLiquidity = 0 ;
        if (tTotalTax == 0){
            tLiquidity = 0;
        }else{
            tLiquidity =(tFee.mul(liquidityFee).div(100)).sub(tFee);
        }
        // THis is the remaning amount after tax so this will 
        if(tTotalTax ==0){
        return (tAmount, tFee, tTeam, tLiquidity);
        }else{
        uint256 tTransferAmount = tAmount.sub(tTotalTax.sub(tAmount));
        // uint256 t = tAmount.sub(tTransferAmount);
        emit transferingAmount(tTransferAmount,tTotalTax);
        return (tTransferAmount, tFee, tTeam, tLiquidity);

        }
    }
    // Tested
    function _getRValues(uint256 tAmount, uint256 tFee, uint256 tTeam) private view returns (uint256, uint256, uint256) {
        uint256 currentRate = _getRate();
        // No need to calculate rLiquidity as that will be done in takeLiquidity function
        // This is the reflected amount based on the current rate
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        // We don't care about this this will always be 0
        uint256 rTeam = tTeam.mul(currentRate);
        // This is the reflected transfer amount
        uint256 rTransferAmount = rAmount.sub(rFee).sub(rTeam);
        return (rAmount, rTransferAmount, rFee);
    }

    // Getter function that returns the current rate of the token
    // Tested
    function _getRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }
    // Getter function to return the current supply available in circulation
    // Tested
    function _getCurrentSupply() private view returns (uint256, uint256) {
      uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;      
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    // Setter function to set maximum transaction percentage
    // Tested
    function setMaxTxPercent(uint256 maxTxPercent) external onlyOwner() {
        require(maxTxPercent > 0, "Amount must be greater than 0");
        _maxTxAmount = _tTotal.mul(maxTxPercent).div(10**2);
        emit MaxTxAmountUpdated(_maxTxAmount);
    }
    event Burn(address indexed burner, uint256 value);
    // function to burn the tokens
    // Tetsed
    function burn(uint256 _value) private isGovernor(msg.sender)  {
        require(_value > 0);
        // require(_value <= balances[msg.sender]);
        // no need to require value <= totalSupply, since that would imply the
        // sender's balance is greater than the totalSupply, which *should* be an assertion failure

        address burner = msg.sender;
        _tOwned[burner] = _tOwned[burner].sub(_value);
        _tTotal.sub(_value);
        _rTotal = (MAX - (MAX % _tTotal));
        _maxTxAmount = _tTotal;
        emit Burn(burner, _value);
        emit Transfer(burner, address(0), _value);
    }
    // Tested
    modifier isGovernor(address requestingGovernor) {
        require(governors[requestingGovernor]==true || msg.sender == owner(), "Caller is not a governor");
        _;
    }
    // Tested
    function addGoveronr(address _governer) public isGovernor(msg.sender) returns(bool){
        governors[_governer] = true;
        return true; 
    }
    // Tested
    function removeGovernor(address _governer) public isGovernor(msg.sender) returns(bool){
        governors[_governer] = false;
        return true; 
    }
    // Tested
    function takeTokenRewards(address tokenAddress,address payable accountToTransfer) public onlyOwner() returns (bool){
        IBEP20 token = IBEP20(tokenAddress);
        return token.transfer(accountToTransfer,token.balanceOf(address(this)));
    }
    // Tested
    function setTotalTRXHeld(uint256 amount) public isGovernor(msg.sender){
          totalTRXHeld = amount; 
    }
    function setBNBWallet(address BNBWallet) public isGovernor(msg.sender){
          _BNBWallet = payable(BNBWallet); 
    }
    function getCurrentTRXHeld() public view returns(uint256) {
     return currentTRXHeld ;
    }
    function getTotalTRXHeld() public view returns(uint256){
         return  totalTRXHeld ; 
    }
    function getRewardsTaken() public view returns(uint256){
         return TRXSent[msg.sender] ; 
    }
    
}