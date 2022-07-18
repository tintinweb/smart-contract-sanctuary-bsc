//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "./IPresaleDatabase.sol";
import "./Cloneable.sol";
import "./IERC20.sol";

interface ILiquidityPairer {
    function pair(address projectToken, address backingToken, address DEX) external;
}

contract PresaleData {

    // Has Liquidity Been Provided yet?
    bool public liquidityHasBeenAdded;

    // block presale is finished
    uint256 public presaleFinishedBlockNumber;
   
    // Presale Has Started
    bool public presaleStarted;
    bool public refundEnabled;

    // Presale Database For Fetching Dynamic Data Such As Fees And Fee Recipients
    IPresaleDatabase internal database;

    // whitelist enabled
    bool public whitelistEnabled;

    // User -> Contribution
    struct User {
        uint256 contribution;
        uint256 toClaim;
        bool isWhitelisted;
    }
    mapping ( address => User ) public userInfo;

    // Token and backing tracking
    uint256 public totalValueRegistered; // Total Registered Contributions, Prevents selfdestruct() attacks
    uint256 public totalTokensToAllocate; // total tokens to give to users as rewards
    uint256 public valueRegisteredWhenEnded; // value registered when presale is ended

    modifier onlyOwner(){
        require(
            database.isOwner(msg.sender, address(this)),
            'Only Owner'
        );
        _;
    }
}

contract Presale is PresaleData, Cloneable {



    ///////////////////////////////////////
    ///////    PUBLIC FUNCTIONS    ////////
    ///////////////////////////////////////


    function register() external payable {
        require(
            isWETH(),
            'Only WETH'
        );
        _register(msg.sender, msg.value);
    }

    function register(uint256 amount) external {
        require(
            !isWETH(),
            'Only Non WETH'
        );

        // transfer in tokens, noting amount received
        uint before = backingTokenBalance();
        require(
            IERC20(backingToken()).transferFrom(
                msg.sender,
                address(this),
                amount
            ),
            'Failure On Transfer From'
        );
        uint received = backingTokenBalance() - before;
        require(
            received <= amount, 
            'Transfer Failure'
        );

        _register(msg.sender, received);
    }

    function claim() external {
        require(
            timeLeftUntilExpiration() == 0,
            'Presale Has Not Expired'
        );
        require(
            liquidityHasBeenAdded,
            'Liquidity Has Not Yet Been Added'
        );
        require(
            userInfo[msg.sender].contribution > 0,
            'Zero Contribution'
        );
        require(
            !refundEnabled,
            'Refund Is Enabled'
        );

        // amount to claim
        uint256 claimAmount = pendingClaim(msg.sender);
        
        // total value registered
        totalValueRegistered -= userInfo[msg.sender].contribution;

        // delete user data
        delete userInfo[msg.sender];

        // send claim to user
        _sendToken(presaleToken(), msg.sender, claimAmount);
    }

    function claimRefund() external {
        require(
            timeLeftUntilExpiration() == 0,
            'Presale Has Not Expired'
        );
        require(
            refundEnabled,
            'Refund Not Enabled'
        );
        uint256 contribution = userInfo[msg.sender].contribution;
        require(
            contribution > 0,
            'Zero To Refund'
        );
        require(
            !liquidityHasBeenAdded,
            'Liquidity Has Already Been Added'
        );

        // delete contribution for sender
        delete userInfo[msg.sender];

        // reduce tokens to allocate
        totalValueRegistered  -= contribution;

        // refund sender their backing
        _sendBacking(msg.sender, contribution);
    }

    receive() external payable {
        require(
            isWETH(),
            'Only WETH'
        );
        _register(msg.sender, msg.value);
    }

    ///////////////////////////////////////
    //////    INTERNAL FUNCTIONS    ///////
    ///////////////////////////////////////

    function _register(address user, uint256 value) internal {
        require(
            value > 0,
            'Cannot Register With Zero Value'
        );
        require(
            msg.sender == tx.origin,
            'Cannot Register A Proxy Or Contract'
        );
        require(
            timeLeftUntilExpiration() > 0,
            'Presale Has Expired'
        );
        require(
            presaleStarted,
            'Presale Has Not Started'
        );
        if (whitelistEnabled) {
            require(
                isWhiteListed(user),
                'Sender Not Whitelisted'
            );
        }

        // register purchase in database
        database.registerParticipation(user, value);

        // add value to contributors and total
        userInfo[user].contribution += value;
        totalValueRegistered += value;

        // increment number of tokens user can claim
        uint256 tokensToAllocate = ( value * exchangeRate() ) / 10**18;
        userInfo[user].toClaim += tokensToAllocate;
        totalTokensToAllocate += tokensToAllocate;

        // ensure requirements
        require(
            userInfo[user].contribution >= minContribution(),
            'Minimum Contribution Not Met'
        );
        require(
            userInfo[user].contribution <= maxContribution(),
            'Max Contribution Exceeded'
        );
        require(
            totalValueRegistered <= hardCap(),
            'Hard Cap Exceeded'
        );
    }

    function _sendToken(address token, address to, uint val) internal {
        require(
            IERC20(token).transfer(
                to,
                val
            ),
            'Failure On Token Transfer'
        );
    }

    function _sendBacking(address to, uint val) internal {
        if (isWETH()) {
            (bool s,) = payable(to).call{value: val}("");
            require(s, 'Failure On ETH Transfer');
        } else {
            _sendToken(backingToken(), to, val);
        }
    }


    ///////////////////////////////////////
    ////////    READ FUNCTIONS    /////////
    ///////////////////////////////////////

    function hardCap() public view returns (uint256) {
        return database.getHardCap(address(this));
    }

    function maxContribution() public view returns (uint256) {
        return database.getMaxContribution(address(this));
    }

    function minContribution() public view returns (uint256) {
        return database.getMinContribution(address(this));
    }

    function exchangeRate() public view returns (uint256) {
        return database.getExchangeRate(address(this));
    }

    function liquidityRate() public view returns (uint256) {
        return database.getLiquidityRate(address(this));
    }

    function duration() public view returns (uint256) {
        return database.getDuration(address(this));
    }

    function backingToken() public view returns (address) {
        return database.getBackingToken(address(this));
    }

    function presaleToken() public view returns (address) {
        return database.getPresaleToken(address(this));
    }

    function DEX() public view returns (address) {
        return database.getDEX(address(this));
    }

    function saleOwner() public view returns (address) {
        return database.getSaleOwner(address(this));
    }

    function isWETH() public view returns (bool) {
        return database.isWETH(address(this));
    }

    function timeLeftUntilExpiration() public view returns (uint256) {
        return presaleFinishedBlockNumber > block.number ? presaleFinishedBlockNumber - block.number : 0;
    }

    function presaleTokenBalance() public view returns (uint256) {
        return IERC20(presaleToken()).balanceOf(address(this));
    }

    function backingTokenBalance() public view returns (uint256) {
        return isWETH() ? address(this).balance : IERC20(backingToken()).balanceOf(address(this));
    }

    function isDynamic() public view returns (bool) {
        return database.isDynamic(address(this));
    }

    function isWhiteListed(address user) public view returns (bool) {
        return userInfo[user].isWhitelisted || database.isWhitelisted(user);
    }

    function userContribution(address user) external view returns (uint256) {
        return userInfo[user].contribution;
    }

    function pendingClaim(address user) public view returns (uint256) {
        if (userInfo[user].contribution == 0) {
            return 0;
        }
        
        if (isDynamic()) {
            if (liquidityHasBeenAdded) {
                return ( userInfo[msg.sender].contribution * presaleTokenBalance() ) / totalValueRegistered;
            } else {
                return ( userInfo[msg.sender].contribution * presaleTokenBalance() ) / ( 2 * totalValueRegistered );
            }
        }
        return userInfo[user].toClaim;
    }

    function tokensRequiredToStart() public view returns (uint256) {
        uint hCapMax = ( hardCap() * exchangeRate() ) / 10**18;
        uint liquidityMax = ( hardCap() * liquidityRate() ) / 10**18;
        return hCapMax + liquidityMax;
    }

    function tokensForLiquidity() internal view returns (uint256) {
        if (isDynamic()) {
            return presaleTokenBalance() / 2;
        } else {
            return ( totalValueRegistered * liquidityRate() ) / 10**18;
        }
    }

    function launchPrice() public view returns (uint256) {
        if (isDynamic()) {
            uint tForLiquidity = liquidityHasBeenAdded ? presaleTokenBalance() : presaleTokenBalance() / 2;
            return ( totalValueRegistered * 10**18 ) / tForLiquidity;
        } else {
            return 10**36 / liquidityRate();
        }
    }

    ///////////////////////////////////////
    ////////    OWNER FUNCTIONS    ////////
    ///////////////////////////////////////

    function disableWhitelist() external onlyOwner {
        whitelistEnabled = false;
    }

    function whitelist(address[] calldata users) external onlyOwner {
        for (uint i = 0; i < users.length; i++) {
            userInfo[users[i]].isWhitelisted = true;
        }
        if (!whitelistEnabled) {
            whitelistEnabled = true;
        }
    }

    function unWhitelist(address[] calldata users) external onlyOwner {
        for (uint i = 0; i < users.length; i++) {
            userInfo[users[i]].isWhitelisted = false;
        }
    }

    function enableRefund() external onlyOwner {
        refundEnabled = true;
    }

    function end() external onlyOwner {
        require(
            timeLeftUntilExpiration() == 0,
            'Presale Has Not Expired'
        );
        require(
            !liquidityHasBeenAdded,
            'Liquidity Has Already Been Added'
        );

        // add liquidity to true
        liquidityHasBeenAdded = true;

        // set value registered to current balance
        valueRegisteredWhenEnded = totalValueRegistered;

        // Presale Token
        address token = presaleToken();

        // send assets to Pairer and Pair Them
        address pairer = database.liquidityPairer();
        if (pairer != address(0)) {
            
            // transfer presale tokens to presale
            IERC20(token).transfer(pairer, tokensForLiquidity());

            // send backing asset to pairer
            _sendBacking(
                pairer, 
                backingTokenBalance()
            );

            // call function to pair liquidity between tokens
            ILiquidityPairer(pairer).pair(token, backingToken(), DEX());
        }

        // end presale in database
        database.endPresale(totalValueRegistered);

        // presale tokens left in contract
        if (isDynamic() == false) {
            uint256 remainingBalance = presaleTokenBalance();
            if (remainingBalance > totalTokensToAllocate) {
                _sendToken(
                    token, 
                    saleOwner(), 
                    remainingBalance - totalTokensToAllocate
                );
            }
        }
    }

    function start() external onlyOwner {
        require(
            presaleTokenBalance() >= tokensRequiredToStart(),
            'Token QTY Needed Are Not In Contract'
        );

        // start sale and set ending block number
        presaleStarted = true;
        presaleFinishedBlockNumber = block.number + duration();
        
        // start presale in database
        database.startPresale();
    }
}