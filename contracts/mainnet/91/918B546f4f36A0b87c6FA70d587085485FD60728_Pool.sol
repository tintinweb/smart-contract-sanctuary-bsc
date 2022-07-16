//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./ERC20.sol";
import "./EnumerableSet.sol";
import "./Initializable.sol";
import "./Ownable.sol";
import "./Address.sol";
import "./SafeMath.sol";
import "./ECDSA.sol";

contract Pool is ERC20, Initializable, Ownable {
    using EnumerableSet for EnumerableSet.AddressSet;
    using SafeMath for uint256;
    using Address for address;
    using ECDSA for bytes32;

    mapping(address => uint256) public depositBalance;
    mapping(address => bool) public isAddedAsset;
    mapping(address => uint256) public locked;
    mapping(address => address) public referrals;

    struct PoolStat {
        uint256 totalAccGain;
        uint256 totalAccLoss;
        uint256 totalDeposit;
        uint256 totalAccDeposit;
    }

    PoolStat public poolStat;

    uint256 private generateAssetIndex;
    uint256 public lastTXBlock;

    bool public enableDeposit;
    uint256 public poolStart;
    uint256 public poolStartBlock;

    struct Config {
        address depositToken;
        address wETH;
        address poolExchange;
        address factory;
        uint256 masterFee;
        uint256 referralFee;
        address operator;
    }

    struct TokensBalance {
        address token;
        uint256 balance;
    }

    uint256 public accMasterFee;

    Config public config;

    EnumerableSet.AddressSet private assets;
    EnumerableSet.AddressSet private investors;

    struct Route {
        string action;
        address pool;
        address route;
        address srcToken;
        address destToken;
        uint256 amountIn;
        uint256 amountOutMin;
        uint256 deadline;
        uint256 expire;
        bytes swapCalldata;
        bytes signature;
    }

    event Referral(address investor, address referral);

    event Deposit(
        address indexed investor,
        uint256 amount,
        uint256 lp,
        uint256 timestamp
    );

    event ExitPool(
        address indexed pool,
        address indexed investor,
        uint256 lp,
        uint256 exitAmount,
        uint256 timestamp
    );

    event Swap(
        address dexRoute,
        address srcToken,
        address destToken,
        uint256 amountIn,
        uint256 amountOut,
        uint256 timestamp
    );

    /*
     */
    constructor() ERC20("TradingFundToken", "TFTOKEN") {}

    function initialize(
        address factory,
        address owner,
        address _depositToken,
        uint256 _masterFee,
        uint256 _referralFee,
        address _wETH,
        address _operator
    ) public initializer {
        _transferOwnership(owner);
        config.depositToken = _depositToken;
        config.factory = factory;
        config.masterFee = _masterFee;
        config.referralFee = _referralFee;
        config.wETH = _wETH;
        config.operator = _operator;

        assets.add(_depositToken);
        _preApprove(_depositToken);
        poolStart = block.timestamp;
        poolStartBlock = block.number;
    }

    function getTokens() public view returns (address[] memory) {
        return assets.values();
    }

    function getInvestors() public view returns (address[] memory) {
        return investors.values();
    }

    /**
     * @dev before use this function
     * offchain should get current pool values and sign by operator and send back to client to execute
     * (A) follow sign [[uint256]pool values, [address]caller, [uint256]lastTXBlock, [uin256]signature timeout, [uint]chainId, [uint]timeout]
     * deposit will locked 24 hours for next exit pool
     * @param poolValues  values in deposit token (busd) from all assets in pool
     * @param lpAmountReceive  values in deposit token (busd) from all assets in pool
     * @param amount amount of deposit token (busd) need to deposit in pool
     * @param expire timestamp expire signature
     * @param referral referral address to pay commission to
     * @param depositSignature offchain signanture refer to (A)
     */
    function deposit(
        uint256 poolValues,
        uint256 lpAmountReceive,
        uint256 expire,
        uint256 amount,
        address referral,
        bytes calldata depositSignature
    ) public {
        require(amount > 0, "INVALID_AMOUNT");
        require(lpAmountReceive > 0, "INVALID_LP");
        require(expire >= block.timestamp, "SIG_EXPIRED");

        if (referral != address(0) && referral != msg.sender) {
            require(referral.isContract() == false, "INVALID_REFERRAL_ADDR");
            require(referrals[msg.sender] == address(0), "MUST_EMPTY_REFERRAL");
            referrals[msg.sender] = referral;

            emit Referral(msg.sender, referral);
        }

        if (msg.sender == owner()) {
            if (enableDeposit == false) {
                enableDeposit = true;
            }
        } else {
            require(enableDeposit == true, "POOL_DISABLE_DEPOSIT");
        }

        require(
            _verifyDeposit(
                address(this),
                msg.sender,
                poolValues,
                lpAmountReceive,
                expire,
                lastTXBlock,
                _chainId(),
                depositSignature
            ),
            "INVALID_DEPOSIT_SIG"
        );

        unchecked {
            //locked[msg.sender] = block.timestamp + 24 hours;
            poolStat.totalDeposit += amount;
            poolStat.totalAccDeposit += amount;
            depositBalance[msg.sender] += amount;
        }

        _mint(msg.sender, lpAmountReceive);

        lastTXBlock++;

        require(
            IERC20(config.depositToken).transferFrom(
                msg.sender,
                address(this),
                amount
            )
        );

        if (!assets.contains(config.depositToken)) {
            assets.add(config.depositToken);
            _preApprove(config.depositToken);
        }

        if (!investors.contains(msg.sender)) {
            investors.add(msg.sender);
        }

        emit Deposit(msg.sender, amount, lpAmountReceive, block.timestamp);
    }

    struct SwapVar {
        uint256 preSrcToken;
        uint256 preDestToken;
        uint256 postSrcToken;
        uint256 postDestToken;
        uint256 amountInUsed;
        uint256 amountOutReceived;
    }

    function swap(Route calldata route) public onlyOwner {
        require(route.expire >= block.timestamp, "SIG_EXPIRED");

        uint256 amountOutReceived = _swap(route);

        if (!assets.contains(route.destToken)) {
            assets.add(route.destToken);
            _preApprove(route.destToken);
        }

        // if source token empty remote from list; except deposit token
        if (IERC20(route.srcToken).balanceOf(address(this)) == 0) {
            assets.remove(route.srcToken);
        }

        lastTXBlock++;

        emit Swap(
            route.route,
            route.srcToken,
            route.destToken,
            route.amountIn,
            amountOutReceived,
            block.timestamp
        );
    }

    /*
    all path must get max values for investor benafit
    */
    function exit(
        Route[] calldata routes,
        uint256 withdrawValues,
        uint256 lpExitAmount,
        uint256 amountExitExpect,
        uint256 amountFeeMaster,
        uint256 amountFeeReferral,
        uint256 expire,
        bytes calldata exitSignature
    ) public {
        // require(
        //     block.timestamp >= locked[msg.sender],
        //     "LOCKED_FROM_LAST_DEPOSIT"
        // );
        require(expire >= block.timestamp, "SIG_EXPIRED");

        require(balanceOf(msg.sender) >= lpExitAmount, "INSUFF_AMOUNT");
        require(withdrawValues > 0, "INVALID_WITHDRAW_VALUES");

        require(
            _verifyExit(
                withdrawValues,
                lpExitAmount,
                amountExitExpect,
                amountFeeMaster,
                amountFeeReferral,
                expire,
                lastTXBlock,
                _chainId(),
                exitSignature
            ),
            "INVALID_SIG_EXIT"
        );

        if (withdrawValues >= poolStat.totalDeposit) {
            poolStat.totalDeposit = 0;
        } else {
            unchecked {
                poolStat.totalDeposit -= withdrawValues;
            }
        }

        if (withdrawValues >= depositBalance[msg.sender]) {
            depositBalance[msg.sender] = 0;
        } else {
            unchecked {
                depositBalance[msg.sender] -= withdrawValues;
            }
        }

        _swapForExit(routes);

        uint256 currentDepositToken = _getAssetBalance(config.depositToken);

        assert(currentDepositToken >= amountExitExpect);

        // pay fee
        if (amountFeeMaster > 0) {
            require(
                IERC20(config.depositToken).transfer(owner(), amountFeeMaster)
            );

            accMasterFee += amountFeeMaster;
        }

        if (amountFeeReferral > 0 && referrals[msg.sender] != address(0)) {
            require(
                IERC20(config.depositToken).transfer(
                    referrals[msg.sender],
                    amountFeeReferral
                )
            );
        }

        require(
            IERC20(config.depositToken).transfer(msg.sender, amountExitExpect)
        );

        if (amountExitExpect > withdrawValues) {
            poolStat.totalAccGain += (amountExitExpect - withdrawValues);
        }

        if (amountExitExpect < withdrawValues) {
            poolStat.totalAccLoss += (withdrawValues - amountExitExpect);
        }

        lastTXBlock++;

        _burn(msg.sender, lpExitAmount);

        emit ExitPool(
            address(this),
            msg.sender,
            lpExitAmount,
            amountExitExpect,
            block.timestamp
        );
    }

    function _swapForExit(Route[] calldata routes) internal {
        Route memory route;

        uint256 assetsSize = assets.length();

        address[] memory removeAssets = new address[](assetsSize);

        for (uint256 i = 0; i < assetsSize; i++) {
            route = routes[i];
            address asset = assets.at(i);

            if (asset == config.depositToken) {
                continue;
            }

            assert(asset == route.srcToken);

            _swap(route);

            if (IERC20(route.srcToken).balanceOf(address(this)) == 0) {
                removeAssets[i] = route.srcToken;
            }
        }

        //clean up
        for (uint256 j = 0; j < removeAssets.length; j++) {
            if (removeAssets[j] == address(0)) {
                continue;
            }
            assets.remove(removeAssets[j]);
        }
    }

    function _swap(Route memory route) internal returns (uint256) {
        uint256 amountInETH;
        if (route.srcToken == config.wETH) {
            amountInETH = route.amountIn;
        } else {
            require(
                IERC20(route.srcToken).approve(route.route, route.amountIn)
            );
        }

        require(_verifySwap(route), "INVALID_VERIFY_SWAP");

        SwapVar memory swapVar;
        swapVar.preSrcToken = _getAssetBalance(route.srcToken);
        swapVar.preDestToken = _getAssetBalance(route.destToken);

        address(route.route).functionCallWithValue(
            route.swapCalldata,
            amountInETH
        );

        swapVar.postSrcToken = _getAssetBalance(route.srcToken);
        swapVar.postDestToken = _getAssetBalance(route.destToken);

        swapVar.amountInUsed = swapVar.preSrcToken - swapVar.postSrcToken;
        swapVar.amountOutReceived =
            swapVar.postDestToken -
            swapVar.preDestToken;
        if (
            swapVar.amountInUsed > route.amountIn ||
            swapVar.amountOutReceived < route.amountOutMin
        ) {
            revert("AmountOutInsufficient");
        }

        return swapVar.amountOutReceived;
    }

    function _getAssetBalance(address token) internal view returns (uint256) {
        if (token == config.wETH) {
            return address(this).balance;
        } else {
            return IERC20(token).balanceOf(address(this));
        }
    }

    function getSignDeposit(
        uint256 poolValues,
        uint256 lpAmountReceive,
        uint256 expire
    ) public view returns (bytes32) {
        return
            _signMessageDeposit(
                address(this),
                msg.sender,
                poolValues,
                lpAmountReceive,
                expire,
                lastTXBlock,
                _chainId()
            );
    }

    function _signMessageDeposit(
        address pool,
        address caller,
        uint256 poolValues,
        uint256 lpAmountReceive,
        uint256 expire,
        uint256 _lastTXBlock,
        uint256 chainId
    ) internal pure returns (bytes32) {
        bytes32 depositHash = keccak256(
            abi.encodePacked(
                pool,
                caller,
                poolValues,
                lpAmountReceive,
                expire,
                _lastTXBlock,
                chainId
            )
        );
        return depositHash.toEthSignedMessageHash();
    }

    function _verifyDeposit(
        address pool,
        address caller,
        uint256 poolValues,
        uint256 lpAmountReceive,
        uint256 expire,
        uint256 _lastTXBlock,
        uint256 chainId,
        bytes memory signature
    ) internal view returns (bool) {
        bytes32 ethSigned = _signMessageDeposit(
            pool,
            caller,
            poolValues,
            lpAmountReceive,
            expire,
            _lastTXBlock,
            chainId
        );

        return ethSigned.recover(signature) == config.operator;
    }

    // ----------- swap

    function getSignSwap(
        string memory action,
        address _route,
        address srcToken,
        address destToken,
        uint256 amountIn,
        uint256 amountOutMin,
        uint256 deadline,
        uint256 expire,
        bytes memory swapCalldata
    ) public view returns (bytes32) {
        Route memory route;
        route.action = action;
        route.pool = address(this);
        route.route = _route;
        route.srcToken = srcToken;
        route.destToken = destToken;
        route.amountIn = amountIn;
        route.amountOutMin = amountOutMin;
        route.deadline = deadline;
        route.expire = expire;
        route.swapCalldata = swapCalldata;
        return _signMessageSwap(route, _chainId());
    }

    function _signMessageSwap(Route memory route, uint256 chainId)
        internal
        view
        returns (bytes32)
    {
        return
            (
                keccak256(
                    abi.encodePacked(
                        _wrapSwapSign(route),
                        route.amountIn,
                        route.amountOutMin,
                        address(this), // to
                        route.deadline,
                        route.expire,
                        lastTXBlock,
                        chainId,
                        route.swapCalldata
                    )
                )
            ).toEthSignedMessageHash();
    }

    function _verifySwap(Route memory route) internal view returns (bool) {
        bytes32 ethSigned = _signMessageSwap(route, _chainId()); //action,
        return ethSigned.recover(route.signature) == config.operator;
    }

    function _wrapSwapSign(Route memory route)
        internal
        view
        returns (bytes memory)
    {
        return
            abi.encodePacked(
                route.action,
                address(this),
                msg.sender,
                route.route,
                route.srcToken,
                route.destToken
            );
    }

    // function _verifySwap(
    //     string memory action,
    //     address route,
    //     address srcToken,
    //     address destToken,
    //     uint256 amountIn,
    //     uint256 amountOutMin,
    //     uint256 deadline,
    //     uint256 expire,
    //     bytes memory swapCalldata,
    //     bytes memory signature
    // ) internal view returns (bool) {
    //     address pool = address(this);
    //     address caller = msg.sender;

    //     bytes32 ethSigned = (
    //         keccak256(
    //             abi.encodePacked(
    //                 action,
    //                 pool,
    //                 caller,
    //                 route,
    //                 srcToken,
    //                 destToken,
    //                 amountIn,
    //                 amountOutMin,
    //                 pool, // to
    //                 deadline,
    //                 expire,
    //                 lastTXBlock,
    //                 _chainId(),
    //                 swapCalldata
    //             )
    //         )
    //     ).toEthSignedMessageHash();

    //     //bytes32 ethSigned = _signMessageSwap(route, _chainId()); //action,
    //     return ethSigned.recover(signature) == config.operator;
    // }

    // ------ exit
    function getSignExit(
        uint256 withdrawValues,
        uint256 lpExitAmount,
        uint256 amountExitExpect,
        uint256 amountFeeMaster,
        uint256 amountFeeReferral,
        uint256 expire
    ) public view returns (bytes32) {
        return
            _signMessageExit(
                withdrawValues,
                lpExitAmount,
                amountExitExpect,
                amountFeeMaster,
                amountFeeReferral,
                expire,
                lastTXBlock,
                _chainId()
            );
    }

    function _signMessageExit(
        uint256 withdrawValues,
        uint256 lpExitAmount,
        uint256 amountExitExpect,
        uint256 amountFeeMaster,
        uint256 amountFeeReferral,
        uint256 expire,
        uint256 _lastTXBlock,
        uint256 chainId
    ) internal view returns (bytes32) {
        bytes32 exitHash = keccak256(
            abi.encodePacked(
                address(this),
                msg.sender,
                withdrawValues,
                lpExitAmount,
                amountExitExpect,
                amountFeeMaster,
                amountFeeReferral,
                expire,
                _lastTXBlock,
                chainId
            )
        );

        return exitHash.toEthSignedMessageHash();
    }

    function _verifyExit(
        uint256 withdrawValues,
        uint256 lpExitAmount,
        uint256 amountExitExpect,
        uint256 amountFeeMaster,
        uint256 amountFeeReferral,
        uint256 expire,
        uint256 _lastTXBlock,
        uint256 chainId,
        bytes memory exitSignature
    ) internal view returns (bool) {
        bytes32 ethSigned = _signMessageExit(
            withdrawValues,
            lpExitAmount,
            amountExitExpect,
            amountFeeMaster,
            amountFeeReferral,
            expire,
            _lastTXBlock,
            chainId
        );

        return ethSigned.recover(exitSignature) == config.operator;
    }

    function _chainId() internal view returns (uint256 chainId) {
        assembly {
            chainId := chainid()
        }
    }

    function emerForTest(address token, uint256 amount) public onlyOwner {
        if (token == config.wETH) {
            payable(msg.sender).transfer(amount);
            return;
        }

        IERC20(token).transfer(msg.sender, amount);
    }

    // extends
    function approveTest(address asset) public onlyOwner {
        IERC20(asset).approve(
            0x1111111254fb6c44bAC0beD2854e76F90643097d,
            0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
        );
    }

    function _preApprove(address asset) internal {
        IERC20(asset).approve(
            0x1111111254fb6c44bAC0beD2854e76F90643097d,
            0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
        );
    }
}