// SPDX-License-Identifier: U-U-U-UPPPPP!!!
pragma solidity ^0.7.4;

import "./SafeMath.sol";
import "./SafeERC20.sol";

import "./IERC31337.sol";
import "./IERC20.sol";
import "./ISwapRouter02.sol";
import "./ISwapFactory.sol";
import "./ISwapPair.sol";

import "./RootedToken.sol";
import "./RootedTransferGate.sol";
import "./TokensRecoverable.sol";

contract MigratorHub is TokensRecoverable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    
    ISwapRouter02 swapRouter;
    ISwapFactory swapFactory;

    ISwapPair public rootedEliteLP;
    ISwapPair public rootedBaseLP;

    RootedToken public rootedToken;
    IERC31337 public eliteToken;
    IERC20 public baseToken;

    struct Account {
        uint256 entitlement;
        uint256 claimedTokens;

        bool canClaim;
        bool hasClaimed;

        uint256 claimTimestamp;
    }

    address public distributionController;
    address public liquidityController;

    bool public isActive;
    bool public claimsEnabled;

    bool public distributionComplete;

    uint256 public claimedTokens;
    uint256 public claimableTokens;

    uint256 public constant rootedTokenSupply = 1e26; // 100 mil
    
    uint256 public totalBaseTokenCollected;
    uint256 public totalBoughtForContributors;

    uint256 public recoveryDate = block.timestamp + 2592000; // 1 Month

    uint256 public rootedBottom;

    mapping (address => uint256) public claimTime;
    mapping (address => uint256) public totalClaim;
    mapping (address => uint256) public remainingClaim;

    mapping (address => Account) public _accountOf;
    mapping (address => bool) public _operator;

    modifier ifEnabled() {
        require(claimsEnabled == true, "CLAIMS_DISABLED");
        _;
    }

    modifier operatorsOnly() {
        require(_operator[msg.sender] == true, "NOT_AN_OPERATOR");
        _;
    }

    event onClaimTokens(address _caller, uint256 _amount, uint256 _timestamp);
    event onSetTokens(address _caller, address _recipient, uint256 _amount, uint256 _timestamp);

    constructor (RootedToken _root, IERC31337 _elite, address _base, ISwapRouter02 _router, address _distributionController) {
        
        rootedToken = RootedToken(_root);
        eliteToken = IERC31337(_elite);
        
        baseToken = IERC20(_base);

        distributionController = _distributionController;

        swapRouter = _router;
        swapFactory = ISwapFactory(_router.factory());
    }

    function eliteRootedPath() public view returns (address[] memory) {
        address[] memory path = new address[](2);
        path[0] = address(eliteToken);
        path[1] = address(rootedToken);
        return path;
    }

    function rootedElitePath() public view returns (address[] memory) {
        address[] memory path = new address[](2);
        path[0] = address(rootedToken);
        path[1] = address(eliteToken);
        return path;
    }

    ////////////////////////////
    // PUBLIC WRITE FUNCTIONS //
    ////////////////////////////

    // Claim tokens from the migration
    function claimNewTokens() public ifEnabled() returns (bool _success) {
        require(_accountOf[msg.sender].canClaim == true, "CANNOT_CLAIM_TOKENS");
        require(_accountOf[msg.sender].hasClaimed == false, "ALREADY_CLAIMED_TOKENS");

        uint256 amount = _accountOf[msg.sender].entitlement;
        require (amount > 0, "Nothing to claim");

        _accountOf[msg.sender].claimedTokens = amount;
        _accountOf[msg.sender].claimTimestamp = block.timestamp;

        claimedTokens += amount;
        claimableTokens -= amount;

        emit onClaimTokens(msg.sender, amount, block.timestamp);
        return true;
    }

    function init(RootedToken _gfi, IERC31337 _cGFI, address _controller) public ownerOnly() {
        rootedToken = _gfi;
        eliteToken = _cGFI;
        
        baseToken = _cGFI.wrappedToken();

        liquidityController = _controller;
    }

    function setupEliteRooted() public {
        rootedEliteLP = ISwapPair(swapFactory.getPair(address(eliteToken), address(rootedToken)));
        if (address(rootedEliteLP) == address(0)) {
            rootedEliteLP = ISwapPair(swapFactory.createPair(address(eliteToken), address(rootedToken)));
            require (address(rootedEliteLP) != address(0));
        }
    }

    function setupBaseRooted() public {
        rootedBaseLP = ISwapPair(swapFactory.getPair(address(baseToken), address(rootedToken)));
        if (address(rootedBaseLP) == address(0)) {
            rootedBaseLP = ISwapPair(swapFactory.createPair(address(baseToken), address(rootedToken)));
            require (address(rootedBaseLP) != address(0));
        }
    }

    ///////////////////////////////
    // CONTROLLER-ONLY FUNCTIONS //
    ///////////////////////////////

    function setEntitlementOf(address _user, uint256 _amount) public operatorsOnly() returns (bool _success) {
        require(_user != address(0) && _user != msg.sender, "INVALID_ADDRESS");

        _accountOf[_user].entitlement = _amount;

        claimableTokens += _amount;

        emit onSetTokens(msg.sender, _user, _amount, block.timestamp);
        return true;
    }

    //////////////////////////
    // OWNER-ONLY FUNCTIONS //
    //////////////////////////

    // Use this to enable or disable addresses from setting entitlements
    function toggleController(address _address, bool _enabled) public ownerOnly() returns (bool _success) {
        _operator[_address] = _enabled;
        return true;
    }

    function completeSetup() public ownerOnly() {
        require (address(rootedEliteLP) != address(0), "Rooted Elite pool is not created");
        require (address(rootedBaseLP) != address(0), "Rooted Base pool is not created");   

        eliteToken.approve(address(swapRouter), uint256(-1));
        rootedToken.approve(address(swapRouter), uint256(-1));
        baseToken.safeApprove(address(swapRouter), uint256(-1));
        baseToken.safeApprove(address(eliteToken), uint256(-1));
        rootedBaseLP.approve(address(swapRouter), uint256(-1));
        rootedEliteLP.approve(address(swapRouter), uint256(-1));
    }

    function distribute() public ownerOnly() {
        require (!distributionComplete, "Distribution complete");

        distributionComplete = true;

        RootedTransferGate gate = RootedTransferGate(address(rootedToken.transferGate()));

        gate.setUnrestricted(true);

        // Mint GFI to this contract, ready to distribute to the right places
        rootedToken.mint(rootedTokenSupply);

        createRootedEliteLiquidity();

        eliteToken.sweepFloor(address(this));
        eliteToken.depositTokens(baseToken.balanceOf(address(this)));
        
        // Buy the bottom
        uint256[] memory buyBottomAmounts = swapRouter.swapExactTokensForTokens(totalBaseTokenCollected, 0, eliteRootedPath(), address(this), block.timestamp);
        rootedBottom = buyBottomAmounts[1];

        // Sell the Top
        uint256[] memory sellTopAmounts = swapRouter.swapExactTokensForTokens(rootedBottom, 0, rootedElitePath(), address(this), block.timestamp);
        uint256 eliteAmount = sellTopAmounts[1];
        eliteToken.withdrawTokens(eliteAmount);

        // Transfer the remaining USDC to the Liquidity Controller
        baseToken.transfer(liquidityController, baseToken.balanceOf(address(this)));

        createRootedBaseLiquidity();

        gate.setUnrestricted(false);
    }

    ////////////////////////////////////
    // PRIVATE AND INTERNAL FUNCTIONS //
    ////////////////////////////////////

    function createRootedEliteLiquidity() private {
        eliteToken.depositTokens(baseToken.balanceOf(address(this)));
        swapRouter.addLiquidity(address(eliteToken), address(rootedToken), eliteToken.balanceOf(address(this)), rootedToken.balanceOf(address(this)), 0, 0, address(this), block.timestamp);
    }

    function createRootedBaseLiquidity() private {
        uint256 elitePerLpToken = eliteToken.balanceOf(address(rootedEliteLP)).mul(1e18).div(rootedEliteLP.totalSupply());
        uint256 lpAmountToRemove = baseToken.balanceOf(address(eliteToken)).mul(1e18).div(elitePerLpToken);
        
        (uint256 eliteAmount, uint256 rootedAmount) = swapRouter.removeLiquidity(address(eliteToken), address(rootedToken), lpAmountToRemove, 0, 0, address(this), block.timestamp);
        
        uint256 baseInElite = baseToken.balanceOf(address(eliteToken));
        uint256 baseAmount = eliteAmount > baseInElite ? baseInElite : eliteAmount;
        
        eliteToken.withdrawTokens(baseAmount);
        swapRouter.addLiquidity(address(baseToken), address(rootedToken), baseAmount, rootedAmount, 0, 0, liquidityController, block.timestamp);
        
        rootedEliteLP.transfer(liquidityController, rootedEliteLP.balanceOf(address(this)));
        eliteToken.transfer(liquidityController, eliteToken.balanceOf(address(this)));
    }

    function canRecoverTokens(IERC20 token) internal override view returns (bool) {
        return block.timestamp > recoveryDate || token != rootedToken;
    }
}