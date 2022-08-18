// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Ownable.sol";
import "./Lockable.sol";
import "./ERC20.sol";
import "./SafeMath.sol";

contract Swap is Ownable, SafeMath, Lockable {

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
        bool exists;
    }

    struct UserTokenData {
        bytes32 hash;
        uint256 amount1;
        uint256 amount2;
        uint256 fee1Total;
        uint256 fee1Claimed;
        uint256 fee2Total;
        uint256 fee2Claimed;
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

    //map for address to check if this address provided liquidity
    mapping(bytes32 => address) mapProviderTokenAddr;


    //number of providers in liquidity pool
    //key: hash => number
    mapping(bytes32 => uint256) mapProviderTokenNumber;
    mapping(bytes32 => mapping(address => uint256)) mapProviderTokenIndex;
    //provider list
    //key: hash => (index of Number => Data)
    mapping(bytes32 => mapping(uint256 => ProviderAllTokenData)) mapProviderAllToken;


    //number of liquidity of user
    //key: user address => number
    mapping(address => uint256) mapUserTokenNumber;
    //user liquidity list order by index
    //key: user address => (index => UserTokenData)
    mapping(address => mapping(uint256 => UserTokenData)) mapUserTokenIndex;
    //mapping hash to index of user liquidity
    //key: user address => (hash => index)
    mapping(address => mapping(bytes32 => uint256)) mapUserTokenHashIndex;
    //user liquidity list specified by hash
    //key: user address => (hash => UserTokenData)
    mapping(address => mapping(bytes32 => UserTokenData)) mapUserTokenHash;

    mapping(address => uint32) mapTokenNeighborNumber;
    mapping(address => mapping(uint32 =>TokenNeighbor)) mapTokenNeighbor;

    struct LiquidityCoinData {
        address tokenAddress;
        uint256 tokenAmount;
        uint256 coinAmount;
        bool exists;
    }

    mapping(address => LiquidityCoinData) mapAllLiquidityCoin;
    mapping(address => LiquidityCoinData) mapUserLiquidityCoin;

    event liquidityTokenAdded(address account, address tokenAddress1, uint256 amount1, address tokenAddress2, uint256 amount2, uint time);
    event liquidityCoinAdded(address account, address tokenAddress, uint256 tokenAmount, uint256 coinAmount, uint time);

    receive() external payable {}

    fallback() external payable {}

    constructor() {   
    }

    //add liquidity pair of tokens to pool
    //添加流动性之后，保持价格不变
    function addLiquidityToken(address tokenAddress1, uint256 amount1, address tokenAddress2, uint256 amount2) external lock {
        require(amount1 > 0 && amount2 > 0, "input amount must be greater than 0");
        uint256 addAmount1 = amount1;
        uint256 addAmount2 = amount2;
        (bool exists, bytes32 hash) = _isTokenPairExists(tokenAddress1, tokenAddress2);
        if(exists) {
            LiquidityTokenData memory data = mapAllLiquidityToken[hash];
            if(amount1 * data.amount2 >= amount2 * data.amount1) {
                addAmount1 = amount2 * data.amount1 / data.amount2;
                addAmount2 = amount2;
            } else {
                addAmount1 = amount1;
                addAmount2 = amount1 * data.amount2 / data.amount1;
            }
        } else {
            hash = keccak256(abi.encodePacked(tokenAddress1, tokenAddress2));
        }

        require(ERC20(tokenAddress1).balanceOf(msg.sender) >= addAmount1, "insufficient balance of token1");
        require(ERC20(tokenAddress1).allowance(msg.sender, address(this)) >= addAmount1, "not allowed token1");
        require(ERC20(tokenAddress1).transferFrom(msg.sender, address(this), addAmount1), "transfer tokenAddress1 to contract error");
        require(ERC20(tokenAddress2).balanceOf(msg.sender) >= addAmount2, "insufficient balance of token2");
        require(ERC20(tokenAddress2).allowance(msg.sender, address(this)) >= addAmount2, "not allowed token2");
        require(ERC20(tokenAddress2).transferFrom(msg.sender, address(this), addAmount2), "transfer tokenAddress2 to contract error");

        if(exists) {
            LiquidityTokenData storage data = mapAllLiquidityToken[hash];
            data.amount1 += addAmount1;
            data.amount2 += addAmount2;
        } else {
            mapAllLiquidityToken[hash] 
            = LiquidityTokenData(tokenAddress1, tokenAddress2, amount1, amount2, true);
        }

        uint256 newPercent = _updateProviderSharePercentOfToken(tokenAddress1, tokenAddress2, addAmount1, msg.sender);

        if(mapProviderTokenAddr[hash] == msg.sender) {
            uint256 index = mapProviderTokenIndex[hash][msg.sender];
            ProviderAllTokenData storage patd = mapProviderAllToken[hash][index];
            patd.amount1 += addAmount1;
            patd.amount2 += addAmount2;
            patd.percent = newPercent;
        } else {
            mapProviderTokenAddr[hash] = msg.sender;
            mapProviderTokenNumber[hash] ++;
            mapProviderTokenIndex[hash][msg.sender] = mapProviderTokenNumber[hash];
            mapProviderAllToken[hash][mapProviderTokenNumber[hash]] = ProviderAllTokenData(
                msg.sender,
                addAmount1,
                addAmount2,
                newPercent,
                0,
                0,
                0,
                0,
                true
            );
        }

        if(mapUserTokenHash[msg.sender][hash].exists) {
            UserTokenData storage utd = mapUserTokenHash[msg.sender][hash];
            utd.amount1 += addAmount1;
            utd.amount2 += addAmount2;
            uint256 index = mapUserTokenHashIndex[msg.sender][hash];
            UserTokenData storage utd_2 = mapUserTokenIndex[msg.sender][index];
            utd_2.amount1 += addAmount1;
            utd_2.amount2 += addAmount2;
        } else {
            mapUserTokenNumber[msg.sender] ++;
            mapUserTokenHashIndex[msg.sender][hash] = mapUserTokenNumber[msg.sender];
            mapUserTokenHash[msg.sender][hash] 
            = mapUserTokenIndex[msg.sender][mapUserTokenNumber[msg.sender]] 
            = UserTokenData(
                hash,
                addAmount1,
                addAmount2,
                0,
                0,
                0,
                0,
                true
            );
        }

        mapTokenNeighborNumber[tokenAddress1] += 1;
        mapTokenNeighbor[tokenAddress1][mapTokenNeighborNumber[tokenAddress1]] = TokenNeighbor(1, hash, tokenAddress2, true);
        mapTokenNeighborNumber[tokenAddress2] += 1;
        mapTokenNeighbor[tokenAddress2][mapTokenNeighborNumber[tokenAddress2]] = TokenNeighbor(1, hash, tokenAddress1, true);

        emit liquidityTokenAdded(msg.sender, tokenAddress1, addAmount1, tokenAddress2, addAmount2, block.timestamp);
    }

    //update liquidity share percent
    function _updateProviderSharePercentOfToken(address token1, address token2, uint256 addAmount1, address provider) internal returns (uint256 percent) {
        bytes32 hash = keccak256(abi.encodePacked(token1, token2));
        uint256 index = mapProviderTokenIndex[hash][provider];
        if(index > 0) {
            percent = ERC20(token1).decimals() * addAmount1 / mapAllLiquidityToken[hash].amount1;
            uint256 rePercent = ERC20(token1).decimals() - percent;
            for(uint256 i = 1; i <= mapProviderTokenNumber[hash]; ++i) {
                ProviderAllTokenData storage p = mapProviderAllToken[hash][i];
                p.percent = percent * rePercent / ERC20(token1).decimals();
                if(p.provider == provider) {
                    p.percent += percent;
                }
            }
        } else {
            percent = ERC20(token1).decimals();
        }
    }

    //add liquidity pair of token and coin to pool
    function addLiquidityCoin(address tokenAddress, uint256 tokenAmount) external payable lock {
        uint256 coinAmount = msg.value;
        require(tokenAmount > 0 && coinAmount > 0, "input amount must be greater than 0");
        uint256 addAmountToken = tokenAmount;
        uint256 addAmountCoin = coinAmount;
        bool exists = mapAllLiquidityCoin[tokenAddress].exists;
        if(exists) {
            LiquidityCoinData memory data = mapAllLiquidityCoin[tokenAddress];
            if(tokenAmount * data.coinAmount >= coinAmount * data.tokenAmount) {
                addAmountToken = coinAmount * data.tokenAmount / data.coinAmount;
                addAmountCoin = coinAmount;
            } else {
                addAmountToken = tokenAmount;
                addAmountCoin = tokenAmount * data.coinAmount / data.tokenAmount;
            }
        }

        require(ERC20(tokenAddress).balanceOf(msg.sender) >= addAmountToken, "insufficient balance of token");
        require(ERC20(tokenAddress).allowance(msg.sender, address(this)) >= addAmountToken, "not allowed token");
        require(ERC20(tokenAddress).transferFrom(msg.sender, address(this), addAmountToken), "transfer tokenAddress to contract error");
        require(msg.sender.balance >= addAmountCoin, "insufficient coin amount");

        if(exists) {
            LiquidityCoinData storage data = mapAllLiquidityCoin[tokenAddress];
            data.tokenAmount += addAmountToken;
            data.coinAmount += addAmountCoin;
        } else {
            mapAllLiquidityCoin[tokenAddress] = LiquidityCoinData(tokenAddress, addAmountToken, addAmountCoin, true);
        }

        if(mapUserLiquidityCoin[msg.sender].exists) {
            LiquidityCoinData storage data = mapUserLiquidityCoin[msg.sender];
            data.tokenAmount += addAmountToken;
            data.coinAmount += addAmountCoin;
        } else {
            mapUserLiquidityCoin[msg.sender] = LiquidityCoinData(tokenAddress, addAmountToken, addAmountCoin, true);
        }

        mapTokenNeighborNumber[tokenAddress] += 1;
        mapTokenNeighbor[tokenAddress][mapTokenNeighborNumber[tokenAddress]] = TokenNeighbor(2, 0, address(0), true);

        emit liquidityCoinAdded(msg.sender, tokenAddress, addAmountToken, addAmountCoin, block.timestamp);
    }

    //swap `fromTokenAddress` to `toTokenAddress` with base `fromTokenAmount`
    function swapToken(address fromTokenAddress, uint256 fromTokenAmount, address toTokenAddress) external lock {
        require(ERC20(fromTokenAddress).balanceOf(msg.sender) >= fromTokenAmount, "insufficient balance");
        require(ERC20(fromTokenAddress).allowance(msg.sender, address(this)) >= fromTokenAmount, "not approved");
        uint256 resultAmount = 0;
        uint256 bridgeAmount = 0;
        bool ok = false;
        (bool exists, bytes32 hash) = _isTokenPairExists(fromTokenAddress, toTokenAddress);
        if(exists) {
            resultAmount = _swapToken(hash, fromTokenAddress, fromTokenAmount, toTokenAddress);
            ok = true;
        } else {
            (bool hasBridge, uint8 nType, address bridgeAddress, bytes32 hash1, bytes32 hash2) = _findBestBridgeOfToken(fromTokenAddress, fromTokenAmount, toTokenAddress);
            if(hasBridge) {
                if(nType == 1) {
                    bridgeAmount = _swapToken(hash1, fromTokenAddress, fromTokenAmount, bridgeAddress);
                    resultAmount = _swapToken(hash2, bridgeAddress, bridgeAmount, toTokenAddress);
                    ok = true;
                } else if(nType == 2) {
                    bridgeAmount = _swapTokenToCoin(fromTokenAddress, fromTokenAmount);
                    resultAmount = _swapCoinToToken(bridgeAmount, toTokenAddress);
                    ok = true;
                }
            }
        }
        require(ok && resultAmount > 0, "can't swap");
        require(ERC20(fromTokenAddress).transferFrom(msg.sender, address(this), fromTokenAmount), "swap error1");
        require(ERC20(toTokenAddress).transfer(msg.sender, resultAmount), "swap error2");
    }

    function swapTokenToCoin(address tokenAddress, uint256 tokenAmount) external lock {
        require(ERC20(tokenAddress).balanceOf(msg.sender) >= tokenAmount, "insufficient balance");
        require(ERC20(tokenAddress).allowance(msg.sender, address(this)) >= tokenAmount, "not approved");
        uint256 resultAmount;
        if(mapAllLiquidityCoin[tokenAddress].exists) {
            resultAmount = _swapTokenToCoin(tokenAddress, tokenAmount);
        } else {
            (bool hasBridge, address bridgeAddress, bytes32 hash) = _findBestBridgeOfToken2Coin(tokenAddress, tokenAmount);
            if(hasBridge) {
                uint256 bridgeAmount = _swapToken(hash, tokenAddress, tokenAmount, bridgeAddress);
                resultAmount = _swapTokenToCoin(bridgeAddress, bridgeAmount);
            }
        }
        require(resultAmount > 0, "lq not exists");
        require(ERC20(tokenAddress).transferFrom(msg.sender, address(this), tokenAmount), "swap error1");
        (bool sent, ) = msg.sender.call{value: resultAmount}("");
        require(sent, "swap error2");
    }

    function swapCoinToToken(address tokenAddress) external lock payable {
        require(msg.sender.balance >= msg.value, "insufficient balance");
        uint256 resultAmount;
        if(mapAllLiquidityCoin[tokenAddress].exists) {
            resultAmount = _swapCoinToToken(msg.value, tokenAddress);
        } else {
            (bool hasBridge, address bridgeAddress, bytes32 hash) = _findBestBridgeOfCoin2Token(msg.value, tokenAddress);
            if(hasBridge) {
                uint256 bridgeAmount = _swapCoinToToken(msg.value, bridgeAddress);
                resultAmount = _swapToken(hash, bridgeAddress, bridgeAmount, tokenAddress);
            }
        }
        require(resultAmount > 0, "lq not exists");
        require(ERC20(tokenAddress).transfer(msg.sender, resultAmount), "swap error");
    }

    function _swapToken(bytes32 hash, address fromTokenAddress, uint256 fromTokenAmount, address toTokenAddress) internal returns (uint256 resultAmount) {
        LiquidityTokenData storage ltd = mapAllLiquidityToken[hash];
        require(ltd.exists, "lq not exists");
        require(fromTokenAddress == ltd.tokenAddress1 && toTokenAddress == ltd.tokenAddress2, "pair order error");
        uint256 distributedAmount = _distributeFee(hash, fromTokenAddress, fromTokenAmount);
        uint256 actualFromTokenAmount = fromTokenAmount - distributedAmount;
        uint256 k = ltd.amount1 * ltd.amount2;
        resultAmount = ltd.amount2 - k / (ltd.amount1 + actualFromTokenAmount);
        ltd.amount1 = ltd.amount1 + actualFromTokenAmount;
        ltd.amount2 = ltd.amount2 - resultAmount;
    }

    //swap token to coin
    function _swapTokenToCoin(address tokenAddress, uint256 tokenAmount) internal returns (uint256 resultAmount) {
        LiquidityCoinData storage lcd = mapAllLiquidityCoin[tokenAddress];
        require(lcd.exists, "lq not exists");
        require(tokenAddress == lcd.tokenAddress, "pair error");
        uint256 k = lcd.tokenAmount * lcd.coinAmount;
        resultAmount = lcd.coinAmount - k / (lcd.tokenAmount + tokenAmount);
        lcd.tokenAmount = lcd.tokenAmount + tokenAmount;
        lcd.tokenAmount = lcd.tokenAmount - resultAmount;
    }

    //swap coin to token
    function _swapCoinToToken(uint256 coinAmount, address toTokenAddress) internal returns (uint256 resultAmount) {
        LiquidityCoinData storage lcd = mapAllLiquidityCoin[toTokenAddress];
        require(lcd.exists, "lq not exists");
        require(toTokenAddress == lcd.tokenAddress, "pair error");
        uint256 k = lcd.tokenAmount * lcd.coinAmount;
        resultAmount = lcd.tokenAmount - k / (lcd.coinAmount + coinAmount);
        lcd.coinAmount = lcd.coinAmount + coinAmount;
        lcd.tokenAmount = lcd.tokenAmount - resultAmount;
    }

    function _distributeFee(bytes32 hash, address fromTokenAddress, uint256 fromTokenAmount) internal returns(uint256 distributedAmount) {
        uint256 providerNumber = mapProviderTokenNumber[hash];
        for(uint256 i = 1; i <= providerNumber; ++i) {
            ProviderAllTokenData storage patd = mapProviderAllToken[hash][i];
            uint256 fee = fromTokenAmount * patd.percent / ERC20(fromTokenAddress).decimals();
            patd.fee1Total += fee;
            distributedAmount += fee;
        }
    }

    function _isTokenPairExists(address tokenAddress1, address tokenAddress2) internal view returns (bool res, bytes32 hash) {
        bytes32 hashTemp = keccak256(abi.encodePacked(tokenAddress1, tokenAddress2));
        if(mapAllLiquidityToken[hash].exists) {
            res = true;
            hash = hashTemp;
        } else {
            hashTemp = keccak256(abi.encodePacked(tokenAddress2, tokenAddress1));
            if(mapAllLiquidityToken[hash].exists) {
                res = true;
                hash = hashTemp;
            }
        }
    }

    function _isCoinPairExists(address tokenAddress) internal view returns (bool res) {
        if(mapAllLiquidityCoin[tokenAddress].exists) {
            res = true;
        }
    }

    function _findBestBridgeOfToken(address fromTokenAddress, uint256 fromAmount, address toTokenAddress) internal view returns (bool res, uint8 nType, address bridgeAddress, bytes32 hash1, bytes32 hash2) {
        for(uint32 i = 1; i <= mapTokenNeighborNumber[fromTokenAddress]; ++i) {
            uint256 bestAmount = 0;
            if(mapTokenNeighbor[fromTokenAddress][i].exists) {
                bool ok = false;
                uint8 nTypeNeighbor = mapTokenNeighbor[fromTokenAddress][i].nType;
                if(nTypeNeighbor == 1) {
                    hash1 = mapTokenNeighbor[fromTokenAddress][i].hash;
                    (ok, hash2) = _isTokenPairExists(mapTokenNeighbor[fromTokenAddress][i].neighbor, toTokenAddress);
                } else if(nTypeNeighbor == 2) {
                    ok = _isCoinPairExists(mapTokenNeighbor[fromTokenAddress][i].neighbor);
                }

                if(ok) {
                    uint256 neighborAmount;
                    uint256 toAmount;
                    bridgeAddress = mapTokenNeighbor[fromTokenAddress][i].neighbor;
                    if(nTypeNeighbor == 1) {
                        neighborAmount = _estimateTokenSwapResult(fromTokenAddress, fromAmount, bridgeAddress);
                        toAmount = _estimateTokenSwapResult(bridgeAddress, neighborAmount, toTokenAddress);
                    } else if(nTypeNeighbor == 2) {
                        neighborAmount = _estimateTokenSwap2CoinResult(fromTokenAddress, fromAmount);
                        toAmount = _estimateCoinSwap2TokenResult(neighborAmount, toTokenAddress);
                    }
                    if(toAmount > bestAmount) {
                        bestAmount = toAmount;
                    }
                    res = true;
                    nType = mapTokenNeighbor[fromTokenAddress][i].nType;
                }
            }
        }
    }

    //find best routine for swapping from `fromTokenAddress` to coin, the routine bridge should be a token
    function _findBestBridgeOfToken2Coin(address fromTokenAddress, uint256 fromAmount) internal view returns (bool res, address bridgeAddress, bytes32 hash) {
        for(uint32 i = 1; i <= mapTokenNeighborNumber[fromTokenAddress]; ++i) {
            uint256 bestAmount = 0;
            if(mapTokenNeighbor[fromTokenAddress][i].exists && mapTokenNeighbor[fromTokenAddress][i].nType == 1) {
                bool ok = _isCoinPairExists(mapTokenNeighbor[fromTokenAddress][i].neighbor);
                if(ok) {
                    hash = mapTokenNeighbor[fromTokenAddress][i].hash;
                    bridgeAddress = mapTokenNeighbor[fromTokenAddress][i].neighbor;
                    uint256 neighborAmount = _estimateTokenSwapResult(fromTokenAddress, fromAmount, bridgeAddress);
                    uint256 toAmount = _estimateTokenSwap2CoinResult(bridgeAddress, neighborAmount);
                    if(toAmount > bestAmount) {
                        bestAmount = toAmount;
                    }
                    res = true;
                }
            }
        }
    }

    function _findBestBridgeOfCoin2Token(uint256 fromAmount, address toTokenAddress) internal view returns (bool res, address bridgeAddress, bytes32 hash) {
        for(uint32 i = 1; i <= mapTokenNeighborNumber[toTokenAddress]; ++i) {
            uint256 bestAmount = 0;
            if(mapTokenNeighbor[toTokenAddress][i].exists && mapTokenNeighbor[toTokenAddress][i].nType == 1) {
                bool ok = _isCoinPairExists(mapTokenNeighbor[toTokenAddress][i].neighbor);
                if(ok) {
                    hash = mapTokenNeighbor[toTokenAddress][i].hash;
                    bridgeAddress = mapTokenNeighbor[toTokenAddress][i].neighbor;
                    uint256 neighborAmount = _estimateCoinSwap2TokenResult(fromAmount, bridgeAddress);
                    uint256 toAmount = _estimateTokenSwapResult(bridgeAddress, neighborAmount, toTokenAddress);
                    if(toAmount > bestAmount) {
                        bestAmount = toAmount;
                    }
                    res = true;
                }
            }
        }
    }

    function estimateTokenSwapResult(address fromTokenAddress, uint256 fromAmount, address toTokenAddress) external view returns (uint256 resultAmount) {
        resultAmount = _estimateTokenSwapResult(fromTokenAddress, fromAmount, toTokenAddress);
    }

    function _estimateTokenSwapResult(address fromTokenAddress, uint256 fromAmount, address toTokenAddress) internal view returns (uint256 resultAmount) {
        (bool resHash, bytes32 hash) = _isTokenPairExists(fromTokenAddress, toTokenAddress);
        require(resHash, "lq not exists");
        LiquidityTokenData memory ltd = mapAllLiquidityToken[hash];
        require(fromTokenAddress == ltd.tokenAddress1 && toTokenAddress == ltd.tokenAddress2, "pair order error");
        uint256 k = ltd.amount1 * ltd.amount2;
        resultAmount = ltd.amount2 - k / (ltd.amount1 + fromAmount);
    }

    function estimateTokenSwap2CoinResult(address fromTokenAddress, uint256 fromAmount) external view returns (uint256 resultAmount) {
        resultAmount = _estimateTokenSwap2CoinResult(fromTokenAddress, fromAmount);
    }

    function _estimateTokenSwap2CoinResult(address fromTokenAddress, uint256 fromAmount) internal view returns (uint256 resultAmount) {
        require(_isCoinPairExists(fromTokenAddress), "lq not exists");
        LiquidityCoinData memory lcd = mapAllLiquidityCoin[fromTokenAddress];
        require(fromTokenAddress == lcd.tokenAddress, "pair error");
        uint256 k = lcd.tokenAmount * lcd.coinAmount;
        resultAmount = lcd.coinAmount - k / (lcd.tokenAmount + fromAmount);
    }

    function estimateCoinSwap2TokenResult(uint256 fromAmount, address toTokenAddress) internal view returns (uint256 resultAmount) {
        resultAmount = _estimateCoinSwap2TokenResult(fromAmount, toTokenAddress);
    }

    function _estimateCoinSwap2TokenResult(uint256 fromAmount, address toTokenAddress) internal view returns (uint256 resultAmount) {
        require(_isCoinPairExists(toTokenAddress), "lq not exists");
        LiquidityCoinData memory lcd = mapAllLiquidityCoin[toTokenAddress];
        require(toTokenAddress == lcd.tokenAddress, "pair error");
        uint256 k = lcd.tokenAmount * lcd.coinAmount;
        resultAmount = lcd.tokenAmount - k / (lcd.coinAmount + fromAmount);
    }
}