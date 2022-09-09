// SPDX-License-Identifier: MIT
pragma solidity =0.8.15;

import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {Counters} from "@openzeppelin/contracts/utils/Counters.sol";
import "./interfaces/IStoXCC.sol";
import "./pancake-swap/interfaces/IPancakeRouter02.sol";
import "./pancake-swap/interfaces/IPancakeERC20.sol";

contract StoXCC is ReentrancyGuard, IStoXCC {
    using Counters for Counters.Counter;

    Counters.Counter internal usersIndex;

    struct User {
        address addr;
        L5[4] line5;
        M3[12] m3;
        M6[12] m6;
    }
    struct L5 {
        uint256[] referalsList;
        uint256 activeTo;
    }
    struct M3 {
        uint256[] referalsList;
        bool isActive;
        bool wasUpgraded;
        uint256 reinvestCount;
    }
    struct M6 {
        uint256[] referalsList;
        bool isActive;
        bool wasUpgraded;
        uint256 reinvestCount;
    }

    uint256 public immutable priceMultiplier;
    address public immutable router;
    address public activeToken;
    bool public isTokenHalvingEnabled;
    address[] public ethToUsdPath;
    address[] public tokenToUsdPath;
    uint8[5] public line5Percents = [10, 4, 3, 2, 1];
    uint256[4] public line5Costs = [50, 200, 500, 1000];

    mapping(uint256 => User) internal users;
    mapping(address => uint256) public userToId;
    mapping(uint256 => uint256) public uplineOf;

    event Payment(uint256 to, uint256 tokenUsdAmount, uint256 busdAmount);
    event UserRegistered(
        address indexed user,
        uint256 indexed userId,
        uint256 indexed refererId
    );
    event Line5BuyLevel(
        uint256 indexed userId,
        uint256 indexed level,
        uint256 months
    );
    event Line5MissedPayment(
        uint256 indexed userId,
        uint256 indexed seller,
        uint128 level,
        uint128 payedLevel
    );
    event MatrixMissedPayment(
        uint256 indexed userId,
        uint256 indexed seller,
        uint8 matrix,
        uint8 level
    );
    event Line5Payment(
        uint256 indexed userId,
        uint256 indexed seller,
        uint128 level,
        uint128 payedLevel
    );
    event MatrixBuyLevel(
        uint256 indexed userId,
        uint256 indexed seller,
        uint8 matrix,
        uint8 level
    );
    event MatrixReinvest(uint256 indexed user, uint8 matrix, uint8 level);
    event MatrixUpgrade(uint256 indexed user, uint8 matrix, uint8 level);
    event MissedMatrixUpgrade(
        uint256 indexed userId,
        uint8 matrix,
        uint8 level
    );
    event MissedEthReceive(
        address indexed receiver,
        address indexed from,
        uint8 matrix,
        uint8 level
    );

    modifier onlyRegistered() {
        require(userToId[msg.sender] > 0, "You are not registered yet.");
        _;
    }
    modifier onlyId1() {
        require(userToId[msg.sender] == 1, "You are not id1.");
        _;
    }

    constructor(
        uint256 _priceMultiplier,
        address[] memory _owners,
        uint256[] memory _ownersWeight,
        uint256 _minimumQuorum,
        address _router,
        address[] memory _ETHtoUSDPath
    ) {
        // address id1 = address(
        //     new StoX1(_owners, _ownersWeight, _minimumQuorum)
        // );
        address id1 = msg.sender;
        require(_priceMultiplier > 0, "Use 10^18 as common value.");
        priceMultiplier = _priceMultiplier;
        require(
            _router != address(0) && id1 != address(0),
            "Empty address error."
        );
        router = _router;
        ethToUsdPath = _ETHtoUSDPath;
        usersIndex.increment();
        userToId[id1] = 1;
        User storage user1 = users[1];
        user1.addr = id1;

        for (uint8 i = 0; i < 4; i++) {
            user1.line5[i].activeTo = type(uint256).max;
        }
        for (uint8 i = 0; i < 12; i++) {
            user1.m3[i].isActive = true;
            user1.m6[i].isActive = true;
        }
    }

    function transferId1To(address id1) onlyId1 external{
        userToId[msg.sender] = 0;
        userToId[id1] = 1;
        users[1].addr = id1;
    }

    function getUsersCount() external view returns (uint256 usersCount) {
        return usersIndex.current();
    }

    function getUserData(uint256 userId)
        external
        view
        returns (User memory userData)
    {
        return users[userId];
    }

    function register(uint256 _refId) external payable nonReentrant {
        require(userToId[msg.sender] == 0, "You are already registered.");
        require(
            _refId <= usersIndex.current() && _refId > 0,
            "Wrong upline id."
        );
        usersIndex.increment();
        uint256 currentId = usersIndex.current();
        userToId[msg.sender] = currentId;
        uplineOf[currentId] = _refId;
        users[currentId].addr = msg.sender;
        uint256 registerCost = 70 * priceMultiplier;
        _buyForETH(registerCost);

        emit UserRegistered(msg.sender, currentId, _refId);
        _buyLine5(currentId, 1, 0);
        _buyM3(currentId, 0);
        _buyM6(currentId, 0);
        _returnLeft();
    }

    function buyM3(uint8 _level) external payable onlyRegistered nonReentrant {
        uint256 currentId = userToId[msg.sender];
        require(
            _level < 12,
            "Level must be lower than 12 (11 for last level)."
        );
        require(
            users[currentId].m3[_level].isActive == false,
            "M3 level is already active."
        );
        require(
            users[currentId].m3[_level - 1].isActive,
            "You must activate previous m3 level."
        );
        uint256 amountInUsd = 10 * (2**_level) * priceMultiplier;
        _buyForETH(amountInUsd);
        _buyM3(currentId, _level);
        _returnLeft();
    }

    function buyM6(uint8 _level) external payable onlyRegistered nonReentrant {
        uint256 currentId = userToId[msg.sender];
        require(
            _level < 12,
            "Level must be lower than 12 (11 for last level)."
        );
        require(
            users[currentId].m6[_level].isActive == false,
            "M6 level is already active."
        );
        require(
            users[currentId].m6[_level - 1].isActive,
            "You must activate previous M6 level."
        );
        uint256 amountInUsd = 10 * (2**_level) * priceMultiplier;
        _buyForETH(amountInUsd);
        _buyM6(currentId, _level);
        _returnLeft();
    }

    function buyLine5(uint8 _level, uint256 _months)
        external
        payable
        onlyRegistered
        nonReentrant
    {
        require(_level < 4, "Maximum level is 3 (4th level).");
        require(_months > 0, "Specify Line5 duration.");
        uint256 amountInUsd = (_months * line5Costs[_level] * priceMultiplier);
        _buyForETH(amountInUsd);
        _buyLine5(userToId[msg.sender], _months, _level);
        _returnLeft();
    }

    function _buyLine5(
        uint256 currentId,
        uint256 _months,
        uint8 _level
    ) internal {
        L5 storage mainL5 = users[currentId].line5[_level];
        if (mainL5.activeTo > block.timestamp) {
            mainL5.activeTo += _months * 30 days;
        } else {
            mainL5.activeTo = block.timestamp + (_months * 30 days);
        }
        uint256 referer = uplineOf[currentId];
        L5 storage refererL5 = users[referer].line5[_level];
        refererL5.referalsList.push(currentId);
        uint256 cost = _months * line5Costs[_level] * priceMultiplier;
        _payLine5(currentId, currentId, _level, 0, 0, cost);
        emit Line5BuyLevel(currentId, _level, _months);
    }

    function _buyM3(uint256 currentId, uint8 _level) internal {
        users[currentId].m3[_level].isActive = true;
        uint256 payableAmount = 10 * (2**_level) * priceMultiplier;
        uint256 seller = _getM3PaymentReciever(currentId, _level);
        _payToId(payableAmount, seller);
        emit MatrixBuyLevel(currentId, seller, 3, _level);
    }

    function _buyM6(uint256 currentId, uint8 _level) internal {
        users[currentId].m6[_level].isActive = true;
        uint256 payableAmount = 10 * (2**_level) * priceMultiplier;
        uint256 seller = _getM6PaymentReceiver(currentId, _level);
        _payToId(payableAmount, seller);
        emit MatrixBuyLevel(currentId, seller, 6, _level);
    }

    function _getM3PaymentReciever(uint256 currentId, uint8 _level)
        internal
        returns (uint256)
    {
        _addToM3(currentId, _level);
        uint256 seller = uplineOf[currentId];
        while (!users[seller].m3[_level].isActive) {
            emit MatrixMissedPayment(currentId, seller, 3, _level);
            seller = uplineOf[seller];
        }
        if (
            seller == uplineOf[currentId] &&
            seller > 1 &&
            users[seller].m3[_level].referalsList.length == 0
        ) {
            seller = uplineOf[seller];

            while (!users[seller].m3[_level].isActive) {
                emit MatrixMissedPayment(currentId, seller, 3, _level);
                seller = uplineOf[seller];
            }
        }
        return seller;
    }

    function _getM6PaymentReceiver(uint256 currentId, uint8 _level)
        internal
        returns (uint256)
    {
        _addToM6(currentId, _level);
        uint256 seller = uplineOf[currentId];
        uint256 length = users[seller].m6[_level].referalsList.length;
        if (length < 3) {
            seller = uplineOf[currentId];
            while (!users[seller].m6[_level].isActive) {
                emit MatrixMissedPayment(currentId, seller, 6, _level);
                seller = uplineOf[seller];
            }
        }
        return seller;
    }

    function _addToM3(uint256 currentId, uint8 _level) internal {
        uint256 upline = uplineOf[currentId];
        M3 storage uplineM3 = users[upline].m3[_level];
        if (uplineM3.referalsList.length == 2) {
            if (_level < 11) {
                M3 storage nextLevelM3 = users[upline].m3[_level + 1];
                if (
                    !(uplineM3.wasUpgraded && nextLevelM3.isActive) &&
                    uplineM3.isActive &&
                    _level < 11
                ) {
                    uplineM3.wasUpgraded = true;
                    nextLevelM3.isActive = true;
                    _addToM3(upline, _level + 1);
                    emit MatrixUpgrade(upline, 3, _level);
                } else {
                    if (!(uplineM3.wasUpgraded || nextLevelM3.isActive)) {
                        emit MissedMatrixUpgrade(upline, 3, _level);
                    }
                }
            }
            emit MatrixReinvest(upline, 3, _level);
            uplineM3.reinvestCount++;
            delete uplineM3.referalsList;
        } else {
            uplineM3.referalsList.push(currentId);
        }
    }

    function _addToM6(uint256 currentId, uint8 _level) internal {
        uint256 upline = uplineOf[currentId];
        M6 storage uplineM6 = users[upline].m6[_level];
        if (uplineM6.referalsList.length == 5) {
            if (_level < 11) {
                M6 storage nextLevelM6 = users[upline].m6[_level + 1];
                if (
                    !uplineM6.wasUpgraded &&
                    !nextLevelM6.isActive &&
                    uplineM6.isActive
                ) {
                    uplineM6.wasUpgraded = true;
                    nextLevelM6.isActive = true;
                    emit MatrixUpgrade(upline, 6, _level);
                    _addToM3(upline, _level + 1);
                } else {
                    if (!(uplineM6.wasUpgraded || nextLevelM6.isActive)) {
                        emit MissedMatrixUpgrade(upline, 6, _level);
                    }
                }
            }
            emit MatrixReinvest(upline, 6, _level);
            uplineM6.reinvestCount++;
            delete uplineM6.referalsList;
        } else {
            uplineM6.referalsList.push(currentId);
        }
    }

    function _payLine5(
        uint256 initialId,
        uint256 currentId,
        uint8 _level,
        uint128 currentDeep,
        uint8 payedLevels,
        uint256 cost
    ) internal {
        uint256 refererId = uplineOf[currentId];
        if (refererId < 2) {
            uint256 cummulativeCost;
            for (uint8 i = payedLevels; i < 5; i++) {
                cummulativeCost += (line5Percents[i] * cost) / 20;
                emit Line5Payment(initialId, 1, _level, i);
            }
            if (cummulativeCost > 0) {
                return _payToId(cummulativeCost, 1);
            }
        } else {
            L5 memory referer = users[refererId].line5[_level];
            if (referer.activeTo >= block.timestamp) {
                uint256 referalsOfRefferer = referer.referalsList.length;
                uint256 requiredReferalsAmount = payedLevels + 1;
                uint8 currentActivatedReferals;
                for (
                    uint256 i = 0;
                    i < referalsOfRefferer && currentActivatedReferals < 5;
                    i++
                ) {
                    uint256 id = referer.referalsList[i];
                    if (users[id].line5[_level].activeTo >= block.timestamp) {
                        currentActivatedReferals++;
                    }
                }
                if ((currentActivatedReferals >= requiredReferalsAmount)) {
                    uint256 cummulativeCost;
                    for (
                        uint8 i = payedLevels;
                        i <= currentDeep && i < 5;
                        i++
                    ) {
                        if (currentActivatedReferals > i) {
                            cummulativeCost += (line5Percents[i] * cost) / 20;
                            payedLevels++;
                            emit Line5Payment(initialId, refererId, _level, i);
                        }
                    }
                    _payToId(cummulativeCost, refererId);
                    if (payedLevels < 5) {
                        return
                            _payLine5(
                                initialId,
                                refererId,
                                _level,
                                currentDeep + 1,
                                payedLevels,
                                cost
                            );
                    }
                }
            }
            emit Line5MissedPayment(initialId, refererId, _level, payedLevels);
            return
                _payLine5(
                    initialId,
                    refererId,
                    _level,
                    currentDeep + 1,
                    payedLevels,
                    cost
                );
        }
    }

    function _buyForETH(uint256 amountInBUSD) internal {
        address [] memory temp = new address[](2);
        temp[0] = ethToUsdPath[1];
        temp[1] = ethToUsdPath[0];
        uint256 etherCost3 = IPancakeRouter02(router).getAmountsIn(
            amountInBUSD,
            ethToUsdPath
        )[0];
        require(msg.value >= etherCost3, "Not enough ether!!!.");
        if (isTokenHalvingEnabled) {
            uint256 tokenAmount = 0;
            if (tokenToUsdPath[0] == tokenToUsdPath[1]) {
                tokenAmount = amountInBUSD / 2;
            } else {
                tokenAmount = IPancakeRouter02(router).getAmountsIn(
                    amountInBUSD / 2,
                    tokenToUsdPath
                )[0];
            }
            address[] memory swapPath = new address[](2);
            swapPath[0] = ethToUsdPath[0];
            swapPath[1] = activeToken;

            IPancakeRouter02(router).swapExactETHForTokens{
                value: msg.value / 2
            }(tokenAmount, swapPath, address(this), block.timestamp);

            uint256 etherCost = IPancakeRouter02(router).getAmountsOut(
                address(this).balance,
                ethToUsdPath
            )[0];
            require(amountInBUSD/2 >= etherCost, "Not enough ether.");

        } else{
            uint256 etherCost = IPancakeRouter02(router).getAmountsOut(
                msg.value,
                ethToUsdPath
            )[0];
            require(amountInBUSD >= etherCost, "Not enough ether.");
        }
    }

    function _payToId(uint256 usdAmount, uint256 to) internal {
        if (isTokenHalvingEnabled) {
            emit Payment(to, usdAmount / 2, usdAmount / 2);
        } else {
            emit Payment(to, 0, usdAmount);
        }

        _payToAddr(usdAmount, users[to].addr);
    }

    function _payToAddr(uint256 usdAmount, address to) internal {
        if (isTokenHalvingEnabled) {
            usdAmount = usdAmount / 2;
            uint256 amountsInToken;
            if (tokenToUsdPath[0] == tokenToUsdPath[1]) {
                amountsInToken = usdAmount;
            } else {
                amountsInToken = IPancakeRouter02(router).getAmountsIn(
                    usdAmount,
                    tokenToUsdPath
                )[0];
            }
            IPancakeERC20(activeToken).transfer(to, amountsInToken);
        }
        uint256 amountInEther = IPancakeRouter02(router).getAmountsIn(
            usdAmount,
            ethToUsdPath
        )[0];
        (bool success, ) = to.call{value: (amountInEther)}("");
        require(success, "Payment failed.");
    }

    function _returnLeft() internal {
        if (address(this).balance > 0) {
            (bool success, ) = payable(msg.sender).call{
                value: address(this).balance
            }("");
            require(success, "Return payment failed.");
        }
        if (isTokenHalvingEnabled) {
            uint256 tokenBalance = IPancakeERC20(activeToken).balanceOf(
                address(this)
            );
            if (tokenBalance > 0) {
                IPancakeERC20(activeToken).transfer(msg.sender, tokenBalance);
            }
        }
    }

    function switchTokenHalving(
        address _token,
        bool _enableStatus,
        address[] memory _tokenToUsdPath
    ) external onlyId1 {
        isTokenHalvingEnabled = !isTokenHalvingEnabled;
        activeToken = _token;
        isTokenHalvingEnabled = _enableStatus;
        tokenToUsdPath = _tokenToUsdPath;
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
// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IStoXCC{
    function switchTokenHalving(
        address token,
        bool enableStatus,
        address [] memory tokenToUsdPath
    ) external;
    function isTokenHalvingEnabled() external returns (bool);
    function activeToken() external returns (address);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IPancakeRouter01.sol";

interface IPancakeRouter02 is IPancakeRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
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
    ) external returns (uint256 amountETH);

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

interface IPancakeERC20 {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IPancakeRouter01 {
    function factory() external view returns (address);

    function WETH() external view returns (address);

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