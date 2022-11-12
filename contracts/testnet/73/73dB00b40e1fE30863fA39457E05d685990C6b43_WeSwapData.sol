// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Callerable.sol";
import "./Strings.sol";
import "./IERC20Metadata.sol";
import "./SafeMath.sol";

contract WeSwapData is Callerable {
    struct LiquidityTokenData {
        address tokenAddress1;
        address tokenAddress2;
        uint256 amount1;
        uint256 amount2;
        bool exists;
    }

    struct ProviderAllTokenData {
        address provider;
        uint256 amount1;
        uint256 amount2;
        uint256 percent;
        uint256 fee1Total;
        uint256 fee1Claimed;
        uint256 fee2Total;
        uint256 fee2Claimed;
        bool removed;
        bool exists;
    }

    struct ProviderAllCoinData {
        address provider;
        uint256 tokenAmount;
        uint256 coinAmount;
        uint256 percent;
        uint256 feeTokenTotal;
        uint256 feeTokenClaimed;
        uint256 feeCoinTotal;
        uint256 feeCoinClaimed;
        bool removed;
        bool exists;
    }

    struct TokenNeighbor {
        uint8 nType;
        bytes32 hash;
        address neighbor;
        bool exists;
    }

    //key: hash of (tokenAddress1+tokenAddress2)
    mapping(bytes32 => LiquidityTokenData) mapAllLiquidityToken;

    //map for address to check if this address provided liquidity of Token-Token
    //key: hash => provider
    mapping(bytes32 => address) mapProviderTokenAddr;

    //map for address to check if this address provided liquidity of Token-Coin
    //key: tokenAddress => provider
    mapping(address => address) mapProviderCoinAddr;

    uint256 tokenLiquidityNumber;
    mapping(uint256 => bytes32) mapTokenLiquidityByIndex;

    //number of providers in Token-Token liquidity pool
    //key: hash => number
    mapping(bytes32 => uint256) mapProviderTokenNumber;
    //key: hash => (provider address => index of mapProviderTokenNumber)
    mapping(bytes32 => mapping(address => uint256)) mapProviderTokenIndex;
    //Token-Token provider list
    //key: hash => (index of mapProviderTokenNumber => ProviderAllTokenData)
    mapping(bytes32 => mapping(uint256 => ProviderAllTokenData)) mapProviderAllToken;

    //user token liquidity number
    //key: account => number
    mapping(address => uint256) mapUserTokenLiquidityNumber;
    //user token liquidity index in mapProviderAllToken
    //key: account => (index of mapUserTokenLiquidityNumber => index of mapTokenLiquidityByIndex)
    mapping(address => mapping(uint256 => uint256)) mapUserTokenLiquidityIndex;

    //number of providers in Token-Coin liquidity pool
    //key: token => provider number
    mapping(address => uint256) mapProviderCoinNumber;
    //key: token => (provider address => index of number)
    mapping(address => mapping(address => uint256)) mapProviderCoinIndex;
    //number of coin-token pair from user
    //key: user account => number
    mapping(address => uint256) mapUserCoinTokenPairNumber;
    //key: user account => (index of mapUserCoinTokenPairNumber => index of mapProviderCoinNumber)
    mapping(address => mapping(uint256 => uint256)) mapUserCoinTokenPair;
    //Token-Coin provider list
    //key: token => (index of number => ProviderAllCoinData)
    mapping(address => mapping(uint256 => ProviderAllCoinData)) mapProviderAllCoin;

    mapping(address => uint32) mapTokenNeighborNumber;
    mapping(address => mapping(uint32 => TokenNeighbor)) mapTokenNeighbor;

    struct LiquidityCoinData {
        address tokenAddress;
        uint256 tokenAmount;
        uint256 coinAmount;
        bool exists;
    }

    //fee
    uint256 internal feeRate;

    //key: token address => LiquidityCoinData
    mapping(address => LiquidityCoinData) mapAllLiquidityCoin;

    //key: user account => (token address => LiquidityCoinData)
    mapping(address => mapping(address => LiquidityCoinData)) mapUserLiquidityCoin;

    event tokenSwaped(
        address fromTokenAddress,
        uint256 fromAmount,
        address toTokenAddress,
        uint256 toAmount,
        uint256 timestamp
    );
    event tokenCoinSwaped(
        address fromTokenAddress,
        uint256 fromTokenAmount,
        uint256 toCoinAmount,
        uint256 timestamp
    );
    event coinTokenSwaped(
        uint256 fromCoinAmount,
        address toTokenAddress,
        uint256 toTokenAmount,
        uint256 timestamp
    );

    event tokenLiquidVol(
        address tokenAddress1,
        uint256 amount1,
        address tokenAddress2,
        uint256 amount2,
        uint256 timestamp
    );
    event tokenCoinLiquidVol(
        address tokenAddress,
        uint256 tokenAmount,
        uint256 coinAmount,
        uint256 timestamp
    );

    constructor() {
        feeRate = 2;
    }

    function isTokenPairExists(address tokenAddress1, address tokenAddress2)
        external
        view
        returns (bool res, bytes32 hash)
    {
        (res, hash) = _isTokenPairExists(tokenAddress1, tokenAddress2);
    }

    function getTokenLiquid(address tokenAddress1, address tokenAddress2)
        external
        view
        returns (
            bool res,
            uint256 amount1,
            uint256 amount2
        )
    {
        bytes32 hash = keccak256(
            abi.encodePacked(
                Strings.addressToString(tokenAddress1),
                Strings.addressToString(tokenAddress2)
            )
        );
        if (mapAllLiquidityToken[hash].exists) {
            res = true;
            amount1 = mapAllLiquidityToken[hash].amount1;
            amount2 = mapAllLiquidityToken[hash].amount2;
        }
    }

    function _isTokenPairExists(address tokenAddress1, address tokenAddress2)
        internal
        view
        returns (bool res, bytes32 hash)
    {
        bytes32 hashTemp = keccak256(
            abi.encodePacked(
                Strings.addressToString(tokenAddress1),
                Strings.addressToString(tokenAddress2)
            )
        );
        if (mapAllLiquidityToken[hashTemp].exists) {
            res = true;
            hash = hashTemp;
        } else {
            hashTemp = keccak256(
                abi.encodePacked(
                    Strings.addressToString(tokenAddress2),
                    Strings.addressToString(tokenAddress1)
                )
            );
            if (mapAllLiquidityToken[hashTemp].exists) {
                res = true;
                hash = hashTemp;
            }
        }
    }

    function getAddedTokenPairAmount(
        address tokenAddress1,
        uint256 amount1,
        address tokenAddress2,
        uint256 amount2
    )
        external
        view
        returns (
            bool exists,
            bytes32 hash,
            uint256 addAmount1,
            uint256 addAmount2
        )
    {
        addAmount1 = amount1;
        addAmount2 = amount2;
        (exists, hash) = _isTokenPairExists(tokenAddress1, tokenAddress2);
        if (exists) {
            LiquidityTokenData memory data = mapAllLiquidityToken[hash];
            if (tokenAddress1 == data.tokenAddress2) {
                tokenAddress1 = data.tokenAddress1;
                addAmount1 = amount2;
                tokenAddress2 = data.tokenAddress2;
                addAmount2 = amount1;
            }
        }

        if (exists) {
            LiquidityTokenData memory data = mapAllLiquidityToken[hash];
            if (amount1 * data.amount2 >= amount2 * data.amount1) {
                addAmount1 = (amount2 * data.amount1) / data.amount2;
                addAmount2 = amount2;
            } else {
                addAmount1 = amount1;
                addAmount2 = (amount1 * data.amount2) / data.amount1;
            }
        } else {
            hash = keccak256(
                abi.encodePacked(
                    Strings.addressToString(tokenAddress1),
                    Strings.addressToString(tokenAddress2)
                )
            );
        }
    }

    function addLiquidityToken(
        address account,
        bool exists,
        bytes32 hash,
        address tokenAddress1,
        uint256 amount1,
        uint256 addAmount1,
        address tokenAddress2,
        uint256 amount2,
        uint256 addAmount2
    ) external onlyCaller {
        uint256 newPercent = 0;
        if (exists) {
            LiquidityTokenData storage data = mapAllLiquidityToken[hash];
            data.amount1 += addAmount1;
            data.amount2 += addAmount2;
            newPercent = _updateProviderSharePercentOfToken(
                tokenAddress1,
                tokenAddress2,
                addAmount1,
                account
            );
        } else {
            mapAllLiquidityToken[hash] = LiquidityTokenData(
                tokenAddress1,
                tokenAddress2,
                amount1,
                amount2,
                true
            );
            newPercent = 10**IERC20Metadata(tokenAddress1).decimals();
        }

        if (mapProviderTokenAddr[hash] == account) {
            uint256 index = mapProviderTokenIndex[hash][account];
            ProviderAllTokenData storage patd = mapProviderAllToken[hash][
                index
            ];
            patd.amount1 += addAmount1;
            patd.amount2 += addAmount2;
            patd.percent = newPercent;
        } else {
            mapProviderTokenAddr[hash] = account;
            mapProviderTokenNumber[hash]++;
            mapUserTokenLiquidityNumber[account]++;
            mapProviderTokenIndex[hash][account] = mapProviderTokenNumber[hash];
            if (
                mapProviderAllToken[hash][mapProviderTokenNumber[hash]]
                    .exists &&
                mapProviderAllToken[hash][mapProviderTokenNumber[hash]].removed
            ) {
                mapProviderAllToken[hash][mapProviderTokenNumber[hash]]
                    .amount1 = addAmount1;
                mapProviderAllToken[hash][mapProviderTokenNumber[hash]]
                    .amount2 = addAmount2;
                mapProviderAllToken[hash][mapProviderTokenNumber[hash]]
                    .percent = newPercent;
                mapProviderAllToken[hash][mapProviderTokenNumber[hash]]
                    .removed = false;
            } else {
                mapProviderAllToken[hash][
                    mapProviderTokenNumber[hash]
                ] = ProviderAllTokenData(
                    account,
                    addAmount1,
                    addAmount2,
                    newPercent,
                    0,
                    0,
                    0,
                    0,
                    false,
                    true
                );
            }
            tokenLiquidityNumber++;
            mapTokenLiquidityByIndex[tokenLiquidityNumber] = hash;

            mapUserTokenLiquidityIndex[account][
                mapUserTokenLiquidityNumber[account]
            ] = tokenLiquidityNumber;
        }

        mapTokenNeighborNumber[tokenAddress1] += 1;
        mapTokenNeighbor[tokenAddress1][
            mapTokenNeighborNumber[tokenAddress1]
        ] = TokenNeighbor(1, hash, tokenAddress2, true);
        mapTokenNeighborNumber[tokenAddress2] += 1;
        mapTokenNeighbor[tokenAddress2][
            mapTokenNeighborNumber[tokenAddress2]
        ] = TokenNeighbor(1, hash, tokenAddress1, true);
    }

    //update liquidity share percent
    function _updateProviderSharePercentOfToken(
        address token1,
        address token2,
        uint256 addAmount1,
        address provider
    ) internal returns (uint256 percent) {
        bytes32 hash = keccak256(
            abi.encodePacked(
                Strings.addressToString(token1),
                Strings.addressToString(token2)
            )
        );
        uint256 index = mapProviderTokenIndex[hash][provider];
        if (index > 0) {
            percent =
                ((10 **
                    IERC20Metadata(mapAllLiquidityToken[hash].tokenAddress1)
                        .decimals()) * addAmount1) /
                (mapAllLiquidityToken[hash].amount1 + addAmount1);
            uint256 rePercent = (10 **
                IERC20Metadata(mapAllLiquidityToken[hash].tokenAddress1)
                    .decimals()) - percent;
            for (uint256 i = 1; i <= mapProviderTokenNumber[hash]; ++i) {
                ProviderAllTokenData storage p = mapProviderAllToken[hash][i];
                if (!p.removed) {
                    p.percent =
                        (p.percent * rePercent) /
                        (10 **
                            IERC20Metadata(
                                mapAllLiquidityToken[hash].tokenAddress1
                            ).decimals());
                }
                if (p.provider == provider) {
                    p.percent += percent;
                }
            }
        } else {
            percent = (10 **
                IERC20Metadata(mapAllLiquidityToken[hash].tokenAddress1)
                    .decimals());
        }
    }

    function getTokenPairHash(address tokenAddress1, address tokenAddress2)
        external
        pure
        returns (bytes32 hash)
    {
        hash = keccak256(
            abi.encodePacked(
                Strings.addressToString(tokenAddress1),
                Strings.addressToString(tokenAddress2)
            )
        );
    }

    function getTokenPairLiquidity(bytes32 hash)
        external
        view
        returns (
            address tokenAddress1,
            uint256 amount1,
            address tokenAddress2,
            uint256 amount2
        )
    {
        LiquidityTokenData memory _data = mapAllLiquidityToken[hash];
        tokenAddress1 = _data.tokenAddress1;
        amount1 = _data.amount1;
        tokenAddress2 = _data.tokenAddress2;
        amount2 = _data.amount2;
    }

    function getAddedCoinPairAmount(
        uint256 coinAmount,
        address tokenAddress,
        uint256 tokenAmount
    )
        external
        view
        returns (
            bool exists,
            uint256 addAmountToken,
            uint256 addAmountCoin
        )
    {
        addAmountToken = tokenAmount;
        addAmountCoin = coinAmount;
        exists = mapAllLiquidityCoin[tokenAddress].exists;
        if (exists) {
            LiquidityCoinData memory data = mapAllLiquidityCoin[tokenAddress];
            if (
                tokenAmount * data.coinAmount >= coinAmount * data.tokenAmount
            ) {
                addAmountToken =
                    (coinAmount * data.tokenAmount) /
                    data.coinAmount;
                addAmountCoin = coinAmount;
            } else {
                addAmountToken = tokenAmount;
                addAmountCoin =
                    (tokenAmount * data.coinAmount) /
                    data.tokenAmount;
            }
        }
    }

    function addLiquidityCoin(
        address account,
        bool exists,
        address tokenAddress,
        uint256 tokenAmount,
        uint256 addAmountToken,
        uint256 addAmountCoin
    ) external onlyCaller {
        if (exists) {
            LiquidityCoinData storage data = mapAllLiquidityCoin[tokenAddress];
            data.tokenAmount += addAmountToken;
            data.coinAmount += addAmountCoin;
        } else {
            mapAllLiquidityCoin[tokenAddress] = LiquidityCoinData(
                tokenAddress,
                addAmountToken,
                addAmountCoin,
                true
            );
        }

        uint256 newPercent = _updateProviderSharePercentOfCoin(
            tokenAddress,
            tokenAmount,
            account
        );

        if (mapProviderCoinAddr[tokenAddress] == account) {
            uint256 index = mapProviderCoinIndex[tokenAddress][account];
            ProviderAllCoinData storage pacd = mapProviderAllCoin[tokenAddress][
                index
            ];
            pacd.tokenAmount += addAmountToken;
            pacd.coinAmount += addAmountCoin;
            pacd.percent = newPercent;
        } else {
            mapProviderCoinAddr[tokenAddress] = account;
            mapProviderCoinNumber[tokenAddress]++;
            mapProviderCoinIndex[tokenAddress][account] = mapProviderCoinNumber[
                tokenAddress
            ];
            if (
                mapProviderAllCoin[tokenAddress][
                    mapProviderCoinNumber[tokenAddress]
                ].exists &&
                mapProviderAllCoin[tokenAddress][
                    mapProviderCoinNumber[tokenAddress]
                ].removed
            ) {
                mapProviderAllCoin[tokenAddress][
                    mapProviderCoinNumber[tokenAddress]
                ].tokenAmount = addAmountToken;
                mapProviderAllCoin[tokenAddress][
                    mapProviderCoinNumber[tokenAddress]
                ].coinAmount = addAmountCoin;
                mapProviderAllCoin[tokenAddress][
                    mapProviderCoinNumber[tokenAddress]
                ].percent = newPercent;
                mapProviderAllCoin[tokenAddress][
                    mapProviderCoinNumber[tokenAddress]
                ].removed = false;
            } else {
                mapProviderAllCoin[tokenAddress][
                    mapProviderCoinNumber[tokenAddress]
                ] = ProviderAllCoinData(
                    account,
                    addAmountToken,
                    addAmountCoin,
                    newPercent,
                    0,
                    0,
                    0,
                    0,
                    false,
                    true
                );
            }
        }

        if (mapUserLiquidityCoin[account][tokenAddress].exists) {
            LiquidityCoinData storage data = mapUserLiquidityCoin[account][
                tokenAddress
            ];
            data.tokenAmount += addAmountToken;
            data.coinAmount += addAmountCoin;
        } else {
            mapUserLiquidityCoin[account][tokenAddress] = LiquidityCoinData(
                tokenAddress,
                addAmountToken,
                addAmountCoin,
                true
            );
            mapUserCoinTokenPairNumber[account] += 1;
            mapUserCoinTokenPair[account][
                mapUserCoinTokenPairNumber[account]
            ] = mapProviderCoinNumber[tokenAddress];
        }

        mapTokenNeighborNumber[tokenAddress] += 1;
        mapTokenNeighbor[tokenAddress][
            mapTokenNeighborNumber[tokenAddress]
        ] = TokenNeighbor(2, 0, address(0), true);
    }

    function _updateProviderSharePercentOfCoin(
        address token,
        uint256 addAmount,
        address provider
    ) internal returns (uint256 percent) {
        uint256 index = mapProviderCoinIndex[token][provider];
        if (index > 0) {
            percent =
                ((10**IERC20Metadata(token).decimals()) * addAmount) /
                (mapAllLiquidityCoin[token].tokenAmount + addAmount);
            uint256 rePercent = (10**IERC20Metadata(token).decimals()) -
                percent;
            for (uint256 i = 1; i <= mapProviderCoinNumber[token]; ++i) {
                ProviderAllCoinData storage p = mapProviderAllCoin[token][i];
                if (!p.removed) {
                    p.percent =
                        (p.percent * rePercent) /
                        (10**IERC20Metadata(token).decimals());
                }
                if (p.provider == provider) {
                    p.percent += percent;
                }
            }
        } else {
            percent = (10**IERC20Metadata(token).decimals());
        }
    }

    function swapToken(
        bytes32 hash,
        address fromTokenAddress,
        uint256 fromTokenAmount,
        address toTokenAddress
    ) external onlyCaller returns (uint256 resultAmount) {
        LiquidityTokenData storage ltd = mapAllLiquidityToken[hash];
        require(ltd.exists, "lq not exists");
        require(
            fromTokenAddress == ltd.tokenAddress1 &&
                toTokenAddress == ltd.tokenAddress2,
            "pair order error"
        );
        uint256 distributedAmount = _distributeTokenSwapTokenFee(
            hash,
            fromTokenAddress,
            fromTokenAmount
        );
        uint256 actualFromTokenAmount = fromTokenAmount - distributedAmount;
        uint256 k = ltd.amount1 * ltd.amount2;
        resultAmount = ltd.amount2 - k / (ltd.amount1 + actualFromTokenAmount);
        ltd.amount1 = ltd.amount1 + actualFromTokenAmount;
        ltd.amount2 = ltd.amount2 - resultAmount;

        emit tokenSwaped(
            fromTokenAddress,
            fromTokenAmount,
            toTokenAddress,
            resultAmount,
            block.timestamp
        );
        LiquidityTokenData memory _data = mapAllLiquidityToken[hash];
        emit tokenLiquidVol(
            _data.tokenAddress1,
            _data.amount1,
            _data.tokenAddress2,
            _data.amount2,
            block.timestamp
        );
    }

    //swap token to coin
    function swapTokenToCoin(address tokenAddress, uint256 tokenAmount)
        external
        onlyCaller
        returns (uint256 resultAmount)
    {
        LiquidityCoinData storage lcd = mapAllLiquidityCoin[tokenAddress];
        require(lcd.exists, "lq not exists");
        require(tokenAddress == lcd.tokenAddress, "pair error");
        uint256 distributedAmount = _distributeTokenSwapCoinFee(
            tokenAddress,
            tokenAmount
        );
        uint256 actualFromTokenAmount = tokenAmount - distributedAmount;
        uint256 k = lcd.tokenAmount * lcd.coinAmount;
        resultAmount =
            lcd.coinAmount -
            k /
            (lcd.tokenAmount + actualFromTokenAmount);
        lcd.tokenAmount = lcd.tokenAmount + actualFromTokenAmount;
        lcd.coinAmount = lcd.coinAmount - resultAmount;

        emit tokenCoinSwaped(
            tokenAddress,
            tokenAmount,
            resultAmount,
            block.timestamp
        );
        LiquidityCoinData memory _data = mapAllLiquidityCoin[tokenAddress];
        emit tokenCoinLiquidVol(
            tokenAddress,
            _data.tokenAmount,
            _data.coinAmount,
            block.timestamp
        );
    }

    //swap coin to token
    function swapCoinToToken(uint256 coinAmount, address toTokenAddress)
        external
        onlyCaller
        returns (uint256 resultAmount)
    {
        LiquidityCoinData storage lcd = mapAllLiquidityCoin[toTokenAddress];
        require(lcd.exists, "lq not exists");
        require(toTokenAddress == lcd.tokenAddress, "pair error");
        uint256 distributedAmount = _distributeCoinSwapTokenFee(
            coinAmount,
            toTokenAddress
        );
        uint256 actualCoinAmount = coinAmount - distributedAmount;
        uint256 k = lcd.tokenAmount * lcd.coinAmount;
        resultAmount =
            lcd.tokenAmount -
            k /
            (lcd.coinAmount + actualCoinAmount);
        lcd.coinAmount = lcd.coinAmount + actualCoinAmount;
        lcd.tokenAmount = lcd.tokenAmount - resultAmount;

        emit coinTokenSwaped(
            coinAmount,
            toTokenAddress,
            resultAmount,
            block.timestamp
        );
        LiquidityCoinData memory _data = mapAllLiquidityCoin[toTokenAddress];
        emit tokenCoinLiquidVol(
            toTokenAddress,
            _data.tokenAmount,
            _data.coinAmount,
            block.timestamp
        );
    }

    function _distributeTokenSwapTokenFee(
        bytes32 hash,
        address fromTokenAddress,
        uint256 fromTokenAmount
    ) internal returns (uint256 distributedAmount) {
        uint256 providerNumber = mapProviderTokenNumber[hash];
        for (uint256 i = 1; i <= providerNumber; ++i) {
            ProviderAllTokenData storage patd = mapProviderAllToken[hash][i];
            uint256 fee = (((fromTokenAmount * feeRate) / 1000) *
                patd.percent) /
                (10**IERC20Metadata(fromTokenAddress).decimals());
            if (fromTokenAddress == mapAllLiquidityToken[hash].tokenAddress1) {
                patd.fee1Total += fee;
            } else if (
                fromTokenAddress == mapAllLiquidityToken[hash].tokenAddress2
            ) {
                patd.fee2Total += fee;
            }
            distributedAmount += fee;
        }
    }

    function _estimateTokenSwapTokenFee(
        bytes32 hash,
        address fromTokenAddress,
        uint256 fromTokenAmount
    ) internal view returns (uint256 fee) {
        uint256 providerNumber = mapProviderTokenNumber[hash];
        for (uint256 i = 1; i <= providerNumber; ++i) {
            ProviderAllTokenData memory patd = mapProviderAllToken[hash][i];
            fee +=
                (fromTokenAmount * patd.percent) /
                (10**IERC20Metadata(fromTokenAddress).decimals());
        }
    }

    function _distributeTokenSwapCoinFee(
        address fromTokenAddress,
        uint256 fromTokenAmount
    ) internal returns (uint256 distributedAmount) {
        uint256 providerNumber = mapProviderCoinNumber[fromTokenAddress];
        for (uint256 i = 1; i <= providerNumber; ++i) {
            ProviderAllCoinData storage pacd = mapProviderAllCoin[
                fromTokenAddress
            ][i];
            uint256 fee = (((fromTokenAmount * feeRate) / 1000) *
                pacd.percent) /
                (10**IERC20Metadata(fromTokenAddress).decimals());
            pacd.feeTokenTotal += fee;
            distributedAmount += fee;
        }
    }

    function _estimateTokenSwapCoinFee(
        address fromTokenAddress,
        uint256 fromTokenAmount
    ) internal view returns (uint256 fee) {
        uint256 providerNumber = mapProviderCoinNumber[fromTokenAddress];
        for (uint256 i = 1; i <= providerNumber; ++i) {
            ProviderAllCoinData memory pacd = mapProviderAllCoin[
                fromTokenAddress
            ][i];
            fee +=
                (fromTokenAmount * pacd.percent) /
                (10**IERC20Metadata(fromTokenAddress).decimals());
        }
    }

    function _distributeCoinSwapTokenFee(
        uint256 coinAmount,
        address toTokenAddress
    ) internal returns (uint256 distributedAmount) {
        uint256 providerNumber = mapProviderCoinNumber[toTokenAddress];
        for (uint256 i = 1; i <= providerNumber; ++i) {
            ProviderAllCoinData storage pacd = mapProviderAllCoin[
                toTokenAddress
            ][i];
            uint256 fee = (((coinAmount * feeRate) / 1000) * pacd.percent) /
                (10**18);
            pacd.feeCoinTotal += fee;
            distributedAmount += fee;
        }
    }

    function _estimateCoinSwapTokenFee(
        uint256 coinAmount,
        address toTokenAddress
    ) internal view returns (uint256 fee) {
        uint256 providerNumber = mapProviderCoinNumber[toTokenAddress];
        for (uint256 i = 1; i <= providerNumber; ++i) {
            ProviderAllCoinData storage pacd = mapProviderAllCoin[
                toTokenAddress
            ][i];
            fee += (coinAmount * pacd.percent) / (10**18);
        }
    }

    function findBestBridgeOfToken(
        address fromTokenAddress,
        uint256 fromAmount,
        address toTokenAddress
    )
        external
        view
        returns (
            bool res,
            uint8 nType,
            address bridgeAddress,
            bytes32 hash1,
            bytes32 hash2
        )
    {
        (res, nType, bridgeAddress, hash1, hash2) = _findBestBridgeOfToken(
            fromTokenAddress,
            fromAmount,
            toTokenAddress
        );
    }

    function _findBestBridgeOfToken(
        address fromTokenAddress,
        uint256 fromAmount,
        address toTokenAddress
    )
        internal
        view
        returns (
            bool res,
            uint8 nType,
            address bridgeAddress,
            bytes32 hash1,
            bytes32 hash2
        )
    {
        for (uint32 i = 1; i <= mapTokenNeighborNumber[fromTokenAddress]; ++i) {
            uint256 bestAmount = 0;
            if (mapTokenNeighbor[fromTokenAddress][i].exists) {
                bool ok = false;
                uint8 nTypeNeighbor = mapTokenNeighbor[fromTokenAddress][i]
                    .nType;
                if (nTypeNeighbor == 1) {
                    hash1 = mapTokenNeighbor[fromTokenAddress][i].hash;
                    (ok, hash2) = _isTokenPairExists(
                        mapTokenNeighbor[fromTokenAddress][i].neighbor,
                        toTokenAddress
                    );
                } else if (nTypeNeighbor == 2) {
                    ok = _isCoinPairExists(
                        mapTokenNeighbor[fromTokenAddress][i].neighbor
                    );
                }

                if (ok) {
                    uint256 neighborAmount;
                    uint256 toAmount;
                    bridgeAddress = mapTokenNeighbor[fromTokenAddress][i]
                        .neighbor;
                    if (nTypeNeighbor == 1) {
                        (, neighborAmount) = _estimateTokenSwapResult(
                            fromTokenAddress,
                            fromAmount,
                            bridgeAddress
                        );
                        (, toAmount) = _estimateTokenSwapResult(
                            bridgeAddress,
                            neighborAmount,
                            toTokenAddress
                        );
                    } else if (nTypeNeighbor == 2) {
                        (
                            ,
                            ,
                            neighborAmount,
                            ,

                        ) = _estimateTokenSwap2CoinResult(
                            fromTokenAddress,
                            fromAmount
                        );
                        (, , toAmount, , ) = _estimateCoinSwap2TokenResult(
                            neighborAmount,
                            toTokenAddress
                        );
                    }
                    if (toAmount > bestAmount) {
                        bestAmount = toAmount;
                    }
                    res = true;
                    nType = mapTokenNeighbor[fromTokenAddress][i].nType;
                }
            }
        }
    }

    //find best routine for swapping from `fromTokenAddress` to coin, the routine bridge should be a token
    function findBestBridgeOfToken2Coin(
        address fromTokenAddress,
        uint256 fromAmount
    )
        external
        view
        returns (
            bool res,
            address bridgeAddress,
            bytes32 hash
        )
    {
        (res, bridgeAddress, hash) = _findBestBridgeOfToken2Coin(
            fromTokenAddress,
            fromAmount
        );
    }

    function _findBestBridgeOfToken2Coin(
        address fromTokenAddress,
        uint256 fromAmount
    )
        internal
        view
        returns (
            bool res,
            address bridgeAddress,
            bytes32 hash
        )
    {
        for (uint32 i = 1; i <= mapTokenNeighborNumber[fromTokenAddress]; ++i) {
            uint256 bestAmount = 0;
            if (
                mapTokenNeighbor[fromTokenAddress][i].exists &&
                mapTokenNeighbor[fromTokenAddress][i].nType == 1
            ) {
                bool ok = _isCoinPairExists(
                    mapTokenNeighbor[fromTokenAddress][i].neighbor
                );
                if (ok) {
                    hash = mapTokenNeighbor[fromTokenAddress][i].hash;
                    bridgeAddress = mapTokenNeighbor[fromTokenAddress][i]
                        .neighbor;
                    (, uint256 neighborAmount) = _estimateTokenSwapResult(
                        fromTokenAddress,
                        fromAmount,
                        bridgeAddress
                    );
                    (, , uint256 toAmount, , ) = _estimateTokenSwap2CoinResult(
                        bridgeAddress,
                        neighborAmount
                    );
                    if (toAmount > bestAmount) {
                        bestAmount = toAmount;
                    }
                    res = true;
                }
            }
        }
    }

    function findBestBridgeOfCoin2Token(
        uint256 fromAmount,
        address toTokenAddress
    )
        external
        view
        returns (
            bool res,
            address bridgeAddress,
            bytes32 hash
        )
    {
        (res, bridgeAddress, hash) = _findBestBridgeOfCoin2Token(
            fromAmount,
            toTokenAddress
        );
    }

    function _findBestBridgeOfCoin2Token(
        uint256 fromAmount,
        address toTokenAddress
    )
        internal
        view
        returns (
            bool res,
            address bridgeAddress,
            bytes32 hash
        )
    {
        for (uint32 i = 1; i <= mapTokenNeighborNumber[toTokenAddress]; ++i) {
            uint256 bestAmount = 0;
            if (
                mapTokenNeighbor[toTokenAddress][i].exists &&
                mapTokenNeighbor[toTokenAddress][i].nType == 1
            ) {
                bool ok = _isCoinPairExists(
                    mapTokenNeighbor[toTokenAddress][i].neighbor
                );
                if (ok) {
                    hash = mapTokenNeighbor[toTokenAddress][i].hash;
                    bridgeAddress = mapTokenNeighbor[toTokenAddress][i]
                        .neighbor;
                    (
                        ,
                        ,
                        uint256 neighborAmount,
                        ,

                    ) = _estimateCoinSwap2TokenResult(
                            fromAmount,
                            bridgeAddress
                        );
                    (, uint256 toAmount) = _estimateTokenSwapResult(
                        bridgeAddress,
                        neighborAmount,
                        toTokenAddress
                    );
                    if (toAmount > bestAmount) {
                        bestAmount = toAmount;
                    }
                    res = true;
                }
            }
        }
    }

    function estimateTokenSwapResult(
        address fromTokenAddress,
        uint256 fromAmount,
        address toTokenAddress
    )
        external
        view
        returns (
            bool result,
            uint256 fee,
            uint256 resultAmount,
            bool needBridge,
            uint8 bridgeType,
            address bridgeAddress
        )
    {
        (bool exists, ) = _isTokenPairExists(fromTokenAddress, toTokenAddress);
        if (!exists) {
            (
                needBridge,
                bridgeType,
                bridgeAddress,
                ,

            ) = _findBestBridgeOfToken(
                fromTokenAddress,
                fromAmount,
                toTokenAddress
            );
            if (needBridge) {
                result = true;
                uint256 bridgeAmount;
                if (bridgeType == 1) {
                    (fee, bridgeAmount) = _estimateTokenSwapResult(
                        fromTokenAddress,
                        fromAmount,
                        bridgeAddress
                    );
                    (, resultAmount) = _estimateTokenSwapResult(
                        bridgeAddress,
                        bridgeAmount,
                        toTokenAddress
                    );
                } else if (bridgeType == 2) {
                    (, fee, bridgeAmount, , ) = _estimateTokenSwap2CoinResult(
                        fromTokenAddress,
                        fromAmount
                    );
                    (, , resultAmount, , ) = _estimateCoinSwap2TokenResult(
                        bridgeAmount,
                        toTokenAddress
                    );
                }
            } else {
                result = false;
            }
        } else {
            result = true;
            (fee, resultAmount) = _estimateTokenSwapResult(
                fromTokenAddress,
                fromAmount,
                toTokenAddress
            );
        }
    }

    function _estimateTokenSwapResult(
        address fromTokenAddress,
        uint256 fromAmount,
        address toTokenAddress
    ) internal view returns (uint256 fee, uint256 resultAmount) {
        (bool resHash, bytes32 hash) = _isTokenPairExists(
            fromTokenAddress,
            toTokenAddress
        );
        require(resHash, "lq not exists");
        LiquidityTokenData memory ltd = mapAllLiquidityToken[hash];
        require(
            fromTokenAddress == ltd.tokenAddress1 &&
                toTokenAddress == ltd.tokenAddress2,
            "pair order error"
        );
        fee = _estimateTokenSwapTokenFee(hash, fromTokenAddress, fromAmount);
        uint256 k = ltd.amount1 * ltd.amount2;
        resultAmount = ltd.amount2 - k / (ltd.amount1 + (fromAmount - fee));
    }

    function estimateTokenSwap2CoinResult(
        address fromTokenAddress,
        uint256 fromAmount
    )
        external
        view
        returns (
            bool res,
            uint256 fee,
            uint256 resultAmount,
            bool needBridge,
            address bridgeAddress
        )
    {
        (
            res,
            fee,
            resultAmount,
            needBridge,
            bridgeAddress
        ) = _estimateTokenSwap2CoinResult(fromTokenAddress, fromAmount);
    }

    function _estimateTokenSwap2CoinResult(
        address fromTokenAddress,
        uint256 fromAmount
    )
        internal
        view
        returns (
            bool res,
            uint256 fee,
            uint256 resultAmount,
            bool needBridge,
            address bridgeAddress
        )
    {
        if (_isCoinPairExists(fromTokenAddress)) {
            LiquidityCoinData memory lcd = mapAllLiquidityCoin[
                fromTokenAddress
            ];
            if (fromTokenAddress == lcd.tokenAddress) {
                fee = _estimateTokenSwapCoinFee(fromTokenAddress, fromAmount);
                uint256 k = lcd.tokenAmount * lcd.coinAmount;
                resultAmount =
                    lcd.coinAmount -
                    k /
                    (lcd.tokenAmount + (fromAmount - fee));
                res = true;
            }
        } else {
            (needBridge, bridgeAddress, ) = _findBestBridgeOfToken2Coin(
                fromTokenAddress,
                fromAmount
            );
            if (needBridge) {
                (uint256 _fee, uint256 bridgeAmount) = _estimateTokenSwapResult(
                    fromTokenAddress,
                    fromAmount,
                    bridgeAddress
                );
                fee = _fee;
                LiquidityCoinData memory lcd = mapAllLiquidityCoin[
                    bridgeAddress
                ];
                uint256 k = lcd.tokenAmount * lcd.coinAmount;
                resultAmount =
                    lcd.coinAmount -
                    k /
                    (lcd.tokenAmount + (bridgeAmount - fee));
                res = true;
            }
        }
    }

    function estimateCoinSwap2TokenResult(
        uint256 fromAmount,
        address toTokenAddress
    )
        internal
        view
        returns (
            bool res,
            uint256 fee,
            uint256 resultAmount,
            bool needBridge,
            address bridgeAddress
        )
    {
        (
            res,
            fee,
            resultAmount,
            needBridge,
            bridgeAddress
        ) = _estimateCoinSwap2TokenResult(fromAmount, toTokenAddress);
    }

    function _estimateCoinSwap2TokenResult(
        uint256 fromAmount,
        address toTokenAddress
    )
        internal
        view
        returns (
            bool res,
            uint256 fee,
            uint256 resultAmount,
            bool needBridge,
            address bridgeAddress
        )
    {
        if (_isCoinPairExists(toTokenAddress)) {
            LiquidityCoinData memory lcd = mapAllLiquidityCoin[toTokenAddress];
            if (toTokenAddress == lcd.tokenAddress) {
                fee = _estimateCoinSwapTokenFee(fromAmount, toTokenAddress);
                uint256 k = lcd.tokenAmount * lcd.coinAmount;
                resultAmount =
                    lcd.tokenAmount -
                    k /
                    (lcd.coinAmount + (fromAmount - fee));
            }
        } else {
            (needBridge, bridgeAddress, ) = _findBestBridgeOfCoin2Token(
                fromAmount,
                toTokenAddress
            );
            if (needBridge) {
                fee = _estimateCoinSwapTokenFee(fromAmount, bridgeAddress);
                LiquidityCoinData memory lcd = mapAllLiquidityCoin[
                    bridgeAddress
                ];
                uint256 k = lcd.tokenAmount * lcd.coinAmount;
                uint256 bridgeAmount = lcd.coinAmount -
                    k /
                    (lcd.tokenAmount + (fromAmount - fee));
                (, resultAmount) = _estimateTokenSwapResult(
                    bridgeAddress,
                    bridgeAmount,
                    toTokenAddress
                );
                res = true;
            }
        }
    }

    function isCoinPairExists(address tokenAddress)
        external
        view
        returns (bool res)
    {
        res = _isCoinPairExists(tokenAddress);
    }

    function getCoinPairLiquidityData(address tokenAddress)
        external
        view
        returns (
            bool res,
            uint256 tokenAmount,
            uint256 coinAmount
        )
    {
        if (mapAllLiquidityCoin[tokenAddress].exists) {
            res = true;
            tokenAmount = mapAllLiquidityCoin[tokenAddress].tokenAmount;
            coinAmount = mapAllLiquidityCoin[tokenAddress].coinAmount;
        }
    }

    function _isCoinPairExists(address tokenAddress)
        internal
        view
        returns (bool res)
    {
        if (mapAllLiquidityCoin[tokenAddress].exists) {
            res = true;
        }
    }

    function getUserLiquidityTokenNumber(address account)
        external
        view
        returns (uint256 res)
    {
        res = mapUserTokenLiquidityNumber[account];
    }

    function getUserLiquidityToken(address account, uint256 index)
        external
        view
        returns (
            bool res,
            uint256 percent,
            uint256 amount1,
            uint256 amount2,
            uint256 fee1Total,
            uint256 fee1Claimed,
            uint256 fee2Total,
            uint256 fee2Claimed
        )
    {
        if (mapUserTokenLiquidityIndex[account][index] > 0) {
            uint256 indexOfMapTokenLiquidityByIndex = mapUserTokenLiquidityIndex[
                    account
                ][index];
            if (indexOfMapTokenLiquidityByIndex > 0) {
                bytes32 hash = mapTokenLiquidityByIndex[
                    indexOfMapTokenLiquidityByIndex
                ];
                uint256 indexOfMapProviderTokenNumber = mapProviderTokenIndex[
                    hash
                ][account];
                if (indexOfMapProviderTokenNumber > 0) {
                    ProviderAllTokenData memory patd = mapProviderAllToken[
                        hash
                    ][indexOfMapProviderTokenNumber];
                    if (patd.exists) {
                        res = true;
                        amount1 = patd.amount1;
                        amount2 = patd.amount2;
                        percent = patd.percent;
                        fee1Total = patd.fee1Total;
                        fee1Claimed = patd.fee1Claimed;
                        fee2Total = patd.fee2Total;
                        fee2Claimed = patd.fee2Claimed;
                    }
                }
            }
        }
    }

    function getUserLiquidityToken(
        address account,
        address tokenAddress1,
        address tokenAddress2
    )
        external
        view
        returns (
            bool res,
            uint256 amount1,
            uint256 amount2,
            uint256 percent,
            uint256 fee1Total,
            uint256 fee1Claimed,
            uint256 fee2Total,
            uint256 fee2Claimed
        )
    {
        (bool isExists, bytes32 hash) = _isTokenPairExists(
            tokenAddress1,
            tokenAddress2
        );
        if (isExists) {
            uint256 index = mapProviderTokenIndex[hash][account];
            if (index > 0) {
                res = true;
                ProviderAllTokenData memory patd = mapProviderAllToken[hash][
                    index
                ];
                amount1 = patd.amount1;
                amount2 = patd.amount2;
                percent = patd.percent;
                fee1Total = patd.fee1Total;
                fee1Claimed = patd.fee1Claimed;
                fee2Total = patd.fee2Total;
                fee2Claimed = patd.fee2Claimed;
            }
        }
    }

    function getUserLiquidityCoinNumber(address account)
        external
        view
        returns (uint256 res)
    {
        res = mapUserCoinTokenPairNumber[account];
    }

    function getUserLiquidityCoin(address account, uint256 index)
        external
        view
        returns (
            address tokenAddress,
            uint256 tokenAmount,
            uint256 coinAmount,
            uint256 percent,
            uint256 feeTokenTotal,
            uint256 feeTokenClaimed,
            uint256 feeCoinTotal,
            uint256 feeCoinClaimed
        )
    {
        uint256 indexOfAll = mapUserCoinTokenPair[account][index];
        if (indexOfAll > 0) {
            ProviderAllCoinData memory pacd = mapProviderAllCoin[tokenAddress][
                indexOfAll
            ];
            if (pacd.exists) {
                //tokenAddress = pacd.;
                tokenAmount = pacd.tokenAmount;
                coinAmount = pacd.coinAmount;
                percent = pacd.percent;
                feeTokenTotal = pacd.feeTokenTotal;
                feeTokenClaimed = pacd.feeTokenClaimed;
                feeCoinTotal = pacd.feeCoinTotal;
                feeCoinClaimed = pacd.feeCoinClaimed;
            }
        }
    }

    function getUserLiquidityCoin(address account, address tokenAddress)
        external
        view
        returns (
            bool res,
            uint256 tokenAmount,
            uint256 coinAmount,
            uint256 percent,
            uint256 feeTokenTotal,
            uint256 feeTokenClaimed,
            uint256 feeCoinTotal,
            uint256 feeCoinClaimed
        )
    {
        uint256 index = mapProviderCoinIndex[tokenAddress][account];
        if (index > 0) {
            ProviderAllCoinData memory pacd = mapProviderAllCoin[tokenAddress][
                index
            ];
            if (pacd.exists) {
                res = true;
                tokenAmount = pacd.tokenAmount;
                coinAmount = pacd.coinAmount;
                percent = pacd.percent;
                feeTokenTotal = pacd.feeTokenTotal;
                feeTokenClaimed = pacd.feeTokenClaimed;
                feeCoinTotal = pacd.feeCoinTotal;
                feeCoinClaimed = pacd.feeCoinClaimed;
            }
        }
    }

    function getUserTokenPairIndex(bytes32 hash, address account)
        external
        view
        returns (uint256 res)
    {
        res = mapProviderTokenIndex[hash][account];
    }

    function getTokenPairLiquidityData(bytes32 hash)
        external
        view
        returns (
            bool res,
            address tokenAddress1,
            address tokenAddress2,
            uint256 amount1,
            uint256 amount2
        )
    {
        if (mapAllLiquidityToken[hash].exists) {
            res = true;
            tokenAddress1 = mapAllLiquidityToken[hash].tokenAddress1;
            tokenAddress2 = mapAllLiquidityToken[hash].tokenAddress2;
            amount1 = mapAllLiquidityToken[hash].amount1;
            amount2 = mapAllLiquidityToken[hash].amount2;
        }
    }

    function claimTokenPairFee(
        bytes32 hash,
        uint256 index,
        uint256 amount,
        uint256 position
    ) external onlyCaller {
        if (position == 1) {
            mapProviderAllToken[hash][index].fee1Claimed = SafeMath.add(
                mapProviderAllToken[hash][index].fee1Claimed,
                amount
            );
        } else if (position == 2) {
            mapProviderAllToken[hash][index].fee2Claimed = SafeMath.add(
                mapProviderAllToken[hash][index].fee2Claimed,
                amount
            );
        }
    }

    function getUserCoinPairIndex(address tokenAddress, address account)
        external
        view
        returns (uint256 res)
    {
        res = mapProviderCoinIndex[tokenAddress][account];
    }

    function claimCoinPairFee(
        address tokenAddress,
        uint256 index,
        uint256 amount,
        uint256 position
    ) external onlyCaller {
        if (position == 1) {
            mapProviderAllCoin[tokenAddress][index].feeTokenClaimed = SafeMath
                .add(
                    mapProviderAllCoin[tokenAddress][index].feeTokenClaimed,
                    amount
                );
        } else if (position == 2) {
            mapProviderAllCoin[tokenAddress][index].feeCoinClaimed = SafeMath
                .add(
                    mapProviderAllCoin[tokenAddress][index].feeCoinClaimed,
                    amount
                );
        }
    }

    function subTokenPairLiquidity(
        bytes32 hash,
        uint256 amount,
        uint256 _type
    ) external onlyCaller {
        if (_type == 1) {
            mapAllLiquidityToken[hash].amount1 = SafeMath.sub(
                mapAllLiquidityToken[hash].amount1,
                amount
            );
        } else if (_type == 2) {
            mapAllLiquidityToken[hash].amount2 = SafeMath.sub(
                mapAllLiquidityToken[hash].amount2,
                amount
            );
        }
    }

    function subPercentTokenPairLiquidity(
        address account,
        bytes32 hash,
        address tokenAddress1,
        uint256 subPercent
    ) external onlyCaller {
        uint256 rePercent = (10**IERC20Metadata(tokenAddress1).decimals()) -
            subPercent;
        for (uint256 i = 1; i <= mapProviderTokenNumber[hash]; ++i) {
            ProviderAllTokenData storage p = mapProviderAllToken[hash][i];
            if (p.provider != account && !p.removed) {
                p.percent =
                    (p.percent *
                        (10 **
                            IERC20Metadata(
                                mapAllLiquidityToken[hash].tokenAddress1
                            ).decimals())) /
                    rePercent;
            } else {
                p.percent = 0;
                p.removed = true;
            }
        }
    }

    function subCoinPairLiquidity(
        address tokenAddress,
        uint256 amount,
        uint256 _type
    ) external onlyCaller {
        if (_type == 1) {
            mapAllLiquidityCoin[tokenAddress].tokenAmount = SafeMath.sub(
                mapAllLiquidityCoin[tokenAddress].tokenAmount,
                amount
            );
        } else if (_type == 2) {
            mapAllLiquidityCoin[tokenAddress].coinAmount = SafeMath.sub(
                mapAllLiquidityCoin[tokenAddress].coinAmount,
                amount
            );
        }
    }

    function subPercentCoinPairLiquidity(
        address account,
        address tokenAddress,
        uint256 subPercent
    ) external onlyCaller {
        uint256 rePercent = (10**IERC20Metadata(tokenAddress).decimals()) -
            subPercent;
        for (uint256 i = 1; i <= mapProviderCoinNumber[tokenAddress]; ++i) {
            ProviderAllCoinData storage p = mapProviderAllCoin[tokenAddress][i];
            if (p.provider != account && !p.removed) {
                p.percent =
                    (p.percent *
                        (10**IERC20Metadata(tokenAddress).decimals())) /
                    rePercent;
            } else {
                p.percent = 0;
                p.removed = true;
            }
        }
    }
}