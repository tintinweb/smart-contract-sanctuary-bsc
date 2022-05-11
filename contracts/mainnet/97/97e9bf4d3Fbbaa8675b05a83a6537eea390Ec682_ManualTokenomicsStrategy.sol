/**
 *Submitted for verification at BscScan.com on 2022-05-11
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;


library Math {
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        return (a & b) + (a ^ b) / 2;
    }

    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b + (a % b == 0 ? 0 : 1);
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}


interface ITokenomicsStrategy {
    function process() external;
}

interface ITokenomicsToken is IERC20, IERC20Metadata {
    function feeDenominator() external view returns (uint16);

    function maxSellBuyFee() external view returns (uint8);

    function sellBuyBurnFee() external view returns (uint8);

    function sellBuyCharityFee() external view returns (uint8);

    function sellBuyOperatingFee() external view returns (uint8);

    function sellBuyMarketingFee() external view returns (uint8);

    function sellBuyTotalFee() external view returns (uint8);

    function setSellBuyFee(
        uint8 sellBuyCharityFee_,
        uint8 sellBuyOperatingFee_,
        uint8 sellBuyMarketingFee_
    ) external;

    function maxTransferFee() external view returns (uint8);

    function transferBurnFee() external view returns (uint8);

    function transferCharityFee() external view returns (uint8);

    function transferOperatingFee() external view returns (uint8);

    function transferMarketingFee() external view returns (uint8);

    function transferTotalFee() external view returns (uint8);

    function setTransferFee(
        uint8 transferCharityFee_,
        uint8 transferOperatingFee_,
        uint8 transferMarketingFee_
    ) external;

    function process() external;

    function isFeeExempt(address account) external view returns (bool);

    function setFeeExempt(address account, bool exempt) external;

    function strategy() external view returns (ITokenomicsStrategy strategy_);

    function setStrategy(ITokenomicsStrategy strategy_) external;

    function dexPair() external view returns (address);

    function setDexPair(address dexPair_) external;

    function burn(uint256 amount) external;

    function burnFrom(address account, uint256 amount) external;

    event FeePayment(address indexed payer, uint256 fee);

    event Burnt(address indexed account, uint256 amount);
}

interface IFCKToken is ITokenomicsToken {
    function teamAndAdvisorsCap() external view returns (uint256);

    function marketingReserveCap() external view returns (uint256);

    function platformReserveCap() external view returns (uint256);

    function launchedAt() external view returns (uint256);

    function launched() external view returns (bool);

    function launch() external returns (bool);

    function mint(address account, uint256 amount) external;

    function pause() external;

    function unpause() external;

    function maxTxAmount() external view returns (uint256);

    function setMaxTxAmount(uint256 maxTxAmount_) external;

    function maxWalletBalance() external view returns (uint256);

    function setMaxWalletBalance(uint256 maxWalletBalance_) external;

    function isTxLimitExempt(address account) external view returns (bool);

    function setIsTxLimitExempt(address recipient, bool exempt) external;

    event Minted(address indexed account, uint256 amount);

    event Launched(uint256 launchedAt);

    event FeePayment(address indexed sender, uint256 balance, uint256 fee);
}

contract BaseTokenomicsStrategy {
    IFCKToken internal _token;
    address private _charityWallet;
    address private _operationslWallet;
    address private _marketingWallet;

    constructor(
        IFCKToken token,
        address charityWallet,
        address operationsWallet,
        address marketingWallet
    ) {
        _token = token;
        _charityWallet = charityWallet;
        _operationslWallet = operationsWallet;
        _marketingWallet = marketingWallet;
    }

    receive() external payable {
        if (msg.value > 0) {
            _distribute(msg.value);
        }
    }

    fallback() external payable {
        if (msg.value > 0) {
            _distribute(msg.value);
        }
    }

    function _distribute(uint256 amount) internal returns (bool) {
        uint8 totalDistribute = _token.transferTotalFee() -
            _token.transferBurnFee();
        uint16 charityFee = (_token.transferCharityFee() *
            _token.feeDenominator()) / totalDistribute;
        uint16 operatingFee = (_token.transferOperatingFee() *
            _token.feeDenominator()) / totalDistribute;

        uint256 charityAmount = Math.ceilDiv(
            amount * charityFee,
            _token.feeDenominator()
        );
        uint256 operatingAmount = Math.ceilDiv(
            amount * operatingFee,
            _token.feeDenominator()
        );
        uint256 marketingAmount = amount - charityAmount - operatingAmount;

        (bool charityRes, ) = payable(_charityWallet).call{
            value: charityAmount,
            gas: 30000
        }("");
        (bool operatingRes, ) = payable(_operationslWallet).call{
            value: operatingAmount,
            gas: 30000
        }("");
        (bool marketingRes, ) = payable(_marketingWallet).call{
            value: marketingAmount,
            gas: 30000
        }("");

        return charityRes && operatingRes && marketingRes;
    }
}

contract ManualTokenomicsStrategy is
    ITokenomicsStrategy,
    BaseTokenomicsStrategy
{
    address private _tokensRecipient;

    constructor(
        IFCKToken token,
        address charityWallet,
        address operationsWallet,
        address marketingWallet,
        address tokensRecipient
    )
        BaseTokenomicsStrategy(
            token,
            charityWallet,
            operationsWallet,
            marketingWallet
        )
    {
        _tokensRecipient = tokensRecipient;
    }

    function process() external override {
        if (msg.sender != address(_token)) {
            _token.transferFrom(
                address(_token),
                _tokensRecipient,
                _token.balanceOf(address(_token))
            );
        }
    }
}