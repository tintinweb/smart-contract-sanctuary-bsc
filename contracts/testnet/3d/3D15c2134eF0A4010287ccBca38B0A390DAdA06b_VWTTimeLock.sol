// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 amount) external;
}

contract VWTTimeLock{
    IERC20 public token;

    // custom data structure to mint tokens
    struct walletData {
        uint times;
        uint256 amount;
        uint256 releaseTime;
        uint256 interval;
    }

    // only one locked account per address
    mapping (address => walletData) public accounts;

    address public constant PRIVATE_SALE_WALLET = address(0);
    address public constant DEVELOPMENT_WALLET = 0xcB5809433a0C4A182AbC86e4853678DC12d43256;
    address public constant LIQUIDITY_MARKET_WALLET = address(0);
    address public constant ADVISOR_WALLET = address(0);
    address public constant LEGAL_WALLET = address(0);
    address public constant MINING_WALLET = address(0);

    
    constructor(address _token, uint256 _startTime){
        token = IERC20(_token);
        defineAccount(PRIVATE_SALE_WALLET, 1, 5000000 * 10 ** 18, _startTime + 180 days, 30 days);
        defineAccount(DEVELOPMENT_WALLET, 8, 10000000 * 10 ** 18, _startTime, 90 days);
        defineAccount(LIQUIDITY_MARKET_WALLET, 30, 1000000 * 10 ** 18, _startTime + 30 days, 30 days);
        defineAccount(ADVISOR_WALLET, 6, 2000000 * 10 ** 18, _startTime, 90 days);
        defineAccount(LEGAL_WALLET, 5, 500000 * 10 ** 18, _startTime, 90 days);
        defineAccount(MINING_WALLET, 22, 10000000 * 10 ** 18, _startTime + 150 days, 30 days);
    }

    /** 
    * these tokens will be released at certain times and at certain intervals
    * and can only be retrieved by the same account which was defining them
    */
    function defineAccount(address account, uint times, uint256 amount, uint256 releaseTime, uint256 interval) internal {
        accounts[account].times = times;
        accounts[account].amount = amount;
        accounts[account].releaseTime = releaseTime;
        accounts[account].interval = interval;
    }
    
    function payOut() public {
        require(accounts[msg.sender].times > 0, "You do not have locked tokens");
        require(accounts[msg.sender].releaseTime < block.timestamp, "It's not time to release your token");
        accounts[msg.sender].times = accounts[msg.sender].times - 1;
        accounts[msg.sender].releaseTime = accounts[msg.sender].releaseTime + accounts[msg.sender].interval;
        token.transfer(msg.sender, accounts[msg.sender].amount);
    }
    
    function getLockedTokensReleaseTime(address account) public view returns (uint x) {
	    return accounts[account].releaseTime;
    }
}