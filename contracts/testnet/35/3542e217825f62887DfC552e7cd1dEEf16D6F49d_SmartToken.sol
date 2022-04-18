// SPDX-License-Identifier: MIT

/**
 * Smart Token
 * @author Sho
 */

pragma solidity 0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/Context.sol';
import '@openzeppelin/contracts/utils/math/SafeMath.sol';
import './libs/IBEP20.sol';
import './libs/TransferHelper.sol';
import './interfaces/IWETH.sol';
import './interfaces/IUniswapRouter.sol';
import './interfaces/IUniswapFactory.sol';
import './interfaces/IUniswapPair.sol';
import './interfaces/IGoldenTreePool.sol';
import './interfaces/ISmartArmy.sol';
import './interfaces/ISmartLadder.sol';
import './interfaces/ISmartFarm.sol';
import './interfaces/ISmartComp.sol';
import './interfaces/ISmartNobilityAchievement.sol';
import './interfaces/ISmartOtherAchievement.sol';

contract SmartToken is Context, IBEP20, Ownable {
    using SafeMath for uint256;

    uint256 private _totalSupply = 15000000 * 1e18;
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    address private _uniswapV2ETHPair;
    address private _uniswapV2BUSDPair;
    address public constant BURN_ADDRESS = 0x000000000000000000000000000000000000dEaD;

    address private _operator;
    address private _smartArmy;
    ISmartComp private comptroller;
    
    // tax addresses
    address private _referralAddress;
    address private _goldenTreePoolAddress;
    address private _devAddress;
    address private _nobilityAchievementAddress;
    address private _otherAchievementAddress;
    address private _farmingRewardAddress;
    address private _intermediaryAddress;
    address private _airdropAddress;
    address private _privateSale;

    // Buy Tax information
    uint256 public _buyIntermediaryTaxFee = 10;
    uint256 public _buyNormalTaxFee = 15; // the % amount of buying amount when buying SMT token

    uint256 public _buyReferralFee = 50;
    uint256 public _buyGoldenPoolFee = 30;
    uint256 public _buyDevFee = 10;
    uint256 public _buyAchievementFee = 10;

    // Sell Tax information
    uint256 public _sellIntermediaryTaxFee = 10;
    uint256 public _sellNormalTaxFee = 15; // the % amount of selling amount when selling SMT token

    uint256 public _sellDevFee = 10;
    uint256 public _sellGoldenPoolFee = 30;
    uint256 public _sellFarmingFee = 20;
    uint256 public _sellBurnFee = 30;
    uint256 public _sellAchievementFee = 10;

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;

    bool _isLockedDevTax;    
    bool _isLockedGoldenTreeTax;
    bool _isLockedFarmingTax;
    bool _isLockedBurnTax;
    bool _isLockedAchievementTax;
    bool _isLockedReferralTax;

    // Transfer Tax information
    uint256 public _transferIntermediaryTaxFee = 10;
    uint256 public _transferNormalTaxFee = 15; // the % amount of transfering amount when transfering SMT token

    uint256 public _transferDevFee = 10;
    uint256 public _transferAchievementFee = 10;
    uint256 public _transferGoldenFee = 50;
    uint256 public _transferFarmingFee = 30;

    uint256 public _liquidityDist; // SMT-BNB liquidity distribution (locked)
    uint256 public _farmingRewardDist; // farming rewards distribution (locked)
    uint256 public _presaleDist; // presale distribution
    uint256 public _privateSaleDist; // private sale distribution
    uint256 public _airdropDist; // airdrop distribution
    uint256 public _suprizeRewardsDist; // surprize rewards distribution (locked)
    uint256 public _chestRewardsDist; // chest rewards distribution (locked)
    uint256 public _devDist; // marketing & development distribution (unlocked)

    bool _isSwap = false;    

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _excludedFromFee;
    mapping(address => address) private _mapAssetToPair; // Asset --> SMT-Asset Pair
    mapping(address => uint256) private _mapSurprizeRewardPaid; // User => surprize rewards paid

    event TaxAddressesUpdated(
        address indexed referral, 
        address indexed goldenTree, 
        address indexed dev, 
        address achievement, 
        address farming
    );

    event ExcludeFromFee(address indexed account, bool excluded);

    event UpdatedBuyFee(uint256 buyTaxFee);
    event UpdatedSellFee(uint256 sellTaxFee);
    event UpdatedTransferFee(uint256 transferTaxFee);

    event UpdatedBuyTaxFees(
        uint256 referralFee,
        uint256 goldenPoolFee,
        uint256 devFee,
        uint256 achievementFee        
    );
    event UpdatedSellTaxFees(
        uint256 devFee,
        uint256 goldenPoolFee,
        uint256 farmingFee,
        uint256 burnFee,
        uint256 achievementFee
    );
    event UpdatedTransferTaxFees(
        uint256 devFee,
        uint256 achievementFee,
        uint256 goldenPoolFee,
        uint256 farmingFee
    );
    event UpdatedTaxes(
        uint256 buyNormalTax,
        uint256 sellNormalTax,
        uint256 transferNormalTax,
        uint256 buyIntermediaryTax,
        uint256 sellIntermediaryTax,
        uint256 transferIntermediaryTax
    );
    event UpdatedTaxLockStatus(
        bool lockDevTax,
        bool lockGoldenTreeTax,
        bool lockFarmingTax,
        bool lockBurnTax,
        bool lockAchievementTax,
        bool lockReferralTax
    );

    event ResetedTimestamp(uint256 start_timestamp);

    event UpdatedGoldenTree(address indexed _address);
    event UpdatedSmartArmy(address indexed _address);

    event UpdatedExchangeRouter(address indexed _router);

    event AddedWhitelist(uint256 lengthOfWhitelist);
    event UpdatedWhitelistAccount(address account, bool enable);

    event CreatedPair(
        address indexed tokenA,
        address indexed tokenB
    );

    event CreatedBNBPair(address indexed _selfToken);

    event UpdatedBuyingTokenInfo(
        address _assetToken,
        uint256 _price,
        uint256 _decimal
    );

    event UpdatedBNBInfo(
        uint256 _price,
        uint256 _decimal
    );

    event TransferedOwnership(
        address oldOwner, 
        address newOwner
    );

    modifier onlyOperator() {
        require(_operator == msg.sender || msg.sender == owner(), "SMT: caller is not the operator");
        _;
    }

    modifier lockSwap() {
        _isSwap = true;
        _;
        _isSwap = false;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Sets the values for busdContract, {totalSupply} and tax addresses
     *
     */
    constructor(
        address smartComp,
        address dev,
        address airdrop,
        address privateSale
    ) {
        _name = "Smart Token";
        _symbol = "SMT";
        _decimals = 18;
        _totalSupply = _totalSupply;

        comptroller = ISmartComp(smartComp);
        _referralAddress = address(comptroller.getSmartLadder());
        _goldenTreePoolAddress = address(comptroller.getGoldenTreePool());
        _nobilityAchievementAddress = address(comptroller.getSmartNobilityAchievement());
        _otherAchievementAddress = address(comptroller.getSmartOtherAchievement());
        _farmingRewardAddress = address(comptroller.getSmartFarm());
        _intermediaryAddress = comptroller.getSmartBridge();
        _smartArmy = address(comptroller.getSmartArmy());
        _devAddress = dev;
        _airdropAddress = airdrop;
        _privateSale = privateSale;
        _operator = msg.sender;

        _excludedFromFee[_referralAddress] = true;
        _excludedFromFee[_goldenTreePoolAddress] = true;
        _excludedFromFee[_nobilityAchievementAddress] = true;
        _excludedFromFee[_otherAchievementAddress] = true;
        _excludedFromFee[_farmingRewardAddress] = true;
        _excludedFromFee[_intermediaryAddress] = true;
        _excludedFromFee[_devAddress] = true;
        _excludedFromFee[_airdropAddress] = true;
        _excludedFromFee[smartComp] = true;
        _excludedFromFee[_smartArmy] = true;
        _excludedFromFee[_privateSale] = true;
        _excludedFromFee[_operator] = true;
        _excludedFromFee[address(this)] = true;

        IUniswapV2Router02 _uniswapV2Router = comptroller.getUniswapV2Router();
        IERC20 busdContract = comptroller.getBUSD();

        _uniswapV2ETHPair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        _uniswapV2BUSDPair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), address(busdContract));


        // farming reward mint.
        _farmingRewardDist = _totalSupply.div(1e5).mul(56037);
        _balances[_farmingRewardAddress] = _balances[_farmingRewardAddress].add(_farmingRewardDist);

        // presale mint.
        _presaleDist = _totalSupply.div(1e5).mul(13333);
        _balances[_operator] = _balances[_operator].add(_presaleDist);

        // private sale mint.
        _privateSaleDist = _totalSupply.div(1e5).mul(3333);
        _balances[_privateSale] = _balances[_privateSale].add(_privateSaleDist);

        // mint initial liquidity to owner wallet.
        _liquidityDist = _totalSupply.div(1e5).mul(11333);
        _balances[_operator] = _balances[_operator].add(_liquidityDist);

        // mint chest rewards to achievement contract.
        _chestRewardsDist = _totalSupply.div(1e5).mul(8864);
        _balances[_nobilityAchievementAddress] = _balances[_nobilityAchievementAddress].add(_chestRewardsDist);

        // mint surprize rewards to achievement contract.
        _suprizeRewardsDist = _totalSupply.div(100).mul(6);
        _balances[_otherAchievementAddress] = _balances[_otherAchievementAddress].add(_suprizeRewardsDist);

        // mint some tokens to airdrop wallet.
        _airdropDist = _totalSupply.div(100);
        _balances[_airdropAddress] = _balances[_airdropAddress].add(_airdropDist);

        // mint some tokens to dev wallet.
        _devDist = _totalSupply.div(1000);
        _balances[_devAddress] = _balances[_devAddress].add(_devDist);
        _status = _NOT_ENTERED;
    }

    function getOwner() external override view returns (address) {
        return owner();
    }

    function getETHPair() external view returns (address) {
        return _uniswapV2ETHPair;
    }

    function getBUSDPair() external view returns (address) {
        return _uniswapV2BUSDPair;
    }

    function name() external override view returns (string memory) {
        return _name;
    }

    function symbol() external override view returns (string memory) {
        return _symbol;
    }

    function decimals() external override view returns (uint8) {
        return _decimals;
    }

    function totalSupply() external override view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external override view returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner, address spender) external override view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external override nonReentrant returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), 'SMT: approve from the zero address');
        require(spender != address(0), 'SMT: approve to the zero address');

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        _transferFrom(_msgSender(), recipient, amount);
        return true;
    }

    function transferFrom(
        address sender, 
        address recipient, 
        uint256 amount
    ) public virtual override returns (bool) {
        _transferFrom(sender, recipient, amount);
        if(_msgSender()!=recipient || !_excludedFromFee[recipient])
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(amount, 'SMT: transfer amount exceeds allowance')
        );        
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) external nonReentrant returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) external nonReentrant returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, 'SMT: decreased allowance below zero'));
        return true;
    }

    function _transferFrom(
        address sender, 
        address recipient, 
        uint256 amount
    ) internal virtual {
        require(sender != address(0), 'SMT: transfer from the zero address');
        require(recipient != address(0), 'SMT: transfer to the zero address');
        require(_balances[sender] >= amount, "SMT: balance of sender is too small.");
        
        if (_isSwap || _excludedFromFee[sender] || _excludedFromFee[recipient]) {
            _transfer(sender, recipient, amount);
        } else {
            bool toPair = recipient == _uniswapV2ETHPair || recipient == _uniswapV2BUSDPair;
            bool fromPair = sender == _uniswapV2ETHPair || sender == _uniswapV2BUSDPair;
            if(sender == _intermediaryAddress && toPair) {
                // Intermediary => Pair: No Fee
                uint256 taxAmount = amount.mul(_sellIntermediaryTaxFee).div(100);
                uint256 recvAmount = amount.sub(taxAmount);    
                distributeSellTax(sender, taxAmount);
                _transfer(sender, recipient, recvAmount);
            } else if(fromPair && recipient == _intermediaryAddress) {
                // Pair => Intermediary: No Fee
                uint256 taxAmount = amount.mul(_buyIntermediaryTaxFee).div(100);
                uint256 recvAmount = amount.sub(taxAmount);
                distributeBuyTax(sender, recipient, taxAmount);
                _transfer(sender, recipient, recvAmount);
            } else if(sender == _intermediaryAddress || recipient == _intermediaryAddress) {
                if (recipient == _intermediaryAddress) {
                    require(enabledIntermediary(sender), "SMT: no smart army account");
                    // sell transfer via intermediary: sell tax reduce 30%
                    uint256 taxAmount = amount.mul(_transferIntermediaryTaxFee.mul(700).div(1000)).div(100);
                    uint256 recvAmount = amount.sub(taxAmount);
                    distributeSellTax(sender, taxAmount);
                    _transfer(sender, recipient, recvAmount);
                } else {
                    require(enabledIntermediary(recipient), "SMT: no smart army account");
                    // buy transfer via intermediary: buy tax reduce 30%
                    uint256 taxAmount = amount.mul(_transferIntermediaryTaxFee.mul(700).div(1000)).div(100);
                    uint256 recvAmount = amount.sub(taxAmount);                    
                    distributeBuyTax(sender, recipient, taxAmount);
                    _transfer(sender, recipient, recvAmount);
                }
            } else if(fromPair) {
                // buy transfer
                uint256 taxAmount = amount.mul(_buyNormalTaxFee).div(100);
                uint256 recvAmount = amount.sub(taxAmount);
                distributeBuyTax(sender, recipient, taxAmount);
                _transfer(sender, recipient, recvAmount);
            } else if(toPair) {
                // sell transfer 
                uint256 taxAmount = amount.mul(_sellNormalTaxFee).div(100);
                uint256 recvAmount = amount.sub(taxAmount);
                distributeSellTax(sender, taxAmount);
                _transfer(sender, recipient, recvAmount);
            } else {
                // normal transfer
                uint256 taxAmount = amount.mul(_transferNormalTaxFee).div(100);
                uint256 recvAmount = amount.sub(taxAmount);  
                distributeTransferTax(sender, taxAmount);
                _transfer(sender, recipient, recvAmount);
            }
        }
    }

    function _transfer(address _from, address _to, uint256 _amount) internal {
        require(_balances[_from] - _amount >= 0, "amount exceeds current balance");
        _balances[_to] += _amount;
        _balances[_from] -= _amount;
        emit Transfer(_from, _to, _amount);
    }

    function _transferToGoldenTreePool(address _sender, uint256 amount) internal {
        _transfer(_sender, address(this), amount);
        _swapTokenForBUSD(_goldenTreePoolAddress, amount);
        IGoldenTreePool(_goldenTreePoolAddress).notifyReward(amount, _sender);
    }

    function _transferToAchievement(address _sender, uint256 amount) internal {        
        _transfer(_sender, address(this), amount);
        _swapTokenForBNB(_otherAchievementAddress, amount);
    }

    function distributeSellTax (
        address sender,
        uint256 amount
    ) internal {
        if(!_isLockedDevTax) {
            uint256 devAmount = amount.mul(_sellDevFee).div(100);
            _transfer(sender, _devAddress, devAmount);
        }
        if(!_isLockedGoldenTreeTax) {
            uint256 goldenTreeAmount = amount.mul(_sellGoldenPoolFee).div(100);
            _transfer(sender, _goldenTreePoolAddress, goldenTreeAmount);
            distributeTaxToGoldenTreePool(sender, goldenTreeAmount);
        }
        if(!_isLockedFarmingTax) {
            uint256 farmingAmount = amount.mul(_sellFarmingFee).div(100);
            _transfer(sender, _farmingRewardAddress, farmingAmount);
            distributeSellTaxToFarming(farmingAmount);
        }
        if(!_isLockedBurnTax) {
            uint256 burnAmount = amount.mul(_sellBurnFee).div(100);
            _transfer(sender, BURN_ADDRESS, burnAmount);
        }
        if(!_isLockedAchievementTax) {
            uint256 achievementAmount = amount.mul(_sellAchievementFee).div(100);
            _transfer(sender, _otherAchievementAddress, achievementAmount);
            distributeTaxToAchievement(achievementAmount);
        }
    }

    /**
     * @dev Distributes buy tax tokens to tax addresses
    */
    function distributeBuyTax(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        if(!_isLockedReferralTax) {
            uint256 referralAmount = amount.mul(_buyReferralFee).div(100);
            _transfer(sender, _referralAddress, referralAmount);
            distributeBuyTaxToLadder(recipient);
        }
        if(!_isLockedGoldenTreeTax) {
            uint256 goldenTreeAmount = amount.mul(_buyGoldenPoolFee).div(100);
            _transfer(sender, _goldenTreePoolAddress, goldenTreeAmount);
            distributeTaxToGoldenTreePool(recipient, goldenTreeAmount);
        }
        if(!_isLockedDevTax) {
            uint256 devAmount = amount.mul(_buyDevFee).div(100);
            _transfer(sender, _devAddress, devAmount);
        }
        if(!_isLockedAchievementTax) {
            uint256 achievementAmount = amount.mul(_buyAchievementFee).div(100);
            _transfer(sender, _otherAchievementAddress, achievementAmount);
            distributeTaxToAchievement(achievementAmount);
        }
    }

    /**
     * @dev Distributes transfer tax tokens to tax addresses
     */
    function distributeTransferTax(
        address sender,
        uint256 amount
    ) internal {

        if(!_isLockedGoldenTreeTax) {
            uint256 goldenTreeAmount = amount.mul(_transferGoldenFee).div(100);
            _transfer(sender, _goldenTreePoolAddress, goldenTreeAmount);
            distributeTaxToGoldenTreePool(sender, goldenTreeAmount);
        }
        if(!_isLockedDevTax) {
            uint256 devAmount = amount.mul(_transferDevFee).div(100);
            _transfer(sender, _devAddress, devAmount);
        }
        if(!_isLockedFarmingTax) {
            uint256 farmingAmount = amount.mul(_transferFarmingFee).div(100);
            _transfer(sender, _farmingRewardAddress, farmingAmount);
        }
        if(!_isLockedAchievementTax) {
            uint256 achievementAmount = amount.mul(_transferAchievementFee).div(100);
            _transfer(sender, _nobilityAchievementAddress, achievementAmount);            
            distributeTaxToAchievement(achievementAmount);
        }
    }

    /**
     * @dev Distributes buy tax tokens to smart ladder system
     */
    function distributeBuyTaxToLadder(address from) internal {
        require(_referralAddress != address(0x0), "SmartLadder can't be zero address");
        ISmartLadder(_referralAddress).distributeBuyTax(from);
    }

    /**
     * @dev Distributes sell tax tokens to farmming passive rewards pool
     */
    function distributeSellTaxToFarming (uint256 amount) internal {
        require(_farmingRewardAddress != address(0x0), "SmartFarm can't be zero address");
        ISmartFarm(_farmingRewardAddress).notifyRewardAmount(amount);
        ISmartOtherAchievement ach = comptroller.getSmartOtherAchievement();
        ach.distributeSellTax(amount);
    }

    /**
     * @dev Distribute tax to golden Tree pool as SMT and notify
     */
    function distributeTaxToGoldenTreePool(address account, uint256 amount) internal {
        require(_goldenTreePoolAddress != address(0x0), "GoldenTreePool can't be zero address");
        IGoldenTreePool(_goldenTreePoolAddress).notifyReward(amount, account);
    }

    /**
     * @dev Distribute tax to golden Tree pool as SMT and notify
     */
    function distributeTaxToAchievement(uint256 amount) internal {
        require(_nobilityAchievementAddress != address(0x0), "GoldenTreePool can't be zero address");
        ISmartNobilityAchievement(_nobilityAchievementAddress).swapDistribute(amount);
        ISmartNobilityAchievement(_nobilityAchievementAddress).distributePassiveShare(amount);        
        addSurprizeDistributor();
    }

    function addSurprizeDistributor() internal {
        ISmartArmy license = comptroller.getSmartArmy();
        address sender = address(tx.origin);
        uint256 amount = _balances[sender] - _mapSurprizeRewardPaid[sender];
        if(license.isActiveLicense(sender) &&  amount >= 1e21) {
            ISmartOtherAchievement ach = comptroller.getSmartOtherAchievement();
            ach.distributeSurprizeReward(sender, amount/1e21);
            _mapSurprizeRewardPaid[sender] += amount;
        }
    }

    /**
     * @dev Returns the address is excluded from burn fee or not.
     */
    function isExcludedFromFee(address account) external view returns (bool) {
        return _excludedFromFee[account];
    }

    /**
     * @dev Exclude the address from fee.
     */
    function excludeFromFee(address account, bool excluded) external onlyOperator {
        require(_excludedFromFee[account] != excluded, "SMT: already excluded or included");
        _excludedFromFee[account] = excluded;

        emit ExcludeFromFee(account, excluded);
    }

    function getPair(address _assetToken) public view returns(address) {
        return _mapAssetToPair[_assetToken];
    }

    function transferOwnership(address account) public override onlyOperator {
        require(account != address(0x0), "owner account can't be zero address");
        address oldOwner = _operator;
        _operator = account;
        emit TransferedOwnership(oldOwner, account);
    }

    /**
     * @dev Sets value for _sellNormalTaxFee with {sellTaxFee} in emergency status.
     */
    function setSellFee(uint256 sellTaxFee) external onlyOperator {
        require(sellTaxFee < 100, 'SMT: sellTaxFee exceeds maximum value');
        _sellNormalTaxFee = sellTaxFee;
        emit UpdatedSellFee(sellTaxFee);
    }

    /**
     * @dev Sets value for _buyNormalTaxFee with {buyTaxFee} in emergency status.
     */
    function setBuyFee(uint256 buyTaxFee) external onlyOperator {
        require(buyTaxFee < 100, 'SMT: buyTaxFee exceeds maximum value');
        _buyNormalTaxFee = buyTaxFee;
        emit UpdatedBuyFee(buyTaxFee);
    }    

    /**
     * @dev Sets value for _transferNormalTaxFee with {transferTaxFee} in emergency status.
     */
    function setTransferFee (uint256 transferTaxFee) external onlyOperator {
        require(transferTaxFee < 100, 'SMT: transferTaxFee exceeds maximum value');
        _transferNormalTaxFee = transferTaxFee;
        emit UpdatedTransferFee(transferTaxFee);
    }  

    /**
     *  @dev reset new router. 
    */
    function setSmartComp(
        address _smartComp
    ) public onlyOperator {
        require(address(_smartComp) != address(0x0), "Smart Comp address can't be zero address");
        comptroller = ISmartComp(_smartComp);
    }

    /**
     *  @dev reset new liquidity pool based on router. 
    */
    function createBNBPair() public onlyOperator {
        require(address(comptroller) != address(0x0), "SmartComp address can't be zero address");        
        IUniswapV2Router02 router = comptroller.getUniswapV2Router();
        _uniswapV2ETHPair = IUniswapV2Factory(router.factory())
            .createPair(address(this), router.WETH());
        emit CreatedBNBPair(address(this));
    }    

    function createBUSDPair(address _busdToken) public onlyOperator {
        createPair(_busdToken);
        _uniswapV2BUSDPair = getPair(_busdToken);
    }

    /**
     *  @dev reset new liquidity pool based on router. 
    */
    function createPair(address _assetToken) public onlyOperator {
        require(address(comptroller) != address(0x0), "SmartComp can't be zero address");
        require(address(_assetToken) != address(0x0), "Asset token address can't be zero address");

        IUniswapV2Router02 router = comptroller.getUniswapV2Router();
        address pairAsset = IUniswapV2Factory(router.factory()).createPair(address(this), _assetToken);
        _mapAssetToPair[_assetToken] = pairAsset;
        emit CreatedPair(address(this), _assetToken);
    }

    /**
     *  @dev Sets tax fees
    */
    function setTaxLockStatus(
        bool lockDevTax,
        bool lockGoldenTreeTax,
        bool lockFarmingTax,
        bool lockBurnTax,
        bool lockAchievementTax,
        bool lockReferralTax
    ) external onlyOperator {
        _isLockedDevTax = lockDevTax;
        _isLockedGoldenTreeTax = lockGoldenTreeTax;
        _isLockedFarmingTax = lockFarmingTax;
        _isLockedBurnTax = lockBurnTax;
        _isLockedAchievementTax = lockAchievementTax;
        _isLockedReferralTax = lockReferralTax;
        emit UpdatedTaxLockStatus(
            lockDevTax,
            lockGoldenTreeTax,
            lockFarmingTax,
            lockBurnTax,
            lockAchievementTax,
            lockReferralTax
        );
    }

    /**
     *  @dev Sets tax fees
    */
    function setTaxFees(
        uint256 buyNormalTax,
        uint256 sellNormalTax,
        uint256 transferNormalTax,
        uint256 buyIntermediaryTax,
        uint256 sellIntermediaryTax,
        uint256 transferIntermediaryTax
    ) external onlyOperator {
        _buyNormalTaxFee = buyNormalTax;
        _sellNormalTaxFee = sellNormalTax;
        _transferNormalTaxFee = transferNormalTax;
        _buyIntermediaryTaxFee = buyIntermediaryTax;
        _sellIntermediaryTaxFee = sellIntermediaryTax;
        _transferIntermediaryTaxFee = transferIntermediaryTax;
        emit UpdatedTaxes(
            buyNormalTax,
            sellNormalTax,
            transferNormalTax,
            buyIntermediaryTax,
            sellIntermediaryTax,
            transferIntermediaryTax
        );
    }

    /**
     *  @dev Sets buying tax fees
    */
    function setBuyTaxFees(
        uint256 referralFee,
        uint256 goldenPoolFee,
        uint256 devFee,
        uint256 achievementFee
    ) external onlyOperator {
        _buyReferralFee = referralFee;
        _buyGoldenPoolFee = goldenPoolFee;
        _buyDevFee = devFee;
        _buyAchievementFee = achievementFee;
        emit UpdatedBuyTaxFees(
            referralFee, 
            goldenPoolFee, 
            devFee, 
            achievementFee
        );
    }

    /**
     *  @dev Sets selling tax fees
    */
    function setSellTaxFees(
        uint256 devFee,
        uint256 goldenPoolFee,
        uint256 farmingFee,
        uint256 burnFee,
        uint256 achievementFee
    ) external onlyOperator {
        _sellDevFee = devFee;
        _sellGoldenPoolFee = goldenPoolFee;
        _sellFarmingFee = farmingFee;
        _sellBurnFee = burnFee;
        _sellAchievementFee = achievementFee;
        emit UpdatedSellTaxFees(
            devFee, 
            goldenPoolFee, 
            farmingFee, 
            burnFee, 
            achievementFee
        );
    }

    /**
     *  @dev Sets buying tax fees
    */
    function setTransferTaxFees(
        uint256 devFee,
        uint256 achievementFee,
        uint256 goldenPoolFee,
        uint256 farmingFee
    ) external onlyOperator {
        _transferDevFee = devFee;
        _transferAchievementFee = achievementFee;
        _transferGoldenFee = goldenPoolFee;
        _transferFarmingFee = farmingFee;
        emit UpdatedTransferTaxFees(
            devFee, 
            achievementFee, 
            goldenPoolFee, 
            farmingFee
        );
    }

    /**
     *  @dev Sets values for tax addresses 
     */
    function setTaxAddresses(
        address referral, 
        address goldenTree, 
        address achievement, 
        address farming, 
        address intermediary,
        address dev, 
        address airdrop
    ) external onlyOperator {

        if (_referralAddress != referral && referral != address(0x0)) {
            _excludedFromFee[_referralAddress] = false;
            _referralAddress = referral;
            _excludedFromFee[referral] = true;
        }
        if (_goldenTreePoolAddress != goldenTree && goldenTree != address(0x0)) {
            _excludedFromFee[_goldenTreePoolAddress] = false;
            _goldenTreePoolAddress = goldenTree;
            _excludedFromFee[goldenTree] = true;
        }
        if (_devAddress != dev && dev != address(0x0)) {
            _excludedFromFee[_devAddress] = false;
            _devAddress = dev;
            _excludedFromFee[dev] = true;
        }
        if (_otherAchievementAddress != achievement && achievement != address(0x0)) {
            _excludedFromFee[_otherAchievementAddress] = false;
            _otherAchievementAddress = achievement;
            _excludedFromFee[achievement] = true;
        }
        if (_farmingRewardAddress != farming && farming != address(0x0)) {
            _excludedFromFee[_farmingRewardAddress] = false;
            _farmingRewardAddress = farming;
            _excludedFromFee[farming] = true;
        }
        if (_airdropAddress != airdrop && airdrop != address(0x0)) {
            _excludedFromFee[_airdropAddress] = false;
            _airdropAddress = airdrop;
            _excludedFromFee[airdrop] = true;
        }
        if (_intermediaryAddress != intermediary && intermediary != address(0x0)) {
            _intermediaryAddress = intermediary;
        }
        emit TaxAddressesUpdated(referral, goldenTree, dev, achievement, farming);
    }

    /**
     * @dev Sets value for _goldenTreePoolAddress
     */
    function setGoldenTreeAddress (address _address) external onlyOperator {
        require(_address!= address(0x0), 'SMT: not allowed zero address');
        _goldenTreePoolAddress = _address;

        emit UpdatedGoldenTree(_address);
    }

    /**
     * @dev Sets value for _smartArmy
     */
    function setSmartArmyAddress(address _address) external onlyOperator {
        require(_address!= address(0x0), 'SMT: not allowed zero address');
        _smartArmy = _address;

        emit UpdatedSmartArmy(_address);
    }
    
    function enabledIntermediary(address account) public view returns (bool){
        if(_smartArmy == address(0x0)) {
            return false;
        }
        return ISmartArmy(_smartArmy).isEnabledIntermediary(account);
    }

    function _swapTokenForBUSD(address to, uint256 tokenAmount) private lockSwap {
        IERC20 busdToken = comptroller.getBUSD();
        IUniswapV2Router02 uniswapV2Router = comptroller.getUniswapV2Router();

        // generate the uniswap pair path of token -> busd
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(busdToken);

        _approve(address(this), address(uniswapV2Router), tokenAmount);
        // make the swap
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            to,
            block.timestamp
        );
    }

    function _swapTokenForBNB(address to, uint256 tokenAmount) private lockSwap{
        IUniswapV2Router02 uniswapV2Router = comptroller.getUniswapV2Router();

        // generate the uniswap pair path of token -> busd
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(uniswapV2Router.WETH());

        _approve(address(this), address(uniswapV2Router), tokenAmount);
        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            to,
            block.timestamp
        );
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
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
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

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
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
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

pragma solidity 0.8.4;

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address _owner, address spender) external view returns (uint256);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    address constant NATIVE_TOKEN = address(0);

    function isEther(address token) internal pure returns (bool) {
      return token == NATIVE_TOKEN;
    }

    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }

    function safeTransferTokenOrETH(address token, address to, uint value) internal {
        isEther(token) 
            ? safeTransferETH(to, value)
            : safeTransfer(token, to, value);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

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

// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

interface IUniswapV2Factory {
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
pragma solidity 0.8.4;

interface IUniswapV2Pair {
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

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

interface IGoldenTreePool {
    function swapDistribute(uint256 _amount) external;
    function notifyReward(uint256 amount, address account) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

interface ISmartArmy {
    /// @dev License Types
    struct LicenseType {
        uint256  level;        // level
        string   name;         // Trial, Opportunist, Runner, Visionary
        uint256  price;        // 100, 1000, 5000, 10,000
        uint256  ladderLevel;  // Level of referral system with this license
        uint256  duration;     // default 6 months
        uint256  portions;
        bool     isValid;
    }

    enum LicenseStatus {
        None,
        Pending,
        Active,
        Expired
    }

    /// @dev User information on license
    struct UserLicense {
        address owner;
        uint256 level;
        uint256 startAt;
        uint256 activeAt;
        uint256 expireAt;
        uint256 lpLocked;
        string tokenUri;

        LicenseStatus status;
    }

    /// @dev User Personal Information
    struct UserPersonal {
        address sponsor;
        string username;
        string telegram;
    }

    /// @dev Fee Info 
    struct FeeInfo {
        uint256 penaltyFeePercent;      // liquidate License LP fee percent
        uint256 extendFeeBNB;       // extend Fee as BNB
        address feeAddress;
    }

    function licenseOf(address account) external view returns(UserLicense memory);
    function licensePortionOf(address account) external view returns(uint256);
    function licenseIdOf(address account) external view returns(uint256);
    function licenseTypeOf(uint256 level) external view returns(LicenseType memory);
    function lockedLPOf(address account) external view returns(uint256);
    function isActiveLicense(address account) external view returns(bool);
    function isEnabledIntermediary(address account) external view returns(bool);
    function licenseLevelOf(address account) external view returns(uint256);
    function licensedUsers() external view returns(address[] memory);
    function licenseActiveDuration(address account, uint256 from, uint256 to) external view returns(uint256, uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

interface ISmartLadder {
    /// @dev Ladder system activities
    struct Activity {
        string      name;         // buytax, farming, ...
        uint16[7]   share;        // share percentage
        address     token;        // share token address
        bool        enabled;      // enabled or disabled temporally
        bool        isValid;
        uint256     totalDistributed; // total distributed
    }
    
    function registerSponsor(address _user, address _sponsor) external;
    function distributeTax(uint256 id, address account) external; 
    function distributeBuyTax(address account) external; 
    function distributeFarmingTax(address account) external; 
    function distributeSmartLivingTax(address account) external; 
    function distributeEcosystemTax(address account) external; 
    
    function activity(uint256 id) external view returns(Activity memory);
    function sponsorOf(address account) external view returns(address);
    function usersOf(address _sponsor) external view returns(address[] memory);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

interface ISmartFarm {
    /// @dev Pool Information
    struct PoolInfo {
        address stakingTokenAddress;     // staking contract address
        address rewardTokenAddress;      // reward token contract
        uint256 rewardPerDay;            // reward percent per day
        uint unstakingFee;            
        uint256 totalStaked;             /* How many tokens we have successfully staked */
    }

    struct UserInfo {
        uint256 tokenBalance;
        uint256 balance;
        uint256 havested;
        uint256 rewards;
        uint256 rewardPerTokenPaid;     // User rewards per token paid for passive
        uint256 lastUpdated;
    }
    
    function stakeSMT(address account, uint256 amount) external returns(uint256);
    function withdrawSMT(address account, uint256 amount) external returns(uint256);
    function claimReward(uint256 _amount) external;
    function notifyRewardAmount(uint _reward) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import './ISmartArmy.sol';
import './ISmartLadder.sol';
import './ISmartFarm.sol';
import './IGoldenTreePool.sol';
import './ISmartNobilityAchievement.sol';
import './ISmartOtherAchievement.sol';
import './IUniswapRouter.sol';
import "./ISmartTokenCash.sol";

// Smart Comptroller Interface
interface ISmartComp {
    function isComptroller() external pure returns(bool);
    function getSMT() external view returns(IERC20);
    function getBUSD() external view returns(IERC20);
    function getWBNB() external view returns(IERC20);

    function getSMTC() external view returns(ISmartTokenCash);
    function getUniswapV2Router() external view returns(IUniswapV2Router02);
    function getUniswapV2Factory() external view returns(address);
    function getSmartArmy() external view returns(ISmartArmy);
    function getSmartLadder() external view returns(ISmartLadder);
    function getSmartFarm() external view returns(ISmartFarm);
    function getGoldenTreePool() external view returns(IGoldenTreePool);
    function getSmartNobilityAchievement() external view returns(ISmartNobilityAchievement);
    function getSmartOtherAchievement() external view returns(ISmartOtherAchievement);
    function getSmartBridge() external view returns(address);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

interface ISmartNobilityAchievement {

    struct NobilityType {
        string            title;               // Title of Nobility Folks Baron Count Viscount Earl Duke Prince King
        uint256           growthRequried;      // Required growth token
        uint256           goldenTreeRewards;   // SMTC golden tree rewards
        uint256           passiveShare;        // Passive share percent
        uint256           availableTitles;     // Titles available
        uint256[]         chestSMTRewardPool;
        uint256[]         chestSMTCRewardPool;        
    }

    struct UserInfo {
        uint256[] chestRewards; // 0: SMT,  1: SMTC
        uint256 checkRewardUpdated;
        uint256[] nobleRewards; // 0: claim, 1: unclaim
        uint256[] passiveShareRewards; // 0: claim, 1: unclaim
    }

    function claimChestSMTReward(uint256) external;
    function claimChestSMTCReward(uint256) external;
    function claimNobleReward(uint256) external;
    function claimPassiveShareReward(uint256) external;

    function distributeToNobleLeaders(uint256) external;
    function distributePassiveShare(uint256) external;

    function notifyGrowth(address, uint256, uint256) external returns(bool);

    function swapDistribute(uint256) external;

    function isNobleLeader(address) external view returns(bool);
    function isUpgradeable(uint256, uint256) external view returns(bool, uint256);

    function nobilityOf(address) external view returns(NobilityType memory);
    function nobilityTitleOf(address) external view returns(string memory);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

interface ISmartOtherAchievement {

    struct UserInfo {
        uint256[] surprizeRewards; // 0: SMT, 1: SMTC
        uint256[] farmRewards;  // 0: claim, 1: unclaim
        uint256[] sellTaxRewards;  // 0: claim, 1: unclaim
    }

    function claimFarmReward(uint256) external;
    function claimSurprizeSMTReward(uint256) external;
    function claimSurprizeSMTCReward(uint256) external;
    function claimSellTaxReward(uint256) external;

    function distributeSellTax(uint256) external;
    function distributeToFarmers(uint256) external;
    function distributeSurprizeReward(address, uint256) external;

    function addFarmDistributor(address) external;
    function removeFarmDistributor(address) external;

    function swapDistribute(uint256) external;

    function isFarmer(address) external view returns(bool);

}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import '../libs/IBEP20.sol';

interface ISmartTokenCash is IBEP20 {
    function burn(uint256 amount) external; 
}