/**
 * @title Fee Vault
 * @dev FeeVault contract
 *
 * @author - <USDFI TRUST>
 * for the USDFI Trust
 *
 * SPDX-License-Identifier: Business Source License 1.1
 *
 **/

import "./Ownable.sol";
import "./SafeERC20.sol";
import "./IRouter2.sol";
import "./IStabilityCheck.sol";
import "./ReentrancyGuard.sol";

pragma solidity 0.6.12;

contract FeeVault is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    IStabilityCheck public stabilityCheck; // = 0x39461d16a363f8447bdf4b22104b1f0c7d63de87

    address public constant unirouter = 0x0BE43929ACD985CaCF6385596cA283E265C1B52e;
    address public constant stable = 0xE7Df6907120684add86f686E103282Ee5CD17b02;
    address public constant usdfi = 0x7DF1938170869AFE410098540c051A8A50308988;
    address public constant wbnb = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    mapping(address => uint256) public _timestamp;

    uint256 internal constant doller = 1000000000000000000;

    address public profitVault;
    address public protocolVault;
    uint256 public feePercent = 20;

    address[] internal tokenToStableRoute; // = [token, usdfi, stable];
    address[] internal tokenToUsdfiRoute; // = [token, usdfi];
    address[] internal tokenToWbnbRoute; // = [token, wbnb];

    constructor(address _stabilityCheck, address _profitVault, address _protocolVault) public {
        stabilityCheck = IStabilityCheck(_stabilityCheck);
        profitVault = _profitVault;
        protocolVault = _protocolVault;
        giveAllowances();
    }

    function createLiquidity(address _token) public nonReentrant {
        giveAllowancesToken(_token);
        generateFee(_token);
        generateProtocolFee(_token);
        calculateBalance(_token);
    }

    function generateFee(address _token) internal {
        uint256 timeframe = block.timestamp.sub(_timestamp[_token]);
        if (timeframe > 8208000) {
            //95% = 95 days
            timeframe = 8208000;
        }

        uint256 tokenBal = IERC20(_token)
            .balanceOf(address(this))
            .mul(timeframe)
            .div(8640000);
        require(tokenBal > 0, "tokenBal 0");

        if (_token != wbnb) {
            tokenToWbnbRoute = [_token, wbnb];
            IRouter2(unirouter)
                .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                    tokenBal,
                    0,
                    tokenToWbnbRoute,
                    address(msg.sender),
                    now
                );
        } else {
            IERC20(wbnb).safeTransfer(address(msg.sender), tokenBal);
        }

        _timestamp[_token] = block.timestamp;
    }

    function generateProtocolFee(address _token) internal {
        uint256 tokenBal = IERC20(_token)
            .balanceOf(address(this))
            .mul(feePercent)
            .div(100);
        require(tokenBal > 0, "tokenBal 0");
        tokenToUsdfiRoute = [_token, usdfi];
        IRouter2(unirouter)
            .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                tokenBal,
                0,
                tokenToUsdfiRoute,
                address(this),
                now
            );
        uint256 usdfiBal = IERC20(usdfi).balanceOf(address(this));
        uint256 stableBal = IERC20(stable).balanceOf(address(this));
        IERC20(usdfi).safeTransfer(profitVault, usdfiBal);
        if (stableBal > 0) {
            IERC20(stable).safeTransfer(profitVault, stableBal);
        }
    }

    function calculateBalance(address _token) internal {
        uint256 bal = IERC20(_token).balanceOf(address(this));

        if (bal > 0) {
            uint256 price = stabilityCheck.rewardsAvailableInBUSD();

            if (price > 1000000000000000000) {
                addLiquidityStable(bal, _token);
            } else if (price < 900000000000000000) {
                addLiquidityUsdfi(bal, _token);
            } else {
                uint256 USDFIPercent = (doller.sub(price)).div(
                    1000000000000000
                );

                uint256 UsdfiBal = bal.mul(USDFIPercent).div(100);
                uint256 StableBal = bal.sub(UsdfiBal);

                addLiquidityUsdfi(UsdfiBal, _token);
                addLiquidityStable(StableBal, _token);
            }
        }
    }

    function addLiquidityUsdfi(uint256 _tokenBal, address _token) internal {
        uint256 UsdfiTokenBalHalf = _tokenBal.div(2);

        tokenToUsdfiRoute = [_token, usdfi];

        IRouter2(unirouter)
            .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                UsdfiTokenBalHalf,
                0,
                tokenToUsdfiRoute,
                address(this),
                now
            );

        uint256 lp0Bal = IERC20(usdfi).balanceOf(address(this));
        uint256 lp1Bal = IERC20(_token).balanceOf(address(this));
        IRouter2(unirouter).addLiquidity(
            usdfi,
            _token,
            lp0Bal,
            lp1Bal,
            1,
            1,
            protocolVault,
            now
        );
    }

    function addLiquidityStable(uint256 _tokenBal, address _token) internal {
        uint256 StableTokenBalHalf = _tokenBal.div(2);

        tokenToStableRoute = [_token, usdfi, stable];

        IRouter2(unirouter)
            .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                StableTokenBalHalf,
                0,
                tokenToStableRoute,
                address(this),
                now
            );

        uint256 lp0Bal = IERC20(stable).balanceOf(address(this));
        uint256 lp1Bal = IERC20(_token).balanceOf(address(this));
        IRouter2(unirouter).addLiquidity(
            usdfi,
            _token,
            lp0Bal,
            lp1Bal,
            1,
            1,
            protocolVault,
            now
        );
    }

    function getFeePercent(address _token) public view returns (uint256) {
        uint256 timeframe = block.timestamp.sub(_timestamp[_token]);
        if (timeframe > 8208000) {
            //95% = 95 days
            timeframe = 8208000;
        }
        return timeframe;
    }

    function stableBuyPercent() public view returns (uint256) {
        uint256 price = stabilityCheck.rewardsAvailableInBUSD();
        uint256 stablePercent;

        if (price > 1000000000000000000) {
            stablePercent = 100;
        } else if (price < 900000000000000000) {
            stablePercent = 0;
        } else {
            stablePercent = (doller.sub(price)).div(1000000000000000);
        }
        return stablePercent;
    }

    function giveAllowances() public {
        IERC20(usdfi).safeApprove(unirouter, 0);
        IERC20(usdfi).safeApprove(unirouter, uint256(-1));

        IERC20(stable).safeApprove(unirouter, 0);
        IERC20(stable).safeApprove(unirouter, uint256(-1));

        IERC20(wbnb).safeApprove(unirouter, 0);
        IERC20(wbnb).safeApprove(unirouter, uint256(-1));
    }

    function giveAllowancesToken(address _token) public {
        IERC20(_token).safeApprove(unirouter, 0);
        IERC20(_token).safeApprove(unirouter, uint256(-1));
    }

    function setProfitVault(address _setProfitVault) external onlyOwner {
        require(_setProfitVault != address(0x0), "not 0 address");
        profitVault = _setProfitVault;
    }

    function setProtocolVault(address _setProtocolVault) external onlyOwner {
        require(_setProtocolVault != address(0x0), "not 0 address");
        protocolVault = _setProtocolVault;
    }

    function setFeePercent(uint256 _setFeePercent) external onlyOwner {
        require(_setFeePercent < 99, "max 99%");
        feePercent = _setFeePercent;
    }

    function withdrawTokens(
        address _token,
        address _to,
        uint256 _amount
    ) external onlyOwner {
        IERC20(_token).safeTransfer(_to, _amount);
    }

    function giveAllowancesMax(address _token, address _to) external onlyOwner {
        IERC20(_token).safeApprove(_to, uint256(-1));
    }

    function giveAllowances(
        address _token,
        address _to,
        uint256 max
    ) external onlyOwner {
        IERC20(_token).safeApprove(_to, uint256(max));
    }

    function removeAllowances(address _token, address _to) external onlyOwner {
        IERC20(_token).safeApprove(_to, 0);
    }
}