// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./interfaces/IWETH.sol";
import "./interfaces/IUniswapV2Factory.sol";
import "./interfaces/IUniswapV2Router02.sol";
import "./interfaces/IEarn.sol";
import "./interfaces/IToken.sol";
import "./interfaces/IRouterFarming.sol";
import "./libraries/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./libraries/Auth.sol";

contract FarmingBNB is Auth, ERC20 {
    using SafeMath for uint256;
    
    address public tokenAddress;
    address public routerAddress;
    address public factoryAddress;
    address public pairAddress;
    address public rewardAddress;
    address public wethAddress;
    address public tokenA; //should Dino
    address public tokenB;

    uint256 public lastResetAPR = 0;
    uint256 public loopInterest = 0;
    uint256 public APR = 0;    
    bool public isCountAPRAYREnable = true;
    uint256 public totalReceiveWeekBNB = 0;
    uint256 public totalClaimWeekly = 0;

    uint256 public totalParticipant;

    mapping (address => uint256) public amountDepositTokenA;
    mapping (address => uint256) public amountDepositTokenB;


    uint256 public totalDividends;
    uint256 public totalDistributed;
    uint256 public totalDistributeToWeth;
    uint256 public totalShares;
    uint256 public dividendsPerShare;
    uint256 public dividendsPerShareAccuracyFactor = 10**36;

    bool public isTaxClaimToOtherTokenActive = true;
    uint256 public percentClaimToOtherToken = 400;
    uint256 public percentTaxDenominator = 10000;
    mapping (address => bool) public isExcludeFromFee;
    address public addressReceiverTax = 0x96f3E92EC8dD881870E48501bF34976224e16352;

    address[] shareholders;
    mapping (address => uint256) shareholderIndexes;
    mapping (address => uint256) shareholderClaims;
    mapping (address => uint256) public lockedLiquidity;
    mapping (address => address) public lockedReflectTo;
    mapping (address => bool) public isDisableFromUnstake;
    
    uint256 public totalLockedLiquidity;

    mapping (address => uint256) public totalDistributeToToken;

    uint256 public minimumDinoLeftOnHolderWallet = 0;

    uint256 public accumulateDividend;

    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalClaimed;
    }
    mapping (address => Share) public shares;

    event AddFarming(address account,uint256 amountTokenA, uint256 amountTokenB, uint256 amountLiquidity);
    event RemoveFarming(address account,uint256 amountLiquidity,address recipient,uint256 amountTokenA,uint256 amountTokenB);
    event Deposit(address account, uint256 amount);

    modifier onlyToken() {
        require(_msgSender()==tokenAddress,"DinoFarming: OnlyToken");
        _;
    }

    constructor(address _tokenAddress, address _routerAddress, address _tokenB, address _rewardAddress)  Auth(msg.sender) ERC20("Dino Farming PCs", "DinoBNB-FP") {
        tokenAddress = _tokenAddress;
        routerAddress = _routerAddress;
        tokenA = _tokenAddress;
        tokenB = _tokenB;
        factoryAddress = IUniswapV2Router02(_routerAddress).factory();
        pairAddress = IUniswapV2Factory(factoryAddress).getPair(tokenA,tokenB);
        rewardAddress = _rewardAddress;
        wethAddress = IUniswapV2Router02(routerAddress).WETH();
        _mint(_msgSender(),0);
    }

    receive() external payable {
        
    }

    function countAPRAPY(uint256 amount) internal {
        if(block.timestamp.sub(lastResetAPR) >= 7 days) {
            totalReceiveWeekBNB = 0;
            totalClaimWeekly = 0;
            loopInterest = 1;
            lastResetAPR = block.timestamp;
        }

        totalReceiveWeekBNB = totalReceiveWeekBNB.add(amount);
        
        unchecked {
            uint year = 365;
            uint day = 7;
            APR = totalReceiveWeekBNB.mul(percentTaxDenominator).div(totalShares).mul(year.div(day)).mul(100).div(percentTaxDenominator);
        }
    }

   function addFarming(uint256 amountTokenForFarming, address recipient) external payable {

      // Transfer token to this contract
      uint256 balanceTokenBefore = ERC20(tokenAddress).balanceOf(address(this));
       uint256 amountForFarm = getAmountForFarm(_msgSender(),amountTokenForFarming);
      ERC20(tokenAddress).transferFrom(_msgSender(), address(this), amountForFarm);
      uint256 balanceTokenAfter = ERC20(tokenAddress).balanceOf(address(this));
      uint256 balanceForFarming = balanceTokenAfter.sub(balanceTokenBefore);

       // Deposit WETH
       uint256 balanceWethBefore = IWETH(wethAddress).balanceOf(address(this));
       IWETH(wethAddress).deposit{value:msg.value}();
       uint256 balanceWethAfter = IWETH(wethAddress).balanceOf(address(this));
       uint256 balanceWethForFarming = balanceWethAfter.sub(balanceWethBefore);

      // Approve Token to Router Address
      ERC20(tokenAddress).approve(routerAddress, balanceForFarming);

       // Approve WETH to Router Address
       IWETH(wethAddress).approve(routerAddress,balanceWethForFarming);

       // Add Liquidity
       IUniswapV2Router02 router = IUniswapV2Router02(routerAddress);
       (uint256 amountTokenA, uint256 amountTokenB, uint256 liquidity) = router.addLiquidity(
            tokenA,
            tokenB,
            balanceForFarming,
            balanceWethForFarming,
            0,
            0,
            address(this),
            block.timestamp
       );

       amountDepositTokenA[recipient] = amountDepositTokenA[recipient].add(balanceForFarming);
       amountDepositTokenB[recipient] = amountDepositTokenB[recipient].add(balanceWethForFarming);
       _mint(recipient,liquidity);
       setShare(recipient);
       calculateShare();

       // staking left, send back to user
       uint256 amountLeft = amountTokenForFarming.sub(amountTokenA);
       if(amountLeft > 0) ERC20(tokenAddress).transfer(_msgSender(),amountLeft);

       emit AddFarming(recipient,amountTokenA,amountTokenB,liquidity);
   }

    function getAmountForFarm(address holder,uint256 amount) internal view returns(uint256){
        uint256 currentBalance = ERC20(tokenAddress).balanceOf(holder);
        require(currentBalance > minimumDinoLeftOnHolderWallet,"DinoFarming: Insufficient Balance For Farming");
        if(currentBalance.sub(amount) < minimumDinoLeftOnHolderWallet) {
            return amount.sub(minimumDinoLeftOnHolderWallet);
        }
        return amount;
    }

   function removeFarming(uint256 amountRemove, address recipient) external {
       require(!isDisableFromUnstake[_msgSender()],"DinoFarming: This Address Is Locked Liquidity");
       require(balanceOf(_msgSender()) >= amountRemove,"DinoFarming: Insufficient Amount");
        // Exclude From Fee for Pair
       IToken(tokenAddress).setIsExcludeFromFee(pairAddress,true);

       // Approve LP Token for transfer to routerAddress
       ERC20(pairAddress).approve(routerAddress,amountRemove);

       // Get Amount Token and Eth Before
       uint256 amountTokenBefore = ERC20(tokenAddress).balanceOf(address(this));
       uint256 amountEthBefore = IWETH(wethAddress).balanceOf(address(this));

       // Remove Liquidity
       IUniswapV2Router02 router = IUniswapV2Router02(routerAddress);
       (uint256 amountA, uint256 amountB) = router.removeLiquidity(
            tokenA,
            tokenB,
            amountRemove,
            0,
            0,
            address(this),
            block.timestamp
       );

       uint256 amountTokenAfter = ERC20(tokenAddress).balanceOf(address(this));
       uint256 amountEthAfter = IWETH(wethAddress).balanceOf(address(this));
       uint256 amountTokenDiff = amountTokenAfter.sub(amountTokenBefore);
       uint256 amountEthDiff = amountEthAfter.sub(amountEthBefore);

        // Transfer Token to Requester
       ERC20(tokenAddress).transfer(recipient,amountTokenDiff);

       // Transfer WETH to Requester
       IWETH(wethAddress).withdraw(amountEthDiff);
       payable(recipient).transfer(amountEthDiff);

       // calculate amount requester
       IToken(tokenAddress).setIsExcludeFromFee(pairAddress,false);
       _burn(_msgSender(),amountRemove);
       setShare(_msgSender());
       calculateShare();

       emit RemoveFarming(_msgSender(),amountRemove,recipient,amountA,amountB);
   }

    function setRewardShare() public {
        IEarn(rewardAddress).setShare(address(this),ERC20(tokenAddress).balanceOf(pairAddress));
    }

    function getTokenFromContract(address _tokenAddress, address to, uint256 amount) external onlyOwner {
        try ERC20(_tokenAddress).approve(to, amount) {} catch {}
        try ERC20(_tokenAddress).transfer(to,amount) {} catch {}
    }

    function deposit(uint256 loop) public payable {
        calculateShare(); 
        countAPRAPY(msg.value);
        emit Deposit(msg.sender,msg.value);
    }

    function calculateShare() public {
        IEarn(rewardAddress).claimFarmingReward(address(this));
        uint256 balanceBefore = IWETH(wethAddress).balanceOf(address(this));
        uint256 ethBalanceForDeposit = address(this).balance;
        if(ethBalanceForDeposit > 0){
            IWETH(wethAddress).deposit{value:ethBalanceForDeposit}();
            uint256 balanceAfter = IWETH(wethAddress).balanceOf(address(this));
            uint256 balanceDiff = balanceAfter.sub(balanceBefore);
            if(totalSupply() > 0){
                totalDividends = totalDividends.add(balanceDiff);
                dividendsPerShare = dividendsPerShare.add(dividendsPerShareAccuracyFactor.mul(balanceDiff).div(totalSupply()));
            }
        }
        setRewardShare();
    }

    function transferWeth(address to, uint256 amount) external onlyOwner {
        _transferWeth(to,amount);
    }

    function _transferWeth(address to, uint256 amount) internal {
        payable(to).transfer(amount);
    }

    function setShare(address account) internal {
        uint256 amount = balanceOf(account);

        if(amount > 0 && shares[account].amount == 0){
            addShareholder(account);
        }else if(amount == 0 && shares[account].amount > 0){
            removeShareholder(account);
        }

        totalShares = totalShares.sub(shares[account].amount).add(amount);
        shares[account].amount = amount;
        shares[account].totalExcluded = getCumulativeDividend(shares[account].amount);
    }

    /** Adding share holder */
    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }

    /** Remove share holder */
    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length-1];
        shareholderIndexes[shareholders[shareholders.length-1]] = shareholderIndexes[shareholder];
        shareholders.pop();
    }

    /** Get cumulative dividend */
    function getCumulativeDividend(uint256 share) internal view returns (uint256) {
        return share.mul(dividendsPerShare).div(dividendsPerShareAccuracyFactor);
    }

    /** Get dividend of account */
    function dividendOf(address account) public view returns (uint256) {

        if(shares[account].amount == 0){ return 0; }

        uint256 shareholderTotalDividends = getCumulativeDividend(shares[account].amount);
        uint256 shareholderTotalExcluded = shares[account].totalExcluded;

        if(shareholderTotalDividends <= shareholderTotalExcluded){ return 0; }

        return shareholderTotalDividends.sub(shareholderTotalExcluded);
    }

    /** Claim to Dino */
    function claim(address account) external {
        _claimToDino(account);
    }

    /** Claim to other token */
    function claimTo(address account, address targetToken) external  {
        _claimToToken(account,targetToken);
    }

    /** Claim to weth */
    function claimToWeth(address account) external{
        _claimToWeth(account);
    }

    /** execute claim to token */
    function _claimToToken(address account, address targetToken) internal {
        IUniswapV2Router02 router = IUniswapV2Router02(routerAddress);
        uint256 amount = isShouldGetFee(account) ? getFee(dividendOf(account)) : dividendOf(account);
        if(amount > 0){
            // IWETH(wethAddress).deposit{value:amount}();

            address[] memory path = new address[](2);
            path[0] = wethAddress;
            path[1] = targetToken;
            IWETH(wethAddress).approve(routerAddress,amount);
            router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                amount,
                0,
                path,
                account,
                block.timestamp
            );
            totalDistributeToToken[targetToken] = totalDistributeToToken[targetToken].add(amount);
            setClaimed(account,amount);
        }
    }

    function _claimToDino(address account) internal {
        IUniswapV2Router02 router = IUniswapV2Router02(routerAddress);
        uint256 amount = dividendOf(account);
        if(amount > 0){
            address[] memory path = new address[](2);
            path[0] = wethAddress;
            path[1] = tokenAddress;
            IWETH(wethAddress).approve(routerAddress,amount);
            uint256[] memory estimate = router.getAmountsOut(amount,path);
            uint256 balanceBeforeSwap = ERC20(tokenAddress).balanceOf(address(this));
            router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                amount,
                estimate[1],
                path,
                address(this),
                block.timestamp
            );
            uint256 balanceAfterSwap = ERC20(tokenAddress).balanceOf(address(this));
            uint256 balanceTransfer = balanceAfterSwap.sub(balanceBeforeSwap);
            ERC20(tokenAddress).transfer(account,balanceTransfer);
            totalDistributeToToken[tokenAddress] = totalDistributeToToken[tokenAddress].add(amount);
            setClaimed(account,amount);
        }
    }

    function estimationReward(address account, address token) external view returns(uint[] memory amounts){
        uint256 dividend = dividendOf(account);
        IUniswapV2Router02 router = IUniswapV2Router02(routerAddress);
        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = token;
        return router.getAmountsOut(dividend,path);
        
    }

    function getFee(uint256 amount) internal returns(uint256){
        if(!isTaxClaimToOtherTokenActive) return amount;
        uint256 amountFee = amount.mul(percentClaimToOtherToken).div(percentTaxDenominator);
        if(amountFee > 0){
            uint256 balanceBefore = address(this).balance;
            IWETH(wethAddress).withdraw(amountFee);
            uint256 balanceAfter = address(this).balance;
            payable(addressReceiverTax).transfer(balanceAfter.sub(balanceBefore));
        }
        return amount.sub(amountFee);
    }

    function isShouldGetFee(address holder) public view returns(bool){
        return !isExcludeFromFee[holder];
    }

    /** execute claim to weth */
    function _claimToWeth(address account) internal {
        uint256 amount = isShouldGetFee(account) ? getFee(dividendOf(account)) : dividendOf(account);
        if(amount > 0){
            uint256 amountBefore = address(this).balance;
            IWETH(wethAddress).withdraw(amount);
            uint256 amountAfter = address(this).balance;
            uint256 amountDiff = amountAfter.sub(amountBefore);
            payable(account).transfer(amount);
            totalDistributeToWeth = totalDistributeToWeth.add(amount);
            setClaimed(account,amount);
        }
    }

    /** get total claim token in weth */
    function claimTotalOf(address account) external view returns(uint256){
        return shares[account].totalClaimed;
    }

    /** Set claimed state */
    function setClaimed(address account, uint256 amount) internal {
        shareholderClaims[account] = block.timestamp;
        shares[account].totalClaimed = shares[account].totalClaimed.add(amount);
        shares[account].totalExcluded = getCumulativeDividend(shares[account].amount);
        totalDistributed = totalDistributed.add(amount);
        calculateShare();
    }

    function setPercentClaimToOtherToken(uint256 percent) external onlyOwner {
        require(percent >= 100 && percent <= 5000, "DinoFarming: min 1% and max 50%");
        percentClaimToOtherToken = percent;
    }

    function setIsTaxClaimToOtherToken(bool state) external onlyOwner {
        isTaxClaimToOtherTokenActive = state;
    }

    function setIsExcludeFromFee(address holder, bool state) external onlyOwner {
        isExcludeFromFee[holder] = state;
    }

    function setAddressReceiverTax(address account) external onlyOwner {
        addressReceiverTax = account;
    }

    function setMinimumDinoOnHolderWallet(uint256 amount) external onlyOwner {
        minimumDinoLeftOnHolderWallet = amount;
    }

    function _afterTokenTransfer(address sender, address recipient, uint256 amount) internal override virtual {
        setShare(sender);
        setShare(recipient);
        if(sender != address(0)) {
            setRewardShare();
            calculateShare();
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override virtual {
        if(amount > 0){
            if(from != address(0) && balanceOf(from).sub(amount) == 0 && totalParticipant > 0) totalParticipant = totalParticipant.sub(1);
            if(to != address(0) && balanceOf(to) == 0) totalParticipant = totalParticipant.add(1);
        }
        // calculateShare();
        // setRewardShare();
    }

    function setLockedLiquidity(address pairAddress, address lockedAddress, address recipient) external onlyOwner {
        uint256 balance = ERC20(pairAddress).balanceOf(lockedAddress);
        require(balance > 0,"DinoFarming: Insufficient Amount");
        
        if(balanceOf(lockedReflectTo[pairAddress]) > 0) _burn(lockedReflectTo[pairAddress],balanceOf(lockedReflectTo[pairAddress]));

        totalLockedLiquidity = totalLockedLiquidity.sub(lockedLiquidity[pairAddress]);
        lockedLiquidity[pairAddress] = balance;
        lockedReflectTo[pairAddress] = recipient;
        totalLockedLiquidity = totalLockedLiquidity.add(balance);

        isDisableFromUnstake[recipient] = true;

        _mint(recipient,balance);
    }

    function removeLockedLiquidity(address pairAddress) external onlyOwner {
        require(balanceOf(lockedReflectTo[pairAddress]) > 0,"DinoFarming: No Locked Found for This pair");
        _burn(lockedReflectTo[pairAddress],balanceOf(lockedReflectTo[pairAddress]));
        isDisableFromUnstake[lockedReflectTo[pairAddress]] = false;
        totalLockedLiquidity = totalLockedLiquidity.sub(lockedLiquidity[pairAddress]);
        lockedLiquidity[pairAddress] = 0;
        lockedReflectTo[pairAddress] = address(0);
        
    }

    function setCountAPRAPY(bool state) external onlyOwner {
        isCountAPRAYREnable = state;
    }

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
    function balanceOf(address account) external view returns (uint256);
    function approve(address guy, uint wad) external returns (bool);
    function transferFrom(address src, address dst, uint256 wad) external returns (bool);
    function allowance(address _owner, address spender)
        external
        view
        returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IUniswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import './IUniswapV2Router01.sol';

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IEarn{
    function setShare(address account,uint256 amount) external;
    function migrate(address rewardAddress, uint256 gas) external;
    function setMigration(address account, uint256 totalExclude, uint256 totalClaimed) external;
    function distributeDividend() external;
    function claim(address account) external;
    function claimTo(address account, address targetToken) external;
    function claimToWeth(address account) external;
    function claimTotalOf(address account) external returns(uint256);
    function deposit(uint256 loop) external payable;
    function dividendOf(address account) external view returns(uint256);
    function claimFarmingReward(address pairAddress) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IToken {
    function setIsExcludeFromFee(address _address, bool _status) external;
    function setRecipientExcludeFromFee(address _address, bool _status) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IRouterFarming {
    function wbnbAddress() external view returns (address);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library SafeMath {
    function tryAdd(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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

    function tryDiv(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract Auth {
    address internal owner;
    mapping(address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), "BabyToken: !OWNER");
        _;
    }

    modifier authorized() {
        require(isAuthorized(msg.sender), "BabyToken: !AUTHORIZED");
        _;
    }

    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    function _getOwner() public view returns (address) {
        return owner;
    }

    event OwnershipTransferred(address owner);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
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