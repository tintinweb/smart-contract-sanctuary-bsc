//SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.15;

import "./interfaces/IDividendDistributor.sol";
import "./interfaces/IDEXRouter.sol";
import "./interfaces/IBEP20.sol";
import "./abstracts/TokenGuard.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract DividendDistributor is
    IDividendDistributor,
    ReentrancyGuard,
    TokenGuard
{
    IDEXRouter router;
    address routerAddress = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
    IBEP20 RewardToken = IBEP20(0x8301F2213c0eeD49a7E28Ae4c3e91722919B8B47); //BUSD
    bool rewardTokenHasTxFee = false;

    address[] shareholders;
    mapping(address => uint256) public shareholderIndexes;
    mapping(address => uint256) public shareholderClaims;
    mapping(address => Share) public shares;

    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalDistributed;
    uint256 public dividendsPerShare;
    uint256 public dividendsPerShareAccuracyFactor = 10**36;

    uint256 public minPeriod = 30 minutes;
    uint256 public minDistribution = 1 * (10**18);

    uint256 public currentIndex;

    bool initialized;
    modifier initialization() {
        require(!initialized);
        _;
        initialized = true;
    }

    constructor() ReentrancyGuard() TokenGuard() {}

    function setDistributionCriteria(
        uint256 newMinPeriod,
        uint256 newMinDistribution
    ) external override onlyToken {
        minPeriod = newMinPeriod;
        minDistribution = newMinDistribution;

        emit DistributionCriteriaChanged(newMinPeriod, newMinDistribution);
    }

    function setRewardToken(address token, bool chargeTxFee)
        external
        onlyToken
    {
        RewardToken = IBEP20(token); //BUSD
        rewardTokenHasTxFee = chargeTxFee;

        emit RewardTokenChanged(token, chargeTxFee);
    }

    function setShare(address shareholder, uint256 amount)
        external
        override
        onlyToken
    {
        if (shares[shareholder].amount > 0) {
            distributeDividend(shareholder);
        }

        if (amount > 0 && shares[shareholder].amount == 0) {
            addShareholder(shareholder);
        } else if (amount == 0 && shares[shareholder].amount > 0) {
            removeShareholder(shareholder);
        }

        totalShares = totalShares - shares[shareholder].amount + amount;
        shares[shareholder].amount = amount;
        shares[shareholder].totalExcluded = getCumulativeDividends(
            shares[shareholder].amount
        );

        emit HolderShareChanged(
            shareholder,
            amount,
            shares[shareholder].totalExcluded
        );
    }

    function setRouter(address _router) external override onlyToken {
        router = IDEXRouter(_router);
        emit RouterChanged(_router);
    }

    function deposit() external payable override onlyToken {
        uint256 balanceBefore = RewardToken.balanceOf(address(this));

        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = address(RewardToken);

        if (rewardTokenHasTxFee) {
            router.swapExactETHForTokensSupportingFeeOnTransferTokens{
                value: msg.value
            }(0, path, address(this), block.timestamp);
        } else {
            router.swapExactETHForTokens{value: msg.value}(
                0,
                path,
                address(this),
                block.timestamp
            );
        }

        uint256 amount = RewardToken.balanceOf(address(this)) - balanceBefore;
        totalDividends = totalDividends + amount;
        dividendsPerShare =
            dividendsPerShare +
            ((dividendsPerShareAccuracyFactor * amount) / totalShares);

        emit Deposited(
            address(RewardToken),
            amount,
            totalDividends,
            dividendsPerShare
        );
    }

    function process(uint256 gas) external override onlyToken nonReentrant {
        uint256 shareholderCount = shareholders.length;

        if (shareholderCount == 0) {
            return;
        }

        uint256 iterations = 0;
        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentIndex >= shareholderCount) {
                currentIndex = 0;
            }

            if (shouldDistribute(shareholders[currentIndex])) {
                distributeDividend(shareholders[currentIndex]);
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }

        emit Processed(gasUsed, gasLeft, currentIndex, iterations);
    }

    function shouldDistribute(address shareholder)
        internal
        view
        returns (bool)
    {
        return
            shareholderClaims[shareholder] + minPeriod < block.timestamp &&
            getUnpaidEarnings(shareholder) > minDistribution;
    }

    function distributeDividend(address shareholder) internal {
        if (shares[shareholder].amount == 0) {
            return;
        }

        uint256 amount = getUnpaidEarnings(shareholder);
        if (amount > 0) {
            totalDistributed = totalDistributed + amount;
            RewardToken.transfer(shareholder, amount);
            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised =
                shares[shareholder].totalRealised +
                amount;
            shares[shareholder].totalExcluded = getCumulativeDividends(
                shares[shareholder].amount
            );
        }
    }

    function claimDividend() external nonReentrant {
        require(shouldDistribute(msg.sender), "Too soon. Need to wait!");
        distributeDividend(msg.sender);
    }

    function getUnpaidEarnings(address shareholder)
        public
        view
        returns (uint256)
    {
        if (shares[shareholder].amount == 0) {
            return 0;
        }

        uint256 shareholderTotalDividends = getCumulativeDividends(
            shares[shareholder].amount
        );
        uint256 shareholderTotalExcluded = shares[shareholder].totalExcluded;

        if (shareholderTotalDividends <= shareholderTotalExcluded) {
            return 0;
        }

        return shareholderTotalDividends - shareholderTotalExcluded;
    }

    function getCumulativeDividends(uint256 share)
        internal
        view
        returns (uint256)
    {
        return (share * dividendsPerShare) / dividendsPerShareAccuracyFactor;
    }

    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }

    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[
            shareholders.length - 1
        ];
        shareholderIndexes[
            shareholders[shareholders.length - 1]
        ] = shareholderIndexes[shareholder];
        shareholders.pop();
    }

    function getShareHolders() public view returns (address[] memory) {
        address[] memory _shareHolders = new address[](shareholders.length);
        for (uint256 i = 0; i < shareholders.length; i++) {
            _shareHolders[i] = shareholders[i];
        }
        return _shareHolders;
    }

    function getDistributorState()
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        return (
            currentIndex,
            totalShares,
            totalDividends,
            totalDistributed,
            dividendsPerShare
        );
    }

    function migrateDistributorStates(
        address[] memory _shareHolders,
        uint256[] memory _shareholderIndexes,
        uint256[] memory _shareholderClaims,
        uint256[] memory _amounts,
        uint256[] memory _totalExcludes,
        uint256[] memory _totalRealises,
        uint256 _currentIndex,
        uint256 _totalShares,
        uint256 _totalDividends,
        uint256 _totalDistributed,
        uint256 _dividendsPerShare
    ) external override {}
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "../structs/Share.sol";

interface IDividendDistributor {
    function setDistributionCriteria(
        uint256 _minPeriod,
        uint256 _minDistribution
    ) external;

    function setShare(address shareholder, uint256 amount) external;

    function setRouter(address _router) external;

    function deposit() external payable;

    function process(uint256 gas) external;

    function migrateDistributorStates(
        address[] memory _shareHolders,
        uint256[] memory _shareholderIndexes,
        uint256[] memory _shareholderClaims,
        uint256[] memory _amounts,
        uint256[] memory _totalExcludes,
        uint256[] memory _totalRealises,
        uint256 _currentIndex,
        uint256 _totalShares,
        uint256 _totalDividends,
        uint256 _totalDistributed,
        uint256 _dividendsPerShare
    ) external;

    event DistributionCriteriaChanged(
        uint256 newMinPeriod,
        uint256 newMinDistribution
    );

    event HolderShareChanged(
        address indexed shareholder,
        uint256 amount,
        uint256 totalExcluded
    );

    event RewardTokenChanged(address indexed token, bool chargeTxFee);

    event Deposited(
        address rewardToken,
        uint256 amount,
        uint256 totalDividends,
        uint256 dividendsPerShare
    );

    event Processed(
        uint256 gasUsed,
        uint256 gasLeft,
        uint256 currentIndex,
        uint256 iterations
    );

    event RouterChanged(address _router);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

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
    )
        external
        returns (
            uint amountA,
            uint amountB,
            uint liquidity
        );

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    )
        external
        payable
        returns (
            uint amountToken,
            uint amountETH,
            uint liquidity
        );

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

    function swapExactETHForTokens(
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
pragma solidity ^0.8.15;

interface IBEP20 {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function getOwner() external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address _owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

abstract contract TokenGuard {
    address _token;

    constructor() {
        _token = msg.sender;
    }

    modifier onlyToken() {
        require(msg.sender == _token);
        _;
    }

    function getTokenOwner() external view returns (address) {
        return _token;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

struct Share {
    uint256 amount;
    uint256 totalExcluded;
    uint256 totalRealised;
}