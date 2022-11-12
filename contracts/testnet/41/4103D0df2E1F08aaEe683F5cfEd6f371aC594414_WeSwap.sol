// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./SafeMath.sol";
import "./Strings.sol";
import "./Ownable.sol";
import "./Lockable.sol";
import "./IERC20.sol";
import "./IERC20Metadata.sol";
import "./WeSwapData.sol";

contract WeSwap is Ownable, Lockable {
    event liquidityTokenAdded(
        address account,
        address tokenAddress1,
        uint256 amount1,
        address tokenAddress2,
        uint256 amount2,
        uint256 time
    );
    event liquidityCoinAdded(
        address account,
        address tokenAddress,
        uint256 tokenAmount,
        uint256 coinAmount,
        uint256 time
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

    receive() external payable {}

    fallback() external payable {}

    WeSwapData internal wsData;

    constructor(address _data) {
        wsData = WeSwapData(_data);
    }

    function setData(address _data) external onlyOwner {
        wsData = WeSwapData(_data);
    }

    function getData() external view returns (address res) {
        res = address(wsData);
    }

    //add liquidity pair of tokens to pool
    //添加流动性之后，保持价格不变
    function addLiquidityToken(
        address tokenAddress1,
        uint256 amount1,
        address tokenAddress2,
        uint256 amount2
    ) external lock {
        require(
            amount1 > 0 && amount2 > 0,
            "input amount must be greater than 0"
        );
        (
            bool exists,
            bytes32 hash,
            uint256 addAmount1,
            uint256 addAmount2
        ) = wsData.getAddedTokenPairAmount(
                tokenAddress1,
                amount1,
                tokenAddress2,
                amount2
            );

        require(
            IERC20(tokenAddress1).balanceOf(msg.sender) >= addAmount1,
            "insufficient balance of token1"
        );
        require(
            IERC20(tokenAddress1).allowance(msg.sender, address(this)) >=
                addAmount1,
            "not allowed token1"
        );

        require(
            IERC20(tokenAddress2).balanceOf(msg.sender) >= addAmount2,
            "insufficient balance of token2"
        );
        require(
            IERC20(tokenAddress2).allowance(msg.sender, address(this)) >=
                addAmount2,
            "not allowed token2"
        );

        wsData.addLiquidityToken(
            msg.sender,
            exists,
            hash,
            tokenAddress1,
            amount1,
            addAmount1,
            tokenAddress2,
            amount2,
            addAmount2
        );

        require(
            IERC20(tokenAddress1).transferFrom(
                msg.sender,
                address(this),
                addAmount1
            ),
            "transfer tokenAddress1 to contract error"
        );
        require(
            IERC20(tokenAddress2).transferFrom(
                msg.sender,
                address(this),
                addAmount2
            ),
            "transfer tokenAddress2 to contract error"
        );

        emit liquidityTokenAdded(
            msg.sender,
            tokenAddress1,
            addAmount1,
            tokenAddress2,
            addAmount2,
            block.timestamp
        );

        (
            address _tokenAddress1,
            uint256 _amount1,
            address _tokenAddress2,
            uint256 _amount2
        ) = wsData.getTokenPairLiquidity(hash);
        emit tokenLiquidVol(
            _tokenAddress1,
            _amount1,
            _tokenAddress2,
            _amount2,
            block.timestamp
        );
    }

    //add liquidity pair of token and coin to pool
    function addLiquidityCoin(address tokenAddress, uint256 tokenAmount)
        external
        payable
        lock
    {
        uint256 coinAmount = msg.value;
        require(
            tokenAmount > 0 && coinAmount > 0,
            "input amount must be greater than 0"
        );

        (bool exists, uint256 addAmountToken, uint256 addAmountCoin) = wsData
            .getAddedCoinPairAmount(coinAmount, tokenAddress, tokenAmount);

        require(
            IERC20Metadata(tokenAddress).balanceOf(msg.sender) >=
                addAmountToken,
            "insufficient balance of token"
        );
        require(
            IERC20(tokenAddress).allowance(msg.sender, address(this)) >=
                addAmountToken,
            "not allowed token"
        );
        require(
            msg.sender.balance >= addAmountCoin,
            "insufficient coin amount"
        );

        wsData.addLiquidityCoin(
            msg.sender,
            exists,
            tokenAddress,
            tokenAmount,
            addAmountToken,
            addAmountCoin
        );

        require(
            IERC20(tokenAddress).transferFrom(
                msg.sender,
                address(this),
                addAmountToken
            ),
            "transfer tokenAddress to contract error"
        );

        emit liquidityCoinAdded(
            msg.sender,
            tokenAddress,
            addAmountToken,
            addAmountCoin,
            block.timestamp
        );
        (bool _res, uint256 _tokenAmount, uint256 _cointAmount) = wsData
            .getCoinPairLiquidityData(tokenAddress);
        require(_res, "error 202");
        emit tokenCoinLiquidVol(
            tokenAddress,
            _tokenAmount,
            _cointAmount,
            block.timestamp
        );
    }

    //swap `fromTokenAddress` to `toTokenAddress` with base `fromTokenAmount`
    function swapToken(
        address fromTokenAddress,
        uint256 fromTokenAmount,
        address toTokenAddress
    ) external lock {
        require(
            IERC20(fromTokenAddress).balanceOf(msg.sender) >= fromTokenAmount,
            "insufficient balance"
        );
        require(
            IERC20(fromTokenAddress).allowance(msg.sender, address(this)) >=
                fromTokenAmount,
            "not approved"
        );
        uint256 resultAmount = 0;
        uint256 bridgeAmount = 0;
        bool ok = false;
        (bool exists, bytes32 hash) = wsData.isTokenPairExists(
            fromTokenAddress,
            toTokenAddress
        );
        if (exists) {
            resultAmount = wsData.swapToken(
                hash,
                fromTokenAddress,
                fromTokenAmount,
                toTokenAddress
            );
            ok = true;
        } else {
            (
                bool hasBridge,
                uint8 nType,
                address bridgeAddress,
                bytes32 hash1,
                bytes32 hash2
            ) = wsData.findBestBridgeOfToken(
                    fromTokenAddress,
                    fromTokenAmount,
                    toTokenAddress
                );
            if (hasBridge) {
                if (nType == 1) {
                    bridgeAmount = wsData.swapToken(
                        hash1,
                        fromTokenAddress,
                        fromTokenAmount,
                        bridgeAddress
                    );
                    resultAmount = wsData.swapToken(
                        hash2,
                        bridgeAddress,
                        bridgeAmount,
                        toTokenAddress
                    );
                    ok = true;
                } else if (nType == 2) {
                    bridgeAmount = wsData.swapTokenToCoin(
                        fromTokenAddress,
                        fromTokenAmount
                    );
                    resultAmount = wsData.swapCoinToToken(
                        bridgeAmount,
                        toTokenAddress
                    );
                    ok = true;
                }
            }
        }
        require(ok && resultAmount > 0, "can't swap");
        require(
            IERC20(fromTokenAddress).transferFrom(
                msg.sender,
                address(this),
                fromTokenAmount
            ),
            "swap error1"
        );
        require(
            IERC20(toTokenAddress).transfer(msg.sender, resultAmount),
            "swap error2"
        );
    }

    function swapTokenToCoin(address tokenAddress, uint256 tokenAmount)
        external
        lock
    {
        require(
            IERC20(tokenAddress).balanceOf(msg.sender) >= tokenAmount,
            "insufficient balance"
        );
        require(
            IERC20(tokenAddress).allowance(msg.sender, address(this)) >=
                tokenAmount,
            "not approved"
        );
        uint256 resultAmount;
        if (wsData.isCoinPairExists(tokenAddress)) {
            resultAmount = wsData.swapTokenToCoin(tokenAddress, tokenAmount);
        } else {
            (bool hasBridge, address bridgeAddress, bytes32 hash) = wsData
                .findBestBridgeOfToken2Coin(tokenAddress, tokenAmount);
            if (hasBridge) {
                uint256 bridgeAmount = wsData.swapToken(
                    hash,
                    tokenAddress,
                    tokenAmount,
                    bridgeAddress
                );
                resultAmount = wsData.swapTokenToCoin(
                    bridgeAddress,
                    bridgeAmount
                );
            }
        }
        require(resultAmount > 0, "lq not exists");
        require(
            IERC20(tokenAddress).transferFrom(
                msg.sender,
                address(this),
                tokenAmount
            ),
            "swap error1"
        );
        (bool sent, ) = msg.sender.call{value: resultAmount}("");
        require(sent, "swap error2");
    }

    function swapCoinToToken(address tokenAddress) external payable lock {
        require(msg.sender.balance >= msg.value, "insufficient balance");
        uint256 resultAmount;
        if (wsData.isCoinPairExists(tokenAddress)) {
            resultAmount = wsData.swapCoinToToken(msg.value, tokenAddress);
        } else {
            (bool hasBridge, address bridgeAddress, bytes32 hash) = wsData
                .findBestBridgeOfCoin2Token(msg.value, tokenAddress);
            if (hasBridge) {
                uint256 bridgeAmount = wsData.swapCoinToToken(
                    msg.value,
                    bridgeAddress
                );
                resultAmount = wsData.swapToken(
                    hash,
                    bridgeAddress,
                    bridgeAmount,
                    tokenAddress
                );
            }
        }
        require(resultAmount > 0, "lq not exists");
        require(
            IERC20(tokenAddress).transfer(msg.sender, resultAmount),
            "swap error"
        );
    }

    //user liquidity process
    function claimFeeFromTokenLiquidity(
        address tokenAddress1,
        uint256 amount1,
        address tokenAddress2,
        uint256 amount2
    ) external lock {
        _claimFeeFromTokenLiquidity(
            msg.sender,
            tokenAddress1,
            amount1,
            tokenAddress2,
            amount2
        );
    }

    function _claimFeeFromTokenLiquidity(
        address account,
        address tokenAddress1,
        uint256 amount1,
        address tokenAddress2,
        uint256 amount2
    ) internal {
        bytes32 hash = keccak256(
            abi.encodePacked(
                Strings.addressToString(tokenAddress1),
                Strings.addressToString(tokenAddress2)
            )
        );
        uint256 index = wsData.getUserTokenPairIndex(hash, account);
        require(index > 0, "u dont supply this token pair");

        (
            bool _res,
            ,
            ,
            ,
            uint256 _fee1Total,
            uint256 _fee1Claimed,
            uint256 _fee2Total,
            uint256 _fee2Claimed
        ) = wsData.getUserLiquidityToken(account, index);

        require(_res, "u dont supply this token pair 2");

        (, address _tokenAddress1, address _tokenAddress2, , ) = wsData
            .getTokenPairLiquidityData(hash);

        require(
            _fee1Total >= SafeMath.add(_fee1Claimed, amount1) ||
                _fee2Total >= SafeMath.add(_fee2Claimed, amount2),
            "no fee amount to claimed"
        );
        if (amount1 > 0 && _fee1Total >= SafeMath.add(_fee1Claimed, amount1)) {
            require(
                IERC20(_tokenAddress1).balanceOf(address(this)) >=
                    SafeMath.sub(
                        _fee1Total,
                        SafeMath.add(_fee1Claimed, amount1)
                    ),
                "insufficient balance in found"
            );
            wsData.claimTokenPairFee(hash, index, amount1, 1);
            require(
                IERC20(_tokenAddress1).transfer(account, amount1),
                "claimFeeFromTokenLiquidity ERROR 1"
            );
        }

        if (amount2 > 0 && _fee2Total >= SafeMath.add(_fee2Claimed, amount2)) {
            require(
                IERC20(_tokenAddress2).balanceOf(address(this)) >=
                    SafeMath.sub(
                        _fee2Total,
                        SafeMath.add(_fee2Claimed, amount2)
                    ),
                "insufficient balance in found"
            );
            wsData.claimTokenPairFee(hash, index, amount2, 2);
            require(
                IERC20(_tokenAddress2).transfer(account, amount2),
                "claimFeeFromTokenLiquidity ERROR 2"
            );
        }
    }

    function claimFeeFromCoinLiquidity(
        address tokenAddress,
        uint256 tokenAmount,
        uint256 coinAmount
    ) external lock {
        _claimFeeFromCoinLiquidity(
            msg.sender,
            tokenAddress,
            tokenAmount,
            coinAmount
        );
    }

    function _claimFeeFromCoinLiquidity(
        address account,
        address tokenAddress,
        uint256 tokenAmount,
        uint256 coinAmount
    ) internal {
        uint256 index = wsData.getUserCoinPairIndex(tokenAddress, account);
        require(index > 0, "u dont supply this coin-token pair liquidity");

        (
            bool _res,
            ,
            ,
            ,
            uint256 _feeTokenTotal,
            uint256 _feeTokenClaimed,
            uint256 _feeCoinTotal,
            uint256 _feeCoinClaimed
        ) = wsData.getUserLiquidityCoin(account, tokenAddress);

        require(_res, "u dont supply this coin-token pair liquidity 2");
        require(
            _feeTokenTotal >= _feeTokenClaimed ||
                _feeCoinTotal >= _feeCoinClaimed,
            "have no fee to claim"
        );
        if (tokenAmount > 0 && _feeTokenTotal > _feeTokenClaimed) {
            require(
                _feeTokenTotal >= SafeMath.add(_feeTokenClaimed, tokenAmount),
                "insufficient token fee to claim"
            );
            require(
                IERC20(tokenAddress).balanceOf(address(this)) >= tokenAmount,
                "insufficient balance in found"
            );
            wsData.claimCoinPairFee(tokenAddress, index, tokenAmount, 1);
            require(
                IERC20(tokenAddress).transfer(account, tokenAmount),
                "claimFeeFromCoinLiquidity ERROR 1"
            );
        }

        if (coinAmount > 0 && _feeCoinTotal > _feeCoinClaimed) {
            require(
                _feeCoinTotal >= SafeMath.add(_feeCoinClaimed, coinAmount),
                "insufficient token fee to claim"
            );
            require(
                address(this).balance >= coinAmount,
                "insufficient coin fee to claim"
            );
            wsData.claimCoinPairFee(tokenAddress, index, coinAmount, 2);
            (bool sent, ) = account.call{value: coinAmount}("");
            require(sent, "claimFeeFromCoinLiquidity ERROR 2");
        }
    }

    function withdrawLiquidityToken(
        address tokenAddress1,
        address tokenAddress2
    ) external lock {
        _withdrawLiquidityToken(msg.sender, tokenAddress1, tokenAddress2);
    }

    function _withdrawLiquidityToken(
        address account,
        address tokenAddress1,
        address tokenAddress2
    ) internal {
        bytes32 hash = keccak256(
            abi.encodePacked(
                Strings.addressToString(tokenAddress1),
                Strings.addressToString(tokenAddress2)
            )
        );
        // uint256 index = mapProviderTokenIndex[hash][account];
        require(
            wsData.getUserTokenPairIndex(hash, account) > 0,
            "u dont supply this token pair"
        );

        (
            bool _res,
            uint256 _percent,
            ,
            ,
            uint256 _fee1Total,
            uint256 _fee1Claimed,
            uint256 _fee2Total,
            uint256 _fee2Claimed
        ) = wsData.getUserLiquidityToken(
                account,
                wsData.getUserTokenPairIndex(hash, account)
            );

        require(_res, "u dont supply this token pair 2");
        // ProviderAllTokenData memory patd = mapProviderAllToken[hash][index];

        (
            ,
            address _tokenAddress1,
            address _tokenAddress2,
            uint256 _amount1,
            uint256 _amount2
        ) = wsData.getTokenPairLiquidityData(hash);

        //withdraw fee
        _claimFeeFromTokenLiquidity(
            account,
            tokenAddress1,
            SafeMath.sub(_fee1Total, _fee1Claimed),
            tokenAddress2,
            SafeMath.sub(_fee2Total, _fee2Claimed)
        );
        //withdraw fund
        //withdraw amount1
        // uint256 withdrawAmount1 = SafeMath.div(SafeMath.mul(_amount1, _percent),
        // (10**IERC20Metadata(_tokenAddress1).decimals()));
        require(
            IERC20(_tokenAddress1).balanceOf(address(this)) >=
                SafeMath.div(
                    SafeMath.mul(_amount1, _percent),
                    (10**IERC20Metadata(_tokenAddress1).decimals())
                ),
            "insufficient fund 1"
        );

        //withdraw amount2
        // uint256 withdrawAmount2 = SafeMath.div(SafeMath.mul(_amount2, _percent),
        // (10**IERC20Metadata(_tokenAddress2).decimals()));
        require(
            IERC20(_tokenAddress2).balanceOf(address(this)) >=
                SafeMath.div(
                    SafeMath.mul(_amount2, _percent),
                    (10**IERC20Metadata(_tokenAddress2).decimals())
                ),
            "insufficient fund 2"
        );

        //sub total amount
        wsData.subTokenPairLiquidity(
            hash,
            SafeMath.div(
                SafeMath.mul(_amount1, _percent),
                (10**IERC20Metadata(_tokenAddress1).decimals())
            ),
            1
        );
        wsData.subTokenPairLiquidity(
            hash,
            SafeMath.div(
                SafeMath.mul(_amount2, _percent),
                (10**IERC20Metadata(_tokenAddress2).decimals())
            ),
            2
        );

        //update percent
        wsData.subPercentTokenPairLiquidity(
            account,
            hash,
            _tokenAddress1,
            _percent
        );

        require(
            IERC20(_tokenAddress1).transfer(
                account,
                SafeMath.div(
                    SafeMath.mul(_amount1, _percent),
                    (10**IERC20Metadata(_tokenAddress1).decimals())
                )
            ),
            "withdrawLiquidityToken error 1"
        );
        require(
            IERC20(_tokenAddress2).transfer(
                account,
                SafeMath.div(
                    SafeMath.mul(_amount2, _percent),
                    (10**IERC20Metadata(_tokenAddress2).decimals())
                )
            ),
            "withdrawLiquidityToken error 2"
        );
    }

    function withdrawLiquidityCoin(address tokenAddress) external lock {
        _withdrawLiquidityCoin(msg.sender, tokenAddress);
    }

    function _withdrawLiquidityCoin(address account, address tokenAddress)
        internal
    {
        uint256 index = wsData.getUserCoinPairIndex(tokenAddress, account); // mapProviderCoinIndex[tokenAddress][account];
        require(index > 0, "u dont supply this coin-token pair liquidity");

        (
            bool _res,
            ,
            ,
            uint256 _percent,
            uint256 _feeTokenTotal,
            uint256 _feeTokenClaimed,
            uint256 _feeCoinTotal,
            uint256 _feeCoinClaimed
        ) = wsData.getUserLiquidityCoin(account, tokenAddress);

        require(_res, "u dont supply this coin-token pair liquidity 2");

        (
            bool _resTotal,
            uint256 _totalTokenAmount,
            uint256 _totalCointAmount
        ) = wsData.getCoinPairLiquidityData(tokenAddress);
        require(_resTotal, "coin pair liquidity not exists");

        // ProviderAllCoinData memory pacd = mapProviderAllCoin[tokenAddress][index];
        //withdraw fee
        _claimFeeFromCoinLiquidity(
            account,
            tokenAddress,
            SafeMath.sub(_feeTokenTotal, _feeTokenClaimed),
            SafeMath.sub(_feeCoinTotal, _feeCoinClaimed)
        );

        //withdraw fund
        //withdraw tokenAmount
        // uint256 tokenAmount = SafeMath.div(SafeMath.mul(_totalTokenAmount, _percent),
        //                         (10**IERC20Metadata(tokenAddress).decimals()));
        require(
            IERC20(tokenAddress).balanceOf(address(this)) >=
                SafeMath.div(
                    SafeMath.mul(_totalTokenAmount, _percent),
                    (10**IERC20Metadata(tokenAddress).decimals())
                ),
            "insufficient fund 1"
        );

        //withdraw coinAmount
        // uint256 coinAmount = SafeMath.div(SafeMath.mul(_totalCointAmount, _percent),
        //                         (10**18));
        require(
            address(this).balance >=
                SafeMath.div(
                    SafeMath.mul(_totalCointAmount, _percent),
                    (10**18)
                ),
            "insufficient fund 2"
        );

        //sub total amount
        wsData.subCoinPairLiquidity(
            tokenAddress,
            SafeMath.div(
                SafeMath.mul(_totalTokenAmount, _percent),
                (10**IERC20Metadata(tokenAddress).decimals())
            ),
            1
        );
        wsData.subCoinPairLiquidity(
            tokenAddress,
            SafeMath.div(SafeMath.mul(_totalCointAmount, _percent), (10**18)),
            2
        );

        //update percent
        wsData.subPercentCoinPairLiquidity(account, tokenAddress, _percent);

        require(
            IERC20(tokenAddress).transfer(
                account,
                SafeMath.div(
                    SafeMath.mul(_totalTokenAmount, _percent),
                    (10**IERC20Metadata(tokenAddress).decimals())
                )
            ),
            "withdrawLiquidityCoin error 1"
        );
        (bool sent, ) = account.call{
            value: SafeMath.div(
                SafeMath.mul(_totalCointAmount, _percent),
                (10**18)
            )
        }("");
        require(sent, "claimFeeFromCoinLiquidity ERROR 2");
    }
}