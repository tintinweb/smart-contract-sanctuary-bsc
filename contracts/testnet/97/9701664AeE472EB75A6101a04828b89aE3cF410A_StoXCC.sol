// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {AccessControlEnumerable} from "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {Counters} from "@openzeppelin/contracts/utils/Counters.sol";
import "./pancake-swap/interfaces/IPancakeRouter02.sol";
import "./pancake-swap/interfaces/IPancakeERC20.sol";
import "./libraries/ECDSAOffsetRecovery.sol";

contract StoXCC is AccessControlEnumerable, ReentrancyGuard {
    using ECDSAOffsetRecovery for bytes32;
    using Counters for Counters.Counter;

    Counters.Counter internal usersIndex;
    uint256 public proposalIndex;

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
    bytes32 public constant OWNER_ROLE = keccak256("OWNER_ROLE");
    uint8 public constant SIGNATURE_LENGTH = 65;
    uint256 public immutable priceMultiplier;
    address public immutable router;
    uint256 public minimumQuorum;
    address public activeToken;
    bool public isTokenHalvingEnabled;
    address[] public ethToUsdPath;
    address[] public tokenToUsdPath;

    mapping(uint256 => User) internal users;
    mapping(address => uint256) public userToId;
    mapping(uint256 => uint256) public uplineOf;
    mapping(address => uint256) public ownersWeight;
    uint8[5] public line5Percents = [10, 4, 3, 2, 1]; // /20
    uint256[4] public line5Costs = [50, 200, 500, 1000];
    uint256 public totalWeight;

    event Payment(uint256 to, uint256 tokenAmount, uint256 busdAmount);
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

    constructor(
        uint256 _priceMultiplier,
        address[] memory _owners,
        uint128[] memory _weights,
        uint256 _minimumQuorum,
        address _router,
        address[] memory _ETHtoUSDPath
    ) {
        require(_priceMultiplier > 0, "Use 10^18 as common value.");
        priceMultiplier = _priceMultiplier;
        require(
            _router != address(0),
            "Empty address error."
        );
        router = _router;
        ethToUsdPath = _ETHtoUSDPath;
        uint256 length = _owners.length;
        uint256 newTotalWeight;
        require(
            length == _weights.length,
            "Owners and weights has different length."
        );
        for (uint256 i = 0; i < length; i++) {
            address newOwner = _owners[i];
            uint256 newWeight = _weights[i];
            require(
                newOwner != address(0) && newWeight > 0,
                "Owner or weight equals zero."
            );
            _grantRole(OWNER_ROLE, newOwner);
            ownersWeight[newOwner] = newWeight;
            newTotalWeight += newWeight;
        }
        totalWeight = newTotalWeight;
        require(_minimumQuorum > 0, "Min quorum should be greater than zero.");
        require(
            _minimumQuorum <= length,
            "Min quorum should be less than owners"
        );
        minimumQuorum = _minimumQuorum;
        usersIndex.increment(); // 1
        userToId[address(this)] = 1;
        User storage user1 = users[1];
        user1.addr = address(this);

        for (uint8 i = 0; i < 4; i++) {
            user1.line5[i].activeTo = type(uint256).max;
        }
        for (uint8 i = 0; i < 12; i++) {
            user1.m3[i].isActive = true;
            user1.m6[i].isActive = true;
        }
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
        uint256 etherCost = IPancakeRouter02(router).getAmountsIn(
            registerCost,
            ethToUsdPath
        )[0];
        require(msg.value >= etherCost, "Not enough ether.");
        if (isTokenHalvingEnabled) {
            address[] memory path = new address[](2);
            (path[0], path[1]) = (IPancakeRouter02(router).WETH(), activeToken);
            IPancakeRouter02(router).swapExactETHForTokens{
                value: (etherCost / 2)
            }(1, ethToUsdPath, address(this), block.timestamp);
        }

        emit UserRegistered(msg.sender, currentId, _refId);
        _buyLine5(currentId, 1, 0);
        _buyM3(currentId, 0);
        _buyM6(currentId, 0);
        _returnEther();
    }

    function _buyForETH(uint256 amountInBUSD) internal {
        // uint256 etherCost = IPancakeRouter02(router).getAmountsIn(
        //     amountInBUSD,
        //     ethToUsdPath
        // )[0];
        // require(msg.value >= etherCost, "Not enough ether.");

        if (isTokenHalvingEnabled) {
            address[] memory swapPath = new address[](2);
            swapPath[0] = ethToUsdPath[0];
            swapPath[1] = activeToken;
            uint256 tokencost;
            if (tokenToUsdPath[0] == tokenToUsdPath[1]) {
                tokencost = amountInBUSD / 2;
            } else {
                tokencost = IPancakeRouter02(router).getAmountsIn(
                    amountInBUSD / 2,
                    tokenToUsdPath
                )[0];
            }
            IPancakeRouter02(router).swapETHForExactTokens{
                value: msg.value
            }(tokencost, swapPath, address(this), block.timestamp);
        }
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
        _returnEther();
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

    receive() external payable {}

    fallback() external {}

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
        uint256 etherCost = IPancakeRouter02(router).getAmountsIn(
            amountInUsd,
            ethToUsdPath
        )[0];
        require(msg.value >= etherCost, "Not enough ether.");

        if (isTokenHalvingEnabled) {
            uint256 tokencost;
            if (tokenToUsdPath[0] == tokenToUsdPath[1]) {
                tokencost = amountInUsd / 2;
            } else {
                tokencost = IPancakeRouter02(router).getAmountsIn(
                    amountInUsd / 2,
                    tokenToUsdPath
                )[0];
            }
            address[] memory swapPath = new address[](2);
            swapPath[0] = IPancakeRouter02(router).WETH();
            swapPath[1] = activeToken;
            IPancakeRouter02(router).swapETHForExactTokens{
                value: etherCost / 2
            }(tokencost, swapPath, address(this), block.timestamp);
        }
        _buyM3(currentId, _level);
        _returnEther();
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
        _returnEther();
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

    function addOwner(
        address newOwner,
        uint256 weight,
        bytes memory _concatSignatures
    ) external onlyRole(OWNER_ROLE) {
        require(newOwner != address(0) && weight > 0, "Owner can't be empty.");
        bytes32 hash = keccak256(
            abi.encodePacked(proposalIndex, newOwner, weight)
        );
        _checkOwners(_concatSignatures, hash);
        _grantRole(OWNER_ROLE, newOwner);
        ownersWeight[newOwner] = weight;
        totalWeight += weight;
    }

    function changeOwnerWeight(
        address owner,
        uint256 weight,
        bytes memory _concatSignatures
    ) external onlyRole(OWNER_ROLE) {
        require(
            hasRole(OWNER_ROLE, owner),
            "Can't change weight of not owner."
        );
        require(weight > 0, "Weight can't be zero.");
        bytes32 hash = keccak256(
            abi.encodePacked(proposalIndex, owner, weight)
        );
        _checkOwners(_concatSignatures, hash);
        totalWeight -= ownersWeight[owner];
        ownersWeight[owner] = weight;
        totalWeight += weight;
    }

    function deleteOwner(bytes memory _concatSignatures, address oldOwner)
        external
        onlyRole(OWNER_ROLE)
    {
        uint256 ownersCount = getRoleMemberCount(OWNER_ROLE);
        require(
            ownersCount > 1,
            "You are the last owner. Transfer your ownership!"
        );
        require(
            minimumQuorum < ownersCount,
            "Minimum quorum can't be more than owners."
        );
        require(
            oldOwner != address(0) && hasRole(OWNER_ROLE, oldOwner),
            "0x0000 address can't be an owner."
        );
        bytes32 hash = keccak256(abi.encodePacked(proposalIndex, oldOwner));
        _checkOwners(_concatSignatures, hash);
        totalWeight -= ownersWeight[oldOwner];
        ownersWeight[oldOwner] = 0;
        _revokeRole(OWNER_ROLE, oldOwner);
    }

    function switchTokenHalving(
        bytes memory _concatSignatures,
        address _token,
        bool _enableStatus,
        address[] memory _tokenToUsdPath
    ) external onlyRole(OWNER_ROLE) {
        if (_enableStatus) {
            require(_token != address(0), "Token address is not specified.");
        }
        bytes32 hash = keccak256(
            abi.encodePacked(
                proposalIndex,
                _token,
                _enableStatus,
                _tokenToUsdPath
            )
        );
        _checkOwners(_concatSignatures, hash);
        activeToken = _token;
        isTokenHalvingEnabled = _enableStatus;
        tokenToUsdPath = _tokenToUsdPath;
    }

    function setMinimumQuorum(bytes memory _concatSignatures, uint256 quorum)
        external
        onlyRole(OWNER_ROLE)
    {
        require(quorum > 0, "Min quorum must be greater than zero.");
        require(
            minimumQuorum <= getRoleMemberCount(OWNER_ROLE),
            "Min quorum must be greater than owners count"
        );
        bytes32 hash = keccak256(abi.encodePacked(proposalIndex, quorum));
        _checkOwners(_concatSignatures, hash);
        minimumQuorum = quorum;
    }

    function _checkOwners(bytes memory _concatSignatures, bytes32 _hash)
        internal
    {
        uint256 signatureLength = SIGNATURE_LENGTH;
        uint256 concatLength = _concatSignatures.length;
        require(concatLength % signatureLength == 0, "Wrong signature length.");
        uint256 signaturesCount;
        assembly {
            // let signaturesCount
            signaturesCount := div(concatLength, signatureLength)
        }
        address[] memory ownersAddresses = new address[](signaturesCount);
        require(
            signaturesCount >= minimumQuorum,
            "Min quorum must be reached."
        );
        for (uint256 i; i < signaturesCount; i++) {
            address ownerAddress = _hash.ecOffsetRecover(
                _concatSignatures,
                i * signatureLength
            );
            require(
                hasRole(OWNER_ROLE, ownerAddress),
                "Signer is not an owner or signed invalid data."
            );

            for (uint256 j; j < i; j++) {
                require(
                    ownerAddress != ownersAddresses[j],
                    "Owner must not be duplicated."
                );
            }
            ownersAddresses[i] = ownerAddress;
        }
        proposalIndex++;
    }

    function _payToId(uint256 usdAmount, uint256 to) internal {
        if (isTokenHalvingEnabled) {
            emit Payment(to, usdAmount / 2, usdAmount / 2);
        } else {
            emit Payment(to, 0, usdAmount);
        }
        if (to == 1) {
            uint256 ownersCount = getRoleMemberCount(OWNER_ROLE);
            uint256 currentTotalWeight = totalWeight;
            for (uint256 i = 0; i < ownersCount; i++) {
                address owner = getRoleMember(OWNER_ROLE, i);
                _payToAddr(
                    ((usdAmount * ownersWeight[owner]) / currentTotalWeight),
                    owner
                );
            }
        } else {
            _payToAddr(usdAmount, users[to].addr);
        }
    }

    function _payToAddr(uint256 usdAmount, address to) internal {
        if (isTokenHalvingEnabled) {
            usdAmount = usdAmount / 2;
            uint256 amountsInToken = IPancakeRouter02(router).getAmountsIn(
                usdAmount,
                tokenToUsdPath
            )[0];
            IPancakeERC20(activeToken).transfer(to, amountsInToken);
        }
        uint256 amountInEther = IPancakeRouter02(router).getAmountsIn(
            usdAmount,
            ethToUsdPath
        )[0];
        (bool success, ) = to.call{value: (amountInEther)}("");
        require(success, "Payment failed.");
    }

    function _returnEther() internal {
        if (address(this).balance > 0) {
            (bool success, ) = payable(msg.sender).call{
                value: address(this).balance
            }("");
            require(success, "Return payment failed.");
        }
    }
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
// OpenZeppelin Contracts (last updated v4.5.0) (access/AccessControlEnumerable.sol)

pragma solidity ^0.8.0;

import "./IAccessControlEnumerable.sol";
import "./AccessControl.sol";
import "../utils/structs/EnumerableSet.sol";

/**
 * @dev Extension of {AccessControl} that allows enumerating the members of each role.
 */
abstract contract AccessControlEnumerable is IAccessControlEnumerable, AccessControl {
    using EnumerableSet for EnumerableSet.AddressSet;

    mapping(bytes32 => EnumerableSet.AddressSet) private _roleMembers;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlEnumerable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns one of the accounts that have `role`. `index` must be a
     * value between 0 and {getRoleMemberCount}, non-inclusive.
     *
     * Role bearers are not sorted in any particular way, and their ordering may
     * change at any point.
     *
     * WARNING: When using {getRoleMember} and {getRoleMemberCount}, make sure
     * you perform all queries on the same block. See the following
     * https://forum.openzeppelin.com/t/iterating-over-elements-on-enumerableset-in-openzeppelin-contracts/2296[forum post]
     * for more information.
     */
    function getRoleMember(bytes32 role, uint256 index) public view virtual override returns (address) {
        return _roleMembers[role].at(index);
    }

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function getRoleMemberCount(bytes32 role) public view virtual override returns (uint256) {
        return _roleMembers[role].length();
    }

    /**
     * @dev Overload {_grantRole} to track enumerable memberships
     */
    function _grantRole(bytes32 role, address account) internal virtual override {
        super._grantRole(role, account);
        _roleMembers[role].add(account);
    }

    /**
     * @dev Overload {_revokeRole} to track enumerable memberships
     */
    function _revokeRole(bytes32 role, address account) internal virtual override {
        super._revokeRole(role, account);
        _roleMembers[role].remove(account);
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

pragma solidity ^0.8.4;

library ECDSAOffsetRecovery 
{
    // function addSignature(bytes memory _currentSig, address _token) public pure returns(bytes memory concatenated){
    //     bytes32 newHash = keccak256(abi.encodePacked(_token));
    //     return abi.encodePacked(_currentSig,newHash);
    // }
    function toEthSignedMessageHash(bytes32 hash) public pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV
    }

    function ecOffsetRecover(bytes32 hash, bytes memory signature, uint256 offset)
        public
        pure
        returns (address)
    {
        bytes32 r;
        bytes32 s;
        uint8 v;

        // Divide the signature in r, s and v variables with inline assembly.
        assembly {
            r := mload(add(signature, add(offset, 0x20)))
            s := mload(add(signature, add(offset, 0x40)))
            v := byte(0, mload(add(signature, add(offset, 0x60))))
        }

        // Version of signature should be 27 or 28, but 0 and 1 are also possible versions
        if (v < 27) {
            v += 27;
        }

        // If the version is correct return the signer address
        if (v != 27 && v != 28) {
            return (address(0));
        }

        // bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        // hash = keccak256(abi.encodePacked(prefix, hash));
        // solium-disable-next-line arg-overflow
        return ecrecover(toEthSignedMessageHash(hash), v, r, s);
    }
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
// OpenZeppelin Contracts v4.4.1 (access/IAccessControlEnumerable.sol)

pragma solidity ^0.8.0;

import "./IAccessControl.sol";

/**
 * @dev External interface of AccessControlEnumerable declared to support ERC165 detection.
 */
interface IAccessControlEnumerable is IAccessControl {
    /**
     * @dev Returns one of the accounts that have `role`. `index` must be a
     * value between 0 and {getRoleMemberCount}, non-inclusive.
     *
     * Role bearers are not sorted in any particular way, and their ordering may
     * change at any point.
     *
     * WARNING: When using {getRoleMember} and {getRoleMemberCount}, make sure
     * you perform all queries on the same block. See the following
     * https://forum.openzeppelin.com/t/iterating-over-elements-on-enumerableset-in-openzeppelin-contracts/2296[forum post]
     * for more information.
     */
    function getRoleMember(bytes32 role, uint256 index) external view returns (address);

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function getRoleMemberCount(bytes32 role) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/AccessControl.sol)

pragma solidity ^0.8.0;

import "./IAccessControl.sol";
import "../utils/Context.sol";
import "../utils/Strings.sol";
import "../utils/introspection/ERC165.sol";

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     *
     * _Available since v4.1._
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role);
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `_msgSender()` is missing `role`.
     * Overriding this function changes the behavior of the {onlyRole} modifier.
     *
     * Format of the revert message is described in {_checkRole}.
     *
     * _Available since v4.6._
     */
    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, _msgSender());
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     *
     * May emit a {RoleGranted} event.
     */
    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     *
     * May emit a {RoleRevoked} event.
     */
    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been revoked `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     *
     * May emit a {RoleRevoked} event.
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * May emit a {RoleGranted} event.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     *
     * NOTE: This function is deprecated in favor of {_grantRole}.
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleGranted} event.
     */
    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleRevoked} event.
     */
    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/structs/EnumerableSet.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 *
 * [WARNING]
 * ====
 *  Trying to delete such a structure from storage will likely result in data corruption, rendering the structure unusable.
 *  See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
 *
 *  In order to clean an EnumerableSet, you can either remove all elements one by one or create a fresh instance using an array of EnumerableSet.
 * ====
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastValue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastValue;
                // Update the index for the moved value
                set._indexes[lastValue] = valueIndex; // Replace lastValue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        return _values(set._inner);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
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