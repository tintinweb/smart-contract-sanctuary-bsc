// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.18;

// Ahbap BNB Chain address.
// See https://twitter.com/ahbap/status/1622963311514996739?s=20&t=-cK1P2pUhc-FtTQUWW1Lew
address payable constant AHBAP_BNBCHAIN = payable(
    0xB67705398fEd380a1CE02e77095fed64f8aCe463
);

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);
}

interface IERC721 {
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external payable;
}

// The top 7 tokens on BNB Chain by market cap according to bscscan.com
IERC20 constant WETH = IERC20(0x2170Ed0880ac9A755fd29B2688956BD959F933F8);
IERC20 constant BSCUSD = IERC20(0x55d398326f99059fF775485246999027B3197955);
IERC20 constant WBNB = IERC20(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
IERC20 constant USDC = IERC20(0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d);
IERC20 constant anyUSDC = IERC20(0x8965349fb649A33a30cbFDa057D8eC2C48AbE2A2);
IERC20 constant XRP = IERC20(0x1D2F0da169ceB9fC7B3144628dB156f3F6c60dBE);
IERC20 constant BUSD = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);

/**
 * Sends all BNB and ERC-20 tokens sent to this address to `AHBAP_BNBCHAIN`.
 */
contract AhbapRelayer {
    receive() external payable {}

    function sweepNativeToken() external {
        AHBAP_BNBCHAIN.transfer(address(this).balance);
    }

    /**
     * Transfers the entire balance of a select list of tokens to
     * AHBAP_BNBCHAIN.
     *
     * The list is obtained by sorting the token by market cap on
     * bscscan.com an taking the top 8.
     *
     * For other tokens use `sweepMultiERC20()` or `sweepSingleERC20()` methods.
     */
    function sweepCommonERC20() external {
        WETH.transfer(AHBAP_BNBCHAIN, WETH.balanceOf(address(this)));
        BSCUSD.transfer(AHBAP_BNBCHAIN, BSCUSD.balanceOf(address(this)));
        WBNB.transfer(AHBAP_BNBCHAIN, WBNB.balanceOf(address(this)));
        USDC.transfer(AHBAP_BNBCHAIN, USDC.balanceOf(address(this)));
        anyUSDC.transfer(AHBAP_BNBCHAIN, anyUSDC.balanceOf(address(this)));
        XRP.transfer(AHBAP_BNBCHAIN, XRP.balanceOf(address(this)));
        BUSD.transfer(AHBAP_BNBCHAIN, BUSD.balanceOf(address(this)));
    }

    /**
     * Transfers the entire balance of the given 5 tokens to
     * `AHBAP_BNBCHAIN`.
     *
     * If you have fewer than 5 tokens, pad the remainder with, say, WAVAX so
     * the transaction doesn't revert.
     *
     * @param tokens A list of ERC20 contract addresses whose balance wil be
     *               sent to `AHBAP_BNBCHAIN`.
     */
    function sweepMultiERC20(IERC20[5] calldata tokens) external {
        tokens[0].transfer(AHBAP_BNBCHAIN, tokens[0].balanceOf(address(this)));
        tokens[1].transfer(AHBAP_BNBCHAIN, tokens[1].balanceOf(address(this)));
        tokens[2].transfer(AHBAP_BNBCHAIN, tokens[2].balanceOf(address(this)));
        tokens[3].transfer(AHBAP_BNBCHAIN, tokens[3].balanceOf(address(this)));
        tokens[4].transfer(AHBAP_BNBCHAIN, tokens[4].balanceOf(address(this)));
    }

    /**
     * Transfers the entire balance of the given token to `AHBAP_BNBCHAIN`.
     *
     * @param token Contract addres of the token to move
     */
    function sweepSingleERC20(IERC20 token) external {
        token.transfer(AHBAP_BNBCHAIN, token.balanceOf(address(this)));
    }

    function sweepNFT(IERC721 nft, uint256 tokenId) external {
        nft.transferFrom(address(this), AHBAP_BNBCHAIN, tokenId);
    }
}