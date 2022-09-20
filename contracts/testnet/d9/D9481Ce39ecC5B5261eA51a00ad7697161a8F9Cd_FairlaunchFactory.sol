// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "./IERC20.sol";
import "./Fairlaunch.sol";
import "./InvestmentsInfo.sol";
import "./InvestmentsLiquidityLock.sol";

interface IPancakeFactory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

contract FairlaunchFactory {
    using SafeMath for uint256;

    event PresaleCreated(bytes32 title, uint256 Id, address presalecontractaddress, address liquiditylockaddress);

    IPancakeFactory private constant PancakeFactory =
    IPancakeFactory(address(0x6725F303b657a9451d8BA641348b6761A6CC7a17));
    address private constant wbnbAddress = address(0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd);

    InvestmentsInfo public immutable SSS;

    constructor(address _InfoAddress) public {
        SSS = InvestmentsInfo(_InfoAddress);
    }

    struct PresaleInfo {
        address tokenAddress;
        uint256 tokenQuantity;
        uint256 softCapInWei;
        uint256 openTime;
        uint256 closeTime;
    }

    struct PresaleUniswapInfo {
        uint256 lpTokensLockDurationInDays;
        uint256 liquidityPercentageAllocation;
    }

    struct PresaleStringInfo {
        bytes32 saleTitle;
        bytes32 linkTelegram;
        bytes32 linkDiscord;
        bytes32 linkTwitter;
        bytes32 linkWebsite;
    }

    // copied from https://github.com/Uniswap/uniswap-v2-periphery/blob/master/contracts/libraries/UniswapV2Library.sol
    // calculates the CREATE2 address for a pair without making any external calls
    function uniV2LibPairFor(
        address factory,
        address tokenA,
        address tokenB
    ) internal pure returns (address pair) {
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        pair = address(
            uint256(
                keccak256(
                    abi.encodePacked(
                        hex"ff",
                        factory,
                        keccak256(abi.encodePacked(token0, token1)),
                        hex"96e8ac4277198ff8b6f785478aa9a39f403cb768dd02cbee326c3e7da348845f" // init code hash
                    )
                )
            )
        );
    }

    function initializeFairlaunch(
        Fairlaunch _flaunch,
        uint256 _totalTokens,
        uint256 _totalTokensinPool,
        PresaleInfo calldata _info,
        PresaleUniswapInfo calldata _uniInfo,
        PresaleStringInfo calldata _stringInfo
    ) internal {
        _flaunch.setAddressInfo(msg.sender, _info.tokenAddress);
        _flaunch.setGeneralInfo(
            _totalTokens,
            _totalTokensinPool,
            _info.softCapInWei,
            _info.openTime,
            _info.closeTime
        );
        _flaunch.setUniswapInfo(
            _uniInfo.lpTokensLockDurationInDays,
            _uniInfo.liquidityPercentageAllocation
        );
        _flaunch.setStringInfo(
            _stringInfo.saleTitle,
            _stringInfo.linkTelegram,
            _stringInfo.linkDiscord,
            _stringInfo.linkTwitter,
            _stringInfo.linkWebsite
        );
    }

    function createPresale(
        PresaleInfo calldata _info,
        PresaleUniswapInfo calldata _uniInfo,
        PresaleStringInfo calldata _stringInfo
    ) external //payable 
    {
        //require(msg.value == 2.5 ether, "msg.value less than 2.5 BNB. Send 2.5 BNB to create presale.");
        IERC20 token = IERC20(_info.tokenAddress);

        Fairlaunch flaunch = new Fairlaunch(address(this), SSS.owner());

        address existingPairAddress = PancakeFactory.getPair(address(token), wbnbAddress);
        require(existingPairAddress == address(0)); // token should not be listed in PancakeSwap

        //uint256 maxEthPoolTokenAmount = _info.hardCapInWei.mul(_uniInfo.liquidityPercentageAllocation).div(100);
        //uint256 maxLiqPoolTokenAmount = maxEthPoolTokenAmount.mul(1e18).div(_uniInfo.listingPriceInWei);

        uint256 maxTokensToBeSold = _info.tokenQuantity.mul(_uniInfo.liquidityPercentageAllocation).mul(95).div(10000);
        uint256 requiredTokenAmount = _info.tokenQuantity.add(maxTokensToBeSold);
        token.transferFrom(msg.sender, address(flaunch), requiredTokenAmount);

        initializeFairlaunch(flaunch, _info.tokenQuantity, maxTokensToBeSold, _info, _uniInfo, _stringInfo);

        address pairAddress = uniV2LibPairFor(address(PancakeFactory), address(token), wbnbAddress);
        InvestmentsLiquidityLock liquidityLock = new InvestmentsLiquidityLock(
                IERC20(pairAddress),
                msg.sender,
                address(flaunch),
                _info.closeTime + (_uniInfo.lpTokensLockDurationInDays * 1 days)
            );

        uint256 Id = SSS.addPresaleAddress(address(flaunch));
        flaunch.setInfo(address(liquidityLock), Id);

        emit PresaleCreated(_stringInfo.saleTitle, Id, address(flaunch), address(liquidityLock));
        //payable(SSS.owner()).transfer(msg.value);
    }
}