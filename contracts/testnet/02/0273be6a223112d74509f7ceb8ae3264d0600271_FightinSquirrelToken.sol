/**
 *Submitted for verification at BscScan.com on 2022-11-17
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

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
     */
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
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

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
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
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
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
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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
     * Authorize address. Owner only. Calls internal _authorize method
     */
    function authorize(address adr) external onlyOwner {
        _authorize(adr);
    }
    
    function _authorize (address adr) internal {
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
interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function getOwner() external view returns (address);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
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


    function swapExactTokensForETH(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}
interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}
library RocketLibrary {
    struct Holder {
        address _address;
        uint256 totalPurchased;
        uint256 totalSold;
        bool isMerchant;
    }

    enum TransferType {
        Sell,
        Buy,
        Transfer
    }

    struct Transfer {
        Holder holder;
        uint256 amt;
        TransferType transferType;
        address from;
        address to;
    }

    struct Burner {
        uint256 totalBurned;
        uint256 stakingPoints;
        uint256 totalSold;
        uint256 loyaltyBoost;
        uint256 totalExcluded;
        uint256 totalRealised;
        uint256 totalRealisedUndeposited;
        bool isExistingBurner;
        bool isMigrated;
    }

    struct PlayCounter {
        uint256 totalBurnPlays;
        uint256 totalTransferPlays;
        uint256 totalBuyPlays;
    }

    struct Winnings {
        uint256 totalWonBurnBoost;
        uint256 totalWonBuyBoost;
        uint256 totalClaimedTransferBoost;
        uint256 lastTimeWonBurnPool;
        uint256 lastTimeWonBuyPool;
        uint256 lastTimeClaimedTransferPool;
    }

    struct RocketPlayer {
        PlayCounter playCounter;
        Winnings winnings;
        uint256 rocketTokens;
    }
}
interface IBurnToEarn {
    function updateUser(address holder, uint256 burnedAmount) external; 
    function updateBurnToEarnFactors(address holder, uint256 boostID, uint256 updateAmount) external; 
    function syncDeposit(uint256 amount) external;
}
interface IRocketPlay {
    function getPoolThreshold(IERC20 token, uint poolID) external view returns (uint256, uint256);
    function playRocketPools(address sender, address recipient, RocketLibrary.TransferType _transferType, uint256 amount) external;
    function playBurnPools(IERC20 token, address sender, uint poolID, uint256 tokenAmount) external;
    function updatePools(uint256 tokenAmount) external;
    function updatePoolByID(uint256 tokenAmount, uint poolID) external;
    function getFee(IERC20 token, uint poolID) external view returns (uint fee);
    function validatePoolID(IERC20 token, uint poolID) external view returns (bool);
}
interface IPoolDistributionGateway {
    function depositBNB() external payable;
    function onTransfer(RocketLibrary.Transfer memory _transfer) external;
    function setShares(address from, address to, uint256 fromBalance, uint256 toBalance) external;
}
interface IRocketForge {
    function getDiscount(address holder) external view returns (uint256, uint256);
}

contract FightinSquirrelToken is IERC20, Auth {

    using SafeMath for uint256;
    using Address for address;

    struct Interfaces {
        bool isInterface;
        uint256 merchantFee;
        bool isMerchant;
    }

    struct RocketContractExclusions {
        bool excludeRocketPlay;
        bool excludePoolDistributionGateway;
        bool excludeBurnToEarn;
        bool excludeRocketForge;
    }

    struct Fees {
        uint256 sell;
        uint256 transfer;
        uint256 buy;
        uint256 burn; //Always divided by the fee.sell to calculate result
        uint256 rocket; //Always divided by the fee.sell to calculate result
        uint256 burn2Earn; //Always divided by the fee.sell to calculate result
    }

    // Fees
    Fees public fee = Fees(1000,0,1000,100,0,0);

    address DEAD = 0x000000000000000000000000000000000000dEaD; 

    //Maintains tokens to burn seperately during swapback
    uint256 public burnReserve; //keeps track of tokens meant to be burned
    uint256 public burnThreshold = 10 * 1e15; //burn tokens when burn threshold is reached to save gas during transactions
    uint256 public swapThreshold = 10 * 1e15; //swap tokens for BNB on a threshold
    
    //Token Pair Data
    IDEXRouter  public router;
    address     public pair;
    mapping(address => bool) liquidityPairs;
    
    //FightinSquirrelToken Token Info
    string  constant _name          = "FightinSquirrelToken";
    string  constant _symbol        = "FST";
    uint8   constant _decimals      = 9;
    uint256 public   _totalSupply   = 1e12 * 1e9;
    uint256 public   _maxTxAmount   = _totalSupply;
    
    //Shareholder Standard Mappings
    mapping(address => uint256)                            _balances;
    mapping(address => mapping(address => uint256))        _allowances;
    mapping(address => bool)                        public isFeeExempt;
    mapping(address => bool)                        public isTxLimitExempt;
    //Shareholder Rocket Mappings
    mapping(address => RocketContractExclusions)    public rocketExclusions; //Manages exclusions with external FightinSquirrelToken contracts
    mapping (address => Interfaces)                 public interfaces; //Manages Interfacing contracts/merchants allowing contracts to make basic transfer. Custom fees only applicable to merchant/non-interface addresses
    mapping (address => bool)                       public isRocketContract; //Manages each FightinSquirrelToken contract that is authorized to interact with the burn pools function
    mapping(address => RocketLibrary.Holder)        public holders;

    //FightinSquirrelToken Interfaces
    IPoolDistributionGateway public  poolDistributionGateway;
    IRocketPlay              public  rocketPlay;
    IRocketForge             public  rocketForge;
    IBurnToEarn              public  burnToEarn;

    //Other 
    uint256 public  tokensBurned; //Counter for tokens burned within the FightinSquirrelToken EcoSystem
    bool    private allowContracts; //Used to prevent other contracts from interacting with our holder accessible functions that are not FightinSquirrelToken contracts. Used to prevent spamming.
    bool    public  enableCustomPool; //Allows interfacing with other IERC20 pools in the RocketPlay contract using the Burn function

    //Determines if the contract executed a swap. Used to prevent circulation issues.
    bool inSwap;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    event ErrorEvent(string reason);
    event SetFeeExempt(address _addr, bool _exempt);
    event SetTxLimitExempt(address _addr, bool _exempt);
    event SetDexRouter(IDEXRouter _router);
    event SetNewFees(uint256 _sellFee, uint256 _transferFee, uint256 _buyFee, uint256 _burnFee, uint256 _rocketFee, uint256 _burn2earnFee);
    event SetInterface(address _interfaceAddr, bool _isInterface, uint256 _fee, bool _isMerchant);
    event SetRocketContract(address _rocketContract, bool _enabled);
    event SetRocketExclusions(address _addr, bool _excludeRocketPlay, bool _excludePoolDistributionGateway, bool _excludeBurnToEarn, bool _excludeRocketForge);
    event SetSwapThreshold(uint256 _swapThreshold);
    event SetTxLimit(uint256 _amount);
    event SetContractInteraction(bool _allowContracts);
    event SetContractInteraction(address _pair, bool _value);
    event TokensBurned(address sender, uint256 amountBurned);

    constructor(address _dexRouter) Auth(msg.sender) {

        router  = IDEXRouter(_dexRouter);
        pair    = IDEXFactory(router.factory()).createPair(router.WETH(), address(this));
        liquidityPairs[pair] = true;

        isFeeExempt[msg.sender]     = true;
        isTxLimitExempt[msg.sender] = true;
        isTxLimitExempt[_dexRouter] = true;
        isTxLimitExempt[pair]       = true;

        _allowances[address(this)][address(router)] = _totalSupply;
        approve(_dexRouter, _totalSupply);
        approve(address(pair), _totalSupply);

        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] -= amount;
        }
        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if (inSwap || interfaces[sender].isInterface || interfaces[recipient].isInterface)
            return _basicTransfer(sender, recipient, amount);

        require(amount <= _maxTxAmount || isTxLimitExempt[sender], "TX Limit Exceeded");

        RocketLibrary.TransferType transferType = _determineTransferType(sender, recipient);

        if (_shouldSwapBack() && transferType != RocketLibrary.TransferType.Transfer)
            _swapBack();
        else if(burnReserve >= burnThreshold)
            _burnTokens();        

        //RocketPlay
        if (address(rocketPlay) != address(0) && transferType != RocketLibrary.TransferType.Sell && !rocketExclusions[sender].excludeRocketPlay) {
            try rocketPlay.playRocketPools(sender, recipient, transferType, amount) {}
            catch Error (string memory reason) {
                emit ErrorEvent("_transferFrom(): rocketPlay.playRocketPools() Failed");
                emit ErrorEvent(reason);
            }
        }
        
        uint amountAfterFee = _getDiscountAndTakeFee(sender, recipient, amount, transferType);

        _setMyRocket(sender, recipient);
        
        uint256 sold;
        if(transferType == RocketLibrary.TransferType.Sell)
                sold = amountAfterFee;

        if(address(burnToEarn) != address(0) && !rocketExclusions[msg.sender].excludeBurnToEarn && sold > 0)
                _updateBurnToEarnFactors(sender, 0, sold);

        if (address(poolDistributionGateway) != address(0)) { 
            uint256 purchased;
            if(transferType == RocketLibrary.TransferType.Buy)
                purchased = amountAfterFee;

            RocketLibrary.Holder memory holder = _updateHolder(address(sender), purchased, sold, interfaces[sender].isMerchant); //creates & updates holder data. Cumulative information
            RocketLibrary.Transfer memory transf = _buildTransfer(holder, amount, transferType, sender, recipient); //creates a transfer for sending to the distribution gateway

            try poolDistributionGateway.onTransfer(transf) {} //store transfer data externally to be used across FightinSquirrelToken EcoSystem
            catch Error (string memory reason) {
                emit ErrorEvent('_transferFrom(): poolDistributionGateway.onTransfer() Failed');
                emit ErrorEvent(reason);
            }
        }

        emit Transfer(sender, recipient, amountAfterFee);
        return true;
    }

    function _internalApprove(address spender, uint256 amount) internal returns (bool) {
        _allowances[msg.sender][spender] = amount;
        return true;
    }

    function _getDiscountAndTakeFee(address sender, address recipient, uint256 amount, RocketLibrary.TransferType transferType) internal returns (uint256) {
        //Grab holder discount information from the RocketForge
        uint256 buyDiscount;
        uint256 sellDiscount; 
        if (address(rocketForge) != address(0)) {
            if(transferType == RocketLibrary.TransferType.Sell && !rocketExclusions[sender].excludeRocketForge) 
                (buyDiscount, sellDiscount) = getDiscount(sender);
            if(transferType == RocketLibrary.TransferType.Buy && !rocketExclusions[recipient].excludeRocketForge)
                (buyDiscount, sellDiscount) = getDiscount(recipient);
        }

        //Calculates and takes applicable fees;
        uint amountAfterFee = isFeeExempt[sender] ? amount : _takeFee(sender, recipient, amount, transferType, buyDiscount, sellDiscount);
        _balances[sender] -= amount;
        _balances[recipient] += amountAfterFee;
        return amountAfterFee;
    }

    //execute any time shareholder balances change to maintain mirrored balance values for external reward distributions
    function _setMyRocket(address sender, address recipient) internal {
        if (address(poolDistributionGateway) != address(0)) {
            uint256 balancesSender = _balances[sender];
            uint256 balancesRecipient = _balances[recipient];

            try poolDistributionGateway.setShares(sender, recipient, balancesSender, balancesRecipient) {} 
            catch Error (string memory reason) {
                emit ErrorEvent("_transferFrom(): poolDistributionGateway.setShares() Failed");
                emit ErrorEvent(reason);
            }
        }
    }

    function _updateHolder(address sender, uint256 purchased, uint256 sold, bool isMerchant) internal returns (RocketLibrary.Holder memory) {
        
        uint256 _totalPurchased   = holders[sender].totalPurchased + purchased;
        uint256 _totalSold        = holders[sender].totalSold + sold;
        
        RocketLibrary.Holder memory holder = RocketLibrary.Holder(sender, _totalPurchased, _totalSold, isMerchant);

        holders[sender] = holder;

        return holder;
    }

    //determines if the transfer is a buy/sell/transfer
    function _determineTransferType(address _from, address _recipient) internal view returns (RocketLibrary.TransferType) {
        if (liquidityPairs[_recipient]) {
            return RocketLibrary.TransferType.Sell;
        } else if (liquidityPairs[_from]) {
            return RocketLibrary.TransferType.Buy;
        }
        return RocketLibrary.TransferType.Transfer;
    }

    //creates the transfer type
    function _buildTransfer(RocketLibrary.Holder memory _holder, uint256 _amt, RocketLibrary.TransferType _transferType, address _from, address _to) internal pure returns (RocketLibrary.Transfer memory) {
        RocketLibrary.Transfer memory _transfer = RocketLibrary.Transfer(_holder, _amt, _transferType, _from, _to);
        return _transfer;
    }

    //handles interface/swap transfers without any other mechanisms. 
    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] -= amount;
        _balances[recipient] += amount;
        if(!inSwap) _setMyRocket(sender, recipient); //ensures holder's shares are updated in the pool distribution gateway,  dex pairs/contracts are exempt at pool distribution gateway. 
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function _takeFee(address _sender, address _receiver, uint256 _amount, RocketLibrary.TransferType _transferType, uint256 _buyDiscount, uint256 _sellDiscount) internal returns (uint256) {
        // Takes the fee and keeps remainder in contract + burnToEarn contract
        uint256 feeAmount = interfaces[_receiver].isMerchant
            ? _amount.mul(interfaces[_receiver].merchantFee).div(10000)
            : _amount.mul(getTotalFee(_transferType, _buyDiscount, _sellDiscount)).div(10000);

        if (feeAmount > 0) {
            //fund external contracts if fees & hooked contracts are present
            (uint256 rocketPlayAlloc, uint256 burn2earnAlloc) = _fundHookedContracts(_sender, feeAmount);
            
            uint256 finalFee = feeAmount.sub(burn2earnAlloc).sub(rocketPlayAlloc); //removes the Burn-to-Earn/RocketPlay contract allocation when Burn-to-Earn/RocketPlay is active

            burnReserve += finalFee.mul(fee.burn).div(fee.sell);//update balance for tokens to be burned in batches to save gas
            
            _balances[address(this)] += finalFee;
            emit Transfer(_sender, address(this), finalFee);
        }
        return (_amount - feeAmount);
    }

    function _fundHookedContracts(address _sender, uint256 feeAmount) internal returns (uint256, uint256) {

        uint256 burn2earnAlloc; //Allocation to send to the Burn 2 Earn Contract for Rewards
        uint256 rocketPlayAlloc; //Allocation reserved for RocketPlay Contract

        if(address(rocketPlay) != address(0) && fee.rocket > 0) {
                rocketPlayAlloc = feeAmount.mul(fee.rocket).div(fee.sell);
                _balances[address(rocketPlay)] += rocketPlayAlloc;
                try rocketPlay.updatePools(rocketPlayAlloc) {} catch {}
                emit Transfer(_sender, address(rocketPlay), rocketPlayAlloc);
        }
            
        if(address(burnToEarn) != address(0) && fee.burn2Earn > 0) {
                burn2earnAlloc = feeAmount.mul(fee.burn2Earn).div(fee.sell);
                _balances[address(burnToEarn)] += burn2earnAlloc;
                try burnToEarn.syncDeposit(burn2earnAlloc) {} catch {}
                emit Transfer(_sender, address(burnToEarn), burn2earnAlloc);
        }
        return (rocketPlayAlloc, burn2earnAlloc);
    }

    function _shouldSwapBack() internal view returns (bool) {
        return ((msg.sender != pair) && (!inSwap) && (_balances[address(this)].sub(burnReserve) >= swapThreshold));
    }

    function _swapBack() internal swapping {
        uint256 amountToSwap = swapThreshold;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amountBNB = address(this).balance;

        if(address(poolDistributionGateway) != address(0)) {
            try poolDistributionGateway.depositBNB{value : amountBNB}() {

            } catch Error(string memory reason) {
                emit ErrorEvent("_swapBack(): poolDistributionGateway.depositBNB() Failed");
                emit ErrorEvent(reason);
            }
        }
    }

    function _playBurnPools(IERC20 token, address holder, uint poolID, uint256 tokenAmount) internal {
        bool success;
        try rocketPlay.validatePoolID(token, poolID) returns (bool _success) {
            success = _success;
        }
        catch Error (string memory reason){
            emit ErrorEvent('_playBurnPools(): rocketPlay.validatePoolID() Failed');
            emit ErrorEvent(reason);
        }
        
        if(success)
        try rocketPlay.playBurnPools(token, holder, poolID, tokenAmount) {} 
        catch Error (string memory reason){
            emit ErrorEvent('_playBurnPools(): rocketPlay.playBurnPools() Failed');
            emit ErrorEvent(reason);
        }
    }

    function _updateBurnToEarnUser(address _holder, uint256 _amountBurned) internal {
        try burnToEarn.updateUser(_holder, _amountBurned) {}
        catch Error (string memory reason){
            emit ErrorEvent('_updateBurnToEarnUser(): burnToEarn.updateUser() Failed');
            emit ErrorEvent(reason);
        }
    }

    function _updateBurnToEarnFactors(address _holder, uint256 boostID, uint256 amountToUpdate) internal {
        try burnToEarn.updateBurnToEarnFactors(_holder, boostID, amountToUpdate) {}
        catch Error (string memory reason){
            emit ErrorEvent('_updateBurnToEarnFactors(): burnToEarn.updateBurnToEarnFactors() Failed');
            emit ErrorEvent(reason);
        }
    }

    function _burnAndUpdateSupply(uint256 tokenAmount, uint256 feeAmount) internal {
        uint256 amountToBurn = tokenAmount.sub(feeAmount); //subtract fee allocation from total to determine amount to burn
        uint256 _total_supply = _totalSupply; //gas savings
        _totalSupply = _total_supply.sub(amountToBurn, 'supply cannot be neg');
        _balances[msg.sender] -= tokenAmount; //requires in place in top call will not revert -=

        _setMyRocket(msg.sender, DEAD); //Dead wallet is exempt inside poolDistributionGateway

        tokensBurned += amountToBurn;

        if(address(burnToEarn) != address(0) && !rocketExclusions[msg.sender].excludeBurnToEarn)
            _updateBurnToEarnUser(msg.sender, amountToBurn);
       
        _internalApprove(address(router), _total_supply);
        _internalApprove(address(pair), _total_supply);
        emit Transfer(msg.sender, address(0), amountToBurn);
        emit TokensBurned(msg.sender, amountToBurn);
    }

    function _takeBurnFee(IERC20 token, uint256 tokenAmount, uint poolID) internal returns (uint256) {
        address _burnToEarn = address(burnToEarn);
        uint rocketPlayFees =  _getRocketFee(token, poolID);   // Grabs current fees from the RocketPlay contract
        uint256 alloc = tokenAmount.mul(rocketPlayFees).div(10000); // Take sell fee alloc and send back to RocketPlay Contract + Other Taxes
        _balances[_burnToEarn] += alloc;
        try burnToEarn.syncDeposit(alloc) {} catch {}
        emit Transfer(msg.sender, _burnToEarn, alloc);
        return alloc;
    }

    function _burnTokens() internal {
        address _FSTAddr = address(this);
        uint256 _burnReserve = burnReserve;
        uint256 _new_supply = _totalSupply.sub(_burnReserve, 'supply cannot be neg');
        _totalSupply = _new_supply;
        _balances[_FSTAddr] = _balances[_FSTAddr].sub(_burnReserve);
        tokensBurned += _burnReserve;
        burnReserve = 0;
        _allowances[_FSTAddr][address(router)] = _new_supply;
        _allowances[_FSTAddr][address(pair)] = _new_supply;
    }

    function _burnTokens(IERC20 token, uint poolID, uint256 tokenAmount, bool justBurn) internal {
        require(tokenAmount > 0, '0 tokens not allowed');
        uint256 feeAmount; //allocation used for fees, default 0
        uint256 _holderBalance = _balances[msg.sender];

        if(address(rocketPlay) != address(0) && !rocketExclusions[msg.sender].excludeRocketPlay && !justBurn) {
            
            uint256 holdAmount;
            if(allowContracts) // Ensures that external unauthorized contracts are unable to interact with the function. Use to mitigate bot spamming. Only allow rocket contracts
                require(!address(msg.sender).isContract() || isRocketContract[msg.sender],'no external contracts allowed'); 

            (tokenAmount, holdAmount) = _getPoolThreshold(token, poolID);   // Gather poolID thresholds for engaging with the Rocket Play platform

            require(_holderBalance >= tokenAmount, 'not enough tokens'); // Ensures balances are checked; as tokenAmount of 1 is overridden. RocketPlay returns the number of tokens required to engage
            require(_holderBalance >= holdAmount, 'does not hodl enough');
            
            _playBurnPools(token, msg.sender, poolID, tokenAmount);

            feeAmount = _takeBurnFee(token, tokenAmount, poolID);
        }
        else
            require(_holderBalance >= tokenAmount, 'does not hodl enough');

        _burnAndUpdateSupply(tokenAmount, feeAmount);
        
    }    

    function _takeExternalFee(uint256 feeAmount) internal returns (bool) {
        // Takes the fee and keeps remainder in contract + burnToEarn contract
        if (feeAmount > 0) {
            
            //fund external contracts if fees & hooked contracts are present
            (uint256 rocketPlayAlloc, uint256 burn2earnAlloc) = _fundHookedContracts(msg.sender, feeAmount);
            
            uint256 finalFee = feeAmount.sub(burn2earnAlloc).sub(rocketPlayAlloc); //removes the Burn-to-Earn/RocketPlay contract allocation when Burn-to-Earn/RocketPlay is active

            //update balance for tokens to be burned in batches to save gas on burn function execution
            burnReserve += finalFee.mul(fee.burn).div(fee.sell);

            _balances[address(this)] += finalFee;
            emit Transfer(msg.sender, address(this), finalFee);
            return true;
        }
        return false;
    }
    
    function _getRocketFee(IERC20 token, uint poolID) internal returns (uint rocketPlayFee) {
        try rocketPlay.getFee(token, poolID) returns (uint _rocketPlayFee) {
            rocketPlayFee = _rocketPlayFee;
        } 
        catch Error (string memory reason){
            emit ErrorEvent('_getRocketFee(): rocketPlay.getFee() Failed');
            emit ErrorEvent(reason);
        }
        return rocketPlayFee;
    }

    function _getPoolThreshold(IERC20 token, uint poolID) internal returns (uint256 poolThreshold, uint256 holdAmount) {
        try rocketPlay.getPoolThreshold(token, poolID) returns (uint256 _poolThreshold, uint256 _holdAmount){
            poolThreshold=_poolThreshold;
            holdAmount = _holdAmount;
        } 
        catch Error (string memory reason){
            emit ErrorEvent('_getPoolThreshold(): rocketPlay.getPoolThreshold() Failed');
            emit ErrorEvent(reason);
        }
        return (poolThreshold, holdAmount);
    }

    // public getters
    function getCirculatingSupply() public view returns (uint256) {
        return (_totalSupply - balanceOf(DEAD) - balanceOf(address(0)));
    }
    
    function getLiquidityBacking(uint256 _accuracy) public view returns (uint256) {
        return _accuracy.mul(balanceOf(pair).mul(2)).div(getCirculatingSupply()); //reserved for external use later
    }

    function isOverLiquified(uint256 _target, uint256 _accuracy) public view returns (bool) {
        return (getLiquidityBacking(_accuracy) > _target);
    }

    //grabs total fee based on transfer type
    function getTotalFee(RocketLibrary.TransferType _transferType, uint256 _buyDiscount, uint256 _sellDiscount) public view returns (uint256) {
        if (_transferType == RocketLibrary.TransferType.Sell) {
            uint256 _sellFee = _sellDiscount > 0 ? fee.sell.sub(fee.sell.mul(_sellDiscount).div(10000)) : fee.sell;
            return _sellFee;
        }
        if (_transferType == RocketLibrary.TransferType.Transfer) {
            return fee.transfer;
        }
        else {
            uint256 _buyFee = _buyDiscount > 0 ? fee.buy.sub(fee.buy.mul(_buyDiscount).div(10000)) : fee.buy;
            return _buyFee;
        }
    }

    //grabs holder discount if applicable from Rocket Forge/Referrals contract
    function getDiscount(address _addr) public returns (uint256 buyDiscount, uint256 sellDiscount) {

        try rocketForge.getDiscount(_addr) returns (uint256 _buyDiscount, uint256 _sellDiscount){
            buyDiscount = _buyDiscount;
            sellDiscount = _sellDiscount;

        } catch Error (string memory reason){
            emit ErrorEvent('getDiscount(): rocketForge.getDiscount() Failed');
            emit ErrorEvent(reason);

            buyDiscount = 0;
            sellDiscount = 0;
        }
        return (buyDiscount, sellDiscount);
    }

    // authorized setters
    function setNewFees(uint256 _sellFee, uint256 _transferFee, uint256 _buyFee, uint256 _burnFee, uint256 _rocketFee, uint256 _burn2earnFee) external authorized {
        require(_sellFee <= 10000
        && _transferFee <= 10000
        && _buyFee <= 10000
        && _burnFee + _rocketFee + _burn2earnFee <= _sellFee, "New fees should be less than entire sell fee");
        
        fee.sell = _sellFee;
        fee.transfer = _transferFee;
        fee.buy = _buyFee;
        fee.burn = _burnFee;
        fee.rocket = _rocketFee;
        fee.burn2Earn = _burn2earnFee;

        if(_burnFee == 0)
            burnReserve = 0;
        emit SetNewFees( _sellFee,  _transferFee, _buyFee, _burnFee, _rocketFee, _burn2earnFee);
    }

    //update DEX router
    function setDexRouter(IDEXRouter _router) external authorized {
        router = _router;
        
        emit SetDexRouter(_router);
    }

    function setTxLimit(uint256 _amount) external authorized {
        _maxTxAmount = _amount;
        emit SetTxLimit(_amount);
    }
    //allows authorized external contracts to interact with the burn pool
    function setContractInteraction(bool _allowContracts) external authorized {
        allowContracts = _allowContracts;
        emit SetContractInteraction( _allowContracts);
    }

    function setIsFeeExempt(address _addr, bool _exempt) external authorized {
        isFeeExempt[_addr] = _exempt;
        emit SetFeeExempt(_addr, _exempt);
    }

    function setIsTxLimitExempt(address _addr, bool _exempt) external authorized {
        isTxLimitExempt[_addr] = _exempt;
        emit SetTxLimitExempt(_addr, _exempt);
    }

    function setLiquidityPair(address _pair, bool _value) external authorized {
        liquidityPairs[_pair] = _value;
        emit SetContractInteraction(_pair,_value);
    }
    //threshold of FightinSquirrelToken to collect before burning from supply
    function setBurnThreshold(uint256 _burnThreshold) external authorized {
        burnThreshold = _burnThreshold;
    }
    //threshold to determine how much FightinSquirrelToken needs to be in the contract to liquidate for rewards
    function setSwapThreshold(uint256 _swapThreshold) external authorized {
        swapThreshold = _swapThreshold;
        emit SetSwapThreshold(_swapThreshold);
    }
    //exempts address from external ecosystem contracts as needed
    function setRocketExclusions(address _addr, bool _excludeRocketPlay, bool _excludePoolDistributionGateway, bool _excludeBurnToEarn, bool _excludeRocketForge) external authorized {
        rocketExclusions[_addr].excludeRocketPlay = _excludeRocketPlay;
        rocketExclusions[_addr].excludePoolDistributionGateway = _excludePoolDistributionGateway;
        rocketExclusions[_addr].excludeBurnToEarn = _excludeBurnToEarn;
        rocketExclusions[_addr].excludeRocketForge = _excludeRocketForge;
        emit SetRocketExclusions( _addr,  _excludeRocketPlay,  _excludePoolDistributionGateway,  _excludeBurnToEarn, _excludeRocketForge);
    }
    //allows basic transfers of tokens without any of the hooks, with the exception of the pool distribution gateway only when present
    function setInterface(address _interfaceAddr, bool _isInterface, uint256 _fee, bool _isMerchant) external authorized {
        interfaces[_interfaceAddr].isInterface = _isInterface;
        interfaces[_interfaceAddr].merchantFee = _fee;
        interfaces[_interfaceAddr].isMerchant  = _isMerchant;
        emit SetInterface(_interfaceAddr, _isInterface, _fee, _isMerchant);
    }
    //set interfacing contract addresses, allows future modularity and upgradeability 
    function setContractInterfaces(IPoolDistributionGateway _poolManager, IRocketPlay _rocketPlay, IRocketForge _rocketForge, IBurnToEarn _burnToEarn) external authorized {
        
        //Set Authorizations after setting Rocket Contract Interfaces;
        poolDistributionGateway = _poolManager;
        rocketPlay              = _rocketPlay;
        rocketForge             = _rocketForge;
        burnToEarn              = _burnToEarn;

        if(address(poolDistributionGateway)!=address(0))
            isRocketContract[address(poolDistributionGateway)] = true;
        if(address(rocketPlay)!=address(0))
            isRocketContract[address(rocketPlay)] = true;
        if(address(rocketForge)!=address(0))
            isRocketContract[address(rocketForge)] = true;
        if(address(burnToEarn)!=address(0))
            isRocketContract[address(burnToEarn)] = true;
    }
    //Allows authorized FightinSquirrelToken eco system contracts access to the _burnTokens function 
    function setRocketContract(address _rocketContract, bool _enabled) external authorized {
        isRocketContract[_rocketContract] = _enabled;
        emit SetRocketContract( _rocketContract, _enabled);
    }
    //Allow additional pools to be rolled for/engaged during burning
    function setCustomPool(bool _enableCustomPool) external authorized {
        enableCustomPool = _enableCustomPool;
    }
    //Allows external Rocket contract/external source contribute directly to contract fees
    function takeFee(uint256 feeAmount) external returns (bool) {
        uint256 holderAmount = _balances[msg.sender];
        require(holderAmount >= feeAmount, 'does not hold enough');
        _balances[msg.sender] -= feeAmount;
        return _takeExternalFee(feeAmount);
    }
    //function to manually kick off swapback
    function manualSwapBack() external {
        if(_shouldSwapBack())
            _swapBack();
    }
    //Manually deposit tokens to the specified rocket pool
    function depositTokenToRocketPools(uint256[3] memory boostAmounts) external {
        address rocketPlayAddr = address(rocketPlay);
        require(rocketPlayAddr != address(0),'not activated');
        uint256 _totalTokens = boostAmounts[0] + boostAmounts[1] + boostAmounts[2];
        require(_balances[msg.sender] >= _totalTokens,'not enough tokens');
        
        uint256 _finalBalance;
        //boostAmounts[0] is BurnBoost;
        //boostAmounts[1] is BuyBoost;
        //boostAmounts[2] is TransferBoost;

        for(uint x=0; x < boostAmounts.length; x++) {
            if(boostAmounts[x] > 0)
                try rocketPlay.updatePoolByID(x, boostAmounts[x]) {
                _finalBalance += boostAmounts[x];
                } catch {}
        }

        //only update balances & kick off rewarding rocketfuel points (pool id 2 in Burn To Earn if _finalBalance > 0
        if(_finalBalance > 0){
            if(address(burnToEarn) != address(0) && !rocketExclusions[msg.sender].excludeBurnToEarn)
                    _updateBurnToEarnFactors(msg.sender, 2, _finalBalance);
            _balances[rocketPlayAddr] += _finalBalance;
            _balances[msg.sender] -= _finalBalance;
            _setMyRocket(msg.sender, rocketPlayAddr); //rocketPlayAddr is exempt from the Pool Distribution Participation
        }
    }
    //Public & External Interactive Functions
    //Burn Functions
    function burnTokenOnly(uint256 tokenAmount) external {
        _burnTokens(IERC20(this), 0, tokenAmount, true);
    }
    function burnForDefaultPool(uint poolID) external {
        _burnTokens(IERC20(this), poolID, 1, false);
    }
    function burnForCustomPool(address token, uint poolID) external {
        require(enableCustomPool,'feature not enabled');
        _burnTokens(IERC20(token), poolID, 1, false);
    }
    function transferBNB(address payable _to) external authorized {
        (bool success,) = _to.call{value : address(this).balance}("");
        require(success, "unable to transfer value");
    }

    //Interface functions
    receive() external payable {}

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }
    function decimals() public pure returns (uint8) {
        return _decimals;
    }
    function symbol() public pure returns (string memory) {
        return _symbol;
    }
    function name() public pure returns (string memory) {
        return _name;
    }
    function getOwner() public view override returns (address) {
        return owner;
    }
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }
    function allowance(address holder, address spender) external view override returns (uint256) {
        return _allowances[holder][spender];
    }
    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
    function approveMax(address spender) external returns (bool) {
        return approve(spender, _totalSupply);
    }
    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }
}