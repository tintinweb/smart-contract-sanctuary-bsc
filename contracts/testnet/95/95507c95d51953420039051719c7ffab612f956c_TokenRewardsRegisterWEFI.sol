/**
 *Submitted for verification at BscScan.com on 2022-10-21
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function balanceOf(address account) external view returns (uint256);
    function totalSupply() external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}

contract TokenRewardsRegisterWEFI is Context, ReentrancyGuard {
    IERC20 public tokenAddress;
    uint256 public registerDurationForRewards = 2629743;
    uint256 private _monthlyUnixTime = registerDurationForRewards;
    uint256 private _totalBalanceWEFI = 0;

    mapping(address => uint256) private _balances;
    mapping(address => uint256) private _registerTime;

    event RegisteredWEFI(address beneficiary, uint256 amount);
    event UnregisteredWEFI(address beneficiary, uint256 amount);
    event ClaimedWEFI(address beneficiary, uint256 amount);
    event TotalWEFIUpdated(uint256 amount);
    event UserWEFIUpdated(uint256 amount);

    modifier ifRegisterExists(address beneficiary){
        require(balanceOf(beneficiary)>0, "TokenRewardsRegisterWEFI: no registered amount exists for respective beneficiary");
        _;
    }

    constructor(address _tokenAddress) {
        require(_tokenAddress != address(0x0));
        tokenAddress = IERC20(_tokenAddress);
    }

    function name() external pure returns (string memory) {
        return "Registered WEFI";
    }

    function symbol() external pure returns (string memory) {
        return "R-WEFI";
    }

    function decimals() external pure  returns (uint8) {
        return 18;
    }
    
    function totalSupply() external view returns (uint256) {
        return _totalBalanceWEFI;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function registerTokens(uint256 amount) external returns (bool) {
        address from = _msgSender();
        _registerTokens(from, amount);

        emit RegisteredWEFI(from, amount);
        emit TotalWEFIUpdated(_totalRegisteredBalanceWEFI());
        emit UserWEFIUpdated(balanceOf(from));
        return true;
    }

    function _registerTokens(address from, uint256 amount) private {
        address to = address(this);
        _balances[from] += amount;
        _totalBalanceWEFI += amount;
        _registerTime[from] = block.timestamp;

        require(tokenAddress.transferFrom(from, to, amount), "TokenRewardsRegisterWEFI: token WEFI transferFrom not succeeded");
    }

    function unregisterTokens() external ifRegisterExists(msg.sender) nonReentrant {
        address to = _msgSender();
        uint256 amount = _balances[to];

        _unregisterTokens(to, amount);
    }

    function _unregisterTokens(address to, uint256 amount) private {
        _balances[to] -= amount;
        _totalBalanceWEFI -= amount;
        _registerTime[to] = 0;

        require(tokenAddress.transfer(to, amount), "TokenRewardsRegisterWEFI: token WEFI transfer not succeeded");

        emit UnregisteredWEFI(to, amount);
        emit TotalWEFIUpdated(_totalRegisteredBalanceWEFI());
        emit UserWEFIUpdated(balanceOf(to));
    }

    function _isRegisteringDurationPassed(address beneficiary) private view returns (bool) {
        uint256 timePassed = block.timestamp-_registerTime[beneficiary];
        if(timePassed > registerDurationForRewards){
            return true;
        }
        return false;
    }

    function claimRewards() external ifRegisterExists(msg.sender) nonReentrant {
        address beneficiary = _msgSender();
        uint256 claimableRewards = _claimRewards(beneficiary);

        emit ClaimedWEFI(beneficiary, claimableRewards);
    }

    function _claimRewards(address beneficiary) private returns (uint256) {
        require(_isRegisteringDurationPassed(beneficiary), "TokenRewardsRegisterWEFI: minimum duration for registering rewards not passed");

        uint256 claimableRewards = _viewClaimableRewards(beneficiary);

        require(totalRewardsBalanceWEFI() >= claimableRewards, "TokenRewardsRegisterWEFI: not sufficient WEFI rewards balance in reward contract");
        require(tokenAddress.transfer(beneficiary, claimableRewards), "TokenRewardsRegisterWEFI: token WEFI transfer not succeeded");
        
        uint256 amount = _balances[beneficiary];
        _unregisterTokens(beneficiary, amount);

        return claimableRewards;
    }

    function _viewClaimableRewards(address beneficiary) private view returns (uint256)
    {
        uint256 registeredAmount = _balances[beneficiary];
        uint256 totalRegisteredWEFI = _totalRegisteredBalanceWEFI();
        uint256 totalRewardsWEFI = totalRewardsBalanceWEFI();

        return ((totalRewardsWEFI*registeredAmount)/totalRegisteredWEFI);
    }

    function viewClaimableRewardsAndReleaseTime(address beneficiary) ifRegisterExists(msg.sender) external view returns (uint256, uint256)
    {
        return (_viewClaimableRewards(beneficiary), (_registerTime[beneficiary] + _monthlyUnixTime));
    }

    function _totalRegisteredBalanceWEFI() private view returns (uint256) {
        return _totalBalanceWEFI;
    }

    function getCurrentTime() external view returns (uint256) {
        return block.timestamp;
    }

    function totalRewardsBalanceWEFI() public view returns (uint256) {
        return (tokenAddress.balanceOf(address(this))-_totalBalanceWEFI);
    }
}