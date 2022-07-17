// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

//Importing Required Libraries
import '@openzeppelin/contracts/utils/math/SafeMath.sol';
import '@openzeppelin/contracts/utils/Address.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./utils/pancake_swap/interfaces/IPancakeSwapV2Factory.sol";
import "./utils/pancake_swap/interfaces/IPancakeSwapV2Pair.sol";
import "./utils/pancake_swap/interfaces/IPancakeSwapV2Router02.sol";

/// @title Dot Coin 
/// @author Ram Krishan Pandey,Gaurav Solanki
/// @notice RFI based token
/// @dev This is customized RFI based token
contract DotCoin is Context, IERC20, Ownable{

    // Using safe-math for uint256 and Address for address
    using SafeMath for uint256;
    using Address for address;

    // Token management
    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;

    // Fee and Reflection management 
    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) private _isExcludedFromReflection;
    address[] private _excludedFromReflection;
   
    // Supply management
    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal = 1_000_000_000e18;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;

    // Token Meta-data
    string private _name;
    string private _symbol;
    uint8 private constant _DECIMALS = 18;
    
    // Tax Management
    uint256 public reflectionsFee = 2; // 2% reflection fees
    uint256 private _previousReflectionsFee = reflectionsFee;
    
    uint256 public liquidityFee = 2; // 2% liquidity fees
    uint256 private _previousLiquidityFee = liquidityFee;
    
    uint256 public rewardsFee = 2; // 2% rewards fees
    uint256 private _previousRewardsFee = rewardsFee;
    
    uint256 public burnFee = 1; // 1% burn fees
    uint256 private _previousBurnFee = burnFee;



    // Management Wallets
    address public airDropWallet;
    address public bufferWallet;
    address public managementWallet;
    address public rewardWallet;
    address public creatorsWallet;
    address public burnWallet;
    

    // Pancake-swap Router and Pair
    IPancakeRouter02 public immutable pancakeswapV2Router;
    address public immutable pancakeswapV2Pair;
    
    // Swap and Liquidify controller
    bool private _inSwapAndLiquify;
    bool private _swapAndLiquifyEnabled = true;
    
    // Maximum tx. amount
    uint256 public  maxTxAmount;

    // Minimum tokens to add in liquidity
    uint256 private  _minTokensSellToAddToLiquidity;
    
    // Evants
    event MinTokensBeforeSwapUpdated(uint256 indexed minTokensBeforeSwap_);

    event SwapAndLiquifyEnabledUpdated(bool indexed enabled_);

    event SwapAndLiquify(
        uint256 indexed tokensSwapped_,
        uint256 indexed ethReceived_,
        uint256 indexed tokensIntoLiqudity_
    );
    
    // swap modifier
    modifier lockTheSwap {
        _inSwapAndLiquify = true;
        _;
        _inSwapAndLiquify = false;
    }

    // Locking-token management

    ///@dev Frequency and percentage of unlock
    uint256 public frequencyOfUnlockGiven; 
    uint256 private constant _PERCENTAGE_OF_UNLOCK = 100; // 100%

    /// @dev locked token structure
    struct LockToken {
        uint256 amount;
        uint256 previousUnlockDate;
    }

    /// @dev Holds number & validity of tokens locked for a given reason for a specified address
    mapping(address => LockToken) public locked;

    ///@dev All  locked accounts accounts
    address[] public totalLockAddress;

    ///@dev Events in swap and Locking
    event Locked(
        address indexed of_,
        uint256 indexed amount_,
        uint256 indexed percentageOfUnlock_,
        uint256  frequencyOfUnlock_
    );


    constructor (string memory name_,string memory symbol_,address[] memory wallets_,bool isMainNetwork_,uint256 maxTxAmount_,uint256 minTokensSellToAddToLiquidity_,address owner_,uint256 frequencyOfUnlock_) {

        // Initializing token anme and symbol
        _name=name_;
        _symbol=symbol_;

        // Initializing max. Tx. Amount and min. Tokens Sell To Add To Liquidity
        maxTxAmount=maxTxAmount_.mul(1e18);
        _minTokensSellToAddToLiquidity=minTokensSellToAddToLiquidity_.mul(1e18);

        // Frequency of unlock in seconds
        frequencyOfUnlockGiven=frequencyOfUnlock_;
        
        // Token transfer
        _rOwned[owner()] = _rTotal;
        emit Transfer(address(0), owner(), _tTotal);

        //Initilizing Pancakeswap
        //TEST NETWORK PANCAKESWAP ADDRESS -0xD99D1c33F9fC3444f8101754aBC46c52416550D1
        //MAIN NETWORK PANCAKESWAP ADDRESS -0x10ED43C718714eb63d5aA57B78B54704E256024E 
        address pancakeSwapV2RouterAddress;
        if(isMainNetwork_){
          pancakeSwapV2RouterAddress=0x10ED43C718714eb63d5aA57B78B54704E256024E;
        }
        else{
          pancakeSwapV2RouterAddress=0xD99D1c33F9fC3444f8101754aBC46c52416550D1;
        }
        IPancakeRouter02 _pancakeswapV2Router = IPancakeRouter02(pancakeSwapV2RouterAddress);
        
        // Create a pancakeswap pair for this new token
        pancakeswapV2Pair = IPancakeFactory(_pancakeswapV2Router.factory())
            .createPair(address(this), _pancakeswapV2Router.WETH());

        // set the rest of the contract variables
        pancakeswapV2Router = _pancakeswapV2Router;

        //Initilize wallets
        (bool statusInitlizeWallets)= _initilizeWallets(wallets_);
        require(statusInitlizeWallets,"unable to initlize wallets");

        //Initilize tokenomics
        (bool statusInitlizeTokenomics)= _initilizeTokenomics();
        require(statusInitlizeTokenomics,"unable to initlize tokenomics");   

        //Transfer owner
        transferOwnership(owner_,false);

    }

    function _initilizeWallets(address[] memory wallets_) private returns(bool){

        require(wallets_.length==6,"invalid wallets length");

        airDropWallet=wallets_[0];
        _isExcludedFromFee[airDropWallet] = true;
        excludeFromReflection(airDropWallet);

        bufferWallet=wallets_[1];
        _isExcludedFromFee[bufferWallet] = true;
        excludeFromReflection(bufferWallet);

        managementWallet=wallets_[2];
        _isExcludedFromFee[managementWallet] = true;
        excludeFromReflection(managementWallet);

        rewardWallet=wallets_[3];
        _isExcludedFromFee[rewardWallet] = true;
        excludeFromReflection(rewardWallet);

        creatorsWallet=wallets_[4];
        _isExcludedFromFee[creatorsWallet] = true;
        excludeFromReflection(creatorsWallet);

        burnWallet=wallets_[5];
        _isExcludedFromFee[burnWallet] = true;
        excludeFromReflection(burnWallet);

        //exclude owner and this contract from fee
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;

        //exclude from reflection
        excludeFromReflection(owner());
        excludeFromReflection(address(this));
        excludeFromReflection(address(0));

        //exclude from reflection pancake 
        excludeFromReflection(address(pancakeswapV2Router));
        excludeFromReflection(pancakeswapV2Pair);

        return true; 

    }

    function _initilizeTokenomics() private returns(bool){
       
        // Airdrop – 0.1 %( 10, 00, 000) – Single Wallet
        transfer(airDropWallet, _tTotal.mul(1).div(1000));   

        // Buffer Wallet – 35% (35, 00, 00, 000) – For later use – Single Wallet
        transfer(bufferWallet, _tTotal.mul(350).div(1000));

        // Management Wallet – 35.9 %( 35, 90, 00, 000) – Single Wallet
        transfer(managementWallet, _tTotal.mul(359).div(1000));

        // Rewards – 18 %( 18, 00, 00, 000) – Single Wallet
        transfer(rewardWallet, _tTotal.mul(180).div(1000));

        // Creators – 6% (6, 00, 00, 000) – Single Wallet
        transfer(creatorsWallet, _tTotal.mul(60).div(1000));

        return true;   
    }

    function name() external view returns (string memory) {
        return _name;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function decimals() external pure returns (uint8) {
        return _DECIMALS;
    }

    function totalSupply() external view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account_) public view override returns (uint256) {
        if (_isExcludedFromReflection[account_]) return _tOwned[account_];
        return _tokenFromReflection(_rOwned[account_]);
    }

    function transfer(address recipient_, uint256 amount_) public override returns (bool) {

        if(_msgSender() == burnWallet){
         require(unlockBalanceof(_msgSender())>=amount_, "ERC20: Insufficient Unlock Amount");
        }
       
        require(_msgSender() != burnWallet, "ERC20: transfer from the burn address");
        _transfer(_msgSender(), recipient_, amount_);
        return true;
    }

    function transferFrom(address sender_, address recipient_, uint256 amount_) external override returns (bool) {
      
        if(sender_ == burnWallet){
         require(unlockBalanceof(sender_)>=amount_, "ERC20: Insufficient Unlock Amount");
        }
        _transfer(sender_, recipient_, amount_);
        _approve(sender_, _msgSender(), _allowances[sender_][_msgSender()].sub(amount_, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
        
    function allowance(address owner_, address spender_) external view override returns (uint256) {
        return _allowances[owner_][spender_];
    }

    function approve(address spender_, uint256 amount_) external override returns (bool) {
        _approve(_msgSender(), spender_, amount_);
        return true;
    }

    function increaseAllowance(address spender_, uint256 addedValue_) external virtual returns (bool) {
        _approve(_msgSender(), spender_, _allowances[_msgSender()][spender_].add(addedValue_));
        return true;
    }

    function decreaseAllowance(address spender_, uint256 subtractedValue_) external virtual returns (bool) {
        _approve(_msgSender(), spender_, _allowances[_msgSender()][spender_].sub(subtractedValue_, "ERC20: decreased allowance below zero"));
        return true;
    }

    function isExcludedFromReflection(address account_) external view returns (bool) {
        return _isExcludedFromReflection[account_];
    }

    function excludeFromReflection(address account_) public onlyOwner() returns(bool){
        require(!_isExcludedFromReflection[account_], "Account is already excluded");
        if(_rOwned[account_] > 0) {
            _tOwned[account_] = _tokenFromReflection(_rOwned[account_]);
        }
        _isExcludedFromReflection[account_] = true;
        _excludedFromReflection.push(account_);

        return true;
    }

    function includeInReflection(address account_) external onlyOwner() returns(bool){
        require(account_!=address(0), "Account is address(0)");
        require(_isExcludedFromReflection[account_], "Account is already excluded");
        for (uint256 i = 0; i < _excludedFromReflection.length; i++) {
            if (_excludedFromReflection[i] == account_) {
                _excludedFromReflection[i] = _excludedFromReflection[_excludedFromReflection.length - 1];
                _tOwned[account_] = 0;
                _isExcludedFromReflection[account_] = false;
                _excludedFromReflection.pop();
                break;
            }
        }
         return true;
    }

    function _approve(address owner_, address spender_, uint256 amount_) private returns(bool){
        require(owner_ != address(0), "ERC20: approve from the zero address");
        require(spender_ != address(0), "ERC20: approve to the zero address");

        _allowances[owner_][spender_] = amount_;
        emit Approval(owner_, spender_, amount_);

        return true;
    }

    function _transfer(
        address from_,
        address to_,
        uint256 amount_
    ) private {
        require(from_ != address(0), "ERC20: transfer from the zero address");
        require(to_ != address(0), "ERC20: transfer to the zero address");
        require(amount_ > 0, "Transfer amount must be greater than zero");
        if(from_ != owner() && to_ != owner()){
           require(amount_ <= maxTxAmount, "Transfer amount exceeds the maxTxAmount.");
        }

        // is the token balance of this contract address over the min number of
        // tokens that we need to initiate a swap + liquidity lock?
        // also, don't get caught in a circular liquidity event.
        // also, don't swap & liquify if sender is uniswap pair.
        uint256 contractTokenBalance = balanceOf(address(this));
        
        //Swap can not cross max tx. amount
        if(contractTokenBalance >= maxTxAmount)
        {
            contractTokenBalance = maxTxAmount;
        }
        
        bool overMinTokenBalance = contractTokenBalance >= _minTokensSellToAddToLiquidity;

        if (
            overMinTokenBalance &&
            !_inSwapAndLiquify &&
            from_ != pancakeswapV2Pair &&
            _swapAndLiquifyEnabled
        ) {
            
            //add liquidity
            (bool swapAndLiquifyStatus)=_swapAndLiquify(contractTokenBalance);
            require(swapAndLiquifyStatus,"Unable to swap And Liquify");
        }
        
        //indicates if fee should be deducted from transfer
        bool takeFee = true;
        
        //if any account belongs to _isExcludedFromFee account then remove the fee
        if(_isExcludedFromFee[from_] || _isExcludedFromFee[to_]){
            takeFee = false;
        }
        
        //transfer amount, it will take tax, burn, liquidity fee
        _tokenTransfer(from_,to_,amount_,takeFee);
    }

        //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(address sender_, address recipient_, uint256 amount_,bool takeFee_) private {
        if(!takeFee_)
            _removeAllFee();
        
        if (_isExcludedFromReflection[sender_] && !_isExcludedFromReflection[recipient_]) {
            _transferFromExcluded(sender_, recipient_, amount_);
        } else if (!_isExcludedFromReflection[sender_] && _isExcludedFromReflection[recipient_]) {
            _transferToExcluded(sender_, recipient_, amount_);
        } else if (!_isExcludedFromReflection[sender_] && !_isExcludedFromReflection[recipient_]) {
           _transferStandard(sender_, recipient_, amount_);
        } else if (_isExcludedFromReflection[sender_] && _isExcludedFromReflection[recipient_]) {
            _transferBothExcluded(sender_, recipient_, amount_);
        } else {
           _transferStandard(sender_, recipient_, amount_);
        }
        
        if(!takeFee_)
            _restoreAllFee();
    }

    function _transferStandard(address sender_, address recipient_, uint256 tAmount_) private {
        (uint256 rAmount,uint256 rTransferAmount,uint256 rRefelctionFee,,,,uint256 tTransferAmount,uint256 tReflectionFee,uint256 tLiquidityFee,uint256 tRewardFee,uint256 tBurnFee) = _getValues(tAmount_);
        _rOwned[sender_] = _rOwned[sender_].sub(rAmount);
        _rOwned[recipient_] = _rOwned[recipient_].add(rTransferAmount);
        _takeLiquidity(tLiquidityFee);
        _takeBurn(tBurnFee);
        _takeReward(tRewardFee);
        _reflectFee(rRefelctionFee, tReflectionFee);
        emit Transfer(sender_, recipient_, tTransferAmount);
    }

    function _transferToExcluded(address sender_, address recipient_, uint256 tAmount_) private {
        (uint256 rAmount,uint256 rTransferAmount,uint256 rRefelctionFee,,,,uint256 tTransferAmount,uint256 tReflectionFee,uint256 tLiquidityFee,uint256 tRewardFee,uint256 tBurnFee)  = _getValues(tAmount_);
        _rOwned[sender_] = _rOwned[sender_].sub(rAmount);
        _tOwned[recipient_] = _tOwned[recipient_].add(tTransferAmount);
        _rOwned[recipient_] = _rOwned[recipient_].add(rTransferAmount);           
        _takeLiquidity(tLiquidityFee);
        _takeBurn(tBurnFee);
        _takeReward(tRewardFee);
        _reflectFee(rRefelctionFee, tReflectionFee);
        emit Transfer(sender_, recipient_, tTransferAmount);
    }

    function _transferFromExcluded(address sender_, address recipient_, uint256 tAmount_) private {
       (uint256 rAmount,uint256 rTransferAmount,uint256 rRefelctionFee,,,,uint256 tTransferAmount,uint256 tReflectionFee,uint256 tLiquidityFee,uint256 tRewardFee,uint256 tBurnFee)  = _getValues(tAmount_);
        _tOwned[sender_] = _tOwned[sender_].sub(tAmount_);
        _rOwned[sender_] = _rOwned[sender_].sub(rAmount);
        _rOwned[recipient_] = _rOwned[recipient_].add(rTransferAmount);   
        _takeLiquidity(tLiquidityFee);
        _takeBurn(tBurnFee);
        _takeReward(tRewardFee);
        _reflectFee(rRefelctionFee, tReflectionFee);
        emit Transfer(sender_, recipient_, tTransferAmount);
    }   

   function _transferBothExcluded(address sender_, address recipient_, uint256 tAmount_) private {
        (uint256 rAmount,uint256 rTransferAmount,uint256 rRefelctionFee,,,,uint256 tTransferAmount,uint256 tReflectionFee,uint256 tLiquidityFee,uint256 tRewardFee,uint256 tBurnFee) = _getValues(tAmount_);
        _tOwned[sender_] = _tOwned[sender_].sub(tAmount_);
        _rOwned[sender_] = _rOwned[sender_].sub(rAmount);
        _tOwned[recipient_] = _tOwned[recipient_].add(tTransferAmount);
        _rOwned[recipient_] = _rOwned[recipient_].add(rTransferAmount);        
        _takeLiquidity(tLiquidityFee);
        _takeBurn(tBurnFee);
        _takeReward(tRewardFee);
        _reflectFee(rRefelctionFee, tReflectionFee);
        emit Transfer(sender_, recipient_, tTransferAmount);
    }

    function changeTax(uint256 newLiquidityFee_,uint256 newBurnFee_,uint256 newRewardFee_,uint256 newReflectFee_) external onlyOwner returns(bool) {        
        require((newLiquidityFee_).add(newBurnFee_).add(newRewardFee_).add(newReflectFee_)<=7,"Tax Fee exceeds 7%");
            reflectionsFee = newReflectFee_;
            liquidityFee = newLiquidityFee_;
            rewardsFee = newRewardFee_;
            burnFee = newBurnFee_;
            return true;
    }
   


    //utils
    function _tokenFromReflection(uint256 rAmount_) private view returns(uint256) {
        require(rAmount_ <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount_.div(currentRate);
    }

    function _getRate() private view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns(uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;      
        for (uint256 i = 0; i < _excludedFromReflection.length; i++) {
            if (_rOwned[_excludedFromReflection[i]] > rSupply || _tOwned[_excludedFromReflection[i]] > tSupply) return (_rTotal, _tTotal);
            rSupply = rSupply.sub(_rOwned[_excludedFromReflection[i]]);
            tSupply = tSupply.sub(_tOwned[_excludedFromReflection[i]]);
        }
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function _removeAllFee() private {
        if(reflectionsFee == 0 && liquidityFee == 0 && rewardsFee == 0 && burnFee == 0 ) return;
        
        _previousReflectionsFee = reflectionsFee;
        _previousLiquidityFee = liquidityFee;
        _previousRewardsFee=rewardsFee;
        _previousBurnFee=burnFee;

        reflectionsFee = 0;
        liquidityFee = 0;
        rewardsFee=0;
        burnFee=0;
    }
    
    function _restoreAllFee() private {

        //Tax Management
        reflectionsFee = _previousReflectionsFee;
        liquidityFee = _previousLiquidityFee;
        rewardsFee = _previousRewardsFee;
        burnFee = _previousBurnFee;
    }

    function _getValues(uint256 tAmount_) private view returns (uint256, uint256, uint256, uint256, uint256, uint256,uint256, uint256, uint256, uint256, uint256) {
         uint256[] memory values=new uint256[](11);
        (values[0],values[1],values[2],values[3],values[4]) = _getTValues(tAmount_);
        (values[5],values[6],values[7],values[8],values[9],values[10]) = _getRValues( tAmount_,  values[1],  values[2], values[3] , values[4], _getRate());
        return (values[5],values[6],values[7],values[8],values[9],values[10],values[0],values[1],values[2],values[3],values[4]);
    }

    function _getTValues(uint256 tAmount_) private view returns (uint256, uint256, uint256,uint256,uint256) {
        uint256[] memory values=new uint256[](5);
        values[0] = _calculateReflectionFee(tAmount_);
        values[1] = _calculateLiquidityFee(tAmount_);
        values[2] = _calculateRewardFee(tAmount_);
        values[3] = _calculateBurnFee(tAmount_);

        uint256 tTransferAmount = tAmount_.sub(values[0]).sub(values[1]).sub(values[2]).sub(values[3]);
        return (tTransferAmount, values[0], values[1],values[2],values[3]);
    }

    function _getRValues(uint256 tAmount_, uint256 tReflectionFee_, uint256 tLiquidityFee_,uint256 tRewardFee_ ,uint256 tBurnFee_, uint256 currentRate_) private pure returns (uint256, uint256, uint256,uint256, uint256, uint256) {
        uint256 rAmount = tAmount_.mul(currentRate_);
        uint256 rRefelctionFee = tReflectionFee_.mul(currentRate_);
        uint256 rLiquidityFee = tLiquidityFee_.mul(currentRate_);
        uint256 rRewardFee = tRewardFee_.mul(currentRate_);
        uint256 rBurnFee = tBurnFee_.mul(currentRate_);
        uint256 rTransferAmount = rAmount.sub(rRefelctionFee).sub(rLiquidityFee).sub(rRewardFee).sub(rBurnFee);
        return (rAmount, rTransferAmount, rRefelctionFee,rLiquidityFee,rRewardFee,rBurnFee);
    }

    function _calculateReflectionFee(uint256 amount_) private view returns (uint256) {
        return amount_.mul(reflectionsFee).div(
            10**2
        );
    }

    function _calculateLiquidityFee(uint256 amount_) private view returns (uint256) {
        return amount_.mul(liquidityFee).div(
            10**2
        );
    }

    function _calculateRewardFee(uint256 amount_) private view returns (uint256) {
        return amount_.mul(rewardsFee).div(
            10**2
        );
    }

    function _calculateBurnFee(uint256 amount_) private view returns (uint256) {
        return amount_.mul(burnFee).div(
            10**2
        );
    }

    function _takeLiquidity(uint256 tLiquidity_) private {
        uint256 currentRate =  _getRate();
        uint256 rLiquidity = tLiquidity_.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rLiquidity);
        if(_isExcludedFromReflection[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)].add(tLiquidity_);
    }

    function _takeBurn(uint256 tBurn_) private {
        uint256 currentRate =  _getRate();
        uint256 rBurn = tBurn_.mul(currentRate);
        _rOwned[burnWallet] = _rOwned[burnWallet].add(rBurn);
        if(_isExcludedFromReflection[burnWallet])
            _tOwned[burnWallet] = _tOwned[burnWallet].add(tBurn_);
      
        if(unlockBalanceof(burnWallet)>0){
            _unLock(burnWallet);
        } 
        if(tBurn_>0){
            _lock(burnWallet,tBurn_);
        }
    }

    function _takeReward(uint256 tReward_) private {
        uint256 currentRate =  _getRate();
        uint256 rReward = tReward_.mul(currentRate);
        _rOwned[rewardWallet] = _rOwned[rewardWallet].add(rReward);
        if(_isExcludedFromReflection[rewardWallet])
            _tOwned[rewardWallet] = _tOwned[rewardWallet].add(tReward_);
    }

    function _reflectFee(uint256 rFee_, uint256 tFee_) private {
        _rTotal = _rTotal.sub(rFee_);
        _tFeeTotal = _tFeeTotal.add(tFee_);
    }

   function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }



    // Locking portion

    /// @notice This function required recipient address, amount and use for locking token for a time duration like :- 1/3 months.
    /// @dev stored in structure with (amount,unlockAmount,persentageOfUnlock,frequencyOfUnlock,createdDate, previousUnlockDate). UnlockAmount calculate (amount * persentageOfUnlock / 10**3).
    /// @param @address recipient, uint256 _amount
    /// @return true
    function _lock(address recipient_, uint256 amount_) private returns (bool) {  
        require(amount_ != 0, "Amount can not be 0");
        if (locked[recipient_].amount > 0) {
            locked[recipient_].amount += amount_;
        }
         else {
            locked[recipient_] = LockToken(
                amount_,
                block.timestamp
            );
            totalLockAddress.push(recipient_);
        }

        emit Locked(
            msg.sender,
            amount_,
            _PERCENTAGE_OF_UNLOCK,
            frequencyOfUnlockGiven
        );
        return true;
    }

    /// @notice This function required recipient address and use for calculate lock token balance for a particular recipient address
    /// @dev update unlockAmount and previousUnlockDate in locked struct.
    /// @param @address recipient
    /// @return lockamount
    function _calculateLockBalance(address recipient_)
        private
        view
        returns (uint256)
    {
        uint256 unlockAmount = 0;
        uint256 lockAmount = 0;

        if (locked[recipient_].amount > 0) {
            uint256 unlockDate = 0;
            unlockDate =
                locked[recipient_].previousUnlockDate +
                (frequencyOfUnlockGiven);
            if (block.timestamp >= unlockDate) {
                unlockAmount =locked[recipient_].amount;
                unlockDate = block.timestamp;
            }
        }
        if (locked[recipient_].amount > unlockAmount) {
            lockAmount = locked[recipient_].amount - unlockAmount;
        }
        return lockAmount;
    }

    /// @notice This function used for get unlockAmount of a recipient.
    /// @dev Get recipient balance and subtract with amount or unlockAmount
    /// @param @address recipient
    /// @return unlockbalance
    function unlockBalanceof(address recipient_) public view returns (uint256) {
        uint256 _lockBalance = _calculateLockBalance(recipient_);
        uint256 _unlockBalance = balanceOf(recipient_) - _lockBalance;
        return _unlockBalance;
    }

    /// @notice This function required recipient address and use for unlocking token for a particular recipient address
    /// @dev update unlockAmount and previousUnlockDate in locked struct.
    /// @param @address recipient
    /// @return true
    function _unLock(address recipient_) private  returns (bool) {
        if (locked[recipient_].amount > 0) {
            uint256 unlockDate = 0;
            unlockDate =
                locked[recipient_].previousUnlockDate +
                (frequencyOfUnlockGiven);
            if (block.timestamp >= unlockDate) {
                        _tokenBurn(burnWallet,locked[recipient_].amount);
                        delete locked[recipient_];  // delete record from struct
                        _removeLockAddress(recipient_);
            }
        }
        return true;
    }

    /// @notice This function required sender address, amount and use for burn tokens with address(0).
    /// @dev calling private function _tokenTransfer
    /// @param @address _sender, uint256 amount 
    /// @return true
    function _tokenBurn(address sender_, uint256 amount_) private returns (bool){
        bool takeFee = true;
        if(_isExcludedFromFee[sender_] || _isExcludedFromFee[address(0)]){
            takeFee = false;
        }
        _tokenTransfer(sender_,address(0),amount_,takeFee);
        return true;
    } 

    /// @notice This private function required recipient address and use for remove particular address from totalAddress array.
    /// @dev apply loop on totalAddress get perticular address match with recipient and delete from array
    /// @param @address recipient
    /// @return true
    function _removeLockAddress(address recipient_) private returns (bool) {
        for (uint256 i = 0; i < totalLockAddress.length; i++) {
            if (totalLockAddress[i] == recipient_) {
                delete totalLockAddress[i];
            }
        }
        return true;
    
    }




    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner_,bool includeInFee_) public  onlyOwner returns(bool){
        require(newOwner_ != address(0), "Ownable: new owner is the zero address");
      
       //include old owner in fee
       if(includeInFee_)
       _isExcludedFromFee[owner()] = false;

       //exclude new owner fee
       _isExcludedFromFee[newOwner_] = true;
       //exclude from reflection
       excludeFromReflection(newOwner_);

       _transferOwnership(newOwner_);

       return true;
    }




    //Recives BNB
    receive() external payable {}

    fallback() external payable {}




    // Pancake Portion

    function setSwapAndLiquifyEnabled(bool newStatus_) external onlyOwner returns(bool){
        _swapAndLiquifyEnabled=newStatus_;
        return true;
    }

    function _swapAndLiquify(uint256 contractTokenBalance_) private lockTheSwap returns(bool){

        // split the contract balance into halves
        uint256 half = contractTokenBalance_.div(2);
        uint256 otherHalf = contractTokenBalance_.sub(half);

        // swap tokens for ETH
        (bool swapTokensForEthStatus)=_swapTokensForEth(half); // <- this breaks the ETH -> HATE swap when swap+liquify is triggered
        require(swapTokensForEthStatus,"unable to breaks the ETH -> HATE swap when swap+liquify is triggered");

        // how much ETH did we just swap into?
        uint256 newBalance = address(this).balance;

        // add liquidity to pancake swap
        (bool addLiquidityStatus)=_addLiquidity(otherHalf, newBalance);
        require(addLiquidityStatus,"unable to breaks the ETH -> HATE swap when swap+liquify is triggered");

        emit SwapAndLiquify(half, newBalance, otherHalf);

        return true;
    }

    function _swapTokensForEth(uint256 tokenAmount_) private returns(bool){

        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = pancakeswapV2Router.WETH();

        _approve(address(this), address(pancakeswapV2Router), tokenAmount_);

        // make the swap
        pancakeswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount_,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
        return true;
    }

    function _addLiquidity(uint256 tokenAmount_, uint256 ethAmount_) private returns(bool) {

        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(pancakeswapV2Router), tokenAmount_);

        // add the liquidity
        pancakeswapV2Router.addLiquidityETH{value: ethAmount_}(
            address(this),
            tokenAmount_,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(0),
            block.timestamp
        );

        return true;
    }

    function buyDotCoin() external payable returns(bool){

        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = pancakeswapV2Router.WETH();

        // make the swap
        pancakeswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens(0, path, _msgSender(), block.timestamp);

        return true;
    }

    // Add Liquidity with BNB
    function addLiquidityBNB(uint256 tokenAmount_) external payable returns(bool) {

        //Transfer tokens to contract
        require(balanceOf(_msgSender())>=tokenAmount_,"You don`t have required amount of tokens");

        _tokenTransfer(_msgSender(), address(this), tokenAmount_, false);

        (bool addLiquidityStatus)=_addLiquidity(tokenAmount_, msg.value);
        require(addLiquidityStatus,"Unable to add liquidity");

        return true;
    }

    // Returns Current Price Of Dot Coin
    function dotCoinPrice() external view returns(uint256){

        // generate the pancakes swap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = pancakeswapV2Router.WETH();

        // make the swap
        uint256[] memory value=pancakeswapV2Router.getAmountsOut(1e18, path);
        return value[1];
    }


}

//SPDX-License-Identifier:MIT
pragma solidity >=0.6.2;

import './IPancakeSwapV2Router01.sol';

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
}

//SPDX-License-Identifier:MIT
pragma solidity >=0.6.2;
pragma solidity >=0.6.2;

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

//SPDX-License-Identifier:MIT
pragma solidity >=0.5.0;

interface IPancakePair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

//SPDX-License-Identifier:MIT
pragma solidity >=0.5.0;

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly
                /// @solidity memory-safe-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }


    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}