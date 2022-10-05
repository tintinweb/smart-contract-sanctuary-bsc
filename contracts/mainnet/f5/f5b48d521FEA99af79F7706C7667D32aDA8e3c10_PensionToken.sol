/**
 *Submitted for verification at BscScan.com on 2022-10-05
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

}

interface InterfaceLP {
    function sync() external;
}

library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    function add(Role storage role, address account) internal {
        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    function remove(Role storage role, address account) internal {
        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}

abstract contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor(
        string memory _tokenName,
        string memory _tokenSymbol,
        uint8 _tokenDecimals
    ) {
        _name = _tokenName;
        _symbol = _tokenSymbol;
        _decimals = _tokenDecimals;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }
}

interface IDEXRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
    function addLiquidity(address tokenA, address tokenB, uint amountADesired, uint amountBDesired, uint amountAMin, uint amountBMin, address to, uint deadline) external returns (uint amountA, uint amountB, uint liquidity);
}

interface IDEXFactory {
    function createPair(address tokenA, address tokenB)
    external
    returns (address pair);
}

contract Ownable {
    address private _owner;

    event OwnershipRenounced(address indexed previousOwner);

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _owner = msg.sender;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(msg.sender == _owner, "Not owner");
        _;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipRenounced(_owner);
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
contract WhitelistedRole is Ownable {
    using Roles for Roles.Role;

    event WhitelistedAdded(address indexed account);
    event WhitelistedRemoved(address indexed account);

    Roles.Role private _whitelisteds;

    modifier onlyWhitelisted() {
        require(isWhitelisted(msg.sender), "WhitelistedRole: caller does not have the Whitelisted role");
        _;
    }

    function isWhitelisted(address account) public view returns (bool) {
        return _whitelisteds.has(account);
    }

    function addWhitelisted(address account) public onlyOwner {
        _addWhitelisted(account);
    }

    function removeWhitelisted(address account) public onlyOwner {
        _removeWhitelisted(account);
    }

    function renounceWhitelisted() public {
        _removeWhitelisted(msg.sender);
    }

    function _addWhitelisted(address account) internal {
        _whitelisteds.add(account);
        emit WhitelistedAdded(account);
    }

    function _removeWhitelisted(address account) internal {
        _whitelisteds.remove(account);
        emit WhitelistedRemoved(account);
    }
}

contract TokenHandler is Ownable {
    function sendTokenToOwner(address token) external onlyOwner {
        if(IERC20(token).balanceOf(address(this)) > 0){
            IERC20(token).transfer(owner(), IERC20(token).balanceOf(address(this)));
        }
    }
}

contract PensionToken is ERC20Detailed, Ownable, WhitelistedRole {

    bool public initialDistributionFinished = false;
    bool public swapEnabled = true;
    bool public isLiquidityInBnb = true;

    uint256 public rewardYield = 4126398;
    uint256 public rewardYieldDenominator = 10000000000;

    uint256 public rebaseFrequency = 1800;
    uint256 public nextRebase = block.timestamp + 604800;

    mapping(address => bool) _isFeeExempt;
    address[] public _makerPairs;
    mapping (address => bool) public automatedMarketMakerPairs;

    uint256 public constant MAX_FEE_RATE = 20;
    uint256 private constant MAX_REBASE_FREQUENCY = 1800;
    uint256 private constant DECIMALS = 18;
    uint256 private constant MAX_UINT256 = type(uint256).max;
    uint256 private constant INITIAL_FRAGMENTS_SUPPLY = 10000 * 10**DECIMALS;
    uint256 private constant TOTAL_GONS = type(uint256).max - (type(uint256).max % INITIAL_FRAGMENTS_SUPPLY);
    uint256 private constant MAX_SUPPLY = ~uint128(0);

    event SwapBack(uint256 contractTokenBalance,uint256 amountToLiquify,uint256 amountToRFV,uint256 amountToTreasury);
    event SwapAndLiquify(uint256 tokensSwapped, uint256 bnbReceived, uint256 tokensIntoLiqudity);
    event SwapAndLiquifyBusd(uint256 tokensSwapped, uint256 busdReceived, uint256 tokensIntoLiqudity);
    event LogRebase(uint256 indexed epoch, uint256 totalSupply);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);

    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;

    address public marketingAddress;
    address public liquidityAddress;
    address public developmentAddress;
    address public teamAddress1;
    address public teamAddress2;
    address public teamAddress3;
    address public teamAddress4;
    address public buybackAddress;
    address public immutable BUSD;  // testnet: 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7, mainnet: 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56 

    IDEXRouter public immutable router;
    address public immutable pair;

    TokenHandler public tokenHandler;

    uint256 public liquidityFee = 3;
    uint256 public marketingFee = 3;
    uint256 public developmentFee = 2;
    uint256 public teamFee = 2;
    uint256 public buybackFee = 0;
    uint256 public totalFee = liquidityFee+(marketingFee)+(developmentFee)+teamFee + buybackFee;
    uint256 public feeDenominator = 100;

    bool inSwap;

    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }
    
    uint256 private _totalSupply;
    uint256 private _gonsPerFragment;
    uint256 private gonSwapThreshold = (TOTAL_GONS / 10000 * 10);

    mapping(address => uint256) private _gonBalances;
    mapping(address => mapping(address => uint256)) private _allowedFragments;

    modifier validRecipient(address to) {
        require(to != address(0x0));
        _;
    }

    constructor() ERC20Detailed("PensionToken", "Pension", 18) {
        address dexAddress;
        address busdAddress;
        if(block.chainid == 56){
            dexAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
            busdAddress = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
        } else if (block.chainid == 97){
            dexAddress = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1;
            busdAddress  = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7;
        } else {
            revert("Chain not configured");
        }

        marketingAddress = address(0xf03fDDE9162bEEc6b6735883a461dD751691d1b9);
        liquidityAddress = address(msg.sender);
        developmentAddress = address(0xaF7d033A858ce2C4891c8778B314D7a7a7bD9D40);
        teamAddress1 = address(0xBb6da379Ed680839c4E1Eb7fE49814cD6e7Cbf8a);
        teamAddress2 = address(0xC1c891711d3c927dce98055bA3a0735974817d62);
        teamAddress3 = address(0xA916350b5eA41aec0FF4d4D6Ce5eFBC1fd832C98);
        teamAddress4 = address(0x70Ac5F87B991209e26a60195dD6876aAd237239b);
        buybackAddress = address(msg.sender);

        router = IDEXRouter(dexAddress);
        BUSD = busdAddress;
        pair = IDEXFactory(router.factory()).createPair(address(this), BUSD);

        tokenHandler = new TokenHandler();

        _allowedFragments[address(this)][address(router)] = ~uint256(0);
        _allowedFragments[address(this)][pair] = ~uint256(0);
        _allowedFragments[address(this)][address(this)] = ~uint256(0);

        setAutomatedMarketMakerPair(pair, true);

        _totalSupply = INITIAL_FRAGMENTS_SUPPLY;
        _gonBalances[msg.sender] = TOTAL_GONS;
        _gonsPerFragment = TOTAL_GONS/(_totalSupply);

        addWhitelisted(address(this));
        addWhitelisted(msg.sender);
        addWhitelisted(dexAddress);
        addWhitelisted(address(0xdead));
        
        _isFeeExempt[address(this)] = true;
        _isFeeExempt[address(msg.sender)] = true;
        _isFeeExempt[address(dexAddress)] = true;
        _isFeeExempt[address(0xdead)] = true;

        emit Transfer(address(0x0), msg.sender, _totalSupply);  
    }

    receive() external payable {}

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function allowance(address owner_, address spender) external view override returns (uint256){
        return _allowedFragments[owner_][spender];
    }

    function balanceOf(address who) public view override returns (uint256) {
        return _gonBalances[who]/(_gonsPerFragment);
    }

    function checkFeeExempt(address _addr) external view returns (bool) {
        return _isFeeExempt[_addr];
    }

    function checkSwapThreshold() external view returns (uint256) {
        return gonSwapThreshold/(_gonsPerFragment);
    }

    function shouldRebase() public view returns (bool) {
        return nextRebase <= block.timestamp;
    }

    function shouldTakeFee(address from, address to) internal view returns (bool) {
        if(_isFeeExempt[from] || _isFeeExempt[to]){
            return false;
        } else {
            return (automatedMarketMakerPairs[from] || automatedMarketMakerPairs[to]);
        }
    }

    function shouldSwapBack() internal view returns (bool) {
        return
        !inSwap &&
        swapEnabled &&
        totalFee > 0 &&
        _gonBalances[address(this)] >= gonSwapThreshold;
    }

    function manualSync() public {
        for(uint i = 0; i < _makerPairs.length; i++){
            InterfaceLP(_makerPairs[i]).sync();
        }
    }

    function transfer(address to, uint256 value) external override validRecipient(to) returns (bool){
        _transferFrom(msg.sender, to, value);
        return true;
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        bool excludedAccount = inSwap || _isFeeExempt[sender] || _isFeeExempt[recipient] || automatedMarketMakerPairs[sender] || isWhitelisted(sender) || isWhitelisted(recipient);

        require(excludedAccount, "Only Exempt Contracts or Wallets may transfer tokens");

        if(!initialDistributionFinished){
            require(_isFeeExempt[sender] || _isFeeExempt[recipient], "Trading is paused");
        }

        uint256 gonAmount = amount*(_gonsPerFragment);

        _gonBalances[sender] = _gonBalances[sender]-(gonAmount);

        uint256 gonAmountReceived = shouldTakeFee(sender, recipient) ? takeFee(sender, gonAmount) : gonAmount;
        _gonBalances[recipient] = _gonBalances[recipient]+(gonAmountReceived);

        emit Transfer(sender, recipient, gonAmountReceived/(_gonsPerFragment));

        return true;
    }

    function transferFrom(address from, address to,  uint256 value) external override validRecipient(to) returns (bool) {
        if (_allowedFragments[from][msg.sender] != MAX_UINT256) {
            require(_allowedFragments[from][msg.sender] >= value,"Insufficient Allowance");
            _allowedFragments[from][msg.sender] = _allowedFragments[from][msg.sender]-(value);
        }
        _transferFrom(from, to, value);
        return true;
    }

    function swapBack() public onlyWhitelisted {

        if(!shouldSwapBack()){return;}

        uint256 contractBalance = balanceOf(address(this));
        
        // Halve the amount of liquidity tokens
        uint256 liquidityTokens = contractBalance * liquidityFee / totalFee / 2;
        
        swapTokensForBUSD(contractBalance - liquidityTokens);

        tokenHandler.sendTokenToOwner(address(BUSD));
        
        uint256 busdBalance = IERC20(BUSD).balanceOf(address(this));
        uint256 busdForLiquidity = busdBalance;

        uint256 busdForMarketing = busdBalance * marketingFee / (totalFee - (liquidityFee / 2));
        uint256 busdForDevelopment = busdBalance * developmentFee / (totalFee - (liquidityFee / 2));
        uint256 busdForTeam = busdBalance * teamFee / (totalFee - (liquidityFee / 2));
        uint256 busdForBuyback = busdBalance * buybackFee / (totalFee - (liquidityFee /2));

        busdForLiquidity -= busdForMarketing + busdForDevelopment + busdForTeam + busdForBuyback;
        
        if(liquidityTokens > 0 && busdForLiquidity > 0){
            addLiquidity(liquidityTokens, busdForLiquidity);
        }

        if(busdForTeam > 0){
            IERC20(BUSD).transfer(teamAddress1, busdForTeam/4);
            IERC20(BUSD).transfer(teamAddress2, busdForTeam/4);
            IERC20(BUSD).transfer(teamAddress3, busdForTeam/4);
            IERC20(BUSD).transfer(teamAddress4, busdForTeam/4);
        }

        if(busdForDevelopment > 0){
            IERC20(BUSD).transfer(developmentAddress, busdForDevelopment);
        }

        if(busdForBuyback> 0){
            IERC20(BUSD).transfer(buybackAddress, busdForBuyback);
        }

        if(busdForMarketing > 0){
            IERC20(BUSD).transfer(marketingAddress, IERC20(BUSD).balanceOf(address(this)));
        }
    }

    function swapTokensForBUSD(uint256 tokenAmount) private {

        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(BUSD);

        approve(address(router), tokenAmount);

        // make the swap
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(tokenHandler),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 busdAmount) private {
        // approve token transfer to cover all possible scenarios
        approve(address(router), tokenAmount);
        IERC20(BUSD).approve(address(router), busdAmount);

        // add the liquidity
        router.addLiquidity(address(this), address(BUSD), tokenAmount, busdAmount, 0,  0,  address(liquidityAddress), block.timestamp);
    }

    function takeFee(address sender, uint256 gonAmount) internal returns (uint256){
        uint256 _realFee = totalFee;

        uint256 feeAmount = gonAmount*(_realFee)/(feeDenominator);

        _gonBalances[address(this)] = _gonBalances[address(this)]+(feeAmount);
        emit Transfer(sender, address(this), feeAmount/(_gonsPerFragment));

        return gonAmount-(feeAmount);
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool){
        uint256 oldValue = _allowedFragments[msg.sender][spender];
        if (subtractedValue >= oldValue) {
            _allowedFragments[msg.sender][spender] = 0;
        } else {
            _allowedFragments[msg.sender][spender] = oldValue-(
                subtractedValue
            );
        }
        emit Approval(
            msg.sender,
            spender,
            _allowedFragments[msg.sender][spender]
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) external returns (bool){
        _allowedFragments[msg.sender][spender] = _allowedFragments[msg.sender][
        spender
        ]+(addedValue);
        emit Approval(
            msg.sender,
            spender,
            _allowedFragments[msg.sender][spender]
        );
        return true;
    }

    function approve(address spender, uint256 value) public override returns (bool){
        _allowedFragments[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function coreRebase(int256 supplyDelta) private returns (uint256) {
        uint256 epoch = block.timestamp;

        if (supplyDelta == 0) {
            emit LogRebase(epoch, _totalSupply);
            return _totalSupply;
        }

        if (supplyDelta < 0) {
            _totalSupply = _totalSupply-(uint256(-supplyDelta));
        } else {
            _totalSupply = _totalSupply+(uint256(supplyDelta));
        }

        if (_totalSupply > MAX_SUPPLY) {
            _totalSupply = MAX_SUPPLY;
        }

        _gonsPerFragment = TOTAL_GONS/(_totalSupply);

        nextRebase = epoch + rebaseFrequency;

        emit LogRebase(epoch, _totalSupply);
        return _totalSupply;
    }

    function manualRebase() external onlyWhitelisted {
        require(!inSwap, "Try again");
        require(nextRebase <= block.timestamp, "Not in time");

        int256 supplyDelta = int256(_totalSupply*(rewardYield)/(rewardYieldDenominator));

        coreRebase(supplyDelta);
        manualSync();
    }
    
    function setAutomatedMarketMakerPair(address _pair, bool _value) public onlyOwner {
        require(automatedMarketMakerPairs[_pair] != _value, "Value already set");

        automatedMarketMakerPairs[_pair] = _value;

        if(_value){
            _makerPairs.push(_pair);
        }else{
            require(_makerPairs.length > 1, "Required 1 pair");
            for (uint256 i = 0; i < _makerPairs.length; i++) {
                if (_makerPairs[i] == _pair) {
                    _makerPairs[i] = _makerPairs[_makerPairs.length - 1];
                    _makerPairs.pop();
                    break;
                }
            }
        }

        emit SetAutomatedMarketMakerPair(_pair, _value);
    }

    function enableTrading(bool _value) external onlyOwner {
        require(initialDistributionFinished != _value, "Not changed");
        initialDistributionFinished = _value;
        nextRebase = block.timestamp + rebaseFrequency;
    }

    function setFeeExempt(address _addr, bool _value) external onlyOwner {
        require(_isFeeExempt[_addr] != _value, "Not changed");
        _isFeeExempt[_addr] = _value;
    }

    function setFeeReceivers(address _liquidityReceiver, address _marketingReceiver, address _developmentReceiver, address _buybackReceiver) external onlyOwner {
        liquidityAddress = _liquidityReceiver;
        marketingAddress = _marketingReceiver;
        developmentAddress = _developmentReceiver;
        buybackAddress = _buybackReceiver;
    }

    function setTeamReceivers(address _team1, address _team2, address _team3, address _team4) external onlyOwner {
        teamAddress1 = _team1;
        teamAddress2 = _team2;
        teamAddress3 = _team3;
        teamAddress4 = _team4;
    }

    function setFees(uint256 _liquidityFee, uint256 _marketingFee, uint256 _developmentFee, uint256 _teamFee, uint256 _buybackFee) external onlyOwner {
        liquidityFee = _liquidityFee;
        marketingFee = _marketingFee;
        developmentFee = _developmentFee;
        teamFee = _teamFee;
        buybackFee = _buybackFee;
        totalFee = liquidityFee + marketingFee + developmentFee + teamFee + buybackFee;
        require(totalFee <= 15, "Fees set too high");
    }

    function clearStuckBalance(address _receiver) external onlyOwner {
        uint256 balance = address(this).balance;
        payable(_receiver).transfer(balance);
    }

    function rescueToken(address tokenAddress, uint256 tokens, address destination) external onlyOwner returns (bool success){
        require(tokenAddress != address(this), "Cannot take native tokens");
        return ERC20Detailed(tokenAddress).transfer(destination, tokens);
    }

    function setRebaseFrequency(uint256 _rebaseFrequency) external onlyOwner {
        require(_rebaseFrequency <= MAX_REBASE_FREQUENCY, "Too high");
        rebaseFrequency = _rebaseFrequency;
    }

    function setRewardYield(uint256 _rewardYield, uint256 _rewardYieldDenominator) external onlyOwner {
        rewardYield = _rewardYield;
        rewardYieldDenominator = _rewardYieldDenominator;
    }

    function setNextRebase(uint256 _nextRebase) external onlyOwner {
        require(nextRebase > block.timestamp, "Must set rebase in the future");
        nextRebase = _nextRebase;
    }
}