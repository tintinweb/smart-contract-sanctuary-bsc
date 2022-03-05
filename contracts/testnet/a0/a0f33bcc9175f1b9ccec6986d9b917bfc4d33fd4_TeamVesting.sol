// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

// Imports
import "./Libraries.sol";

contract TeamVesting is ReentrancyGuard {
    IERC20 public token;
    address public teamWallet; // Wallet team
    uint public cooldownTime = 30 days; // time .
    uint public claimReady; // save claim.
    bool private tokenAvailable = false;
    uint public initialContractBalance; // Initial contract balance.
    bool private initialized; // Checks if the variable initializedContractBalance has been defined.

    constructor(address _teamWallet) {
        teamWallet = _teamWallet;
    }

    modifier onlyOwner() {
        require(msg.sender == teamWallet, 'You must be the owner.');
        _;
    }

    /**
     * @notice function upgrade token.
     * @param _token adrees contract token.
     */
    function setToken(IERC20 _token) public onlyOwner {
        require(!tokenAvailable, "Token is already inserted.");
        token = _token;
        tokenAvailable = true;
    }

    /**
     * @notice  % de un number.
     * @param x number.
     * @param y % del number.
     * @param scale number.
     */
    function mulScale (uint x, uint y, uint128 scale) internal pure returns (uint) {
        uint a = x / scale;
        uint b = x % scale;
        uint c = y / scale;
        uint d = y % scale;

        return a * c * scale + a * d + b * c + b * d / scale;
    }

    /**
     * @notice claim 8,33% months.
     */
    function claimTokens() public onlyOwner nonReentrant {
        require(claimReady <= block.timestamp, "You can't claim now.");
        require(token.balanceOf(address(this)) > 0, "Insufficient Balance.");

        if(!initialized) {
            initialContractBalance = token.balanceOf(address(this));
            initialized = true;
        }

        uint _withdrawableBalance = mulScale(initialContractBalance, 833, 10000); // 833 basis points = 8,33%.

        if(token.balanceOf(address(this)) <= _withdrawableBalance) {
            token.transfer(teamWallet, token.balanceOf(address(this)));
        } else {
            claimReady = block.timestamp + cooldownTime;

            token.transfer(teamWallet, _withdrawableBalance); 
        }
    }
}