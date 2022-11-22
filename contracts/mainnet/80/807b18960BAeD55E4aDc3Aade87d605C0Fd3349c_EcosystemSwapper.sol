//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "./IUniswapV2Router02.sol";
import "./IERC20.sol";
import "./Ownable.sol";

interface IStable {
    function sell(uint256 tokenAmount) external returns (uint256);
    function mintWithBacking(uint256 numTokens, address recipient) external returns (uint256);
    function burn(uint256 amount) external;
}

interface IToken {
    function buyFee() external view returns (uint256);
    function sellFee() external view returns (uint256);
    function buyFeeRecipient() external view returns (address);
    function sellFeeRecipient() external view returns (address);
}

interface IInfinity {
    function buy(address recipient) external payable;
    function sell(uint256 amount) external returns (bool);
}

contract EcosystemSwapper is Ownable {

    // Pancake Router
    IUniswapV2Router02 public constant router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);

    // Normal Tokens
    address public constant MDB = 0x0557a288A93ed0DF218785F2787dac1cd077F8f3;
    address public constant INFINITY = 0xaCC966B91100f879C9eD4839ed2F77c70E3E97eD;
    address public constant BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;

    // Stable Tokens
    address public constant MDBP = 0x9f8BB16f49393eeA4331A39B69071759e54e16ea;
    address public constant PHOENIX = 0xfc62b18CAC1343bd839CcbEDB9FC3382a84219B9;

    // Stable Fees
    uint256 public constant MDBPBuyFee = 75;
    uint256 public constant MDBPSellFee = 25;
    uint256 public constant PHOENIXFee = 200;
    
    uint256 private constant FEE_DENOM = 10**4;

    function swap(address fromToken, address toToken, uint256 amount) external payable {

        // check if ETH
        bool isETH = fromToken == address(0);
        uint256 bal = isETH ? address(this).balance : _transferIn(fromToken, amount);

        // process Txs with ETH as the fromToken
        if (isETH) {

            _bnbToToken(toToken, amount);

        } else {

            // BUSD -> toToken
            if (fromToken == BUSD) {

                if (isStable(toToken)) {
                    _mintStable(toToken, bal);
                } else {

                    // BUSD -> BNB
                    _tokenToBnb(BUSD);

                    // BNB -> Token
                    _bnbToToken(toToken, address(this).balance);
                    
                }

            } else if (fromToken == MDB) {
                
                // MDB -> BNB
                _tokenToBnb(MDB);

                // BNB -> Asset
                _bnbToToken(toToken, address(this).balance);

            } else if (fromToken == INFINITY) {

                if (toToken == PHOENIX) {
                    _tokenToToken(fromToken, toToken);
                } else {
                    _tokenToBnb(fromToken);
                    _bnbToToken(toToken, address(this).balance);
                }

            } else if (fromToken == PHOENIX) {

                if (toToken == INFINITY) {
                    _tokenToToken(fromToken, toToken);
                } else if (toToken == BUSD) {
                    _sellStable(fromToken);
                } else {
                    _sellStable(fromToken);
                    _tokenToBnb(BUSD);
                    _bnbToToken(toToken, address(this).balance);
                }

            } else if (fromToken == MDBP) {

                if (toToken == MDB) {
                    _tokenToToken(fromToken, toToken);
                } else if (toToken == BUSD) {
                    _sellStable(fromToken);
                } else {
                    _sellStable(fromToken);
                    _tokenToBnb(BUSD);
                    _bnbToToken(toToken, address(this).balance);
                }


            } else {

                _tokenToBnb(fromToken);
                _bnbToToken(toToken, address(this).balance);

            }

        }

        if (toToken == address(0)) {
            (bool s,) = payable(msg.sender).call{value: address(this).balance}("");
            require(s);
        } else {
            uint256 endBalance = IERC20(toToken).balanceOf(address(this));
            if (endBalance > 0) {
                IERC20(toToken).transfer(msg.sender, endBalance);
            }
        }
    }

    function _tokenToBnb(address token) internal {

        _processFee(token, false);

        uint256 amount = IERC20(token).balanceOf(address(this));

        if (token == INFINITY) {
            IInfinity(INFINITY).sell(amount);
        } else {

            IERC20(token).approve(address(router), amount);

            address[] memory path = new address[](2);
            path[0] = token;
            path[1] = router.WETH();

            router.swapExactTokensForETHSupportingFeeOnTransferTokens(amount, 1, path, address(this), block.timestamp + 100);
        }
    }

    function _bnbToToken(address token, uint amount) internal {

        if (token == address(0)) {
            return;
        }

        if (isStable(token)) {
            _bnbToStable(token, amount);
            return;
        }

        if (token == INFINITY) {

            IInfinity(token).buy{value: amount}(address(this));

        } else {

            address[] memory path = new address[](2);
            path[0] = router.WETH();
            path[1] = token;

            router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amount}(1, path, address(this), block.timestamp + 100);
            delete path;
        }

        _processFee(token, true);
    }

    function _bnbToStable(address token, uint amount) internal {

        (bool s,) = payable(token).call{value: amount}("");
        require(s);

        _processFee(token, true);
    }

    function _sellStable(address token) internal {

        _processFee(token, false);
        IStable(token).sell(IERC20(token).balanceOf(address(this)));
    }

    function _mintStable(address token, uint256 amount) internal {

        IERC20(BUSD).approve(token, amount);
        IStable(token).mintWithBacking(amount, address(this));

        _processFee(token, true);
    }

    function _tokenToToken(address fromToken, address toToken) internal {
        
        // process sell fee
        _processFee(fromToken, false);

        // fetch new sell amount
        uint256 amount = IERC20(fromToken).balanceOf(address(this));

        // approve router
        IERC20(fromToken).approve(address(router), amount);

        // build path
        address[] memory path = new address[](2);
        path[0] = fromToken;
        path[1] = toToken;

        // make swap
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(amount, 1, path, address(this), block.timestamp + 100);

        // clear memory
        delete path;

        // process buy fee
        _processFee(toToken, true);
    }

    function isStable(address token) public pure returns (bool) {
        return token == MDBP || token == PHOENIX;
    }

    function _transferIn(address token, uint256 amount) internal returns (uint256) {
        require(
            IERC20(token).allowance(msg.sender, address(this)) >= amount,
            'Insufficient Allowance'
        );
        require(
            IERC20(token).transferFrom(msg.sender, address(this), amount),
            'ERR Transfer From'
        );
        uint256 balance = IERC20(token).balanceOf(address(this));
        require(balance > 0, 'Zero Balance');
        return balance;
    }

    function _processFee(address token, bool isBuy) internal {

        if (token == MDB || token == INFINITY) {

            uint256 fee = isBuy ? IToken(token).buyFee() : IToken(token).sellFee();
            address recipient = isBuy ? IToken(token).buyFeeRecipient() : IToken(token).sellFeeRecipient();

            uint256 balance = IERC20(token).balanceOf(address(this));

            if (balance > FEE_DENOM) {
                IERC20(token).transfer(
                    recipient, 
                    ( balance * fee ) / FEE_DENOM
                );
            }

        } else if (token == MDBP || token == PHOENIX) {

            uint256 fee = token == MDBP ? isBuy ? MDBPBuyFee : MDBPSellFee : PHOENIXFee;
            uint256 balance = IERC20(token).balanceOf(address(this));

            if (balance > FEE_DENOM) {
                IStable(token).burn(
                    ( balance * fee ) / FEE_DENOM
                );
            }
            
        }

    }


    receive() external payable {}
}