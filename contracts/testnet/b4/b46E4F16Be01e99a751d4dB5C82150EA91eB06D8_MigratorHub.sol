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

    bool public claimsEnabled;
    bool public distributionComplete;

    uint256 public claimedTokens;
    uint256 public claimableTokens;

    uint256 public constant rootedTokenSupply = 1e26; // 100 mil

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

    event onToggleClaims(address _caller, bool _option, uint256 _timestamp);

    constructor (RootedToken _root, IERC31337 _elite, address _base, ISwapRouter02 _router, address _distributionController) {
        
        rootedToken = RootedToken(_root);
        eliteToken = IERC31337(_elite);
        
        baseToken = IERC20(_base);

        distributionController = _distributionController;

        swapRouter = _router;
        swapFactory = ISwapFactory(_router.factory());

        distributionComplete = false;
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

        // Find the number of tokens to give the user
        uint256 amount = _accountOf[msg.sender].entitlement;
        require (amount > 0, "Nothing to claim");

        // Update the stats of user
        _accountOf[msg.sender].claimedTokens = amount;
        _accountOf[msg.sender].claimTimestamp = block.timestamp;

        // Add the amount of tokens claimed to the count
        claimedTokens += amount;

        // Restrict the user from claiming again
        _accountOf[msg.sender].canClaim = false;
        _accountOf[msg.sender].hasClaimed = true;

        // Transfer the tokens
        rootedToken.transfer(msg.sender, amount);

        // Tell the network, successful function
        emit onClaimTokens(msg.sender, amount, block.timestamp);
        return true;
    }

    ///////////////////////////////
    // CONTROLLER-ONLY FUNCTIONS //
    ///////////////////////////////

    // Set _amount of tokens _user is able to claim
    function setEntitlementOf(address _user, uint256 _amount) public operatorsOnly() returns (bool _success) {
        require(_user != address(0) && _user != msg.sender, "INVALID_ADDRESS");
        require(_accountOf[_user].hasClaimed == false, "ALREADY_CLAIMED_TOKENS");

        // Set number of tokens claimable
        _accountOf[_user].entitlement = _amount;

        // add _amount to the total of claimable tokens
        claimableTokens += _amount;

        // Tell the contract, the user is allowed to claim, and that they have not yet done so.
        _accountOf[_user].canClaim = true;
        _accountOf[_user].hasClaimed = false;

        // Tell network, successful function
        emit onSetTokens(msg.sender, _user, _amount, block.timestamp);
        return true;
    }

    //////////////////////////
    // OWNER-ONLY FUNCTIONS //
    //////////////////////////

    // 0: Use this to enable or disable addresses from setting entitlements
    function toggleController(address _address, bool _enabled) public ownerOnly() returns (bool _success) {
        _operator[_address] = _enabled;
        return true;
    }

    // 1: Initialise this contract with addresses
    function init(RootedToken _gfi, IERC31337 _cGFI, address _controller) public ownerOnly() {
        rootedToken = _gfi;
        eliteToken = _cGFI;
        
        baseToken = _cGFI.wrappedToken();

        liquidityController = _controller;
    }

    // 2: Create the elite pair if it doesn't exist already
    function setupEliteRooted() public ownerOnly() {
        rootedEliteLP = ISwapPair(swapFactory.getPair(address(eliteToken), address(rootedToken)));
        if (address(rootedEliteLP) == address(0)) {
            rootedEliteLP = ISwapPair(swapFactory.createPair(address(eliteToken), address(rootedToken)));
            require (address(rootedEliteLP) != address(0));
        }
    }

    // 3: Create the public pair if it doesn't exist already
    function setupBaseRooted() public ownerOnly() {
        rootedBaseLP = ISwapPair(swapFactory.getPair(address(baseToken), address(rootedToken)));
        if (address(rootedBaseLP) == address(0)) {
            rootedBaseLP = ISwapPair(swapFactory.createPair(address(baseToken), address(rootedToken)));
            require (address(rootedBaseLP) != address(0));
        }
    }

    // 4: Approve all the necessary contracts
    function approveAll() public ownerOnly() {
        require (address(rootedEliteLP) != address(0), "Rooted Elite pool is not created");
        require (address(rootedBaseLP) != address(0), "Rooted Base pool is not created");   

        eliteToken.approve(address(swapRouter), uint256(-1));
        rootedToken.approve(address(swapRouter), uint256(-1));
        baseToken.safeApprove(address(swapRouter), uint256(-1));
        baseToken.safeApprove(address(eliteToken), uint256(-1));
        rootedBaseLP.approve(address(swapRouter), uint256(-1));
        rootedEliteLP.approve(address(swapRouter), uint256(-1));
    }

    // 5: Run the distribution effects
    function distribute() public ownerOnly() {
        require (!distributionComplete, "Distribution complete");

        // Mark the distribution as complete
        distributionComplete = true;

        // Set the gate!
        RootedTransferGate gate = RootedTransferGate(address(rootedToken.transferGate()));

        // Unlock the gate!
        gate.setUnrestricted(true);

        // Mint GFI to this contract
        rootedToken.mint(rootedTokenSupply);

        // Find remainder of GFI (after user distributions)
        uint256 remainders = (rootedTokenSupply.sub(claimableTokens));

        // Transfer the remaining USDC to the Liquidity Controller
        baseToken.transfer(liquidityController, baseToken.balanceOf(address(this)));

        // Transfer the remaining GFI to the Liquidity Controller
        rootedToken.transfer(liquidityController, remainders);

        // Lock the gate!
        gate.setUnrestricted(false);
    }

    // 6: Enable claims for users
    function toggleClaims(bool _enabled) public ownerOnly() returns (bool _success) {
        
        // Set claims to _enabled (arg)
        claimsEnabled = _enabled;

        // Tell the network, successful function
        emit onToggleClaims(msg.sender, _enabled, block.timestamp);
        return true;
    }

    ////////////////////////////////////
    // PRIVATE AND INTERNAL FUNCTIONS //
    ////////////////////////////////////

    function canRecoverTokens(IERC20 token) internal override view returns (bool) {
        return true;
    }
}