// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "./Factory.sol";
import "./Tiers.sol";

contract Toto is Ownable {
    uint8 public constant version = 1;
    uint256 public fee = 100000000000000000;
    address feeWallet = 0xa6A67BeEd1033085AB8dd2D37e6bd5a8C19B5695;
    mapping(uint256 => mapping(address => bool)) public approvedRouters;
    Factory public factory;
    address public tiers;

    address[] public activePresales;
    mapping (address => uint256) private activePresalesIndex;
    address[] public cancelledPresales;
    mapping (address => uint256) private cancelledPresalesIndex;
    address[] public launchedPresales;
    mapping (address => uint256) private launchedPresalesIndex;

    constructor() {
        owner = msg.sender;

        approvedRouters[97][0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3] = true;
        approvedRouters[56][0x10ED43C718714eb63d5aA57B78B54704E256024E] = true;
        approvedRouters[1][0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D] = true;

        factory = new Factory(address(this));
        tiers = address(new Tiers());
    }

    function createPad(address _token, address _router, uint256[16] memory _inputs, string[10] memory _socials) external payable returns(address){
        require(msg.value == fee, "Incorrect fee paid");
        require(approvedRouters[block.chainid][_router], "Invalid router");

        collectFees();

        address ps = factory.generatePad(msg.sender, _token, _router, tiers, _inputs, _socials);
        activePresalesIndex[ps] = activePresales.length;
        activePresales.push(ps);
        return ps;
    }

    function addApprovedRouter(uint256 _chain, address _router) external onlyOwner {
        require(_router != address(0), "Invalid address");
        approvedRouters[_chain][_router] = true;
    }

    function removeApprovedRouter(uint256 _chain, address _router) external onlyOwner {
        approvedRouters[_chain][_router] = false;
    }

    function setFeeWallet(address _wallet) external onlyOwner {
        require(_wallet != address(0), "Invalid address");
        feeWallet = _wallet;
    }

    function setFee(uint256 amount) external onlyOwner {
        fee = amount;
    }

    function setFactory(address _factory) external onlyOwner {
        require(_factory != address(0), "Invalid address");
        factory = Factory(_factory);
    }

    function setTiers(address _tiers) external onlyOwner {
        tiers = _tiers;
    }

    function launch(address _presale) external {
        require(msg.sender == Presale(_presale).owner(), "Not presale owner");
        Presale(_presale).launch();
        launchedPresalesIndex[_presale] = launchedPresales.length;
        launchedPresales.push(_presale);
        removePresale(_presale);
    }

    function cancelSale(address _presale) external {
        require(msg.sender == Presale(_presale).owner(), "Not presale owner");
        Presale(_presale).cancelSale();
        cancelledPresalesIndex[_presale] = cancelledPresales.length;
        cancelledPresales.push(_presale);
        removePresale(_presale);
    }

    function collectFees() public {
        (bool sent, ) = feeWallet.call{value: address(this).balance}("");
        require(sent, "Failed to send funds");
    }

    function removePresale(address _presale) internal {
        uint256 lastIndex = activePresales.length-1;
        uint256 index = activePresalesIndex[_presale];

        address lastPresale = activePresales[lastIndex];

        activePresales[index] = lastPresale;
        activePresalesIndex[lastPresale] = index;

        delete activePresalesIndex[_presale];
        activePresales.pop();
    }

    function listPresales(uint256 _type, uint256 _start, uint256 _limit) external view returns (address[] memory presales, uint256 lastId) {
        //Types
        //1 - active
        //2 - launched
        //3 - cancelled
        address[] memory _search = _type == 1 ? activePresales : _type == 2 ? launchedPresales : cancelledPresales;
        if (_limit > 0) {
            if(_limit > _search.length - _start) _limit = _search.length - _start;
            presales = new address[](_limit);

            uint256 gasUsed = 0;
            uint256 gasLeft = gasleft();

            for (uint256 i=_start; gasUsed < 5000000 && i < _search.length && i - _start < _limit ; i++) {
                presales[i-_start] = _search[i];
                lastId = i;
                gasUsed += gasLeft - gasleft();
                gasLeft = gasleft();
            }
        }
    }

    receive() external payable {}
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Tiers {
    //tier 1 : 24,000,000,000,000,000
    //tier 1 - 1hr early access
    //tier 2 : 15,000,000,000,000,000
    //tier 2 - 30mins early access
    //tier 3 : 10,000,000,000,000,000
    //tier 3 - auto whitelist
    IERC20 constant sod = IERC20(0xCDB943908DE5Ee37998a53f23467017d1A307E60);

    function hasWhitelistTier(address user) external view returns (bool) {
        return sod.balanceOf(user) >= 10_000_000_000_000_000 * (10**9);
    }

    function getEarlyAccessPeriod(address user) external view returns (uint256) {
        return sod.balanceOf(user) >= 24_000_000_000_000_000 * (10**9) ? 1 hours : (sod.balanceOf(user) >= 15_000_000_000_000_000 * (10**9) ? 30 minutes : 0);
    }

    function hasPreBought(address _user) external pure returns(bool){
        //NOT IMPLEMENTED
        _user;
        return false;
    }

    function preBuy(address _presale) external payable {
        //NOT IMPLEMENTED
        //Add user to preBuy list for presale
    }

    function autoAddUsers(address _presale) external returns(uint256 totalUsers, uint256 totalValue){
        //NOT IMPLEMENTED
        //if the presale has launched
        //for users who pre-bought
        //if they haven't been added yet
        //add them to the presale

        //if addOnFirstBuy enabled
        //Presale(_presale).addTierSales(users, totalValue);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "./Tiers.sol";

interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface IDEXRouter {
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

interface IDexPair {
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

contract Ownable {
    address public owner;
    modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }
}

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
    event Pause();
    event Unpause();

    bool public paused = false;


    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
   */
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
   */
    modifier whenPaused() {
        require(paused);
        _;
    }

    /**
     * @dev called by the owner to pause, triggers stopped state
   */
    function pause() onlyOwner whenNotPaused public {
        paused = true;
        emit Pause();
    }

    /**
     * @dev called by the owner to unpause, returns to normal state
   */
    function unpause() onlyOwner whenPaused public {
        paused = false;
        emit Unpause();
    }
}

contract Whitelist is Pausable {

    Tiers tiers;
    address[] private whitelist;
    mapping (address => uint256) private whitelistIndex;

    event WhitelistAdded(address indexed account);
    event WhitelistRemoved(address indexed account);

    constructor(address _tiers) {
        tiers = Tiers(_tiers);
    }

    function isWhitelisted(address _address)
    public
    view
    returns (bool)
    {
        if (paused) {
            return false;
        }

        return whitelist[whitelistIndex[_address]] == _address || tiers.hasWhitelistTier(_address);
    }

    function addWhitelist(address _address)
    external
    onlyOwner
    {
        require(whitelist[whitelistIndex[_address]] != _address, "User already whitelisted");
        addUser(_address);
        emit WhitelistAdded(_address);
    }

    function removeWhitelist(address _address)
    external
    onlyOwner
    {
        require(whitelist[whitelistIndex[_address]] == _address, "User not on whitelist");
        removeUser(_address);
        emit WhitelistRemoved(_address);
    }

    function addWhitelistedBulk(address[] memory accounts)
    external
    onlyOwner
    {
        for (uint256 account = 0; account < accounts.length; account++) {
            addUser(accounts[account]);
        }
    }

    function removeWhitelistedBulk(address[] memory accounts)
    external
    onlyOwner
    {
        for (uint256 account = 0; account < accounts.length; account++) {
            removeUser(accounts[account]);
        }
    }

    function addUser(address user) internal {
        whitelistIndex[user] = whitelist.length;
        whitelist.push(user);
    }

    function removeUser(address user) internal {
        uint256 lastIndex = whitelist.length-1;
        uint256 index = whitelistIndex[user];

        address lastUser = whitelist[lastIndex];

        whitelist[index] = lastUser;
        whitelistIndex[lastUser] = index;

        delete whitelistIndex[user];
        whitelist.pop();
    }

    function listWhitelist(uint256 _start, uint256 _limit) external view returns (address[] memory users, uint256 lastId) {
        if (_limit > 0) {
            if(_limit > whitelist.length - _start) _limit = whitelist.length - _start;
            users = new address[](_limit);

            uint256 gasUsed = 0;
            uint256 gasLeft = gasleft();

            for (uint256 i=_start; gasUsed < 5000000 && i < whitelist.length && i - _start < _limit ; i++) {
                users[i-_start] = whitelist[i];
                lastId = i;
                gasUsed += gasLeft - gasleft();
                gasLeft = gasleft();
            }
        }
    }
}

contract Presale is Whitelist {
    using SafeERC20 for IERC20;
    using Address for address;

    IERC20 token;
    address public liquidityPair;

    mapping(address=>uint256) public claimedAmount;
    mapping(address=>uint256) public vestedAmount;
    mapping(address=>uint256) public paidAmount;

    uint256 public totalBuyers;

    uint256 public _cancelledAt;
    uint256 public _launchedAt;

    uint256 public immutable startDate;
    uint256 public immutable endDate;
    uint256 public immutable tokensPerUnit;
    uint256 public immutable softcap;
    uint256 public immutable hardcap;
    uint256 public immutable maxContribution;
    uint256 public immutable minContribution;
    uint256 public immutable percentToLiquidity;
    uint256 public immutable tokensPerUnitLaunch;
    uint256 public immutable liquidityLockDays;
    uint256 public immutable presaleVestingHours;
    uint256 public immutable presaleVestingPercent;
    uint256 public vestingFinishedAt;
    bool public immutable burnExtraTokens;
    Socials public social;
    address public immutable routerAddress;
    address public immutable controller;

    struct Socials {
        string logo;
        string website;
        string facebook;
        string twitter;
        string github;
        string telegram;
        string instagram;
        string discord;
        string reddit;
        string description;
    }

    modifier onlyController() {
        require(controller == msg.sender, "Caller is not authorised");
        _;
    }

    event BuyPresale(address indexed user, uint256 value, uint256 tokens);
    event Lock(address indexed pair, uint256 unlocksAt);
    event WithdrawLiquidity();

    constructor (address _owner, address _token, address _router, address _controller, address _tiers, uint256[16] memory _inputs, string[10] memory _socials) Whitelist(_tiers) {
        // _inputs:
        // 0_tokensPerUnit, 1_startDate, 2_endDate, 3_softcap, 
        // 4_hardcap, 5_maxContribution, 6_minContribution, 7_percentToLiquidity
        // 8_tokensPerUnitLaunch, 9_burnExtraTokens, 10_liquidityLockDays
        // 11_presaleVestingHours, 12_presaleVestingPercent, 13_spare, 14_spare, 15_spare
        require(_owner != address(0), "Invalid owner");
        require(_inputs[0] > 0 && _inputs[8] > 0, "Tokens per unit must be greater than 0");
        require( _inputs[2] > _inputs[1], "End must be after start");
        require( _inputs[2] > block.timestamp && _inputs[1] > block.timestamp, "Dates must be in the future");
        require( _inputs[5] >=  _inputs[6], "Max purchase must be greater than or equal to minimum purchase");
        require( _inputs[4] > 0 && _inputs[3] > 0, "Hardcap and softcap must be greater than 0");
        require( _inputs[4] >=  _inputs[3], "Hardcap must be greater than or equal to softcap");
        require( _inputs[3] >=  _inputs[4]/2, "Softcap must be greater than or equal to half hardcap");
        require( _inputs[7] <= 100 &&  _inputs[7] >= 55, "Liquidity outside bounds");
        require( _inputs[10] >= 30, "Liquidity lock too short");
        require( _inputs[12] <= 100, "Vesting percent outside of bounds");

        token = IERC20(_token);
        tokensPerUnit = _inputs[0];
        tokensPerUnitLaunch = _inputs[8];
        startDate =_inputs[1];
        endDate = _inputs[2];
        softcap = _inputs[3];
        hardcap = _inputs[4];
        maxContribution =_inputs[5];
        minContribution =  _inputs[6];
        percentToLiquidity =  _inputs[7];
        burnExtraTokens = _inputs[9] > 0;
        liquidityLockDays = _inputs[10];
        presaleVestingHours = _inputs[11];
        presaleVestingPercent = _inputs[12];
        owner = _owner;
        routerAddress = _router;
        controller = _controller;

        _updateSocials(_socials);
    }

    function updateSocials(string[10] memory _socials) public onlyOwner {
        _updateSocials(_socials);
    }

    function _updateSocials(string[10] memory _socials) internal {
        require(bytes(_socials[0]).length >= 12, "Logo appears invalid.");
        require(bytes(_socials[1]).length >= 12, "Website appears invalid.");
        require(bytes(_socials[9]).length >= 128, "Description must be 128 characters or more.");
        social = Socials(_socials[0],_socials[1],_socials[2],_socials[3],_socials[4],_socials[5],_socials[6],_socials[7],_socials[8],_socials[9]);
    }

    function liquidityUnlockTime() public view returns(uint256) {
        return _launchedAt + (liquidityLockDays * 1 days);
    }

    function launched() public view returns(bool) {
        return _launchedAt > 0;
    }

    function cancelled() public view returns(bool) {
        return _cancelledAt > 0;
    }

    function cancelSale() external onlyController {
        require(!launched(), "Presale already launched");
        _cancelledAt = block.timestamp;
    }

    function withdrawTokens() external onlyOwner {
        require(cancelled() && !launched(), "Presale in progress");
        token.transfer(msg.sender,token.balanceOf(address(this)));
    }

    function withdrawLiquidity() external onlyOwner {

        emit WithdrawLiquidity();
    }

    function addTierSales(uint256 _boughtFor, uint256 _totalValue) external payable {
        require(msg.sender == address(tiers), "Invalid tier-buy");

        totalBuyers += _boughtFor;
        require(address(this).balance + _totalValue <= hardcap, "Hardcap reached");
        require(_totalValue == msg.value, "Insufficient funds");
    }

    function buyFor(address _for) external payable {
        require(msg.sender == address(tiers), "Invalid tier-buy");
        _buy(_for, msg.value);
    }

    function buy() external payable {
        require(!tiers.hasPreBought(msg.sender), "Please use Tier System");
        _buy(msg.sender, msg.value);
    }

    function _buy(address _for, uint256 _value) internal {
        require(!cancelled(), "Presale cancelled");
        require(!address(_for).isContract(), "No contract purchases");
        uint256 newBalance = paidAmount[_for] + _value;
        if (!paused){
            require( isWhitelisted(_for));
        }

        if(totalBuyers == 0) {
            tiers.autoAddUsers(address(this));
        }

        require( newBalance <= maxContribution,"Max contribution exceeded");
        require( _value >= minContribution || address(this).balance + _value == hardcap,"Min contribution not reached");
        require(token.balanceOf(address(this)) > 0,"No more tokens");
        require(address(this).balance + _value <= hardcap, "Hardcap reached");
        require(block.timestamp >= startDate - tiers.getEarlyAccessPeriod(_for) && block.timestamp < endDate, "Outside of presale time");

        if(vestedAmount[_for] == 0)
            totalBuyers++;
        vestedAmount[_for] = newBalance * tokensPerUnit / (1*10**18);
        paidAmount[_for] = newBalance;


        emit BuyPresale(_for, _value, _value * tokensPerUnit / (1*10**18));
    }

    function claimFor(address _for, uint256 _amount) external {
        require(msg.sender == address(tiers), "Invalid tier-claim");
        _claim(_for, _amount);
    }

    function claim() external {
        _claim(msg.sender, vestedAmount[msg.sender]);
    }

    function _claim(address _for, uint256 _vestedAmount) internal {
        require(!cancelled(), "Presale cancelled");
        require(_vestedAmount > 0, "None bought");
        uint256 remaining = _vestedAmount - claimedAmount[_for];
        require(token.balanceOf(address(this)) >= remaining,"Not enough tokens");
        require(launched(), "Presale not launched yet");

        uint256 toSend;
        if(vestingFinishedAt > 0 && vestingFinishedAt > block.timestamp) {
            require(claimedAmount[_for] == 0, "Already claimed unvested amount");
            toSend = remaining * presaleVestingPercent / 100;
        } else
            toSend = remaining;

        claimedAmount[_for] += toSend;
        token.transfer(_for,toSend);
    }

    function abort() external {
        require(vestedAmount[msg.sender] > 0, "None bought");
        require(address(this).balance > 0,"Insufficient Balance");
        bool failed = block.timestamp >= endDate && address(this).balance < softcap;
        require(block.timestamp < endDate || failed, "Presale ended");
        uint256 toRefund = paidAmount[msg.sender];
        vestedAmount[msg.sender] = 0;
        paidAmount[msg.sender] = 0;
        if(!cancelled() && !failed) {
            (bool feeSent, ) = controller.call{value: (toRefund * 10) / 100}("");
            require(feeSent, "Failed to send fees");
        }
        (bool sent, ) = msg.sender.call{value: (toRefund * (cancelled() || failed ? 100 : 90)) / 100}("");
        require(sent, "Failed to send refund");
        totalBuyers--;
    }

    function currentBalance() external view returns(uint256) {
        return address(this).balance;
    }

    function launch() external onlyController {
        require(block.timestamp > endDate || address(this).balance >= hardcap - (minContribution - 1), "Presale not ended");
        require(address(this).balance >= softcap, "Softcap not reached");
        require(!cancelled() && !launched(), "Presale already final");

        IDEXRouter router = IDEXRouter(routerAddress);
        IDEXFactory factory = IDEXFactory(router.factory());
        uint256 toLaunch = address(this).balance * percentToLiquidity / 100;
        uint256 tokensToLaunch = toLaunch * tokensPerUnitLaunch / (1 * 10**18);
        liquidityPair = factory.getPair(router.WETH(), address(token));
        if(liquidityPair == address(0))
            liquidityPair = factory.getPair(address(token), router.WETH());

        token.approve(routerAddress, tokensToLaunch);
        if(liquidityPair == address(0))
            liquidityPair = factory.createPair(address(token),router.WETH());

        router.addLiquidityETH{value: toLaunch}(address(token),tokensToLaunch,0,0,address(this),block.timestamp);

        (bool sent, ) = msg.sender.call{value: address(this).balance}("");
        require(sent, "Failed to send funds");

        if(burnExtraTokens)
            token.transfer(0x000000000000000000000000000000000000dEaD, token.balanceOf(address(this)));
        else
            token.transfer(msg.sender, token.balanceOf(address(this)));

        _launchedAt = block.timestamp;
        vestingFinishedAt = _launchedAt + (presaleVestingHours * 1 hours);
        emit Lock(liquidityPair, liquidityUnlockTime());
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "./Presale.sol";

contract Factory {
    address immutable main;
    constructor (address _controller) {
        main = _controller;
    }
    function generatePad (address _owner, address _token, address _router, address _tiers, uint256[16] memory _inputs, string[10] memory _socials) external returns(address){
        require(msg.sender == main, "Invalid controller");
        Presale ps = new Presale(_owner, _token, _router, main, _tiers, _inputs, _socials);
        uint256 requiredTokens = (_inputs[4] * _inputs[2] / (1 * 10**18)) + (_inputs[4] * _inputs[7] * _inputs[8] / 100*(1 * 10**18));
        IERC20(_token).transferFrom(_owner, address(ps),requiredTokens);
        require(IERC20(_token).balanceOf(address(ps)) == requiredTokens, "Not enough tokens transferred");
        return address(ps);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
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