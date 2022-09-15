pragma solidity 0.8.15;

// SPDX-License-Identifier: MIT


abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }
}

interface IERC20 {
   
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

}

library Address {
   
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
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

library SafeERC20 {
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + (value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance =
            token.allowance(address(this), spender) - (value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

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

abstract contract Ownable is Context {
    address private _owner;

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

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
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
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
        _;
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

contract Pausable is Context {
  
    event Paused(address account);
    event Unpaused(address account);

    bool private _paused;

    constructor() {
        _paused = false;
    }

    function paused() public view returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

interface IWBNB is IERC20 {
    function deposit() external payable;

    function withdraw(uint256 wad) external;
}

interface IToken {
    function totalSupply() external returns(uint);
}

interface GammaTroller {
    function claimGamma(address[] memory holders,address[] memory gTokens,bool borrowers,bool suppliers) external ;
}

interface Gtoken {
    function mint(uint mintAmount) external returns (uint);
    function redeem(uint redeemTokens) external returns (uint); 
}

abstract contract StratX2 is Ownable, ReentrancyGuard, Pausable {

    using SafeERC20 for IERC20;

    GammaTroller public gammaTroller;

    bool public onlyGov = true;

    address public wantAddress;
    address public rewardsAddress;
    address payable public feeAddressesSetter;
    uint256 public lastEarnBlock = 0;

    uint256 public feeRewards = 0;
    uint256 public feeRewardsAccruedPerWeek;
    uint256 public feeRewardsAccrued;
    
    address public depositFeeAddress = 0xAc88bD12C992B1AdBB43183a0Aa5e3fa5AE3E5eE;
    address public withdrawFeeAddress = 0xAc88bD12C992B1AdBB43183a0Aa5e3fa5AE3E5eE;

    address public wbnbAddress;
    address public gammaFarmAddress;
    address public GAMMAAddress;
    address public iGammaAddress;
    address public govAddress; // timelock contract

    uint256 public wantLockedTotal = 0;
    uint256 public sharesTotal = 0;
    uint256 public pid; // pid of pool in farmContractAddress
    uint256 public constant initialExchangeRate = 1e8;
   
    uint256 public entranceFeeFactor; 
    uint256 public constant entranceFeeFactorMax = 10000;
    uint256 public constant entranceFeeFactorLL = 9950; // 0.5% is the max entrance fee settable. LL = lowerlimit

    uint256 public withdrawFeeFactor;
    uint256 public constant withdrawFeeFactorMax = 10000;
    uint256 public constant withdrawFeeFactorLL = 9950; // 0.5% is the max entrance fee settable. LL = lowerlimit

    address public performanceFeeAddress;

    uint256 public controllerFee = 0; // 0;  0%(auto-compounding fee)
    uint256 public constant controllerFeeMax = 10000; // 100 = 1%
    uint256 public constant controllerFeeUL = 2500;

    uint256 public immutable performanceFeeMax = 2500; //25%
    uint256 public performanceFee = 1000; //10%

    uint256 public instantWithdrawFee = 500; // 5%;
    uint256 public immutable instantWithdrawFeeMax = 1000; //10%

    event SetSettings(
        uint256 _entranceFeeFactor, 
        uint256 _withdrawFeeFactor,
        uint256 _controllerFee,
        uint256 _performanceFee
    );
    event SetGov(address _govAddress);
    event SetOnlyGov(bool _onlyGov);
    event SetRewardsAddress(address _rewardsAddress);
    event PerformanceFeeAddressChanged(address oldPerformanceFeeAddress,address newPerformanceFeeAddress);
    event Harvest(address indexed sender, uint256 performanceFee);

    modifier onlyAllowGov() {
        require(msg.sender == govAddress, "!gov");
        _;
    }

    /**
    * @notice Calculates the exchange rate from the gToken to the iToken
    * @return (calculated exchange rate scaled by 1e18)
    */
    function iTokenExchangeRate() public  returns (uint) {
        uint256 _totalSupply = IToken(iGammaAddress).totalSupply();
        if (_totalSupply == 0) {
           /**
            * If there are no iTokens minted:
            *  exchangeRate = initialExchangeRate
            */
            return (initialExchangeRate); //1e8
        } else { 
            uint256 exchangeRate = (wantLockedTotal * 1e18) / _totalSupply;
            return exchangeRate;
        }
    }

    // Receives new deposits from user
    function deposit(uint256 _wantAmt) external virtual onlyOwner nonReentrant whenNotPaused returns (uint256, uint256) {
        IERC20(GAMMAAddress).safeTransferFrom(address(msg.sender), address(this), _wantAmt);

        uint256 balBefore = IERC20(wantAddress).balanceOf(address(this));
        IERC20(GAMMAAddress).safeIncreaseAllowance(wantAddress, _wantAmt);
        Gtoken(wantAddress).mint(_wantAmt);
        uint256 depositAmount = IERC20(wantAddress).balanceOf(address(this)) - balBefore;

        uint256 depositFee = (depositAmount*(entranceFeeFactorMax - entranceFeeFactor))/(entranceFeeFactorMax);
        if(depositFee > 0){
            IERC20(wantAddress).safeTransfer(depositFeeAddress, depositFee);
        }
        depositAmount = depositAmount - depositFee;

        uint256 sharesAdded = depositAmount;
        if (wantLockedTotal > 0 && sharesTotal > 0) {
            sharesAdded = (sharesTotal * depositAmount)/wantLockedTotal;
        }   
        sharesTotal = sharesTotal + sharesAdded;

        uint256 current_exchange_rate = iTokenExchangeRate();
        uint256 mintAmount = (depositAmount * 1e18) / current_exchange_rate;

        wantLockedTotal = wantLockedTotal + depositAmount;
        
        return (sharesAdded, mintAmount);
    }

    function unstake(uint256 _wantAmt, bool instantly) public virtual onlyOwner nonReentrant returns (uint256, uint256, uint256) {
        require(_wantAmt > 0, "_wantAmt <= 0");

        if (wantLockedTotal < _wantAmt) {
            _wantAmt = wantLockedTotal;
        }

        uint256 balanceOfStrat = IERC20(wantAddress).balanceOf(address(this));
        if (_wantAmt > balanceOfStrat) {
            _wantAmt = balanceOfStrat;
        }

        uint256 sharesRemoved = (_wantAmt*sharesTotal)/wantLockedTotal;
        if (sharesRemoved > sharesTotal) {
            sharesRemoved = sharesTotal;
            _wantAmt = sharesRemoved*wantLockedTotal/sharesTotal;
        }
        sharesTotal = sharesTotal - sharesRemoved;
        
        uint256 stratWantTokensRemoved = _wantAmt;
        uint256 withdrawFee;

        uint256 feeFactor = withdrawFeeFactor;
        uint256 feeFactorMax = withdrawFeeFactorMax;

        if(instantly) {
            feeFactor = instantWithdrawFee;
            feeFactorMax = instantWithdrawFeeMax;
        }
        
        if (feeFactor < feeFactorMax && _wantAmt > 0) {
            withdrawFee = _wantAmt*((feeFactorMax - feeFactor)/(feeFactorMax));
            _wantAmt = _wantAmt - withdrawFee;
            withdrawFee = withdrawFee/2;
            IERC20(wantAddress).safeTransfer(withdrawFeeAddress, withdrawFee);
        }
        
        feeRewards += withdrawFee;
        feeRewardsAccrued += withdrawFee;

        wantLockedTotal = wantLockedTotal - _wantAmt - withdrawFee;

        uint256 balBefore = IERC20(GAMMAAddress).balanceOf(address(this));
        Gtoken(wantAddress).redeem(_wantAmt);
        uint256 withdrawAmount = IERC20(GAMMAAddress).balanceOf(address(this)) - balBefore;
        
        IERC20(GAMMAAddress).safeTransfer(gammaFarmAddress, withdrawAmount);

        return (sharesRemoved, withdrawAmount, stratWantTokensRemoved);
    }

    function emergencyWithdraw(uint256 _wantAmt) external virtual onlyOwner returns (uint256, uint256, uint256) {
        return unstake(_wantAmt, true);
    }

    function getShares() external virtual view returns (uint256, uint256) {
        return (wantLockedTotal, sharesTotal);
    }

    function pause() public virtual onlyAllowGov {
        _pause();
    }

    function unpause() public virtual onlyAllowGov {
        _unpause();
    }

    function setSettings(
        uint256 _entranceFeeFactor, 
        uint256 _withdrawFeeFactor,
        uint256 _controllerFee,
        uint256 _performanceFee
    ) public virtual onlyAllowGov {

        require(_entranceFeeFactor >= entranceFeeFactorLL, "_entranceFeeFactor too low");
        require(_entranceFeeFactor <= entranceFeeFactorMax, "_entranceFeeFactor too high");
        entranceFeeFactor = _entranceFeeFactor;

        require(_withdrawFeeFactor >= withdrawFeeFactorLL, "_withdrawFeeFactor too low");
        require(_withdrawFeeFactor <= withdrawFeeFactorMax, "_withdrawFeeFactor too high");
        withdrawFeeFactor = _withdrawFeeFactor;

        require(_controllerFee <= controllerFeeUL, "_controllerFee too high");
        controllerFee = _controllerFee;

        require(_performanceFee <= performanceFeeMax, "_performanceFee too high");
        performanceFee = _performanceFee;

        emit SetSettings(_entranceFeeFactor, _withdrawFeeFactor, _controllerFee, performanceFee);

    }

    function setGov(address _govAddress) public virtual onlyAllowGov {
        govAddress = _govAddress;
        emit SetGov(_govAddress);
    }

    function setOnlyGov(bool _onlyGov) public virtual onlyAllowGov {
        onlyGov = _onlyGov;
        emit SetOnlyGov(_onlyGov);
    }

    function setRewardsAddress(address _rewardsAddress) public virtual onlyAllowGov {
        rewardsAddress = _rewardsAddress;
        emit SetRewardsAddress(_rewardsAddress);
    }

    function inCaseTokensGetStuck(address _token) external onlyOwner {
        require(_token != address(wantAddress), "Token cannot be same as deposit token");
        require(_token != GAMMAAddress, "Token cannot be same as gamma token");
        uint256 amount = IERC20(_token).balanceOf(address(this));
        IERC20(_token).safeTransfer(_msgSender(), amount);
    }

    function _wrapBNB() internal virtual {
        // BNB -> WBNB
        uint256 bnbBal = address(this).balance;
        if (bnbBal > 0) {
            IWBNB(wbnbAddress).deposit{value: bnbBal}(); // BNB -> WBNB
        }
    }

    function wrapBNB() public virtual onlyAllowGov {
        _wrapBNB();
    }

    function claimPendingGamma() internal {
        
        address[] memory holders = new address[](1);
        holders[0] = address(this);

        address[] memory gTokens = new address[](1);
        gTokens[0] = address(wantAddress);

        gammaTroller.claimGamma(holders,gTokens, false, true);        

    }

    function changeFeeAddress(address _depositFeeAddress,address _withdrawFeeAddress) public {
        require(_msgSender() == feeAddressesSetter,"Access denied");
        depositFeeAddress = _depositFeeAddress;
        withdrawFeeAddress = _withdrawFeeAddress;
    }

    function changePerformanceFeeAddress(address _newPerformanceFeeAddress) external onlyOwner {
        require(_newPerformanceFeeAddress != address(0),"_newPerformanceFeeAddress should no be zero address");
        emit PerformanceFeeAddressChanged(performanceFeeAddress,_newPerformanceFeeAddress);
        performanceFeeAddress = _newPerformanceFeeAddress;
    }

    function earnGammaProfitsiGamma(uint256 _gammaRewards) external {
        require(_msgSender() == gammaFarmAddress, "unauthorised access" );
        uint fee;
        IERC20(wantAddress).safeTransferFrom(address(msg.sender), address(this), _gammaRewards);
        claimPendingGamma();
        //invest GAMMA into gTOKEN
        IERC20 gToken = IERC20(wantAddress);
        uint gTokenBal = 0;
        uint256 bal = IERC20(GAMMAAddress).balanceOf(address(this));
        if (bal > 0) {
            uint gTokenBalBefore = gToken.balanceOf(address(this));
            Gtoken(wantAddress).mint(bal);
            uint gTokenBalAfter = gToken.balanceOf(address(this));
            gTokenBal = gTokenBalAfter - gTokenBalBefore;
            fee = (gTokenBal * performanceFee) / 10000;
            gTokenBal = gTokenBal - fee;
            gToken.safeTransfer(performanceFeeAddress,fee);
        }
        wantLockedTotal = wantLockedTotal + gTokenBal;
    }

    /**
    * @notice Checks if the _msgSender() is a contract or a proxy
    */
    modifier notContract() {
        require(!_isContract(_msgSender()), "contract not allowed");
        require(_msgSender() == tx.origin, "proxy contract not allowed");
        _;
    }

    function _isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }
}

contract GammaStrategy_GAMMA is StratX2 {
    
    constructor(
        address[] memory _addresses,
        uint256 _pid,
        uint256 _entranceFeeFactor,
        uint256 _withdrawFeeFactor,
        address _performanceFeeAddress

    ) {
        wbnbAddress = _addresses[0];
        govAddress = _addresses[1];
        gammaFarmAddress = _addresses[2];
        GAMMAAddress = _addresses[3];
        wantAddress = _addresses[4];
        rewardsAddress = _addresses[5];
        iGammaAddress = _addresses[6];
        gammaTroller = GammaTroller(_addresses[7]);
        performanceFeeAddress = _performanceFeeAddress;
        
        pid = _pid;     

        entranceFeeFactor = _entranceFeeFactor;
        withdrawFeeFactor = _withdrawFeeFactor;
        feeAddressesSetter = payable(0xFd525F21C17f2469B730a118E0568B4b459d61B9); 
        transferOwnership(gammaFarmAddress);
    }
    
    function changeFeeAddressSetter(address payable _newFeeAddressSetter) public {
        require(_msgSender() == feeAddressesSetter,"Access denied");
        feeAddressesSetter = _newFeeAddressSetter;
    }
}