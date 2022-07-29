/**
 *Submitted for verification at BscScan.com on 2022-07-29
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
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


interface IDexFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}


interface IDexRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function getAmountsOut(
        uint amountIn,
        address[] calldata path
    ) external view returns (uint[] memory amounts);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function swapExactETHForTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts);
    function swapExactTokensForETH(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
}


contract DividendDistributor is ReentrancyGuard {
    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
    }

    IDexRouter public constant ROUTER = IDexRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    address public immutable token;
    address public reward = ROUTER.WETH();

    address[] shareHolders;
    uint256 currentIndex;

    mapping (address => Share) public shares;
    mapping (address => uint256) shareholderIndexes;
    mapping (address => uint256) shareholderClaims;

    uint256 public totalDistributed;
    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public dividendsPerShare;
    uint256 public dividendsPerShareAccuracyFactor = 10**18;

    uint256 public gasLimit = 250000;
    uint256 public minPeriod = 1 hours;
    uint256 public minDistribution = 10**17;
    
    event DividendDistributed(address to, uint256 amount);
    event DividendDistributionFailed(address account);
    event Deposit(uint256 amount);
    event SetShare(address account, uint256 amount);
    event Process();
    event SetRewardToken(address reward);
    event SetDistributionCriteria(uint256 period, uint256 amount);
    event SetGasLimit(uint256 gas);

    modifier onlyToken() {
        require(msg.sender == token, "Caller is not the token");
        _;
    }

    constructor() {
        token = msg.sender;
    }

    // Token

    function deposit() external payable onlyToken {
        if (msg.value > 0) {
            totalDividends += msg.value;
            dividendsPerShare += dividendsPerShareAccuracyFactor * msg.value / totalShares;
            emit Deposit(msg.value);
        }
    }

    function setShare(address shareholder, uint256 amount) external onlyToken {
        if(shares[shareholder].amount > 0){
            distributeDividend(shareholder);
        }

        if(amount > 0 && shares[shareholder].amount == 0){
            addShareholder(shareholder);
        }else if(amount == 0 && shares[shareholder].amount > 0){
            removeShareholder(shareholder);
        }

        totalShares = totalShares - shares[shareholder].amount + amount;
        shares[shareholder].amount = amount;
        shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);

        emit SetShare(shareholder, amount);
    }

    function process() external onlyToken {
        uint256 shareholderCount = shareHolders.length;

        if(shareholderCount == 0) { return; }

        uint256 gasLeft = gasleft();
        uint256 gasUsed;
        uint256 avgGasCost;
        uint256 iterations;

        while(gasUsed + avgGasCost < gasLimit && iterations < shareholderCount) {
            if(currentIndex >= shareholderCount){
                currentIndex = 0;
            }

            if(shouldDistribute(shareHolders[currentIndex])){
                distributeDividend(shareHolders[currentIndex]);
            }

            gasUsed += gasLeft - gasleft();
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
            avgGasCost = gasUsed / iterations;
        }

        emit Process();
    }

    // Public

    function claimDividend() external {
        distributeDividend(msg.sender);
    }

    function getUnpaidEarnings(address shareholder) public view returns (uint256) {
        if(shares[shareholder].amount == 0){ return 0; }

        uint256 shareholderTotalDividends = getCumulativeDividends(shares[shareholder].amount);
        uint256 shareholderTotalExcluded = shares[shareholder].totalExcluded;

        if(shareholderTotalDividends <= shareholderTotalExcluded){ return 0; }
        return shareholderTotalDividends - shareholderTotalExcluded;
    }

    // Private
    
    function shouldDistribute(address shareholder) private view returns (bool) {
        return shareholderClaims[shareholder] + minPeriod < block.timestamp
                && getUnpaidEarnings(shareholder) > minDistribution;
    }

    function distributeDividend(address shareholder) private nonReentrant {
        if(shares[shareholder].amount == 0){ return; }

        uint256 amount = getUnpaidEarnings(shareholder);
        if(amount > 0){
            if(reward == ROUTER.WETH()) {
                (bool success,) = payable(shareholder).call{value: amount}("");
                if (success) {
                    totalDistributed += amount;
                    shareholderClaims[shareholder] = block.timestamp;
                    shares[shareholder].totalRealised += amount;
                    shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
                    emit DividendDistributed(shareholder, amount);
                } else {
                    emit DividendDistributionFailed(shareholder);
                }
            } else {
                address[] memory path = new address[](2);
                path[0] = ROUTER.WETH();
                path[1] = reward;

                try ROUTER.swapExactETHForTokens{value: amount}(
                    0,
                    path,
                    shareholder,
                    block.timestamp
                ) {
                    totalDistributed += amount;
                    shareholderClaims[shareholder] = block.timestamp;
                    shares[shareholder].totalRealised += amount;
                    shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
                    emit DividendDistributed(shareholder, amount);
                } catch {
                    emit DividendDistributionFailed(shareholder);
                }
            }
        }
    }

    function getCumulativeDividends(uint256 share) private view returns (uint256) {
        return share * dividendsPerShare / dividendsPerShareAccuracyFactor;
    }

    function addShareholder(address shareholder) private {
        shareholderIndexes[shareholder] = shareHolders.length;
        shareHolders.push(shareholder);
    }

    function removeShareholder(address shareholder) private {
        shareHolders[shareholderIndexes[shareholder]] = shareHolders[shareHolders.length-1];
        shareholderIndexes[shareHolders[shareHolders.length-1]] = shareholderIndexes[shareholder];
        shareHolders.pop();
    }

    // Maintenance

    function setRewardToken(address newReward) external onlyToken {
        require(
            newReward == ROUTER.WETH() || // BNB
            newReward == 0x2170Ed0880ac9A755fd29B2688956BD959F933F8 || // ETH
            newReward == 0xCC42724C6683B7E57334c4E856f4c9965ED682bD || // MATIC
            newReward == 0x570A5D26f7765Ecb712C0924E4De545B89fD43dF || // SOL
            newReward == 0x1CE0c2827e2eF14D5C4f29a091d735A204794041 || // AVAX
            newReward == 0x0Eb3a705fc54725037CC9e008bDede697f62F335 || // ATOM
            newReward == 0x1D2F0da169ceB9fC7B3144628dB156f3F6c60dBE, // XRP
            "Invalid reward address"
        );

        reward = newReward;
        emit SetRewardToken(reward);
    }

    function setDistributionCriteria(uint256 newMinPeriod, uint256 newMinDistribution) external onlyToken {
        require(newMinPeriod <= 1 weeks && newMinDistribution <= 1 ether, "Parameters out of bounds");
        
        minPeriod = newMinPeriod;
        minDistribution = newMinDistribution;
        emit SetDistributionCriteria(newMinPeriod, newMinDistribution);
    }

    function setGasLimit(uint256 gas) external onlyToken {
        require(gas <= 750000 && gas >= 100000, "Gas limit out of bounds");
        
        gasLimit = gas;
        emit SetGasLimit(gas);
    }
}