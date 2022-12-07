// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.17;

import "./IERC20.sol";
import "./Ownable.sol";
import "./Token.sol";
import "./TokenFactory.sol";
import "./TokenSetting.sol";
import "./SafeMath.sol";


interface ITokenFactory {
    function registerToken(address _tokenOwner, address _tokenAddress) external;

    function tokenGeneratorsLength() external view returns (uint256);
}

contract TokenGenerator is Ownable {
    using SafeMath for uint256;
    ITokenFactory public TOKEN_FACTORY;
    ITokenSetting public TOKEN_SETTING;

    event CreateToken(address userAddress, address tokenAddress, uint256 creationFee, uint256 totalSupplyFee);

    constructor(address _tokenFactory, address _tokenSetting) {
        TOKEN_FACTORY = ITokenFactory(_tokenFactory);
        TOKEN_SETTING = ITokenSetting(_tokenSetting);
    }

    /**
     * @notice Creates a new Token contract and registers it in the Token Factory
     */
    function createToken(
        string memory name,
        string memory symbol,
        uint8 decimals,
        uint256 totalSupply
    ) public payable {
        require(msg.value == TOKEN_SETTING.getCreationFee(), 'TOKEN GENERATOR: FEE NOT MET');
        payable(TOKEN_SETTING.getTokenFeeAddress()).transfer(TOKEN_SETTING.getCreationFee());

        IERC20 newToken = new Token(name, symbol, decimals, payable(msg.sender), totalSupply);
        uint256 tokenBalance = newToken.balanceOf(address(this));
        uint256 totalSupplyFee = tokenBalance.mul(TOKEN_SETTING.getTotalSupplyFee()).div(1000);
        if (totalSupplyFee > 0) {
            newToken.transfer(TOKEN_SETTING.getTokenFeeAddress(), totalSupplyFee);
        }
        newToken.transfer(msg.sender, tokenBalance - totalSupplyFee);
        TOKEN_FACTORY.registerToken(msg.sender, address(newToken));
        emit CreateToken(msg.sender, address(newToken), msg.value, totalSupplyFee);
    }
}