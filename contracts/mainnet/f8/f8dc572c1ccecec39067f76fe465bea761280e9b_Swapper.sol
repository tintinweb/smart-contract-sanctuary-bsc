// SPDX-License-Identifier: BSD-3-Clause

pragma solidity ^0.8.0;

import "./PaymentSplitterUpgradeable.sol";
import "./OwnersUpgradeable.sol";
import "./external/IPancakeRouter02.sol";

contract Swapper is PaymentSplitterUpgradeable, OwnersUpgradeable {
    struct Path {
        address[] pathIn;
        address[] pathOut;
    }

    struct MapPath {
        address[] keys;
        mapping(address => Path) values;
        mapping(address => uint256) indexOf;
        mapping(address => bool) inserted;
    }

    struct Sponso {
        address to;
        uint256 rate;
        uint256 until;
        uint256 released;
        uint256 claimable;
        address[] path;
        uint256 discountRate;
    }

    MapPath private mapPath;

    string[] public allInflus;
    mapping(string => bool) public influInserted;
    mapping(string => Sponso) public influData;

    address public spring;
    address public futur;
    address public distri;
    address public lpHandler;
    address public router;
    address public base;
    address public payeeAddress;

    uint256 public futurFee;
    uint256 public rewardsFee;
    uint256 public lpFee;

    bool private swapping;
    bool private swapLiquifyCreate;
    bool private swapLiquifyClaim;
    bool private swapFutur;
    bool private swapRewards;
    bool private swapLpPool;
    bool private swapPayee;

    uint256 public swapTokensAmountCreate;
    uint256 public swapTokensAmountClaim;

    address public handler;

    bool public openSwapCreateLuckyBoxesWithTokens;
    bool public openSwapClaimRewardsAll;
    bool public openSwapClaimRewardsBatch;
    bool public openSwapClaimRewardsNodeType;
    bool public openSwapApplyWaterpack;
    bool public openSwapApplyFertilizer;
    bool public openSwapNewPlot;

    function initialize(
        address[] memory payees,
        uint256[] memory shares,
        address[] memory addresses,
        uint256[] memory fees,
        uint256[] memory _swAmounts,
        address _handler
    ) external initializer {
        __Swapper_init(payees, shares, addresses, fees, _swAmounts, _handler);
    }

    function __Swapper_init(
        address[] memory payees,
        uint256[] memory shares,
        address[] memory addresses,
        uint256[] memory fees,
        uint256[] memory _swAmounts,
        address _handler
    ) internal onlyInitializing {
        __Owners_init_unchained();
        __PaymentSplitter_init_unchained(payees, shares);
        __Swapper_init_unchained(addresses, fees, _swAmounts, _handler);
    }

    function __Swapper_init_unchained(
        address[] memory addresses,
        uint256[] memory fees,
        uint256[] memory _swAmounts,
        address _handler
    ) internal onlyInitializing {
        spring = addresses[0];
        futur = addresses[1];
        distri = addresses[2];
        lpHandler = addresses[3];
        router = addresses[4];
        base = addresses[5];

        futurFee = fees[0];
        rewardsFee = fees[1];
        lpFee = fees[2];

        swapTokensAmountCreate = _swAmounts[0];
        swapTokensAmountClaim = _swAmounts[1];

        handler = _handler;

        swapping = false;
        swapLiquifyCreate = true;
        swapLiquifyClaim = true;
        swapFutur = true;
        swapRewards = true;
        swapLpPool = true;
        swapPayee = true;

        openSwapCreateLuckyBoxesWithTokens = false;
        openSwapClaimRewardsAll = false;
        openSwapClaimRewardsBatch = false;
        openSwapClaimRewardsNodeType = false;
        openSwapApplyWaterpack = false;
        openSwapApplyFertilizer = false;
        openSwapNewPlot = false;
    }

    modifier onlyHandler() {
        require(msg.sender == handler, "Swapper: Only Handler");
        _;
    }

    function addMapPath(
        address token,
        address[] memory pathIn,
        address[] memory pathOut
    ) external onlyOwners {
        require(!mapPath.inserted[token], "Swapper: Token already exists");
        mapPathSet(token, Path({pathIn: pathIn, pathOut: pathOut}));
    }

    function updateMapPath(
        address token,
        address[] memory pathIn,
        address[] memory pathOut
    ) external onlyOwners {
        require(mapPath.inserted[token], "Swapper: Token doesnt exist");
        mapPathSet(token, Path({pathIn: pathIn, pathOut: pathOut}));
    }

    function removeMapPath(address token) external onlyOwners {
        require(mapPath.inserted[token], "Swapper: Token doesnt exist");
        mapPathRemove(token);
    }

    function addInflu(
        string memory name,
        address to,
        uint256 until,
        uint256 rate,
        address[] memory path,
        uint256 discountRate
    ) external onlyOwners {
        require(!influInserted[name], "Swapper: Influ already exists");

        allInflus.push(name);
        influInserted[name] = true;

        influData[name] = Sponso({
            to: to,
            rate: rate,
            until: until,
            released: 0,
            claimable: 0,
            path: path,
            discountRate: discountRate
        });
    }

    // function updateInflu(
    //     string memory name,
    //     uint256 until,
    //     uint256 rate,
    //     address[] memory path,
    //     uint256 discountRate
    // ) external onlyOwners {
    //     require(influInserted[name], "Swapper: Influ doesnt exist exists");

    //     Sponso memory cur = influData[name];

    //     influData[name] = Sponso({
    //         to: cur.to,
    //         rate: rate,
    //         until: until,
    //         released: cur.released,
    //         claimable: cur.claimable,
    //         path: path,
    //         discountRate: discountRate
    //     });
    // }

    // function releaseInflu(string memory name) external {
    //     require(influInserted[name], "Swapper: Influ doesnt exist exists");

    //     Sponso storage cur = influData[name];

    //     require(cur.claimable > 0, "Swapper: Nothing to claim");

    //     uint256 amount;
    //     if (cur.path[cur.path.length - 1] != spring)
    //         amount = IPancakeRouter02(router).getAmountsOut(
    //             cur.claimable,
    //             cur.path
    //         )[cur.path.length - 1];
    //     else amount = cur.claimable;

    //     cur.released += cur.claimable;
    //     cur.claimable = 0;

    //     IERC20(cur.path[cur.path.length - 1]).transferFrom(
    //         futur,
    //         cur.to,
    //         amount
    //     );
    // }

    function getClaimableAmountInTokens(string calldata name)
        public
        view
        returns (uint256 amount, address tokenOut)
    {
        require(influInserted[name], "Swapper: Influ doesnt exist exists");
        Sponso storage cur = influData[name];

        tokenOut = cur.path[cur.path.length - 1];
        amount = IPancakeRouter02(router).getAmountsOut(
            cur.claimable,
            cur.path
        )[cur.path.length - 1];
    }

    function swapCreateLuckyBoxesWithTokens(
        address tokenIn,
        address user,
        uint256 price,
        string memory sponso
    ) external onlyHandler {
        require(openSwapCreateLuckyBoxesWithTokens, "Swapper: Not open");
        _swapCreation(tokenIn, user, price, sponso);
    }

    function swapClaimRewardsAll(
        address tokenOut,
        address user,
        uint256 rewardsTotal,
        uint256 feesTotal
    ) external onlyHandler {
        require(openSwapClaimRewardsAll, "Swapper: Not open");
        _swapClaim(tokenOut, user, rewardsTotal, feesTotal);
    }

    function swapClaimRewardsBatch(
        address tokenOut,
        address user,
        uint256 rewardsTotal,
        uint256 feesTotal
    ) external onlyHandler {
        require(openSwapClaimRewardsBatch, "Swapper: Not open");
        _swapClaim(tokenOut, user, rewardsTotal, feesTotal);
    }

    function swapClaimRewardsNodeType(
        address tokenOut,
        address user,
        uint256 rewardsTotal,
        uint256 feesTotal
    ) external onlyHandler {
        require(openSwapClaimRewardsNodeType, "Swapper: Not open");
        _swapClaim(tokenOut, user, rewardsTotal, feesTotal);
    }

    function swapApplyWaterpack(
        address tokenIn,
        address user,
        uint256 amount,
        string memory sponso
    ) external onlyHandler {
        require(openSwapApplyWaterpack, "Swapper: Not open");
        _swapCreation(tokenIn, user, amount, sponso);
    }

    function swapApplyFertilizer(
        address tokenIn,
        address user,
        uint256 amount,
        string memory sponso
    ) external onlyHandler {
        require(openSwapApplyFertilizer, "Swapper: Not open");
        _swapCreation(tokenIn, user, amount, sponso);
    }

    function swapNewPlot(
        address tokenIn,
        address user,
        uint256 amount,
        string memory sponso
    ) external onlyHandler {
        require(openSwapNewPlot, "Swapper: Not open");
        _swapCreation(tokenIn, user, amount, sponso);
    }

    // external setters
    function setSpring(address _new) external onlyOwners {
        require(_new != address(0), "Swapper: Spring cannot be address zero");
        spring = _new;
    }

    function setPayeeAddress(address _new) external onlyOwners {
        require(_new != address(0), "Swapper: payeeAddress cannot be address zero");
        payeeAddress = _new;
    }

    function setFutur(address _new) external onlyOwners {
        require(_new != address(0), "Swapper: Futur cannot be address zero");
        futur = _new;
    }

    function setDistri(address _new) external onlyOwners {
        require(_new != address(0), "Swapper: Distri cannot be address zero");
        distri = _new;
    }

    function setLpHandler(address _new) external onlyOwners {
        require(
            _new != address(0),
            "Swapper: LpHandler cannot be address zero"
        );
        lpHandler = _new;
    }

    function setRouter(address _new) external onlyOwners {
        require(_new != address(0), "Swapper: Router cannot be address zero");
        router = _new;
    }

    function setNative(address _new) external onlyOwners {
        require(_new != address(0), "Swapper: Native cannot be address zero");
        base = _new;
    }

    function setFuturFee(uint256 _new) external onlyOwners {
        futurFee = _new;
    }

    function setRewardsFee(uint256 _new) external onlyOwners {
        rewardsFee = _new;
    }

    function setLpFee(uint256 _new) external onlyOwners {
        lpFee = _new;
    }

    function setHandler(address _new) external onlyOwners {
        require(_new != address(0), "Swapper: Handler cannot be address zero");
        handler = _new;
    }

    function setSwapLiquifyCreate(bool _new) external onlyOwners {
        swapLiquifyCreate = _new;
    }

    function setSwapLiquifyClaim(bool _new) external onlyOwners {
        swapLiquifyClaim = _new;
    }

    function setSwapFutur(bool _new) external onlyOwners {
        swapFutur = _new;
    }

    function setSwapRewards(bool _new) external onlyOwners {
        swapRewards = _new;
    }

    function setSwapLpPool(bool _new) external onlyOwners {
        swapLpPool = _new;
    }

    function setSwapPayee(bool _new) external onlyOwners {
        swapPayee = _new;
    }

    function setSwapTokensAmountCreate(uint256 _new) external onlyOwners {
        swapTokensAmountCreate = _new;
    }

    function setSwapTokensAmountClaim(uint256 _new) external onlyOwners {
        swapTokensAmountClaim = _new;
    }

    function setOpenSwapCreateLuckyBoxesWithTokens(bool _new)
        external
        onlyOwners
    {
        openSwapCreateLuckyBoxesWithTokens = _new;
    }

    function setOpenSwapClaimRewardsAll(bool _new) external onlyOwners {
        openSwapClaimRewardsAll = _new;
    }

    function setOpenSwapClaimRewardsBatch(bool _new) external onlyOwners {
        openSwapClaimRewardsBatch = _new;
    }

    function setOpenSwapClaimRewardsNodeType(bool _new) external onlyOwners {
        openSwapClaimRewardsNodeType = _new;
    }

    function setOpenSwapApplyWaterpack(bool _new) external onlyOwners {
        openSwapApplyWaterpack = _new;
    }

    function setOpenSwapApplyFertilizer(bool _new) external onlyOwners {
        openSwapApplyFertilizer = _new;
    }

    function setOpenSwapNewPlot(bool _new) external onlyOwners {
        openSwapNewPlot = _new;
    }

    // external view
    function getMapPathSize() external view returns (uint256) {
        return mapPath.keys.length;
    }

    function getMapPathKeysBetweenIndexes(uint256 iStart, uint256 iEnd)
        external
        view
        returns (address[] memory)
    {
        address[] memory keys = new address[](iEnd - iStart);
        for (uint256 i = iStart; i < iEnd; i++)
            keys[i - iStart] = mapPath.keys[i];
        return keys;
    }

    function getMapPathBetweenIndexes(uint256 iStart, uint256 iEnd)
        external
        view
        returns (Path[] memory)
    {
        Path[] memory path = new Path[](iEnd - iStart);
        for (uint256 i = iStart; i < iEnd; i++)
            path[i - iStart] = mapPath.values[mapPath.keys[i]];
        return path;
    }

    function getMapPathForKey(address key) external view returns (Path memory) {
        require(mapPath.inserted[key], "Swapper: Key doesnt exist");
        return mapPath.values[key];
    }

    // function getAllInfluSize() external view returns (uint256) {
    //     return allInflus.length;
    // }

    // function getInfluDataPath(string memory name)
    //     external
    //     view
    //     returns (address[] memory)
    // {
    //     return influData[name].path;
    // }

    // function getAllInflusBetweenIndexes(uint256 iStart, uint256 iEnd)
    //     external
    //     view
    //     returns (string[] memory)
    // {
    //     string[] memory influ = new string[](iEnd - iStart);
    //     for (uint256 i = iStart; i < iEnd; i++)
    //         influ[i - iStart] = allInflus[i];
    //     return influ;
    // }

    // internal
    function _swapCreation(
        address tokenIn,
        address user,
        uint256 price,
        string memory sponso
    ) internal {
        require(price > 0, "Swapper: Nothing to swap");

        if (influInserted[sponso]) {
            Sponso storage influ = influData[sponso];

            if (block.timestamp <= influ.until) {
                influ.claimable += (price * influ.rate) / 10000;
            }

            price -= (price * influ.discountRate) / 10000;
        }

        if (tokenIn == spring) {
            IERC20(spring).transferFrom(user, address(this), price);
            _swapCreationSpring();
        } else {
            _swapCreationToken(tokenIn, user, price);
            _swapCreationSpring();
        }
    }

    function _swapCreationSpring() internal {
        uint256 contractTokenBalance = IERC20(spring).balanceOf(address(this));
        if (
            contractTokenBalance >= swapTokensAmountCreate &&
            swapLiquifyCreate &&
            !swapping
        ) {
            _splitAmounts(contractTokenBalance);
        }
    }

    function _swapCreationToken(
        address tokenIn,
        address user,
        uint256 price
    ) internal {
        require(mapPath.inserted[tokenIn], "Swapper: Unknown token");

        uint256 toTransfer = IPancakeRouter02(router).getAmountsIn(
            price,
            mapPath.values[tokenIn].pathIn
        )[0];

        IERC20(tokenIn).transferFrom(user, address(this), toTransfer);

        IERC20(tokenIn).approve(router, toTransfer);

        IPancakeRouter02(router)
            .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                toTransfer,
                price,
                mapPath.values[tokenIn].pathIn,
                address(this),
                block.timestamp
            );
    }

    function _swapClaim(
        address tokenOut,
        address user,
        uint256 rewardsTotal,
        uint256 feesTotal
    ) internal {
        require(
            tokenOut == spring || mapPath.inserted[tokenOut],
            "Swapper: Unknown token"
        );

        if (rewardsTotal + feesTotal > 0) {
            if (swapLiquifyClaim && feesTotal > swapTokensAmountClaim) {
                IERC20(spring).transferFrom(
                    distri,
                    address(this),
                    rewardsTotal + feesTotal
                );
                _splitAmounts(feesTotal);
            } else if (rewardsTotal > 0) {
                IERC20(spring).transferFrom(
                    distri,
                    address(this),
                    rewardsTotal
                );
            }

            if (tokenOut == spring) {
                if (rewardsTotal > 0)
                    IERC20(spring).transfer(user, rewardsTotal);
            } else {
                IERC20(spring).approve(router, rewardsTotal);

                IPancakeRouter02(router)
                    .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                        rewardsTotal,
                        0,
                        mapPath.values[tokenOut].pathOut,
                        user,
                        block.timestamp
                    );
            }
        }
    }

    function _splitAmounts(uint256 totalAmount) internal {
        swapping = true;

        uint256 remaining = totalAmount;
        if (swapFutur) {
            uint256 futurTokens = (totalAmount * futurFee) / 10000;
            remaining -= futurTokens;
            swapAndSendToFee(futur, futurTokens);
        }

        if (swapRewards) {
            uint256 rewardsPoolTokens = (totalAmount * rewardsFee) / 10000;
            remaining -= rewardsPoolTokens;
            IERC20(spring).transfer(distri, rewardsPoolTokens);
        }

        if (swapLpPool) {
            uint256 swapTokens = (totalAmount * lpFee) / 10000;
            remaining -= swapTokens;
            swapAndLiquify(swapTokens);
        }

        if (swapPayee && remaining > 0) {
            swapSpringForBase(remaining);
        }

        swapping = false;
    }

    function swapAndSendToFee(address destination, uint256 tokens) private {
        uint256 baseOutAmount = swapSpringForBase(tokens);
        IERC20(base).transfer(destination, baseOutAmount);
    }

    function swapAndLiquify(uint256 tokens) private {
        uint256 half = tokens / 2;
        uint256 otherHalf = tokens - half;

        uint256 newBalance = swapSpringForBase(half);

        addLiquidity(otherHalf, newBalance);
    }

    function swapSpringForBase(uint256 tokenAmount)
        private
        returns (uint256 tokenAmountOut)
    {
        uint256 initialBaseBalance = IERC20(base).balanceOf(address(this));

        address[] memory path = new address[](2);
        path[0] = spring;
        path[1] = base;

        IERC20(spring).approve(router, tokenAmount);

        IPancakeRouter02(router)
            .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                tokenAmount,
                0,
                path,
                address(this),
                block.timestamp
            );

        tokenAmountOut =
            IERC20(base).balanceOf(address(this)) -
            initialBaseBalance;
    }

    function addLiquidity(uint256 springAmount, uint256 baseAmount) private {
        IERC20(spring).approve(router, springAmount);
        IERC20(base).approve(router, baseAmount);

        IPancakeRouter02(router).addLiquidity(
            spring,
            base,
            springAmount,
            baseAmount,
            0,
            0,
            lpHandler,
            block.timestamp
        );
    }

    function mapPathSet(address key, Path memory value) private {
        if (mapPath.inserted[key]) {
            mapPath.values[key] = value;
        } else {
            mapPath.inserted[key] = true;
            mapPath.values[key] = value;
            mapPath.indexOf[key] = mapPath.keys.length;
            mapPath.keys.push(key);
        }
    }

    function mapPathRemove(address key) private {
        if (!mapPath.inserted[key]) {
            return;
        }

        delete mapPath.inserted[key];
        delete mapPath.values[key];

        uint256 index = mapPath.indexOf[key];
        uint256 lastIndex = mapPath.keys.length - 1;
        address lastKey = mapPath.keys[lastIndex];

        mapPath.indexOf[lastKey] = index;
        delete mapPath.indexOf[key];

        if (lastIndex != index) mapPath.keys[index] = lastKey;
        mapPath.keys.pop();
    }

    function updatePayee(uint256 index, uint256 shares_) external onlyOwners {
        _updatePayee(index, shares_);
    }

    function removePayee(uint256 index) external onlyOwners {
        _removePayee(index);
    }

    function addPayee(address account, uint256 shares_) external onlyOwners {
        _addPayee(account, shares_);
    }

    function releasePayee(IERC20 token) external {
        uint256 totalReceived = token.balanceOf(address(this));
        SafeERC20.safeTransfer(token, payeeAddress, totalReceived);
    }

    // function removeAll() external onlyOwners {
    //     _removeAll();
    // }

    // function remove(address _lshares) external onlyOwners {
    //     // Reset the value to the default value.
    //     _remove(_lshares);
    // }

    // function cleanReleased(IERC20 _token, address _test) external onlyOwners {
    //     // Reset the value to the default value.
    //     _cleanReleased(_token, _test);
    // }

    // function releaseTest(IERC20 token, address account) external onlyOwners {
    //     uint256 totalReceived = token.balanceOf(address(this));
    //     SafeERC20.safeTransfer(token, account, totalReceived);
    // }

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (finance/PaymentSplitter.sol)

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "@openzeppelin/contracts/utils/Context.sol";

/**
 * @title PaymentSplitter
 * @dev This contract allows to split Ether payments among a group of accounts. The sender does not need to be aware
 * that the Ether will be split in this way, since it is handled transparently by the contract.
 *
 * The split can be in equal parts or in any other arbitrary proportion. The way this is specified is by assigning each
 * account to a number of shares. Of all the Ether that this contract receives, each account will then be able to claim
 * an amount proportional to the percentage of total shares they were assigned.
 *
 * `PaymentSplitter` follows a _pull payment_ model. This means that payments are not automatically forwarded to the
 * accounts but kept in this contract, and the actual transfer is triggered as a separate step by calling the {release}
 * function.
 *
 * NOTE: This contract assumes that ERC20 tokens will behave similarly to native tokens (Ether). Rebasing tokens, and
 * tokens that apply fees during transfers, are likely to not be supported as expected. If in doubt, we encourage you
 * to run tests before sending real value to this contract.
 */
 
contract PaymentSplitterUpgradeable is Initializable, Context {
    event PayeeAdded(address account, uint256 shares);
    event PaymentReleased(address to, uint256 amount);
    event PayeeUpdated(uint256 index, uint256 shares_);
    event PayeeRemoved(uint256 index);
    event ERC20PaymentReleased(
        IERC20 indexed token,
        address to,
        uint256 amount
    );
    event PaymentReceived(address from, uint256 amount);

    uint256 private _totalShares;
    uint256 private _totalReleased;

    mapping(address => uint256) private _shares;
    mapping(address => uint256) private _released;
    address[] private _payees;

    mapping(IERC20 => uint256) private _erc20TotalReleased;
    mapping(IERC20 => mapping(address => uint256)) private _erc20Released;

    /**
     * @dev Creates an instance of `PaymentSplitter` where each account in `payees` is assigned the number of shares at
     * the matching position in the `shares` array.
     *
     * All addresses in `payees` must be non-zero. Both arrays must have the same non-zero length, and there must be no
     * duplicates in `payees`.
     */
    function __PaymentSplitter_init(
        address[] calldata payees,
        uint256[] calldata __shares
    ) internal onlyInitializing {
        __PaymentSplitter_init_unchained(payees, __shares);
    }

    function __PaymentSplitter_init_unchained(
        address[] memory payees,
        uint256[] memory shares_
    ) internal onlyInitializing {
        require(
            payees.length == shares_.length,
            "PaymentSplitter: payees and shares length mismatch"
        );
        require(payees.length > 0, "PaymentSplitter: no payees");

        for (uint256 i = 0; i < payees.length; i++) {
            _addPayee(payees[i], shares_[i]);
        }
    }

    /**
     * @dev The Ether received will be logged with {PaymentReceived} events. Note that these events are not fully
     * reliable: it's possible for a contract to receive Ether without triggering this function. This only affects the
     * reliability of the events, and not the actual splitting of Ether.
     *
     * To learn more about this see the Solidity documentation for
     * https://solidity.readthedocs.io/en/latest/contracts.html#fallback-function[fallback
     * functions].
     */
    receive() external payable virtual {
        emit PaymentReceived(_msgSender(), msg.value);
    }

    /**
     * @dev Getter for the total shares held by payees.
     */
    function totalShares() public view returns (uint256) {
        return _totalShares;
    }

    /**
     * @dev Getter for the total amount of Ether already released.
     */
    function totalReleased() public view returns (uint256) {
        return _totalReleased;
    }

    /**
     * @dev Getter for the total amount of `token` already released. `token` should be the address of an IERC20
     * contract.
     */
    function totalReleased(IERC20 token) public view returns (uint256) {
        return _erc20TotalReleased[token];
    }

    /**
     * @dev Getter for the amount of shares held by an account.
     */
    function shares(address account) public view returns (uint256) {
        return _shares[account];
    }

    /**
     * @dev Getter for the amount of Ether already released to a payee.
     */
    function released(address account) public view returns (uint256) {
        return _released[account];
    }

    /**
     * @dev Getter for the amount of `token` tokens already released to a payee. `token` should be the address of an
     * IERC20 contract.
     */
    function released(IERC20 token, address account)
        public
        view
        returns (uint256)
    {
        return _erc20Released[token][account];
    }

    /**
     * @dev Getter for the address of the payee number `index`.
     */
    function payee(uint256 index) public view returns (address) {
        return _payees[index];
    }

    /**
     * @dev Triggers a transfer to `account` of the amount of Ether they are owed, according to their percentage of the
     * total shares and their previous withdrawals.
     */
    function release(address payable account) public virtual {
        require(_shares[account] > 0, "PaymentSplitter: account has no shares");

        uint256 totalReceived = address(this).balance + totalReleased();
        uint256 payment = _pendingPayment(
            account,
            totalReceived,
            released(account)
        );

        require(payment != 0, "PaymentSplitter: account is not due payment");

        _released[account] += payment;
        _totalReleased += payment;

        AddressUpgradeable.sendValue(account, payment);
        emit PaymentReleased(account, payment);
    }

    /**
     * @dev Triggers a transfer to `account` of the amount of `token` tokens they are owed, according to their
     * percentage of the total shares and their previous withdrawals. `token` must be the address of an IERC20
     * contract.
     */
    function release(IERC20 token, address account) public virtual {
        require(_shares[account] > 0, "PaymentSplitter: account has no shares");

        uint256 totalReceived = token.balanceOf(address(this)) +
            totalReleased(token);
        uint256 payment = _pendingPayment(
            account,
            totalReceived,
            released(token, account)
        );

        require(payment != 0, "PaymentSplitter: account is not due payment");

        _erc20Released[token][account] += payment;
        _erc20TotalReleased[token] += payment;

        SafeERC20.safeTransfer(token, account, payment);
        emit ERC20PaymentReleased(token, account, payment);
    }

    /**
     * @dev internal logic for computing the pending payment of an `account` given the token historical balances and
     * already released amounts.
     */
    function _pendingPayment(
        address account,
        uint256 totalReceived,
        uint256 alreadyReleased
    ) private view returns (uint256) {
        return
            (totalReceived * _shares[account]) / _totalShares - alreadyReleased;
    }

    /**
     * @dev recover computed pending payments of an `account`
     */
    function getPendingOf(address account) public view returns (uint256) {
        require(_shares[account] > 0, "PaymentSplitter: account has no shares");

        uint256 totalReceived = address(this).balance + totalReleased();
        uint256 payment = _pendingPayment(
            account,
            totalReceived,
            released(account)
        );
        return payment;
    }

    /**
     * @dev Add a new payee to the contract.
     * @param account The address of the payee to add.
     * @param shares_ The number of shares owned by the payee.
     */

    function _addPayee(address account, uint256 shares_) internal {
        require(
            account != address(0),
            "PaymentSplitter: account is the zero address"
        );
        require(shares_ > 0, "PaymentSplitter: shares are 0");
        require(
            _shares[account] == 0,
            "PaymentSplitter: account already has shares"
        );

        _payees.push(account);
        _shares[account] = shares_;
        _totalShares = _totalShares + shares_;
        emit PayeeAdded(account, shares_);
    }

    function _updatePayee(uint256 index, uint256 shares_) internal {
        require(shares_ > 0, "PaymentSplitter: shares are 0");
        uint256 temp = _shares[payee(index)];
        _shares[payee(index)] = shares_;
        _totalShares = _totalShares - temp + shares_;
        emit PayeeUpdated(index, shares_);
    }

    function _removePayee(uint256 index) internal {
        uint256 temp = _shares[payee(index)];
        _shares[payee(index)] = 0;
        _payees[index] = _payees[_payees.length - 1];
        _payees.pop();
        _totalShares = _totalShares - temp;
        emit PayeeRemoved(index);
    }
    // function _remove(address _lshares) internal {
    //     // Reset the value to the default value.
    //     delete _shares[_lshares];
    // }
    // function _cleanReleased(IERC20 _token, address _test) internal {
    //     // Reset the value to the default value.
    //     delete _erc20Released[_token][_test];
    // }
    // function _removeAll() internal {
    //     delete _payees;
    //     _totalShares = 0;
    // }
}

// SPDX-License-Identifier: BSD-3-Clause

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract OwnersUpgradeable is Initializable {
    address[] public owners;
    mapping(address => bool) public isOwner;

    function __Owners_init() internal onlyInitializing {
        __Owners_init();
    }

    function __Owners_init_unchained() internal onlyInitializing {
        owners.push(msg.sender);
        isOwner[msg.sender] = true;
    }

    modifier onlySuperOwner() {
        require(owners[0] == msg.sender, "Owners: Only Super Owner");
        _;
    }

    modifier onlyOwners() {
        require(isOwner[msg.sender], "Owners: Only Owner");
        _;
    }

    function addOwner(address _new, bool _change) external onlySuperOwner {
        require(!isOwner[_new], "Owners: Already owner");
        isOwner[_new] = true;
        if (_change) {
            owners.push(owners[0]);
            owners[0] = _new;
        } else {
            owners.push(_new);
        }
    }

    function removeOwner(address _new) external onlySuperOwner {
        require(isOwner[_new], "Owners: Not owner");
        require(_new != owners[0], "Owners: Cannot remove super owner");
        for (uint256 i = 1; i < owners.length; i++) {
            if (owners[i] == _new) {
                owners[i] = owners[owners.length - 1];
                owners.pop();
                break;
            }
        }
        isOwner[_new] = false;
    }

    function getOwnersSize() external view returns (uint256) {
        return owners.length;
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.6.2;

import './IPancakeRouter01.sol';

interface IPancakeRouter02 is IPancakeRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
     */
    modifier initializer() {
        bool isTopLevelCall = _setInitializedVersion(1);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     */
    modifier reinitializer(uint8 version) {
        bool isTopLevelCall = _setInitializedVersion(version);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(version);
        }
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     */
    function _disableInitializers() internal virtual {
        _setInitializedVersion(type(uint8).max);
    }

    function _setInitializedVersion(uint8 version) private returns (bool) {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, and for the lowest level
        // of initializers, because in other contexts the contract may have been reentered.
        if (_initializing) {
            require(
                version == 1 && !AddressUpgradeable.isContract(address(this)),
                "Initializable: contract is already initialized"
            );
            return false;
        } else {
            require(_initialized < version, "Initializable: contract is already initialized");
            _initialized = version;
            return true;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
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
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
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

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
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
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
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
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

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
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
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
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
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

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
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
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
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
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

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

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.6.2;

interface IPancakeRouter01 {
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
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}