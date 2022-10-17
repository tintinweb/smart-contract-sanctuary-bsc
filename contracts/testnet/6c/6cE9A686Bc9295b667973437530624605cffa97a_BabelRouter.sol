// SPDX-License-Identifier: MIT
// 2022 - BabelSwap Team

pragma solidity =0.6.6;

import {IBabelFactory} from '../core/interfaces/IBabelFactory.sol';
import {TransferHelper} from './lib/TransferHelper.sol';

import {IBabelRouter} from './interfaces/IBabelRouter.sol';
import {IBabelPair, BabelLibrary, SafeMath} from './lib/BabelLibrary.sol';
import {IPositionNFT} from './interfaces/IPositionNFT.sol';
import {IERC20} from './interfaces/IERC20.sol';
import {IWBNB} from './interfaces/IWBNB.sol';

contract BabelRouter is IBabelRouter {
    using SafeMath for uint;

    address public immutable override factory;
    address public immutable override WBNB;
    address public immutable forbiddenToken;
    address public admin;

    address public treasuryWallet;
    address public distributor;
    address public bBLockLiq;

    mapping(address=>bool) public sellFeeTokens;

    uint public sellNativeFee = 1500; // 15%
    uint public sellNativeLPFee = 1500; // 15%
    uint public sellNativeLPTokenFee = 500; // 5%
    uint public sellNativeLPOtherTokenFee = 400; // 4%

    IPositionNFT public nftToken;

    modifier ensure(uint deadline) {
        if (block.timestamp > deadline) revert('BabelRouter: EXPIRED');
        // require(deadline >= block.timestamp, 'BabelRouter: EXPIRED');
        _;
    }
    
    modifier onlyAdmin() {
        if (msg.sender != admin) revert('Only Admin');
        _;
    }

    constructor(address _factory, address _WBNB, address _bBLockliq, address _forbiddenToken) public {
        factory = _factory;
        WBNB = _WBNB;
        bBLockLiq = _bBLockliq;
        forbiddenToken = _forbiddenToken;
        admin = msg.sender;
    }

    receive() external payable {
        assert(msg.sender == WBNB); // only accept WBNB via fallback from the WBNB contract
    }

    function setSellFeeToken(address _token, bool _enableFee) external onlyAdmin {
        sellFeeTokens[_token] = _enableFee;
    }

    function setFees(
        uint _selNativefee, 
        uint _sellNativeLPFee, 
        uint _sellNativeLPTokenFee, uint _sellNativeLPOtherTokenFee) external onlyAdmin {

        require(_selNativefee <= 3000, 'Too much Fee');
        require(_sellNativeLPFee <= 3000, 'Too much Fee');
        require(_sellNativeLPTokenFee <= 3000, 'Too much Fee');
        require(_sellNativeLPOtherTokenFee <= 3000, 'Too much Fee');
        sellNativeFee = _selNativefee;
        sellNativeLPFee = _sellNativeLPFee;
        sellNativeLPTokenFee = _sellNativeLPTokenFee;
        sellNativeLPOtherTokenFee = _sellNativeLPOtherTokenFee;
    }

    function setTreasuryWallet(address _wallet) external onlyAdmin {
        treasuryWallet = _wallet;
    }

    function setbBLockLiq(address _bBLockLiq) external onlyAdmin {
        bBLockLiq = _bBLockLiq;
    }

    function setDistributor(address _distributor) external onlyAdmin {
        distributor = _distributor;
    }

    function setNFT(IPositionNFT _nftToken) external onlyAdmin {
        nftToken = _nftToken;
    }
    function _addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin
    ) internal virtual returns (uint amountA, uint amountB) {
        // create the pair if it doesn't exist yet
        if (IBabelFactory(factory).getPair(tokenA, tokenB) == address(0)) {
            IBabelFactory(factory).createPair(tokenA, tokenB);
        }
        (uint reserveA, uint reserveB) = BabelLibrary.getReserves(factory, tokenA, tokenB);
        if (reserveA == 0 && reserveB == 0) {
            (amountA, amountB) = (amountADesired, amountBDesired);
        } else {
            uint amountBOptimal = BabelLibrary.quote(amountADesired, reserveA, reserveB);
            if (amountBOptimal <= amountBDesired) {
                if (amountBMin > amountBOptimal) revert('BabelRouter: INSUFFICIENT_B_AMOUNT');
                // require(amountBOptimal >= amountBMin, 'BabelRouter: INSUFFICIENT_B_AMOUNT');
                (amountA, amountB) = (amountADesired, amountBOptimal);
            } else {
                uint amountAOptimal = BabelLibrary.quote(amountBDesired, reserveB, reserveA);
                assert(amountAOptimal <= amountADesired);
                if (amountAMin > amountAOptimal) revert('BabelRouter: INSUFFICIENT_A_AMOUNT');
                // require(amountAOptimal >= amountAMin, 'BabelRouter: INSUFFICIENT_A_AMOUNT');
                (amountA, amountB) = (amountAOptimal, amountBDesired);
            }
        }
    }

    function removeLiquidityNFT(address pair, uint liquidity) internal {
        uint[] memory tokenIds = nftToken.getTokenIDForLP(msg.sender, pair);        
        uint liquidityForUpdate;
        uint length = tokenIds.length;
        for(uint i; i < length; i++) {
            if(tokenIds[i] == 0) { break; }    
            if(liquidity > nftToken.tokenLiquidity(tokenIds[i])) {
                liquidityForUpdate = nftToken.tokenLiquidity(tokenIds[i]);
            } else {
                liquidityForUpdate = liquidity;
            }
            liquidity = liquidity.sub(liquidityForUpdate);
            nftToken.updateInfo(tokenIds[i], liquidity);
        }
    }

    function mintPositionNFT(address pair, address tokenA, address tokenB, uint liquidity) internal {        
        nftToken.mint(pair, tokenA, tokenB, liquidity, msg.sender);
    }

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) public virtual override ensure(deadline) returns (uint amountA, uint amountB, uint liquidity) {
        if (tokenA == forbiddenToken || tokenB == forbiddenToken) revert('Forbidden Token');
        (amountA, amountB) = _addLiquidity(tokenA, tokenB, amountADesired, amountBDesired, amountAMin, amountBMin);
        address pair = BabelLibrary.pairFor(factory, tokenA, tokenB);
        TransferHelper.safeTransferFrom(tokenA, msg.sender, pair, amountA);
        TransferHelper.safeTransferFrom(tokenB, msg.sender, pair, amountB);
        liquidity = IBabelPair(pair).mint(to);
        
        mintPositionNFT(pair, tokenA, tokenB, liquidity);
    }
    function addLiquidityBNB(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountBNBMin,
        address to,
        uint deadline
    ) external virtual override payable ensure(deadline) returns (uint amountToken, uint amountBNB, uint liquidity) {
        if (token == forbiddenToken) revert('Forbidden Token');
        (amountToken, amountBNB) = _addLiquidity(
            token,
            WBNB,
            amountTokenDesired,
            msg.value,
            amountTokenMin,
            amountBNBMin
        );
        address pair = BabelLibrary.pairFor(factory, token, WBNB);
        TransferHelper.safeTransferFrom(token, msg.sender, pair, amountToken);
        IWBNB(WBNB).deposit{value: amountBNB}();
        assert(IWBNB(WBNB).transfer(pair, amountBNB));
        liquidity = IBabelPair(pair).mint(to);
        // refund dust bnb, if any
        if (msg.value > amountBNB) TransferHelper.safeTransferBNB(msg.sender, msg.value.sub(amountBNB));
        
        mintPositionNFT(pair, token, WBNB, liquidity);
    }

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) public virtual override ensure(deadline) returns (uint amountA, uint amountB) {
        address pair = BabelLibrary.pairFor(factory, tokenA, tokenB);
        uint userLiquidity = nftToken.getLiquidityForLP(msg.sender, pair);
        liquidity = userLiquidity >= liquidity ? liquidity : userLiquidity;
        // remove liquidity fee
        if(sellFeeTokens[tokenA] || sellFeeTokens[tokenB]) {
            uint feeAmount = liquidity.mul(sellNativeLPFee).div(10000);
            liquidity = liquidity.sub(feeAmount);
            uint lockAmount = feeAmount.mul(2).div(5);
            IBabelPair(pair).transferFrom(msg.sender, bBLockLiq, lockAmount);
        }        

        removeLiquidityNFT(pair, liquidity);

        IBabelPair(pair).transferFrom(msg.sender, pair, liquidity); // send liquidity to pair
        (uint amount0, uint amount1) = IBabelPair(pair).burn(address(this));
        (address token0,) = BabelLibrary.sortTokens(tokenA, tokenB);
        (amountA, amountB) = tokenA == token0 ? (amount0, amount1) : (amount1, amount0);
        if (amountAMin > amountA) revert('BabelRouter: INSUFFICIENT_A_AMOUNT');
        // require(amountA >= amountAMin, 'BabelRouter: INSUFFICIENT_A_AMOUNT');
        if (amountBMin > amountB) revert('BabelRouter: INSUFFICIENT_B_AMOUNT');
        // require(amountB >= amountBMin, 'BabelRouter: INSUFFICIENT_B_AMOUNT');
        // remove liquidity fee(tokens)
        (amountA, amountB) = getRemoveLPFee(tokenA, tokenB, amountA, amountB);
        if(to != address(this)) {
            TransferHelper.safeTransfer(tokenA, to, amountA);
            TransferHelper.safeTransfer(tokenB, to, amountB);
        }
    }

    function getRemoveLPFee(
        address tokenA,
        address tokenB,
        uint amountA,
        uint amountB
    ) internal returns (uint _amountA, uint _amountB) {
        _amountA = amountA;
        _amountB = amountB;
        uint feeAmount;
        uint burnAmount;
        if(sellFeeTokens[tokenA]) {
            feeAmount = amountA.mul(sellNativeLPTokenFee).div(10000);
            _amountA = amountA.sub(feeAmount);
            burnAmount = feeAmount.div(5);
            IERC20(tokenA).burn(address(this), burnAmount);
            feeAmount = feeAmount.sub(burnAmount);
            TransferHelper.safeTransfer(tokenA, distributor, feeAmount);
            
            feeAmount = amountB.mul(sellNativeLPOtherTokenFee).div(10000);
            _amountB = amountB.sub(feeAmount);
            // IERC20(tokenB).approve(treasuryWallet, feeAmount);
            TransferHelper.safeTransfer(tokenB, treasuryWallet, feeAmount);
        } else if(sellFeeTokens[tokenB]) {
            feeAmount = amountB.mul(sellNativeLPTokenFee).div(10000);
            _amountB = amountB.sub(feeAmount);
            burnAmount = feeAmount.div(5);
            IERC20(tokenB).burn(address(this), burnAmount);
            feeAmount = feeAmount.sub(burnAmount);
            IERC20(tokenB).approve(distributor, feeAmount);
            TransferHelper.safeTransfer(tokenB, distributor, feeAmount);
            
            feeAmount = amountA.mul(sellNativeLPOtherTokenFee).div(10000);
            _amountA = amountA.sub(feeAmount);
            // IERC20(tokenA).approve(treasuryWallet, feeAmount);
            TransferHelper.safeTransfer(tokenA, treasuryWallet, feeAmount);
        }
    }

    function removeLiquidityBNB(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountBNBMin,
        address to,
        uint deadline
    ) public virtual override ensure(deadline) returns (uint amountToken, uint amountBNB) {
        (amountToken, amountBNB) = removeLiquidity(
            token,
            WBNB,
            liquidity,
            amountTokenMin,
            amountBNBMin,
            address(this),
            deadline
        );
        TransferHelper.safeTransfer(token, to, amountToken);
        IWBNB(WBNB).withdraw(amountBNB);
        TransferHelper.safeTransferBNB(to, amountBNB);
    }
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external virtual override returns (uint amountA, uint amountB) {
        address pair = BabelLibrary.pairFor(factory, tokenA, tokenB);
        uint value = approveMax ? uint(-1) : liquidity;
        IBabelPair(pair).permit(msg.sender, address(this), value, deadline, v, r, s);
        (amountA, amountB) = removeLiquidity(tokenA, tokenB, liquidity, amountAMin, amountBMin, to, deadline);
    }
    function removeLiquidityBNBWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountBNBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external virtual override returns (uint amountToken, uint amountBNB) {
        address pair = BabelLibrary.pairFor(factory, token, WBNB);
        uint value = approveMax ? uint(-1) : liquidity;
        IBabelPair(pair).permit(msg.sender, address(this), value, deadline, v, r, s);
        (amountToken, amountBNB) = removeLiquidityBNB(token, liquidity, amountTokenMin, amountBNBMin, to, deadline);
    }

    function removeLiquidityBNBSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountBNBMin,
        address to,
        uint deadline
    ) public virtual override ensure(deadline) returns (uint amountBNB) {
        (, amountBNB) = removeLiquidity(
            token,
            WBNB,
            liquidity,
            amountTokenMin,
            amountBNBMin,
            address(this),
            deadline
        );
        TransferHelper.safeTransfer(token, to, IERC20(token).balanceOf(address(this)));
        IWBNB(WBNB).withdraw(amountBNB);
        TransferHelper.safeTransferBNB(to, amountBNB);
    }
    function removeLiquidityBNBWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountBNBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external virtual override returns (uint amountBNB) {
        address pair = BabelLibrary.pairFor(factory, token, WBNB);
        uint value = approveMax ? uint(-1) : liquidity;
        IBabelPair(pair).permit(msg.sender, address(this), value, deadline, v, r, s);
        amountBNB = removeLiquidityBNBSupportingFeeOnTransferTokens(
            token, liquidity, amountTokenMin, amountBNBMin, to, deadline
        );
    }

    // requires the initial amount to have already been sent to the first pair
    function _swap(uint[] memory amounts, address[] memory path, address _to) internal virtual {
        uint length = path.length;
        // for (uint i; i < path.length - 1; i++) {
        for (uint i; i < length - 1; i++) {
            (address input, address output) = (path[i], path[i + 1]);
            (address token0,) = BabelLibrary.sortTokens(input, output);
            uint amountOut = amounts[i + 1];
            (uint amount0Out, uint amount1Out) = input == token0 ? (uint(0), amountOut) : (amountOut, uint(0));
            address to = i < length - 2 ? BabelLibrary.pairFor(factory, output, path[i + 2]) : _to;
            IBabelPair(BabelLibrary.pairFor(factory, input, output)).swap(
                amount0Out, amount1Out, to, new bytes(0)
            );
        }
    }
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external virtual override ensure(deadline) returns (uint[] memory amounts) {
        uint nativeFeeAmount = sellFeeTokens[path[0]] ? amountIn.mul(sellNativeFee).div(10000) : 0;
        amountIn = amountIn.sub(nativeFeeAmount);
        amounts = BabelLibrary.getAmountsOut(factory, amountIn, path);
        if (amountOutMin > amounts[amounts.length - 1]) revert('BabelRouter: INSUFFICIENT_OUTPUT_AMOUNT');
        // require(amounts[amounts.length - 1] >= amountOutMin, 'BabelRouter: INSUFFICIENT_OUTPUT_AMOUNT');
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, BabelLibrary.pairFor(factory, path[0], path[1]), amounts[0]
        );
        _swap(amounts, path, to);
        if(nativeFeeAmount > 0)
            getFeeForSellingSellFeeToken(path, nativeFeeAmount, true);
    }
    function getFeeForSellingSellFeeToken(address[] memory path, uint256 nativeFeeAmount, bool isIn) internal {        
        // do sell native token fee
        if (nativeFeeAmount > 0) {
            // get coin
            uint swapAmount = nativeFeeAmount.div(2);
            uint[] memory _amounts = BabelLibrary.getAmountsOut(factory, swapAmount, path);
            if(!isIn)
                _amounts = BabelLibrary.getAmountsIn(factory, swapAmount, path);
            TransferHelper.safeTransferFrom(
                path[0], msg.sender, BabelLibrary.pairFor(factory, path[0], path[1]), _amounts[0]
            );
            uint oldBalance = IERC20(path[1]).balanceOf(address(this));
            _swap(_amounts, path, address(this));
            
            // get exact amount of coin
            uint liquidityAmount = IERC20(path[1]).balanceOf(address(this)).sub(oldBalance);

            // take native token fee
            TransferHelper.safeTransferFrom(
                path[0], msg.sender, address(this), swapAmount
            );

            // send treasury coin fee
            uint treasuryAmount = liquidityAmount.div(3);
            if(WBNB == path[path.length - 1]) {
                IWBNB(WBNB).withdraw(treasuryAmount);
                payable(distributor).transfer(treasuryAmount);
            } else {
                TransferHelper.safeTransfer(
                    path[1], distributor, treasuryAmount
                );
            }
            liquidityAmount = liquidityAmount.sub(treasuryAmount);
            
            // send native token for distributing
            uint distributeAmount = swapAmount.div(3);
            TransferHelper.safeTransfer(
                path[0], treasuryWallet, distributeAmount
            );
            // add lp
            uint lpAmount = swapAmount.sub(distributeAmount);
            addLiquidity(path[0], path[1], lpAmount, liquidityAmount, 0, 0, treasuryWallet, block.timestamp + 1000);
        }
    }
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external virtual override ensure(deadline) returns (uint[] memory amounts) {
        uint coinAmount = sellFeeTokens[path[0]] ? amountOut.mul(sellNativeFee).div(10000) : 0;
        amountOut = amountOut.sub(coinAmount);
        amounts = BabelLibrary.getAmountsIn(factory, amountOut, path);
        if (amounts[0] > amountInMax) revert('BabelRouter: EXCESSIVE_INPUT_AMOUNT');
        // require(amounts[0] <= amountInMax, 'BabelRouter: EXCESSIVE_INPUT_AMOUNT');
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, BabelLibrary.pairFor(factory, path[0], path[1]), amounts[0]
        );
        _swap(amounts, path, to);
        if(coinAmount > 0)
            getFeeForSellingSellFeeToken(path, coinAmount, false);
    }
    function swapExactBNBForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        virtual
        override
        payable
        ensure(deadline)
        returns (uint[] memory amounts)
    {
        if (path[0] != WBNB) revert('BabelRouter: INVALID_PATH');
        // require(path[0] == WBNB, 'BabelRouter: INVALID_PATH');
        amounts = BabelLibrary.getAmountsOut(factory, msg.value, path);
        if (amountOutMin > amounts[amounts.length - 1]) revert('BabelRouter: INSUFFICIENT_OUTPUT_AMOUNT');
        // require(amounts[amounts.length - 1] >= amountOutMin, 'BabelRouter: INSUFFICIENT_OUTPUT_AMOUNT');
        IWBNB(WBNB).deposit{value: amounts[0]}();
        assert(IWBNB(WBNB).transfer(BabelLibrary.pairFor(factory, path[0], path[1]), amounts[0]));
        _swap(amounts, path, to);
    }
    function swapTokensForExactBNB(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        virtual
        override
        ensure(deadline)
        returns (uint[] memory amounts)
    {
        if (WBNB != path[path.length - 1]) revert('BabelRouter: INVALID_PATH');
        // require(path[path.length - 1] == WBNB, 'BabelRouter: INVALID_PATH');
        uint coinAmount = sellFeeTokens[path[0]] ? amountOut.mul(sellNativeFee).div(10000) : 0;
        amountOut = amountOut.sub(coinAmount);
        amounts = BabelLibrary.getAmountsIn(factory, amountOut, path);
        if (amounts[0] > amountInMax) revert('BabelRouter: EXCESSIVE_INPUT_AMOUNT');
        // require(amounts[0] <= amountInMax, 'BabelRouter: EXCESSIVE_INPUT_AMOUNT');
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, BabelLibrary.pairFor(factory, path[0], path[1]), amounts[0]
        );
        _swap(amounts, path, address(this));
        IWBNB(WBNB).withdraw(amounts[amounts.length - 1]);
        TransferHelper.safeTransferBNB(to, amounts[amounts.length - 1]);
        if(coinAmount > 0)
            getFeeForSellingSellFeeToken(path, coinAmount, false);
    }
    function swapExactTokensForBNB(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        virtual
        override
        ensure(deadline)
        returns (uint[] memory amounts)
    {
        if (WBNB != path[path.length - 1]) revert('BabelRouter: INVALID_PATH');
        //require(path[path.length - 1] == WBNB, 'BabelRouter: INVALID_PATH');
        uint nativeFeeAmount = sellFeeTokens[path[0]] ? amountIn.mul(sellNativeFee).div(10000) : 0;
        amountIn = amountIn.sub(nativeFeeAmount);
        amounts = BabelLibrary.getAmountsOut(factory, amountIn, path);
        if (amountOutMin > amounts[amounts.length - 1]) revert('BabelRouter: INSUFFICIENT_OUTPUT_AMOUNT');
        // require(amounts[amounts.length - 1] >= amountOutMin, 'BabelRouter: INSUFFICIENT_OUTPUT_AMOUNT');
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, BabelLibrary.pairFor(factory, path[0], path[1]), amounts[0]
        );
        _swap(amounts, path, address(this));
        IWBNB(WBNB).withdraw(amounts[amounts.length - 1]);
        TransferHelper.safeTransferBNB(to, amounts[amounts.length - 1]);
        if(nativeFeeAmount > 0)
            getFeeForSellingSellFeeToken(path, nativeFeeAmount, true);
    }
    function swapBNBForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        virtual
        override
        payable
        ensure(deadline)
        returns (uint[] memory amounts)
    {
        if (WBNB != path[0]) revert('BabelRouter: INVALID_PATH');
        // require(path[0] == WBNB, 'BabelRouter: INVALID_PATH');
        amounts = BabelLibrary.getAmountsIn(factory, amountOut, path);
        if (amounts[0] > msg.value) revert('BabelRouter: EXCESSIVE_INPUT_AMOUNT');
        // require(amounts[0] <= msg.value, 'BabelRouter: EXCESSIVE_INPUT_AMOUNT');
        IWBNB(WBNB).deposit{value: amounts[0]}();
        assert(IWBNB(WBNB).transfer(BabelLibrary.pairFor(factory, path[0], path[1]), amounts[0]));
        _swap(amounts, path, to);
        // refund dust bnb, if any
        if (msg.value > amounts[0]) TransferHelper.safeTransferBNB(msg.sender, msg.value.sub(amounts[0]));
    }

    // requires the initial amount to have already been sent to the first pair
    function _swapSupportingFeeOnTransferTokens(address[] memory path, address _to) internal virtual {
        uint length = path.length;
        // for (uint i; i < path.length - 1; i++) {
        for (uint i; i < length - 1; i++) {
            (address input, address output) = (path[i], path[i + 1]);
            (address token0,) = BabelLibrary.sortTokens(input, output);
            IBabelPair pair = IBabelPair(BabelLibrary.pairFor(factory, input, output));
            uint amountInput;
            uint amountOutput;
            { // scope to avoid stack too deep errors
            (uint reserve0, uint reserve1,) = pair.getReserves();
            (uint reserveInput, uint reserveOutput) = input == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
            amountInput = IERC20(input).balanceOf(address(pair)).sub(reserveInput);
            amountOutput = BabelLibrary.getAmountOut(amountInput, reserveInput, reserveOutput);
            }
            (uint amount0Out, uint amount1Out) = input == token0 ? (uint(0), amountOutput) : (amountOutput, uint(0));
            address to = i < path.length - 2 ? BabelLibrary.pairFor(factory, output, path[i + 2]) : _to;
            pair.swap(amount0Out, amount1Out, to, new bytes(0));
        }
    }
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external virtual override ensure(deadline) {
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, BabelLibrary.pairFor(factory, path[0], path[1]), amountIn
        );
        uint balanceBefore = IERC20(path[path.length - 1]).balanceOf(to);
        _swapSupportingFeeOnTransferTokens(path, to);
        require(
            IERC20(path[path.length - 1]).balanceOf(to).sub(balanceBefore) >= amountOutMin,
            'BabelRouter: INSUFFICIENT_OUTPUT_AMOUNT'
        );
    }
    function swapExactBNBForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    )
        external
        virtual
        override
        payable
        ensure(deadline)
    {
        require(path[0] == WBNB, 'BabelRouter: INVALID_PATH');
        uint amountIn = msg.value;
        IWBNB(WBNB).deposit{value: amountIn}();
        assert(IWBNB(WBNB).transfer(BabelLibrary.pairFor(factory, path[0], path[1]), amountIn));
        uint balanceBefore = IERC20(path[path.length - 1]).balanceOf(to);
        _swapSupportingFeeOnTransferTokens(path, to);
        require(
            IERC20(path[path.length - 1]).balanceOf(to).sub(balanceBefore) >= amountOutMin,
            'BabelRouter: INSUFFICIENT_OUTPUT_AMOUNT'
        );
    }
    function swapExactTokensForBNBSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    )
        external
        virtual
        override
        ensure(deadline)
    {
        require(path[path.length - 1] == WBNB, 'BabelRouter: INVALID_PATH');
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, BabelLibrary.pairFor(factory, path[0], path[1]), amountIn
        );
        _swapSupportingFeeOnTransferTokens(path, address(this));
        uint amountOut = IERC20(WBNB).balanceOf(address(this));
        require(amountOut >= amountOutMin, 'BabelRouter: INSUFFICIENT_OUTPUT_AMOUNT');
        IWBNB(WBNB).withdraw(amountOut);
        TransferHelper.safeTransferBNB(to, amountOut);
    }

    function quote(uint amountA, uint reserveA, uint reserveB) public pure virtual override returns (uint amountB) {
        return BabelLibrary.quote(amountA, reserveA, reserveB);
    }

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut)
        public
        pure
        virtual
        override
        returns (uint amountOut)
    {
        return BabelLibrary.getAmountOut(amountIn, reserveIn, reserveOut);
    }

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut)
        public
        pure
        virtual
        override
        returns (uint amountIn)
    {
        return BabelLibrary.getAmountIn(amountOut, reserveIn, reserveOut);
    }

    function getAmountsOut(uint amountIn, address[] memory path)
        public
        view
        virtual
        override
        returns (uint[] memory amounts)
    {
        return BabelLibrary.getAmountsOut(factory, amountIn, path);
    }

    function getAmountsIn(uint amountOut, address[] memory path)
        public
        view
        virtual
        override
        returns (uint[] memory amounts)
    {
        return BabelLibrary.getAmountsIn(factory, amountOut, path);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0;

interface IBabelFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;

    function INIT_CODE_PAIR_HASH() external view returns (bytes32);
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.6.0;

// helper methods for interacting with ERC20 tokens and sending BNB that do not consistently return true/false

library TransferHelper {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferBNB(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'TransferHelper: BNB_TRANSFER_FAILED');
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2;

interface IBabelRouter {
    function factory() external pure returns (address);
    function WBNB() external pure returns (address);

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
    function addLiquidityBNB(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountBNBMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountBNB, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityBNB(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountBNBMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountBNB);
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
    function removeLiquidityBNBWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountBNBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountBNB);
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
    function swapExactBNBForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactBNB(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForBNB(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapBNBForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);

    function removeLiquidityBNBSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountBNBMin,
        address to,
        uint deadline
    ) external returns (uint amountBNB);
    function removeLiquidityBNBWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountBNBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountBNB);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactBNBForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForBNBSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0;

import {IBabelFactory} from '../../core/interfaces/IBabelFactory.sol';
import {IBabelPair} from '../../core/interfaces/IBabelPair.sol';

import {SafeMath} from './SafeMath.sol';

library BabelLibrary {
    using SafeMath for uint;

    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        if (tokenA == tokenB) revert('BabelLibrary: IDENTICAL_ADDRESSES');
        // require(tokenA != tokenB, 'BabelLibrary: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        if (token0 == address(0)) revert('BabelLibrary: ZERO_ADDRESS');
        // require(token0 != address(0), 'BabelLibrary: ZERO_ADDRESS');
    }

    // calculates the CREATE2 address for a pair without making any external calls
    function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(uint(keccak256(abi.encodePacked(
                hex'ff',
                factory,
                keccak256(abi.encodePacked(token0, token1)),
                hex'1c4da2a2496bd51da575dfe3f0160724098c33196acc95db042f60c98426b9fa' // init code hash
            ))));
    }

    // fetches and sorts the reserves for a pair
    function getReserves(
        address factory, 
        address tokenA, 
        address tokenB) internal view returns (uint reserveA, uint reserveB) {

        (address token0,) = sortTokens(tokenA, tokenB);
        (uint reserve0, uint reserve1,) = IBabelPair(pairFor(factory, tokenA, tokenB)).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    // given some amount of an asset and pair reserves, returns an equivalent amount of the other asset
    function quote(uint amountA, uint reserveA, uint reserveB) internal pure returns (uint amountB) {
        if (amountA == 0) revert('BabelLibrary: INSUFFICIENT_AMOUNT');
        // require(amountA > 0, 'BabelLibrary: INSUFFICIENT_AMOUNT');
        if (reserveA == 0 && reserveB == 0) revert('BabelLibrary: INSUFFICIENT_LIQUIDITY');
        // require(reserveA > 0 && reserveB > 0, 'BabelLibrary: INSUFFICIENT_LIQUIDITY');
        amountB = amountA.mul(reserveB) / reserveA;
    }

    // given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal pure returns (uint amountOut) {
        if (amountIn == 0) revert('BabelLibrary: INSUFFICIENT_INPUT_AMOUNT');
        // require(amountIn > 0, 'BabelLibrary: INSUFFICIENT_INPUT_AMOUNT');
        if (reserveIn == 0 && reserveOut == 0) revert('BabelLibrary: INSUFFICIENT_LIQUIDITY');
        // require(reserveIn > 0 && reserveOut > 0, 'BabelLibrary: INSUFFICIENT_LIQUIDITY');
        uint amountInWithFee = amountIn.mul(997);
        uint numerator = amountInWithFee.mul(reserveOut);
        uint denominator = reserveIn.mul(1000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }

    // given an output amount of an asset and pair reserves, returns a required input amount of the other asset
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) internal pure returns (uint amountIn) {
        if (amountOut == 0) revert('BabelLibrary: INSUFFICIENT_OUTPUT_AMOUNT');
        // require(amountOut > 0, 'BabelLibrary: INSUFFICIENT_OUTPUT_AMOUNT');
        if (reserveIn == 0 && reserveOut == 0) revert('BabelLibrary: INSUFFICIENT_LIQUIDITY');
        // require(reserveIn > 0 && reserveOut > 0, 'BabelLibrary: INSUFFICIENT_LIQUIDITY');
        uint numerator = reserveIn.mul(amountOut).mul(1000);
        uint denominator = reserveOut.sub(amountOut).mul(997);
        amountIn = (numerator / denominator).add(1);
    }

    // performs chained getAmountOut calculations on any number of pairs
    function getAmountsOut(
        address factory, 
        uint amountIn, 
        address[] memory path) internal view returns (uint[] memory amounts) {

        uint256 length = path.length;

        if (2 > length) revert('BabelLibrary: INVALID_PATH');
        // require(path.length >= 2, 'BabelLibrary: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[0] = amountIn;
        for (uint i; i < path.length - 1; i++) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i], path[i + 1]);
            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);
        }
    }

    // performs chained getAmountIn calculations on any number of pairs
    function getAmountsIn(
        address factory, 
        uint amountOut, 
        address[] memory path) internal view returns (uint[] memory amounts) {

        uint256 length = path.length;

        if (2 > length) revert('BabelLibrary: INVALID_PATH');
        // require(path.length >= 2, 'BabelLibrary: INVALID_PATH');
        amounts = new uint[](length);
        amounts[amounts.length - 1] = amountOut;
        for (uint i = length - 1; i > 0; i--) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i - 1], path[i]);
            amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut);
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0;

interface IPositionNFT {
    function mint(address lp, address token0, address token1, uint liquidity, address account) external returns (uint);
    function getTokenIDForLP(address account, address lp) external view returns(uint[] memory);
    function getLiquidityForLP(address account, address lp) external view returns(uint);
    function getPriceOfLiquidity(address pair, uint liquidity, address token) external view returns (uint);
    function updateInfo(uint tokenId, uint liquidity) external;
    function tokenLP(uint tokenId) external view returns(address);
    function tokenLiquidity(uint tokenId) external view returns(uint);
    function safeTransferFrom(address from, address to, uint tokenId) external;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0;

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
    function burn(address _from, uint256 _amount) external;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0;

interface IWBNB {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function balanceOf(address owner) external view returns (uint);
    function withdraw(uint) external;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0;

interface IBabelPair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.6 <0.8.0;

// a library for performing overflow-safe math, courtesy of DappHub (https://github.com/dapphub/ds-math)

library SafeMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, 'ds-math-add-overflow');
    }

    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, 'ds-math-sub-underflow');
    }

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, 'ds-math-mul-overflow');
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }
}